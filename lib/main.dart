import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'services/energy_service.dart';
import 'services/locale_service.dart';
import 'services/notification_service.dart';
import 'services/reading_service.dart';
import 'services/remote_config_service.dart';
import 'services/rewarded_ad_service.dart';
import 'services/theme_service.dart';
import 'services/tts_service.dart';
import 'services/widget_service.dart';
import 'services/app_settings.dart';
import 'services/word_service.dart';
import 'screens/main_screen.dart';
import 'widgets/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 다국어, 테마, 전역 설정 및 온보딩 초기화
  await LocaleService.init();
  await ThemeService.init();
  await AppSettings.init();

  // 2. 단어 데이터셋 비동기 로드, TTS, AI 에너지, 독해 보관함 및 푸시 알림 초기화
  await WordService.init();
  await TtsService.init();
  await EnergyService.init();
  await ReadingService.init();
  await NotificationService.init();
  await WidgetService.updateWidget();

  // 3. 모바일 환경일 때만 Firebase 및 AdMob 초기화
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      debugPrint('[Firebase] 초기화 성공');
      await RemoteConfigService.init();
    } catch (e) {
      debugPrint('[Firebase] 초기화 에러: $e');
    }

    try {
      await MobileAds.instance.initialize();
      RewardedAdService.preloadAd();
      debugPrint('[AdMob] 초기화 성공 및 보상형 광고 프리로드');
    } catch (e) {
      debugPrint('[AdMob] 초기화 에러: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.currentLocale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.themeMode,
          builder: (context, themeMode, _) {
            return MaterialApp(
              locale: locale,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.indigo,
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8FAFC),
                cardColor: Colors.white,
                listTileTheme: ListTileThemeData(
                  dense: true,
                  titleTextStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  subtitleTextStyle: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: Colors.white,
                  indicatorColor: const Color(0xFFEEF2FF),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      );
                    }
                    return const TextStyle(fontSize: 11, fontWeight: FontWeight.normal);
                  }),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  primary: const Color(0xFF818CF8),
                  surface: const Color(0xFF1E293B),
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                cardColor: const Color(0xFF1E293B),
                cardTheme: const CardThemeData(
                  color: Color(0xFF1E293B),
                  elevation: 0,
                ),
                dialogTheme: const DialogThemeData(
                  backgroundColor: Color(0xFF1E293B),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  contentTextStyle: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 14,
                  ),
                ),
                bottomSheetTheme: const BottomSheetThemeData(
                  backgroundColor: Color(0xFF1E293B),
                  modalBackgroundColor: Color(0xFF1E293B),
                ),
                listTileTheme: const ListTileThemeData(
                  dense: true,
                  titleTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  subtitleTextStyle: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                  iconColor: Color(0xFF94A3B8),
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF0F172A),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  iconTheme: IconThemeData(color: Colors.white),
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                navigationBarTheme: NavigationBarThemeData(
                  backgroundColor: const Color(0xFF1E293B),
                  indicatorColor: const Color(0xFF312E81),
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Color(0xFF818CF8));
                    }
                    return const IconThemeData(color: Color(0xFF94A3B8));
                  }),
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF818CF8),
                      );
                    }
                    return const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF94A3B8),
                    );
                  }),
                ),
              ),
              home: ValueListenableBuilder<bool>(
                valueListenable: AppSettings.hasSeenOnboarding,
                builder: (context, hasSeen, _) {
                  if (!hasSeen) {
                    return const OnboardingScreen();
                  }
                  return const MainScreen();
                },
              ),
            );
          },
        );
      },
    );
  }
}
