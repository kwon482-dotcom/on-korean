import 'package:flutter/material.dart';

import '../../services/locale_service.dart';

/// 문제 생성 로딩 인디케이터 카드
class ReadingLoadingCard extends StatelessWidget {
  final String mode; // 'reading' | 'listening'
  final String level;

  const ReadingLoadingCard({
    super.key,
    required this.mode,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = mode == 'listening';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            CircularProgressIndicator(
              color: isListening ? Colors.deepPurple : Colors.indigo,
            ),
            const SizedBox(height: 20),
            Text(
              isListening
                  ? LocaleService.tr('reading_generating_listening', [level])
                  : LocaleService.tr('reading_generating_level', [level]),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
            ),
            const SizedBox(height: 8),
            Text(
              isListening
                  ? LocaleService.tr('reading_generating_listening_desc')
                  : LocaleService.tr('reading_generating'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

/// 초기 진입 시 안내 카드
class ReadingEmptyIntroCard extends StatelessWidget {
  final String mode; // 'reading' | 'listening'

  const ReadingEmptyIntroCard({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = mode == 'listening';
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isListening ? Colors.deepPurple.shade50 : Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isListening ? Icons.headphones : Icons.menu_book,
                size: 36,
                color: isListening ? Colors.deepPurple : Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isListening
                  ? LocaleService.tr('reading_intro_listening_title')
                  : LocaleService.tr('reading_intro_title'),
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isListening
                  ? LocaleService.tr('reading_intro_listening_desc')
                  : LocaleService.tr('reading_intro_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
