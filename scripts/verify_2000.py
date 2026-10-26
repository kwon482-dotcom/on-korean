# -*- coding: utf-8 -*-
import json
import sys

def verify():
    with open('assets/data/korean_words.json', 'r', encoding='utf-8') as f:
        korean = json.load(f)
    with open('assets/data/jlpt_words.json', 'r', encoding='utf-8') as f:
        jlpt = json.load(f)

    print(f"[1/6] Total items in korean_words.json: {len(korean)}")
    print(f"[2/6] Total items in jlpt_words.json: {len(jlpt)}")
    assert len(korean) == 2000, f"Expected 2000, got {len(korean)}"
    assert len(jlpt) == 2000, f"Expected 2000 in jlpt, got {len(jlpt)}"

    # Check ID sequence
    print("[3/6] Verifying ID sequence k0001 to k2000...")
    for idx, item in enumerate(korean, 1):
        expected_id = f"k{idx:04d}"
        assert item["id"] == expected_id, f"Item {idx} has ID {item['id']}, expected {expected_id}"
        assert jlpt[idx-1]["id"] == expected_id, f"JLPT item {idx} mismatch"

    # Check duplicates
    print("[4/6] Checking duplicates...")
    words = [x["word"].strip() for x in korean]
    dups = [w for w in set(words) if words.count(w) > 1]
    assert len(dups) == 0, f"Duplicates found: {dups}"

    # Check required fields
    print("[5/6] Validating all 9 fields across all 2,000 entries...")
    required_fields = [
        "word", "furigana", "meaningEn", "meaningJa", "meaningKo",
        "partOfSpeech", "exampleKo", "exampleEn", "exampleJa"
    ]
    for idx, item in enumerate(korean, 1):
        for field in required_fields:
            val = item.get(field, "")
            assert val and isinstance(val, str) and len(val.strip()) > 0, f"Missing or empty {field} in item {idx} ({item['word']})"

    # Category counts
    print("[6/6] Checking category distribution...")
    cat_counts = {}
    for item in korean:
        cat_counts[item["category"]] = cat_counts.get(item["category"], 0) + 1
    
    expected_cats = {
        "한글 기초 & 생존 회화": 420,
        "TOPIK I 초급 필수 어휘": 420,
        "TOPIK II 중급 핵심 어휘": 400,
        "K-드라마 & 실전 리얼 회화": 390,
        "비즈니스 & 시사 고급 한국어": 370
    }
    for cat, exp in expected_cats.items():
        actual = cat_counts.get(cat, 0)
        assert actual == exp, f"Category '{cat}' expected {exp}, got {actual}"
        print(f"  - {cat}: {actual} words (OK)")

    print("\nALL VERIFICATIONS PASSED 100%! EXACTLY 2,000 HIGH-QUALITY KOREAN WORDS REACHED!")

if __name__ == "__main__":
    verify()
