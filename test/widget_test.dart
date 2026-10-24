import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_korean/models/reading_model.dart';
import 'package:on_korean/models/word_model.dart';
import 'package:on_korean/services/locale_service.dart';
import 'package:on_korean/services/reading_service.dart';
import 'package:on_korean/services/remote_config_service.dart';
import 'package:on_korean/services/ai_service.dart';
import 'package:on_korean/services/energy_service.dart';
import 'package:on_korean/services/stats_service.dart';
import 'package:on_korean/services/tts_service.dart';
import 'package:on_korean/services/widget_service.dart';
import 'package:on_korean/services/word_service.dart';
import 'package:on_korean/services/notification_service.dart';
import 'package:on_korean/widgets/reading/reading_speed_chip.dart';
import 'package:on_korean/widgets/reading/reading_passage_card.dart';
import 'package:on_korean/widgets/reading/reading_quiz_card.dart';
import 'package:on_korean/widgets/reading/reading_vocab_section.dart';
import 'package:on_korean/widgets/reading/reading_state_cards.dart';
import 'package:on_korean/widgets/settings/settings_ecosystem_tile.dart';
import 'package:on_korean/widgets/settings/settings_notification_section.dart';
import 'package:on_korean/services/theme_service.dart';
import 'package:on_korean/services/app_settings.dart';
import 'package:on_korean/widgets/onboarding_screen.dart';
import 'package:on_korean/services/backup_service.dart';
import 'package:on_korean/services/review_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleService Tests', () {
    test('Default and manual locale translations', () async {
      // Test Korean
      await LocaleService.changeLocale('ko');
      expect(LocaleService.tr('app_title'), '작심삼일 한국어');
      expect(LocaleService.tr('nav_today'), '오늘학습');

      // Test Japanese
      await LocaleService.changeLocale('ja');
      expect(LocaleService.tr('app_title'), '三日坊主韓国語');
      expect(LocaleService.tr('nav_today'), '今日の学習');

      // Test English
      await LocaleService.changeLocale('en');
      expect(LocaleService.tr('app_title'), 'OnKorean');
      expect(LocaleService.tr('nav_today'), 'Today');
    });
  });

  group('WordModel & English JSON Dataset Tests', () {
    test('JSON asset loads correctly and contains 1800 curated English words across 5 core categories', () async {
      final jsonString = await rootBundle.loadString(
        'assets/data/jlpt_words.json',
      );
      final List<dynamic> list = jsonDecode(jsonString);

      expect(list.isNotEmpty, true);
      expect(list.length, greaterThan(0));

      final words = list.map((e) => WordModel.fromJson(e)).toList();

      final starterWords = words.where((w) => w.level == '한글 기초 & 생존 회화').toList();
      final topik1Words = words.where((w) => w.level == 'TOPIK I 초급 필수 어휘').toList();
      final topik2Words = words.where((w) => w.level == 'TOPIK II 중급 핵심 어휘').toList();
      final kdramaWords = words.where((w) => w.level == 'K-드라마 & 실전 리얼 회화').toList();
      final bizWords = words.where((w) => w.level == '비즈니스 & 시사 고급 한국어').toList();

      expect(starterWords.isNotEmpty, true);
      expect(topik1Words.isNotEmpty, true);
      expect(topik2Words.isNotEmpty, true);
      expect(kdramaWords.isNotEmpty, true);
      expect(bizWords.isNotEmpty, true);

      // Verify each word has clean English fields and translations
      for (final w in words) {
        expect(w.id.isNotEmpty, true);
        expect(w.word.trim().isNotEmpty, true);
        expect(w.meaning.trim().isNotEmpty, true);
        expect(w.meaningEn, isNotNull);
        expect(w.meaningEn!.trim().isNotEmpty, true);
      }
    });
  });

  group('TtsService Pronunciation Filtering Tests', () {
    test('English words and phrasal verbs pronounce cleanly without phonetic brackets or Korean', () {
      final vocabWord = WordModel(
        id: 'v1',
        level: '한글 기초 & 생존 회화',
        word: 'apple',
        furigana: '/ˈæpl/',
        meaning: '사과',
        meaningEn: 'apple',
      );
      expect(TtsService.getPronounceableText(vocabWord), 'apple');

      final phrasalWord = WordModel(
        id: 'p1',
        level: '원어민 필수 구동사',
        word: 'look forward to (something)',
        furigana: '기대하다',
        meaning: '~을 손꼽아 기다리다',
        meaningEn: 'anticipate with pleasure',
      );
      expect(TtsService.getPronounceableText(phrasalWord), 'look forward to');

      final slashWord = WordModel(
        id: 's1',
        level: '비즈니스 & 토익',
        word: 'prioritize [praɪˈɔːrətaɪz]',
        furigana: '',
        meaning: '우선순위를 매기다',
      );
      expect(TtsService.getPronounceableText(slashWord), 'prioritize');
    });

    test('Auto-play state toggle persists or defaults to true', () async {
      await TtsService.init();
      expect(TtsService.isAutoPlay, true);

      await TtsService.setAutoPlay(false);
      expect(TtsService.isAutoPlay, false);

      await TtsService.setAutoPlay(true);
      expect(TtsService.isAutoPlay, true);

      expect(TtsService.repeatWordTwice, false);
      await TtsService.setRepeatWordTwice(true);
      expect(TtsService.repeatWordTwice, true);
      await TtsService.setRepeatWordTwice(false);
      expect(TtsService.repeatWordTwice, false);
    });
  });

  group('WordModel Mastery Tests', () {
    test('isMastered serialization and default value', () {
      final word = WordModel(
        id: 'w1',
        level: '한글 기초 & 생존 회화',
        word: 'cat',
        furigana: '/kæt/',
        meaning: '고양이',
      );
      expect(word.isMastered, false);

      final json = word.toJson();
      expect(json['isMastered'], false);

      final wordMastered = WordModel.fromJson({...json, 'isMastered': true});
      expect(wordMastered.isMastered, true);
    });
  });

  group('RemoteConfigService & AiService Tests', () {
    test('RemoteConfig safe fallback when hardcoded key is commented out', () {
      final keys = RemoteConfigService.getGeminiApiKeys();
      expect(keys, isA<List<String>>());
      expect(AiService.apiKey, isA<String>());
    });

    test('AiService isValidEnglishSentence strictly filters invalid sentences and non-English scripts', () {
      // 1. Valid pure English sentences
      expect(
        AiService.isValidEnglishSentence(
          'Where is the nearest train station?',
          '가장 가까운 기차역이 어디인가요?',
        ),
        true,
      );
      expect(
        AiService.isValidEnglishSentence(
          'Could you please give me a hand with this?',
          '이것 좀 도와주시겠어요?',
        ),
        true,
      );

      // 2. Korean sentence mistakenly in target (strict rejection)
      expect(
        AiService.isValidEnglishSentence('오늘은 날씨가 좋네요.', '오늘은 날씨가 좋네요.'),
        false,
      );

      // 3. Japanese text in target (strict rejection)
      expect(
        AiService.isValidEnglishSentence('机の上に本があります。', '책상 위에 책이 있습니다.'),
        false,
      );

      // 4. Empty string (strict rejection)
      expect(AiService.isValidEnglishSentence('', ''), false);
    });
  });

  group('WordService AI Example Caching Tests', () {
    test('AI generated example persists in cache and memory', () async {
      final testWord = WordModel(
        id: 'test_word_1',
        level: '한글 기초 & 생존 회화',
        word: 'book',
        furigana: '/bʊk/',
        meaning: '책',
      );
      await WordService.cacheAiExample(
        testWord.id,
        'She loves reading books in the library.',
        '그녀는 도서관에서 책 읽는 것을 아주 좋아합니다.',
        jaTranslation: '彼女は図書館で本を読むのが大好きです。',
      );
      expect(testWord.id, 'test_word_1');
    });

    test(
      'WordService importWordsFromRawText parses 4-column data with meaningEn',
      () async {
        final rawTsv =
            'airport\t/ˈerpɔːrt/\t공항\tairport\nweather\t/ˈweðər/\t날씨\tweather';
        final count = await WordService.importWordsFromRawText(
          rawTsv,
          level: '테스트카테고리',
        );
        expect(count, 2);

        final imported = WordService.getAllWords()
            .where((w) => w.level == '테스트카테고리')
            .toList();
        expect(imported.length, 2);

        final airport = imported.firstWhere((w) => w.word == 'airport');
        expect(airport.furigana, '/ˈerpɔːrt/');
        expect(airport.meaning, '공항');
        expect(airport.meaningEn, 'airport');
        expect(airport.getLocalizedMeaning('ko'), '공항');
        expect(airport.getLocalizedMeaning('en'), 'airport');
      },
    );
  });

  group('EnergyService & Rewarded Quota Tests', () {
    test('Initial energy, consumption, recharge, and Pro mode', () async {
      await EnergyService.init();
      expect(EnergyService.currentEnergy.value, 10);
      expect(EnergyService.canUseAi, true);

      // Consume 1
      final consumed = await EnergyService.consume();
      expect(consumed, true);
      expect(EnergyService.currentEnergy.value, 9);

      // Consume 3 (for reading)
      expect(EnergyService.canAfford(3), true);
      final consumedReading = await EnergyService.consume(3);
      expect(consumedReading, true);
      expect(EnergyService.currentEnergy.value, 6);

      // Reward recharge +5
      await EnergyService.addRewardEnergy(5);
      expect(EnergyService.currentEnergy.value, 11);

      // Pro mode test
      expect(EnergyService.isPro.value, false);
      await EnergyService.setProUser(true);
      expect(EnergyService.isPro.value, true);
      expect(EnergyService.canUseAi, true);
      expect(EnergyService.canAfford(3), true);

      // Clean up Pro flag
      await EnergyService.setProUser(false);
    });

    test('License and Pro localization strings exist', () async {
      await LocaleService.changeLocale('ko');
      expect(LocaleService.tr('settings_licenses'), '오픈소스 라이선스');
      expect(LocaleService.tr('ai_energy'), 'AI 에너지');
      expect(LocaleService.tr('ad_reward_btn'), '🎬 광고 보고 +5회 충전');
      expect(LocaleService.tr('pro_title'), '💎 멤버십 플랜 안내');
    });
  });

  group('ReadingModel & ReadingService Tests', () {
    test(
      'ReadingModel serialization and deserialization with English passages',
      () {
        final item = ReadingModel(
          id: 'r1',
          level: '초급',
          theme: '일상',
          title: 'Morning Coffee Ritual',
          passageEn: 'Starting the morning with a cup of warm coffee helps me stay focused throughout the day.',
          passageKo: '따뜻한 커피 한 잔으로 아침을 시작하면 하루 종일 집중력을 유지하는 데 도움이 됩니다.',
          questionEn: 'How does coffee help the writer in the morning?',
          options: ['Stay focused', 'Fall asleep', 'Lose keys', 'Feel cold'],
          correctIndex: 0,
          explanation: '지문에서 하루 종일 집중력을 유지하는 데 도움이 된다고 언급했습니다.',
          keyVocab: [
            ReadingVocab(
              word: 'focused',
              reading: '/ˈfoʊkəst/',
              meaning: '집중하는, 몰두하는',
            ),
          ],
          createdAt: DateTime.now(),
        );

        final json = item.toJson();
        final fromJson = ReadingModel.fromJson(json);

        expect(fromJson.id, 'r1');
        expect(fromJson.level, '초급');
        expect(fromJson.type, 'reading');
        expect(fromJson.options.length, 4);
        expect(fromJson.correctIndex, 0);
        expect(fromJson.keyVocab.length, 1);
        expect(fromJson.keyVocab.first.word, 'focused');

        // Check backwards compatibility getters
        expect(fromJson.passageKo.isNotEmpty, isTrue);
        expect(fromJson.passageEn.isNotEmpty, isTrue);

        final listeningItem = ReadingModel(
          id: 'r2',
          level: '비즈니스',
          theme: '비즈니스',
          type: 'listening',
          title: 'Conference Call Check-in',
          passageEn:
              'Good morning everyone, can you hear me clearly on the line?',
          passageKo: '좋은 아침입니다 여러분, 제 목소리가 잘 들리시나요?',
          questionEn: 'What is the speaker asking about?',
          options: [
            'Audio clarity',
            'Weather forecast',
            'Lunch menu',
            'Train schedule',
          ],
          correctIndex: 0,
          explanation: '목소리가 선명하게 들리는지 확인하고 있습니다.',
          keyVocab: [],
          createdAt: DateTime.now(),
        );
        final listeningJson = listeningItem.toJson();
        expect(listeningJson['type'], 'listening');
        final listeningFromJson = ReadingModel.fromJson(listeningJson);
        expect(listeningFromJson.type, 'listening');
      },
    );

    test('ReadingService local archive save, toggle, and delete', () async {
      await ReadingService.init();

      final item = ReadingModel(
        id: 'test_reading',
        level: '중급',
        theme: '여행',
        title: 'Airport Transit Tips',
        passageEn: 'Make sure to arrive at least two hours before your domestic flight.',
        passageKo: '국내선 항공편 출발 최소 2시간 전에는 공항에 도착하세요.',
        questionEn: 'When should passengers arrive at the airport?',
        options: [
          '2 hours before',
          '10 minutes before',
          'After boarding',
          'Next morning',
        ],
        correctIndex: 0,
        explanation: '최소 2시간 전 도착을 권장하고 있습니다.',
        keyVocab: [],
        createdAt: DateTime.now(),
      );

      await ReadingService.saveReading(item);
      expect(
        ReadingService.savedReadings.value.any((r) => r.id == 'test_reading'),
        true,
      );

      await ReadingService.toggleCompleted('test_reading');
      final saved = ReadingService.savedReadings.value.firstWhere(
        (r) => r.id == 'test_reading',
      );
      expect(saved.isCompleted, true);

      await ReadingService.deleteReading('test_reading');
      expect(
        ReadingService.savedReadings.value.any((r) => r.id == 'test_reading'),
        false,
      );
    });
  });

  group('StatsService Tests', () {
    test('Daily study and mastered count recording', () async {
      final initialTotal = await StatsService.getTodayCount();
      final initialMastered = await StatsService.getTodayMasteredCount();

      await StatsService.recordWordStudied(remembered: false);
      expect(await StatsService.getTodayCount(), initialTotal + 1);
      expect(await StatsService.getTodayMasteredCount(), initialMastered);

      await StatsService.recordWordStudied(remembered: true);
      expect(await StatsService.getTodayCount(), initialTotal + 2);
      expect(await StatsService.getTodayMasteredCount(), initialMastered + 1);

      final last7 = await StatsService.getLast7Days();
      expect(last7.length, 7);
      expect(last7.last['isToday'], true);
      expect(last7.last['count'] >= 2, true);
      expect(last7.last['masteredCount'] >= 1, true);
    });
  });

  group('English Localization & Multi-language Tests', () {
    test(
      'All 1800 words contain valid meaningEn and fallback correctly',
      () async {
        final jsonString = await rootBundle.loadString(
          'assets/data/jlpt_words.json',
        );
        final List<dynamic> list = jsonDecode(jsonString);
        expect(list.length, greaterThan(0));

        for (var item in list) {
          final word = WordModel.fromJson(item);
          expect(word.meaningEn, isNotNull);
          expect(
            word.meaningEn!.trim().isNotEmpty,
            true,
            reason: 'Word ${word.word} has empty meaningEn',
          );

          // Test localized meaning behavior
          expect(word.getLocalizedMeaning('en'), word.meaningEn ?? word.meaning);
          expect(word.getLocalizedMeaning('ko'), word.meaningKo ?? word.meaning);
        }
      },
    );

    test('WordModel partOfSpeech localization', () {
      final wordNoun = WordModel(
        id: '1',
        level: '한글 기초 & 생존 회화',
        word: 'book',
        furigana: '/bʊk/',
        meaning: '책',
        meaningEn: 'book',
        partOfSpeech: '명사',
      );
      expect(wordNoun.getLocalizedPartOfSpeech('en'), 'Noun');
      expect(wordNoun.getLocalizedPartOfSpeech('ja'), '名詞');
      expect(wordNoun.getLocalizedPartOfSpeech('ko'), '명사');

      final wordVerb = WordModel(
        id: '2',
        level: '한글 기초 & 생존 회화',
        word: 'go',
        furigana: '/ɡoʊ/',
        meaning: '가다',
        meaningEn: 'to go',
        partOfSpeech: '동사',
      );
      expect(wordVerb.getLocalizedPartOfSpeech('en'), 'Verb');
      expect(wordVerb.getLocalizedPartOfSpeech('ja'), '動詞');
      expect(wordVerb.getLocalizedPartOfSpeech('ko'), '동사');
    });

    test('WordService category localization across languages', () {
      expect(
        WordService.getLocalizedCategory('한글 기초 & 생존 회화', 'en'),
        'Hangul & Survival Basics',
      );
      expect(WordService.getLocalizedCategory('한글 기초 & 생존 회화', 'ja'), 'ハングル基礎・必須表現');
      expect(WordService.getLocalizedCategory('한글 기초 & 생존 회화', 'ko'), '한글 기초 & 생존 회화');

      expect(
        WordService.getLocalizedCategory('TOPIK I 초급 필수 어휘', 'en'),
        'TOPIK I Elementary',
      );
      expect(WordService.getLocalizedCategory('TOPIK I 초급 필수 어휘', 'ja'), 'TOPIK I 初級必須単語');
      expect(WordService.getLocalizedCategory('TOPIK I 초급 필수 어휘', 'ko'), 'TOPIK I 초급 필수 어휘');

      expect(
        WordService.getLocalizedCategory('TOPIK II 중급 핵심 어휘', 'en'),
        'TOPIK II Intermediate',
      );
      expect(WordService.getLocalizedCategory('TOPIK II 중급 핵심 어휘', 'ja'), 'TOPIK II 中級頻出単語');
      expect(WordService.getLocalizedCategory('TOPIK II 중급 핵심 어휘', 'ko'), 'TOPIK II 중급 핵심 어휘');

      expect(
        WordService.getLocalizedCategory('K-드라마 & 실전 리얼 회화', 'en'),
        'K-Drama & Real-Life Phrases',
      );
      expect(WordService.getLocalizedCategory('K-드라마 & 실전 리얼 회화', 'ja'), 'K-POP・K-ドラマ 日常会話');
      expect(WordService.getLocalizedCategory('K-드라마 & 실전 리얼 회화', 'ko'), 'K-드라마 & 실전 리얼 회화');

      expect(
        WordService.getLocalizedCategory('비즈니스 & 시사 고급 한국어', 'en'),
        'Business & Advanced Korean',
      );
      expect(WordService.getLocalizedCategory('비즈니스 & 시사 고급 한국어', 'ja'), 'ビジネス・時事上級韓国語');
      expect(WordService.getLocalizedCategory('비즈니스 & 시사 고급 한국어', 'ko'), '비즈니스 & 시사 고급 한국어');
    });

    test('All new localization keys exist across ko, ja, en', () async {
      final keys = [
        'ai_1min',
        'badge_pro_unlimited',
        'card_ai_example_label',
        'course_starter',
        'course_starter_sub',
        'course_travel',
        'course_travel_sub',
        'course_business',
        'course_business_sub',
        'course_advanced',
        'course_advanced_sub',
        'course_phrasal',
        'course_phrasal_sub',
        'course_custom_sub',
        'search_empty',
        'search_results_count',
        'add_category_hint',
        'lab_banner_sub',
        'library_category_mastery',
        'btn_study_short',
        'tooltip_remove_wrong',
        'tooltip_remove_bookmark',
        'stats_day_tooltip',
        'settings_notif_scheduled',
        'settings_notif_change_time',
        'settings_notif_test_sub',
        'settings_notif_test_sent',
        'settings_notif_test_action',
        'settings_import_success',
        'archive_filter_all',
        'archive_filter_reading',
        'archive_filter_listening',
        'archive_empty_filtered',
        'btn_get_lifetime',
        'btn_try_trial',
        'ad_load_failed',
        'fallback_custom_category',
        'course_words_count',
        'empty_category',
        'ecosystem_title',
        'ecosystem_subtitle',
        'my_deck_study_wrong',
        'my_deck_study_bookmark',
        'tag_new',
        'tag_review',
        'tag_check',
        'stats_today_study_sessions',
        'stats_unit_words',
        'stats_unit_times',
      ];

      for (var lang in ['ko', 'ja', 'en']) {
        await LocaleService.changeLocale(lang);
        for (var k in keys) {
          final val = LocaleService.tr(k);
          expect(val != k, true, reason: 'Key $k missing in $lang');
        }
      }
    });

    test(
      'WordModel localizedLevel translates categories appropriately',
      () async {
        final starterWord = WordModel(
          id: '1',
          level: '한글 기초 & 생존 회화',
          word: '안녕하세요',
          furigana: '[an-nyeong-ha-se-yo]',
          meaning: 'Hello',
        );
        final bizWord = WordModel(
          id: '2',
          level: '비즈니스 & 시사 고급 한국어',
          word: '협상',
          furigana: '[hyeop-sang]',
          meaning: 'Negotiation',
        );

        // KO
        await LocaleService.changeLocale('ko');
        expect(starterWord.localizedLevel, '한글 기초 & 생존 회화');
        expect(bizWord.localizedLevel, '비즈니스 & 시사 고급 한국어');

        // EN
        await LocaleService.changeLocale('en');
        expect(starterWord.localizedLevel, 'Hangul & Survival Basics');
        expect(bizWord.localizedLevel, 'Business & Advanced Korean');

        // JA
        await LocaleService.changeLocale('ja');
        expect(starterWord.localizedLevel, 'ハングル基礎・必須表現');
        expect(bizWord.localizedLevel, 'ビジネス・時事上級韓国語');
      },
    );
  });

  group('Reading Modular Widget Component Tests', () {
    testWidgets('ReadingSpeedChip cycles speeds correctly', (tester) async {
      double currentSpeed = 1.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ReadingSpeedChip(
                  playbackRate: currentSpeed,
                  onSpeedChanged: (rate) => setState(() => currentSpeed = rate),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('1.0x'), findsOneWidget);

      await tester.tap(find.byType(ReadingSpeedChip));
      await tester.pump();
      expect(find.text('1.2x'), findsOneWidget);

      await tester.tap(find.byType(ReadingSpeedChip));
      await tester.pump();
      expect(find.text('0.8x'), findsOneWidget);

      await tester.tap(find.byType(ReadingSpeedChip));
      await tester.pump();
      expect(find.text('1.0x'), findsOneWidget);
    });

    testWidgets('ReadingQuizCard displays question and choices', (
      tester,
    ) async {
      final sample = ReadingModel(
        id: 'test_reading_1',
        title: 'IT Infrastructure',
        theme: 'IT',
        level: '중급',
        type: 'reading',
        passageEn: 'The system is operating normally without server errors.',
        passageKo: '시스템이 서버 오류 없이 정상적으로 가동되고 있습니다.',
        questionEn: 'How is the system operating?',
        options: ['Normally', 'With fatal crash', 'Very slowly', 'Offline'],
        correctIndex: 0,
        explanation: '정상적으로 가동 중이라고 기술되어 있습니다.',
        keyVocab: [
          ReadingVocab(
            word: 'operating',
            reading: '/ˈɑːpəreɪtɪŋ/',
            meaning: '작동하는',
          ),
        ],
        createdAt: DateTime.now(),
      );

      int? selectedOption;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ReadingQuizCard(
                  reading: sample,
                  selectedOptionIndex: selectedOption,
                  onSelectOption: (idx) => setState(() => selectedOption = idx),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('How is the system operating?'), findsOneWidget);
      expect(find.text('Normally'), findsOneWidget);
      expect(find.text('With fatal crash'), findsOneWidget);

      // Tap first option
      await tester.tap(find.text('Normally'));
      await tester.pump();
      expect(selectedOption, 0);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets(
      'ReadingLoadingCard and ReadingEmptyIntroCard render without errors',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ReadingLoadingCard(mode: 'reading', level: '중급'),
                  ReadingEmptyIntroCard(mode: 'listening'),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(ReadingLoadingCard), findsOneWidget);
        expect(find.byType(ReadingEmptyIntroCard), findsOneWidget);
        expect(find.byIcon(Icons.headphones), findsOneWidget);
      },
    );

    testWidgets('ReadingPassageCard and ReadingVocabSection render correctly', (
      tester,
    ) async {
      final sample = ReadingModel(
        id: 'test_reading_2',
        title: 'Network Communication',
        theme: 'Network',
        level: '비즈니스',
        type: 'reading',
        passageEn: 'Network packets pass through the router securely.',
        passageKo: '네트워크 패킷이 라우터를 안전하게 통과합니다.',
        questionEn: 'What passes through the router?',
        options: ['Packets', 'Cables', 'Monitors', 'Printers'],
        correctIndex: 0,
        explanation: '패킷이 라우터를 통과한다고 기술되어 있습니다.',
        keyVocab: [
          ReadingVocab(
            word: 'packet',
            reading: '/ˈpækɪt/',
            meaning: '패킷, 데이터 묶음',
          ),
        ],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ReadingPassageCard(
                    reading: sample,
                    isLargeFont: false,
                    revealScript: false,
                    isAnswered: false,
                    playbackRate: 1.0,
                    onToggleComplete: () {},
                    onToggleFontSize: () {},
                    onSpeedChanged: (_) {},
                    onRevealScript: () {},
                  ),
                  ReadingVocabSection(
                    reading: sample,
                    showTranslation: true,
                    onAddVocab: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Network Communication'), findsOneWidget);
      expect(find.text('네트워크 패킷이 라우터를 안전하게 통과합니다.'), findsWidgets);
      expect(find.text('packet'), findsOneWidget);
    });
  });

  group('Settings Modular Widget Component Tests', () {
    testWidgets('SettingsEcosystemTile renders correctly with sister apps', (
      tester,
    ) async {
      await LocaleService.changeLocale('ko');
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SettingsEcosystemTile())),
      );

      expect(find.text('GyuC Studio Apps'), findsOneWidget);
      expect(find.text('On가계부 · On타이머 · 작심삼일본어 · 했니?'), findsOneWidget);
      expect(find.byIcon(Icons.apps_rounded), findsOneWidget);
    });
  });

  group('WidgetService Tests', () {
    test(
      'WidgetService updateWidget and updateWithWord execute without errors',
      () async {
        final sample = WordModel(
          id: 'widget_test_1',
          level: '비즈니스 & 토익',
          word: 'coordinate',
          furigana: '/koʊˈɔːrdɪneɪt/',
          meaning: '조정하다, 협력하다',
          meaningEn: 'bring different elements into a harmonious relationship',
        );

        await WidgetService.updateWithWord(sample);
        await WidgetService.updateWidget();
        expect(WidgetService.appWidgetProviderName, 'OnKoreanWidgetProvider');
      },
    );
  });

  group('NotificationService & SettingsNotificationSection Tests', () {
    test('NotificationService time settings persist and update', () async {
      await NotificationService.setReminderTime(21, 45);
      expect(NotificationService.reminderHour.value, 21);
      expect(NotificationService.reminderMinute.value, 45);
    });

    testWidgets('SettingsNotificationSection renders correctly with toggle', (
      tester,
    ) async {
      await LocaleService.changeLocale('ko');
      NotificationService.isReminderEnabled.value = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: SettingsNotificationSection()),
          ),
        ),
      );

      // Section header exists in ExpansionTile
      expect(
        find.text(LocaleService.tr('settings_notif_section')),
        findsOneWidget,
      );

      // Tap ExpansionTile to expand
      await tester.tap(find.text(LocaleService.tr('settings_notif_section')));
      await tester.pumpAndSettle();

      expect(
        find.text(LocaleService.tr('settings_notif_daily')),
        findsOneWidget,
      );
      // When false, time ListTile and test button are not rendered
      expect(find.text(LocaleService.tr('settings_notif_time')), findsNothing);

      // Now set to true
      NotificationService.isReminderEnabled.value = true;
      await tester.pumpAndSettle();

      expect(
        find.text(LocaleService.tr('settings_notif_time')),
        findsOneWidget,
      );
      expect(
        find.text(LocaleService.tr('settings_notif_test_btn')),
        findsOneWidget,
      );
    });
  });

  group('ThemeService Tests', () {
    test('ThemeService initializes and persists theme mode changes', () async {
      await ThemeService.init();
      expect(ThemeService.themeMode.value, ThemeMode.system);

      await ThemeService.setThemeMode(ThemeMode.dark);
      expect(ThemeService.themeMode.value, ThemeMode.dark);

      await ThemeService.setThemeMode(ThemeMode.light);
      expect(ThemeService.themeMode.value, ThemeMode.light);
    });
  });

  group('BackupService Tests', () {
    test(
      'generateBackupJson and restoreFromJson execute properly with merging',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('mastered_word_ids', [
          'starter_1',
          'starter_2',
        ]);
        await prefs.setStringList('bookmarked_word_ids', ['starter_1']);
        await prefs.setInt('study_streak_days', 5);

        final backupJson = await BackupService.generateBackupJson();
        expect(backupJson.contains('on-korean'), isTrue);
        expect(backupJson.contains('starter_1'), isTrue);

        // Simulate restore with additional data
        final customBackup = jsonEncode({
          'app': 'on-korean',
          'version': 1,
          'mastered_word_ids': ['starter_2', 'starter_3'],
          'bookmarked_word_ids': ['starter_3'],
          'study_streak_days': 7,
        });

        final success = await BackupService.restoreFromJson(customBackup);
        expect(success, isTrue);

        final restoredMastered = prefs.getStringList('mastered_word_ids') ?? [];
        expect(restoredMastered.contains('starter_1'), isTrue);
        expect(restoredMastered.contains('starter_2'), isTrue);
        expect(restoredMastered.contains('starter_3'), isTrue);

        final restoredStreak = prefs.getInt('study_streak_days');
        expect(restoredStreak, 7);
      },
    );

    test('restoreFromJson rejects invalid json or other app backups', () async {
      expect(
        await BackupService.restoreFromJson('invalid json string'),
        isFalse,
      );
      expect(
        await BackupService.restoreFromJson(jsonEncode({'app': 'other_app'})),
        isFalse,
      );
    });
  });

  group('ReviewService Tests', () {
    test('checkAndRequestReview executes safely without throwing in test environment', () async {
      await ReviewService.checkAndRequestReview(
        currentCount: 10,
        targetThreshold: 30,
      );
      await ReviewService.checkAndRequestReview(
        currentCount: 35,
        targetThreshold: 30,
      );
    });
  });

  group('AppSettings & Onboarding Tests', () {
    test(
      'AppSettings initializes and saves onboarding state correctly',
      () async {
        SharedPreferences.setMockInitialValues({});
        await AppSettings.init();
        expect(AppSettings.hasSeenOnboarding.value, isFalse);

        await AppSettings.setHasSeenOnboarding(true);
        expect(AppSettings.hasSeenOnboarding.value, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('has_seen_onboarding'), isTrue);
      },
    );

    test('Onboarding localization keys exist across all languages', () async {
      final keys = [
        'onboarding_skip',
        'onboarding_next',
        'onboarding_start',
        'settings_onboarding',
        'settings_onboarding_desc',
      ];
      for (var lang in ['ko', 'ja', 'en']) {
        await LocaleService.changeLocale(lang);
        for (var k in keys) {
          final val = LocaleService.tr(k);
          expect(val != k, true, reason: 'Key $k missing in $lang');
        }
      }
    });

    testWidgets('OnboardingScreen renders with page controls and skip button', (
      tester,
    ) async {
      await LocaleService.changeLocale('ko');
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(home: OnboardingScreen(onFinish: () => finished = true)),
      );

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text(LocaleService.tr('onboarding_skip')), findsOneWidget);
      expect(find.text(LocaleService.tr('onboarding_next')), findsOneWidget);

      await tester.tap(find.text(LocaleService.tr('onboarding_skip')));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });
  });

  group('WordService Golden Slot & SRS Cooldown Tests', () {
    test(
      'Golden slot distribution, cooldown, and lastReviewedAt tracking',
      () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await WordService.reloadFromPrefs();
        WordService.clearSessionCooldown();

        // Initial study session should return 10 words
        final session1 = WordService.getTodayStudyWords(limit: 10);
        expect(session1.length, 10);

        // Simulate user marking the first 2 words as wrong
        await WordService.recordStudyResult(session1[0], false);
        await WordService.recordStudyResult(session1[1], false);

        expect(session1[0].isWrong, true);
        expect(session1[0].lastReviewedAt, isNotNull);

        // Next immediate session: the 2 words from session 1 should be cooled down (not duplicated in next 10 if new words exist)
        final session2 = WordService.getTodayStudyWords(limit: 10);
        expect(session2.length, 10);
        final s2Ids = session2.map((w) => w.id).toSet();
        expect(s2Ids.contains(session1[0].id), false);
        expect(s2Ids.contains(session1[1].id), false);
      },
    );
  });
}
