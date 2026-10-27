# -*- coding: utf-8 -*-
import json

data = json.load(open('assets/data/korean_words.json', encoding='utf-8'))
existing = {x['word'].strip() for x in data}

def check_words(word_list):
    dups = [w for w in word_list if w in existing]
    return dups

print(f"Total existing words in dataset: {len(existing)}")
