import 'package:flutter/material.dart';

import '../../services/energy_service.dart';
import '../../services/locale_service.dart';
import 'settings_ecosystem_tile.dart';

/// 앱 정보 섹션 (GyuC 생태계 교차 홍보 + 오픈소스 라이선스 + 앱 버전 & VIP 테스터 이스터에그)
class SettingsAppInfoSection extends StatefulWidget {
  final String appVersion;
  final String buildNumber;

  const SettingsAppInfoSection({
    super.key,
    required this.appVersion,
    required this.buildNumber,
  });

  @override
  State<SettingsAppInfoSection> createState() => _SettingsAppInfoSectionState();
}

class _SettingsAppInfoSectionState extends State<SettingsAppInfoSection> {
  int _developerTapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. GyuC Studio 자매앱 교차 홍보
        const SettingsEcosystemTile(),
        const Divider(),

        // 2. 오픈소스 라이선스
        ListTile(
          leading: const Icon(Icons.description_outlined, color: Colors.blueGrey),
          title: Text(LocaleService.tr('settings_licenses')),
          subtitle: Text(LocaleService.tr('settings_licenses_desc')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: LocaleService.tr('app_title'),
              applicationVersion: 'v${widget.appVersion} (${widget.buildNumber})',
              applicationLegalese: '© 2026 onvocab@gyugyu.net. All rights reserved.',
            );
          },
        ),
        const Divider(),

        // 3. 앱 버전 및 VIP 테스터 모드 토글
        ValueListenableBuilder<bool>(
          valueListenable: EnergyService.isPro,
          builder: (context, isPro, _) {
            return ListTile(
              leading: Icon(
                isPro ? Icons.verified : Icons.info_outline,
                color: isPro ? Colors.green : Colors.indigo,
              ),
              title: Text(LocaleService.tr('settings_app_version')),
              subtitle: Text(
                '${LocaleService.tr('settings_latest_ver')} (v${widget.appVersion}+${widget.buildNumber})'
                '${isPro ? ' [VIP Tester]' : ''}',
              ),
              onTap: () async {
                _developerTapCount++;
                if (_developerTapCount >= 7) {
                  _developerTapCount = 0;
                  final isNowPro = await EnergyService.toggleProTesterMode();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: isNowPro ? Colors.indigo : Colors.grey.shade800,
                        content: Text(
                          isNowPro
                              ? LocaleService.tr('tester_mode_enabled')
                              : LocaleService.tr('tester_mode_disabled'),
                        ),
                      ),
                    );
                  }
                }
              },
            );
          },
        ),
      ],
    );
  }
}
