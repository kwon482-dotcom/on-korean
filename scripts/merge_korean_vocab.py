# -*- coding: utf-8 -*-
"""Merge all Korean vocabulary datasets, deduplicate, validate, and write JSON files."""

import json
import os
import sys

# Add scripts directory to sys.path
script_dir = os.path.dirname(os.path.abspath(__file__))
project_dir = os.path.dirname(script_dir)
sys.path.insert(0, script_dir)

from data_basics import BASICS_WORDS
from data_basics_2 import BASICS_WORDS_2
from data_topik1 import TOPIK1_WORDS
from data_topik1_2 import TOPIK1_WORDS_2
from data_topik1_3 import TOPIK1_WORDS_3
from data_topik2 import TOPIK2_WORDS
from data_topik2_2 import TOPIK2_WORDS_2
from data_topik2_3 import TOPIK2_WORDS_3
from data_kdrama import KDRAMA_WORDS
from data_kdrama_2 import KDRAMA_WORDS_2
from data_kdrama_3 import KDRAMA_WORDS_3
from data_kdrama_4 import KDRAMA_WORDS_4
from data_business import BUSINESS_WORDS
from data_business_2 import BUSINESS_WORDS_2
from data_final_touch import FINAL_TOUCH_WORDS

def main():
    existing_file = os.path.join(project_dir, "assets", "data", "korean_words.json")
    seen_words = set()
    result = []

    # Read base starter words
    if os.path.exists(existing_file):
        with open(existing_file, "r", encoding="utf-8") as f:
            existing_words = json.load(f)
            for w in existing_words:
                result.append(w)
                seen_words.add(w["word"].strip())

    categories_map = [
        ("한글 기초 & 생존 회화", BASICS_WORDS + BASICS_WORDS_2 + FINAL_TOUCH_WORDS[:10]),
        ("TOPIK I 초급 필수 어휘", TOPIK1_WORDS + TOPIK1_WORDS_2 + TOPIK1_WORDS_3 + FINAL_TOUCH_WORDS[10:18]),
        ("TOPIK II 중급 핵심 어휘", TOPIK2_WORDS + TOPIK2_WORDS_2 + TOPIK2_WORDS_3 + FINAL_TOUCH_WORDS[18:]),
        ("K-드라마 & 실전 리얼 회화", KDRAMA_WORDS + KDRAMA_WORDS_2 + KDRAMA_WORDS_3 + KDRAMA_WORDS_4),
        ("비즈니스 & 시사 고급 한국어", BUSINESS_WORDS + BUSINESS_WORDS_2),
    ]

    added_count = 0
    for cat_name, word_list in categories_map:
        for item in word_list:
            word = item[0].strip()
            if word in seen_words:
                continue
            seen_words.add(word)

            entry = {
                "id": f"k{len(result) + 1:04d}",
                "level": cat_name,
                "category": cat_name,
                "word": word,
                "furigana": item[1],
                "meaning": item[2],
                "meaningEn": item[2],
                "meaningJa": item[3],
                "meaningKo": item[4],
                "partOfSpeech": item[5],
                "exampleKo": item[6],
                "exampleEn": item[7],
                "exampleJa": item[8]
            }
            result.append(entry)
            added_count += 1

    # Re-index all IDs k0001 to kNNNN sequentially
    for i, item in enumerate(result, 1):
        item["id"] = f"k{i:04d}"

    print(f"Total merged words: {len(result)} (Newly Added: {added_count})")

    cat_counts = {}
    for item in result:
        cat_counts[item["category"]] = cat_counts.get(item["category"], 0) + 1

    for cat, count in cat_counts.items():
        print(f"  - {cat}: {count} words")

    # Save to assets/data/korean_words.json
    out_file = os.path.join(project_dir, "assets", "data", "korean_words.json")
    with open(out_file, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print(f"Successfully wrote {out_file}")

    # Save to assets/data/jlpt_words.json (sync/fallback for tests)
    out_file2 = os.path.join(project_dir, "assets", "data", "jlpt_words.json")
    with open(out_file2, "w", encoding="utf-8") as f:
        json.dump(result, f, ensure_ascii=False, indent=2)
    print(f"Successfully wrote {out_file2}")

if __name__ == "__main__":
    main()
