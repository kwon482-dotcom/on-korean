import 'package:flutter/material.dart';

import '../../services/locale_service.dart';
import '../../services/tts_service.dart';

/// 음성 발음(TTS) 속도, 성별 선택, 볼륨 안내 및 자동 재생/반복 설정 섹션
class SettingsAudioSection extends StatelessWidget {
  final double ttsRate;
  final bool isAutoPlay;
  final bool repeatWordTwice;
  final String voiceGender;
  final ValueChanged<double> onTtsRateChanged;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onRepeatWordTwiceChanged;
  final ValueChanged<String> onVoiceGenderChanged;

  const SettingsAudioSection({
    super.key,
    required this.ttsRate,
    required this.isAutoPlay,
    required this.repeatWordTwice,
    this.voiceGender = 'female',
    required this.onTtsRateChanged,
    required this.onAutoPlayChanged,
    required this.onRepeatWordTwiceChanged,
    required this.onVoiceGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 💡 1. 음성 목소리 성별 선택 (여성 vs 남성) - 풀위드 세그먼트 버튼 레이아웃
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleService.tr('settings_tts_voice_gender'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    voiceGender == 'female'
                        ? LocaleService.tr('settings_tts_female')
                        : LocaleService.tr('settings_tts_male'),
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
                child: SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  segments: [
                    ButtonSegment<String>(
                      value: 'female',
                      icon: const Text('👩', style: TextStyle(fontSize: 14)),
                      label: Text(LocaleService.tr('settings_tts_female')),
                    ),
                    ButtonSegment<String>(
                      value: 'male',
                      icon: const Text('👨', style: TextStyle(fontSize: 14)),
                      label: Text(LocaleService.tr('settings_tts_male')),
                    ),
                  ],
                  selected: {voiceGender},
                  onSelectionChanged: (set) async {
                    final selected = set.first;
                    if (selected != voiceGender) {
                      onVoiceGenderChanged(selected);
                      await TtsService.setVoiceGender(selected);
                      TtsService.speak('안녕하세요, 한국어 공부를 시작해 볼까요?');
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 💡 2. 발음 속도 슬라이더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleService.tr('settings_tts_speed'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
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
                  onPressed: () => TtsService.speak('안녕하세요, 한국어 공부를 시작해 볼까요?'),
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
