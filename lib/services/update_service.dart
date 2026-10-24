import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'locale_service.dart';

/// 구글 플레이 인앱 업데이트(In-App Update) 서비스
class UpdateService {
  static bool _isChecking = false;

  /// 인앱 업데이트 가능 여부 확인 및 업데이트 수행
  ///
  /// - [context]: 스낵바 또는 다이얼로그 표시용 BuildContext
  /// - [isManualCheck]: 사용자가 설정 화면 등에서 직접 '앱 버전'을 터치하여 수동 확인할 때 true
  static Future<void> checkForUpdate(
    BuildContext? context, {
    bool isManualCheck = false,
  }) async {
    // 1. 플랫폼 가드: 웹, iOS, 데스크톱 등 비-안드로이드 환경에서는 에러 없이 안전하게 스킵
    if (kIsWeb || !Platform.isAndroid) {
      debugPrint('[UpdateService] In-App Update는 Android 환경에서만 지원됩니다.');
      if (isManualCheck && context != null && context.mounted) {
        _showSnackBar(context, LocaleService.tr('update_latest'));
      }
      return;
    }

    if (_isChecking) return;
    _isChecking = true;

    try {
      debugPrint('[UpdateService] Google Play 인앱 업데이트 확인 시작...');
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      debugPrint(
        '[UpdateService] 업데이트 정보: 가용성=${info.updateAvailability}, '
        'FlexibleAllowed=${info.flexibleUpdateAllowed}, '
        'ImmediateAllowed=${info.immediateUpdateAllowed}, '
        'InstallStatus=${info.installStatus}',
      );

      // 2. 이미 백그라운드 다운로드가 완료되어 설치 대기 중인 경우 -> 재시작 안내
      if (info.installStatus == InstallStatus.downloaded) {
        if (context != null && context.mounted) {
          _showCompleteUpdateSnackBar(context);
        }
        return;
      }

      // 3. 업데이트가 출시된 경우
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // 1순위: 사용자가 앱을 계속 사용할 수 있는 유연한 업데이트(Flexible Update) 우선 적용
        if (info.flexibleUpdateAllowed) {
          debugPrint('[UpdateService] Flexible Update(유연한 업데이트) 시작');
          final result = await InAppUpdate.startFlexibleUpdate();
          debugPrint('[UpdateService] Flexible Update 결과: $result');

          if (result == AppUpdateResult.success) {
            if (context != null && context.mounted) {
              _showCompleteUpdateSnackBar(context);
            }
          }
        }
        // 2순위: 유연한 업데이트 미지원 시 즉시 업데이트(Immediate Update) 적용
        else if (info.immediateUpdateAllowed) {
          debugPrint('[UpdateService] Immediate Update(즉시 업데이트) 시작');
          await InAppUpdate.performImmediateUpdate();
        }
      }
      // 4. 업데이트가 없는 경우
      else if (info.updateAvailability == UpdateAvailability.updateNotAvailable) {
        debugPrint('[UpdateService] 현재 최신 버전을 사용 중입니다.');
        if (isManualCheck && context != null && context.mounted) {
          _showSnackBar(context, LocaleService.tr('update_latest'));
        }
      }
    } catch (e) {
      // 5. 디버그 모드, 사이드로딩, 스토어 미출시 상태 등에서 에러가 발생해도 크래시 없이 조용히 로깅만 수행
      debugPrint('[UpdateService] 인앱 업데이트 확인 중 예외 발생 (안전하게 스킵): $e');
      if (isManualCheck && context != null && context.mounted) {
        _showSnackBar(context, LocaleService.tr('update_latest'));
      }
    } finally {
      _isChecking = false;
    }
  }

  /// 다운로드 완료 후 앱 재시작 스낵바 표시
  static void _showCompleteUpdateSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocaleService.tr('update_downloaded')),
        duration: const Duration(days: 1), // 사용자가 재시작을 누를 때까지 유지
        action: SnackBarAction(
          label: LocaleService.tr('update_restart'),
          onPressed: () {
            InAppUpdate.completeFlexibleUpdate().catchError((e) {
              debugPrint('[UpdateService] completeFlexibleUpdate 에러: $e');
            });
          },
        ),
      ),
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
