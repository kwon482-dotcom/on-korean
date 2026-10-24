import 'package:flutter/material.dart';

import '../../services/locale_service.dart';
import '../../services/word_service.dart';

/// 외부 단어장(Anki/CSV) 텍스트 대량 일괄 가져오기 다이얼로그
class SettingsImportDialog {
  static Future<void> show(BuildContext context) async {
    final textController = TextEditingController();
    final customCategoryController = TextEditingController();

    final categories = WordService.getAllCategories();
    String selectedLevel = categories.contains('기타') ? '기타' : categories.first;
    bool isCustomCategory = false;

    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDlgState) => AlertDialog(
          title: Text(isJa ? '外部単語帳 (Anki/CSV) インポート' : (isEn ? 'Import Deck (Anki/CSV)' : '외부 단어장 (Anki/CSV) 가져오기')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isJa
                      ? '形式: 1行に1単語ずつ入力してください。\n• 単語,読み,意味(日本語),意味(英語)\n• 単語,読み,意味\n• 単語,意味\n• タブ(Tab)区切りのAnkiやNotionテキストにも対応しています。'
                      : (isEn
                          ? 'Format: 1 word per line.\n• Word,Reading,Meaning(KO),Meaning(EN)\n• Word,Reading,Meaning\n• Word,Meaning\n• Tab-separated Anki or Notion text is supported.'
                          : '형식: 한 줄에 하나씩 단어를 입력하세요.\n• 단어,후리가나,한국어뜻,영어뜻\n• 단어,후리가나,뜻\n• 단어,뜻\n• 탭(Tab) 구분 Anki나 노션 텍스트도 자동 지원됩니다.'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  decoration: InputDecoration(
                    labelText: isJa ? 'インポート先単語帳(カテゴリ)' : (isEn ? 'Target Deck / Category' : '가져올 단어장(카테고리)'),
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
                        selectedLevel = v ?? '기타';
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
                      hintText: isJa ? '例: N1上級語彙, テーマ会話' : (isEn ? 'e.g. Advanced N1, Themes' : '예: N1고급어휘, 테마회화'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '例:\n空港,くうこう,공항\n天気,てんき,날씨\n車,자동차',
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
                final raw = textController.text.trim();
                if (raw.isEmpty) return;

                final finalLevel = isCustomCategory
                    ? (customCategoryController.text.trim().isEmpty
                        ? '기타'
                        : customCategoryController.text.trim())
                    : selectedLevel;

                final count = await WordService.importWordsFromRawText(
                  raw,
                  level: finalLevel,
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocaleService.tr('settings_import_success', [count]))),
                  );
                }
              },
              child: Text(LocaleService.tr('import_bulk')),
            ),
          ],
        ),
      ),
    );
  }
}
