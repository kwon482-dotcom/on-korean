# -*- coding: utf-8 -*-
import json
data = json.load(open('assets/data/korean_words.json', encoding='utf-8'))
existing = {x['word'].strip() for x in data}

cands = [
    '어디에 있나요', '추천해 주세요', '계산해 주세요', '따로 계산해 주세요', '카드로 할게요',
    '현금 영수증', '봉투 필요하세요', '담아 주세요', '포장해 주세요', '여기서 먹을게요',
    '가져갈게요', '얼음 적게', '덜 맵게', '고수 빼주세요', '물 좀 더 주세요',
    '반찬 더 주세요', '휴지 있어요', '와이파이 비밀번호', '충전기 있어요', '화장실이 어디예요',
    '몇 시에 닫아요', '몇 시에 열어요', '브레이크 타임', '라스트 오더', '예약했어요',
    '몇 명이에요', '두 명이에요', '세 명이에요', '혼자 왔어요', '자리 있어요',
    '만석이에요', '대기 시간', '대기 명단', '이름 적어주세요', '순서가 되면',
    '호출 벨', '진동벨', '셀프 코너', '앞치마 주세요', '숟가락과 젓가락',
    '물티슈', '종이컵', '빨대', '냅킨', '메뉴판',
    '시그니처 메뉴', '인기 메뉴', '세트 메뉴', '단품', '추가 주문'
]

dups = [w for w in cands if w in existing]
with open('scripts/dup_output.txt', 'w', encoding='utf-8') as f:
    f.write("Dups:\n" + "\n".join(dups) + "\n")
    unique = [w for w in cands if w not in existing]
    f.write(f"\nUnique ({len(unique)}):\n" + "\n".join(unique) + "\n")
