import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 보상형 광고(Rewarded Ad) 관리 서비스
class RewardedAdService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static String get _adUnitId {
    // 💡 출시 빌드(kReleaseMode)일 때 실제 발급받은 보상형 광고 단위 노출
    // 디버그/개발 중에는 구글 공식 테스트 광고 ID로 무효 트래픽/계정 제재 방지
    if (kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-4701087745821757/4980544020' // on-korean 보상형 광고 ID (Android)
          : 'ca-app-pub-4701087745821757/4354425312'; // on-korean 보상형 광고 ID (iOS)
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
  }

  /// 앱 시작 시 또는 광고 시청 후 미리 광고를 백그라운드에서 로드
  static void preloadAd() {
    if (kIsWeb) return;
    if (_rewardedAd != null || _isLoading) return;

    _isLoading = true;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          debugPrint('[AdMob] 보상형 광고 사전 로드 성공');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
          debugPrint('[AdMob] 보상형 광고 로드 실패: $error');
        },
      ),
    );
  }

  /// 광고가 현재 바로 시청 가능한지 확인
  static bool get isAdReady => _rewardedAd != null;

  /// 보상형 광고 표시 및 보상 지급
  static Future<void> showRewardedAd({
    required VoidCallback onRewarded,
    VoidCallback? onDismissed,
    VoidCallback? onFailed,
  }) async {
    if (kIsWeb) {
      // 웹 등 비모바일 환경에서는 바로 보상 처리
      onRewarded();
      return;
    }

    if (_rewardedAd == null) {
      preloadAd();
      if (onFailed != null) {
        onFailed();
      }
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        preloadAd(); // 다음 시청을 위해 미리 준비
        if (onDismissed != null) {
          onDismissed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] 보상형 광고 송출 실패: $error');
        ad.dispose();
        _rewardedAd = null;
        preloadAd();
        if (onFailed != null) {
          onFailed();
        }
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdMob] 보상 획득 완료: ${reward.amount} ${reward.type}');
        onRewarded();
      },
    );
  }
}
