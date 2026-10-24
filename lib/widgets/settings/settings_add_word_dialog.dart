import 'package:flutter/material.dart';

import '../../models/word_model.dart';
import '../../services/locale_service.dart';
import '../../services/word_service.dart';

/// 단어 1개 수동 직접 추가 다이얼로그 (동적 카테고리 + 직접 입력 지원)
class SettingsAddWordDialog {
  static Future<void> show(BuildContext context) async {
    final wordController = TextEditingController();
    final furiController = TextEditingController();
    final meanController = TextEditingController();
    final customCategoryController = TextEditingController();

    final categories = WordService.getAllCategories();
    String selectedLevel = categories.contains('N5') ? 'N5' : categories.first;
    bool isCustomCategory = false;

    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) => AlertDialog(
          title: Text(isJa ? '単語の手動追加' : (isEn ? 'Add New Card' : '단어 직접 추가')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  decoration: InputDecoration(
                    labelText: isJa ? '単語帳(カテゴリ)の選択' : (isEn ? 'Select Deck / Category' : '단어장(카테고리) 선택'),
                  ),
                  items: [
                    ...categories.map(
                      (l) => DropdownMenuItem(value: l, child: Text(WordService.getLocalizedCategory(l))),
                    ),
                    DropdownMenuItem(
                      value: '__custom__',
                      child: Text(isJa ? '➕ 新規カテゴリ直接入力' : (isEn ? '➕ Enter New Category' : '➕ 새 카테고리 직접 입력')),
                    ),
                  ],
                  onChanged: (v) {
                    setDlgState(() {
                      if (v == '__custom__') {
                        isCustomCategory = true;
                      } else {
                        isCustomCategory = false;
                        selectedLevel = v ?? 'N5';
                      }
                    });
                  },
                ),
                if (isCustomCategory) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customCategoryController,
                    decoration: InputDecoration(
                      labelText: isJa ? '新規カテゴリ名' : (isEn ? 'New Category Name' : '새 카테고리명'),
                      hintText: isJa ? '例: 旅行会話, ビジネス' : (isEn ? 'e.g. Travel, Business' : '예: 여행회화, 비즈니스'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: wordController,
                  decoration: InputDecoration(
                    labelText: isJa ? '単語 (表記)' : (isEn ? 'Word' : '단어 (표기)'),
                    hintText: '例: 友達',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: furiController,
                  decoration: InputDecoration(
                    labelText: isJa ? 'ふりがな (読み方)' : (isEn ? 'Furigana / Reading' : '후리가나 (읽는 법)'),
                    hintText: '例: ともだち',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: meanController,
                  decoration: InputDecoration(
                    labelText: isJa ? '意味 (対訳)' : (isEn ? 'Meaning' : '한국어 뜻'),
                    hintText: isJa ? '例: 友達 (ともだち)' : (isEn ? 'e.g. Friend' : '예: 친구'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(LocaleService.tr('btn_cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (wordController.text.trim().isEmpty || meanController.text.trim().isEmpty) {
                  return;
                }

                final fallbackCat = isJa ? 'その他' : (isEn ? 'Custom' : '기타');
                final finalLevel = isCustomCategory
                    ? (customCategoryController.text.trim().isEmpty
                        ? fallbackCat
                        : customCategoryController.text.trim())
                    : selectedLevel;

                final newWord = WordModel(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  level: finalLevel,
                  word: wordController.text.trim(),
                  furigana: furiController.text.trim().isEmpty
                      ? wordController.text.trim()
                      : furiController.text.trim(),
                  meaning: meanController.text.trim(),
                  meaningEn: isEn ? meanController.text.trim() : null,
                );

                await WordService.addCustomWord(newWord);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isJa ? '単語が追加されました！' : (isEn ? 'Card added successfully!' : '단어가 성공적으로 추가되었습니다!'),
                      ),
                    ),
                  );
                }
              },
              child: Text(LocaleService.tr('btn_save')),
            ),
          ],
        ),
      ),
    );
  }
}
