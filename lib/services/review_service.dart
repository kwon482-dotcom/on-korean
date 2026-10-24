import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 스토어 인앱 리뷰(In-App Review) 유도 및 바로가기 공용 서비스
/// (OnVocab, OnRoutine, On타이머 등 모든 자매앱에서 그대로 재사용 가능)
class ReviewService {
  static final InAppReview _inAppReview = InAppReview.instance;

  static const String _prefHasRequestedReviewKey =
      'has_requested_in_app_review';

  /// 특정 달성 조건(예: 누적 암기 30개 또는 목표 달성 n회) 도달 시 자연스럽게 인앱 리뷰 팝업 요청
  /// [currentCount]: 현재 달성 횟수 (예: 마스터 단어 수, 완료 루틴 수 등)
  /// [targetThreshold]: 리뷰 팝업을 띄울 목표 기준치 (기본값: 30)
  static Future<void> checkAndRequestReview({
    int currentCount = 0,
    int targetThreshold = 30,
  }) async {
    if (kIsWeb) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequested = prefs.getBool(_prefHasRequestedReviewKey) ?? false;
      if (hasRequested) return; // 이미 리뷰를 요청한 적이 있다면 중복 방지

      if (currentCount >= targetThreshold) {
        // 구글 플레이 / 앱스토어 인앱 리뷰 지원 여부 확인
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
          await prefs.setBool(_prefHasRequestedReviewKey, true);
          debugPrint('[ReviewService] 인앱 리뷰 팝업 요청 성공 (목표 $targetThreshold 달성)');
        }
      }
    } catch (e) {
      debugPrint('[ReviewService] 인앱 리뷰 요청 실패: $e');
    }
  }

  /// 설정 화면 등에서 사용자가 직접 '스토어 평가 및 리뷰 남기기'를 눌렀을 때 스토어로 이동
  static Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {
      debugPrint('[ReviewService] 스토어 페이지 열기 실패: $e');
    }
  }
}
