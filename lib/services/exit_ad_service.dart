import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'energy_service.dart';

/// 앱 종료 팝업용 AdMob 네이티브 광고(Native Ad) 관리 서비스
class ExitAdService {
  static NativeAd? _nativeAd;
  static bool _isLoaded = false;
  static bool _isLoading = false;

  /// 광고 단위 ID 분기
  /// - 릴리스 모드(kReleaseMode): 발급받은 정식 네이티브 광고 ID
  /// - 디버그/테스트 모드: 구글 공식 테스트 네이티브 광고 ID (무효 트래픽/계정 제재 방지)
  static String get adUnitId {
    if (kReleaseMode) {
      return 'ca-app-pub-4701087745821757/1239524424'; // on-korean 공식 네이티브 광고 ID
    } else {
      return 'ca-app-pub-3940256099942544/2247696110'; // 구글 공식 테스트 네이티브 광고 ID
    }
  }

  /// 사전 로드된 네이티브 광고 객체
  static NativeAd? get nativeAd => _nativeAd;

  /// 광고가 현재 바로 표시 가능한지 여부
  static bool get isAdReady => _isLoaded && _nativeAd != null;

  /// 앱 시작 시 또는 광고 소비 후 백그라운드에서 미리 NativeAd를 사전 로드
  static void preloadAd() {
    // 1. Android 기기 및 비-웹 환경에서만 작동
    if (kIsWeb || !Platform.isAndroid) return;

    // 2. Pro 유료 회원(광고 제거 플랜)인 경우 광고 로드 건너뜀
    if (EnergyService.isPro.value) {
      debugPrint('[ExitAdService] Pro 회원이므로 광고 로드를 건너뜁니다.');
      return;
    }

    // 3. 이미 광고가 준비되어 있거나 현재 로딩 중이면 중복 요청 방지
    if (_nativeAd != null || _isLoading) return;

    _isLoading = true;
    _isLoaded = false;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isLoaded = true;
          _isLoading = false;
          debugPrint('[ExitAdService] 네이티브 광고 사전 로드 완료 (Exit Ad ready)');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[ExitAdService] 네이티브 광고 로드 실패: $error');
          ad.dispose();
          _nativeAd = null;
          _isLoaded = false;
          _isLoading = false;
        },
        onAdOpened: (ad) => debugPrint('[ExitAdService] 네이티브 광고 열림'),
        onAdClosed: (ad) => debugPrint('[ExitAdService] 네이티브 광고 닫힘'),
        onAdClicked: (ad) => debugPrint('[ExitAdService] 네이티브 광고 클릭됨'),
        onAdImpression: (ad) => debugPrint('[ExitAdService] 네이티브 광고 노출됨'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );

    _nativeAd!.load();
  }

  /// 취소 등으로 팝업이 닫힌 뒤 다음번 뒤로가기를 위해 광고 재충전
  static void reloadAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
    _isLoading = false;
    preloadAd();
  }

  /// 서비스 종료 시 자원 해제
  static void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
    _isLoading = false;
  }
}
