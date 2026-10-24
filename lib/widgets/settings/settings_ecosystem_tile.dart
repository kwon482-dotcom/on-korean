import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/locale_service.dart';

/// GyuC Studio 자매앱 생태계 교차 홍보 타일
class SettingsEcosystemTile extends StatelessWidget {
  const SettingsEcosystemTile({super.key});

  Future<void> _openEcosystemHub(BuildContext context) async {
    final uri = Uri.parse('https://kwon482-dotcom.github.io');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleService.tr('ad_load_failed'))),
          );
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 13,
        backgroundColor: Color(0xFFEEF2FF),
        child: Icon(
          Icons.apps_rounded,
          color: Color(0xFF4F46E5),
          size: 15,
        ),
      ),
      title: Text(
        LocaleService.tr('ecosystem_title'),
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
      subtitle: Text(
        LocaleService.tr('ecosystem_subtitle'),
        style: const TextStyle(
          fontSize: 10.5,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.open_in_new_rounded,
        size: 16,
        color: Color(0xFF94A3B8),
      ),
      onTap: () => _openEcosystemHub(context),
    );
  }
}
