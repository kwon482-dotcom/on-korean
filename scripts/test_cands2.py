# -*- coding: utf-8 -*-
import json
data = json.load(open('assets/data/korean_words.json', encoding='utf-8'))
existing = {x['word'].strip() for x in data}

cands = [
    '출구가 어디예요', '입구가 어디예요', '엘리베이터', '에스컬레이터', '계단',
    '비상구', '몇 번 출구', '환승역', '갈아타는 곳', '반대 방향',
    '방면', '종점', '이번 정류장', '다음 정류장', '내리실 문',
    '하차 태그', '승차 태그', '잔액 부족', '교통카드 충전기', '일회용 교통카드',
    '보증금 환급기', '분실물 센터', '물품 보관함', '코인 라커', '짐 보관',
    '무겁다', '가볍다', '두통약', '소화제', '감기약',
    '진통제', '밴드', '파스', '소독약', '안약',
    '마스크', '어지러워요', '속이 안 좋아요', '열이 나요', '목이 아파요',
    '배가 아파요', '콧물이 나요', '기침이 나요', '알레르기', '처방전',
    '식후 30분', '하루 세 번', '체크인', '체크아웃', '룸서비스'
]

dups = [w for w in cands if w in existing]
with open('scripts/dup_output2.txt', 'w', encoding='utf-8') as f:
    f.write("Dups:\n" + "\n".join(dups) + "\n")
    unique = [w for w in cands if w not in existing]
    f.write(f"\nUnique ({len(unique)}):\n" + "\n".join(unique) + "\n")
