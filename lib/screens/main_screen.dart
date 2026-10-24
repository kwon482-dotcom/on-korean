import 'package:flutter/material.dart';

import '../services/energy_service.dart';
import '../services/locale_service.dart';
import '../services/stats_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/energy_badge.dart';
import '../widgets/library_tab.dart';
import '../widgets/my_deck_tab.dart';
import '../widgets/stats_tab.dart';
import 'reading_screen.dart';
import 'study_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 1. 앱 복귀 시 자정(00:00) 경과 여부 확인 및 일일 무료 AI 에너지(10개) 리셋
      EnergyService.init();
      // 2. 날짜 변경에 따른 스트릭 및 오늘 학습량 대시보드 UI 즉시 갱신
      if (mounted) {
        setState(() {});
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // 앱이 백그라운드로 전환되거나 화면이 잠길 때 재생 중인 일본어 TTS 음성 즉시 정지
      TtsService.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _TodayStudyTab(
        onStartStudy: (category) {
          final words = WordService.getTodayStudyWords(category: category);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudyScreen(customWords: words),
            ),
          ).then((_) => setState(() {}));
        },
        onStartWrongStudy: () {
          final wrongs = WordService.getWrongWords();
          if (wrongs.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleService.tr('empty_wrong'))),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudyScreen(customWords: wrongs),
            ),
          ).then((_) => setState(() {}));
        },
        onStartBookmarkStudy: () {
          final bookmarks = WordService.getBookmarkedWords();
          if (bookmarks.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(LocaleService.tr('empty_bookmark'))),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudyScreen(customWords: bookmarks),
            ),
          ).then((_) => setState(() {}));
        },
      ),
      const LibraryTab(),
      const MyDeckTab(),
      const StatsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleService.tr('app_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const EnergyBadge(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: LocaleService.tr('settings_title'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ), // 💡 누락되었던 AppBar 닫는 괄호
      body: PageView(
        controller: _pageController,
        onPageChanged: (idx) {
          setState(() => _currentIndex = idx);
        },
        children: tabs,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(fontSize: 11.2, fontWeight: FontWeight.bold);
                }
                return const TextStyle(fontSize: 11.2, fontWeight: FontWeight.w500);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) {
                setState(() => _currentIndex = idx);
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.school_outlined),
                  selectedIcon: const Icon(Icons.school),
                  label: LocaleService.tr('nav_today'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.library_books_outlined),
                  selectedIcon: const Icon(Icons.library_books),
                  label: LocaleService.tr('nav_library'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bookmark_outline),
                  selectedIcon: const Icon(Icons.bookmark),
                  label: LocaleService.tr('nav_mydeck'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: LocaleService.tr('nav_stats'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 1. 오늘 학습 대시보드 탭 (카테고리/급수/오답/북마크 선택형 집중 학습)
class _TodayStudyTab extends StatefulWidget {
  final Function(String category) onStartStudy;
  final VoidCallback onStartWrongStudy;
  final VoidCallback onStartBookmarkStudy;

  const _TodayStudyTab({
    required this.onStartStudy,
    required this.onStartWrongStudy,
    required this.onStartBookmarkStudy,
  });

  @override
  State<_TodayStudyTab> createState() => _TodayStudyTabState();
}

class _TodayStudyTabState extends State<_TodayStudyTab> {
  String _selectedCategory = '전체';
  int _streak = 1;
  int _todayCount = 0;
  int _todayMasteredCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant _TodayStudyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await StatsService.getStreak();
    final today = await StatsService.getTodayCount();
    final todayMastered = await StatsService.getTodayMasteredCount();
    if (mounted) {
      setState(() {
        _streak = streak > 0 ? streak : 1;
        _todayCount = today;
        _todayMasteredCount = todayMastered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWords = WordService.getAllWords().length;
    final masteredWords = WordService.getAllMasteredWords().length;
    final progressRatio = totalWords > 0 ? (masteredWords / totalWords).clamp(0.0, 1.0) : 0.0;
    final wrongCount = WordService.getWrongWords().length;
    final bookmarkCount = WordService.getBookmarkedWords().length;
    final categories = WordService.getAllCategories();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🔥 $_streak ${LocaleService.tr('streak_days')}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF312E81) : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _todayCount > 0
                                  ? '${LocaleService.tr('today_studied_badge')}: $_todayMasteredCount/$_todayCount'
                                  : '${LocaleService.tr('today_studied_badge')}: 0',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Text(
                      LocaleService.tr('mastery_progress'),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$masteredWords',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          ' / $totalWords',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${(progressRatio * 100).toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 8,
                        backgroundColor: isDark ? const Color(0xFF334155) : Colors.indigo.shade50,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 💡 오답 및 북마크 카드 (탭하면 바로 해당 단어 복습으로 진입)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onStartWrongStudy,
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      color: isDark ? const Color(0xFF2E1218) : Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isDark
                            ? const BorderSide(color: Color(0xFF7F1D1D))
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              LocaleService.tr('review_wrong'),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFF87171) : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$wrongCount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFF87171) : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: widget.onStartBookmarkStudy,
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      color: isDark ? const Color(0xFF2C2208) : Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isDark
                            ? const BorderSide(color: Color(0xFF78350F))
                            : BorderSide.none,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            Text(
                              LocaleService.tr('saved_bookmarks'),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$bookmarkCount',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 💡 학습할 카테고리 선택기 + 드롭다운 하싯코(옆 모퉁이) 출제 범위 필터 버튼
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: LocaleService.tr('select_category'),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.category_outlined,
                        color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: '전체',
                        child: Text(
                          WordService.getSelectedStudyCategories().length == categories.length
                              ? LocaleService.tr('all_mix')
                              : LocaleService.tr('main_custom_random', [WordService.getSelectedStudyCategories().length]),
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...categories.map(
                        (c) {
                          String prefix = '📖';
                          if (c.contains('여행')) prefix = '✈️';
                          if (c.contains('비즈니스')) prefix = '💼';
                          if (c.contains('한자')) prefix = '🈸';
                          if (c.contains('문법')) prefix = '💡';
                          if (c.contains('가타카나')) prefix = '🔤';
                          if (c.contains('초밥')) prefix = '🍣';
                          if (c.contains('IT') || c.contains('네트워크')) prefix = '💻';

                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              '$prefix ${WordService.getLocalizedCategory(c)} ${LocaleService.tr('focus_study')}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // 💡 드롭다운 하싯코 필터 버튼
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : Colors.indigo.shade100,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                      size: 20,
                    ),
                    tooltip: LocaleService.tr('filter_btn_tooltip'),
                    onPressed: _showFilterDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => widget.onStartStudy(_selectedCategory),
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  _selectedCategory == '전체'
                      ? LocaleService.tr('start_study')
                      : '${WordService.getLocalizedCategory(_selectedCategory)} ${LocaleService.tr('focus_study')}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ✨ AI 실전 랩 (청해 · 독해) 프리미엄 배너 카드
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReadingScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF1E1B4B)]
                        : [
                            Colors.indigo.shade50.withValues(alpha: 0.9),
                            Colors.deepPurple.shade50.withValues(alpha: 0.9),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : Colors.indigo.shade100,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.indigo, Colors.deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                LocaleService.tr('lab_card_title'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2E1065)
                                      : Colors.deepPurple.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  LocaleService.tr('ai_1min'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFC084FC)
                                        : Colors.deepPurple.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            LocaleService.tr('lab_card_subtitle'),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LocaleService.tr('lab_card_sub_desc'),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // 💡 랜덤 학습 출제 범위 설정 모달 바텀시트
  void _showFilterDialog() {
    final allCategories = WordService.getAllCategories();
    final selected = Set<String>.from(WordService.getSelectedStudyCategories());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          LocaleService.tr('filter_title'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${selected.length} / ${allCategories.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LocaleService.tr('filter_desc'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 퀵 프리셋 버튼
                    Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.select_all, size: 16),
                          label: Text(LocaleService.tr('filter_select_all')),
                          onPressed: () {
                            setModalState(() {
                              selected.addAll(allCategories);
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.flight_takeoff, size: 16),
                          label: Text(LocaleService.tr('filter_select_basic')),
                          onPressed: () {
                            setModalState(() {
                              selected.clear();
                              selected.addAll([
                                '여행 일본어',
                                '생활 필수 가타카나',
                                '초밥집 & 생선 한자',
                                'N5',
                                'N5 문법',
                                'N4',
                                'N4 문법',
                              ].where((c) => allCategories.contains(c)));
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allCategories.length,
                        itemBuilder: (context, idx) {
                          final cat = allCategories[idx];
                          final isChecked = selected.contains(cat);

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              WordService.getLocalizedCategory(cat),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            value: isChecked,
                            activeColor: Colors.indigo,
                            onChanged: (bool? val) {
                              setModalState(() {
                                if (val == true) {
                                  selected.add(cat);
                                } else {
                                  if (selected.length > 1) {
                                    selected.remove(cat);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleService.tr('main_filter_min_warning')),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await WordService.setSelectedStudyCategories(selected);
                          if (!context.mounted) return;
                          setState(() {});
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          LocaleService.tr('btn_confirm'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
}
