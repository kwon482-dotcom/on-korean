import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 전역 설정 및 온보딩 상태 관리 서비스
class AppSettings {
  static const String _prefHasSeenOnboardingKey = 'has_seen_onboarding';

  /// 첫 실행 온보딩 확인 여부
  static final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier<bool>(true);

  static bool _isInitialized = false;

  /// 설정 초기화
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingSeen = prefs.getBool(_prefHasSeenOnboardingKey);

      if (existingSeen != null) {
        hasSeenOnboarding.value = existingSeen;
      } else {
        // 기존 사용자가 앱 업데이트 시 갑자기 온보딩이 뜨지 않도록 기존 데이터 유무 체크
        final streak = prefs.getInt('study_streak_count') ?? 0;
        final totalLearned = prefs.getStringList('mastered_words_list')?.length ?? 0;
        if (streak > 0 || totalLearned > 0) {
          hasSeenOnboarding.value = true;
          await prefs.setBool(_prefHasSeenOnboardingKey, true);
        } else {
          hasSeenOnboarding.value = false;
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[AppSettings] 초기화 실패: $e');
    }
  }

  /// 온보딩 완료 여부 저장
  static Future<void> setHasSeenOnboarding(bool seen) async {
    hasSeenOnboarding.value = seen;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefHasSeenOnboardingKey, seen);
    } catch (e) {
      debugPrint('[AppSettings] 온보딩 상태 저장 실패: $e');
    }
  }
}
