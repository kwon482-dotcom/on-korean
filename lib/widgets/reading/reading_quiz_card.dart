import 'package:flutter/material.dart';

import '../../models/reading_model.dart';
import '../../services/locale_service.dart';
import '../../services/tts_service.dart';

/// 퀴즈 카드 (문제 지문 + 4지선다 옵션 + 정답 피드백 + 청해 모드 보기 오디오)
class ReadingQuizCard extends StatelessWidget {
  final ReadingModel reading;
  final int? selectedOptionIndex;
  final ValueChanged<int> onSelectOption;

  const ReadingQuizCard({
    super.key,
    required this.reading,
    required this.selectedOptionIndex,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isListeningMode = reading.type == 'listening';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isListeningMode ? Icons.hearing : Icons.help_outline,
                  color: isListeningMode
                      ? (isDark ? const Color(0xFFA78BFA) : Colors.deepPurple)
                      : (isDark ? const Color(0xFF818CF8) : Colors.indigo),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isListeningMode
                      ? LocaleService.tr('lab_quiz_listening_title')
                      : LocaleService.tr('reading_quiz_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              reading.targetQuestion,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // 4지선다 옵션 리스트
            ...List.generate(reading.options.length, (idx) {
              final optionText = reading.options[idx];
              final isSelected = selectedOptionIndex == idx;
              final isAnswered = selectedOptionIndex != null;
              final isCorrectOption = idx == reading.correctIndex;

              Color bgColor = isDark ? const Color(0xFF0F172A) : Colors.grey.shade50;
              Color borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;
              Color textColor = isDark ? Colors.white : Colors.black87;

              if (isAnswered) {
                if (isCorrectOption) {
                  bgColor = isDark ? const Color(0xFF064E3B) : Colors.green.shade50;
                  borderColor = isDark ? const Color(0xFF059669) : Colors.green;
                  textColor = isDark ? const Color(0xFF6EE7B7) : Colors.green.shade900;
                } else if (isSelected) {
                  bgColor = isDark ? const Color(0xFF450A0A) : Colors.red.shade50;
                  borderColor = isDark ? const Color(0xFFDC2626) : Colors.red;
                  textColor = isDark ? const Color(0xFFFCA5A5) : Colors.red.shade900;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelectOption(idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected || (isAnswered && isCorrectOption) ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAnswered && isCorrectOption
                                ? (isDark ? const Color(0xFF059669) : Colors.green)
                                : (isSelected
                                    ? (isDark ? const Color(0xFFDC2626) : Colors.red)
                                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade200)),
                          ),
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAnswered && (isCorrectOption || isSelected)
                                  ? Colors.white
                                  : (isDark ? const Color(0xFFCBD5E1) : Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            optionText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: textColor,
                            ),
                          ),
                        ),
                        // 청해 모드일 때 보기 발음 재생 아이콘
                        if (isListeningMode)
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              size: 18,
                              color: isDark ? const Color(0xFFA78BFA) : Colors.deepPurple,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: LocaleService.tr('lab_listen_option'),
                            onPressed: () => TtsService.speak(optionText),
                          ),
                        if (isAnswered && isCorrectOption)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.check, color: Colors.green, size: 20),
                          )
                        else if (isAnswered && isSelected)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.close, color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
