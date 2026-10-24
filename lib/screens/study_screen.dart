import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/word_model.dart';
import '../services/ai_service.dart';
import '../services/energy_service.dart';
import '../services/locale_service.dart';
import '../services/review_service.dart';
import '../services/stats_service.dart';
import '../services/tts_service.dart';
import '../services/word_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/energy_badge.dart';
import '../widgets/energy_modal_sheet.dart';

class StudyScreen extends StatefulWidget {
  final List<WordModel>? customWords;

  const StudyScreen({super.key, this.customWords});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late List<WordModel> _studyWords;
  int _currentIndex = 0;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;
  bool _isGeneratingAi = false;
  String? _aiError; // 💡 실패 시 에러 메시지 보관

  @override
  void initState() {
    super.initState();
    _studyWords = widget.customWords ?? WordService.getTodayStudyWords();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kIsWeb && _studyWords.isNotEmpty && TtsService.isAutoPlay) {
        TtsService.speakWord(_studyWords[0]);
      }
    });
  }

  @override
  void dispose() {
    TtsService.stop();
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;
  }

  void _nextWord(bool remembered) {
    final currentWord = _studyWords[_currentIndex];
    WordService.recordStudyResult(currentWord, remembered);
    StatsService.recordWordStudied(remembered: remembered);

    if (_currentIndex < _studyWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFront = true;
        _aiError = null; // 💡 다음 단어로 넘어가면 이전 에러 초기화
      });
      _flipController.reset();
      if (TtsService.isAutoPlay) {
        TtsService.speakWord(_studyWords[_currentIndex]);
      }
    } else {
      _showCompletionDialog();
    }
  }

  // 💡 실패 시 다시 시도할 수 있도록 보강된 AI 생성 로직 (에너지 관리 및 보상형 광고 연동)
  Future<void> _generateAiExample(WordModel word) async {
    if (!EnergyService.canAfford(1)) {
      EnergyModalSheet.show(context);
      return;
    }

    setState(() {
      _isGeneratingAi = true;
      _aiError = null;
    });

    try {
      final result = await AiService.generateExample(word);

      if (mounted) {
        setState(() {
          final ko = result['ko']?.trim() ?? '';
          final translation =
              (result['en'] ?? result['trans'] ?? result['ja'])?.trim() ?? '';
          final lang = LocaleService.currentLocale.value.languageCode;

          if (ko.isNotEmpty &&
              !ko.contains('실패했습니다') &&
              AiService.isValidKoreanSentence(ko, translation)) {
            word.exampleKo = ko;
            if (lang == 'ja') {
              word.exampleJa = translation;
            } else {
              word.exampleEn = translation;
            }
            _aiError = null;
            // 💡 생성 성공 시 로컬 영구 캐시 보관 및 에너지 1 소진
            WordService.cacheAiExample(word.id, ko, translation, langCode: lang);
            EnergyService.consume(1);
          } else {
            _aiError = translation.isNotEmpty
                ? translation
                : (lang == 'ja'
                    ? 'AI例文の生成に失敗しました。'
                    : (lang == 'ko'
                        ? 'AI 예문 생성에 실패했습니다.'
                        : 'Failed to generate AI example.'));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiError = LocaleService.currentLocale.value.languageCode == 'en'
              ? 'A temporary error occurred. Please try again.'
              : '일시적인 오류입니다. 다시 시도해 주세요.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAi = false;
        });
      }
    }
  }

  void _showCompletionDialog() {
    // 💡 듀오링고 스타일의 경쾌한 완료 진동 (중간 탭 -> 묵직한 완료 탭)
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });

    final masteredCount = WordService.getAllMasteredWords().length;
    final totalWords = WordService.getAllWords().length;
    final pct = totalWords > 0 ? (masteredCount / totalWords * 100).toStringAsFixed(1) : '0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(LocaleService.tr('study_complete_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleService.tr('study_session_completed'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleService.tr('study_overall_progress', [masteredCount, totalWords, pct]),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LocaleService.tr('study_review_tip'),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ReviewService.checkAndRequestReview(
                  currentCount: masteredCount,
                  targetThreshold: 30,
                );
              },
              child: Text(LocaleService.tr('btn_confirm')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_studyWords.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(LocaleService.tr('study_empty'))),
      );
    }

    final currentWord = _studyWords[_currentIndex];
    final progress = (_currentIndex + 1) / _studyWords.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentIndex + 1} / ${_studyWords.length}'),
        centerTitle: true,
        actions: [
          const EnergyBadge(),
          IconButton(
            icon: Icon(
              currentWord.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: currentWord.isBookmarked ? Colors.amber : null,
            ),
            onPressed: () async {
              await WordService.toggleBookmark(currentWord);
              setState(() {});
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress, minHeight: 4),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final angle = _flipAnimation.value * pi;
                      final isUnder = angle > (pi / 2);

                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        alignment: Alignment.center,
                        child: isUnder
                            ? Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildBackCard(currentWord),
                              )
                            : _buildFrontCard(currentWord),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () => _nextWord(false),
                      icon: const Icon(Icons.close),
                      label: Text(
                        LocaleService.tr('study_dont_know'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _nextWord(true),
                      icon: const Icon(Icons.check),
                      label: Text(
                        LocaleService.tr('study_know'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  bottomNavigationBar: const SafeArea(
    child: AdBannerWidget(),
  ),
);
}

  Widget _buildFrontCard(WordModel word) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGrammar = word.level.contains('문법') || word.partOfSpeech == '문법';
    final isKanji = word.level.contains('한자') || word.partOfSpeech == '한자';

    final badgeBgColor = isDark
        ? (isKanji
            ? const Color(0xFF78350F)
            : (isGrammar ? const Color(0xFF134E4A) : const Color(0xFF312E81)))
        : (isKanji
            ? Colors.amber.shade100
            : (isGrammar ? Colors.teal.shade50 : Colors.indigo.shade50));
    final badgeTextColor = isDark
        ? (isKanji
            ? const Color(0xFFFDE68A)
            : (isGrammar ? const Color(0xFF5EEAD4) : const Color(0xFFA5B4FC)))
        : (isKanji
            ? Colors.brown.shade800
            : (isGrammar ? Colors.teal.shade700 : Colors.indigo));

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    word.localizedLevel,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildCardStatusTag(word, isDark),
              ],
            ),
            const Spacer(),
            if (isGrammar)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LocaleService.tr('card_grammar_indicator'),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                  ),
                ),
              )
            else if (isKanji)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2208) : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF78350F) : Colors.amber.shade200,
                  ),
                ),
                child: Text(
                  LocaleService.tr('card_kanji_indicator'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFDE68A) : Colors.brown.shade800,
                  ),
                ),
              )
            else
              Text(
                word.furigana,
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              word.word,
              style: TextStyle(
                fontSize: isKanji ? 68 : (isGrammar ? 38 : 48),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            IconButton.filledTonal(
              iconSize: 28,
              icon: const Icon(Icons.volume_up_rounded),
              onPressed: () => TtsService.speakWord(word),
            ),
            const Spacer(),
            Text(
              LocaleService.tr('study_tap_flip'),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStatusTag(WordModel word, bool isDark) {
    String label;
    IconData icon;
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (word.isWrong) {
      label = LocaleService.tr('tag_review');
      icon = Icons.refresh_rounded;
      bgColor = isDark ? const Color(0xFF4C1D24) : const Color(0xFFFEE2E2);
      textColor = isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700;
      borderColor = Colors.redAccent.withValues(alpha: 0.4);
    } else if (word.isMastered) {
      label = LocaleService.tr('tag_check');
      icon = Icons.verified_outlined;
      bgColor = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      textColor = isDark ? const Color(0xFF6EE7B7) : Colors.teal.shade800;
      borderColor = Colors.teal.withValues(alpha: 0.4);
    } else {
      label = LocaleService.tr('tag_new');
      icon = Icons.auto_awesome;
      bgColor = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
      textColor = isDark ? const Color(0xFF93C5FD) : Colors.indigo.shade700;
      borderColor = Colors.indigo.withValues(alpha: 0.4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.5, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(WordModel word) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGrammar = word.level.contains('문법') || word.partOfSpeech == '문법';
    final isKanji = word.level.contains('한자') || word.partOfSpeech == '한자';

    final cardBgColor = isDark
        ? (isKanji
            ? const Color(0xFF1C1917)
            : (isGrammar
                ? const Color(0xFF042F2E)
                : const Color(0xFF1E293B)))
        : (isKanji
            ? Colors.amber.shade50
            : (isGrammar ? Colors.teal.shade50 : Colors.indigo.shade50));
    final primaryTextColor = isDark
        ? (isKanji
            ? const Color(0xFFFDE68A)
            : (isGrammar ? const Color(0xFF5EEAD4) : const Color(0xFF818CF8)))
        : (isKanji
            ? Colors.brown.shade800
            : (isGrammar ? Colors.teal.shade800 : Colors.indigo));

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      color: cardBgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // 1. 상단 품사/레벨 뱃지 (상단 고정)
            if (word.partOfSpeech.isNotEmpty)
              Text(
                '[ ${word.getLocalizedPartOfSpeech()} ]',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                ),
              )
            else
              const SizedBox(height: 18),

            // 2. 카드 중앙 컨텐츠 (공간 내에서 자동 중앙 정렬 & 긴 본문 발생 시 스르륵 부드럽게 위아래로 확장)
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        word.getLocalizedMeaning(),
                        style: TextStyle(
                          fontSize: isGrammar ? 26 : (isKanji ? 28 : 32),
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGrammar || isKanji
                            ? word.word
                            : '${word.word} (${word.furigana})',
                        style: TextStyle(
                          fontSize: isKanji ? 22 : 16.5,
                          fontWeight: isKanji ? FontWeight.bold : FontWeight.normal,
                          color: isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // 💡 문법 카드일 경우 접속 형태 안내 박스
                      if (isGrammar && word.furigana.isNotEmpty && word.furigana != word.word) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF0D9488) : Colors.teal.shade200,
                            ),
                          ),
                          child: Text(
                            '${LocaleService.tr('grammar_connect')}: ${word.furigana}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF5EEAD4) : Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ],
                      // 💡 한자 카드일 경우 음독/훈독 안내 박스
                      if (isKanji && word.furigana.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFFD97706) : Colors.amber.shade300,
                            ),
                          ),
                          child: Text(
                            word.furigana,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFFFDE68A) : Colors.brown.shade900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // 💡 예문 노출 또는 AI 생성 버튼 (부드러운 크기 전환 애니메이션)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: (word.targetExample.isNotEmpty && AiService.isValidKoreanSentence(word.targetExample))
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : Colors.transparent,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.auto_awesome,
                                              size: 13,
                                              color: isDark ? const Color(0xFF818CF8) : Colors.indigo.shade400,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              LocaleService.tr('card_ai_example_label'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? const Color(0xFF818CF8) : Colors.indigo.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                              icon: _isGeneratingAi
                                                  ? SizedBox(
                                                      width: 14,
                                                      height: 14,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                                                      ),
                                                    )
                                                  : Icon(
                                                      Icons.refresh_rounded,
                                                      size: 17,
                                                      color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                                                    ),
                                              tooltip: LocaleService.tr('ai_regenerate'),
                                              onPressed: _isGeneratingAi
                                                  ? null
                                                  : () => _generateAiExample(word),
                                            ),
                                            const SizedBox(width: 6),
                                            IconButton(
                                              visualDensity: VisualDensity.compact,
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(),
                                              icon: Icon(
                                                Icons.volume_up_rounded,
                                                size: 17,
                                                color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                                              ),
                                              tooltip: LocaleService.tr('listen_example'),
                                              onPressed: () => TtsService.speak(word.targetExample),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      word.targetExample,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      word.getLocalizedExampleMeaning(),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                                        height: 1.35,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_aiError != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        _aiError!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      LocaleService.tr('ai_disclaimer'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isGeneratingAi)
                                    const SizedBox(
                                      height: 36,
                                      width: 36,
                                      child: CircularProgressIndicator(strokeWidth: 3),
                                    )
                                  else ...[
                                    if (_aiError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          _aiError!,
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                                        side: BorderSide(
                                          color: _aiError != null
                                              ? Colors.redAccent
                                              : (isDark ? const Color(0xFF6366F1) : Colors.indigo),
                                        ),
                                      ),
                                      onPressed: () => _generateAiExample(word),
                                      icon: Icon(
                                        _aiError != null
                                            ? Icons.refresh_rounded
                                            : Icons.auto_awesome,
                                        size: 16,
                                        color: _aiError != null
                                            ? Colors.redAccent
                                            : (isDark ? const Color(0xFF818CF8) : Colors.indigo),
                                      ),
                                      label: Text(
                                        _aiError != null
                                            ? LocaleService.tr('ai_retry')
                                            : LocaleService.tr('ai_example'),
                                        style: TextStyle(
                                          color: _aiError != null
                                              ? Colors.redAccent
                                              : (isDark ? const Color(0xFF818CF8) : Colors.indigo),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. 하단 카드 뒤집기 안내 (하단 고정)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                LocaleService.tr('study_tap_front'),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
