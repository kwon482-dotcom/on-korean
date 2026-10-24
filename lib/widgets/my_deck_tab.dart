import 'package:flutter/material.dart';

import '../models/word_model.dart';
import '../services/locale_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../screens/study_screen.dart';

class MyDeckTab extends StatefulWidget {
  const MyDeckTab({super.key});

  @override
  State<MyDeckTab> createState() => _MyDeckTabState();
}

class _MyDeckTabState extends State<MyDeckTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              indicatorColor: Colors.indigo,
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  text: LocaleService.tr('wrong_notes'),
                ),
                Tab(
                  icon: const Icon(Icons.bookmark_outline, size: 18),
                  text: LocaleService.tr('bookmarks'),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildDeckList(WordService.getWrongWords(), isWrongMode: true),
            _buildDeckList(
              WordService.getBookmarkedWords(),
              isWrongMode: false,
            ),
          ],
        ),
      ),
    );
  }

  String _compactCategory(String cat) {
    if (cat.contains('비즈니스 실무')) return '비즈니스 실무';
    if (cat.contains('비즈니스 실전')) return '비즈니스 경어';
    if (cat.contains('초밥집')) return '초밥·생선';
    if (cat.contains('Business Practical')) return 'Biz Vocab';
    if (cat.contains('Business Keigo')) return 'Biz Keigo';
    if (cat.contains('Sushi & Fish')) return 'Sushi';
    if (cat.contains('ビジネス実務')) return '実務語彙';
    if (cat.contains('ビジネス実践')) return '実践敬語';
    if (cat.contains('寿司屋')) return '寿司・魚';
    return cat;
  }

  Widget _buildDeckList(List<WordModel> words, {required bool isWrongMode}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isWrongMode ? Icons.check_circle_outline : Icons.bookmark_border,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isWrongMode
                  ? LocaleService.tr('empty_wrong')
                  : LocaleService.tr('empty_bookmark'),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Column(
          children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${words.length} ${LocaleService.tr('words_registered')}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWrongMode
                      ? (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                      : (isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50),
                  foregroundColor: isWrongMode
                      ? (isDark ? Colors.red.shade200 : Colors.red)
                      : (isDark ? Colors.indigo.shade200 : Colors.indigo),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudyScreen(customWords: words),
                    ),
                  ).then((_) => setState(() {}));
                },
                icon: const Icon(Icons.play_circle_fill, size: 16),
                label: Text(
                  isWrongMode
                      ? LocaleService.tr('my_deck_study_wrong')
                      : LocaleService.tr('my_deck_study_bookmark'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: words.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                leading: Container(
                  constraints: const BoxConstraints(maxWidth: 82),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _compactCategory(word.localizedLevel),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (word.furigana.isNotEmpty && word.furigana != word.word) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          word.furigana,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  word.getLocalizedMeaning(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      iconSize: 20,
                      icon: const Icon(
                        Icons.volume_up_outlined,
                        color: Colors.indigo,
                      ),
                      onPressed: () => TtsService.speakWord(word),
                    ),
                    const SizedBox(width: 4),
                    if (isWrongMode)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        iconSize: 20,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                        ),
                        tooltip: LocaleService.tr('tooltip_remove_wrong'),
                        onPressed: () async {
                          await WordService.markWrong(word, false);
                          setState(() {});
                        },
                      )
                    else
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        iconSize: 20,
                        icon: const Icon(Icons.bookmark, color: Colors.amber),
                        tooltip: LocaleService.tr('tooltip_remove_bookmark'),
                        onPressed: () async {
                          await WordService.toggleBookmark(word);
                          setState(() {});
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);
}
}
