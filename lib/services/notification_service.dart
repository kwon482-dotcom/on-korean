import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'locale_service.dart';

/// 매일 일본어 학습 리마인더 로컬 푸시 알림 서비스
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefReminderEnabledKey = 'daily_study_reminder_enabled';
  static const String _prefReminderHourKey = 'daily_study_reminder_hour';
  static const String _prefReminderMinuteKey = 'daily_study_reminder_minute';

  static final ValueNotifier<bool> isReminderEnabled = ValueNotifier<bool>(false);
  static final ValueNotifier<int> reminderHour = ValueNotifier<int>(20); // 기본 오후 8시
  static final ValueNotifier<int> reminderMinute = ValueNotifier<int>(0);

  static bool _isInitialized = false;

  /// 알림 서비스 초기화
  static Future<void> init() async {
    if (_isInitialized) return;
    if (kIsWeb) return;

    try {
      // 1. 타임존 데이터베이스 초기화 및 실제 기기 타임존 설정
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        final String currentTimeZone = timezoneInfo.identifier;
        tz.setLocalLocation(tz.getLocation(currentTimeZone));
        debugPrint('[NotificationService] 로컬 타임존 설정 완료: $currentTimeZone');
      } catch (e) {
        debugPrint('[NotificationService] 타임존 자동 감지 실패 ($e), 오프셋으로 탐색...');
        try {
          final offset = DateTime.now().timeZoneOffset;
          for (final loc in tz.timeZoneDatabase.locations.values) {
            if (loc.currentTimeZone.offset == offset) {
              tz.setLocalLocation(loc);
              debugPrint('[NotificationService] 대체 타임존 설정 완료: ${loc.name}');
              break;
            }
          }
        } catch (fallbackError) {
          debugPrint('[NotificationService] 타임존 대체 설정 실패: $fallbackError');
        }
      }

      // 2. 저장된 알림 설정 로드
      final prefs = await SharedPreferences.getInstance();
      final savedEnabled = prefs.getBool(_prefReminderEnabledKey) ?? false;
      reminderHour.value = prefs.getInt(_prefReminderHourKey) ?? 20;
      reminderMinute.value = prefs.getInt(_prefReminderMinuteKey) ?? 0;

      // 3. 플러그인 초기화 설정
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _notificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('[NotificationService] 알림 탭됨: ${response.payload}');
        },
      );

      // Android 고우선순위 알림 채널 명시적 생성 (Importance.max)
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        final channel = AndroidNotificationChannel(
          'daily_study_reminder',
          LocaleService.tr('notif_channel_name'),
          description: LocaleService.tr('notif_channel_desc'),
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidPlatform.createNotificationChannel(channel);
      }

      _isInitialized = true;

      // 4. 저장된 설정이 켜져 있는 경우, 실제 기기 권한 확인 후 스케줄 등록 또는 동기화
      if (savedEnabled) {
        final hasPermission = await isPermissionGranted();
        if (hasPermission) {
          isReminderEnabled.value = true;
          await _scheduleDaily();
        } else {
          // 기기 시스템 설정에서 알림 권한이 꺼져있는 경우 상태 동기화
          isReminderEnabled.value = false;
          await prefs.setBool(_prefReminderEnabledKey, false);
          debugPrint('[NotificationService] 기기 알림 권한 없음으로 비활성화 동기화');
        }
      } else {
        isReminderEnabled.value = false;
      }

      // 언어 변경 시 알림 메시지 다국어 갱신
      LocaleService.currentLocale.addListener(() {
        if (isReminderEnabled.value) {
          _scheduleDaily();
        }
      });

      debugPrint('[NotificationService] 초기화 완료 (알림 활성: ${isReminderEnabled.value})');
    } catch (e) {
      debugPrint('[NotificationService] 초기화 실패: $e');
    }
  }

  /// 푸시 알림 권한 부여 여부 확인 (Android 13+ 및 이전 버전 호환)
  static Future<bool> isPermissionGranted() async {
    if (kIsWeb) return false;
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        final enabled = await androidPlatform.areNotificationsEnabled();
        return enabled ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('[NotificationService] 권한 확인 에러: $e');
      return false;
    }
  }

  /// 푸시 알림 권한 요청 (Android 13+ 및 iOS)
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        final alreadyEnabled = await androidPlatform.areNotificationsEnabled();
        if (alreadyEnabled == true) {
          return true;
        }
        final granted = await androidPlatform.requestNotificationsPermission();
        return granted ?? false;
      }
      final iosPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlatform != null) {
        final granted = await iosPlatform.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] 권한 요청 에러: $e');
    }
    return true;
  }

  /// 현재 기기에서 알림 권한이 켜져 있는지 확인
  static Future<bool> areNotificationsEnabled() async => isPermissionGranted();

  /// 기기 시스템 앱 알림 설정 화면 바로 열기 (Android)
  static Future<void> openNotificationSettings() async {
    if (kIsWeb) return;
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        await androidPlatform.openAppNotificationSettings();
      }
    } catch (e) {
      debugPrint('[NotificationService] openNotificationSettings 에러: $e');
    }
  }

  /// Android 정확한 알람(Exact Alarm) 가능 여부 확인
  static Future<bool> canScheduleExactAlarms() async {
    if (kIsWeb) return false;
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        final can = await androidPlatform.canScheduleExactNotifications();
        return can ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] canScheduleExactAlarms 에러: $e');
    }
    return true;
  }

  /// 기기 시스템의 '알람 및 리마인더 허용' 설정 화면 열기
  static Future<void> requestExactAlarmsPermission() async {
    if (kIsWeb) return;
    try {
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlatform != null) {
        await androidPlatform.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('[NotificationService] requestExactAlarmsPermission 에러: $e');
    }
  }

  /// 기기 설정과 현재 앱 내 리마인더 활성화 상태 동기화
  static Future<void> syncPermissionStatus() async {
    if (kIsWeb) return;
    try {
      if (isReminderEnabled.value) {
        final granted = await isPermissionGranted();
        if (!granted) {
          isReminderEnabled.value = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_prefReminderEnabledKey, false);
          await cancelAll();
          debugPrint('[NotificationService] 시스템 권한 변경 감지: 알림 비활성화 처리');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] 권한 동기화 실패: $e');
    }
  }

  /// 알림 사용 여부 설정 토글 (권한 요청 포함, 성공 여부 반환)
  static Future<bool> setReminderEnabled(bool enabled) async {
    if (enabled) {
      // 💡 스위치를 켤 때 즉시 권한 요청
      final granted = await requestPermission();
      if (!granted) {
        isReminderEnabled.value = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefReminderEnabledKey, false);
        await cancelAll();
        return false;
      }
    }

    isReminderEnabled.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefReminderEnabledKey, enabled);

    if (enabled) {
      await _scheduleDaily();
    } else {
      await cancelAll();
    }
    return true;
  }

  /// 알림 시간 변경
  static Future<void> setReminderTime(int hour, int minute) async {
    reminderHour.value = hour;
    reminderMinute.value = minute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefReminderHourKey, hour);
    await prefs.setInt(_prefReminderMinuteKey, minute);

    if (isReminderEnabled.value) {
      await _scheduleDaily();
    }
  }

  /// 모든 예약 알림 취소
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('[NotificationService] 모든 예약 알림 취소 완료');
    } catch (e) {
      debugPrint('[NotificationService] 알림 취소 실패: $e');
    }
  }

  /// 매일 지정 시각 반복 알림 스케줄링
  static Future<void> _scheduleDaily() async {
    if (kIsWeb) return;
    if (!isReminderEnabled.value) return;

    try {
      await _notificationsPlugin.cancel(id: 1001); // 기존 일일 알림 취소

      final scheduledDate = _nextInstanceOfTime(
        reminderHour.value,
        reminderMinute.value,
      );

      final androidDetails = AndroidNotificationDetails(
        'daily_study_reminder',
        LocaleService.tr('notif_channel_name'),
        channelDescription: LocaleService.tr('notif_channel_desc'),
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: 1001,
          title: LocaleService.tr('notif_study_title'),
          body: LocaleService.tr('notif_study_body'),
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
          '[NotificationService] 매일 알림 예약 완료 (exact): ${reminderHour.value}:${reminderMinute.value.toString().padLeft(2, '0')} (대상시각: $scheduledDate)',
        );
      } catch (e) {
        debugPrint('[NotificationService] exact 모드 실패 ($e), inexact 모드로 폴백 시도');
        await _notificationsPlugin.zonedSchedule(
          id: 1001,
          title: LocaleService.tr('notif_study_title'),
          body: LocaleService.tr('notif_study_body'),
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
          '[NotificationService] 매일 알림 예약 완료 (inexact): ${reminderHour.value}:${reminderMinute.value.toString().padLeft(2, '0')} (대상시각: $scheduledDate)',
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] 매일 알림 예약 실패: $e');
    }
  }

  /// 다음 알림 시각 계산 (기기 로컬 타임존 기준)
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// 즉시 테스트 알림 전송 (동작 확인용, 권한 검사 포함 및 성공 여부 반환)
  static Future<bool> showTestNotification() async {
    if (kIsWeb) return false;
    try {
      final granted = await requestPermission();
      if (!granted) {
        debugPrint('[NotificationService] 테스트 알림 전송 중단: 권한 없음');
        return false;
      }

      final androidDetails = AndroidNotificationDetails(
        'daily_study_reminder',
        LocaleService.tr('notif_channel_name'),
        channelDescription: LocaleService.tr('notif_channel_desc'),
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id: 999,
        title: LocaleService.tr('notif_test_title'),
        body: LocaleService.tr('notif_test_body'),
        notificationDetails: notificationDetails,
      );
      return true;
    } catch (e) {
      debugPrint('[NotificationService] 테스트 알림 실패: $e');
      return false;
    }
  }
}
