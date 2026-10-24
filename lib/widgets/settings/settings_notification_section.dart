import 'package:flutter/material.dart';

import '../../services/locale_service.dart';
import '../../services/notification_service.dart';

/// 매일 학습 푸시 알림 설정 아코디언 (ExpansionTile)
class SettingsNotificationSection extends StatefulWidget {
  const SettingsNotificationSection({super.key});

  @override
  State<SettingsNotificationSection> createState() =>
      _SettingsNotificationSectionState();
}

class _SettingsNotificationSectionState
    extends State<SettingsNotificationSection> {
  @override
  void initState() {
    super.initState();
    // 설정 화면 진입 시 실제 기기 권한 상태와 동기화
    NotificationService.syncPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NotificationService.isReminderEnabled,
      builder: (context, enabled, _) {
        return ValueListenableBuilder<int>(
          valueListenable: NotificationService.reminderHour,
          builder: (_, hour, __) {
            return ValueListenableBuilder<int>(
              valueListenable: NotificationService.reminderMinute,
              builder: (timeCtx, minute, ___) {
                final time = TimeOfDay(hour: hour, minute: minute);
                final formattedTime = time.format(timeCtx);
                final statusSummary = enabled
                    ? LocaleService.tr('settings_notif_status_on', [formattedTime])
                    : LocaleService.tr('settings_notif_status_off');

                return ExpansionTile(
                  leading: Icon(
                    Icons.notifications_active,
                    color: enabled ? Colors.deepPurple : Colors.grey.shade500,
                    size: 22,
                  ),
                  title: Text(
                    LocaleService.tr('settings_notif_section'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    statusSummary,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
                      color: enabled ? Colors.deepPurple : Colors.grey.shade600,
                    ),
                  ),
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.alarm, color: Colors.deepPurple),
                      title: Text(
                        LocaleService.tr('settings_notif_daily'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        LocaleService.tr('settings_notif_daily_desc'),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      value: enabled,
                      onChanged: (val) async {
                        final messenger = ScaffoldMessenger.of(context);
                        final success =
                            await NotificationService.setReminderEnabled(val);

                        if (!context.mounted) return;

                        if (val) {
                          if (success) {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  LocaleService.tr('settings_notif_scheduled', [
                                    '${NotificationService.reminderHour.value.toString().padLeft(2, '0')}:${NotificationService.reminderMinute.value.toString().padLeft(2, '0')}',
                                  ]),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  LocaleService.tr(
                                    'settings_notif_permission_denied',
                                  ),
                                ),
                                duration: const Duration(seconds: 4),
                                backgroundColor: Colors.redAccent,
                                action: SnackBarAction(
                                  label: LocaleService.tr('settings_notif_open_settings'),
                                  textColor: Colors.white,
                                  onPressed: () {
                                    NotificationService.openNotificationSettings();
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                    if (enabled) ...[
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.deepPurple,
                        ),
                        title: Text(LocaleService.tr('settings_notif_time')),
                        subtitle: Text(
                          formattedTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 14,
                          ),
                        ),
                        trailing: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 14),
                          label: Text(
                            LocaleService.tr('settings_notif_change_time'),
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (picked != null) {
                              await NotificationService.setReminderTime(
                                picked.hour,
                                picked.minute,
                              );
                              if (context.mounted) {
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.hideCurrentSnackBar();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      LocaleService.tr(
                                        'settings_notif_scheduled',
                                        [
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                                        ],
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        leading: const Icon(
                          Icons.send_outlined,
                          color: Colors.deepPurple,
                        ),
                        title: Text(LocaleService.tr('settings_notif_test_btn')),
                        subtitle: Text(
                          LocaleService.tr('settings_notif_test_sub'),
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple.shade50,
                            foregroundColor: Colors.deepPurple,
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final sent =
                                await NotificationService.showTestNotification();
                            if (!context.mounted) return;

                            messenger.hideCurrentSnackBar();
                            if (sent) {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleService.tr('settings_notif_test_sent'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleService.tr(
                                      'settings_notif_permission_denied',
                                    ),
                                  ),
                                  duration: const Duration(seconds: 4),
                                  backgroundColor: Colors.redAccent,
                                  action: SnackBarAction(
                                    label: LocaleService.tr('settings_notif_open_settings'),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      NotificationService.openNotificationSettings();
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            LocaleService.tr('settings_notif_test_action'),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
