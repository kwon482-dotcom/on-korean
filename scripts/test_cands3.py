# -*- coding: utf-8 -*-
import json
data = json.load(open('assets/data/korean_words.json', encoding='utf-8'))
existing = {x['word'].strip() for x in data}

cands = [
    '몇 호선이에요', '급행열차', '일반열차', '막차 시간', '첫차 시간',
    '택시 승강장', '버스 전용 차로', '하차 벨', '기사님 세워주세요', '여기서 내려주세요',
    '트렁크 열어주세요', '네비게이션', '고속도로 통행료', '환전소', '환율이 얼마예요',
    '수수료가 얼마예요', '유심칩', '포켓 와이파이', '데이터 무제한', '데이터 로밍',
    '비행기 모드', '보조 배터리', '멀티 어댑터', '돼지코'
]
dups = [w for w in cands if w in existing]
with open('scripts/dup_output3.txt', 'w', encoding='utf-8') as f:
    f.write("Dups:\n" + "\n".join(dups) + "\n")
    unique = [w for w in cands if w not in existing]
    f.write(f"\nUnique ({len(unique)}):\n" + "\n".join(unique) + "\n")
