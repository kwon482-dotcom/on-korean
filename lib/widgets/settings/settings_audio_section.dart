import 'package:flutter/material.dart';

import '../../services/locale_service.dart';
import '../../services/tts_service.dart';

/// 음성 발음(TTS) 속도, 볼륨 안내 및 자동 재생/반복 설정 섹션
class SettingsAudioSection extends StatelessWidget {
  final double ttsRate;
  final bool isAutoPlay;
  final bool repeatWordTwice;
  final ValueChanged<double> onTtsRateChanged;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onRepeatWordTwiceChanged;

  const SettingsAudioSection({
    super.key,
    required this.ttsRate,
    required this.isAutoPlay,
    required this.repeatWordTwice,
    required this.onTtsRateChanged,
    required this.onAutoPlayChanged,
    required this.onRepeatWordTwiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleService.tr('settings_tts_speed'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ttsRate == 1.0
                        ? '1.00x (${LocaleService.tr('settings_tts_default')})'
                        : '${ttsRate.toStringAsFixed(2)}x',
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: ttsRate.clamp(0.6, 1.4),
                min: 0.6,
                max: 1.4,
                divisions: 8,
                onChanged: (val) {
                  final newRate = double.parse(val.toStringAsFixed(2));
                  onTtsRateChanged(newRate);
                  TtsService.setRate(newRate);
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => TtsService.speak('日本語の勉強を始めましょう'),
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: Text(LocaleService.tr('settings_tts_test')),
                ),
              ),
              const SizedBox(height: 6),
              // 💡 미디어 볼륨 안내 팁 박스
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade50.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.indigo.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: isDark ? const Color(0xFF818CF8) : Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            LocaleService.tr('settings_tts_volume_tip'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFFCBD5E1) : Colors.indigo.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
        // 💡 음성 자동 재생 토글 스위치
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined, color: Colors.indigo),
          title: Text(
            LocaleService.tr('settings_tts_autoplay'),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            LocaleService.tr('settings_tts_autoplay_desc'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          value: isAutoPlay,
          onChanged: (val) {
            onAutoPlayChanged(val);
            TtsService.setAutoPlay(val);
          },
        ),
        // 💡 단어 2회 반복 읽기 토글 스위치
        SwitchListTile(
          secondary: const Icon(Icons.repeat, color: Colors.indigo),
          title: Text(
            LocaleService.tr('settings_tts_repeat_word'),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            LocaleService.tr('settings_tts_repeat_word_desc'),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          value: repeatWordTwice,
          onChanged: (val) {
            onRepeatWordTwiceChanged(val);
            TtsService.setRepeatWordTwice(val);
          },
        ),
      ],
    );
  }
}
