# -*- coding: utf-8 -*-
"""1차 확장 500개 완성 마무리 어휘 (500-Word Phase 1 Completion Dataset)"""

FINAL_TOUCH_WORDS = [
    # 한글 기초 & 생존 회화 (10개)
    ("저기요", "[jeo-gi-yo]", "Excuse me (to call waiter/passerby)", "すみません (店員を呼ぶ時など)", "식당에서 직원을 부르거나 모르는 사람을 부를 때 쓰는 대표 호칭", "표현", "저기요, 여기 반찬 좀 더 주실 수 있나요?", "Excuse me, could we get some more side dishes here?", "すみません、ここにおかずのお代わりをいただけますか？"),
    ("얼마나 걸려요?", "[eol-ma-na geol-lyeo-yo]", "How long does it take?", "どれくらいかかりますか？", "소요 시간을 묻는 필수 여행 질문", "표현", "여기서 공항까지 택시로 얼마나 걸려요?", "How long does it take by taxi from here to the airport?", "ここから空港までタクシーでどれくらいかかりますか？"),
    ("어떻게 가요?", "[eo-tteo-ke ga-yo]", "How do I get there?", "どうやって行きますか？", "목적지로 가는 방법이나 교통편을 물어볼 때", "표현", "명동에서 남산타워까지 어떻게 가요?", "How do I get from Myeongdong to Namsan Tower?", "明洞から南山タワーまでどうやって行きますか？"),
    ("이것 좀 보여주세요", "[i-geot jom bo-yeo-ju-se-yo]", "Please show me this", "これを見せてください", "쇼핑할 때 진열대 물건을 자세히 보고 싶을 때", "표현", "저기 유리장 안에 있는 목걸이 이것 좀 보여주세요.", "Could you please show me this necklace inside the glass case?", "あそこのガラスケースの中にあるネックレスを見せてください。"),
    ("입어봐도 돼요?", "[i-beo-bwa-do dwae-yo]", "Can I try this on?", "試着してもいいですか？", "옷가게에서 옷을 시착해 보고 싶을 때 묻는 말", "표현", "디자인이 마음에 드는데 피팅룸에서 입어봐도 돼요?", "I like the design; can I try this on in the fitting room?", "デザインが気に入ったのですが、試着室で試着してもいいですか？"),
    ("신어봐도 돼요?", "[si-neo-bwa-do dwae-yo]", "Can I try these shoes on?", "履いてみてもいいですか？", "신발 가게에서 신발을 착용해 보고 싶을 때", "표현", "운동화 240 사이즈로 신어봐도 돼요?", "Can I try these sneakers on in size 240?", "スニーカーの240サイズを履いてみてもいいですか？"),
    ("화장품", "[hwa-jang-pum]", "Cosmetics / Makeup", "化粧品 / コスメ", "얼굴을 곱게 가꾸거나 피부를 보호하는 미용 제품", "명사", "명동 화장품 로드숍에서 마스크팩을 대량으로 샀어요.", "I bought facial mask sheets in bulk at a Myeongdong cosmetic shop.", "明洞のコスメロードショップでフェイスマスクを大量に買いました。"),
    ("기념품", "[gi-nyeom-pum]", "Souvenir", "記念品 / お土産", "여행이나 특별한 일을 추억으로 남기기 위한 물건", "명사", "인사동 전통 공예품점에서 가족 선물용 기념품을 샀어요.", "I bought souvenirs for family gifts at an Insa-dong craft shop.", "仁寺洞の伝統工芸品店で家族へのお土産の記念品を買いました。"),
    ("지하철", "[ji-ha-cheol]", "Subway / Metro", "地下鉄", "도시의 지하에 레일을 깔고 운행하는 전철", "명사", "서울 지하철은 와이파이도 잘 터지고 냉난방이 쾌적해요.", "Seoul subway has great Wi-Fi and comfortable heating and cooling.", "ソウルの地下鉄はWi-Fiもよく繋がり、冷暖방も快適です。"),
    ("버스", "[beo-seu]", "Bus", "バス", "여러 승객을 정해진 노선에 따라 태워 나르는 대형 차량", "명사", "시내버스를 타고 광화문 광장으로 이동했어요.", "I took a city bus and traveled to Gwanghwamun Square.", "市内バスに乗って光化門広場へ移動しました。"),

    # TOPIK I 초급 필수 어휘 (8개)
    ("비행기", "[bi-haeng-gi]", "Airplane", "飛行機", "하늘을 날아 사람이나 짐을 실어 나르는 항공기", "명사", "제주도행 비행기 창가 자리에서 푸른 바다를 내려다봤어요.", "I looked down at the blue sea from the window seat of Jeju flight.", "済州島行きの飛行機の窓側の席から青い海を見下ろしました。"),
    ("기차", "[gi-cha]", "Train", "列車 / 汽車", "철로 위를 달리며 승객과 화물을 운송하는 교통수단", "명사", "KTX 기차를 타면 서울에서 부산까지 2시간 반이면 가요.", "Taking the KTX train, it takes only 2.5 hours from Seoul to Busan.", "KTX列車に乗れば、ソウルから釜山まで2時間半で行けます。"),
    ("시장", "[si-jang]", "Traditional market", "市場", "여러 상인이 모여 물건을 사고파는 활기찬 장터", "명사", "광장시장에서 빈대떡과 마약김밥을 맛있게 사 먹었어요.", "I ate Bindaetteok and Mayak Kimbap at Gwangjang Market.", "広蔵市場（クァンジャンシジャン）でピンデトックと麻薬キンパを美味しく食べました。"),
    ("식당", "[sik-dang]", "Restaurant", "食堂 / 飲食店", "음식을 조리하여 손님에게 파는 가게", "명사", "골목 안쪽에 숨어 있는 30년 전통 국밥 식당이에요.", "It's a 30-year traditional Gukbap restaurant hidden in an alley.", "路地の奥に隠れている30年伝統のクッパ食堂です。"),
    ("카페", "[ka-pe]", "Cafe / Coffee shop", "カフェ", "커피나 음료, 디저트를 즐기며 쉬는 공간", "명사", "성수동 골목길의 감성적인 카페에서 노트북으로 작업했어요.", "I worked on my laptop at an emotional cafe in Seongsu-dong.", "聖水洞の路地裏にあるエモーショナルなカフェでノートパソコン作業をしました。"),
    ("도서관", "[do-seo-gwan]", "Library", "図書館", "다양한 도서와 자료를 수집하여 열람하게 하는 시설", "명사", "국립중앙도서관에서 한국 역사 관련 고문헌을 찾아봤어요.", "I looked up Korean history classics at the National Library.", "国立中央図書館で韓国の歴史に関する古文献を調べてみました。"),
    ("영화관", "[yeong-hwa-gwan]", "Movie theater / Cinema", "映画館", "영화를 관람객에게 상영하는 시설", "명사", "주말 저녁에 영화관에서 팝콘을 먹으며 영화를 봤습니다.", "I watched a movie eating popcorn at the theater on weekend night.", "週末の夜に映画館でポップコーンを食べながら映画を見ました。"),
    ("백화점", "[baek-hwa-jeom]", "Department store", "デパート / 百貨店", "다양한 고급 상품을 층별로 진열하여 판매하는 대형 매장", "명사", "더현대 서울 백화점 지하 푸드코트에는 맛집이 가득해요.", "The basement food court of The Hyundai Seoul is full of eateries.", "「ザ・現代ソウル」デパートの地下フードコートには名店が一杯です。"),

    # TOPIK II 중급 및 비즈니스 (10개)
    ("계획", "[gye-hoek]", "Plan / Blueprint", "計画", "앞으로 할 일의 절차나 방법, 규모를 미리 짬", "명사", "주말 여행 세부 계획을 엑셀 파일로 꼼꼼히 정리했어요.", "I meticulously organized the detailed weekend trip plan in Excel.", "週末旅行の詳細な計画をエクセルファイルに几帳面にまとめました。"),
    ("문제", "[mun-je]", "Problem / Issue", "問題", "해결하거나 답을 찾아야 할 어려운 상황이나 물음", "명사", "소통을 통해 팀원들 사이의 갈등 문제를 슬기롭게 풀었습니다.", "Through communication, we wisely solved conflict issues in the team.", "コミュニケーションを通じてチームメンバー間の葛藤の問題を賢く解決しました。"),
    ("답변", "[dap-byeon]", "Reply / Answer", "回答 / 返答", "질문이나 요구에 대해 설명하거나 의견을 내놓음", "명사", "문의하신 사항에 대한 공식 답변 메일을 작성해 보내드렸습니다.", "I wrote and sent an official reply email regarding your inquiry.", "お問い合わせいただいた事項に対する公式な回答メールを作成してお送りしました。"),
    ("의견", "[ui-gyeon]", "Opinion / Viewpoint", "意見", "어떤 대상이나 일에 대하여 가지는 생각", "명사", "회의 참석자 모두가 각자의 창의적인 의견을 자유롭게 나눴어요.", "All meeting attendees freely shared their creative opinions.", "会議の参加者全員がそれぞれの創造的な意見を自由に交わしました。"),
    ("조건", "[jo-geon]", "Condition / Terms", "条件", "어떤 일을 성립시키기 위하여 갖추어야 할 요건", "명사", "양측이 모두 만족할 수 있는 최적의 계약 조건을 도출했습니다.", "We derived optimal contract conditions satisfactory to both parties.", "双方が共に満足できる最適な契約条件を導き出しました。"),
    ("성장", "[seong-jang]", "Growth", "成長", "사람이 자라거나 규모나 역량이 커짐", "명사", "실패의 경험을 밑거름 삼아 한 단계 더 높은 성장을 이루었습니다.", "Using failure as a stepping stone, we achieved higher growth.", "失敗の経験を糧にして、一段階さらに高い成長を成し遂げました。"),
    ("기쁨", "[gi-ppeum]", "Joy / Delight", "喜び", "욕구가 충족되거나 좋은 일을 맞아 마음에 넘치는 즐거움", "명사", "오랜 노력 끝에 결실을 맺었을 때 느끼는 기쁨은 말로 다 못해요.", "The joy felt when bearing fruit after long effort is beyond words.", "長年の努力の末に実を結んだ時に感じる喜びは言葉にできません。"),
    ("슬픔", "[seul-peum]", "Sadness / Sorrow", "悲しみ", "마음이 아프고 서글픈 감정", "명사", "이별의 슬픔을 달래기 위해 친구들과 함께 바다를 찾았어요.", "To soothe the sadness of farewell, I visited the sea with friends.", "別れの悲しみを癒すために友達と一緒に海を訪れました。"),
    ("열정", "[yeol-jeong]", "Passion / Ardor", "情熱", "어떤 일에 열렬한 애정을 가지고 쏟는 뜨거운 기운", "명사", "새로운 언어를 배우는 여러분의 열정을 진심으로 응원합니다.", "I sincerely support your passion for learning a new language.", "新しい言語を学ぶ皆さんの情熱を心から応援します。"),
    ("자신", "[ja-sin]", "Confidence / Oneself", "自信 / 自分自身", "스스로를 믿는 굳센 마음 또는 자기 자신", "명사", "자기 자신을 믿고 꾸준히 한 걸음씩 나아가세요.", "Trust yourself and take steady steps forward one by one.", "自分自身を信じて、着実に一歩ずつ進んでください。"),
]
