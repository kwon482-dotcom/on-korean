# -*- coding: utf-8 -*-
import json
import sys

def verify():
    with open('assets/data/korean_words.json', 'r', encoding='utf-8') as f:
        korean = json.load(f)
    with open('assets/data/jlpt_words.json', 'r', encoding='utf-8') as f:
        jlpt = json.load(f)

    print(f"[1/5] Total items in korean_words.json: {len(korean)}")
    print(f"[2/5] Total items in jlpt_words.json: {len(jlpt)}")
    assert len(korean) == 1900, f"Expected 1900, got {len(korean)}"
    assert len(jlpt) == 1900, f"Expected 1900 in jlpt, got {len(jlpt)}"

    # Check ID sequence
    print("[3/5] Verifying ID sequence k0001 to k1900...")
    for idx, item in enumerate(korean, 1):
        expected_id = f"k{idx:04d}"
        assert item["id"] == expected_id, f"Item {idx} has ID {item['id']}, expected {expected_id}"
        assert jlpt[idx-1]["id"] == expected_id, f"JLPT item {idx} mismatch"

    # Check duplicates
    print("[4/5] Checking duplicates...")
    words = [x["word"].strip() for x in korean]
    dups = [w for w in set(words) if words.count(w) > 1]
    assert len(dups) == 0, f"Duplicates found: {dups}"

    # Check required fields
    print("[5/5] Validating all 9 fields...")
    required_fields = [
        "word", "furigana", "meaningEn", "meaningJa", "meaningKo",
        "partOfSpeech", "exampleKo", "exampleEn", "exampleJa"
    ]
    for idx, item in enumerate(korean, 1):
        for field in required_fields:
            val = item.get(field, "")
            assert val and isinstance(val, str) and len(val.strip()) > 0, f"Missing or empty {field} in item {idx} ({item['word']})"

    print("\nALL VERIFICATIONS PASSED 100%! EXACTLY 1,900 HIGH-QUALITY KOREAN WORDS.")

if __name__ == "__main__":
    verify()
