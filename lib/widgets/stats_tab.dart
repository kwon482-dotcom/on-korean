import 'dart:math';

import 'package:flutter/material.dart';

import '../models/reading_model.dart';
import '../screens/reading_screen.dart';
import '../services/locale_service.dart';
import '../services/reading_service.dart';
import '../services/stats_service.dart';
import '../services/word_service.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  int _streak = 0;
  int _todayCount = 0;
  int _todayMasteredCount = 0;
  List<Map<String, dynamic>> _last7Days = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(covariant StatsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await StatsService.getStreak();
    final today = await StatsService.getTodayCount();
    final todayMastered = await StatsService.getTodayMasteredCount();
    final last7 = await StatsService.getLast7Days();

    if (mounted) {
      setState(() {
        _streak = streak;
        _todayCount = today;
        _todayMasteredCount = todayMastered;
        _last7Days = last7;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 7일 중 최대값 (막대 그래프 비율 계산용)
    int maxCount = 10;
    for (var item in _last7Days) {
      maxCount = max(maxCount, item['count'] as int);
    }

    // 💡 단어장에 등록된 모든 카테고리(단어, 문법, 커스텀) 동적 로드
    final categories = WordService.getAllCategories();
    final allWords = WordService.getAllWords();

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. 연속 스트릭 & 오늘 학습 요약 (알아요 / 총 학습수 동시 표기)
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            Text(
                              '🔥 ${LocaleService.tr('stats_streak')}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_streak',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocaleService.tr('streak_days'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Column(
                          children: [
                            Text(
                              '📖 ${LocaleService.tr('stats_today_done')}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_todayMasteredCount',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  LocaleService.tr('stats_unit_words'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _todayCount > 0
                                      ? LocaleService.tr('stats_today_study_sessions', [_todayCount])
                                      : LocaleService.tr('stats_ratio_guide'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

          // 2. 최근 7일 학습량 막대 그래프
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleService.tr('stats_trend_7days'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 13.5,
                        color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          LocaleService.tr('stats_chart_hint'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _last7Days.map((item) {
                        final count = item['count'] as int;
                        final masteredCount = (item['masteredCount'] as int?) ?? 0;
                        final isToday = item['isToday'] as bool;
                        final totalRatio = count > 0 ? (count / maxCount).clamp(0.08, 1.0) : 0.04;
                        final masteredRatio = count > 0 ? ((masteredCount / maxCount).clamp(0.0, totalRatio)) : 0.0;
                        final percent = count > 0 ? ((masteredCount / count) * 100).toStringAsFixed(0) : '0';
                        final tooltipMsg = LocaleService.tr('stats_day_tooltip', [item['dayLabel'], count, masteredCount, percent]);

                        return Tooltip(
                          message: tooltipMsg,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                count > 0 ? '$count' : '',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.indigo
                                      : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // 총 학습량 막대 (배경)
                                  Container(
                                    width: 22,
                                    height: 90 * totalRatio,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? Colors.indigo.shade200
                                          : Colors.indigo.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  // 암기 완료 '알아요' 막대 (진한 전경)
                                  if (masteredRatio > 0)
                                    Container(
                                      width: 22,
                                      height: 90 * masteredRatio,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? Colors.indigo
                                            : Colors.indigo.shade600,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['dayLabel'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isToday ? Colors.indigo : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 막대 범례
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade600,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              LocaleService.tr('stats_legend_mastered'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              LocaleService.tr('stats_legend_total'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. ✨ AI 실전 랩 (청해 · 독해) 독립 통계 요약 카드
          ValueListenableBuilder<List<ReadingModel>>(
            valueListenable: ReadingService.savedReadings,
            builder: (context, readings, _) {
              final readingSets = readings.where((r) => r.type == 'reading').toList();
              final listeningSets = readings.where((r) => r.type == 'listening').toList();
              final readingDone = readingSets.where((r) => r.isCompleted).length;
              final listeningDone = listeningSets.where((r) => r.isCompleted).length;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2E1065) : Colors.deepPurple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.auto_awesome, color: isDark ? const Color(0xFFC084FC) : Colors.deepPurple, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  LocaleService.tr('stats_reading_lab_title'),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReadingScreen(initialMode: 'reading'),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF132E2D) : Colors.teal.shade50.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? const Color(0xFF115E59) : Colors.teal.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              LocaleService.tr('lab_mode_reading'),
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFF2DD4BF) : Colors.teal.shade800,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.chevron_right, size: 14, color: isDark ? const Color(0xFF2DD4BF) : Colors.teal.shade400),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleService.tr('stats_ratio_simple', [readingDone, readingSets.length]),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ReadingScreen(initialMode: 'listening'),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2E1065) : Colors.deepPurple.shade50.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? const Color(0xFF6B21A8) : Colors.deepPurple.shade100),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              LocaleService.tr('lab_mode_listening'),
                                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFC084FC) : Colors.deepPurple.shade800),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.chevron_right, size: 14, color: isDark ? const Color(0xFFC084FC) : Colors.deepPurple.shade400),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleService.tr('stats_ratio_simple', [listeningDone, listeningSets.length]),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 3. 📊 급수/문법/카테고리별 암기 달성률 현황
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          LocaleService.tr('stats_category_progress'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.5) : Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            LocaleService.tr('stats_total_words', [allWords.length]),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (categories.isEmpty)
                    Text(
                      LocaleService.tr('stats_no_categories'),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    )
                  else
                    ...categories.map((cat) {
                      final totalCount = WordService.getWordsByLevel(cat).length;
                      final masteredCount = WordService.getMasteredWordsByLevel(cat).length;
                      final ratio = totalCount > 0 ? (masteredCount / totalCount).clamp(0.0, 1.0) : 0.0;
                      final percent = (ratio * 100).toStringAsFixed(1);

                      final isGrammar = cat.contains('문법');
                      final isKanji = cat.contains('한자');
                      final isTravel = cat.contains('여행');
                      final isBusiness = cat.contains('비즈니스');
                      final isIt = cat.contains('IT') || cat.contains('네트워크');
                      final barColor = isTravel
                          ? Colors.blue.shade600
                          : (isBusiness
                              ? Colors.deepPurple
                              : (isIt
                                  ? Colors.cyan.shade700
                                  : (isGrammar
                                      ? Colors.teal
                                      : (isKanji ? Colors.amber.shade700 : Colors.indigo))));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: barColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          WordService.getLocalizedCategory(cat),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$masteredCount / $totalCount ($percent%)',
                                    style: TextStyle(
                                      color: masteredCount > 0
                                          ? barColor
                                          : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600),
                                      fontWeight: masteredCount > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: totalCount > 0 ? ratio : 0.0,
                                minHeight: 8,
                                backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                                color: barColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
}
