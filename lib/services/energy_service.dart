import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remote_config_service.dart';

/// AI 기능 (예문 생성, 1분 독해 등) 무료 이용 횟수 및 에너지 관리 서비스
class EnergyService {
  static const String _keyEnergy = 'ai_energy_count';
  static const String _keyLastDate = 'ai_energy_last_date';
  static const String _keyIsPro = 'is_pro_user';

  static int get defaultDailyEnergy => RemoteConfigService.getDailyFreeEnergy();
  static int get energyPerRewardAd => RemoteConfigService.getAdRewardEnergy();

  /// 반응형 잔여 에너지 Notifier
  static final ValueNotifier<int> currentEnergy = ValueNotifier<int>(10);

  /// Pro(광고제거 + AI 무제한) 여부 Notifier
  static final ValueNotifier<bool> isPro = ValueNotifier<bool>(false);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayString();
    final lastDate = prefs.getString(_keyLastDate);

    isPro.value = prefs.getBool(_keyIsPro) ?? false;
    final daily = defaultDailyEnergy;

    if (lastDate != todayStr) {
      // 날짜가 바뀌었으면 (자정 리셋)
      final existingEnergy = prefs.getInt(_keyEnergy) ?? 0;
      // 이전 광고 보상으로 daily 이상 모아둔 게 있다면 보존, 아니라면 daily로 만충
      final newEnergy = existingEnergy < daily ? daily : existingEnergy;

      await prefs.setInt(_keyEnergy, newEnergy);
      await prefs.setString(_keyLastDate, todayStr);
      currentEnergy.value = newEnergy;
    } else {
      final savedEnergy = prefs.getInt(_keyEnergy) ?? daily;
      currentEnergy.value = savedEnergy;
    }
  }

  /// AI 기능 호출 가능 여부 (Pro 사용자이거나 특정 양 이상의 에너지를 보유하고 있는지)
  static bool canAfford([int amount = 1]) => isPro.value || currentEnergy.value >= amount;

  /// 기본 AI 호출 가능 여부 (1개 이상)
  static bool get canUseAi => canAfford(1);

  /// AI 호출 에너지 소진 (단어 예문 1, 1분 독해 3)
  static Future<bool> consume([int amount = 1]) async {
    if (isPro.value) return true;

    if (currentEnergy.value >= amount) {
      currentEnergy.value -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyEnergy, currentEnergy.value);
      return true;
    }
    return false;
  }

  /// 보상형 광고 시청 완료 시 에너지 충전 (+5 or 원격 설정치)
  static Future<void> addRewardEnergy([int? amount]) async {
    final add = amount ?? energyPerRewardAd;
    currentEnergy.value += add;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyEnergy, currentEnergy.value);
  }

  /// Pro 멤버십 활성화 (인앱 구매 완료 시 호출)
  static Future<void> setProUser(bool pro) async {
    isPro.value = pro;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, pro);
  }

  /// 개발자/테스터 편의를 위한 Pro 모드 토글 (설정 화면에서 버전 7회 탭 시 활성화)
  static Future<bool> toggleProTesterMode() async {
    final next = !isPro.value;
    await setProUser(next);
    return next;
  }

  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
