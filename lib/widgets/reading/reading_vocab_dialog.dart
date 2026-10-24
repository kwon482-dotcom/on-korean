import 'package:flutter/material.dart';

import '../../models/reading_model.dart';
import '../../models/word_model.dart';
import '../../services/locale_service.dart';
import '../../services/word_service.dart';

/// 핵심 어휘를 내 단어장으로 저장하는 다이얼로그 (카테고리 선택 및 새 카테고리 직접 입력 지원)
class ReadingVocabDialog {
  static Future<void> show(
    BuildContext context, {
    required ReadingVocab vocab,
    required String currentLevel,
  }) async {
    final categories = WordService.getAllCategories();
    String selectedCategory = categories.contains(currentLevel)
        ? currentLevel
        : (categories.isNotEmpty ? categories.first : LocaleService.tr('fallback_custom_category'));
    bool isCustomCategory = false;
    final textController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    Icons.bookmark_add,
                    color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocaleService.tr('reading_add_to_deck_title'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : Colors.indigo.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : Colors.indigo.shade100,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vocab.word,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vocab.reading} • ${vocab.meaning}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      LocaleService.tr('reading_add_to_deck_select'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: isCustomCategory ? '__CUSTOM__' : selectedCategory,
                      isExpanded: true,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        ...categories.map((c) => DropdownMenuItem(value: c, child: Text(WordService.getLocalizedCategory(c)))),
                        DropdownMenuItem(
                          value: '__CUSTOM__',
                          child: Text(
                            LocaleService.tr('reading_add_new_deck_option'),
                            style: TextStyle(
                              color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == '__CUSTOM__') {
                          setDialogState(() {
                            isCustomCategory = true;
                          });
                        } else if (val != null) {
                          setDialogState(() {
                            isCustomCategory = false;
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    if (isCustomCategory) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: textController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: LocaleService.tr('reading_add_deck_hint'),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(LocaleService.tr('btn_cancel')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    String targetCategory = selectedCategory;
                    if (isCustomCategory) {
                      final input = textController.text.trim();
                      if (input.isEmpty) {
                        return;
                      }
                      targetCategory = input;
                    }

                    final newWord = WordModel(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      level: targetCategory,
                      word: vocab.word,
                      furigana: vocab.reading,
                      meaning: vocab.meaning,
                      meaningEn: LocaleService.currentLocale.value.languageCode == 'en'
                          ? vocab.meaning
                          : null,
                    );

                    await WordService.addCustomWord(newWord);

                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            LocaleService.tr('reading_add_to_deck_success', [vocab.word, targetCategory]),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text(LocaleService.tr('btn_add')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
