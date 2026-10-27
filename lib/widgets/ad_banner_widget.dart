import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // 💡 출시 빌드(kReleaseMode)일 때만 실제 배너 노출, 평소엔 공식 테스트 배너
  String get _adUnitId {
    if (kReleaseMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-4701087745821757/3057088263' // 실제 배너 ID (Android)
          : 'ca-app-pub-4701087745821757/3782745523'; // 실제 배너 ID (iOS)
    } else {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // 구글 공식 안드로이드 테스트 ID
          : 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadBanner();
    }
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 웹 환경에서는 AdMob 배너를 노출하지 않고 여백 완전 제거
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

    // 💡 모바일에서 배너가 로드되었을 때만 네비게이션 바 바로 위에 밀착하여 노출
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    // 💡 광고 로딩 전이나 실패 시 빈 공백을 남기지 않고 높이 0으로 처리
    return const SizedBox.shrink();
  }
}
