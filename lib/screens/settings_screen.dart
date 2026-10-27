import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/backup_service.dart';
import '../services/locale_service.dart';
import '../services/review_service.dart';
import '../services/theme_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/settings/settings_add_word_dialog.dart';
import '../widgets/settings/settings_app_info_section.dart';
import '../widgets/settings/settings_audio_section.dart';
import '../widgets/settings/settings_category_filter_sheet.dart';
import '../widgets/settings/settings_import_dialog.dart';
import '../widgets/settings/settings_notification_section.dart';
import '../widgets/onboarding_screen.dart';
import '../widgets/settings/settings_support_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _ttsRate = TtsService.currentRate;
  bool _isAutoPlay = TtsService.isAutoPlay;
  bool _repeatWordTwice = TtsService.repeatWordTwice;
  String _appVersion = '1.0.5';
  String _buildNumber = '6';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
          _buildNumber = info.buildNumber;
        });
      }
    } catch (e) {
      debugPrint('[PackageInfo] 버전 로드 에러: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = LocaleService.currentLocale.value.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(LocaleService.tr('settings_title'))),
      body: ListTileTheme(
        data: ListTileThemeData(
          dense: true,
          titleTextStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 11.5,
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
          ),
          iconColor: isDark ? const Color(0xFF94A3B8) : null,
        ),
        child: ListView(
          children: [
            // 1. 언어 선택 (영어, 일본어, 한국어 순)
            ListTile(
              title: Text(
                LocaleService.tr('settings_lang'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                currentLang == 'en'
                    ? 'English'
                    : currentLang == 'ja'
                        ? '日本語'
                        : '한국어',
              ),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('EN')),
                  ButtonSegment(value: 'ja', label: Text('日')),
                  ButtonSegment(value: 'ko', label: Text('한')),
                ],
                selected: {currentLang},
                onSelectionChanged: (set) async {
                  await LocaleService.changeLocale(set.first);
                  setState(() {});
                },
              ),
            ),
            const Divider(),

            // 1-1. 화면 테마 선택 (시스템, 라이트, 다크) - 줄바꿈 스택 레이아웃
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService.themeMode,
                builder: (context, currentThemeMode, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleService.tr('settings_theme'),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            currentThemeMode == ThemeMode.system
                                ? LocaleService.tr('theme_system')
                                : currentThemeMode == ThemeMode.light
                                    ? LocaleService.tr('theme_light')
                                    : LocaleService.tr('theme_dark'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: const Icon(Icons.brightness_auto, size: 16),
                              label: Text(LocaleService.tr('theme_system')),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.light_mode, size: 16),
                              label: Text(LocaleService.tr('theme_light')),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.dark_mode, size: 16),
                              label: Text(LocaleService.tr('theme_dark')),
                            ),
                          ],
                          selected: {currentThemeMode},
                          onSelectionChanged: (set) async {
                            await ThemeService.setThemeMode(set.first);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(),

            // 2. 발음(TTS) 설정 섹션
            SettingsAudioSection(
              ttsRate: _ttsRate,
              isAutoPlay: _isAutoPlay,
              repeatWordTwice: _repeatWordTwice,
              onTtsRateChanged: (val) => setState(() => _ttsRate = val),
              onAutoPlayChanged: (val) => setState(() => _isAutoPlay = val),
              onRepeatWordTwiceChanged: (val) => setState(() => _repeatWordTwice = val),
            ),
            const Divider(),

            // 3. 랜덤 학습 출제 범위(카테고리) 설정
            ListTile(
              leading: const Icon(Icons.tune, color: Colors.indigo),
              title: Text(LocaleService.tr('filter_title')),
              subtitle: Text(
                LocaleService.tr('settings_categories_selected', [
                  WordService.getSelectedStudyCategories().length,
                  WordService.getAllCategories().length,
                ]),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => SettingsCategoryFilterSheet.show(
                context,
                onApplied: () => setState(() {}),
              ),
            ),
            const Divider(),

            // 4. 매일 학습 푸시 알림 섹션
            const SettingsNotificationSection(),
            const Divider(),

            // 5. 단어 관리 섹션 (수동 직접 추가 & Anki/CSV 일괄 가져오기)
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.indigo),
              title: Text(LocaleService.tr('settings_add_word')),
              subtitle: Text(LocaleService.tr('settings_add_word_desc')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => SettingsAddWordDialog.show(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.file_download_outlined,
                color: Colors.teal,
              ),
              title: Text(LocaleService.tr('settings_import')),
              subtitle: Text(LocaleService.tr('settings_import_desc')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => SettingsImportDialog.show(context),
            ),
            const Divider(),

            // 5-1. 학습 데이터 백업 및 복원 (.json 파일 내보내기/가져오기)
            ExpansionTile(
              leading: const Icon(Icons.cloud_sync_outlined, color: Colors.indigo),
              title: Text(
                LocaleService.tr('settings_backup_section'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                LocaleService.tr('settings_backup_export_sub'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.file_upload_outlined, color: Colors.indigo),
                  title: Text(LocaleService.tr('settings_backup_export')),
                  subtitle: Text(LocaleService.tr('settings_backup_export_sub')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => BackupService.exportBackup(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.file_download_outlined, color: Colors.teal),
                  title: Text(LocaleService.tr('settings_backup_import')),
                  subtitle: Text(LocaleService.tr('settings_backup_import_sub')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => BackupService.importBackup(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.restore, color: Colors.indigo),
                  title: Text(LocaleService.tr('pro_restore_purchases')),
                  subtitle: Text(LocaleService.tr('pro_restore_purchases_desc')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(LocaleService.tr('pro_restore_result'))),
                    );
                  },
                ),
              ],
            ),
            const Divider(),

            // 6. 문의 및 공지사항 / 보너스 단어장 아코디언 (ExpansionTile)
            ExpansionTile(
              leading: const Icon(Icons.campaign_outlined, color: Colors.orange),
              title: Text(
                LocaleService.tr('settings_support_title'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                LocaleService.tr('settings_support_subtitle'),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.auto_stories_outlined, color: Colors.indigo),
                  title: Text(LocaleService.tr('settings_onboarding')),
                  subtitle: Text(LocaleService.tr('settings_onboarding_desc')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OnboardingScreen(isReviewMode: true),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.menu_book_outlined, color: Colors.indigo),
                  title: Text(LocaleService.tr('settings_notice_guide')),
                  subtitle: Text(LocaleService.tr('settings_notice_guide_sub')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => SettingsSupportDialogs.showNotice(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.card_giftcard, color: Colors.teal),
                  title: Text(LocaleService.tr('settings_bonus_pack')),
                  subtitle: Text(LocaleService.tr('settings_bonus_pack_sub')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => SettingsSupportDialogs.showBonusPacks(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(Icons.mail_outline, color: Colors.amber.shade800),
                  title: Text(LocaleService.tr('settings_feedback')),
                  subtitle: Text(LocaleService.tr('settings_feedback_sub')),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => SettingsSupportDialogs.showFeedback(context),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                  title: Text(LocaleService.tr('settings_rate_app')),
                  subtitle: Text(LocaleService.tr('settings_rate_app_sub')),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => ReviewService.openStoreListing(),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
                  title: Text(LocaleService.tr('settings_privacy_policy')),
                  subtitle: Text(LocaleService.tr('settings_privacy_policy_desc')),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => SettingsSupportDialogs.openPrivacyPolicy(context),
                ),
              ],
            ),
            const Divider(),

            // 7. 앱 정보 & GyuC Studio 자매앱 교차 홍보 & 라이선스 & 버전
            SettingsAppInfoSection(
              appVersion: _appVersion,
              buildNumber: _buildNumber,
            ),
          ],
        ),
      ),
    );
  }
}
