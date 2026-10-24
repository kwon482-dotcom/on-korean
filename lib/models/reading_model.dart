class ReadingVocab {
  final String word;
  final String reading;
  final String meaning;

  ReadingVocab({
    required this.word,
    required this.reading,
    required this.meaning,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    'reading': reading,
    'meaning': meaning,
  };

  factory ReadingVocab.fromJson(Map<String, dynamic> json) => ReadingVocab(
    word: json['word']?.toString() ?? '',
    reading: json['reading']?.toString() ?? '',
    meaning: json['meaning']?.toString() ?? '',
  );
}

class ReadingModel {
  final String id;
  final String level; // 한글 기초, TOPIK I, TOPIK II, K-드라마, 고급
  final String theme; // 일상, 문화, 여행, 비즈니스 등
  final String type; // 'reading' | 'listening'
  final String title;
  final String passageKo; // 타겟 한국어 지문 본문
  final String _passageEn; // 영어 번역
  final String _passageJa; // 일본어 번역
  final String questionKo; // 타겟 한국어 질문
  final String _questionEn; // 영어 질문
  final String _questionJa; // 일본어 질문
  final List<String> options; // 한국어 4지선다 선택지
  final int correctIndex;
  final String explanation; // 정답 해설
  final List<ReadingVocab> keyVocab;
  final DateTime createdAt;
  bool isCompleted;

  ReadingModel({
    required this.id,
    required this.level,
    required this.theme,
    this.type = 'reading',
    required this.title,
    required this.passageKo,
    String? passageEn,
    String? passageJa,
    String? questionKo,
    String? questionEn,
    String? questionJa,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.keyVocab,
    required this.createdAt,
    this.isCompleted = false,
  })  : _passageEn = passageEn ?? '',
        _passageJa = passageJa ?? '',
        questionKo = questionKo ?? questionJa ?? questionEn ?? '',
        _questionEn = questionEn ?? '',
        _questionJa = questionJa ?? '';

  /// 타겟 한국어 본문 (하위 호환 및 명시적 접근)
  String get targetPassage => passageKo.isNotEmpty ? passageKo : (_passageEn.isNotEmpty ? _passageEn : _passageJa);
  String get passageEn => _passageEn.isNotEmpty ? _passageEn : passageKo;
  String get passageJa => _passageJa.isNotEmpty ? _passageJa : (_passageEn.isNotEmpty ? _passageEn : passageKo);

  String get targetQuestion => questionKo.isNotEmpty ? questionKo : (_questionEn.isNotEmpty ? _questionEn : _questionJa);
  String get questionEn => _questionEn.isNotEmpty ? _questionEn : questionKo;
  String get questionJa => _questionJa.isNotEmpty ? _questionJa : (_questionEn.isNotEmpty ? _questionEn : questionKo);

  /// 현재 언어에 어울리는 본문 번역 반환
  String getLocalizedTranslation([String? langCode]) {
    if (langCode == 'ja' && _passageJa.isNotEmpty) return _passageJa;
    if (langCode == 'en' && _passageEn.isNotEmpty) return _passageEn;
    return _passageEn.isNotEmpty ? _passageEn : (_passageJa.isNotEmpty ? _passageJa : passageKo);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'theme': theme,
    'type': type,
    'title': title,
    'passageKo': passageKo,
    'passageEn': _passageEn,
    'passageJa': _passageJa,
    'questionKo': questionKo,
    'questionEn': _questionEn,
    'questionJa': _questionJa,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'keyVocab': keyVocab.map((v) => v.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    final rawKo = json['passageKo']?.toString() ?? '';
    final rawJa = json['passageJa']?.toString() ?? '';
    final rawEn = json['passageEn']?.toString() ?? '';

    // 한국어 본문 우선, 없으면 fallback
    final effectiveKo = rawKo.isNotEmpty ? rawKo : (rawJa.isNotEmpty ? rawJa : rawEn);

    final rawQKo = json['questionKo']?.toString() ?? '';
    final rawQJa = json['questionJa']?.toString() ?? '';
    final rawQEn = json['questionEn']?.toString() ?? '';
    final effectiveQKo = rawQKo.isNotEmpty ? rawQKo : (rawQJa.isNotEmpty ? rawQJa : rawQEn);

    return ReadingModel(
      id: json['id']?.toString() ?? '',
      level: json['level']?.toString() ?? '초급',
      theme: json['theme']?.toString() ?? '일상',
      type: json['type']?.toString() ?? 'reading',
      title: json['title']?.toString() ?? '',
      passageKo: effectiveKo,
      passageEn: rawEn,
      passageJa: rawJa,
      questionKo: effectiveQKo,
      questionEn: rawQEn,
      questionJa: rawQJa,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      keyVocab:
          (json['keyVocab'] as List<dynamic>?)
              ?.map((e) => ReadingVocab.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isCompleted: json['isCompleted'] == true,
    );
  }
}
