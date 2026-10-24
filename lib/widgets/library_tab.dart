import 'package:flutter/material.dart';

import '../screens/reading_screen.dart';
import '../screens/study_screen.dart';
import '../services/locale_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ➕ 새 카테고리(단어장) 추가 다이얼로그
  void _showAddCategoryDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleService.tr('add_category')),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: LocaleService.tr('add_category_hint'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleService.tr('btn_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCat = textController.text.trim();
              if (newCat.isNotEmpty) {
                await WordService.addCategory(newCat);
                if (mounted) setState(() {});
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(LocaleService.tr('btn_add')),
          ),
        ],
      ),
    );
  }

  // 📖 특정 카테고리 단어 목록 모달 바텀시트
  void _showWordListModal(BuildContext context, String category) {
    final words = WordService.getWordsByLevel(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    // 상단 핸들
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 헤더 바 (카테고리명 + 학습 시작 버튼)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                WordService.getLocalizedCategory(category),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${words.length} ${LocaleService.tr('words_registered')}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudyScreen(customWords: words),
                                ),
                              ).then((_) {
                                if (mounted) setState(() {});
                              });
                            },
                            icon: const Icon(Icons.play_arrow, size: 18),
                            label: Text(
                              LocaleService.tr('focus_study'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                    // 단어 리스트
                    Expanded(
                      child: words.isEmpty
                          ? Center(
                              child: Text(
                                LocaleService.tr('empty_category', [WordService.getLocalizedCategory(category)]),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: words.length,
                              separatorBuilder: (_, __) =>
                                  Divider(height: 1, color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                              itemBuilder: (context, idx) {
                                final word = words[idx];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  title: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          word.word,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (word.furigana.isNotEmpty &&
                                          word.furigana != word.word) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            word.furigana,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      word.getLocalizedMeaning(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.volume_up, size: 20),
                                        color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo,
                                        onPressed: () => TtsService.speakWord(word),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          word.isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          size: 20,
                                          color: word.isBookmarked
                                              ? Colors.amber
                                              : (isDark ? const Color(0xFF64748B) : Colors.grey),
                                        ),
                                        onPressed: () async {
                                          await WordService.toggleBookmark(word);
                                          setModalState(() {});
                                          if (mounted) setState(() {});
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = WordService.getAllCategories();

    // 💡 체계적인 한국어 5대 코스 정의
    final courses = [
      _CourseDef(
        title: LocaleService.tr('course_hangul'),
        subtitle: LocaleService.tr('course_hangul_sub'),
        icon: Icons.school,
        color: Colors.indigo,
        categories: ['한글 기초 & 생존 회화'].where((c) => allCategories.contains(c)).toList(),
      ),
      _CourseDef(
        title: LocaleService.tr('course_topik1'),
        subtitle: LocaleService.tr('course_topik1_sub'),
        icon: Icons.auto_stories,
        color: Colors.blue.shade700,
        categories: ['TOPIK I 초급 필수 어휘'].where((c) => allCategories.contains(c)).toList(),
      ),
      _CourseDef(
        title: LocaleService.tr('course_topik2'),
        subtitle: LocaleService.tr('course_topik2_sub'),
        icon: Icons.menu_book,
        color: Colors.teal.shade700,
        categories: ['TOPIK II 중급 핵심 어휘'].where((c) => allCategories.contains(c)).toList(),
      ),
      _CourseDef(
        title: LocaleService.tr('course_kdrama'),
        subtitle: LocaleService.tr('course_kdrama_sub'),
        icon: Icons.stars,
        color: Colors.pink.shade600,
        categories: ['K-드라마 & 실전 리얼 회화'].where((c) => allCategories.contains(c)).toList(),
      ),
      _CourseDef(
        title: LocaleService.tr('course_business'),
        subtitle: LocaleService.tr('course_business_sub'),
        icon: Icons.business_center,
        color: Colors.brown.shade700,
        categories: ['비즈니스 & 시사 고급 한국어'].where((c) => allCategories.contains(c)).toList(),
      ),
    ];

    // 표준 코스에 포함되지 않은 사용자 정의/가져오기 카테고리 수집
    final standardSet = {
      '한글 기초 & 생존 회화',
      'TOPIK I 초급 필수 어휘',
      'TOPIK II 중급 핵심 어휘',
      'K-드라마 & 실전 리얼 회화',
      '비즈니스 & 시사 고급 한국어',
    };
    final customCategories = allCategories.where((c) => !standardSet.contains(c)).toList();

    if (customCategories.isNotEmpty) {
      courses.add(
        _CourseDef(
          title: LocaleService.tr('course_custom'),
          subtitle: LocaleService.tr('course_custom_sub'),
          icon: Icons.folder_special,
          color: Colors.blueGrey.shade700,
          categories: customCategories,
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Row(
                children: [
                  // 1. 🔍 실시간 통합 검색창
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: LocaleService.tr('search_hint'),
                          hintStyle: const TextStyle(fontSize: 14),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.indigo,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 2. ➕ 새 카테고리 추가 버튼
                  IconButton(
                    icon: const Icon(
                      Icons.playlist_add,
                      color: Colors.indigo,
                      size: 26,
                    ),
                    tooltip: LocaleService.tr('add_category'),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: _searchQuery.isNotEmpty
              ? _buildSearchResults()
              : _buildCourseAccordionList(courses),
        ),
      ),
    );
  }

  // 🔍 1. 검색 모드 화면
  Widget _buildSearchResults() {
    final results = WordService.searchWords(query: _searchQuery);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              LocaleService.tr('search_empty'),
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            LocaleService.tr('search_results_count', [results.length]),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, idx) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final word = results[idx];
              return ListTile(
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        word.word,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (word.furigana.isNotEmpty && word.furigana != word.word) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          word.furigana,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
                      const Spacer(),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        word.localizedLevel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(word.getLocalizedMeaning(), style: const TextStyle(fontSize: 14)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      color: Colors.indigo,
                      onPressed: () => TtsService.speakWord(word),
                    ),
                    IconButton(
                      icon: Icon(
                        word.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: word.isBookmarked ? Colors.amber : Colors.grey,
                      ),
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
    );
  }

  // 📂 2. 메인 카드형 폴더 아코디언 목록 화면
  Widget _buildCourseAccordionList(List<_CourseDef> courses) {
    final totalAllWords = WordService.getAllWords().length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        // 상단 보관함 요약 카드
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.collections_bookmark, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleService.tr('nav_library'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      LocaleService.tr('library_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  LocaleService.tr('stats_total_words', [totalAllWords]),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 📚 AI 1분 단문 독해실 특별 배너 카드
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.indigo.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_stories, color: Colors.indigo, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                LocaleService.tr('reading_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            LocaleService.tr('lab_banner_sub'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 코스별 아코디언 카드 렌더링
        ...courses.map((course) => _buildCourseCard(course)),
      ],
    );
  }

  // 🗂️ 개별 코스 폴더 카드 (터치 시 스르륵 펼쳐짐)
  Widget _buildCourseCard(_CourseDef course) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int courseTotalWords = 0;
    for (var cat in course.categories) {
      courseTotalWords += WordService.getWordsByLevel(cat).length;
    }

    return Card(
      elevation: isDark ? 0 : 1.5,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: course.color.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(course.icon, color: course.color, size: 24),
        ),
        title: Text(
          course.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            course.subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: course.color.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            LocaleService.tr('course_words_count', [courseTotalWords]),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: course.color,
            ),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: course.categories.map((cat) {
          final words = WordService.getWordsByLevel(cat);
          final masteredCount = WordService.getMasteredWordsByLevel(cat).length;

          IconData subIcon = Icons.article_outlined;
          if (cat.contains('한자')) subIcon = Icons.square_outlined;
          if (cat.contains('문법')) subIcon = Icons.lightbulb_outline;
          if (cat.contains('여행')) subIcon = Icons.flight_takeoff;
          if (cat.contains('비즈니스')) subIcon = Icons.business_center_outlined;
          if (cat.contains('가타카나')) subIcon = Icons.translate;
          if (cat.contains('초밥')) subIcon = Icons.restaurant;
          if (cat.contains('IT') || cat.contains('네트워크')) subIcon = Icons.computer;

          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(subIcon, size: 20, color: course.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        WordService.getLocalizedCategory(cat),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LocaleService.tr('library_category_mastery', [masteredCount, words.length]),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 1. 단어 목록 보기 버튼
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity.compact,
                    foregroundColor: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                  ),
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: Text(
                    LocaleService.tr('view_words'),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _showWordListModal(context, cat),
                ),
                const SizedBox(width: 4),
                // 2. 해당 카테고리 즉시 집중 학습 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: course.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudyScreen(customWords: words),
                      ),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        LocaleService.tr('btn_study_short'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 💡 코스 정의 데이터 모델
class _CourseDef {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> categories;

  _CourseDef({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.categories,
  });
}
