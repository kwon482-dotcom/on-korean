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
    {'category': 'IT·디지털', 'detail': '배달 앱(우버이츠 등)으로 점심 도시락 주문하고 비대면 문 앞 수령'},
    {
      'category': 'IT·디지털',
      'detail': '재택근무(리모트 워크) 중 온라인 화상회의(줌) 음소거와 배경 흐림 매너',
    },
    {'category': 'IT·디지털', 'detail': '스마트워치로 수면 패턴과 일일 만보 걷기 달성 기록 확인'},
    {'category': 'IT·디지털', 'detail': '클라우드 드라이브 대용량 파일 공유 링크 전달과 다운로드 기한'},
    {'category': 'IT·디지털', 'detail': '전자책(이북) 단말기로 만화와 소설 읽기 및 글자 크기 조절'},
    {'category': 'IT·디지털', 'detail': 'SNS에 여행 사진을 올릴 때 개인정보와 위치 태그 유출 방지 주의'},
    {'category': 'IT·디지털', 'detail': '무선 이어폰의 노이즈 캔슬링 기능과 전철 내 주변 소음 차단'},

    // 2. 일상·생활 상식
    {'category': '일상·생활', 'detail': '비 오는 날 일본의 투명 비닐우산과 상점 앞 우산꽂이 잠금장치'},
    {'category': '일상·생활', 'detail': '일본 마트 저녁 시간대 타임세일과 할인 스티커(반값 도시락)'},
    {'category': '일상·생활', 'detail': '일본의 세밀한 쓰레기 분리수거 규칙과 타는 쓰레기/플라스틱 배출'},
    {'category': '일상·생활', 'detail': '동네 코인 런드리(24시 빨래방) 대형 건조기와 운동화 전용 세탁기'},
    {'category': '일상·생활', 'detail': '일본 가정의 욕조 목욕(오후로) 문화와 물 순환 보온 시스템'},
    {'category': '일상·생활', 'detail': '다이소와 세리아 등 100엔 숍의 아이디어 수납용품 쇼핑'},
    {'category': '일상·생활', 'detail': '환절기 감기 예방과 동네 약국(드러그스토어)에서 종합감기약 찾기'},
    {'category': '일상·생활', 'detail': '택배 부재중 연락표(후재표)의 QR코드로 저녁 시간대 재배달 신청'},
    {'category': '일상·생활', 'detail': '역 분실물 센터(이실물 센터)에 두고 내린 우산과 가방 찾기 절차'},
    {'category': '일상·생활', 'detail': '동네 구립 도서관 회원증 만들기 카드 발급과 대출 권수'},
    {'category': '일상·생활', 'detail': '일본의 지진 대비 비상 배낭 꾸리기(생수, 비상식량, 손전등 점검)'},
    {'category': '일상·생활', 'detail': '역 앞 유료 자전거 주차장(추린조) 정기권 등록과 방치 금지 구역'},
    {'category': '일상·생활', 'detail': '공과금(전기세·수도세) 지로용지 들고 편의점 계산대 바코드 납부'},
    {'category': '일상·생활', 'detail': '반려견 산책 시 배변 봉투와 물병 휴대 에티켓'},

    // 3. 교통·여행
    {'category': '교통·여행', 'detail': '스이카(Suica)/파스모 교통카드 스마트폰 등록과 개찰구 터치 통과'},
    {'category': '교통·여행', 'detail': '신칸센 탑승 전 역 플랫폼에서 에키벤(지역 특산 기차 도시락) 고르기'},
    {'category': '교통·여행', 'detail': '온천 료칸의 유카타 바르게 입는 법과 온천욕 매너'},
    {'category': '교통·여행', 'detail': '일본 택시의 자동문 열림과 뒷자리 안전벨트 에티켓'},
    {'category': '교통·여행', 'detail': '교토 청수사(키요미즈데라) 골목길 산책과 기념품(야츠하시) 시식'},
    {'category': '교통·여행', 'detail': '하네다/나리타 공항 전망대에서 비행기 이착륙 구경하기'},
    {'category': '교통·여행', 'detail': '일본 전철의 여성 전용 차량과 우선석 매너 모드 규칙'},
    {'category': '교통·여행', 'detail': '도쿄 지하철 환승 노선도 확인과 각역정차와 급행 전철 구분'},
    {'category': '교통·여행', 'detail': '지방 소도시 노면전차(친친덴샤) 뒷문 승차 및 정리권 뽑기'},
    {'category': '교통·여행', 'detail': '일본 렌터카 여행 시 좌측통행 운전 주의점과 내비게이션 맵코드'},
    {'category': '교통·여행', 'detail': '신칸센 자유석과 지정석의 차이 및 대형 수하물 사전 예약 룰'},
    {'category': '교통·여행', 'detail': '가마쿠라 에노덴 전철을 타고 바다가 보이는 건널목 건너기'},

    // 4. 음식·미식·외식
    {'category': '음식·미식', 'detail': '라멘 전문점 입구의 식권 발매기(자판기) 주문법과 면 삶기 취향'},
    {'category': '음식·미식', 'detail': '퇴근길 이자카야의 오토오시(기본 안주)와 나마비루 건배'},
    {'category': '음식·미식', 'detail': '회전초밥집에서 터치패널 주문과 레일 위 접시 집기'},
    {'category': '음식·미식', 'detail': '여름 축제의 시원한 빙수(카키고오리)와 타코야키 만들기 파티'},
    {'category': '음식·미식', 'detail': '겨울철 따뜻한 나베 요리와 다 먹은 국물에 죽(조스이) 끓여 먹기'},
    {'category': '음식·미식', 'detail': '일본 전통 찻집에서 말차와 계절 화과자(와가시) 맛보기'},
    {'category': '음식·미식', 'detail': '일본의 편의점(콘비니) 계절 한정 디저트와 즉석 커피 머신'},
    {'category': '음식·미식', 'detail': '레트로 킷사텐(전통 다방)의 모닝 세트(토스트, 삶은 계란, 커피)'},
    {'category': '음식·미식', 'detail': '소바(메밀국수) 다 먹은 뒤 따뜻한 소바유(면수)를 츠유에 타 마시기'},
    {'category': '음식·미식', 'detail': '돈카츠 전문점에서 양배추 샐러드와 밥 무료 리필(오카와리) 부탁하기'},
    {'category': '음식·미식', 'detail': '규동 체인점에서 츠유다쿠(국물 넉넉히) 옵션과 날계란 추가 주문'},
    {'category': '음식·미식', 'detail': '겨울 편의점 계산대 옆 오뎅 냄비에서 무(다이콘)와 계란 담기'},
    {'category': '음식·미식', 'detail': '동네 빵집에서 갓 구워 나온 멜론빵과 소금빵 트레이에 담기'},

    // 5. 문화·전통
    {'category': '문화·전통', 'detail': '새해 첫날 신사 참배(하츠모우데)와 오미쿠지(운세 뽑기)'},
    {'category': '문화·전통', 'detail': '여름 마츠리의 불꽃놀이(하나비)와 킨교스쿠이(금붕어 건지기)'},
    {'category': '문화·전통', 'detail': '봄 벚꽃놀이(하나미) 명당 돗자리 잡기와 피크닉 도시락'},
    {'category': '문화·전통', 'detail': '칠석(타나바타) 대나무에 소원을 적은 단자쿠 종이 매달기'},
    {'category': '문화·전통', 'detail': '일본의 개인 도장(인감) 문화와 전자결재 시스템의 변화'},
    {'category': '문화·전통', 'detail': '일본 신사의 테미즈야에서 손과 입을 정화하는 전통 순서'},
    {'category': '문화·전통', 'detail': '가을 단풍(모미지가리) 명소 야간 라이트업 구경과 산책'},
    {'category': '문화·전통', 'detail': '입춘 전날 세츠분에 악귀를 쫓는 콩 던지기와 에호마키 김밥 먹기'},
    {'category': '문화·전통', 'detail': '성인식(세이진시키) 날 화려한 후리소데 기모노 차림의 청년들'},
    {'category': '문화·전통', 'detail': '정월 카가미모치(찰떡)를 쪼개어 단팥죽(젠자이) 끓여 먹는 풍습'},

    // 6. 취미·엔터테인먼트
    {'category': '취미·엔터', 'detail': '아키하바라 피규어 샵과 가챠폰(캡슐 토이) 뽑기 머신 돌리기'},
    {'category': '취미·엔터', 'detail': '진보초 고서점 거리에서 오래된 만화책과 문학작품 찾기'},
    {'category': '취미·엔터', 'detail': '일본 영화관에서 조용히 엔딩 크레딧 끝까지 감상하기'},
    {'category': '취미·엔터', 'detail': '고양이 카페나 시바견 카페에서 음료 마시며 힐링하기'},
    {'category': '취미·엔터', 'detail': '가라오케(노래방) 기계의 정밀 채점 모드와 무제한 음료 바(드링크바)'},
    {'category': '취미·엔터', 'detail': '오락실(게임센터)의 크레인 인형 뽑기 기계 각도 공략'},
    {'category': '취미·엔터', 'detail': '주말 시립 미술관 기획전에서 음성 오디오 가이드 빌려 감상하기'},

    // 7. 쇼핑·서비스
    {'category': '쇼핑·서비스', 'detail': '드러그스토어 면세(Tax-Free) 카운터에서 여권 제시하고 결제하기'},
    {'category': '쇼핑·서비스', 'detail': '안경점에서 시력 측정하고 블루라이트 차단 렌즈 맞추기'},
    {'category': '쇼핑·서비스', 'detail': '옷가게 피팅룸 이용 시 신발 벗기와 페이스 커버 착용 예절'},
    {'category': '쇼핑·서비스', 'detail': '무인양품(MUJI)에서 심플한 인테리어 수납함과 문구류 고르기'},
    {'category': '쇼핑·서비스', 'detail': '대형 서점에서 잡지 부록 구경과 베스트셀러 신간 코너 둘러보기'},
    {'category': '쇼핑·서비스', 'detail': '백화점 지하 식품관(데파치카) 폐점 30분 전 마감 세일 쇼핑'},
    {'category': '쇼핑·서비스', 'detail': '가전양판점에서 포인트 카드 적립과 최신 가전제품 성능 비교'},

    // 8. 직장·캠퍼스·사회
    {'category': '직장·캠퍼스', 'detail': '일본 회사의 이메일 서두 인사말(お世話になっております) 작성법'},
    {'category': '직장·캠퍼스', 'detail': '첫 비즈니스 미팅에서 두 손으로 명함 교환하기와 보관 매너'},
    {'category': '직장·캠퍼스', 'detail': '출장이나 여행 후 직장 동료들에게 오미야게(선물 과자) 나누기'},
    {'category': '직장·캠퍼스', 'detail': '엘리베이터와 회의실의 상석(카미자)과 하석(시모자) 위치 예절'},
    {'category': '직장·캠퍼스', 'detail': '대학 도서관에서 과제 리포트 자료 조사와 참고문헌 찾기'},
    {'category': '직장·캠퍼스', 'detail': '취업 준비(슈카츠) 정장 차림과 회사 설명회 참가'},
    {'category': '직장·캠퍼스', 'detail': '동아리 신입생 환영회와 부실 청소 당번 정하기'},
    {'category': '직장·캠퍼스', 'detail': '직장 선배에게 업무 진행 상황을 중간 보고(호렌소)하는 방법'},
    {'category': '직장·캠퍼스', 'detail': '아르바이트 첫 출근날 근무 스케줄(시프트표) 확인과 인사하기'},
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

    final isEn = LocaleService.currentLocale.value.languageCode == 'en';
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
    if (isEn) {
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
    final candidateKeys = keys.take(2).toList();

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
