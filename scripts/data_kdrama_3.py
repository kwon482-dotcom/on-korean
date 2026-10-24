# -*- coding: utf-8 -*-
"""K-드라마 & 실전 리얼 회화 파트 3 (K-Drama & K-Culture Part 3)"""

KDRAMA_WORDS_3 = [
    ("첫사랑", "[cheot-sa-rang]", "First love", "初恋", "처음으로 느낀 순수하고 풋풋한 사랑", "명사", "한국 멜로 영화의 단골 테마는 풋풋한 첫사랑 이야기예요.", "The staple theme of Korean romance films is innocent first love.", "韓国の恋愛映画の定番テーマは、初々しい初恋の物語です。"),
    ("짝사랑", "[jjak-sa-rang]", "Unrequited love / Crush", "片思い", "혼자서만 남모르게 상대를 사모하는 사랑", "명사", "서브 남주인공의 애절한 짝사랑 연기에 시청자들이 울었어요.", "Viewers wept at the second lead's poignant unrequited love acting.", "サブ男性主人公の切ない片思いの演技に視聴者が涙しました。"),
    ("고백", "[go-baek]", "Confession (of feelings)", "告白", "마음속에 숨겨둔 사랑이나 비밀을 솔직하게 털어놓음", "명사", "남산타워 야경을 바라보며 주인공이 진심 어린 고백을 했어요.", "Looking at the Namsan Tower night view, the lead gave a sincere confession.", "南山タワーの夜景を見つめながら、主人公が心からの告白をしました。"),
    ("이별", "[i-byeol]", "Breakup / Farewell", "別れ / 離別", "서로 헤어져 갈라섬", "명사", "가슴 아픈 이별 장면에서 흐르는 OST 음악이 너무 슬퍼요.", "The OST music playing during the heartbreaking breakup scene is so sad.", "胸の痛む別れのシーンで流れるOSTの曲がとても悲しいです。"),
    ("약속해", "[yak-so-kae]", "Promise me", "約束して", "서로의 다짐을 확실하게 맺자고 청하는 말", "표현", "언제 어디서든 꼭 다시 만나기로 나랑 약속해.", "Promise me that we will definitely meet again whenever and wherever.", "いつどこででも必ずまた会おうと、私と約束して。"),
    ("보고 싶어", "[bo-go si-peo]", "I miss you", "会いたい", "그리운 사람을 눈앞에서 마주하고 싶은 애틋한 마음", "표현", "하루 종일 네 생각만 나고 너무 보고 싶어.", "I think of you all day, and I miss you so much.", "一日中あなたのことばかり思い浮かんで、とても会いたいです。"),
    ("사랑해", "[sa-rang-hae]", "I love you", "愛してる / 大好き", "이성이나 가족, 친구를 깊이 아끼고 사랑함을 전하는 말", "표현", "수줍게 건넨 '사랑해' 한마디에 온 세상이 멈춘 것 같았어.", "At the shyly whispered 'I love you', the whole world felt still.", "照れくさそうに口にした「愛してる」のひと言に、世界中が止まったようでした。"),
    ("진심", "[jin-sim]", "Sincerity / True feelings", "本心 / 真心", "거짓이나 꾸밈이 없는 참된 마음", "명사", "장난이 아니라 진심으로 널 좋아하고 있어.", "It's not a joke; I like you with all my sincerity.", "冗談じゃなくて、本心からあなたのことが好きです。"),
    ("설레다", "[seol-le-da]", "To flutter / To feel butterflies", "胸が高鳴る / トキメク", "마음이 가라앉지 않고 두근두근 들뜨다", "동사", "처음 손을 잡았을 때 심장이 터질 것처럼 설렜어요.", "When we first held hands, my heart fluttered as if it would burst.", "初めて手を握った時、心臓が破裂しそうなくらいトキメキました。"),
    ("눈물", "[nun-mul]", "Tears", "涙", "슬픔이나 감동, 아픔으로 눈에서 흘러나오는 맑은 액체", "명사", "주인공의 안타까운 사연을 듣고 저절로 눈물이 흘렀어요.", "Hearing the protagonist's sad story, tears flowed naturally.", "主人公の切ない事情を聞いて、自然と涙が溢れました。"),
    ("운명", "[un-myeong]", "Destiny / Fate", "運命", "인간의 힘으로는 어찌할 수 없는 정해진 삶의 길", "명사", "어릴 적 헤어진 두 주인공이 성인이 되어 다시 만난 건 운명이었어.", "The two meeting again as adults after separating young was destiny.", "幼い頃に別れた二人が大人になって再会したのは運命でした。"),
    ("영원히", "[yeong-won-hi]", "Forever / Eternally", "永遠に", "끝없이 이어지는 시간 동안 영원토록", "부사", "너의 곁에서 영원히 함께할 것을 맹세할게.", "I swear to stay together by your side forever.", "あなたのそばで永遠に一緒にいることを誓うよ。"),
    ("행복해", "[haeng-bok-hae]", "I am happy", "幸せだ / 幸せだよ", "마음에 차고 넘치는 만족과 기쁨을 느낄 때 하는 말", "표현", "너와 함께 있는 이 순간이 내 인생에서 가장 행복해.", "This moment being with you is the happiest in my life.", "あなたと一緒にいるこの瞬間が、私の人生で一番幸せです。"),
    ("화이팅", "[hwa-i-ting]", "Fighting! / Cheerio! / You got this!", "ファイティン / 頑張って", "힘을 내라고 격려하고 응원할 때 외치는 한국식 표현", "표현", "내일 시험 잘 보고 와! 화이팅!", "Do well on tomorrow's exam! Fighting!", "明日の試験、上手くいきますように！ファイティン！"),
    ("힘내", "[him-nae]", "Cheer up / Stay strong", "元気出して / 頑張って", "어려움에 처한 상대에게 용기와 위로를 건네는 말", "표현", "지금은 힘들지만 다 지나갈 거야. 조금만 힘내!", "It's tough right now, but it'll all pass. Hang in there a bit!", "今は辛いけれど全部過ぎ去るよ。少しだけ元気を出して！"),
    ("축하해", "[chuk-ha-hae]", "Congratulations (casual)", "おめでとう", "친구 사이에 기쁜 일을 축하해 주는 말", "표현", "원하던 회사에 최종 합격한 거 정말 축하해!", "Congratulations so much on passing the final round at your dream company!", "念願の会社に最終合格したこと、本当におめでとう！"),
    ("대단해", "[dae-dan-hae]", "Amazing / Incredible", "すごい / 大したものだ", "능력이나 결과가 비범하여 크게 감탄할 때 쓰는 말", "표현", "독학으로 한국어 5급을 땄다니 너 정말 대단해!", "Acquiring Korean Level 5 through self-study, you're truly incredible!", "独学で韓国語5級を取ったなんて、君は本当にすごいよ！"),
    ("멋있어", "[meo-si-sseo]", "Cool / Handsome / Stylish", "かっこいい", "보기에 훌륭하고 세련되며 당당하다", "형용사", "무대 위에서 춤추는 아이돌의 카리스마가 너무 멋있어요.", "The charisma of the idol dancing on stage is so cool.", "ステージの上で踊るアイドルのカリスマがとてもかっこいいです。"),
    ("착하다", "[cha-ka-da]", "To be kind / Good-natured", "優しい / 善良だ", "마음씨가 곱고 어질며 남을 잘 돕다", "형용사", "어려운 이웃을 남몰래 돕는 참 착한 청년이에요.", "He is a truly kind young man who secretly helps neighbors in need.", "困っている隣人を人知れず助ける、とても優しい青年です。"),
    ("솔직히", "[sol-jji-ki]", "Honestly / Frankly speaking", "正直 / ぶっちゃけ", "거짓 없이 속마음을 털어놓고 말하자면", "부사", "솔직히 말해서 처음엔 네가 조금 무서웠어.", "Honestly speaking, at first I was a bit scared of you.", "正直に言って、最初はあなたが少し怖かったよ。"),
]
