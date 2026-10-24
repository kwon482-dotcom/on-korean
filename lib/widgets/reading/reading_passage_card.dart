import 'package:flutter/material.dart';

import '../../models/reading_model.dart';
import '../../services/locale_service.dart';
import '../../services/tts_service.dart';
import 'reading_speed_chip.dart';

/// 독해 / 청해 메인 카드 (지문 본문/대본 가림 + 글자크기 + 배속 + 오디오 재생)
class ReadingPassageCard extends StatelessWidget {
  final ReadingModel reading;
  final bool isLargeFont;
  final bool revealScript;
  final bool isAnswered;
  final double playbackRate;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleFontSize;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onRevealScript;

  const ReadingPassageCard({
    super.key,
    required this.reading,
    required this.isLargeFont,
    required this.revealScript,
    required this.isAnswered,
    required this.playbackRate,
    required this.onToggleComplete,
    required this.onToggleFontSize,
    required this.onSpeedChanged,
    required this.onRevealScript,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isListeningMode = reading.type == 'listening';
    final showPassageText = !isListeningMode || isAnswered || revealScript;
    final passageFontSize = isLargeFont ? 20.0 : 16.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 뱃지 및 완료 버튼 행
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF312E81) : Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF4338CA) : Colors.indigo.shade200,
                        ),
                      ),
                      child: Text(
                        reading.level,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reading.theme,
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? (isListeningMode
                                ? const Color(0xFF2E1065)
                                : const Color(0xFF042F2E))
                            : (isListeningMode
                                ? Colors.deepPurple.shade50
                                : Colors.teal.shade50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isListeningMode
                            ? LocaleService.tr('archive_filter_listening')
                            : LocaleService.tr('archive_filter_reading'),
                        style: TextStyle(
                          color: isDark
                              ? (isListeningMode
                                  ? const Color(0xFFC084FC)
                                  : const Color(0xFF5EEAD4))
                              : (isListeningMode
                                  ? Colors.deepPurple.shade800
                                  : Colors.teal.shade800),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // 학습 완료 체크 뱃지 (오른쪽 상단 배치)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onToggleComplete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: reading.isCompleted
                          ? (isDark ? const Color(0xFF064E3B) : Colors.green.shade50)
                          : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: reading.isCompleted
                            ? (isDark ? const Color(0xFF059669) : Colors.green.shade400)
                            : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reading.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                          color: reading.isCompleted
                              ? (isDark ? const Color(0xFF6EE7B7) : Colors.green.shade700)
                              : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          reading.isCompleted
                              ? LocaleService.tr('reading_completed')
                              : LocaleService.tr('reading_mark_complete'),
                          style: TextStyle(
                            color: reading.isCompleted
                                ? (isDark ? const Color(0xFF6EE7B7) : Colors.green.shade800)
                                : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            fontSize: 11,
                            fontWeight: reading.isCompleted ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 글자 크기 버튼 및 심플 완료 안내 힌트
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: onToggleFontSize,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLargeFont
                            ? (isDark ? const Color(0xFF312E81) : Colors.indigo.shade50)
                            : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLargeFont
                              ? (isDark ? const Color(0xFF4338CA) : Colors.indigo.shade300)
                              : (isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.format_size,
                            size: 13,
                            color: isLargeFont
                                ? (isDark ? const Color(0xFFA5B4FC) : Colors.indigo)
                                : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isLargeFont
                                ? LocaleService.tr('lab_font_large')
                                : LocaleService.tr('lab_font_normal'),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: isLargeFont ? FontWeight.bold : FontWeight.normal,
                              color: isLargeFont
                                  ? (isDark ? const Color(0xFFA5B4FC) : Colors.indigo)
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          reading.isCompleted ? Icons.check_circle_outline : Icons.touch_app_outlined,
                          size: 12.5,
                          color: reading.isCompleted
                              ? (isDark ? const Color(0xFF6EE7B7) : Colors.green.shade700)
                              : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            reading.isCompleted
                                ? LocaleService.tr('reading_completed_done_short')
                                : LocaleService.tr('reading_completed_hint_short'),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: reading.isCompleted
                                  ? (isDark ? const Color(0xFF6EE7B7) : Colors.green.shade700)
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                              fontWeight: reading.isCompleted ? FontWeight.bold : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 지문 제목
            Text(
              reading.title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            // 🎧 청해 모드: 대본 가림 카드 ↔ 대본 공개 부드러운 스르륵 애니메이션 (독해 모드는 즉각 표시)
            if (isListeningMode)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  child: !showPassageText
                      ? _buildListeningHiddenCard(context)
                      : KeyedSubtree(
                          key: const ValueKey('listening_revealed_script'),
                          child: _buildPassageTextBox(true, passageFontSize),
                        ),
                ),
              )
            else
              _buildPassageTextBox(false, passageFontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildListeningHiddenCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const ValueKey('listening_hidden_card'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [Colors.deepPurple.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF4338CA) : Colors.deepPurple.shade100,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.headphones,
            size: 36,
            color: isDark ? const Color(0xFFA78BFA) : Colors.deepPurple,
          ),
          const SizedBox(height: 10),
          Text(
            LocaleService.tr('lab_listening_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE0E7FF) : Colors.deepPurple.shade900,
            ),
          ),
          const SizedBox(height: 16),
          // 💡 단일 순환 배속 버튼
          ReadingSpeedChip(
            playbackRate: playbackRate,
            onSpeedChanged: onSpeedChanged,
            prominent: true,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => TtsService.speak(reading.passageJa, rate: playbackRate),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF6366F1) : Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.volume_up, size: 20),
            label: Text(
              LocaleService.tr('lab_listen_passage'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRevealScript,
            icon: const Icon(Icons.visibility_outlined, size: 16),
            label: Text(
              LocaleService.tr('lab_show_script'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          // 🔈 미디어 볼륨 안내
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.volume_down,
                size: 13,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                LocaleService.tr('lab_volume_hint'),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassageTextBox(bool isListeningMode, double passageFontSize) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : (isListeningMode
                        ? Colors.deepPurple.shade50.withValues(alpha: 0.3)
                        : Colors.amber.shade50.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : (isListeningMode
                          ? Colors.deepPurple.shade100
                          : Colors.amber.shade100),
                ),
              ),
              child: Text(
                reading.passageJa,
                style: TextStyle(
                  fontSize: passageFontSize,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: isDark ? const Color(0xFFF1F5F9) : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 💡 단일 순환 배속 칩
                ReadingSpeedChip(
                  playbackRate: playbackRate,
                  onSpeedChanged: onSpeedChanged,
                  prominent: false,
                ),
                TextButton.icon(
                  onPressed: () => TtsService.speak(reading.passageJa, rate: playbackRate),
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: Text(
                    isListeningMode
                        ? LocaleService.tr('lab_listen_again')
                        : LocaleService.tr('reading_listen_all'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
