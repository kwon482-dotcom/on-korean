# -*- coding: utf-8 -*-
"""한글 기초 & 생존 회화 파트 2 (Hangul Basics Part 2)"""

BASICS_WORDS_2 = [
    # 신체 부위
    ("머리", "[meo-ri]", "Head / Hair", "頭 / 髪", "사람의 목 윗부분 또는 머리카락", "명사", "어제부터 머리가 지끈지끈 아파요.", "My head has been throbbing since yesterday.", "昨日から頭がズキズキ痛みます。"),
    ("눈", "[nun]", "Eye / Snow", "目 / 雪", "사물을 보는 감각 기관 또는 겨울에 내리는 흰 눈", "명사", "눈이 펑펑 내려서 온 세상이 하얗네요.", "Snow is falling heavily, so the whole world is white.", "雪がしんしんと降って世界中が真っ白ですね。"),
    ("코", "[ko]", "Nose", "鼻", "호흡하고 냄새를 맡는 감각 기관", "명사", "감기에 걸려서 코가 꽉 막혔어요.", "I caught a cold, so my nose is all stuffed up.", "風邪をひいて鼻がすっかり詰まりました。"),
    ("입", "[ip]", "Mouth", "口", "음식을 먹고 말을 하는 신체 기관", "명사", "입안이 헐어서 매운 음식을 못 먹겠어요.", "My mouth is sore, so I cannot eat spicy food.", "口の中が荒れて辛いものが食べられません。"),
    ("귀", "[gwi]", "Ear", "耳", "소리를 듣는 청각 기관", "명사", "이어폰을 오래 꼈더니 귀가 아파요.", "I wore earphones for a long time, so my ears hurt.", "イヤホンを長くつけていたので耳が痛いです。"),
    ("손", "[son]", "Hand", "手", "팔 끝에 붙어 물건을 쥐는 신체 기관", "명사", "외출 후에는 비누로 손을 깨끗이 씻어요.", "Wash your hands cleanly with soap after going out.", "外出した後は石鹸で手を綺麗に洗います。"),
    ("발", "[bal]", "Foot", "足 (足首から下)", "다리 끝에 붙어 서거나 걷는 데 쓰는 신체 부위", "명사", "새 구두를 신어서 발이 조금 아파요.", "I wore new shoes, so my feet hurt a bit.", "新しい靴を履いたので足が少し痛いです。"),
    ("다리", "[da-ri]", "Leg / Bridge", "脚 / 橋", "몸을 지탱하고 걷는 신체 부위 또는 강을 건너는 다리", "명사", "하루 종일 서 있어서 다리가 퉁퉁 부었어요.", "I was standing all day, so my legs are swollen.", "一日中立っていたので脚がパンパンに浮腫みました。"),

    # 음식 & 식재료
    ("밥", "[bap]", "Rice / Meal", "ご飯 / 食事", "쌀로 지은 음식 또는 일상적인 식사", "명사", "한국 사람은 밥심으로 산다는 말이 있어요.", "There is a saying that Koreans live on the strength of rice.", "韓国人はご飯の力で生きるという言葉があります。"),
    ("김치", "[gim-chi]", "Kimchi", "キムチ", "배추나 무를 고춧가루와 젓갈에 버무려 발효시킨 한국 전통 음식", "명사", "잘 익은 배추김치로 찌개를 끓였어요.", "I cooked stew with well-fermented Napa cabbage kimchi.", "よく漬かった白菜キムチでチゲを作りました。"),
    ("고기", "[go-gi]", "Meat", "肉", "식용으로 쓰이는 동물의 살", "명사", "주말에 가족들과 삼겹살 고기를 구워 먹었어요.", "I grilled pork belly meat with my family over the weekend.", "週末に家族とサムギョプサルの肉を焼いて食べました。"),
    ("라면", "[ra-myeon]", "Instant ramen", "ラーメン (インスタント)", "면을 끓여 매콤한 국물과 함께 먹는 즉석 면 요리", "명사", "출출할 때는 끓여 먹는 라면이 최고예요.", "When hungry, cooked instant ramen is the best.", "小腹が空いた時は煮て食べるラーメンが一番です。"),
    ("빵", "[ppang]", "Bread", "パン", "밀가루를 반죽하여 오븐에 구운 음식", "명사", "성수동 베이커리 카페에서 소금빵을 샀어요.", "I bought salt bread at a bakery cafe in Seongsu-dong.", "聖水洞のベーカリーカフェで塩パンを買いました。"),
    ("우유", "[u-yu]", "Milk", "牛乳 / ミルク", "소의 젖으로 만든 영양가 높은 음료", "명사", "아침에 토스트와 함께 따뜻한 우유를 마셔요.", "I drink warm milk with toast in the morning.", "朝にトーストと一緒に温かい牛乳を飲みます。"),
    ("커피", "[keo-pi]", "Coffee", "コーヒー", "커피 원두를 볶아 내린 대중적인 기호 음료", "명사", "아침에 아이스 아메리카노 커피를 마셔야 잠이 깨요.", "I need an iced Americano in the morning to wake up.", "朝にアイスアメリカーノを飲まないと目が覚めません。"),
    ("차", "[cha]", "Tea / Car", "お茶 / 車", "차나무 잎을 우려 마시는 음료 또는 도로를 달리는 차량", "명사", "식사 후에 따뜻한 녹차 한 잔을 마셨어요.", "I drank a cup of warm green tea after the meal.", "食後に温かい緑茶を一杯飲みました。"),
    ("과일", "[gwa-il]", "Fruit", "果物 / フルーツ", "나무나 풀에서 열리는 달콤하고 즙이 많은 열매", "명사", "여름에는 수박과 참외 과일이 제일 맛있어요.", "In summer, watermelon and Korean melon are the most delicious.", "夏にはスイカとチャメ（マクワウリ）の果物が一番美味しいです。"),

    # 계절 & 날씨
    ("봄", "[bom]", "Spring", "春", "겨울과 여름 사이의 따뜻한 계절", "명사", "봄이 오면 여의도에 벚꽃 축제가 열려요.", "When spring comes, cherry blossom festival opens in Yeouido.", "春が来ると汝矣島で桜祭りが開かれます。"),
    ("여름", "[yeo-reum]", "Summer", "夏", "한 해 중 가장 무덥고 비가 많은 계절", "명사", "여름 휴가철에 부산 해운대 바다로 여행을 떠났어요.", "During summer vacation, I traveled to Haeundae beach in Busan.", "夏休みに釜山の海雲台の海へ旅行に出かけました。"),
    ("가을", "[ga-eul]", "Autumn / Fall", "秋", "여름과 겨울 사이의 서늘하고 맑은 단풍 계절", "명사", "가을에는 설악산 단풍이 정말 장관이에요.", "In autumn, the maple leaves on Seoraksan are truly magnificent.", "秋には雪岳山の紅葉が本当に壮観です。"),
    ("겨울", "[gyeo-ul]", "Winter", "冬", "한 해 중 가장 춥고 눈이 내리는 계절", "명사", "한국의 겨울은 기온이 낮고 칼바람이 불어요.", "Winter in Korea has low temperatures and biting winds.", "韓国の冬は気温が低く、冷たい風が吹き荒れます。"),
    ("비", "[bi]", "Rain", "雨", "대기 중의 수증기가 엉겨 땅으로 떨어지는 물방울", "명사", "장마철이라 며칠째 계속 비가 내리고 있어요.", "Because it's the monsoon season, it has been raining for days.", "梅雨なので何日もずっと雨が降り続いています。"),
    ("바람", "[ba-ram]", "Wind", "風", "기압 차이로 인해 공기가 이동하는 현상", "명사", "시원한 가을바람이 솔솔 불어오네요.", "A refreshing autumn wind is blowing gently.", "涼しい秋風がそよそよと吹いてきますね。"),
    ("구름", "[gu-reum]", "Cloud", "雲", "하늘에 떠 있는 물방울이나 얼음 알갱이의 무리", "명사", "하늘에 뭉게구름이 둥실둥실 떠 있어요.", "Fluffy clouds are floating in the sky.", "空に入道雲がぷかぷかと浮かんでいます。"),

    # 일상 사물 & 주거
    ("집", "[jip]", "Home / House", "家", "사람이 거주하는 주택이나 안식처", "명사", "퇴근하고 집에 오면 마음이 제일 편안해요.", "Coming home after work brings the greatest peace of mind.", "退勤して家に帰ってくると心が一番安らぎます。"),
    ("방", "[bang]", "Room", "部屋", "벽으로 둘러막은 건물 안의 칸", "명사", "햇볕이 잘 드는 남향 방이라 아늑해요.", "It's a cozy south-facing room with good sunlight.", "日当たりが良い南向きの部屋なので心地よいです。"),
    ("문", "[mun]", "Door / Gate", "ドア / 扉 / 門", "사람이나 바람이 드나들도록 튼 어귀", "명사", "외출할 때는 현관문을 꼭 잠그세요.", "Always lock the front door when going out.", "外出するときは玄関のドアを必ず施錠してください。"),
    ("창문", "[chang-mun]", "Window", "窓", "빛이나 공기가 들어오도록 벽에 낸 문", "명사", "환기를 위해 거실 창문을 활짝 열었어요.", "I opened the living room window wide for ventilation.", "換気のためにリビングの窓をいっぱいに開けました。"),
    ("침대", "[chim-dae]", "Bed", "ベッド", "잠을 잘 수 있도록 만든 가구", "명사", "푹신한 침대에 누워 스마트폰을 보다가 잠들었어요.", "Lying in the soft bed browsing my phone, I fell asleep.", "ふかふかのベッドに横になってスマホを見ていたら眠ってしまいました。"),
    ("책상", "[chaek-sang]", "Desk", "机 / デスク", "글을 쓰거나 사무를 볼 때 쓰는 상", "명사", "책상 위에 스탠드 조명을 켜고 한국어를 공부해요.", "I turn on the desk lamp and study Korean on the desk.", "机の上のスタンドライトをつけて韓国語を勉強します。"),
    ("의자", "[ui-ja]", "Chair", "椅子", "앉을 수 있도록 다리가 달린 가구", "명사", "장시간 앉아 있어도 편안한 인체공학 의자예요.", "It's an ergonomic chair that remains comfortable even when sitting long.", "長時間座っていても楽な人間工学に基づいた椅子です。"),
    ("옷", "[ot]", "Clothes / Clothing", "服", "사람이 몸에 걸쳐 입는 것", "명사", "동대문 패션몰에서 세련된 가을 옷을 샀어요.", "I bought stylish autumn clothes at Dongdaemun fashion mall.", "東大門のファッションモールでおしゃれな秋服を買いました。"),
    ("신발", "[sin-bal]", "Shoes", "靴 / 履物", "발에 신는 신호용 물품", "명사", "한국은 실내에 들어갈 때 신발을 벗어야 해요.", "In Korea, you must take off your shoes when entering indoors.", "韓国では室内に入る時に靴を脱がなければなりません。"),
    ("가방", "[ga-bang]", "Bag / Backpack", "バッグ / カバン", "물건을 넣어 들고 다니는 용구", "명사", "노트북과 필통을 튼튼한 백팩 가방에 넣었어요.", "I put my laptop and pencil case into a sturdy backpack bag.", "ノートパソコンと筆箱を丈夫なリュックサックに入れました。"),
    ("시계", "[si-gye]", "Clock / Watch", "時計", "시간을 재거나 알려주는 기계", "명사", "벽에 걸린 시계를 보니 벌써 밤 11시예요.", "Looking at the clock on the wall, it is already 11 PM.", "壁に掛けられた時計を見ると、もう夜の11時です。"),
    ("지갑", "[ji-gap]", "Wallet", "財布", "돈이나 신용카드, 신분증을 넣어 가지고 다니는 용구", "명사", "카페 테이블 위에 지갑을 두고 올 뻔했어요.", "I almost left my wallet on the cafe table.", "カフェのテーブルの上に財布を置き忘れそうになりました。"),
    ("돈", "[don]", "Money", "お金", "물건을 사고팔 때 쓰는 화폐 가치", "명사", "ATM 기기에서 현금 돈을 조금 인출했어요.", "I withdrew a bit of cash money from the ATM.", "ATM機から現金のお金を少し引き出しました。"),
    ("전화", "[jeon-hwa]", "Phone call / Telephone", "電話", "먼 곳에 있는 사람과 목소리로 통화함", "명사", "회의 중이라 전화를 받을 수 없으니 문자 남겨주세요.", "I am in a meeting and cannot answer the phone, so please leave a text.", "会議中なので電話に出られません。メッセージを残してください。"),
    ("사진", "[sa-jin]", "Photo / Picture", "写真", "카메라로 찍어 나타낸 영상", "명사", "인생네컷 부스에서 친구들과 추억 사진을 찍었어요.", "I took memorable photos with friends at a photo booth.", "「人生4カット」のブースで友達と思い出の写真を撮りました。"),
]
