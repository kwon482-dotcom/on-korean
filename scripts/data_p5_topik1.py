# -*- coding: utf-8 -*-
"""
Phase 5: TOPIK I 초급 필수 어휘 (Exactly 100 unique words, 0 duplicates)
"""

from scripts.data_p5_topik1_part1 import P5_TOPIK1_WORDS_PART1
from scripts.data_p5_topik1_part2 import P5_TOPIK1_WORDS_PART2

# Clean items from part 1 and part 2 (excluding existing collisions)
_EXCLUDE = {
    "분리수거", "보조배터리", "콘센트", "도마", "물병", "이쑤시개", "앞치마",
    "재활용품", "널다", "빗다", "비우다", "채우다", "붓다", "삶다", "볶다",
    "튀기다", "썰다", "깎다", "잠그다", "털다", "말리다", "갈아입다"
}

_CLEAN_PART1 = [w for w in P5_TOPIK1_WORDS_PART1 if w[0] not in _EXCLUDE]
_CLEAN_PART2 = [w for w in P5_TOPIK1_WORDS_PART2 if w[0] not in _EXCLUDE]

# 22 fresh replacements to reach exactly 100 words
_REPLACEMENTS = [
    (
        "손톱깎이",
        "son-top-kkak-i",
        "nail clippers",
        "爪切り (つめきり)",
        "손톱이나 발톱을 단정하게 깎는 작은 도구",
        "명사",
        "손톱이 길게 자라서 손톱깎이로 깔끔하게 깎았어요.",
        "My nails grew long, so I trimmed them neatly with nail clippers.",
        "爪が伸びたので爪切りできれいに切りました。"
    ),
    (
        "면봉",
        "myeon-bong",
        "cotton swab / Q-tip",
        "綿棒 (めんぼう)",
        "가느다란 막대 양끝에 솜을 뭉친 위생 용품",
        "명사",
        "귀에 들어간 물을 면봉으로 살살 닦아냈어요.",
        "I gently wiped out the water from my ear with a cotton swab.",
        "耳に入った水を綿棒で優しく拭き取りました。"
    ),
    (
        "화장솜",
        "hwa-jang-som",
        "cotton pad",
        "コットン / 化粧綿",
        "얼굴에 스킨을 바를 때 쓰는 부드러운 솜",
        "명사",
        "화장솜에 토너를 충분히 적셔 피부결을 정돈했어요.",
        "I soaked a cotton pad with toner to smooth my skin texture.",
        "コットンに化粧水をたっぷり染み込ませて肌のキメを整えました。"
    ),
    (
        "핸드크림",
        "haen-deu-keu-rim",
        "hand cream",
        "ハンドクリーム",
        "손 피부가 트지 않게 바르는 보습 크림",
        "명사",
        "손이 건조할 때마다 은은한 향의 핸드크림을 발라요.",
        "Whenever my hands feel dry, I apply subtle scented hand cream.",
        "手が乾燥するたびにほのかな香りのハンドクリームを塗ります。"
    ),
    (
        "립밤",
        "rip-bam",
        "lip balm",
        "リップクリーム / リップバーム",
        "입술이 트지 않도록 바르는 보습제",
        "명사",
        "겨울철에는 입술이 자주 터서 립밤을 챙겨 다녀요.",
        "My lips often get chapped in winter, so I carry a lip balm.",
        "冬場は唇がよく荒れるのでリップクリームを持ち歩いています。"
    ),
    (
        "선크림",
        "seon-keu-rim",
        "sunscreen / sun cream",
        "日焼け止め (ひやけどめ) / サンスクリーン",
        "자외선으로부터 피부를 보호하기 위해 바르는 크림",
        "명사",
        "외출하기 30분 전에 얼굴과 목에 선크림을 꼼꼼히 발랐어요.",
        "I carefully applied sunscreen to my face and neck 30 minutes before going out.",
        "外出する30分前に顔と首に日焼け止めを念入りに塗りました。"
    ),
    (
        "클렌징폼",
        "keul-len-jing-pom",
        "cleansing foam / facial cleanser",
        "洗顔フォーム (せんがんフォーム)",
        "얼굴의 노폐물과 화장을 지우는 거품 세안제",
        "명사",
        "외출 후 클렌징폼으로 얼굴을 깨끗이 씻었어요.",
        "After coming home, I washed my face cleanly with cleansing foam.",
        "帰宅後、洗顔フォームで顔を綺麗に洗いました。"
    ),
    (
        "샤워타월",
        "sya-wo-ta-weol",
        "shower towel / bath washcloth",
        "シャワータオル / ボディタオル",
        "몸을 씻을 때 거품을 내어 문지르는 긴 타월",
        "명사",
        "샤워타월에 바디워시를 묻혀 풍성한 거품을 냈어요.",
        "I put body wash on the shower towel and created rich foam.",
        "シャワータオルにボディソープをつけてたっぷりと泡立てました。"
    ),
    (
        "비누받침",
        "bi-nu-bat-chim",
        "soap dish / soap holder",
        "石鹸置き (せっけんおき)",
        "비누가 무르지 않도록 올려놓는 받침대",
        "명사",
        "세면대 옆에 물이 잘 빠지는 비누받침을 놓았어요.",
        "I placed a well-draining soap dish next to the sink.",
        "洗面台の横に水切れの良い石鹸置きを置きました。"
    ),
    (
        "칫솔꽂이",
        "chit-sol-kkot-i",
        "toothbrush holder",
        "歯ブラシ立て (はブラシたて)",
        "칫솔을 세워 보관할 수 있는 꽂이",
        "명사",
        "욕실 거울 수납장에 위생적인 칫솔꽂이를 달았어요.",
        "I attached a hygienic toothbrush holder in the bathroom mirror cabinet.",
        "浴室の鏡裏収納に衛生的な歯ブラシ立てを取り付けました。"
    ),
    (
        "치실",
        "chi-sil",
        "dental floss",
        "デンタルフロス / 糸ようじ",
        "치아 사이의 찌꺼기를 제거하는 가는 실",
        "명사",
        "양치질을 한 후에 치실로 꼼꼼하게 치아를 관리해요.",
        "After brushing my teeth, I meticulously care for them with dental floss.",
        "歯磨きをした後にデンタルフロスで念入りにケアします。"
    ),
    (
        "귀이개",
        "gwi-i-gae",
        "earpick",
        "耳かき (みみかき)",
        "귀지를 파낼 때 쓰는 작은 주걱 모양의 도구",
        "명사",
        "서랍에서 나무 귀이개를 꺼내 조심스럽게 귀를 청소했어요.",
        "I took out a wooden earpick from the drawer and carefully cleaned my ear.",
        "引き出しから木製の耳かきを取り出して慎重に耳掃除をしました。"
    ),
    (
        "바지걸이",
        "ba-ji-geol-i",
        "pants hanger / trousers hanger",
        "ズボンハンガー / スラックスハンガー",
        "바지가 구겨지지 않게 집어서 거는 옷걸이",
        "명사",
        "정장 바지는 주름이 생기지 않도록 바지걸이에 걸어 보관해요.",
        "I hang suit trousers on a pants hanger to prevent wrinkles.",
        "スーツのズボンはシワにならないようズボンハンガーに掛けて保管します。"
    ),
    (
        "키친타월",
        "ki-chin-ta-weol",
        "paper towel / kitchen roll",
        "キッチンペーパー",
        "주방에서 기름기를 닦거나 물기를 뺄 때 쓰는 두꺼운 종이",
        "명사",
        "튀김 요리의 기름기를 빼려고 그릇에 키친타월을 깔았어요.",
        "I lined a dish with kitchen paper towels to drain oil from fried foods.",
        "揚げ物の油を切るために皿にキッチンペーパーを敷きました。"
    ),
    (
        "위생장갑",
        "wi-saeng-jang-gap",
        "disposable plastic gloves",
        "使い捨てビニール手袋 (ビニールてぶくろ)",
        "요리할 때 손을 깨끗하게 유지하기 위해 끼는 얇은 비닐 장갑",
        "명사",
        "김치를 버무릴 때 손에 양념이 묻지 않게 위생장갑을 꼈어요.",
        "I put on disposable plastic gloves so seasoning wouldn't stain my hands while mixing kimchi.",
        "キムチを和える時に手にヤンニョムがつかないようビニール手袋をはめました。"
    ),
    (
        "지퍼백",
        "ji-peo-baek",
        "zipper storage bag",
        "ジッパー付き保存袋 (ジッパーぶくろ)",
        "입구를 밀봉할 수 있는 투명한 비닐 백",
        "명사",
        "남은 채소를 신선하게 보관하기 위해 지퍼백에 나누어 담았어요.",
        "I divided leftover vegetables into zipper storage bags to keep them fresh.",
        "残った野菜を新鮮に保つためジッパー付き保存袋に小分けにしました。"
    ),
    (
        "고무줄",
        "go-mu-jul",
        "rubber band / hair elastic",
        "輪ゴム (わゴム) / ヘアゴム",
        "물건을 묶거나 머리를 묶을 때 쓰는 탄력 있는 줄",
        "명사",
        "개봉한 과자 봉지가 눅눅해지지 않게 노란 고무줄로 묶었어요.",
        "I tied the opened snack bag with a yellow rubber band so it wouldn't get soggy.",
        "開けたお菓子の袋が湿気ないように黄色い輪ゴムで縛りました。"
    ),
    (
        "수정테이프",
        "su-jeong-te-i-peu",
        "correction tape",
        "修正テープ (しゅうせいテープ)",
        "글씨가 틀렸을 때 하얗게 덮어 씌우는 테이프",
        "명사",
        "노트에 잘못 쓴 글자를 수정테이프로 지우고 다시 썼어요.",
        "I covered the mistyped letters in the notebook with correction tape and rewrote them.",
        "ノートに書き間違えた文字を修正テープで消して書き直しました。"
    ),
    (
        "네임펜",
        "ne-im-pen",
        "permanent marker",
        "油性ペン (ゆせいペン) / 名前ペン",
        "지워지지 않게 이름이나 표시를 쓸 때 쓰는 펜",
        "명사",
        "새 학기 공책 앞면에 검은색 네임펜으로 이름을 썼어요.",
        "I wrote my name on the front of the new term notebook with a black permanent marker.",
        "新学期のノートの表紙に黒い油性ペンで名前を書きました。"
    ),
    (
        "샤프심",
        "sya-peu-sim",
        "mechanical pencil lead",
        "シャープペンの芯 (シャープペンのしん)",
        "샤프펜슬 안에 넣어 쓰는 가는 흑연 심",
        "명사",
        "시험 도중에 샤프심이 부러져서 새 심을 꺼내 넣었어요.",
        "The pencil lead broke during the exam, so I took out a new one and loaded it.",
        "試験中にシャープペンの芯が折れたので、新しい芯を取り出して入れました。"
    ),
    (
        "독서대",
        "dok-seo-dae",
        "book stand / reading rack",
        "書見台 (しょけんだい) / ブックスタンド",
        "책을 세워 놓고 편하게 읽을 수 있게 받치는 대",
        "명사",
        "목이 아프지 않게 두꺼운 전공 책을 독서대에 올려놓았어요.",
        "I placed the thick textbook on the book stand so my neck wouldn't ache.",
        "首が痛くならないように分厚い専門書を書見台に置きました。"
    ),
    (
        "줄자",
        "jul-ja",
        "tape measure",
        "メジャー / 巻尺 (まきじゃく)",
        "감아서 보관하는 유연한 눈금자",
        "명사",
        "새 가구를 들여놓기 전에 방 구석의 길이를 줄자로 재었어요.",
        "Before bringing in new furniture, I measured the room corner with a tape measure.",
        "新しい家具を置く前に部屋の隅の長さをメジャーで測りました。"
    )
]

P5_TOPIK1_WORDS = _CLEAN_PART1 + _CLEAN_PART2 + _REPLACEMENTS
