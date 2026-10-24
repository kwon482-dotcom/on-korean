import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Firebase Remote Config 관리 서비스
/// Gemini API 키 원격 관리 및 다중 키 회전(키 로테이션/폴백)을 지원합니다.
class RemoteConfigService {
  // 💡 보안 조치: 실제 운영 키는 Firebase Remote Config 콘솔에서 안전하게 원격 배포됩니다.
  static const String _defaultApiKey = '';
  static const String _defaultModels =
      'gemini-3.5-flash-lite,gemini-flash-lite-latest,gemini-3.1-flash-lite,gemini-3.8-flash';

  static bool _isInitialized = false;

  /// Remote Config 초기화 및 최신 값 fetch
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await remoteConfig.setDefaults(<String, dynamic>{
        'gemini_api_key': _defaultApiKey,
        'gemini_models': _defaultModels,
        'daily_free_energy': 10,
        'ad_reward_energy': 5,
        'reading_energy_cost': 3,
        'example_energy_cost': 1,
      });

      final updated = await remoteConfig.fetchAndActivate();
      _isInitialized = true;
      debugPrint('[RemoteConfig] 활성화 완료 (업데이트 여부: $updated)');
    } catch (e) {
      debugPrint('[RemoteConfig] 초기화 또는 fetch 에러 (기본값 유지): $e');
    }
  }

  /// 등록된 Gemini API 키 목록을 반환합니다.
  /// Firebase Remote Config에 쉼표(,)나 세미콜론(;), 줄바꿈으로 여러 키를 등록한 경우
  /// 자동으로 리스트로 분리하여 쿼터 초과 시 순차 우회(로테이션)가 가능합니다.
  static List<String> getGeminiApiKeys() {
    if (_isInitialized) {
      try {
        final rawKeyString =
            FirebaseRemoteConfig.instance.getString('gemini_api_key');
        if (rawKeyString.isNotEmpty) {
          final keys = rawKeyString
              .split(RegExp(r'[,;\n]'))
              .map((k) => k.trim())
              .where((k) => k.isNotEmpty)
              .toList();
          if (keys.isNotEmpty) {
            return keys;
          }
        }
      } catch (e) {
        debugPrint('[RemoteConfig] 키 파싱 에러: $e');
      }
    }
    return _defaultApiKey.isNotEmpty ? [_defaultApiKey] : [];
  }

  /// 원격 관리되는 Gemini 모델 목록을 반환합니다.
  /// Firebase Remote Config에서 'gemini_models' 값을 수정하여
  /// 앱 재배포 없이 구글 신형 모델을 즉시 적용할 수 있습니다.
  static List<String> getGeminiModels() {
    if (_isInitialized) {
      try {
        final rawModelString =
            FirebaseRemoteConfig.instance.getString('gemini_models');
        if (rawModelString.isNotEmpty) {
          final models = rawModelString
              .split(RegExp(r'[,;\n]'))
              .map((m) => m.trim())
              .where((m) => m.isNotEmpty)
              .toList();
          if (models.isNotEmpty) {
            return models;
          }
        }
      } catch (e) {
        debugPrint('[RemoteConfig] 모델 파싱 에러: $e');
      }
    }
    return [
      'gemini-3.5-flash-lite',
      'gemini-flash-lite-latest',
      'gemini-3.1-flash-lite',
      'gemini-3.8-flash',
    ];
  }

  /// 매일 자정 충전되는 기본 무료 AI 에너지 (기본값: 10)
  static int getDailyFreeEnergy() {
    if (_isInitialized) {
      try {
        final val = FirebaseRemoteConfig.instance.getInt('daily_free_energy');
        if (val > 0) return val;
      } catch (e) {
        debugPrint('[RemoteConfig] daily_free_energy 파싱 에러: $e');
      }
    }
    return 10;
  }

  /// 보상형 광고 1회 시청 시 충전되는 에너지 (기본값: 5)
  static int getAdRewardEnergy() {
    if (_isInitialized) {
      try {
        final val = FirebaseRemoteConfig.instance.getInt('ad_reward_energy');
        if (val > 0) return val;
      } catch (e) {
        debugPrint('[RemoteConfig] ad_reward_energy 파싱 에러: $e');
      }
    }
    return 5;
  }

  /// 1분 독해 생성 시 소모되는 에너지 (기본값: 3)
  static int getReadingEnergyCost() {
    if (_isInitialized) {
      try {
        final val = FirebaseRemoteConfig.instance.getInt('reading_energy_cost');
        if (val > 0) return val;
      } catch (e) {
        debugPrint('[RemoteConfig] reading_energy_cost 파싱 에러: $e');
      }
    }
    return 3;
  }

  /// 단어 AI 예문 생성 시 소모되는 에너지 (기본값: 1)
  static int getExampleEnergyCost() {
    if (_isInitialized) {
      try {
        final val = FirebaseRemoteConfig.instance.getInt('example_energy_cost');
        if (val > 0) return val;
      } catch (e) {
        debugPrint('[RemoteConfig] example_energy_cost 파싱 에러: $e');
      }
    }
    return 1;
  }
}
