import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reading_model.dart';
import 'energy_service.dart';
import 'locale_service.dart';
import 'remote_config_service.dart';

/// AI 1분 단문 독해 생성 및 로컬 기기 보관 관리 서비스
class ReadingService {
  static const String _prefKeySavedReadings = 'saved_ai_readings';

  static final ValueNotifier<List<ReadingModel>> savedReadings =
      ValueNotifier<List<ReadingModel>>([]);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_prefKeySavedReadings);
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(rawJson);
        savedReadings.value = list
            .map((e) => ReadingModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('[ReadingService] 독해 데이터 로드 에러: $e');
        savedReadings.value = [];
      }
    }
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = savedReadings.value.map((e) => e.toJson()).toList();
    await prefs.setString(_prefKeySavedReadings, jsonEncode(jsonList));
  }

  /// 독해 카드 보관(저장)
  static Future<void> saveReading(ReadingModel item) async {
    final current = List<ReadingModel>.from(savedReadings.value);
    current.removeWhere((e) => e.id == item.id);
    current.insert(0, item);
    savedReadings.value = current;
    await _persist();
  }

  /// 독해 카드 삭제
  static Future<void> deleteReading(String id) async {
    final current = List<ReadingModel>.from(savedReadings.value);
    current.removeWhere((e) => e.id == id);
    savedReadings.value = current;
    await _persist();
  }

  /// 완료/복습 여부 직접 설정
  static Future<void> setCompleted(String id, bool completed) async {
    final current = List<ReadingModel>.from(savedReadings.value);
    final idx = current.indexWhere((e) => e.id == id);
    if (idx != -1) {
      current[idx].isCompleted = completed;
      savedReadings.value = current;
      await _persist();
    }
  }

  /// 완료/복습 여부 토글
  static Future<void> toggleCompleted(String id) async {
    final current = List<ReadingModel>.from(savedReadings.value);
    final idx = current.indexWhere((e) => e.id == id);
    if (idx != -1) {
      current[idx].isCompleted = !current[idx].isCompleted;
      savedReadings.value = current;
      await _persist();
    }
  }

  static const List<Map<String, String>> _diverseThemes = [
    // 1. IT·디지털·현대사회
    {'category': 'IT·디지털', 'detail': '생성형 AI(인공지능) 챗봇을 활용한 업무 효율화와 질문 작성 팁'},
    {'category': 'IT·디지털', 'detail': '편의점과 마트의 셀프 계산대(무인 포스기) 바코드 스캔 이용법'},
    {'category': 'IT·디지털', 'detail': '스마트폰 배터리 절약 모드와 다크 테마(화면 어둡게) 설정'},
    {'category': 'IT·디지털', 'detail': '배달 앱으로 점심 도시락과 음료 주문하고 문 앞 비대면 수령'},
    {'category': 'IT·디지털', 'detail': '재택근무 중 온라인 화상회의 음소거와 배경 흐림 매너'},
    {'category': 'IT·디지털', 'detail': '스마트워치로 수면 패턴과 일일 만보 걷기 달성 기록 확인'},
    {'category': 'IT·디지털', 'detail': '클라우드 드라이브 대용량 파일 공유 링크 전달과 다운로드 기한'},
    {'category': 'IT·디지털', 'detail': 'SNS에 여행 사진을 올릴 때 개인정보와 위치 태그 유출 방지 주의'},
    {'category': 'IT·디지털', 'detail': '무선 이어폰의 노이즈 캔슬링 기능과 지하철 내 주변 소음 차단'},
    {'category': 'IT·디지털', 'detail': '당근마켓 등 동네 이웃과의 중고 거래 매너와 따뜻한 매너온도'},
    {'category': 'IT·디지털', 'detail': '모바일 간편결제(카카오페이/토스)로 식사 후 친구들과 더치페이 1/N 송금'},

    // 2. 일상·생활 상식
    {'category': '일상·생활', 'detail': '비 오는 날 편의점 비닐우산 구매와 빗물 털이개 사용 에티켓'},
    {'category': '일상·생활', 'detail': '아파트 무인 택배함 비밀번호 입력과 부재중 로켓배송 수령'},
    {'category': '일상·생활', 'detail': '분리수거 요일제에 맞춰 투명 페트병 라벨 떼고 압착 배출하기'},
    {'category': '일상·생활', 'detail': '추운 겨울 동파 방지를 위해 보일러 외출 모드 설정과 온돌 난방'},
    {'category': '일상·생활', 'detail': '찜질방에서 양머리 수건 하고 시원한 식혜와 맥반석 구운 계란 먹기'},
    {'category': '일상·생활', 'detail': '동네 행정복지센터(주민센터)에서 주민등록등본 발급과 무인민원기 이용'},
    {'category': '일상·생활', 'detail': '환절기 감기 예방과 동네 약국에서 따뜻한 쌍화탕과 비타민 찾기'},
    {'category': '일상·생활', 'detail': '반려견과 동네 산책로 걸으며 배변 봉투와 리드줄 챙기는 펫티켓'},
    {'category': '일상·생활', 'detail': '24시간 무인 빨래방(코인세탁소)에서 대형 이불 세탁과 건조기 돌리기'},
    {'category': '일상·생활', 'detail': '주말 대형마트 시식 코너 둘러보기와 종량제 봉투 장바구니 구매'},

    // 3. 교통·여행
    {'category': '교통·여행', 'detail': '스마트폰 티머니(T-money) 교통카드로 지하철·시내버스 환승 할인 받기'},
    {'category': '교통·여행', 'detail': 'KTX 기차 타고 서울역에서 부산역까지 2시간 반 만에 도착하기'},
    {'category': '교통·여행', 'detail': '제주도 렌터카 여행과 에메랄드빛 협재 해변 해안도로 드라이브'},
    {'category': '교통·여행', 'detail': '경복궁에서 한복 곱게 차려입고 고궁 무료입장 및 야간 개장 관람'},
    {'category': '교통·여행', 'detail': '남산 서울타워 케이블카 타고 올라가 서울 야경 구경과 사랑의 자물쇠 걸기'},
    {'category': '교통·여행', 'detail': '강릉 안목해변 커피거리에서 푸른 동해 바다를 바라보며 커피 마시기'},
    {'category': '교통·여행', 'detail': '부산 해운대 해변 열차를 타고 청사포 다릿돌 전망대 바다 산책'},
    {'category': '교통·여행', 'detail': '전주 한옥마을 골목길 산책과 따뜻한 전통 놋그릇 비빔밥 맛보기'},
    {'category': '교통·여행', 'detail': '심야 안전 귀가를 위한 스마트폰 브랜드 콜택시 호출과 자동 결제'},
    {'category': '교통·여행', 'detail': '인천공항 공항철도 직통열차 탑승과 해외여행 출국 수속 팁'},

    // 4. 음식·미식·외식
    {'category': '음식·미식', 'detail': '한강 공원 잔디밭에 돗자리 펴고 즉석 조리 라면과 치맥(치킨·맥주) 배달'},
    {'category': '음식·미식', 'detail': '분식집에서 매콤달콤한 떡볶이 국물에 바삭한 모둠튀김과 순대 찍어 먹기'},
    {'category': '음식·미식', 'detail': '삼겹살 전문점에서 노릇하게 구운 고기를 상추, 깻잎, 쌈장에 싸먹기'},
    {'category': '음식·미식', 'detail': '비 오는 날 파전 지글지글 부치는 고소한 냄새와 시원한 막걸리 한잔'},
    {'category': '음식·미식', 'detail': '철판 닭갈비 다 먹은 뒤 김가루와 참기름을 둘러 볶아 먹는 K-볶음밥'},
    {'category': '음식·미식', 'detail': '추운 겨울 길거리 포장마차에서 호호 불며 먹는 어묵 꼬치와 따뜻한 국물'},
    {'category': '음식·미식', 'detail': '식후 디저트로 시원한 딸기 찹쌀떡과 달콤한 눈꽃 팥빙수 나눠 먹기'},
    {'category': '음식·미식', 'detail': '든든한 점심 식사로 뚝배기에 보글보글 끓는 돼지고기 김치찌개와 공깃밥'},
    {'category': '음식·미식', 'detail': '동네 골목 소문난 베이커리에서 갓 구운 쫄깃한 소금빵과 단팥빵 고르기'},
    {'category': '음식·미식', 'detail': '여름철 무더위를 식혀주는 살얼음 동동 띄운 시원한 물냉면과 숯불고기'},

    // 5. 문화·전통·엔터
    {'category': '문화·전통', 'detail': '설날 아침 온 가족이 모여 따뜻한 떡국 먹고 어른들께 세배 드리기'},
    {'category': '문화·전통', 'detail': '추석 명절에 온 가족이 둘러앉아 달콤한 꿀과 깨를 넣어 송편 빚기'},
    {'category': '문화·전통', 'detail': 'K-팝 아이돌 콘서트 티켓팅 광클 도전과 반짝이는 응원봉 흔들기'},
    {'category': '문화·전통', 'detail': '친구들과 코인노래방(코노)에서 1시간 동안 신나게 애창곡 부르기'},
    {'category': '문화·전통', 'detail': '봄날 여의도 윤중로 벚꽃축제 길을 걸으며 인생 사진 남기기'},
    {'category': '문화·전통', 'detail': '홍대 걷고싶은거리에서 열정적인 길거리 버스킹 댄스와 인디 밴드 공연'},
    {'category': '문화·전통', 'detail': '한글날을 맞아 세종대왕의 훈민정음 창제 이야기와 한글의 독창성 되새기기'},
    {'category': '문화·전통', 'detail': '가을 단풍이 붉게 물든 설악산 국립공원 등산과 정상 인증 사진'},
    {'category': '문화·전통', 'detail': '정월 대보름에 오곡밥과 부럼(땅콩, 호두) 깨물며 한 해 무사태평 기원'},
    {'category': '문화·전통', 'detail': '영화관에서 팝콘과 콜라를 들고 화제의 최신 한국 영화 개봉작 관람'},

    // 6. 쇼핑·서비스
    {'category': '쇼핑·서비스', 'detail': '올리브영에서 피부 진정 마스크팩과 최신 K-뷰티 스킨케어 화장품 쇼핑'},
    {'category': '쇼핑·서비스', 'detail': '동대문 패션타운 야시장 둘러보기와 가성비 좋은 최신 유행 옷 고르기'},
    {'category': '쇼핑·서비스', 'detail': '교보문고 광화문점 대형 서점에서 베스트셀러 소설과 에세이 둘러보기'},
    {'category': '쇼핑·서비스', 'detail': '전통 광장시장에서 바삭한 녹두빈대떡과 마약김밥 포장하기'},
    {'category': '쇼핑·서비스', 'detail': '무인 소품샵에서 귀여운 한국 캐릭터 스티커와 다이어리 꾸미기 용품 쇼핑'},
    {'category': '쇼핑·서비스', 'detail': '안경점에서 15분 만에 시력 측정하고 가벼운 티타늄 안경 맞추기'},
    {'category': '쇼핑·서비스', 'detail': '미용실에서 헤어 디자이너와 상담 후 자연스러운 헤어스타일 변신'},

    // 7. 직장·캠퍼스·사회
    {'category': '직장·캠퍼스', 'detail': '첫 출근날 두 손으로 정중하게 명함 교환하기와 부서 선배들께 인사하기'},
    {'category': '직장·캠퍼스', 'detail': '직장인들의 점심 필수 코스 "얼죽아(얼어 죽어도 아이스 아메리카노)" 테이크아웃'},
    {'category': '직장·캠퍼스', 'detail': '대학교 수강신청 첫날 서버 시간 확인하며 광클릭으로 올클리어 성공'},
    {'category': '직장·캠퍼스', 'detail': '대학교 봄 축제 기간 학과 주점과 초청 가수 공연 다 함께 즐기기'},
    {'category': '직장·캠퍼스', 'detail': '새 학기 캠퍼스에서 같은 학과 동기들과 단체 과잠(학과 점퍼) 맞춰 입기'},
    {'category': '직장·캠퍼스', 'detail': '퇴근 후 친한 팀원들과 맛있는 치킨집에서 갖는 가벼운 번개 모임'},
    {'category': '직장·캠퍼스', 'detail': '프로젝트 발표를 위한 사내 프레젠테이션 PPT 제작과 리허설 연습'},
    {'category': '직장·캠퍼스', 'detail': '직장 상사에게 업무 진행 상황을 중간보고하고 피드백 받기'},
    {'category': '직장·캠퍼스', 'detail': '취업 준비생의 모의 면접 연습과 단정하고 깔끔한 면접 정장 준비'},
    {'category': '직장·캠퍼스', 'detail': '대학교 중앙도서관 열람실에서 중간고사 시험공부와 친구와 캔커피 마시기'},
  ];

  static final List<String> _recentDetails = [];

  /// AI 1분 단문 독해/청해 생성
  static Future<ReadingModel?> generateReading({
    required String level,
    String type = 'reading',
    String? theme,
  }) async {
    final keys = RemoteConfigService.getGeminiApiKeys();
    if (keys.isEmpty || keys.first.isEmpty) {
      return null;
    }

    // 💡 Remote Config 원격 제어 및 초고속 Lite 모델 최우선 풀
    final models = RemoteConfigService.getGeminiModels();

    // 💡 특정 소재(말차, 편의점 등)가 자주 반복되지 않도록 80여 개 이상의 풍부한 테마 풀에서 무작위 선정
    final available = _diverseThemes
        .where((t) => !_recentDetails.contains(t['detail']))
        .toList();
    final chosen = available.isNotEmpty
        ? (available..shuffle()).first
        : (_diverseThemes..shuffle()).first;

    _recentDetails.add(chosen['detail']!);
    // 💡 최근 25개 주제를 기억하여 최소 25회 동안 동일 소재 재등장 완전 방지
    if (_recentDetails.length > 25) {
      _recentDetails.removeAt(0);
    }

    final categoryName = theme != null && theme.isNotEmpty
        ? theme
        : chosen['category']!;
    final detailTopic = chosen['detail']!;

    final langCode = LocaleService.currentLocale.value.languageCode;
    final isEn = langCode == 'en';
    final isJa = langCode == 'ja';
    final modeLabel = type == 'listening' ? '듣기(청해 평가)' : '단문 독해';
    final formatHint = type == 'listening'
        ? '''1. [듣기 모드 필수 지침]:
- 듣기 평가에 최적화된 생생한 2인 대화문(예: 두 사람의 일상 대화, 점원과 손님, 직장 동료, 친구) 또는 공공장소/안내 방송 형식의 3~5문장으로 작성할 것.
- 2인 대화문일 경우 반드시 발화자 기호(예: 민수：..., 지수：... 또는 손님：..., 직원：...)를 문장 앞에 붙여 자연스러운 구어체 한국어로 작성할 것.
- 질문(questionKo)은 실제 TOPIK 듣기 기출처럼 음성을 듣고 정답을 고르는 질문(예: 「남자는 이어서 무엇을 하겠습니까?」, 「두 사람은 어디에서 만나기로 했습니까?」, 「여자는 무엇에 대해 이야기하고 있습니까?」 등)으로 출제할 것.'''
        : '''1. [단문 독해 필수 지침]:
- 지문 길이는 3~5문장의 부담 없는 단문으로 작성할 것 (1분 내에 가볍게 읽을 수 있는 분량).
- 질문(questionKo)은 지문의 핵심 내용이나 글쓴이의 중심 생각을 묻는 문제(TOPIK 형식)로 출제할 것.''';

    final String prompt;
    if (isJa) {
      final jaFormatHint = type == 'listening'
          ? '''1. 【リスニングモード必須要件】:
- リスニング評価に最適な生き生きとした2人の韓国語日常会話（例：日常会話、店員と客、同僚、友達）またはアナウンス放送形式（3〜5文）。
- 2人会話の場合は必ず話者名（例：민수：..., 지수：... または 손님：..., 직원：...）を先頭に付けること。
- 質問(questionKo)はTOPIK形式のリスニング設問（例：「남자는 이어서 무엇을 하겠습니까?」など）にすること。'''
          : '''1. 【短文読解モード必須要件】:
- 1分でサクッと読める3〜5文の自然な標準韓国語短文。
- 質問(questionKo)はTOPIK形式の内容一致または主題把握設問にすること。''';

      prompt =
          '''
あなたは韓国語教育の最高専門家であり、TOPIK（韓国語能力試験）の出題委員です。
日本の韓国語学習者（難易度: $level）向けに、「1分ショート韓国語 ${type == 'listening' ? '聴解(リスニング)' : '読解'}カード」を1つ作成してください。

【テーマとシチュエーション】:
• カテゴリ: $categoryName
• 状況・素材: $detailTopic

【作成条件】:
$jaFormatHint
2. $level レベルにぴったりの自然な韓国語語彙と文法を使用すること。
3. 理解度をチェックする4択クイズ1問を出題すること。
4. 本文中の重要韓国語語彙3〜4個を厳選し、発音（ローマ字）と【日本語の意味】をまとめること。

【★言語ルール - 最重要厳守★】:
• "title", "passageKo", "questionKo", "options"(4つの選択肢すべて)は必ず100%自然な【韓国語(ハングル)】で作成すること。
• "passageJa"は本文全体の自然で正確な【日本語対訳】。
• "passageEn"は本文全体の自然な英語訳。
• "explanation"(正解と解説)は、必ず【日本語】で親切・論理的に作成すること！（韓国語不可）
• "keyVocab"の"meaning"は、必ず【日本語の意味】で記述すること！（韓国語不可、例: "word": "다방", "reading": "[da-bang]", "meaning": "伝統的な喫茶店"）

マークダウン記法(```json等)は一切含めず、純粋なJSONオブジェクトのみで返答してください:
{
  "title": "韓国語タイトル (ハングル)",
  "theme": "$categoryName",
  "passageKo": "韓国語本文 (3〜5文の自然なハングル本文または対話文)",
  "passageJa": "本文全体の自然な日本語訳",
  "passageEn": "本文全体の英語訳",
  "questionKo": "韓国語の設問 (ハングル)",
  "options": [
    "選択肢1 (ハングル)",
    "選択肢2 (ハングル)",
    "選択肢3 (ハングル)",
    "選択肢4 (ハングル)"
  ],
  "correctIndex": 0,
  "explanation": "日本語による正解とわかりやすい解説 (1〜2文)",
  "keyVocab": [
    {"word": "単語(ハングル)", "reading": "[ローマ字発音]", "meaning": "単語の日本語の意味"}
  ]
}
''';
    } else if (isEn) {
      final enFormatHint = type == 'listening'
          ? '''1. [Listening Mode Requirements]:
- Write 3-5 sentences of vivid 2-person dialogue (e.g., daily conversation, clerk and customer, coworkers, friends) or a public announcement in natural Korean.
- For 2-person dialogues, prefix each sentence with speaker names (e.g., Minsoo: ..., Jisoo: ... or Customer: ..., Clerk: ...).
- The question (questionKo) must test audio comprehension (e.g., "What will the man do next?", "Where did the two decide to meet?").'''
          : '''1. [Reading Mode Requirements]:
- Passage length must be 3-5 concise sentences in natural standard Korean (easy to read within 1 minute).
- The question (questionKo) must test comprehension of the central topic or author's intent.''';

      prompt =
          '''
You are a professional Korean language educator and TOPIK (Test of Proficiency in Korean) exam designer.
Create 1 "1-Minute Korean Short ${type == 'listening' ? 'Listening' : 'Reading'} Card" tailored to level: $level.

[Theme & Topic]:
• Category: $categoryName
• Scenario & Topic: $detailTopic

[Passage Requirements]:
$enFormatHint
2. Use vocabulary and grammar appropriate for level: $level.
3. Write accurate and natural standard Korean sentences.
4. Include 1 multiple-choice quiz question with 4 options to test comprehension.
5. Select 3-4 key vocabulary words with romanized pronunciation and English meaning.

[Language Rules - STRICT]:
• "title", "passageKo", "questionKo", "options" (all 4 options) MUST be 100% natural Korean (한국어).
• "passageEn", "explanation", and the "meaning" of "keyVocab" MUST be written in English.
• "passageJa" must be a smooth Japanese translation of the passage.

Respond strictly in pure JSON format without markdown code blocks:
{
  "title": "Korean Title (한국어 제목)",
  "theme": "$categoryName",
  "passageKo": "Korean passage (3-5 sentences in natural Korean)",
  "passageEn": "Accurate English translation of the passage",
  "passageJa": "Accurate Japanese translation of the passage",
  "questionKo": "Question in Korean (TOPIK style)",
  "options": [
    "Option 1 in Korean",
    "Option 2 in Korean",
    "Option 3 in Korean",
    "Option 4 in Korean"
  ],
  "correctIndex": 0,
  "explanation": "Answer explanation and rationale in English (1-2 sentences)",
  "keyVocab": [
    {"word": "단어", "reading": "[dan-eo]", "meaning": "English meaning of the word"}
  ]
}
''';
    } else {
      prompt =
          '''
너는 한국어 교육 전문 튜터이자 TOPIK(한국어능력시험) 출제위원이야.
한국어 학습 $level 난이도에 맞춘 "1분 숏폼 한국어 $modeLabel 카드"를 1개 작성해줘.

[이번 주제와 소재]:
• 대분류: $categoryName
• 핵심 상황 및 소재: $detailTopic

[지문 요구사항]:
$formatHint
2. $level 수준에 어울리는 어휘와 문법을 사용할 것.
3. 오탈자 없는 정확하고 자연스러운 표준 한국어 문장으로 작성할 것.
4. 내용을 잘 이해했는지 확인할 수 있는 4지선다형 퀴즈 1문항을 함께 출제할 것.
5. 지문 속에서 공부하기 좋은 핵심 단어 3~4개를 선정하여 로마자 발음과 뜻을 정리해줄 것.

[언어 규정 - 절대 엄수]:
• "title", "passageKo", "questionKo", "options"(4개 선택지 모두)는 반드시 100% 순수 한국어로만 작성해야 합니다.
• "passageEn"은 매끄러운 영어 번역, "passageJa"는 매끄러운 일본어 번역으로 작성할 것.
• "explanation"은 학습자의 이해를 돕는 친절한 해설로 작성할 것.

반드시 마크다운 코드블록 없이, 아래의 순수한 JSON 형식으로만 응답해줘:
{
  "title": "한국어 제목",
  "theme": "$categoryName",
  "passageKo": "한국어 본문 (3〜5문장의 한국어 본문/대화문)",
  "passageEn": "지문 전체의 매끄러운 영어 번역",
  "passageJa": "지문 전체의 매끄러운 일본어 번역",
  "questionKo": "한국어 질문 (TOPIK 시험 스타일의 한국어 질문)",
  "options": [
    "한국어 선택지 1",
    "한국어 선택지 2",
    "한국어 선택지 3",
    "한국어 선택지 4"
  ],
  "correctIndex": 0,
  "explanation": "정답 해설 및 이유 (1~2줄)",
  "keyVocab": [
    {"word": "단어", "reading": "[dan-eo]", "meaning": "단어 뜻"}
  ]
}
''';
    }

    // 💡 최적화: 무료 RPM(15회) 쿼터를 보호하고 과도한 대기 지연을 방지하기 위해 최우선 2개 모델까지만 시도
    final candidateModels = models.take(2).toList();
    // 💡 키 로테이션(로드 밸런싱): 등록된 키들(01, 02 등)을 무작위 셔플하여 트래픽을 균등 분산 (02번 키 활성화)
    final candidateKeys = (List<String>.from(keys)..shuffle()).take(2).toList();

    for (final currentKey in candidateKeys) {
      for (final model in candidateModels) {
        final urlStr =
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$currentKey';

        try {
          final response = await http
              .post(
                Uri.parse(urlStr),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'contents': [
                    {
                      'parts': [
                        {'text': prompt},
                      ],
                    },
                  ],
                  'generationConfig': {
                    'responseMimeType': 'application/json',
                    'temperature': 0.7, // 💡 다양한 창의성과 엄격한 급수/주제 틀 유지를 위한 밸런스 조정
                  },
                }),
              )
              .timeout(const Duration(milliseconds: 7500));

          if (response.statusCode == 200) {
            final data = jsonDecode(utf8.decode(response.bodyBytes));
            final candidates = data['candidates'] as List<dynamic>?;
            if (candidates != null && candidates.isNotEmpty) {
              final content = candidates[0]['content'];
              final parts = content?['parts'] as List<dynamic>?;
              if (parts != null && parts.isNotEmpty) {
                final rawText = parts[0]['text'] as String? ?? '';
                final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
                if (jsonMatch != null) {
                  final Map<String, dynamic> parsed = jsonDecode(
                    jsonMatch.group(0)!,
                  );

                  final title = parsed['title']?.toString().trim() ?? '';
                  final rawKo = parsed['passageKo']?.toString().trim() ?? parsed['passage']?.toString().trim() ?? '';
                  final rawEn = parsed['passageEn']?.toString().trim() ?? '';
                  final rawJa = parsed['passageJa']?.toString().trim() ?? '';
                  final passageKo = rawKo.isNotEmpty ? rawKo : (rawJa.isNotEmpty ? rawJa : rawEn);
                  final passageEn = rawEn.isNotEmpty ? rawEn : (rawJa.isNotEmpty ? rawJa : passageKo);
                  final passageJa = rawJa.isNotEmpty ? rawJa : passageEn;

                  final questionKo = (parsed['questionKo'] ?? parsed['questionJa'] ?? parsed['question'] ?? '').toString().trim();
                  final optionsRaw = parsed['options'] as List<dynamic>? ?? [];
                  final options = optionsRaw
                      .map((e) => e.toString().trim())
                      .toList();
                  final correctIndex =
                      (parsed['correctIndex'] as num?)?.toInt() ?? 0;
                  final explanation =
                      parsed['explanation']?.toString().trim() ?? '';
                  final keyVocabRaw =
                      parsed['keyVocab'] as List<dynamic>? ?? [];
                  final keyVocab = keyVocabRaw
                      .map(
                        (e) => ReadingVocab.fromJson(e as Map<String, dynamic>),
                      )
                      .toList();

                  // 한국어 안전 제목 보정
                  String safeTitle = title;
                  if (safeTitle.isEmpty) {
                    safeTitle = type == 'listening'
                        ? '한국어 듣기 연습'
                        : '한국어 1분 단문 독해';
                  }

                  if (passageKo.isNotEmpty) {
                    final newReading = ReadingModel(
                      id: 'reading_${DateTime.now().millisecondsSinceEpoch}',
                      level: level,
                      type: type,
                      theme:
                          parsed['theme']?.toString().trim().isNotEmpty == true
                          ? parsed['theme'].toString().trim()
                          : categoryName,
                      title: safeTitle,
                      passageKo: passageKo,
                      passageEn: passageEn,
                      passageJa: passageJa,
                      questionKo: questionKo,
                      questionEn: questionKo,
                      questionJa: questionKo,
                      options: options,
                      correctIndex: correctIndex.clamp(
                        0,
                        options.isNotEmpty ? options.length - 1 : 0,
                      ),
                      explanation: explanation,
                      keyVocab: keyVocab,
                      createdAt: DateTime.now(),
                    );

                    // 💡 독해 에너지 소진 (원격 설정값 연동) 및 로컬 보관함 자동 영구 저장
                    final cost = RemoteConfigService.getReadingEnergyCost();
                    await EnergyService.consume(cost);
                    await saveReading(newReading);

                    return newReading;
                  }
                }
              }
            }
          } else if (response.statusCode == 429) {
            debugPrint('[$model] 429 한도 초과. 다음 키 또는 모델로 우회...');
            if (candidateKeys.length > 1) {
              break;
            }
            continue;
          } else if (response.statusCode == 503 || response.statusCode == 404) {
            debugPrint('[$model] ${response.statusCode} 응답. 다음 모델로 우회...');
            continue;
          }
        } on TimeoutException {
          debugPrint('[$model] 응답 시간 초과 (7.5초), 다음 모델로 우회');
          continue;
        } catch (e) {
          debugPrint('[ReadingService ($model)] 예외 발생: $e');
        }
      }
    }

    return null;
  }
}
