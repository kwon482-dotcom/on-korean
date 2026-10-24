import 'package:flutter/material.dart';

import '../models/reading_model.dart';
import '../services/energy_service.dart';
import '../services/locale_service.dart';
import '../services/reading_service.dart';
import '../services/remote_config_service.dart';
import '../services/tts_service.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/energy_badge.dart';
import '../widgets/energy_modal_sheet.dart';
import '../widgets/reading/reading_archive_tab.dart';
import '../widgets/reading/reading_passage_card.dart';
import '../widgets/reading/reading_quiz_card.dart';
import '../widgets/reading/reading_state_cards.dart';
import '../widgets/reading/reading_vocab_dialog.dart';
import '../widgets/reading/reading_vocab_section.dart';

/// AI 실전 랩 화면 (1분 단문 독해 & 1분 청해 리스닝 + 이해 확인 퀴즈 + 어휘 + 보관함)
class ReadingScreen extends StatefulWidget {
  final ReadingModel? initialReading;
  final String? initialMode; // 'reading' | 'listening'

  const ReadingScreen({
    super.key,
    this.initialReading,
    this.initialMode,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLevel = 'N3';
  String _selectedMode = 'reading'; // 'reading' | 'listening'
  ReadingModel? _currentReading;
  bool _isGenerating = false;
  int? _selectedOptionIndex;
  bool _showTranslation = false;
  bool _isLargeFont = false; // 보통(16pt) vs 크게(20pt)
  bool _revealScript = false; // 청해 모드에서 대본 강제 보기 토글
  double _playbackRate = 1.0; // 0.8x | 1.0x | 1.2x
  String _archiveFilter = 'all'; // 'all' | 'reading' | 'listening'

  final List<String> _levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialMode != null) {
      _selectedMode = widget.initialMode!;
    }
    if (widget.initialReading != null) {
      _currentReading = widget.initialReading;
      _selectedLevel = widget.initialReading!.level;
      _selectedMode = widget.initialReading!.type;
    }
  }

  @override
  void dispose() {
    TtsService.stop();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateNewReading() async {
    final cost = RemoteConfigService.getReadingEnergyCost();
    if (!EnergyService.canAfford(cost)) {
      EnergyModalSheet.show(context);
      return;
    }

    setState(() {
      _isGenerating = true;
      _selectedOptionIndex = null;
      _showTranslation = false;
      _revealScript = false;
    });

    try {
      final reading = await ReadingService.generateReading(
        level: _selectedLevel,
        type: _selectedMode,
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          if (reading != null) {
            _currentReading = reading;
            _tabController.animateTo(0);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleService.tr('reading_fail')),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleService.tr('reading_error'))),
        );
      }
    }
  }

  void _toggleComplete() {
    if (_currentReading == null) return;
    final targetState = !_currentReading!.isCompleted;
    setState(() => _currentReading!.isCompleted = targetState);
    ReadingService.setCompleted(_currentReading!.id, targetState);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          targetState
              ? LocaleService.tr('reading_completed_toast')
              : LocaleService.tr('reading_uncompleted_toast'),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleService.tr('reading_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: const [
          EnergyBadge(),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.indigo,
          tabs: [
            Tab(
              icon: const Icon(Icons.psychology_outlined, size: 20),
              text: LocaleService.tr('lab_tab_quiz'),
            ),
            ValueListenableBuilder<List<ReadingModel>>(
              valueListenable: ReadingService.savedReadings,
              builder: (context, list, _) {
                return Tab(
                  icon: const Icon(Icons.folder_special, size: 20),
                  text: '${LocaleService.tr('reading_archive')} (${list.length})',
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudyTab(),
          ReadingArchiveTab(
            currentFilter: _archiveFilter,
            onFilterChanged: (filter) => setState(() => _archiveFilter = filter),
            onSelectReading: (item) {
              setState(() {
                _currentReading = item;
                _selectedLevel = item.level;
                _selectedMode = item.type;
                _selectedOptionIndex = null;
                _showTranslation = false;
                _revealScript = false;
                _tabController.animateTo(0);
              });
            },
            onDeleteReading: (item) async {
              await ReadingService.deleteReading(item.id);
              if (_currentReading?.id == item.id) {
                setState(() => _currentReading = null);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        child: AdBannerWidget(),
      ),
    );
  }

  // 1. 실전 학습 탭 (모드 선택 + 급수 + 지문/리스닝 + 퀴즈 + 해석/단어)
  Widget _buildStudyTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 💡 모드 선택 세그먼트 (1분 독해 vs 1분 청해)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (_selectedMode != 'reading') {
                            TtsService.stop();
                            setState(() {
                              _selectedMode = 'reading';
                              _revealScript = false;
                              if (_currentReading != null && _currentReading!.type != 'reading') {
                                _currentReading = null;
                                _selectedOptionIndex = null;
                                _showTranslation = false;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedMode == 'reading'
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedMode == 'reading'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            LocaleService.tr('lab_mode_reading'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedMode == 'reading' ? FontWeight.bold : FontWeight.normal,
                              color: _selectedMode == 'reading'
                                  ? (isDark ? const Color(0xFFA5B4FC) : Colors.indigo)
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          if (_selectedMode != 'listening') {
                            TtsService.stop();
                            setState(() {
                              _selectedMode = 'listening';
                              _revealScript = false;
                              if (_currentReading != null && _currentReading!.type != 'listening') {
                                _currentReading = null;
                                _selectedOptionIndex = null;
                                _showTranslation = false;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _selectedMode == 'listening'
                                ? (isDark ? const Color(0xFF334155) : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _selectedMode == 'listening'
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            LocaleService.tr('lab_mode_listening'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedMode == 'listening' ? FontWeight.bold : FontWeight.normal,
                              color: _selectedMode == 'listening'
                                  ? (isDark ? const Color(0xFFD8B4FE) : Colors.deepPurple)
                                  : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 급수 선택 칩
              Row(
                children: [
                  Text(
                    '${LocaleService.tr('reading_difficulty')}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _levels.map((lvl) {
                          final isSelected = _selectedLevel == lvl;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(
                                lvl,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                  color: isSelected && isDark ? const Color(0xFFA5B4FC) : null,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: isDark ? const Color(0xFF312E81) : Colors.indigo.shade100,
                              onSelected: (val) {
                                if (val) {
                                  TtsService.stop();
                                  setState(() {
                                    _selectedLevel = lvl;
                                    if (_currentReading != null && _currentReading!.level != lvl) {
                                      _currentReading = null;
                                      _selectedOptionIndex = null;
                                      _showTranslation = false;
                                    }
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isGenerating)
                ReadingLoadingCard(
                  mode: _selectedMode,
                  level: _selectedLevel,
                )
              else if (_currentReading != null) ...[
                ReadingPassageCard(
                  reading: _currentReading!,
                  isLargeFont: _isLargeFont,
                  revealScript: _revealScript,
                  isAnswered: _selectedOptionIndex != null,
                  playbackRate: _playbackRate,
                  onToggleComplete: _toggleComplete,
                  onToggleFontSize: () => setState(() => _isLargeFont = !_isLargeFont),
                  onSpeedChanged: (rate) => setState(() => _playbackRate = rate),
                  onRevealScript: () => setState(() => _revealScript = true),
                ),
                const SizedBox(height: 16),
                ReadingQuizCard(
                  reading: _currentReading!,
                  selectedOptionIndex: _selectedOptionIndex,
                  onSelectOption: (idx) {
                    setState(() {
                      _selectedOptionIndex = idx;
                      _showTranslation = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ReadingVocabSection(
                  reading: _currentReading!,
                  showTranslation: _showTranslation,
                  onAddVocab: (vocab) => ReadingVocabDialog.show(
                    context,
                    vocab: vocab,
                    currentLevel: _currentReading!.level,
                  ),
                ),
              ] else
                ReadingEmptyIntroCard(mode: _selectedMode),

              const SizedBox(height: 16),
              // 하단 생성 버튼
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateNewReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedMode == 'listening' ? Colors.deepPurple : Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _selectedMode == 'listening'
                      ? LocaleService.tr('reading_generate_another_listening', [RemoteConfigService.getReadingEnergyCost()])
                      : LocaleService.tr('reading_generate_another', [RemoteConfigService.getReadingEnergyCost()]),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
