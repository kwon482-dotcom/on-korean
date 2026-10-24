import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'locale_service.dart';

class StatsService {
  static const String _prefDailyCountKey = 'daily_study_counts';
  static const String _prefDailyMasteredKey = 'daily_mastered_counts';
  static const String _prefLastStudyDateKey = 'last_study_date';
  static const String _prefStreakKey = 'study_streak_days';

  static String _todayStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // 카드 1개 학습 완료 시 카운트 증가 및 스트릭 갱신 (알아요 여부 포함)
  static Future<void> recordWordStudied({bool remembered = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayStr();

    // 1. 일별 누적 총 학습 수 기록
    final raw = prefs.getString(_prefDailyCountKey) ?? '{}';
    Map<String, dynamic> map = jsonDecode(raw);
    int current = (map[today] as num?)?.toInt() ?? 0;
    map[today] = current + 1;
    await prefs.setString(_prefDailyCountKey, jsonEncode(map));

    // 1-1. 일별 '알아요(암기)' 수 기록
    if (remembered) {
      final rawMastered = prefs.getString(_prefDailyMasteredKey) ?? '{}';
      Map<String, dynamic> masteredMap = jsonDecode(rawMastered);
      int currentMastered = (masteredMap[today] as num?)?.toInt() ?? 0;
      masteredMap[today] = currentMastered + 1;
      await prefs.setString(_prefDailyMasteredKey, jsonEncode(masteredMap));
    }

    // 2. 스트릭(연속 학습일) 계산
    final lastDate = prefs.getString(_prefLastStudyDateKey);
    int streak = prefs.getInt(_prefStreakKey) ?? 0;

    if (lastDate == null) {
      streak = 1;
    } else if (lastDate != today) {
      final lastDt = DateTime.parse(lastDate);
      final nowDt = DateTime.parse(today);
      final diff = nowDt.difference(lastDt).inDays;

      if (diff == 1) {
        streak += 1; // 어제 학습하고 오늘 또 함 (연속 유지)
      } else if (diff > 1) {
        streak = 1; // 하루 이상 건너뜀 (초기화 후 1일부터)
      }
    }

    await prefs.setString(_prefLastStudyDateKey, today);
    await prefs.setInt(_prefStreakKey, streak);
  }

  // 현재 스트릭 수치 반환
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_prefLastStudyDateKey);
    final streak = prefs.getInt(_prefStreakKey) ?? 0;
    if (lastDate == null) return 0;

    final today = _todayStr();
    final diff = DateTime.parse(today)
        .difference(DateTime.parse(lastDate))
        .inDays;
    // 어제도 오늘도 안 들어왔으면 스트릭 0
    if (diff > 1) return 0;
    return streak;
  }

  // 오늘 학습한 총 단어 수
  static Future<int> getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefDailyCountKey) ?? '{}';
    final Map<String, dynamic> map = jsonDecode(raw);
    return (map[_todayStr()] as num?)?.toInt() ?? 0;
  }

  // 오늘 암기 완료('알아요')한 단어 수
  static Future<int> getTodayMasteredCount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefDailyMasteredKey) ?? '{}';
    final Map<String, dynamic> map = jsonDecode(raw);
    return (map[_todayStr()] as num?)?.toInt() ?? 0;
  }

  // 최근 7일 학습 데이터 (요일, 전체 학습수, 암기 완료수)
  static Future<List<Map<String, dynamic>>> getLast7Days() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefDailyCountKey) ?? '{}';
    final Map<String, dynamic> map = jsonDecode(raw);

    final rawMastered = prefs.getString(_prefDailyMasteredKey) ?? '{}';
    final Map<String, dynamic> masteredMap = jsonDecode(rawMastered);

    final now = DateTime.now();
    final List<Map<String, dynamic>> result = [];
    final lang = LocaleService.currentLocale.value.languageCode;
    final List<String> weekdayNames;
    if (lang == 'en') {
      weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (lang == 'ja') {
      weekdayNames = ['月', '火', '水', '木', '金', '土', '日'];
    } else {
      weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    }

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      final count = (map[key] as num?)?.toInt() ?? 0;
      final masteredCount = (masteredMap[key] as num?)?.toInt() ?? 0;
      result.add({
        'dayLabel': weekdayNames[d.weekday - 1],
        'isToday': i == 0,
        'count': count,
        'masteredCount': masteredCount,
      });
    }
    return result;
  }
}
