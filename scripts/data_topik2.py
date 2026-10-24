# -*- coding: utf-8 -*-
"""TOPIK II 중급 핵심 어휘 (TOPIK II Intermediate Core Vocabulary)"""

TOPIK2_WORDS = [
    # 1. 일상 심화 & 사회 활동
    ("경험", "[gyeong-heom]", "Experience", "経験", "자신이 실제로 겪거나 해 본 일", "명사", "한국 유학 생활은 정말 값진 경험이었어요.", "Studying abroad in Korea was truly a valuable experience.", "韓国への留学生活は本当に貴重な経験でした。"),
    ("준비하다", "[jun-bi-ha-da]", "To prepare", "準備する", "어떤 일에 대비하여 미리 갖추어 놓다", "동사", "다음 주에 볼 TOPIK 시험을 열심히 준비하고 있어요.", "I am diligently preparing for the TOPIK exam next week.", "来週受けるTOPIK試験を一生懸命準備しています。"),
    ("신청하다", "[sin-cheong-ha-da]", "To apply / To register", "申し込む / 申請する", "공식적으로 원하는 바를 적어 내거나 요청하다", "동사", "어학당 여름 학기 수업을 온라인으로 신청했어요.", "I applied for the language institute summer semester online.", "語学堂の夏学期クラスをオンラインで申請しました。"),
    ("결정하다", "[gyeol-jeong-ha-da]", "To decide", "決定する", "어떤 일에 대해 분명한 생각을 정하다", "동사", "졸업 후에 한국에 더 머물기로 결정했어요.", "I decided to stay longer in Korea after graduation.", "卒業後に韓国にもっと滞在することを決定しました。"),
    ("선택하다", "[seon-taek-ha-da]", "To choose / To select", "選択する / 選ぶ", "여럿 중에서 마음에 드는 것을 고르다", "동사", "다양한 전공 중에서 국어국문학을 선택했습니다.", "Among various majors, I chose Korean Language and Literature.", "多様な専攻の中から国語国文学を選択しました。"),
    ("약속", "[yak-sok]", "Appointment / Promise", "約束", "다른 사람과 어떤 일을 하기로 미리 정함", "명사", "금요일 저녁에 친구와 저녁 식사 약속이 있어요.", "I have a dinner appointment with a friend on Friday evening.", "金曜日の夕方に友達と夕食の約束があります。"),
    ("모임", "[mo-im]", "Gathering / Meeting", "集まり / 会", "어떤 목적을 위해 사람들이 모이는 자리", "명사", "주말마다 언어 교환 모임에 나가요.", "I go to a language exchange gathering every weekend.", "週末ごとに言語交換の集まりに参加しています。"),
    ("배달", "[bae-dal]", "Delivery", "配達 / 出前", "주문한 물건이나 음식을 가져다주는 일", "명사", "한국은 야식 배달 문화가 아주 잘 발달해 있어요.", "In Korea, late-night snack delivery culture is very well developed.", "韓国は夜食の出前文化がとてもよく発達しています。"),
    ("포장", "[po-jang]", "Packaging / Takeout", "包装 / テイクアウト", "물건이나 음식을 싸서 보호하거나 가져가게 함", "명사", "선물용으로 고급스럽게 포장해 주실 수 있나요?", "Could you wrap it up luxuriously for a gift?", "プレゼント用に高級感のある包装をしてもらえますか？"),
    ("할인", "[ha-rin]", "Discount", "割引", "정해진 가격에서 일정 금액을 깎아 줌", "명사", "학생증을 보여주면 20퍼센트 할인을 받을 수 있어요.", "If you show your student ID, you can get a 20 percent discount.", "学生証を提示すると20％の割引を受けられます。"),
    ("교환", "[gyo-hwan]", "Exchange", "交換", "서로 다른 것을 바꾸거나 물건을 다른 것으로 바꿈", "명사", "사이즈가 맞지 않아서 라지 사이즈로 교환했어요.", "The size didn't fit, so I exchanged it for a large size.", "サイズが合わなかったのでLサイズに交換しました。"),
    ("환불", "[hwan-bul]", "Refund", "払い戻し / 返金", "산 물건을 돌려주고 지불했던 돈을 도로 찾음", "명사", "영수증이 있으면 일주일 안에 환불이 가능합니다.", "If you have a receipt, refunds are possible within a week.", "レシートがあれば1週間以内に払い戻しが可能です。"),
    ("예약하다", "[ye-yak-ha-da]", "To reserve / To book", "予約する", "자리나 방, 탈것 등을 미리 확보해 두다", "동사", "인기 있는 한옥 숙소를 석 달 전에 미리 예약했어요.", "I booked a popular Hanok stay three months in advance.", "人気の韓屋宿を3ヶ月前にあらかじめ予約しました。"),
    ("취소하다", "[chwi-so-ha-da]", "To cancel", "キャンセルする / 取り消す", "이미 정해진 계획이나 약속을 물리다", "동사", "갑작스러운 출장 때문에 비행기 표를 취소했어요.", "Due to a sudden business trip, I canceled my plane ticket.", "突然の出張のため、航空券をキャンセルしました。"),
    ("방문하다", "[bang-mun-ha-da]", "To visit", "訪問する / 訪れる", "어떤 사람이나 장소를 찾아가다", "동사", "한국에 올 때마다 경복궁을 꼭 방문해요.", "Whenever I come to Korea, I always visit Gyeongbokgung.", "韓国に来るたびに景福宮を必ず訪れます。"),
    ("추천하다", "[chu-cheon-ha-da]", "To recommend", "推薦する / おすすめする", "어떤 사람이나 물건, 장소가 좋다고 남에게 권하다", "동사", "서울에서 꼭 가봐야 할 카페를 추천해 주세요.", "Please recommend a cafe in Seoul that I must visit.", "ソウルでぜひ行くべきカフェをおすすめしてください。"),
    ("부탁하다", "[bu-tak-ha-da]", "To ask a favor / To request", "頼む / お願いする", "상대방에게 어떤 일을 해 달라고 청하다", "동사", "어려운 번역이라 선배에게 도움을 부탁했어요.", "It was a difficult translation, so I asked a senior for help.", "難しい翻訳だったので、先輩に手伝いをお願いしました。"),
    ("설명하다", "[seol-myeong-ha-da]", "To explain", "説明する", "어떤 사실이나 내용을 알기 쉽게 밝혀 말하다", "동사", "가이드분이 한국의 역사에 대해 알기 쉽게 설명해 주셨어요.", "The tour guide explained Korean history in an easy-to-understand way.", "ガイドの方が韓国の歴史について分かりやすく説明してくれました。"),
    ("이해하다", "[i-hae-ha-da]", "To understand", "理解する", "말이나 글의 뜻, 또는 상황의 맥락을 알아듣다", "동사", "설명을 듣고 나니 이제 완전히 이해가 돼요.", "After listening to the explanation, I completely understand now.", "説明を聞いた後、ようやく完全に理解できました。"),
    ("해결하다", "[hae-gyeol-ha-da]", "To solve / To resolve", "解決する", "엉킨 문제나 갈등을 풀어서 처리하다", "동사", "친구와 진솔한 대화를 통해 오해를 해결했어요.", "Through honest talk with my friend, I resolved the misunderstanding.", "友達と本音で話し合って誤解を解決しました。"),

    # 2. 감정, 성격, 생각 표현
    ("노력하다", "[no-ryeok-ha-da]", "To make an effort / To endeavor", "努力する", "어떤 목적을 이루기 위해 온 힘을 다하다", "동사", "자연스러운 한국어 발음을 내려고 매일 노력해요.", "I try hard every day to pronounce Korean naturally.", "自然な韓国語の発音を出すために毎日努力しています。"),
    ("성공하다", "[seong-gong-ha-da]", "To succeed", "成功する", "뜻한 바를 목적대로 잘 이루어 내다", "동사", "열심히 공부한 끝에 원하던 대학원에 합격해 성공했어요.", "After studying hard, I succeeded in getting into grad school.", "一生懸命勉強した末に希望の大学院に合格し成功しました。"),
    ("실패하다", "[sil-pae-ha-da]", "To fail", "失敗する", "목적한 바를 이루지 못하고 어긋나다", "동사", "한 번 실패했다고 해서 쉽게 포기하지 마세요.", "Just because you failed once, don't give up easily.", "一度失敗したからといって簡単に諦めないでください。"),
    ("성격", "[seong-gyeok]", "Personality", "性格", "사람이 지닌 고유한 성품이나 기질", "명사", "제 친구는 긍정적이고 활발한 성격을 가졌어요.", "My friend has a positive and lively personality.", "私の友達はポジティブで活発な性格をしています。"),
    ("기분", "[gi-bun]", "Mood / Feeling", "気分", "주위 환경이나 마음에 따라 일어나는 감정 상태", "명사", "날씨가 맑아서 아침부터 기분이 상쾌해요.", "The weather is sunny, so I feel refreshed since morning.", "天気が晴れているので朝から気分が爽やかです。"),
    ("불안하다", "[bul-an-ha-da]", "To be anxious / Uneasy", "不安だ", "마음이 편하지 않고 조마조마하다", "형용사", "시험 결과가 나오기 전까지는 조금 불안해요.", "Until the exam results come out, I feel a bit anxious.", "試験結果が出るまでは少し不安です。"),
    ("자신감", "[ja-sin-gam]", "Confidence", "自信", "스스로 해낼 수 있다고 굳게 믿는 마음", "명사", "한국인과 대화를 자주 나눌수록 자신감이 생겨요.", "The more I talk with Koreans, the more confidence I gain.", "韓国人と会話を交わすほど自信がつきます。"),
    ("후회하다", "[hu-hoe-ha-da]", "To regret", "後悔する", "이전의 잘못이나 놓친 기회를 뒤늦게 안타까워하다", "동사", "젊을 때 더 많은 도전을 하지 않은 것을 후회하지 않으려고 해요.", "I try not to regret not taking more challenges while young.", "若い時にもっと多くの挑戦をしなかったことを後悔しないようにしています。"),
    ("기대하다", "[gi-dae-ha-da]", "To look forward to / To anticipate", "期待する", "어떤 일이 잘 이루어지기를 바라고 기다리다", "동사", "다음 달에 있을 방탄소년단 콘서트를 엄청 기대하고 있어요.", "I am looking forward to BTS's concert next month immensely.", "来月にあるBTSのコンサートをものすごく期待しています。"),
    ("답답하다", "[dap-da-pa-da]", "To feel frustrated / Stuffy", "もどかしい / 息苦しい", "마음이나 공기가 통하지 않아 괴롭고 답답하다", "형용사", "하고 싶은 말을 한국어로 다 못해서 조금 답답했어요.", "I couldn't say everything I wanted in Korean, so I felt frustrated.", "言いたいことを韓国語で全部言えなくてもどかしかったです。"),

    # 3. 인간관계 & 사회 표현
    ("인연", "[in-yeon]", "Destiny / Deep connection", "縁 / 因縁", "사람과 사람 사이에 맺어지는 소중한 관계", "명사", "여행지에서 만난 사람들과 좋은 인연을 맺었어요.", "I formed wonderful connections with people met while traveling.", "旅行先で出会った人々と良い縁を結びました。"),
    ("배려하다", "[bae-ryeo-ha-da]", "To be considerate", "配慮する / 気遣う", "상대방의 입장과 형편을 깊이 생각하고 도와주다", "동사", "서로를 배려하는 따뜻한 태도가 사회를 밝게 만들어요.", "A warm attitude considerate of one another makes society brighter.", "お互いを思いやる温かい態度が社会を明るくします。"),
    ("갈등", "[gal-deung]", "Conflict", "葛藤 / 対立", "서로 다른 생각이나 이해관계로 충돌하는 상태", "명사", "직장 내 갈등을 해결하기 위해 팀 워크숍을 열었습니다.", "To resolve workplace conflicts, a team workshop was held.", "職場内の葛藤を解決するためにチームワークショップを開きました。"),
    ("익숙하다", "[ik-su-ka-da]", "To be familiar / Accustomed", "慣れている / 馴染みがある", "자주 보거나 겪어서 어색하지 않고 편안하다", "형용사", "한국에 산 지 1년이 되니 지하철 환승이 익숙해요.", "Having lived in Korea for a year, subway transfer is familiar.", "韓国に住んで1年になるので地下鉄の乗り換えに慣れました。"),
    ("불편하다", "[bul-pyeon-ha-da]", "To be uncomfortable / Inconvenient", "不便だ", "이용하기 거북하거나 마음이 편하지 않다", "형용사", "침대가 너무 딱딱해서 잠자리가 불편했어요.", "The bed was too hard, so sleeping was uncomfortable.", "ベッドが硬すぎて寝心地が不便でした。"),
]
