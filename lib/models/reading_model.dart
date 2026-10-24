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
  final String level; // 기초, 초급, 중급, K-드라마, 고급
  final String theme; // 일상, 문화, 여행, 비즈니스 등
  final String type; // 'reading' | 'listening'
  final String title;
  final String passageJa;
  final String passageKo;
  final String questionJa;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final List<ReadingVocab> keyVocab;
  final DateTime createdAt;
  bool isCompleted;

  ReadingModel({
    required this.id,
    required this.level,
    required this.theme,
    this.type = 'reading',
    required this.title,
    String? passageJa,
    String? passageEn,
    required this.passageKo,
    String? questionJa,
    String? questionEn,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.keyVocab,
    required this.createdAt,
    this.isCompleted = false,
  })  : passageJa = passageEn ?? passageJa ?? '',
        questionJa = questionEn ?? questionJa ?? '';

  String get passageEn => passageJa;
  String get questionEn => questionJa;

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'theme': theme,
    'type': type,
    'title': title,
    'passageEn': passageEn,
    'passageJa': passageJa,
    'passageKo': passageKo,
    'questionEn': questionEn,
    'questionJa': questionJa,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
    'keyVocab': keyVocab.map((v) => v.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory ReadingModel.fromJson(Map<String, dynamic> json) => ReadingModel(
    id: json['id']?.toString() ?? '',
    level: json['level']?.toString() ?? '초급',
    theme: json['theme']?.toString() ?? '일상',
    type: json['type']?.toString() ?? 'reading',
    title: json['title']?.toString() ?? '',
    passageEn: json['passageEn']?.toString() ?? json['passageJa']?.toString() ?? '',
    passageKo: json['passageKo']?.toString() ?? '',
    questionEn: json['questionEn']?.toString() ?? json['questionJa']?.toString() ?? '',
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
