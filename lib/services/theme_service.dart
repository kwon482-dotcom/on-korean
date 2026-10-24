import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 화면 테마 관리 서비스 (시스템 기본 / 라이트 / 다크)
class ThemeService {
  static const String _prefThemeModeKey = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static bool _isInitialized = false;

  /// 테마 설정 로드
  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_prefThemeModeKey) ?? 'system';
      if (modeStr == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else if (modeStr == 'light') {
        themeMode.value = ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.system;
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('[ThemeService] 초기화 에러: $e');
    }
  }

  /// 테마 모드 변경 및 영구 저장
  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefThemeModeKey, mode.name);
    } catch (e) {
      debugPrint('[ThemeService] 테마 저장 실패: $e');
    }
  }
}
