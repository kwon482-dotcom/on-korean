# -*- coding: utf-8 -*-
import json

for filepath in ['assets/data/korean_words.json', 'assets/data/jlpt_words.json']:
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    assert len(data) == 3500, f'Expected 3500 words, got {len(data)} in {filepath}'
    words = [d['word'] for d in data]
    assert len(set(words)) == 3500, f'Duplicates found: {3500 - len(set(words))}'
    for i, d in enumerate(data, 1):
        expected_id = f'k{i:04d}'
        assert d['id'] == expected_id, f"Index {i} has id {d['id']}"
        required_fields = ['id', 'level', 'category', 'word', 'furigana', 'meaning', 'meaningEn', 'meaningJa', 'meaningKo', 'partOfSpeech', 'exampleKo', 'exampleEn', 'exampleJa']
        for rf in required_fields:
            val = d.get(rf)
            assert val and str(val).strip(), f"Item {i} ({d['word']}) has empty field {rf}"
    print(f'{filepath}: ALL 3,500 ENTRIES PERFECTLY VALIDATED!')
