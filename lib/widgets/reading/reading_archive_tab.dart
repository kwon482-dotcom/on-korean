import 'package:flutter/material.dart';

import '../../models/reading_model.dart';
import '../../services/locale_service.dart';
import '../../services/reading_service.dart';

/// 내 보관함 탭 (이전에 생성해둔 지문/청해 목록 + 필터 + 삭제)
class ReadingArchiveTab extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<ReadingModel> onSelectReading;
  final ValueChanged<ReadingModel> onDeleteReading;

  const ReadingArchiveTab({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onSelectReading,
    required this.onDeleteReading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: ValueListenableBuilder<List<ReadingModel>>(
          valueListenable: ReadingService.savedReadings,
          builder: (context, readings, _) {
            if (readings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        LocaleService.tr('reading_empty_archive'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            }

            final filtered = readings.where((r) {
              if (currentFilter == 'reading') return r.type != 'listening';
              if (currentFilter == 'listening') return r.type == 'listening';
              return true;
            }).toList();

            return Column(
              children: [
                // 보관함 필터 칩 바
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(
                          '${LocaleService.tr('archive_filter_all')} (${readings.length})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: currentFilter == 'all',
                        selectedColor: Colors.indigo.shade100,
                        onSelected: (val) {
                          if (val) onFilterChanged('all');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(
                          '${LocaleService.tr('archive_filter_reading')} (${readings.where((r) => r.type != 'listening').length})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: currentFilter == 'reading',
                        selectedColor: Colors.teal.shade100,
                        onSelected: (val) {
                          if (val) onFilterChanged('reading');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text(
                          '${LocaleService.tr('archive_filter_listening')} (${readings.where((r) => r.type == 'listening').length})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: currentFilter == 'listening',
                        selectedColor: Colors.deepPurple.shade100,
                        onSelected: (val) {
                          if (val) onFilterChanged('listening');
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            LocaleService.tr('archive_empty_filtered'),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, idx) {
                            final item = filtered[idx];
                            final isListening = item.type == 'listening';
                            final dateStr =
                                '${item.createdAt.year}.${item.createdAt.month.toString().padLeft(2, '0')}.${item.createdAt.day.toString().padLeft(2, '0')}';

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isListening ? Colors.deepPurple.shade50 : Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.level,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isListening ? Colors.deepPurple : Colors.indigo,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        isListening ? '🎧' : '📖',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                subtitle: Text(
                                  '$dateStr • ${item.theme} • ${item.isCompleted ? LocaleService.tr('reading_completed') : LocaleService.tr('reading_incomplete')}',
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => onDeleteReading(item),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                                onTap: () => onSelectReading(item),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
