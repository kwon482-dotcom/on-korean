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
  static const String _prefRateKey = 'tts_speech_rate_v2';
  static const String _prefAutoPlayKey = 'tts_auto_play_enabled';
  static const String _prefRepeatWordTwiceKey = 'tts_repeat_word_twice';

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

      _flutterTts.setErrorHandler((msg) {
        debugPrint('[TTS] 음성 이벤트 안내: $msg');
      });

      if (!kIsWeb) {
        try {
          final dynamic engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      await _flutterTts.setLanguage('ko-KR');
      // 네이티브 TTS 엔진 속도 환산 (1.0x -> 0.48 엔진 속도)
      await _flutterTts.setSpeechRate((currentRate * 0.48).clamp(0.1, 1.0));
      await _flutterTts.setVolume(1.0);
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
    // 네이티브 TTS 엔진 속도 환산 (1.0x -> 0.48 엔진 속도)
    await _flutterTts.setSpeechRate((newRate * 0.48).clamp(0.1, 1.0));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefRateKey, newRate);
  }

  static Future<void> setRepeatWordTwice(bool enabled) async {
    repeatWordTwice = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRepeatWordTwiceKey, enabled);
  }

  static Future<void> stop() async {
    _speakWordSession++;
    try {
      await _flutterTts.stop();
    } catch (_) {}
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
    try {
      // 1. 발음기호 대괄호 [ ... ] 및 슬래시 / ... / 제거
      String clean = text.replaceAll(RegExp(r'\[.*?\]'), ' ').replaceAll(RegExp(r'/.*?/'), ' ');
      // 2. 한글 음절/자모를 우선적으로 발음
      clean = clean.replaceAll(RegExp(r'[〜~+]'), ' ');
      clean = clean.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (clean.isEmpty) clean = text;

      await _init();
      await _flutterTts.stop();
      final effectiveRate = rate ?? currentRate;
      await _flutterTts.setSpeechRate((effectiveRate * 0.48).clamp(0.1, 1.0));
      await _flutterTts.speak(clean);
    } catch (e) {
      debugPrint('[TTS] 재생 오류: $e');
    }
  }
}
