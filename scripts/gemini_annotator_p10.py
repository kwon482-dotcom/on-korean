# -*- coding: utf-8 -*-
"""
Gemini Vocabulary Annotator for Phase 10 (5,000 -> 6,000 words).
Reads scripts/p10_candidate_map.json and generates:
  - scripts/data_p10_{category}_p{part}.py (50 words each)
  - scripts/data_p10_{category}.py (200 words each)
"""

import json
import os
import sys
import time
import urllib.request
import urllib.error
import re

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Simple standard Revised Romanization fallback
INITIALS = ['g', 'kk', 'n', 'd', 'tt', 'r', 'm', 'b', 'pp', 's', 'ss', '', 'j', 'jj', 'ch', 'k', 't', 'p', 'h']
MEDIALS = ['a', 'ae', 'ya', 'yae', 'eo', 'e', 'yeo', 'ye', 'o', 'wa', 'wae', 'oe', 'yo', 'u', 'wo', 'we', 'wi', 'yu', 'eu', 'ui', 'i']
FINALS = ['', 'k', 'k', 'ks', 'n', 'nj', 'nh', 't', 'l', 'lg', 'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'm', 'p', 'ps', 't', 't', 'ng', 't', 't', 'k', 't', 'p', 'h']

def romanize_korean_text(text):
    result = []
    for char in text:
        code = ord(char)
        if 0xAC00 <= code <= 0xD7A3:
            syl_idx = code - 0xAC00
            cho = syl_idx // (21 * 28)
            jung = (syl_idx % (21 * 28)) // 28
            jong = syl_idx % 28
            rom = INITIALS[cho] + MEDIALS[jung] + FINALS[jong]
            result.append(rom)
        elif char in ('-', ' ', '.', '/'):
            result.append(char)
        elif char.isalnum():
            result.append(char.lower())
    return "-".join(r for r in result if r)

def clean_furigana(furigana, word):
    if not furigana or re.search(r'[\uac00-\ud7a3]', furigana):
        # Auto-romanize if missing or contains Hangul
        furigana = romanize_korean_text(word)
    # clean multiple hyphens
    furigana = re.sub(r'-+', '-', furigana).strip('-')
    return furigana

CANDIDATE_MAP_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "p10_candidate_map.json")
KEY_FILE = "c:/src/gemini_api_key.txt"
MODELS = ["gemini-3.5-flash-lite", "gemini-2.5-flash-lite", "gemini-3.1-flash-lite"]

def load_api_keys():
    if not os.path.exists(KEY_FILE):
        raise FileNotFoundError(f"Key file not found: {KEY_FILE}")
    with open(KEY_FILE, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()
    keys = [l.strip() for l in lines if l.strip().startswith("AQ.") or l.strip().startswith("AI")]
    if not keys:
        raise ValueError("No valid API keys found in file!")
    print(f"[AUTH] Loaded {len(keys)} Gemini API keys.")
    return keys

class GeminiClient:
    def __init__(self, keys):
        self.keys = keys
        self.key_idx = 0

    def get_next_key(self):
        k = self.keys[self.key_idx]
        self.key_idx = (self.key_idx + 1) % len(self.keys)
        return k

    def call_gemini(self, prompt, retries=5):
        for attempt in range(retries):
            key = self.get_next_key()
            for model in MODELS:
                url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={key}"
                payload = {
                    "contents": [{"parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "temperature": 0.2,
                        "responseMimeType": "application/json"
                    }
                }
                data = json.dumps(payload).encode("utf-8")
                req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
                try:
                    with urllib.request.urlopen(req, timeout=30) as res:
                        body = json.loads(res.read().decode("utf-8"))
                        text = body["candidates"][0]["content"]["parts"][0]["text"]
                        return text
                except urllib.error.HTTPError as e:
                    err_body = e.read().decode("utf-8", errors="ignore")
                    if e.code in (429, 503):
                        print(f"[{model} Key {self.key_idx}] Rate limited ({e.code}). Backing off... Attempt {attempt+1}/{retries}")
                        time.sleep(2 * (attempt + 1))
                        break
                    else:
                        print(f"[{model} Key {self.key_idx}] HTTP Error {e.code}: {err_body[:200]}")
                        time.sleep(1)
                        continue
                except Exception as e:
                    print(f"[{model} Key {self.key_idx}] Network/Timeout: {e}")
                    time.sleep(2)
                    continue
        raise RuntimeError("Exhausted all retries and keys for prompt!")

def safe_json_parse(raw_json):
    # Try direct parse
    try:
        return json.loads(raw_json, strict=False)
    except Exception:
        pass
    
    # Strip markdown fences
    cleaned = re.sub(r"^```(?:json)?\s*", "", raw_json.strip())
    cleaned = re.sub(r"\s*```$", "", cleaned)
    try:
        return json.loads(cleaned, strict=False)
    except Exception:
        pass

    # Fix invalid escape sequences like \' or unescaped backslashes
    cleaned = re.sub(r"\\'", "'", cleaned)
    cleaned = re.sub(r'\\([^"\\/bfnrtu])', r'\1', cleaned)
    return json.loads(cleaned, strict=False)

def annotate_batch(client, words_chunk, category_name, max_retries=3):
    prompt = f"""You are a professional lexicographer specializing in Korean language education for global learners.
Annotate the following {len(words_chunk)} Korean words/phrases for Category: '{category_name}'.

Words to annotate:
{json.dumps(words_chunk, ensure_ascii=False)}

For EACH word, produce a JSON object with EXACTLY these 9 keys:
1. "word": string (must match the provided word exactly)
2. "furigana": string (romanized pronunciation guide with hyphens between syllables, e.g., 'chung-chi-chi-ryo'. Pure English romanization ONLY, NEVER contain any Korean Hangul characters)
3. "meaningEn": string (natural, concise English translation)
4. "meaningJa": string (natural, concise Japanese translation in kanji/kana)
5. "meaningKo": string (clear, simple Korean definition in easy Korean)
6. "partOfSpeech": string (one of: '명사', '동사', '형용사', '부사', '관용구', '속담', '감탄사')
7. "exampleKo": string (natural, authentic conversational or practical example sentence in Korean featuring the word)
8. "exampleEn": string (accurate English translation of the exampleKo sentence)
9. "exampleJa": string (accurate Japanese translation of the exampleKo sentence)

CRITICAL RULES:
- Output a strict JSON array of objects.
- Do NOT use unescaped double quotes inside string values; use single quotes (') instead.
- Do NOT use invalid escape sequences like \\'.
- Every word in the input list must appear in order.
"""
    for attempt in range(max_retries):
        raw_json = client.call_gemini(prompt)
        try:
            items = safe_json_parse(raw_json)
            # Normalize to map by word
            item_map = {}
            for item in items:
                w = item.get("word", "").strip()
                if w:
                    item_map[w] = item

            results = []
            for w in words_chunk:
                if w in item_map:
                    it = item_map[w]
                else:
                    found = False
                    for k, val in item_map.items():
                        if k.replace(" ", "") == w.replace(" ", ""):
                            it = val
                            found = True
                            break
                    if not found:
                        raise ValueError(f"Missing annotation for word '{w}'")

                furigana = it.get("furigana", "").strip()
                furigana = clean_furigana(furigana, w)
                meaningEn = it.get("meaningEn", "").strip().replace('"', "'")
                meaningJa = it.get("meaningJa", "").strip().replace('"', "'")
                meaningKo = it.get("meaningKo", "").strip().replace('"', "'")
                pos = it.get("partOfSpeech", "명사").strip()
                exampleKo = it.get("exampleKo", "").strip().replace('"', "'")
                exampleEn = it.get("exampleEn", "").strip().replace('"', "'")
                exampleJa = it.get("exampleJa", "").strip().replace('"', "'")

                # Basic validations
                assert furigana and furigana != w, f"Invalid furigana for '{w}': {furigana}"
                assert not re.search(r'[\uac00-\ud7a3]', furigana), f"Hangul in furigana for '{w}': {furigana}"
                assert meaningEn, f"Empty meaningEn for '{w}'"
                assert meaningJa, f"Empty meaningJa for '{w}'"
                assert meaningKo, f"Empty meaningKo for '{w}'"
                assert exampleKo, f"Empty exampleKo for '{w}'"
                assert exampleEn, f"Empty exampleEn for '{w}'"
                assert exampleJa, f"Empty exampleJa for '{w}'"

                results.append((w, furigana, meaningEn, meaningJa, meaningKo, pos, exampleKo, exampleEn, exampleJa))
            return results
        except Exception as e:
            print(f"[RETRY BATCH] Attempt {attempt+1}/{max_retries} failed with {type(e).__name__}: {e}")
            time.sleep(2)

    raise RuntimeError(f"Failed to annotate chunk after {max_retries} attempts: {words_chunk}")

def write_part_file(category, part, word_tuples):
    cat_upper = category.upper()
    filename = f"data_p10_{category}_p{part}.py"
    filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)
    
    lines = [
        "# -*- coding: utf-8 -*-",
        f'"""',
        f'Phase 10: {category.capitalize()} Part {part} (50 words)',
        f'"""',
        "",
        f"P10_{cat_upper}_WORDS_P{part} = ["
    ]
    for tup in word_tuples:
        escaped_tup = tuple(s.replace('"', '\\"') if isinstance(s, str) else s for s in tup)
        # format as ("w", "f", "en", "ja", "ko", "pos", "eko", "een", "eja"),
        items_str = ", ".join(f'"{s}"' for s in escaped_tup)
        lines.append(f"    ({items_str}),")
    lines.append("]")
    lines.append("")

    with open(filepath, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"[SAVED] {filepath} ({len(word_tuples)} words)")

def write_category_combined_file(category):
    cat_upper = category.upper()
    filename = f"data_p10_{category}.py"
    filepath = os.path.join(os.path.dirname(os.path.abspath(__file__)), filename)

    content = f"""# -*- coding: utf-8 -*-
\"\"\"
Phase 10: {category.capitalize()} (200 words)
\"\"\"
try:
    from scripts.data_p10_{category}_p1 import P10_{cat_upper}_WORDS_P1
    from scripts.data_p10_{category}_p2 import P10_{cat_upper}_WORDS_P2
    from scripts.data_p10_{category}_p3 import P10_{cat_upper}_WORDS_P3
    from scripts.data_p10_{category}_p4 import P10_{cat_upper}_WORDS_P4
except ImportError:
    from data_p10_{category}_p1 import P10_{cat_upper}_WORDS_P1
    from data_p10_{category}_p2 import P10_{cat_upper}_WORDS_P2
    from data_p10_{category}_p3 import P10_{cat_upper}_WORDS_P3
    from data_p10_{category}_p4 import P10_{cat_upper}_WORDS_P4

P10_{cat_upper}_WORDS = P10_{cat_upper}_WORDS_P1 + P10_{cat_upper}_WORDS_P2 + P10_{cat_upper}_WORDS_P3 + P10_{cat_upper}_WORDS_P4
"""
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"[COMBINED] {filepath}")

def process_category(client, cand_map, category, target_part=None):
    cat_names = {
        "basics": "한글 기초 & 생존 회화",
        "topik1": "TOPIK I 초급 필수 어휘",
        "topik2": "TOPIK II 중급 핵심 어휘",
        "kdrama": "K-드라마 & 실전 리얼 회화",
        "business": "비즈니스 & 시사 고급 한국어"
    }
    cat_desc = cat_names.get(category, category)
    parts_to_run = [target_part] if target_part else [1, 2, 3, 4]

    for part in parts_to_run:
        part_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), f"data_p10_{category}_p{part}.py")
        if os.path.exists(part_file):
            print(f"[SKIP] {part_file} already exists.")
            continue

        raw_words = cand_map[category][str(part)]
        assert len(raw_words) == 50, f"Expected 50 words for {category} part {part}, got {len(raw_words)}"

        print(f"\n=== Processing {category} Part {part} (50 words) ===")
        all_part_tuples = []
        # Process in chunks of 10
        chunk_size = 10
        for i in range(0, len(raw_words), chunk_size):
            chunk = raw_words[i:i+chunk_size]
            print(f"Annotating words {i+1}..{i+len(chunk)}: {chunk}")
            tuples = annotate_batch(client, chunk, cat_desc)
            all_part_tuples.extend(tuples)
            time.sleep(1)  # small friendly delay

        assert len(all_part_tuples) == 50
        write_part_file(category, part, all_part_tuples)

    # If all 4 parts exist, generate combined file
    all_exist = all(os.path.exists(os.path.join(os.path.dirname(os.path.abspath(__file__)), f"data_p10_{category}_p{p}.py")) for p in [1, 2, 3, 4])
    if all_exist:
        write_category_combined_file(category)

def main():
    keys = load_api_keys()
    client = GeminiClient(keys)

    with open(CANDIDATE_MAP_FILE, "r", encoding="utf-8") as f:
        cand_map = json.load(f)

    target_cat = sys.argv[1] if len(sys.argv) > 1 else None
    target_part = int(sys.argv[2]) if len(sys.argv) > 2 else None

    categories = [target_cat] if target_cat else ["basics", "topik1", "topik2", "kdrama", "business"]

    for cat in categories:
        process_category(client, cand_map, cat, target_part)

    print("\n[ALL COMPLETE] Phase 10 Annotation Finished.")

if __name__ == "__main__":
    main()
