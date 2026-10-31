import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_model.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _initialized = false;
  // 💡 사용자가 인지하는 기준 배속: 1.0x (표준)
  static double currentRate = 1.0;
  static bool isAutoPlay = true;
  static bool repeatWordTwice = false;
  // 💡 음성 성별 선택: 'female'(여성) | 'male'(남성)
  static String voiceGender = 'female';
  static const String _prefRateKey = 'tts_speech_rate_v2';
  static const String _prefAutoPlayKey = 'tts_auto_play_enabled';
  static const String _prefRepeatWordTwiceKey = 'tts_repeat_word_twice';
  static const String _prefVoiceGenderKey = 'tts_voice_gender';

  static Future<void> init() async {
    await _init();
  }

  static Future<void> _init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      currentRate = prefs.getDouble(_prefRateKey) ?? 1.0;
      isAutoPlay = prefs.getBool(_prefAutoPlayKey) ?? true;
      repeatWordTwice = prefs.getBool(_prefRepeatWordTwiceKey) ?? false;
      voiceGender = prefs.getString(_prefVoiceGenderKey) ?? 'female';

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TTS] 음성 이벤트 안내: $msg');
      });

      if (!kIsWeb) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          try {
            final dynamic engines = await _flutterTts.getEngines;
            if (engines is List && engines.contains('com.google.android.tts')) {
              await _flutterTts.setEngine('com.google.android.tts');
            }
          } catch (_) {}
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          try {
            await _flutterTts.setSharedInstance(true);
            await _flutterTts.setIosAudioCategory(
              IosTextToSpeechAudioCategory.playback,
              [
                IosTextToSpeechAudioCategoryOptions.allowBluetooth,
                IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
                IosTextToSpeechAudioCategoryOptions.mixWithOthers,
                IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              ],
              IosTextToSpeechAudioMode.defaultMode,
            );
          } catch (_) {}
        }
      }

      await _flutterTts.setLanguage('ko-KR');
      // 💡 안드로이드 및 iOS 고품질 신경망(Neural/Enhanced) 보이스 자동 탐색 및 지정
      await _selectBestKoreanVoice();

      // 💡 성별 맞춤 피치 설정: 여성 1.06 (밝고 또렷함), 남성 0.98 (차분하고 신뢰감 있는 중저음)
      final double basePitch = voiceGender == 'male' ? 0.98 : 1.06;
      await _flutterTts.setPitch(basePitch);
      await _flutterTts.setVolume(1.0);
      // 네이티브 TTS 엔진 속도 환산 (1.0x -> 0.45 엔진 속도)
      await _flutterTts.setSpeechRate((currentRate * 0.45).clamp(0.1, 1.0));
      if (!kIsWeb) {
        await _flutterTts.awaitSynthCompletion(true);
      }
      _initialized = true;
    } catch (e) {
      debugPrint('[TTS] 초기화 실패: $e');
    }
  }

  static Future<void> setAutoPlay(bool enabled) async {
    isAutoPlay = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoPlayKey, enabled);
  }

  static Future<void> setRate(double newRate) async {
    currentRate = newRate;
    // 네이티브 TTS 엔진 속도 환산 (1.0x -> 0.45 엔진 속도)
    await _flutterTts.setSpeechRate((newRate * 0.45).clamp(0.1, 1.0));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefRateKey, newRate);
  }

  static Future<void> setRepeatWordTwice(bool enabled) async {
    repeatWordTwice = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRepeatWordTwiceKey, enabled);
  }

  // 💡 음성 성별 변경 및 최적화 보이스 재선택
  static Future<void> setVoiceGender(String gender) async {
    voiceGender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefVoiceGenderKey, gender);
    await _selectBestKoreanVoice();
    final double basePitch = voiceGender == 'male' ? 0.98 : 1.06;
    await _flutterTts.setPitch(basePitch);
  }

  static Future<void> stop() async {
    _speakWordSession++;
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  // 💡 안드로이드 및 iOS 기기 내 최적의 고품질 신경망(Neural/Enhanced) 한국어 보이스 자동 탐색 및 적용
  static Future<void> _selectBestKoreanVoice() async {
    if (kIsWeb) return;
    try {
      final dynamic rawVoices = await _flutterTts.getVoices;
      if (rawVoices is! List || rawVoices.isEmpty) return;

      Map<String, dynamic>? bestVoice;
      int highestScore = -9999;
      final wantFemale = voiceGender == 'female';

      for (var v in rawVoices) {
        if (v is! Map) continue;
        final name = (v['name'] ?? '').toString().toLowerCase();
        final locale = (v['locale'] ?? '').toString().toLowerCase().replaceAll('_', '-');

        // 한국어(ko-KR, ko 등) 보이스 필터링
        if (!locale.startsWith('ko')) continue;

        int score = 10; // 기본 한국어 보이스 점수

        // 성별 판별
        final gender = (v['gender'] ?? '').toString().toLowerCase();
        final isMale = gender == 'male' ||
            name.contains('male') ||
            name.contains('-kob') ||
            name.contains('-koa') ||
            name.contains('#male') ||
            name.contains('_male') ||
            name.contains('minho') ||
            name.contains('민호');
        final isFemale = gender == 'female' ||
            name.contains('female') ||
            name.contains('#female') ||
            name.contains('_female') ||
            name.contains('-koc') ||
            name.contains('-kod') ||
            name.contains('-ism') ||
            name.contains('yuna') ||
            name.contains('유나');

        if (wantFemale) {
          if (isMale) score -= 100;
          if (isFemale) score += 60;
          // Android: ko-kr-x-koc, ko-kr-x-kod, ko-kr-x-ism (+70)
          if (name.contains('ko-kr-x-koc') ||
              name.contains('ko-kr-x-kod') ||
              name.contains('ko-kr-x-ism')) {
            score += 70;
          }
          // iOS: yuna (+60)
          if (name.contains('yuna') || name.contains('유나')) {
            score += 60;
          }
        } else {
          // 남성 보이스 선호 시
          if (isFemale) score -= 100;
          if (isMale) score += 60;
          // Android: ko-kr-x-kob, ko-kr-x-koa (+70)
          if (name.contains('ko-kr-x-kob') || name.contains('ko-kr-x-koa')) {
            score += 70;
          }
          // iOS: minho (+60)
          if (name.contains('minho') || name.contains('민호')) {
            score += 60;
          }
        }

        // 공통 고품질 가산점
        if (name.contains('network')) score += 35;
        if (name.contains('neural')) score += 35;
        if (name.contains('wavenet')) score += 35;
        if (name.contains('enhanced')) score += 35;
        if (name.contains('premium')) score += 35;
        if (name.contains('natural')) score += 30;

        final quality = (v['quality'] ?? '').toString();
        if (quality == '500' || quality == 'enhanced') score += 35;
        if (name.contains('compact')) score -= 30;

        if (score > highestScore) {
          highestScore = score;
          bestVoice = Map<String, dynamic>.from(v);
        }
      }

      if (bestVoice != null) {
        final voiceMap = <String, String>{
          'name': bestVoice['name'].toString(),
          'locale': bestVoice['locale'].toString(),
        };
        await _flutterTts.setVoice(voiceMap);
        debugPrint('[TTS] $voiceGender 한국어 고품질 보이스 자동 선택 완료: ${voiceMap['name']} (score: $highestScore)');
      }
    } catch (e) {
      debugPrint('[TTS] 보이스 자동 선택 예외(기본값 유지): $e');
    }
  }

  static int _speakWordSession = 0;

  // 💡 단어/문장 텍스트에서 순수 한국어 발음 대상 추출
  static String getPronounceableText(WordModel word) {
    // 로마자 발음 표기 [ ... ] 또는 주석 ( ... ) 제거 후 순수 한국어 본문 추출
    return word.word.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'\(.*?\)'), '').trim();
  }

  // 💡 WordModel 객체를 안전하게 한국어로 발음 (단어 2회 반복 설정 지원)
  static Future<void> speakWord(WordModel word, {double? rate}) async {
    final text = getPronounceableText(word);
    final currentSession = ++_speakWordSession;
    await speak(text, rate: rate);
    if (repeatWordTwice) {
      await Future.delayed(const Duration(milliseconds: 650));
      if (_speakWordSession == currentSession) {
        await speak(text, rate: rate);
      }
    }
  }

  // 💡 일반 텍스트 발음 (로마자 기호 및 영/일 번역 자동 필터링, ko-KR 음성 출력)
  static Future<void> speak(String text, {double? rate}) async {
    _speakWordSession++;
    try {
      // 1. 발음기호 대괄호 [ ... ] 및 슬래시 / ... / 제거
      String clean = text.replaceAll(RegExp(r'\[.*?\]'), ' ').replaceAll(RegExp(r'/.*?/'), ' ');
      // 2. 한글 음절/자모를 우선적으로 발음 (물결표 및 덧셈 기호 제거)
      clean = clean.replaceAll(RegExp(r'[〜~+]'), ' ');
      // 3. 문장 부호(쉼표/마침표) 뒤 미세 호흡 공백 부여 (사람처럼 자연스러운 끊어 읽기)
      clean = clean.replaceAll('、', '、 ').replaceAll('，', '， ').replaceAll(',', ', ');
      clean = clean.replaceAll('。', '。 ').replaceAll('．', '． ').replaceAll('.', '. ');
      clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (clean.isEmpty) clean = text;

      await _init();
      await _flutterTts.stop();
      final effectiveRate = rate ?? currentRate;
      await _flutterTts.setSpeechRate((effectiveRate * 0.45).clamp(0.1, 1.0));
      final double basePitch = voiceGender == 'male' ? 0.98 : 1.06;
      await _flutterTts.setPitch(basePitch);
      await _flutterTts.speak(clean);
    } catch (e) {
      debugPrint('[TTS] 재생 오류: $e');
    }
  }
}
