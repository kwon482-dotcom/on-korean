import 'dart:async';

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

  // 💡 단어 카드 발음 전용 세션 ID (사용자가 다른 단어로 넘어가거나 정지 시 2회 반복 취소용)
  static int _activeSessionId = 0;
  static Completer<void>? _speakCompleter;

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
        if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
          _speakCompleter!.complete();
        }
      });
      _flutterTts.setCompletionHandler(() {
        if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
          _speakCompleter!.complete();
        }
      });
      _flutterTts.setCancelHandler(() {
        if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
          _speakCompleter!.complete();
        }
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

      // 💡 성별 맞춤 피치 설정: 여성 1.05 (밝고 또렷함), 남성 0.98 (자연스럽고 신뢰감 있는 남성 톤)
      final double basePitch = voiceGender == 'male' ? 0.98 : 1.05;
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
    final double basePitch = voiceGender == 'male' ? 0.98 : 1.05;
    await _flutterTts.setPitch(basePitch);
  }

  static Future<void> stop() async {
    _activeSessionId++;
    if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
      _speakCompleter!.complete();
    }
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  // 💡 안드로이드(구글/삼성 SMT) 및 iOS 기기 내 최적의 고품질 신경망 한국어 보이스 자동 탐색 및 적용
  // - Google 음성 1번 (koc): 여성 메인
  // - Google 음성 2번 (ism / kod): 여성 서브
  // - Google 음성 3번 (kob): 남성 메인
  // - Google 음성 4번 (koa): 남성 서브
  // - iOS: yuna (여성) / minho (남성)
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

        // 명확한 여성/남성 식별자 판별
        final isFemaleVoice = name.contains('koc') ||
            name.contains('ism') ||
            name.contains('kod') ||
            name.contains('yuna') ||
            name.contains('유나') ||
            name.contains('female') ||
            name.contains('여성') ||
            name.contains('#female') ||
            name.contains('_female') ||
            name.contains('-female') ||
            name.contains('kor-kor-female');

        final isMaleVoice = name.contains('kob') ||
            name.contains('koa') ||
            name.contains('minho') ||
            name.contains('민호') ||
            name.contains('male') ||
            name.contains('남성') ||
            name.contains('#male') ||
            name.contains('_male') ||
            name.contains('-male') ||
            name.contains('kor-kor-male');

        if (wantFemale) {
          // 남성 보이스는 즉시 원천 차단 (-999점)
          if (isMaleVoice) score -= 999;
          if (isFemaleVoice) score += 60;

          // 1순위: Google 음성 1번 (ko-kr-x-koc)
          if (name.contains('ko-kr-x-koc') || name.contains('koc')) score += 150;
          // 2순위: Apple iOS 유나 (yuna)
          if (name.contains('yuna') || name.contains('유나')) score += 120;
          // 3순위: Google 음성 2번 (ism, kod)
          if (name.contains('ko-kr-x-ism') || name.contains('ko-kr-x-kod')) score += 80;
        } else {
          // 여성 보이스(koc, ism, kod, yuna 등)는 남성 선택 시 -999점으로 완전 차단!
          if (isFemaleVoice) score -= 999;
          if (isMaleVoice) score += 60;

          // 1순위: Google 음성 3번 (ko-kr-x-kob)
          if (name.contains('ko-kr-x-kob') || name.contains('kob')) score += 150;
          // 2순위: Google 음성 4번 (ko-kr-x-koa)
          if (name.contains('ko-kr-x-koa') || name.contains('koa')) score += 130;
          // 3순위: Apple iOS 민호 (minho)
          if (name.contains('minho') || name.contains('민호')) score += 120;
          // 삼성 SMT 남성
          if (name.contains('kor-kor-male')) score += 100;
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

  // 💡 단어/문장 텍스트에서 순수 한국어 발음 대상 추출
  static String getPronounceableText(WordModel word) {
    // 로마자 발음 표기 [ ... ] 또는 주석 ( ... ) 제거 후 순수 한국어 본문 추출
    return word.word.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'\(.*?\)'), '').trim();
  }

  // 💡 WordModel 객체를 안전하게 한국어로 발음 (단어 2회 반복 설정 지원)
  static Future<void> speakWord(WordModel word, {double? rate}) async {
    final text = getPronounceableText(word);
    final sessionId = ++_activeSessionId;

    // 1회차 발음 실행
    await _executeSpeak(text, rate: rate);

    // 단어 2회 반복 설정이 활성화되어 있고, 사용자가 다음 단어로 넘기지 않은 경우
    if (repeatWordTwice && _activeSessionId == sessionId) {
      final effectiveRate = rate ?? currentRate;
      // 글자 수 기반 예상 소요 시간 계산 (1자당 약 280ms)
      final estimatedMillis = ((text.length * 280) / effectiveRate).clamp(600.0, 4000.0).toInt();

      // 1회차 발음 종료 대기 (네이티브 완료 이벤트 또는 예상 발음 시간)
      await _speakCompleter?.future.timeout(
        Duration(milliseconds: estimatedMillis),
        onTimeout: () => null,
      );

      // 1회차와 2회차 발음 사이 자연스러운 호흡 간격 (0.45초)
      await Future.delayed(const Duration(milliseconds: 450));

      // 딜레이 동안 사용자가 다른 카드로 넘기거나 정지하지 않았는지 최종 확인
      if (_activeSessionId == sessionId) {
        await _executeSpeak(text, rate: rate);
      }
    }
  }

  // 💡 일반 텍스트 발음 (예문, 안내 음성 등 단일 재생)
  static Future<void> speak(String text, {double? rate}) async {
    _activeSessionId++; // 기존 대기 중인 단어 반복 세션 무효화
    await _executeSpeak(text, rate: rate);
  }

  // 💡 실제 네이티브 TTS 엔진을 호출하는 내부 공통 메서드
  static Future<void> _executeSpeak(String text, {double? rate}) async {
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

      // 이전 completer 정리 및 새 발음 완료 대기 completer 생성
      if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
        _speakCompleter!.complete();
      }
      _speakCompleter = Completer<void>();

      final effectiveRate = rate ?? currentRate;
      await _flutterTts.setSpeechRate((effectiveRate * 0.45).clamp(0.1, 1.0));
      final double basePitch = voiceGender == 'male' ? 0.98 : 1.05;
      await _flutterTts.setPitch(basePitch);
      await _flutterTts.speak(clean);
    } catch (e) {
      debugPrint('[TTS] 재생 오류: $e');
      if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
        _speakCompleter!.complete();
      }
    }
  }
}
