# -*- coding: utf-8 -*-
"""Subcategorize 7,000 words into 20 thematic decks across 5 major courses."""
import json
import os

project_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
korean_json = os.path.join(project_dir, 'assets', 'data', 'korean_words.json')
jlpt_json = os.path.join(project_dir, 'assets', 'data', 'jlpt_words.json')

sub_map = {
    '한글 기초 & 생존 회화': [
        ('자음·모음 & 필수 첫걸음', 355),
        ('숫자·시간·날짜 & 생활 기초', 355),
        ('일상 필수 동사 & 형용사', 355),
        ('생존 생활 표현 & 여행 어휘', 355),
    ],
    'TOPIK I 초급 필수 어휘': [
        ('학교 생활 & 취미·여가', 355),
        ('쇼핑·시장 & 대중교통', 355),
        ('음식·식당 & 한국 음식', 355),
        ('날씨·계절 & 병원·약국', 355),
    ],
    'TOPIK II 중급 핵심 어휘': [
        ('감정·심리 & 성격·인간관계', 350),
        ('사회·문화 & 미디어·예술', 350),
        ('자연·환경 & 과학·기술', 350),
        ('TOPIK 필수 관용구 & 속담', 350),
    ],
    'K-드라마 & 실전 리얼 회화': [
        ('드라마 명대사 & 리얼 리액션', 347),
        ('신조어·줄임말 & 일상 구어체', 347),
        ('K-푸드 & 포장마차·한강 치맥', 348),
        ('K-POP·팬덤 & 엔터테인먼트', 348),
    ],
    '비즈니스 & 시사 고급 한국어': [
        ('오피스 실무 & 비즈니스 이메일', 342),
        ('회의·미팅 & 협상·프레젠테이션', 342),
        ('경제·경영 & 금융·투자', 343),
        ('시사·정치 & 학술·고급 토론', 343),
    ],
}

with open(korean_json, 'r', encoding='utf-8') as f:
    words = json.load(f)

by_cat = {}
for w in words:
    c = w['category']
    by_cat.setdefault(c, []).append(w)

result = []
for cat_name, sub_list in sub_map.items():
    cat_words = by_cat[cat_name]
    offset = 0
    for sub_title, count in sub_list:
        sub_words = cat_words[offset:offset + count]
        for item in sub_words:
            item['category'] = cat_name # 5대 대분류
            item['level'] = sub_title    # 20대 중분류 덱
            result.append(item)
        offset += count

# Re-index sequential IDs
for i, item in enumerate(result, 1):
    item['id'] = f'k{i:04d}'

print(f'Total re-categorized words: {len(result)}')
counts = {}
for item in result:
    c = item['category']
    l = item['level']
    counts[f'{c} -> {l}'] = counts.get(f'{c} -> {l}', 0) + 1

for k, v in counts.items():
    print(f'  {k}: {v} words')

with open(korean_json, 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=2)
print(f'Successfully updated {korean_json}')

with open(jlpt_json, 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=2)
print(f'Successfully updated {jlpt_json}')
