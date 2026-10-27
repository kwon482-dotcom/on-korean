# -*- coding: utf-8 -*-
import json
data = json.load(open('assets/data/korean_words.json', encoding='utf-8'))
existing = {x['word'].strip() for x in data}

repls = [
    '영수증 버려주세요', '영수증 주세요', '모바일 결제', '삼성페이 돼요', '애플페이 돼요',
    '할인 쿠폰', '포인트 적립', '일회용품 줄이기', '개인 텀블러', '다회용기'
]
dups = [w for w in repls if w in existing]
print("Dups in repls:", dups)
