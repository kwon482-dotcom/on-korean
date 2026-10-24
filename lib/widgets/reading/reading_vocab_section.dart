import 'package:flutter/material.dart';

import '../../models/reading_model.dart';
import '../../services/locale_service.dart';
import '../../services/tts_service.dart';

/// 한국어 번역 & 퀴즈 해설 & 핵심 어휘 리스트 섹션
class ReadingVocabSection extends StatelessWidget {
  final ReadingModel reading;
  final bool showTranslation;
  final void Function(ReadingVocab vocab) onAddVocab;

  const ReadingVocabSection({
    super.key,
    required this.reading,
    required this.showTranslation,
    required this.onAddVocab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = LocaleService.currentLocale.value.languageCode;
    final flag = langCode == 'ja' ? '🇯🇵' : (langCode == 'en' ? '🇺🇸' : '🇰🇷');
    final localizedText = reading.getLocalizedTranslation(langCode);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        initiallyExpanded: showTranslation,
        leading: Icon(Icons.translate, color: isDark ? const Color(0xFF2DD4BF) : Colors.teal),
        title: Text(
          LocaleService.tr('reading_check_answer'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          const Divider(),
          // 1. 한국어/현지어 번역
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$flag ↔️ ${LocaleService.tr('reading_trans_title')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : Colors.indigo.shade50.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
            ),
            child: Text(
              localizedText,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.6,
                color: isDark ? const Color(0xFFCBD5E1) : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. 퀴즈 정답 해설
          if (reading.explanation.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '💡 ${LocaleService.tr('reading_exp_title')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? const Color(0xFF2DD4BF) : Colors.teal,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : Colors.teal.shade50.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
              ),
              child: Text(
                '${LocaleService.tr('reading_correct_answer', [reading.correctIndex + 1])}\n${reading.explanation}',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? const Color(0xFFCBD5E1) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3. 핵심 어휘 정리
          if (reading.keyVocab.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🈸 ${LocaleService.tr('reading_key_vocab')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  LocaleService.tr('reading_key_vocab_hint'),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...reading.keyVocab.map((vocab) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onLongPress: () => onAddVocab(vocab),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vocab.word,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${vocab.reading} • ${vocab.meaning}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ➕ 단어장 저장 버튼
                          IconButton(
                            icon: Icon(
                              Icons.bookmark_add_outlined,
                              size: 20,
                              color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                            ),
                            tooltip: LocaleService.tr('reading_add_to_deck_title'),
                            onPressed: () => onAddVocab(vocab),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.volume_up,
                              size: 18,
                              color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                            ),
                            onPressed: () => TtsService.speak(vocab.word),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
