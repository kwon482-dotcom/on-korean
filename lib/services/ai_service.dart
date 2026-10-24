import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/word_model.dart';
import 'locale_service.dart';
import 'remote_config_service.dart';

class AiService {
  // 💡 Firebase Remote Config를 통해 동적 주입 및 핫픽스되는 최신 API 키 반환
  static String get apiKey {
    final keys = RemoteConfigService.getGeminiApiKeys();
    return keys.isNotEmpty ? keys.first : '';
  }

  /// 💡 한국어 예문 엄격 유효성 검증 (순수 한국어 문장 검증 및 복붙 방지)
  static bool isValidKoreanSentence(String ko, [String? translation]) {
    final cleanKo = ko.trim();
    if (cleanKo.isEmpty) return false;

    // 1. 번역문과 한국어 원문이 글자 그대로 동일하면 복붙 결함
    if (translation != null && translation.trim().isNotEmpty) {
      if (cleanKo == translation.trim()) return false;
    }

    // 2. 한글 음절(가-힣)이 최소 1자 이상 포함되어야 함
    final hangulRegex = RegExp(r'[\uAC00-\uD7A3]');
    if (!hangulRegex.hasMatch(cleanKo)) {
      return false;
    }

    return true;
  }

  /// 💡 테스트 및 호환용 영어 검증 메서드
  static bool isValidEnglishSentence(String en, [String? translation]) {
    final cleanEn = en.trim();
    if (cleanEn.isEmpty) return false;

    if (translation != null && translation.trim().isNotEmpty) {
      if (cleanEn.toLowerCase() == translation.trim().toLowerCase()) return false;
    }

    final hangulRegex = RegExp(r'[\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F]');
    if (hangulRegex.hasMatch(cleanEn)) return false;

    final kanaRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]');
    if (kanaRegex.hasMatch(cleanEn)) return false;

    final englishRegex = RegExp(r'[a-zA-Z]');
    if (!englishRegex.hasMatch(cleanEn)) return false;

    final words = cleanEn.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (words.length < 2) return false;

    return true;
  }

  /// 💡 테스트 및 호환용 일본어 검증 메서드
  static bool isValidJapaneseSentence(String ja, [String? translation]) {
    final cleanJa = ja.trim();
    if (cleanJa.isEmpty) return false;
    if (translation != null && translation.trim().isNotEmpty) {
      if (cleanJa == translation.trim()) return false;
    }
    final hangulRegex = RegExp(r'[\uAC00-\uD7A3\u1100-\u11FF\u3130-\u318F]');
    if (hangulRegex.hasMatch(cleanJa)) return false;
    final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');
    return japaneseRegex.hasMatch(cleanJa);
  }

  static Future<Map<String, String>> generateExample(WordModel word) async {
    final keys = RemoteConfigService.getGeminiApiKeys();
    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isKo = LocaleService.currentLocale.value.languageCode == 'ko';
    if (keys.isEmpty || keys.first.isEmpty) {
      final msg = isJa
          ? 'Gemini APIキーが設定されていません。'
          : (isKo ? 'Gemini API 키가 설정되지 않았습니다.' : 'Gemini API key is not configured.');
      return {'ko': '', 'en': msg, 'ja': msg, 'trans': msg};
    }

    final models = RemoteConfigService.getGeminiModels();

    final meaningTarget = word.meaningEn ?? word.meaning;

    final prompt = '''
You are an expert Korean language teacher.
Create ONE natural, vivid example sentence in Korean using the vocabulary word "${word.word}" (Meaning: $meaningTarget, Level: ${word.level}).
Also provide natural English translation and Japanese translation.

[STRICT OUTPUT FORMAT]:
Output ONLY a raw valid JSON object with exactly these keys:
{
  "ko": "Korean sentence here",
  "en": "English translation here",
  "ja": "Japanese translation here"
}
Do NOT include markdown code blocks or extra text.
''';

    for (final apiKey in keys) {
      if (apiKey.trim().isEmpty) continue;

      for (final model in models) {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        try {
          final response = await http
              .post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'contents': [
                    {
                      'parts': [
                        {'text': prompt},
                      ],
                    },
                  ],
                  'generationConfig': {
                    'temperature': 0.7,
                    'topK': 40,
                    'topP': 0.95,
                    'maxOutputTokens': 1024,
                    'responseMimeType': 'application/json',
                  },
                }),
              )
              .timeout(const Duration(seconds: 12));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final text =
                data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

            if (text.isNotEmpty) {
              String cleaned = text.trim();
              if (cleaned.startsWith('```json')) {
                cleaned = cleaned.substring(7);
              }
              if (cleaned.startsWith('```')) {
                cleaned = cleaned.substring(3);
              }
              if (cleaned.endsWith('```')) {
                cleaned = cleaned.substring(0, cleaned.length - 3);
              }
              cleaned = cleaned.trim();

              try {
                final json = jsonDecode(cleaned);
                final ko = (json['ko'] ?? json['korean'] ?? json['sentence'] ?? '')
                    .toString()
                    .trim();
                final en = (json['en'] ?? json['english'] ?? '').toString().trim();
                final ja = (json['ja'] ?? json['japanese'] ?? '').toString().trim();

                if (isValidKoreanSentence(ko, en)) {
                  final trans = isJa ? (ja.isNotEmpty ? ja : en) : (isKo ? ko : (en.isNotEmpty ? en : ja));
                  return {
                    'ko': ko,
                    'en': en,
                    'ja': ja,
                    'trans': trans,
                  };
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
      }
    }

    final fallbackKo = '${word.word}을(를) 활용한 실전 문장입니다.';
    final fallbackEn = 'Example sentence using ${word.word}.';
    final fallbackJa = '${word.word}を使った例文です。';
    return {
      'ko': fallbackKo,
      'en': fallbackEn,
      'ja': fallbackJa,
      'trans': isJa ? fallbackJa : (isKo ? fallbackKo : fallbackEn),
    };
  }
}
