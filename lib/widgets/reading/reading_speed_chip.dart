import 'package:flutter/material.dart';

import '../../services/locale_service.dart';

/// 배속 순환 칩 (1.0x -> 1.2x -> 0.8x -> 1.0x 순환)
class ReadingSpeedChip extends StatelessWidget {
  final double playbackRate;
  final ValueChanged<double> onSpeedChanged;
  final bool prominent; // 대본 가림 카드용(강조형) vs 지문 하단용(컴팩트형)

  const ReadingSpeedChip({
    super.key,
    required this.playbackRate,
    required this.onSpeedChanged,
    this.prominent = false,
  });

  void _cycleSpeed() {
    double nextRate;
    if (playbackRate == 1.0) {
      nextRate = 1.2;
    } else if (playbackRate == 1.2) {
      nextRate = 0.8;
    } else {
      nextRate = 1.0;
    }
    onSpeedChanged(nextRate);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (prominent) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _cycleSpeed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B4B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF6366F1) : Colors.deepPurple.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.speed,
                size: 13,
                color: isDark ? const Color(0xFFA78BFA) : Colors.deepPurple,
              ),
              const SizedBox(width: 4),
              Text(
                '${LocaleService.tr('lab_playback_speed')} ${playbackRate}x',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFDDD6FE) : Colors.deepPurple.shade900,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _cycleSpeed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 13,
              color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
            ),
            const SizedBox(width: 4),
            Text(
              '${playbackRate}x',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
