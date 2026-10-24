import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/word_model.dart';
import 'locale_service.dart';
import 'word_service.dart';

/// 홈 화면 2x1 단어 플래시카드 위젯 서비스
class WidgetService {
  static const String appWidgetProviderName = 'OnKoreanWidgetProvider';

  /// 위젯 데이터 갱신 (낱자 한자나 문법을 제외한 실전 '어휘' 위주 출제)
  static Future<void> updateWidget() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      final all = WordService.getAllWords();
      if (all.isEmpty) return;

      // 💡 홈 화면 위젯은 낱자 한자(부수/획수 등 긴 메타정보)나 문법 문형이 아닌 실전 '어휘(단어)'로 한정
      final vocabOnly = all.where((w) {
        final isKanji = w.partOfSpeech == '한자' || w.level.contains('한자');
        final isGrammar = w.partOfSpeech == '문법' || w.level.contains('문법');
        return !isKanji && !isGrammar;
      }).toList();

      final targetBase = vocabOnly.isNotEmpty ? vocabOnly : all;

      // 1순위: 아직 외우지 않은 미마스터 어휘
      final unmastered = targetBase.where((w) => !w.isMastered).toList();
      List<WordModel> pool;
      if (unmastered.isNotEmpty) {
        pool = unmastered;
      } else {
        // 2순위: 북마크된 어휘
        final bookmarked = targetBase.where((w) => w.isBookmarked).toList();
        if (bookmarked.isNotEmpty) {
          pool = bookmarked;
        } else {
          // 3순위: 전체 어휘
          pool = targetBase;
        }
      }

      final random = Random();
      final word = pool[random.nextInt(pool.length)];

      // 💡 백그라운드 주기적(1시간) 위젯 자동 갱신용 단어 풀 캐싱 (최대 100단어)
      final isEn = LocaleService.currentLocale.value.languageCode == 'en';
      final shuffledPool = List<WordModel>.from(pool)..shuffle(random);
      final cachePool = shuffledPool.take(100).map((w) {
        final rawMeaning = (isEn && w.meaningEn != null && w.meaningEn!.isNotEmpty)
            ? w.meaningEn!
            : w.meaning;
        // 위젯 영역에 맞게 첫 줄의 깔끔한 핵심 의미만 추출 (줄바꿈 방지)
        final meaning = rawMeaning.split('\n')[0].trim();
        return {
          'level': _getWidgetLevelLabel(w, isEn),
          'word': w.word,
          'furigana': w.furigana,
          'meaning': meaning,
        };
      }).toList();

      await HomeWidget.saveWidgetData<String>(
        'widget_words_pool',
        jsonEncode(cachePool),
      );

      await updateWithWord(word);
    } catch (e) {
      debugPrint('[WidgetService] 위젯 업데이트 오류: $e');
    }
  }

  /// 특정 단어로 위젯 즉시 갱신
  static Future<void> updateWithWord(WordModel word) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    try {
      final isEn = LocaleService.currentLocale.value.languageCode == 'en';
      final rawMeaning = (isEn && word.meaningEn != null && word.meaningEn!.isNotEmpty)
          ? word.meaningEn!
          : word.meaning;
      // 위젯 영역에 맞게 첫 줄의 깔끔한 핵심 의미만 추출 (줄바꿈 방지)
      final meaning = rawMeaning.split('\n')[0].trim();
      final levelLabel = _getWidgetLevelLabel(word, isEn);

      await HomeWidget.saveWidgetData<String>('widget_level', levelLabel);
      await HomeWidget.saveWidgetData<String>('widget_word', word.word);
      await HomeWidget.saveWidgetData<String>('widget_furigana', word.furigana);
      await HomeWidget.saveWidgetData<String>('widget_meaning', meaning);
      await HomeWidget.saveWidgetData<bool>('widget_manual_updated', true);

      await HomeWidget.updateWidget(
        name: appWidgetProviderName,
        androidName: appWidgetProviderName,
      );
    } catch (e) {
      debugPrint('[WidgetService] 위젯 단어 동기화 오류: $e');
    }
  }

  /// 2x1 소형 위젯 뱃지 크기에 맞춘 간결한 급수/카테고리 라벨
  static String _getWidgetLevelLabel(WordModel word, bool isEn) {
    switch (word.level) {
      case '비즈니스 실무 어휘':
      case '비즈니스 실전 경어':
      case '비즈니스 일본어':
        return isEn ? 'Business' : '비즈니스';
      case '여행 일본어':
        return isEn ? 'Travel' : '여행';
      case '생활 필수 가타카나':
        return isEn ? 'Katakana' : '가타카나';
      case '초밥집 & 생선 한자':
        return isEn ? 'Sushi' : '초밥/생선';
      case 'IT 실무 & 네트워크':
        return isEn ? 'IT' : 'IT/개발';
      default:
        return word.localizedLevel;
    }
  }
}
