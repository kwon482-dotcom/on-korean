import '../services/locale_service.dart';
import '../services/word_service.dart';

class WordModel {
  final String id;
  final String level; // 한글 기초, TOPIK I 초급, TOPIK II 중급, K-드라마 & 일상회화, 비즈니스 & 시사
  final String word; // 한국어 표제어 (예: 안녕하세요, 약속하다)
  final String furigana; // 발음 표기/로마자 (예: [An-nyeong-ha-se-yo], [Yak-sok-ha-da])
  final String meaning; // 기본 영어 뜻 (예: Hello, To make an appointment)
  final String? meaningJa; // 일본어 뜻 (예: こんにちは, 約束する)
  final String? meaningKo; // 한국어 뜻/설명 (예: 만났을 때 하는 정중한 인사)
  final String? meaningEn; // 영어 뜻
  final String partOfSpeech; // 품사 (명사, 동사 등)

  // 💡 AI 실시간 생성을 위해 final 제거 (동적 변경 허용)
  String exampleKo; // 예문 한국어 원문 (학습 타겟)
  String exampleEn; // 예문 영어 번역
  String exampleJa; // 예문 일본어 번역

  // SRS 학습 상태 플래그
  int intervalLevel; // 0: 미학습, 1~5: 복습 단계
  DateTime? nextReviewAt; // 다음 복습 예정 시각
  DateTime? lastReviewedAt; // 마지막 학습/복습 시각
  bool isBookmarked; // 즐겨찾기 여부
  bool isWrong; // 오답노트 등록 여부
  bool isMastered; // 암기 완료 여부 (알아요)

  WordModel({
    required this.id,
    required this.level,
    required this.word,
    required this.furigana,
    required this.meaning,
    this.meaningJa,
    this.meaningKo,
    this.meaningEn,
    this.partOfSpeech = '',
    this.exampleKo = '',
    this.exampleEn = '',
    this.exampleJa = '',
    this.intervalLevel = 0,
    this.nextReviewAt,
    this.lastReviewedAt,
    this.isBookmarked = false,
    this.isWrong = false,
    this.isMastered = false,
  });

  /// 현재 언어(또는 지정된 언어 코드)에 맞는 급수/카테고리 이름을 반환합니다.
  String getLocalizedLevel([String? langCode]) {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    return WordService.getLocalizedCategory(level, code);
  }

  String get localizedLevel => getLocalizedLevel();

  /// 현재 언어(또는 지정된 언어 코드)에 맞는 단어 뜻을 반환합니다.
  String getLocalizedMeaning([String? langCode]) {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    if (code == 'ja' && meaningJa != null && meaningJa!.trim().isNotEmpty) {
      return meaningJa!;
    }
    if (code == 'ko' && meaningKo != null && meaningKo!.trim().isNotEmpty) {
      return meaningKo!;
    }
    if (code == 'en' && meaningEn != null && meaningEn!.trim().isNotEmpty) {
      return meaningEn!;
    }
    // 기본값
    return meaning;
  }

  /// 예문이 존재하는지 여부 (한국어 예문 기준)
  bool get hasExample => exampleKo.trim().isNotEmpty;

  /// 타겟 학습 언어(한국어) 예문 반환
  String get targetExample => exampleKo;

  /// 현재 언어에 맞는 예문 번역을 반환합니다.
  String getLocalizedExampleMeaning([String? langCode]) {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    if (code == 'ja') {
      return exampleJa.trim().isNotEmpty ? exampleJa : (exampleEn.trim().isNotEmpty ? exampleEn : exampleKo);
    }
    if (code == 'ko') {
      return exampleKo;
    }
    // 기본 영어 번역
    return exampleEn.trim().isNotEmpty ? exampleEn : (exampleJa.trim().isNotEmpty ? exampleJa : exampleKo);
  }

  /// 현재 언어에 맞는 품사를 반환합니다.
  String getLocalizedPartOfSpeech([String? langCode]) {
    final code = langCode ?? LocaleService.currentLocale.value.languageCode;
    if (code == 'ja') {
      switch (partOfSpeech) {
        case '명사':
        case 'Noun':
          return '名詞';
        case '동사':
        case 'Verb':
          return '動詞';
        case '형용사':
        case 'Adj':
          return '形容詞';
        case '부사':
        case 'Adverb':
          return '副詞';
        case '감탄사':
        case 'Interjection':
          return '感嘆詞';
        case '인사':
        case 'Greeting':
          return '挨拶';
        case '표현':
        case 'Expression':
          return '表現';
        default:
          return partOfSpeech;
      }
    }
    if (code == 'ko') {
      return partOfSpeech;
    }
    // 기본 영어 표기
    switch (partOfSpeech) {
      case '명사':
        return 'Noun';
      case '동사':
        return 'Verb';
      case '형용사':
        return 'Adj';
      case '부사':
        return 'Adverb';
      case '감탄사':
        return 'Interjection';
      case '인사':
        return 'Greeting';
      case '표현':
        return 'Expression';
      default:
        return partOfSpeech;
    }
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String,
      level: json['level'] as String,
      word: json['word'] as String,
      furigana: json['furigana'] as String? ?? '',
      meaning: (json['meaning'] ?? json['meaningEn']) as String? ?? '',
      meaningJa: json['meaningJa'] as String?,
      meaningKo: json['meaningKo'] as String?,
      meaningEn: (json['meaningEn'] ?? json['meaning']) as String?,
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      exampleKo: json['exampleKo'] as String? ?? (json['exampleJa'] as String? ?? ''),
      exampleEn: json['exampleEn'] as String? ?? '',
      exampleJa: json['exampleJa'] as String? ?? '',
      intervalLevel: json['intervalLevel'] as int? ?? 0,
      nextReviewAt: json['nextReviewAt'] != null
          ? DateTime.tryParse(json['nextReviewAt'] as String)
          : null,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.tryParse(json['lastReviewedAt'] as String)
          : null,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isWrong: json['isWrong'] as bool? ?? false,
      isMastered: json['isMastered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'word': word,
      'furigana': furigana,
      'meaning': meaning,
      if (meaningJa != null) 'meaningJa': meaningJa,
      if (meaningKo != null) 'meaningKo': meaningKo,
      'partOfSpeech': partOfSpeech,
      'exampleKo': exampleKo,
      'exampleEn': exampleEn,
      'exampleJa': exampleJa,
      'intervalLevel': intervalLevel,
      'nextReviewAt': nextReviewAt?.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'isBookmarked': isBookmarked,
      'isWrong': isWrong,
      'isMastered': isMastered,
    };
  }
}
