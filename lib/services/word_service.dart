import 'ai_service.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_model.dart';
import 'locale_service.dart';
import 'review_service.dart';
import 'widget_service.dart';

class WordService {
  static List<WordModel> _allWords = [];
  static List<String> _customCategories = [];

  static const String _prefBookmarkKey = 'bookmarked_word_ids';
  static const String _prefWrongKey = 'wrong_word_ids';
  static const String _prefMasteredKey = 'mastered_word_ids';
  static const String _prefCustomWordsKey = 'user_custom_words';
  static const String _prefCustomCategoriesKey = 'user_custom_categories';
  static const String _prefSelectedCategoriesKey = 'selected_study_categories';
  static const String _prefCachedAiExamplesKey = 'cached_ai_examples';
  static const String _prefLastReviewedTimestampsKey = 'last_reviewed_timestamps';
  static const String _prefLastSessionWordIdsKey = 'last_session_word_ids';
  static Set<String> _selectedStudyCategories = {};
  static Set<String> _lastSessionWordIds = {};

  static Future<void> init() async {
    if (_allWords.isNotEmpty) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/korean_words.json',
      );
      final List<dynamic> list = jsonDecode(jsonString);
      _allWords = list.map((e) => WordModel.fromJson(e)).toList();

      final prefs = await SharedPreferences.getInstance();

      // 커스텀 카테고리 로드
      _customCategories = prefs.getStringList(_prefCustomCategoriesKey) ?? [];

      // 커스텀 단어 로드
      final customJson = prefs.getString(_prefCustomWordsKey);
      if (customJson != null) {
        final List<dynamic> customList = jsonDecode(customJson);
        final customWords = customList
            .map((e) => WordModel.fromJson(e))
            .toList();
        for (var cw in customWords) {
          final exists = _allWords.any(
            (w) => w.id == cw.id || (w.word == cw.word && w.level == cw.level),
          );
          if (!exists) {
            _allWords.add(cw);
          }
        }
      }

      final bookmarks = prefs.getStringList(_prefBookmarkKey) ?? [];
      final wrongs = prefs.getStringList(_prefWrongKey) ?? [];
      final mastered = prefs.getStringList(_prefMasteredKey) ?? [];
      _selectedStudyCategories =
          (prefs.getStringList(_prefSelectedCategoriesKey) ?? []).toSet();
      _lastSessionWordIds =
          (prefs.getStringList(_prefLastSessionWordIdsKey) ?? []).toSet();

      // 💡 마지막 학습 시각(타임스탬프) 복원 (오래된 오답/장기 복습 우선순위)
      final timestampsRaw = prefs.getString(_prefLastReviewedTimestampsKey);
      Map<String, dynamic> tsMap = {};
      if (timestampsRaw != null && timestampsRaw.isNotEmpty) {
        try {
          tsMap = jsonDecode(timestampsRaw);
        } catch (_) {}
      }

      for (var word in _allWords) {
        word.isBookmarked = bookmarks.contains(word.id);
        word.isWrong = wrongs.contains(word.id);
        word.isMastered = mastered.contains(word.id);
        if (tsMap.containsKey(word.id)) {
          word.lastReviewedAt = DateTime.tryParse(tsMap[word.id].toString());
        }
      }

      // 💡 로컬 영구 캐시된 AI 예문 복원 (유효성 검증 및 비정상 캐시 자동 청소)
      final cachedExamplesJson = prefs.getString(_prefCachedAiExamplesKey);
      if (cachedExamplesJson != null && cachedExamplesJson.isNotEmpty) {
        try {
          final Map<String, dynamic> cachedMap = jsonDecode(cachedExamplesJson);
          bool hasDirty = false;
          for (var word in _allWords) {
            if (cachedMap.containsKey(word.id)) {
              final item = cachedMap[word.id];
              if (item is Map) {
                final ko = item['ko']?.toString() ?? '';
                final ja = item['ja']?.toString() ?? '';
                final en = item['en']?.toString() ?? '';
                if (ko.isNotEmpty && AiService.isValidKoreanSentence(ko, en.isNotEmpty ? en : ja)) {
                  word.exampleKo = ko;
                  word.exampleJa = ja;
                  word.exampleEn = en;
                } else {
                  // 잘못 캐시된 과거 예문 즉시 자동 파기
                  cachedMap.remove(word.id);
                  hasDirty = true;
                }
              }
            }
          }
          if (hasDirty) {
            await prefs.setString(_prefCachedAiExamplesKey, jsonEncode(cachedMap));
          }
        } catch (_) {}
      }
    } catch (e) {
      _allWords = [];
    }
  }

  /// 백업 복원 등 외부 변경 후 SharedPreferences 데이터를 메모리로 다시 로드
  static Future<void> reloadFromPrefs() async {
    _allWords = [];
    _customCategories = [];
    _selectedStudyCategories = {};
    _lastSessionWordIds = {};
    await init();
    await WidgetService.updateWidget();
  }

  static Future<void> _saveLastSessionWordIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefLastSessionWordIdsKey, _lastSessionWordIds.toList());
    } catch (_) {}
  }

  /// 테스트 또는 수동 초기화용 세션 쿨다운 리셋
  static void clearSessionCooldown() {
    _lastSessionWordIds.clear();
  }

  static List<WordModel> getAllWords() => _allWords;

  // 💡 한국어 5대 코어 코스 및 20대 테마 덱 체계적 정렬
  static List<String> getAllCategories() {
    final standardOrder = [
      // 1. 한글 기초 & 생존 회화 코스
      '자음·모음 & 필수 첫걸음',
      '숫자·시간·날짜 & 생활 기초',
      '일상 필수 동사 & 형용사',
      '생존 생활 표현 & 여행 어휘',

      // 2. TOPIK I 초급 필수 어휘 코스
      '학교 생활 & 취미·여가',
      '쇼핑·시장 & 대중교통',
      '음식·식당 & 한국 음식',
      '날씨·계절 & 병원·약국',

      // 3. TOPIK II 중급 핵심 어휘 코스
      '감정·심리 & 성격·인간관계',
      '사회·문화 & 미디어·예술',
      '자연·환경 & 과학·기술',
      'TOPIK 필수 관용구 & 속담',

      // 4. K-드라마 & 실전 리얼 회화 코스
      '드라마 명대사 & 리얼 리액션',
      '신조어·줄임말 & 일상 구어체',
      'K-푸드 & 포장마차·한강 치맥',
      'K-POP·팬덤 & 엔터테인먼트',

      // 5. 비즈니스 & 시사 고급 한국어 코스
      '오피스 실무 & 비즈니스 이메일',
      '회의·미팅 & 협상·프레젠테이션',
      '경제·경영 & 금융·투자',
      '시사·정치 & 학술·고급 토론',
    ];
    final dynamicCategories = _allWords.map((w) => w.level).toSet().toList();

    final List<String> result = [];
    for (var s in standardOrder) {
      if (dynamicCategories.contains(s) || _customCategories.contains(s)) {
        result.add(s);
      }
    }
    for (var c in dynamicCategories) {
      if (!result.contains(c)) result.add(c);
    }
    for (var custom in _customCategories) {
      if (!result.contains(custom)) result.add(custom);
    }

    if (!result.contains('기타')) result.add('기타');
    return result.isEmpty ? ['자음·모음 & 필수 첫걸음'] : result;
  }

  /// 카테고리/급수명을 현재 언어에 맞춰 번역하여 반환합니다.
  static String getLocalizedCategory(String category, [String? langCode]) {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    if (code == 'en') {
      switch (category) {
        case '전체':
          return 'All Categories';

        // 5대 대분류 코스
        case '한글 기초 & 생존 회화':
          return 'Hangul & Survival Basics';
        case 'TOPIK I 초급 필수 어휘':
          return 'TOPIK I Elementary';
        case 'TOPIK II 중급 핵심 어휘':
          return 'TOPIK II Intermediate';
        case 'K-드라마 & 실전 리얼 회화':
          return 'K-Drama & Real-Life Phrases';
        case '비즈니스 & 시사 고급 한국어':
          return 'Business & Advanced Korean';

        // 20대 서브 테마 덱
        case '자음·모음 & 필수 첫걸음':
          return 'Hangul Alphabet & First Steps';
        case '숫자·시간·날짜 & 생활 기초':
          return 'Numbers, Time & Daily Basics';
        case '일상 필수 동사 & 형용사':
          return 'Core Verbs & Adjectives';
        case '생존 생활 표현 & 여행 어휘':
          return 'Survival Phrases & Travel';

        case '학교 생활 & 취미·여가':
          return 'Campus Life & Hobbies';
        case '쇼핑·시장 & 대중교통':
          return 'Shopping & Public Transit';
        case '음식·식당 & 한국 음식':
          return 'Dining & Korean Food';
        case '날씨·계절 & 병원·약국':
          return 'Weather, Health & Clinic';

        case '감정·심리 & 성격·인간관계':
          return 'Emotions, Traits & Relations';
        case '사회·문화 & 미디어·예술':
          return 'Society, Culture & Media';
        case '자연·환경 & 과학·기술':
          return 'Nature, Environment & Tech';
        case 'TOPIK 필수 관용구 & 속담':
          return 'Idioms & Proverbs';

        case '드라마 명대사 & 리얼 리액션':
          return 'K-Drama Lines & Reactions';
        case '신조어·줄임말 & 일상 구어체':
          return 'Slang, Abbreviations & Colloquial';
        case 'K-푸드 & 포장마차·한강 치맥':
          return 'K-Food & Hangang Life';
        case 'K-POP·팬덤 & 엔터테인먼트':
          return 'K-Pop & Entertainment';

        case '오피스 실무 & 비즈니스 이메일':
          return 'Office Work & Business Emails';
        case '회의·미팅 & 협상·프레젠테이션':
          return 'Meetings & Negotiations';
        case '경제·경영 & 금융·투자':
          return 'Economy & Finance';
        case '시사·정치 & 학술·고급 토론':
          return 'Current Events & Politics';

        case '기타':
          return 'Other';
        case '나만의 단어장':
          return 'My Deck';
        default:
          return category;
      }
    } else if (code == 'ja') {
      switch (category) {
        case '전체':
          return '全カテゴリ';

        // 5대 대분류 코스
        case '한글 기초 & 생존 회화':
          return 'ハングル基礎・必須表現';
        case 'TOPIK I 초급 필수 어휘':
          return 'TOPIK I 初級必須単語';
        case 'TOPIK II 중급 핵심 어휘':
          return 'TOPIK II 中級頻出単語';
        case 'K-드라마 & 실전 리얼 회화':
          return 'K-POP・K-ドラマ 日常会話';
        case '비즈니스 & 시사 고급 한국어':
          return 'ビジネス・時事上級韓国語';

        // 20대 서브 테마 덱
        case '자음·모음 & 필수 첫걸음':
          return 'ハングル文字・基本の第一歩';
        case '숫자·시간·날짜 & 생활 기초':
          return '数字・時間・日付・生活基礎';
        case '일상 필수 동사 & 형용사':
          return '日常必須 動詞・形容詞';
        case '생존 생활 표현 & 여행 어휘':
          return 'サバイバル日常表現・旅行単語';

        case '학교 생활 & 취미·여가':
          return '学校生活・趣味・余暇';
        case '쇼핑·시장 & 대중교통':
          return 'ショッピング・市場・交通';
        case '음식·식당 & 한국 음식':
          return '食事・レストラン・韓国料理';
        case '날씨·계절 & 병원·약국':
          return '天気・季節・病院・薬局';

        case '감정·심리 & 성격·인간관계':
          return '感情・心理・性格・人間関係';
        case '사회·문화 & 미디어·예술':
          return '社会・文化・メディア・芸術';
        case '자연·환경 & 과학·기술':
          return '自然・環境・科学・IT技術';
        case 'TOPIK 필수 관용구 & 속담':
          return 'TOPIK必須 慣用句・ことわざ';

        case '드라마 명대사 & 리얼 리액션':
          return 'ドラマ名セリフ・リアルリアクション';
        case '신조어·줄임말 & 일상 구어체':
          return '新造語・若者言葉・日常口語';
        case 'K-푸드 & 포장마차·한강 치맥':
          return 'K-FOOD・屋台・漢江チメク';
        case 'K-POP·팬덤 & 엔터테인먼트':
          return 'K-POP・ファン・エンタメ';

        case '오피스 실무 & 비즈니스 이메일':
          return 'オフィス実務・ビジネスメール';
        case '회의·미팅 & 협상·프레젠테이션':
          return '会議・交渉・プレゼンテーション';
        case '경제·경영 & 금융·투자':
          return '経済・経営・金融・投資';
        case '시사·정치 & 학술·고급 토론':
          return '時事・政治・学術・討論';

        case '기타':
          return 'その他';
        case '나만의 단어장':
          return 'マイ単語帳';
        default:
          return category;
      }
    }
    return category;
  }

  // 💡 랜덤 학습 출제 범위(카테고리 필터) 조회 및 저장
  static Set<String> getSelectedStudyCategories() {
    if (_selectedStudyCategories.isEmpty) {
      return getAllCategories().toSet();
    }
    return Set.from(_selectedStudyCategories);
  }

  static Future<void> setSelectedStudyCategories(Set<String> categories) async {
    _selectedStudyCategories = Set.from(categories);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefSelectedCategoriesKey,
      _selectedStudyCategories.toList(),
    );
  }

  static Future<void> toggleCategorySelection(String category) async {
    final current = getSelectedStudyCategories();
    if (current.contains(category)) {
      if (current.length > 1) {
        current.remove(category);
      }
    } else {
      current.add(category);
    }
    await setSelectedStudyCategories(current);
  }

  // 🔍 실시간 단어 검색 (한자, 후리가나, 뜻 동시 매칭 + 급수 필터)
  static List<WordModel> searchWords({required String query, String? level}) {
    final cleanQuery = query.trim().toLowerCase();

    return _allWords.where((w) {
      if (level != null && level != '전체' && w.level != level) {
        return false;
      }
      if (cleanQuery.isEmpty) return true;

      final matchWord = w.word.toLowerCase().contains(cleanQuery);
      final matchFuri = w.furigana.toLowerCase().contains(cleanQuery);
      final matchMeaning = w.meaning.toLowerCase().contains(cleanQuery) ||
          (w.meaningEn?.toLowerCase().contains(cleanQuery) ?? false);

      return matchWord || matchFuri || matchMeaning;
    }).toList();
  }

  // ➕ 새 카테고리 영구 등록
  static Future<void> addCategory(String categoryName) async {
    final clean = categoryName.trim();
    if (clean.isEmpty || _customCategories.contains(clean)) return;

    _customCategories.add(clean);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefCustomCategoriesKey, _customCategories);
  }

  static List<WordModel> getWordsByLevel(String level) {
    return _allWords.where((w) => w.level == level || w.category == level).toList();
  }

  static List<WordModel> getTodayStudyWords({
    String category = '전체',
    int limit = 10,
  }) {
    if (_allWords.isEmpty) return [];
    List<WordModel> pool;
    if (category == '전체') {
      final selected = getSelectedStudyCategories();
      pool = _allWords.where((w) => selected.contains(w.level)).toList();
      if (pool.isEmpty) pool = List.from(_allWords);
    } else {
      pool = _allWords.where((w) => w.level == category).toList();
    }
    if (pool.isEmpty) pool = List.from(_allWords);

    // 💡 [에빙하우스 망각곡선 황금 슬롯 & 쿨다운 순환 알고리즘]
    // 1. 새 단어 풀 (미학습 카드)
    final unlearnedList = pool
        .where((w) => !w.isWrong && !w.isMastered)
        .toList()
      ..shuffle();

    // 2. 오답 복습 풀 (마지막 학습 시각 기준 오래전에 본 순서로 정렬)
    final allWrong = pool.where((w) => w.isWrong).toList();
    allWrong.sort((a, b) {
      if (a.lastReviewedAt == null && b.lastReviewedAt == null) return 0;
      if (a.lastReviewedAt == null) return -1; // 복습 이력 없는 단어 최우선
      if (b.lastReviewedAt == null) return 1;
      return a.lastReviewedAt!.compareTo(b.lastReviewedAt!);
    });

    // 직전 세션에서 방금 본 단어는 최소 1세션 쿨다운(휴식) 적용
    final wrongListAvailable = allWrong
        .where((w) => !_lastSessionWordIds.contains(w.id))
        .toList();

    // 3. 장기 기억 점검 풀 (암기 완료 단어 중 가장 오래전에 외운 순서로 정렬)
    final allMastered = pool.where((w) => w.isMastered).toList();
    allMastered.sort((a, b) {
      if (a.lastReviewedAt == null && b.lastReviewedAt == null) return 0;
      if (a.lastReviewedAt == null) return -1;
      if (b.lastReviewedAt == null) return 1;
      return a.lastReviewedAt!.compareTo(b.lastReviewedAt!);
    });
    final masteredAvailable = allMastered
        .where((w) => !_lastSessionWordIds.contains(w.id))
        .toList();

    // 🎯 슬롯 목표치 설정 (10단어 기준: 새 단어 6장, 오답 복습 3장, 장기 점검 1장)
    int targetNew = (limit * 0.6).round();
    int targetWrong = (limit * 0.3).round();
    int targetMastered = limit - targetNew - targetWrong;

    final List<WordModel> result = [];

    // 1차: 각 슬롯별 우선 배분 (쿨다운 적용된 가용 풀 우선)
    final pickedNew = unlearnedList.take(targetNew).toList();
    result.addAll(pickedNew);

    final wrongPool = wrongListAvailable.isNotEmpty
        ? wrongListAvailable
        : (unlearnedList.isEmpty ? allWrong : <WordModel>[]);
    final pickedWrong = wrongPool.take(targetWrong).toList();
    result.addAll(pickedWrong);

    final masteredPool = masteredAvailable.isNotEmpty
        ? masteredAvailable
        : (unlearnedList.isEmpty && wrongPool.isEmpty ? allMastered : <WordModel>[]);
    final pickedMastered = masteredPool.take(targetMastered).toList();
    result.addAll(pickedMastered);

    // 2차: 부족한 슬롯 자동 보충 (우선순위: 새 단어 -> 가용 오답 -> 가용 마스터 -> 전체 오답 -> 전체 마스터)
    void fillRemaining(List<WordModel> candidates) {
      if (result.length >= limit) return;
      final existingIds = result.map((w) => w.id).toSet();
      for (var w in candidates) {
        if (!existingIds.contains(w.id)) {
          result.add(w);
          existingIds.add(w.id);
          if (result.length >= limit) break;
        }
      }
    }

    fillRemaining(unlearnedList);
    fillRemaining(wrongListAvailable);
    fillRemaining(masteredAvailable);
    fillRemaining(allWrong);
    fillRemaining(allMastered);

    // 직전 세션 출제 단어 갱신 및 SharedPreferences 저장 (세션 쿨다운 유지)
    _lastSessionWordIds = result.map((w) => w.id).toSet();
    _saveLastSessionWordIds();

    // 최종 출제 10장을 골고루 섞어 새단어/오답/점검 카드가 자연스럽게 교차되도록 함
    result.shuffle();
    return result;
  }

  static Future<void> addCustomWord(WordModel newWord) async {
    // 중복 검사: 동일 단어가 있으면 교체 또는 무시
    final existingIdx = _allWords.indexWhere(
      (w) => w.word == newWord.word && w.level == newWord.level,
    );
    if (existingIdx >= 0) {
      _allWords[existingIdx] = newWord;
    } else {
      _allWords.add(newWord);
    }
    final prefs = await SharedPreferences.getInstance();

    final customJson = prefs.getString(_prefCustomWordsKey);
    List<dynamic> customList = customJson != null ? jsonDecode(customJson) : [];
    customList.removeWhere((item) => item['word'] == newWord.word && item['level'] == newWord.level);
    customList.add(newWord.toJson());

    await prefs.setString(_prefCustomWordsKey, jsonEncode(customList));

    // 신규 카테고리 자동 등록
    if (!_customCategories.contains(newWord.level)) {
      await addCategory(newWord.level);
    }
  }

  static Future<int> importWordsFromRawText(
    String rawText, {
    String level = '기타',
  }) async {
    final lines = rawText.split('\n');
    int addedCount = 0;
    final List<WordModel> newWords = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      List<String> parts = [];
      if (trimmed.contains('\t')) {
        parts = trimmed.split('\t');
      } else if (trimmed.contains(',')) {
        parts = trimmed.split(',');
      }

      if (parts.length >= 2) {
        final word = parts[0].trim();
        String furigana = word;
        String meaning = '';
        String? meaningEn;

        if (parts.length == 2) {
          meaning = parts[1].trim();
        } else if (parts.length == 3) {
          furigana = parts[1].trim().isEmpty ? word : parts[1].trim();
          meaning = parts[2].trim();
        } else {
          // 💡 4개 이상 컬럼: [단어, 후리가나, 한국어 뜻, 영어 뜻]
          furigana = parts[1].trim().isEmpty ? word : parts[1].trim();
          meaning = parts[2].trim();
          final en = parts[3].trim();
          if (en.isNotEmpty) meaningEn = en;
        }

        if (word.isNotEmpty && meaning.isNotEmpty) {
          // 💡 중복 검사: 이미 동일 급수에 동일 단어가 있으면 건너뛰기(Skip)
          final isDuplicate = _allWords.any(
                (w) => w.word == word && w.level == level,
              ) ||
              newWords.any((w) => w.word == word && w.level == level);

          if (isDuplicate) continue;

          final newWord = WordModel(
            id: 'import_${DateTime.now().millisecondsSinceEpoch}_$addedCount',
            level: level,
            word: word,
            furigana: furigana,
            meaning: meaning,
            meaningEn: meaningEn,
          );
          newWords.add(newWord);
          addedCount++;
        }
      }
    }

    if (newWords.isNotEmpty) {
      _allWords.addAll(newWords);
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getString(_prefCustomWordsKey);
      List<dynamic> customList = customJson != null
          ? jsonDecode(customJson)
          : [];
      for (var w in newWords) {
        customList.add(w.toJson());
      }
      await prefs.setString(_prefCustomWordsKey, jsonEncode(customList));

      if (!_customCategories.contains(level)) {
        await addCategory(level);
      }
    }

    return addedCount;
  }

  static Future<void> toggleBookmark(WordModel word) async {
    word.isBookmarked = !word.isBookmarked;
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_prefBookmarkKey) ?? [];
    if (word.isBookmarked) {
      if (!bookmarks.contains(word.id)) bookmarks.add(word.id);
    } else {
      bookmarks.remove(word.id);
    }
    await prefs.setStringList(_prefBookmarkKey, bookmarks);
  }

  static Future<void> recordStudyResult(WordModel word, bool remembered) async {
    word.isWrong = !remembered;
    word.isMastered = remembered;
    word.lastReviewedAt = DateTime.now();

    final prefs = await SharedPreferences.getInstance();

    // 0. 마지막 학습 시각(타임스탬프) 영구 보관 (쿨다운 및 오래된 오답 우선순위용)
    try {
      final tsRaw = prefs.getString(_prefLastReviewedTimestampsKey);
      Map<String, dynamic> tsMap = {};
      if (tsRaw != null && tsRaw.isNotEmpty) {
        tsMap = jsonDecode(tsRaw);
      }
      tsMap[word.id] = word.lastReviewedAt!.toIso8601String();
      await prefs.setString(_prefLastReviewedTimestampsKey, jsonEncode(tsMap));
    } catch (_) {}

    // 1. 오답노트 갱신
    final wrongs = prefs.getStringList(_prefWrongKey) ?? [];
    if (!remembered) {
      if (!wrongs.contains(word.id)) wrongs.add(word.id);
    } else {
      wrongs.remove(word.id);
    }
    await prefs.setStringList(_prefWrongKey, wrongs);

    // 2. 암기 완료(알아요) 목록 갱신
    final mastered = prefs.getStringList(_prefMasteredKey) ?? [];
    if (remembered) {
      if (!mastered.contains(word.id)) mastered.add(word.id);
    } else {
      mastered.remove(word.id);
    }
    await prefs.setStringList(_prefMasteredKey, mastered);
    WidgetService.updateWidget();

    // 💡 누적 마스터 단어 수가 30개 이상 도달 시 최초 1회 인앱 리뷰 팝업 요청
    if (remembered) {
      ReviewService.checkAndRequestReview(
        currentCount: mastered.length,
        targetThreshold: 30,
      );
    }
  }

  static Future<void> markWrong(WordModel word, bool isWrong) async {
    await recordStudyResult(word, !isWrong);
  }

  static List<WordModel> getBookmarkedWords() {
    return _allWords.where((w) => w.isBookmarked).toList();
  }

  static List<WordModel> getWrongWords() {
    return _allWords.where((w) => w.isWrong).toList();
  }

  static List<WordModel> getMasteredWordsByLevel(String level) {
    return _allWords.where((w) => (w.level == level || w.category == level) && w.isMastered).toList();
  }

  static List<WordModel> getAllMasteredWords() {
    return _allWords.where((w) => w.isMastered).toList();
  }

  /// 💡 AI 생성 예문 로컬 영구 캐싱 (동일 단어 재학습 시 API 호출 및 에너지 낭비 방지)
  static Future<void> cacheAiExample(
    String wordId,
    String ko,
    String translation, {
    String? langCode,
    String? jaTranslation,
  }) async {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    // 1. 메모리 상의 단어 모델 즉시 갱신
    for (var word in _allWords) {
      if (word.id == wordId) {
        word.exampleKo = ko;
        if (code == 'ja') {
          word.exampleJa = translation;
        } else if (code == 'en') {
          word.exampleEn = translation;
        }
        if (jaTranslation != null && jaTranslation.isNotEmpty) {
          word.exampleJa = jaTranslation;
        }
        break;
      }
    }

    // 2. SharedPreferences 영구 저장
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_prefCachedAiExamplesKey);
      Map<String, dynamic> cachedMap = {};
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          cachedMap = jsonDecode(cachedJson);
        } catch (_) {}
      }
      final existing = (cachedMap[wordId] is Map)
          ? Map<String, dynamic>.from(cachedMap[wordId])
          : <String, dynamic>{};
      existing['ko'] = ko;
      if (code == 'ja') {
        existing['ja'] = translation;
      } else {
        existing['en'] = translation;
      }
      if (jaTranslation != null && jaTranslation.isNotEmpty) {
        existing['ja'] = jaTranslation;
      }
      cachedMap[wordId] = existing;
      await prefs.setString(_prefCachedAiExamplesKey, jsonEncode(cachedMap));
    } catch (e) {
      // SharedPreferences 저장 실패 시에도 메모리 상의 갱신은 유지
    }
  }
}
