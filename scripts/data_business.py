# -*- coding: utf-8 -*-
"""비즈니스 & 시사 고급 한국어 (Business & Advanced Professional Korean)"""

BUSINESS_WORDS = [
    # 1. 회사 생활 & 업무 절차
    ("업무", "[eom-mu]", "Work / Business task", "業務 / 仕事", "직장에서 맡아서 하는 구체적인 직무나 일", "명사", "오늘 처리해야 할 주요 업무 리스트를 작성했습니다.", "I wrote down the list of major work tasks to handle today.", "今日処理すべき主要な業務リストを作成しました。"),
    ("회의", "[hoe-ui]", "Meeting / Conference", "会議", "여러 사람이 모여 어떤 안건을 토론하고 협의함", "명사", "오후 2시에 기획팀과 3분기 프로젝트 회의가 있어요.", "There is a Q3 project meeting with the planning team at 2 PM.", "午後2時に企画チームと第3四半期のプロジェクト会議があります。"),
    ("보고", "[bo-go]", "Report", "報告", "일의 진행 상황이나 결과를 상사나 관계자에게 알림", "명사", "매주 금요일마다 주간 업무 보고서를 팀장님께 제출해요.", "Every Friday, I submit a weekly work report to the team lead.", "毎週金曜日ごとに週間業務報告書をチーム長に提出します。"),
    ("결재", "[gyeol-jjae]", "Approval (managerial sign-off)", "決裁", "부하 직원이 올린 안건을 상관이 허가하고 승인하는 일", "명사", "예산 사용 건에 대해 팀장님 결재를 받았습니다.", "I received the team lead's approval regarding the budget usage.", "予算の使用件についてチーム長の決裁をもらいました。"),
    ("마감", "[ma-gam]", "Deadline", "締め切り", "일이나 서류 접수 등을 끝내기로 정해진 기한", "명사", "프로젝트 마감 기한이 코앞이라 모두 야근을 하고 있어요.", "The project deadline is just around the corner, so everyone is working overtime.", "プロジェクトの締め切りが目前に迫っており、みんな残業しています。"),
    ("피드백", "[pi-deu-baek]", "Feedback", "フィードバック", "결과물이나 행동에 대해 평가하고 보완점을 제시함", "명사", "발표 자료에 대한 부장님의 피드백을 반영해 수정했어요.", "I revised the presentation slides reflecting the director's feedback.", "プレゼン資料に対する部長のフィードバックを反映して修正しました。"),
    ("협업", "[hyeo-beop]", "Collaboration / Teamwork", "協業 / コラボレーション", "목적을 달성하기 위해 여러 팀이나 사람이 힘을 합침", "명사", "개발팀과 디자인팀의 긴밀한 협업이 프로젝트 성공의 열쇠입니다.", "Close collaboration between dev and design teams is the key to success.", "開発チームとデザインチームの緊密な協業がプロジェクト成功の鍵です。"),
    ("미팅", "[mi-ting]", "Business meeting", "ミーティング", "관계자나 고객과 만나 업무를 논의하는 일", "명사", "오전에 신규 클라이언트와 화상 미팅을 진행했어요.", "I conducted a video meeting with the new client in the morning.", "午前に新規クライアントとビデオミーティングを行いました。"),
    ("거래처", "[geo-rae-cheo]", "Client / Business partner", "取引先", "지속적으로 상품이나 서비스를 거래하는 상대 회사", "명사", "중요한 거래처 담당자와의 오찬 미팅 일정을 잡았습니다.", "I scheduled a luncheon meeting with the key client representative.", "重要な取引先の担当者との昼食ミーティングの予定を取りました。"),
    ("제안서", "[je-an-seo]", "Proposal", "提案書 / 企画書", "어떤 의견이나 계획을 공식적으로 제안하는 문서", "명사", "다음 주 입찰을 위해 서비스 제안서를 꼼꼼히 검토 중입니다.", "I am carefully reviewing the service proposal for next week's bidding.", "来週の入札のためにサービス提案書を入念に検討中です。"),
    ("첨부파일", "[cheom-bu-pa-il]", "Attachment (email)", "添付ファイル", "이메일이나 전자 문서에 덧붙여 함께 보내는 컴퓨터 파일", "명사", "상세 견적서는 메일에 첨부파일로 보내드렸습니다.", "The detailed quotation was sent as an email attachment.", "詳細なお見積書はメールに添付ファイルとしてお送りしました。"),
    ("출근", "[chul-geun]", "Going to work / Clock-in", "出勤", "일하러 직장에 나감", "명사", "우리 회사는 자율 출퇴근제라 10시까지 출근해도 돼요.", "Our company has flexible hours, so we can clock in by 10 AM.", "私たちの会社はフレックスタイム制なので、10時までに出勤すればいいです。"),
    ("퇴근", "[toe-geun]", "Leaving work / Clock-out", "退勤", "하루의 일과를 마치고 직장에서 집으로 돌아감", "명사", "오늘 할 일을 깔끔하게 다 끝내고 정시 퇴근했어요.", "I finished today's tasks cleanly and left work on time.", "今日のやるべきことをすっきりと終えて、定時退勤しました。"),
    ("야근", "[ya-geun]", "Night overtime work", "残業 / 夜勤", "퇴근 시간이 지난 밤늦게까지 직장에서 일함", "명사", "급한 시스템 점검 때문에 어젯밤에 야근을 했습니다.", "Due to urgent system inspection, I worked overtime last night.", "急なシステム点検のため、昨晩残業をしました。"),
    ("연차", "[yeon-cha]", "Annual leave / PTO", "年次有給休暇 / 年休", "1년 동안 근무한 대가로 주어지는 유급 휴가", "명사", "다음 주 월요일에 연차를 쓰고 고향에 다녀올 생각이에요.", "I plan to take annual leave next Monday and visit my hometown.", "来週の月曜日に有給を取って実家に帰省するつもりです。"),
    ("회식", "[hoe-sik]", "Company dinner / Team get-together", "会食 / 飲み会", "직장 동료들이 다 함께 모여 식사나 술자리를 갖는 모임", "명사", "삼겹살에 소주 한잔하며 팀 단합 회식을 가졌습니다.", "We had a team building dinner over pork belly and soju.", "サムギョプサルに焼酎を一杯飲みながら、チーム結束の会食を行いました。"),
    ("대리", "[dae-ri]", "Assistant Manager (title)", "代理", "사원 바로 위의 직급으로 실무를 주도하는 직책", "명사", "김 대리님이 신입 사원 멘토링을 친절하게 맡아 주셨어요.", "Assistant Manager Kim kindly took charge of new employee mentoring.", "キム代理が新入社員のメンタリングを親切に引き受けてくれました。"),
    ("과장", "[gwa-jang]", "Manager (title)", "課長", "팀의 중간 관리자 직책", "명사", "이 안건에 대해서는 박 과장님께 먼저 검토를 요청하세요.", "Regarding this matter, please ask Manager Park for review first.", "この案件については、パク課長にまず検討を依頼してください。"),
    ("팀장", "[tim-jang]", "Team Leader", "チーム長", "한 팀을 총괄하여 이끄는 리더", "명사", "팀장님의 전략적인 결단 덕분에 위기를 넘길 수 있었습니다.", "Thanks to the team leader's strategic decision, we overcame the crisis.", "チーム長の戦略的な決断のおかげで、危機を乗り切ることができました。"),
    ("대표", "[dae-pyo]", "CEO / Representative", "代表 / 社長", "조직이나 회사를 대표하는 최고 책임자", "명사", "대표님께서 신년사에서 혁신과 성장을 강조하셨습니다.", "The CEO emphasized innovation and growth in the New Year address.", "代表が新年の辞で革新と成長を強調されました。"),
    ("잘 부탁드립니다", "[jal bu-tak-deu-rim-ni-da]", "Looking forward to working with you", "よろしくお願いいたします", "새로운 프로젝트나 업무를 시작할 때 상대에게 정중히 건네는 인사", "표현", "이번에 새로 부임한 마케팅 담당자입니다. 잘 부탁드립니다!", "I am the newly appointed marketing manager. Looking forward to working with you!", "この度新しく着任したマーケティング担当者です。よろしくお願いいたします！"),
]
