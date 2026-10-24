// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps
import 'dart:convert';
import 'dart:io';

import 'data_n5.dart';
import 'data_n4.dart';
import 'data_n3.dart';
import 'data_n2.dart';
import 'data_n1.dart';
import 'data_extra.dart';

void main() async {
  final assetFile = File('assets/data/jlpt_words.json');
  if (!assetFile.existsSync()) {
    print('Error: assets/data/jlpt_words.json not found!');
    return;
  }

  final rawJson = assetFile.readAsStringSync();
  final List<dynamic> existingList = jsonDecode(rawJson);
  print('기존 데이터 개수: ${existingList.length}개');

  // 중복 체크용 Set: (level + '::' + word)
  final Set<String> seen = {};
  final List<Map<String, dynamic>> combined = [];

  // 1. 기존 데이터 등록
  for (final item in existingList) {
    final level = item['level']?.toString() ?? 'N5';
    final word = item['word']?.toString() ?? '';
    final key = '$level::$word';
    if (!seen.contains(key) && word.isNotEmpty) {
      seen.add(key);
      combined.add(Map<String, dynamic>.from(item));
    }
  }

  // 2. 확장 데이터 추가 헬퍼
  void addLevelData(String levelPrefix, List<Map<String, String>> data) {
    for (final item in data) {
      final partOfSpeech = item['partOfSpeech'] ?? '명사';
      String targetLevel = levelPrefix;
      if (partOfSpeech == '문법') {
        targetLevel = '$levelPrefix 문법';
      } else if (partOfSpeech == '한자') {
        targetLevel = '$levelPrefix 한자';
      }

      final word = item['word'] ?? '';
      final key = '$targetLevel::$word';
      if (!seen.contains(key) && word.isNotEmpty) {
        seen.add(key);
        combined.add({
          'id': 'temp', // 아래에서 일괄 재부여
          'level': targetLevel,
          'word': word,
          'furigana': item['furigana'] ?? word,
          'meaning': item['meaning'] ?? '',
          'partOfSpeech': partOfSpeech,
        });
      }
    }
  }

  addLevelData('N5', n5Data);
  addLevelData('N4', n4Data);
  addLevelData('N3', n3Data);
  addLevelData('N2', n2Data);
  addLevelData('N1', n1Data);

  // Extra 데이터 주입
  extraDataByLevel.forEach((lvl, words) {
    addLevelData(lvl, words);
  });

  // 3. 레벨별로 정렬 및 일관된 ID 재부여
  // 레벨 순서: N5, N5 문법, N5 한자, N4, N4 문법, N4 한자, ...
  final levelOrder = [
    'N5', 'N5 문법', 'N5 한자',
    'N4', 'N4 문법', 'N4 한자',
    'N3', 'N3 문법', 'N3 한자',
    'N2', 'N2 문법', 'N2 한자',
    'N1', 'N1 문법', 'N1 한자',
  ];

  combined.sort((a, b) {
    final idxA = levelOrder.indexOf(a['level']);
    final idxB = levelOrder.indexOf(b['level']);
    if (idxA != idxB) return idxA.compareTo(idxB);
    return a['word'].compareTo(b['word']);
  });

  // ID 재부여
  final Map<String, int> counter = {};
  for (final item in combined) {
    final lvl = item['level'] as String;
    counter[lvl] = (counter[lvl] ?? 0) + 1;
    final num = counter[lvl]!;
    final numStr = num.toString().padLeft(3, '0');

    String prefix = 'w';
    if (lvl.contains('문법')) {
      prefix = 'g';
    } else if (lvl.contains('한자')) {
      prefix = 'k';
    }
    final lvlTag = lvl.split(' ')[0].toLowerCase(); // n5, n4, n3, n2, n1
    item['id'] = '${lvlTag}_${prefix}$numStr';
  }

  // 4. 저장
  const encoder = JsonEncoder.withIndent('  ');
  assetFile.writeAsStringSync(encoder.convert(combined));

  print('\n🎉 확장 완료!');
  print('총 데이터 개수: ${combined.length}개\n');
  print('=== 카테고리별 세부 통계 ===');
  for (final lvl in levelOrder) {
    print('- $lvl: ${counter[lvl] ?? 0}개');
  }
}
