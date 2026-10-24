import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_service.dart';
import 'reading_service.dart';
import 'word_service.dart';

/// 학습 진도, 북마크, 오답노트, 단어장 백업 및 복원 서비스
class BackupService {
  static const int currentBackupVersion = 1;

  /// 백업 JSON 문자열 생성
  static Future<String> generateBackupJson() async {
    final prefs = await SharedPreferences.getInstance();

    final mastered = prefs.getStringList('mastered_word_ids') ?? [];
    final bookmarks = prefs.getStringList('bookmarked_word_ids') ?? [];
    final wrongs = prefs.getStringList('wrong_word_ids') ?? [];
    final customWordsRaw = prefs.getString('user_custom_words');
    final customCategories =
        prefs.getStringList('user_custom_categories') ?? [];
    final selectedCategories =
        prefs.getStringList('selected_study_categories') ?? [];
    final cachedAiRaw = prefs.getString('cached_ai_examples');
    final timestampsRaw = prefs.getString('last_reviewed_timestamps');
    final savedReadingsRaw = prefs.getString('saved_ai_readings');
    final dailyCountsRaw = prefs.getString('daily_study_counts');
    final dailyMasteredRaw = prefs.getString('daily_mastered_counts');
    final streak = prefs.getInt('study_streak_days') ?? 0;
    final lastStudyDate = prefs.getString('last_study_date') ?? '';

    final Map<String, dynamic> backupData = {
      'app': 'on-korean',
      'version': currentBackupVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'mastered_word_ids': mastered,
      'bookmarked_word_ids': bookmarks,
      'wrong_word_ids': wrongs,
      'user_custom_words':
          customWordsRaw != null ? jsonDecode(customWordsRaw) : [],
      'user_custom_categories': customCategories,
      'selected_study_categories': selectedCategories,
      'cached_ai_examples': cachedAiRaw != null ? jsonDecode(cachedAiRaw) : {},
      'last_reviewed_timestamps':
          timestampsRaw != null ? jsonDecode(timestampsRaw) : {},
      'saved_ai_readings':
          savedReadingsRaw != null ? jsonDecode(savedReadingsRaw) : [],
      'daily_study_counts':
          dailyCountsRaw != null ? jsonDecode(dailyCountsRaw) : {},
      'daily_mastered_counts':
          dailyMasteredRaw != null ? jsonDecode(dailyMasteredRaw) : {},
      'study_streak_days': streak,
      'last_study_date': lastStudyDate,
    };

    return jsonEncode(backupData);
  }

  /// 백업 내보내기 (.json 파일 생성 및 공유)
  static Future<void> exportBackup(BuildContext context) async {
    try {
      final jsonStr = await generateBackupJson();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final fileName = 'on_vocab_backup_$dateStr.json';

      // 1. 임시 디렉터리에 실제 .json 파일 생성 (파일 공유)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(jsonStr, flush: true);

      // 2. 안드로이드 다운로드 공용 폴더에도 백업 사본 저장 시도
      if (!kIsWeb && Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            final publicFile = File('${downloadDir.path}/$fileName');
            await publicFile.writeAsString(jsonStr, flush: true);
          }
        } catch (_) {}
      }

      // 3. 파일 공유 실행 (카카오톡, 구글 드라이브, 메일 등)
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(tempFile.path, mimeType: 'application/json', name: fileName)
          ],
          subject: fileName,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleService.tr('settings_backup_export_fail', [e.toString()]),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// 백업 복원 (.json 파일 선택 및 병합 복원)
  static Future<void> importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(LocaleService.tr('settings_backup_import')),
        content: Text(LocaleService.tr('settings_backup_import_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(LocaleService.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LocaleService.tr('confirm')),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (picked != null && picked.path != null) {
        final file = File(picked.path!);
        final jsonStr = await file.readAsString();

        final success = await restoreFromJson(jsonStr);
        if (!context.mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleService.tr('settings_backup_import_success')),
              backgroundColor: Colors.indigo,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleService.tr('settings_backup_invalid')),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleService.tr('settings_backup_import_fail', [e.toString()]),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  /// JSON 문자열을 파싱하여 SharedPreferences에 안전하게 병합/복원
  static Future<bool> restoreFromJson(String jsonStr) async {
    try {
      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return false;

      // app 검증 (on-korean 또는 on-vocab 백업 파일 호환 확인)
      if (decoded['app'] != null && decoded['app'] != 'on-korean' && decoded['app'] != 'on-vocab') {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      // 1. mastered_word_ids 병합 (기존 암기 완료 단어 보존 + 백업 합산)
      if (decoded['mastered_word_ids'] is List) {
        final existing = prefs.getStringList('mastered_word_ids') ?? [];
        final incoming = (decoded['mastered_word_ids'] as List)
            .map((e) => e.toString())
            .toList();
        final merged = {...existing, ...incoming}.toList();
        await prefs.setStringList('mastered_word_ids', merged);
      }

      // 2. bookmarked_word_ids 병합
      if (decoded['bookmarked_word_ids'] is List) {
        final existing = prefs.getStringList('bookmarked_word_ids') ?? [];
        final incoming = (decoded['bookmarked_word_ids'] as List)
            .map((e) => e.toString())
            .toList();
        final merged = {...existing, ...incoming}.toList();
        await prefs.setStringList('bookmarked_word_ids', merged);
      }

      // 3. wrong_word_ids 병합
      if (decoded['wrong_word_ids'] is List) {
        final existing = prefs.getStringList('wrong_word_ids') ?? [];
        final incoming = (decoded['wrong_word_ids'] as List)
            .map((e) => e.toString())
            .toList();
        final merged = {...existing, ...incoming}.toList();
        await prefs.setStringList('wrong_word_ids', merged);
      }

      // 4. user_custom_categories 병합
      if (decoded['user_custom_categories'] is List) {
        final existing = prefs.getStringList('user_custom_categories') ?? [];
        final incoming = (decoded['user_custom_categories'] as List)
            .map((e) => e.toString())
            .toList();
        final merged = {...existing, ...incoming}.toList();
        await prefs.setStringList('user_custom_categories', merged);
      }

      // 5. user_custom_words 병합 (동일 단어 중복 방지)
      if (decoded['user_custom_words'] is List) {
        final existingRaw = prefs.getString('user_custom_words');
        List<dynamic> existingList =
            existingRaw != null ? jsonDecode(existingRaw) : [];
        final incomingList = decoded['user_custom_words'] as List;

        final Map<String, dynamic> wordsMap = {};
        for (var item in existingList) {
          if (item is Map) {
            final key = '${item['word']}_${item['level']}';
            wordsMap[key] = item;
          }
        }
        for (var item in incomingList) {
          if (item is Map) {
            final key = '${item['word']}_${item['level']}';
            wordsMap[key] = item;
          }
        }
        await prefs.setString(
          'user_custom_words',
          jsonEncode(wordsMap.values.toList()),
        );
      }

      // 6. saved_ai_readings 독해 보관함 병합
      if (decoded['saved_ai_readings'] is List) {
        final existingRaw = prefs.getString('saved_ai_readings');
        List<dynamic> existingList =
            existingRaw != null ? jsonDecode(existingRaw) : [];
        final incomingList = decoded['saved_ai_readings'] as List;

        final Map<String, dynamic> readingsMap = {};
        for (var item in existingList) {
          if (item is Map && item['id'] != null) {
            readingsMap[item['id'].toString()] = item;
          }
        }
        for (var item in incomingList) {
          if (item is Map && item['id'] != null) {
            readingsMap[item['id'].toString()] = item;
          }
        }
        await prefs.setString(
          'saved_ai_readings',
          jsonEncode(readingsMap.values.toList()),
        );
      }

      // 7. cached_ai_examples 캐시 예문 병합
      if (decoded['cached_ai_examples'] is Map) {
        final existingRaw = prefs.getString('cached_ai_examples');
        Map<String, dynamic> existingMap =
            existingRaw != null ? jsonDecode(existingRaw) : {};
        final incomingMap =
            decoded['cached_ai_examples'] as Map<String, dynamic>;
        existingMap.addAll(incomingMap);
        await prefs.setString('cached_ai_examples', jsonEncode(existingMap));
      }

      // 7-1. last_reviewed_timestamps 학습 시각 병합
      if (decoded['last_reviewed_timestamps'] is Map) {
        final existingRaw = prefs.getString('last_reviewed_timestamps');
        Map<String, dynamic> existingMap =
            existingRaw != null ? jsonDecode(existingRaw) : {};
        final incomingMap =
            decoded['last_reviewed_timestamps'] as Map<String, dynamic>;
        existingMap.addAll(incomingMap);
        await prefs.setString('last_reviewed_timestamps', jsonEncode(existingMap));
      }

      // 8. 학습 통계 병합 (일별 학습량, 스트릭 등)
      if (decoded['daily_study_counts'] is Map) {
        final existingRaw = prefs.getString('daily_study_counts');
        Map<String, dynamic> existingMap =
            existingRaw != null ? jsonDecode(existingRaw) : {};
        final incomingMap =
            decoded['daily_study_counts'] as Map<String, dynamic>;
        for (var entry in incomingMap.entries) {
          final cur = (existingMap[entry.key] as num?)?.toInt() ?? 0;
          final inc = (entry.value as num?)?.toInt() ?? 0;
          existingMap[entry.key] = cur > inc ? cur : inc;
        }
        await prefs.setString('daily_study_counts', jsonEncode(existingMap));
      }

      if (decoded['daily_mastered_counts'] is Map) {
        final existingRaw = prefs.getString('daily_mastered_counts');
        Map<String, dynamic> existingMap =
            existingRaw != null ? jsonDecode(existingRaw) : {};
        final incomingMap =
            decoded['daily_mastered_counts'] as Map<String, dynamic>;
        for (var entry in incomingMap.entries) {
          final cur = (existingMap[entry.key] as num?)?.toInt() ?? 0;
          final inc = (entry.value as num?)?.toInt() ?? 0;
          existingMap[entry.key] = cur > inc ? cur : inc;
        }
        await prefs.setString('daily_mastered_counts', jsonEncode(existingMap));
      }

      if (decoded['study_streak_days'] is int) {
        final existingStreak = prefs.getInt('study_streak_days') ?? 0;
        final incomingStreak = decoded['study_streak_days'] as int;
        if (incomingStreak > existingStreak) {
          await prefs.setInt('study_streak_days', incomingStreak);
        }
      }

      // 9. 메모리 내 상태 동기화
      await WordService.reloadFromPrefs();
      await ReadingService.init();

      return true;
    } catch (e) {
      debugPrint('[BackupService] 복원 처리 중 오류: $e');
      return false;
    }
  }
}
