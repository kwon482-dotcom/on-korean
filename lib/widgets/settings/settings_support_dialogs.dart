import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/locale_service.dart';

/// 고객지원 및 공지/가이드, 보너스팩, 피드백, 개인정보처리방침 다이얼로그 모음
class SettingsSupportDialogs {
  /// 공지사항 & 학습 가이드
  static void showNotice(BuildContext context) {
    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.orange),
            const SizedBox(width: 8),
            Text(LocaleService.tr('settings_notice_guide')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isJa
                    ? '1. 忘却曲線に基づく反復学習'
                    : (isEn ? '1. Spaced Repetition Learning' : '1. 망각곡선 반복 학습'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isJa
                    ? 'カードをめくる際に「まだ」を押すと、自動的に復習ノートに蓄積され、いつでも集中復習できます。'
                    : (isEn
                        ? 'Cards marked "Don\'t Know" are automatically added to your review queue so you can master them anytime.'
                        : '카드를 넘길 때 [몰라요]를 누르면 자동으로 오답노트에 누적되어 언제든 집중 복습할 수 있습니다.'),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                isJa
                    ? '2. ネイティブ高音質音声(TTS)の設定'
                    : (isEn ? '2. High-Quality Korean Audio (TTS)' : '2. 네이티브 한국어 고음질 발음(TTS) 설정 팁'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isIOS
                    ? (isJa
                        ? 'iPhoneの[設定] > [アクセシビリティ] > [読み上げコンテンツ] > [声] > [韓国語]から「Yuna(ユナ)」などの高音質(プレミアム)音声をダウンロードすると、より自然な発音で学習できます。'
                        : (isEn
                            ? 'In iPhone [Settings] > [Accessibility] > [Spoken Content] > [Voices] > [Korean], download a high-quality (Premium) voice such as "Yuna" for natural native pronunciation.'
                            : '아이폰 [설정] > [손쉬운 사용] > [콘텐츠 말하기] > [음성] > [한국어]에서 "유나(Yuna)" 등의 고품질(프리미엄) 음성을 다운로드하시면 원어민 수준의 자연스러운 음성을 들으실 수 있습니다.'))
                    : (isJa
                        ? 'スマートフォンの[設定] > [ユーザー補助] > [テキスト読み上げ]で「Googleテキスト読み上げ」を選択し、韓国語高音質音声をダウンロードすると、より自然な発音で学習できます。'
                        : (isEn
                            ? 'In your device Settings > Accessibility > Text-to-Speech, select "Google Speech Services" and download Korean high-quality voice for natural pronunciation.'
                            : '스마트폰 [설정] > [일반] > [글자 읽어주기]에서 기본 엔진을 "Google 음성 서비스"로 설정하시고 한국어 고음질 팩을 다운로드하시면 원어민 수준의 자연스러운 음성을 들으실 수 있습니다.')),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                isJa
                    ? '3. AI例文のご案内'
                    : (isEn ? '3. AI-Generated Contextual Examples' : '3. AI 맞춤 예문 안내'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                isJa
                    ? 'Google Gemini AIによる実践例文です。別の例文を確認したい場合は、🔄(再生成)ボタンを押すと新しい例文が作成されます。'
                    : (isEn
                        ? 'Examples are powered by Google Gemini AI. Tap 🔄 to regenerate anytime.'
                        : 'Google Gemini AI 기반 실시간 예문입니다. 어색하거나 마음에 들지 않을 때는 🔄(새로고침) 버튼을 누르면 즉시 새로운 예문이 생성됩니다.'),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleService.tr('btn_confirm')),
          ),
        ],
      ),
    );
  }

  /// 보너스 단어장 배포 안내
  static void showBonusPacks(BuildContext context) {
    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.card_giftcard, color: Colors.teal),
            const SizedBox(width: 8),
            Text(LocaleService.tr('settings_bonus_pack')),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isJa
                  ? '韓国語学習者のためのボーナス単語帳を公式Webにて定期配布しています。'
                  : (isEn
                      ? 'Bonus Korean vocabulary decks are available on our official website.'
                      : '한국어 학습자를 위한 보너스 단어장을 공식 웹사이트에서 정기 배포하고 있습니다.'),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isJa
                        ? '・ TOPIK 必須単語パック\n・ K-POP / K-ドラマ 頻出表現\n・ 韓国旅行・日常会話フレーズ'
                        : (isEn
                            ? '・ TOPIK Essential Vocabulary Pack\n・ K-POP / K-Drama Expressions\n・ Korea Travel & Daily Phrases'
                            : '・ TOPIK 필수 어휘 팩\n・ K-POP / K-드라마 빈출 표현\n・ 한국 여행 & 일상 회화 단어장'),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.teal.shade900,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleService.tr('btn_confirm')),
          ),
        ],
      ),
    );
  }

  /// 문의 및 피드백
  static void showFeedback(BuildContext context) {
    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.mail_outline, color: Colors.amber.shade800),
            const SizedBox(width: 8),
            Text(LocaleService.tr('settings_feedback')),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isJa
                  ? '「三日坊主韓国語」をご利用いただき、誠にありがとうございます！'
                  : (isEn
                      ? 'Thank you for using OnKorean!'
                      : '작심삼일 한국어를 이용해 주셔서 진심으로 감사드립니다!'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              isJa
                  ? '単語データの誤り、アプリの改善案、機能リクエストなど、どんなご意見でもお気軽にお寄せください。迅速に検討・反映いたします。'
                  : (isEn
                      ? 'Feel free to send us bug reports, suggestions, or feedback. We review every message carefully!'
                      : '단어 데이터 오탈자 제보, 앱 개선 아이디어, 기능 건의 사항 등 어떤 의견이든 편하게 보내주세요. 빠르게 검토하여 반영하겠습니다.'),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, size: 20, color: Colors.indigo),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'onkorean@gyugyu.net',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.indigo),
                    tooltip: isJa ? 'メールアドレスをコピー' : (isEn ? 'Copy Email' : '이메일 주소 복사'),
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: 'onkorean@gyugyu.net'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isJa ? 'メールアドレスをコピーしました。' : (isEn ? 'Email address copied.' : '이메일 주소가 복사되었습니다.'),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.send, size: 16),
            label: Text(isJa ? 'メール送信' : (isEn ? 'Send Email' : '메일 보내기')),
            onPressed: () async {
              final uri = Uri.parse('mailto:onkorean@gyugyu.net?subject=[OnKorean] Feedback');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocaleService.tr('btn_confirm')),
          ),
        ],
      ),
    );
  }

  /// 개인정보처리방침 열기
  static Future<void> openPrivacyPolicy(BuildContext context) async {
    final isJa = LocaleService.currentLocale.value.languageCode == 'ja';
    final isEn = LocaleService.currentLocale.value.languageCode == 'en';
    final uri = Uri.parse(
      'https://garnet-toad-cfe.notion.site/Privacy-Policy-40353644b69780a58c19fcdf9206dd96?source=copy_link',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isJa ? 'ブラウザを開けませんでした。' : (isEn ? 'Could not open browser.' : '브라우저를 열 수 없습니다.'),
              ),
            ),
          );
        }
      }
    } catch (_) {}
  }
}
