# 📚 작심삼일본어 (on-vocab) 코드 진단, AI 보안 및 다국어 확장 로드맵

> **문서 목적**: 온보카(작심삼일본어)의 비공개 테스트 이후 상용 릴리즈와, 이를 뼈대로 삼아 '한국어 마스터 앱', '영어 마스터 앱'으로 확장하는 **[목표 언어 기반 앱 팩토리 파이프라인]**을 구축하기 위한 가이드입니다.

---

## 📌 1. 프로젝트 현황 요약
* **패키지명**: `com.kwon.onvocab`
* **현재 버전**: `1.3.1+10` (비공개 테스트 진행 중)
* **핵심 스택**: Flutter, `FlutterTts`, `FirebaseRemoteConfig`, Google Gemini API, Shared Preferences, AdMob (Banner + Rewarded)
* **특이사항**: 1,213개 JLPT N5~N1/비즈니스/테마 단어 DB, Gemini 실시간 예문 생성, 에너지 충전 BM 루프

---

## 🚨 2. 긴급 코드 진단 및 보안 조치 (Audit & Checklist)

### [CRITICAL] 1. Gemini API 키 클라이언트 하드코딩 및 쿼터 고갈 방지
* **위치**: `lib/services/remote_config_service.dart` (line 7~8), `lib/services/ai_service.dart`
* **문제점**:
  * `_defaultApiKey` 문자열이 소스코드에 하드코딩되어 있습니다. 만약 깃허브가 Public으로 전환되거나 APK가 디컴파일되면 Google 자동 시크릿 스캐너에 의해 키가 즉시 폐기(Revoke)되거나 악의적 대량 호출로 무료 쿼터(15 RPM)가 마비됩니다.
* **검증 체크리스트**:
  - [ ] **기본 키 하드코딩 제거**: 빈 문자열로 변경하고, 오직 Firebase Remote Config를 통해서만 가져오도록 강제.
  - [ ] **AI 생성 예문 로컬 영구 캐싱 (비용 절감 필수)**: 생성된 예문을 단어 모델에 영구 저장하여, 동일한 단어는 다시 Gemini API를 호출하지 않도록 방어.
* **해결 코드 (AI 예문 캐싱)**:
  ```dart
  // 예문 생성 후 로컬 SharedPreferences / DB에 즉시 영구 보관
  static Future<void> cacheGeneratedExample(String wordId, String ja, String ko) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_example_ja_$wordId', ja);
    await prefs.setString('ai_example_ko_$wordId', ko);
  }

  // 예문 불러오기 시 캐시 우선 확인
  static Map<String, String>? getCachedExample(String wordId, SharedPreferences prefs) {
    final ja = prefs.getString('ai_example_ja_$wordId');
    final ko = prefs.getString('ai_example_ko_$wordId');
    if (ja != null && ko != null) {
      return {'ja': ja, 'ko': ko};
    }
    return null;
  }
  ```

---

### [ENHANCEMENT] 2. 망각곡선 기반 간격 반복(SRS) 학습 알고리즘 도입
* **위치**: `lib/services/word_service.dart`, `lib/screens/study_screen.dart`
* **문제점**:
  * 현재는 '알아요/몰라요' 상태가 단순 플래그(`isMastered`, `isWrong`)로만 저장됩니다.
* **개선안**:
  * '몰라요'를 누른 단어는 1일 뒤, 3일 뒤, 7일 뒤 복습 주기로 스케줄링하여 복습 큐에 자동 배치 (학습 지속률 및 리텐션 대폭 향상).

---

## 🌐 3. [핵심 전략] 목표 언어(Target Language) 기준 3대 어학 앱 확장

### 전략 개요: "목표 언어 1개당 1개 앱 + 모국어 다국어화"
* 유저 검색 행동은 **"배우고 싶은 목표 언어"**로 수렴합니다.
* 앱 내에서 모든 언어를 다 배우게 하는 것이 아니라, **하나의 목표 언어에 집중하되 사용자의 모국어(한국어, 영어, 일본어)를 지원**하는 구조가 ASO와 수익 면에서 가장 우수합니다.

```
[On-Vocab 기반 3대 어학 생태계]
  │
  ├── 1. [일본어 앱] 작심삼일본어 (현재 앱)
  │      └── 목표 언어: 일본어 (JLPT, 비즈니스, 여행)
  │      └── 지원 모국어: 한국어 (한>일) + 영어 (영>일)
  │      └── 글로벌 스토어: 미국/동남아 등 전 세계 일본어 학습자 흡수
  │
  ├── 2. [한국어 앱] 3日韓国語 / 3-Day Korean (차기작 1순위)
  │      └── 목표 언어: 한국어 (TOPIK, K-POP, 드라마 실전 회화)
  │      └── 지원 모국어: 일본어 (일>한) + 영어 (영>한)
  │      └── 타겟: 일본 10~40대 한류 팬 및 글로벌 한국어 학습자 (eCPM 극상)
  │
  └── 3. [영어 앱] 瞬簡英単語 / 3-Day English (차기작 2순위)
         └── 목표 언어: 영어 (TOEIC, 비즈니스 실무)
         └── 지원 모국어: 한국어 (한>영) + 일본어 (일>영)
         └── 타겟: 한국 & 일본 양국 토익/취업 수험생 (아시아 최대 시장)
```

### 데이터 모델 확장 설계:
```dart
class WordModel {
  final String id;
  final String word;           // 목표 단어 (예: 食べる / 안녕하세요 / collaborate)
  final String? phonetic;      // 발음/후리가나 (たべる / an-nyeong... / kəˈlæb.ə.reɪt)
  final String meaningKo;      // 한국어 뜻
  final String meaningEn;      // 영어 뜻
  final String meaningJa;      // 일본어 뜻 (한국어/영어 앱의 경우)
  final String exampleTarget;  // 목표 언어 예문
  final String exampleKo;      // 예문 한국어 번역
  final String exampleEn;      // 예문 영어 번역
  final String exampleJa;      // 예문 일본어 번역
}
```

---

## 🗺️ 4. 향후 릴리즈 로드맵

### 릴리즈 v1.3.2 (비공개 테스트 통과 및 보안 패치)
1. **Gemini API 예문 로컬 영구 캐싱 적용**.
2. **비공개 테스트 20인 피드백 반영 (버그 픽스 및 UI 튜닝)**.
3. **프로덕션 정식 출시 신청**.

### 릴리즈 v1.4.0 (영>일 글로벌 스토어 확장)
1. **영어 뜻/영어 예문 필드 추가 (`meaningEn`, `exampleEn`)**.
2. **구글 플레이 콘솔 [스토어 등록정보 현지화] 추가**:
   * 미국/글로벌 스토어 명칭: `3-Day Japanese: JLPT & Words` 등록.
   * 글로벌 유저 유입으로 AdMob eCPM 수익 다각화.

### 릴리즈 v2.0.0 (차기작 '한국어 마스터 앱' 팩토리 가동)
1. **동일 코드베이스 포크 ➔ 한국어 단어 800개 데이터셋 배치**.
2. **일본어/영어 뜻 제공 ➔ 일본 플레이 스토어 집중 런칭**.
