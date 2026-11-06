import 'package:flutter/material.dart';

import '../../services/locale_service.dart';
import '../../services/word_service.dart';

/// 랜덤 학습 출제 범위(카테고리) 설정 모달 바텀시트
class SettingsCategoryFilterSheet {
  static Future<void> show(BuildContext context, {VoidCallback? onApplied}) async {
    final allCategories = WordService.getAllCategories();
    final selected = Set<String>.from(WordService.getSelectedStudyCategories());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
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
                          color: Colors.grey.shade300,
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${selected.length} / ${allCategories.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      LocaleService.tr('filter_desc'),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
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
                                '한글 기초 & 생존 회화',
                                'TOPIK I 초급 필수 어휘',
                                '자음·모음 & 필수 첫걸음',
                                '숫자·시간·날짜 & 생활 기초',
                                '일상 필수 동사 & 형용사',
                                '생존 생활 표현 & 여행 어휘',
                                '학교 생활 & 취미·여가',
                                '쇼핑·시장 & 대중교통',
                                '음식·식당 & 한국 음식',
                                '날씨·계절 & 병원·약국',
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
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                          onApplied?.call();
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
