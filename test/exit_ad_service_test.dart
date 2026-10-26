import 'package:flutter_test/flutter_test.dart';
import 'package:on_korean/services/exit_ad_service.dart';
import 'package:on_korean/services/locale_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ExitAdService has correct ad unit IDs and initial state', () {
    expect(ExitAdService.adUnitId, isNotEmpty);
    expect(ExitAdService.isAdReady, isFalse);
    expect(ExitAdService.nativeAd, isNull);
  });

  test('LocaleService has exit dialog keys in ko, ja, en', () async {
    // Check ko
    await LocaleService.changeLocale('ko');
    expect(LocaleService.tr('exit_dialog_title'), '앱을 종료하시겠습니까?');
    expect(LocaleService.tr('exit_dialog_desc'), contains('오늘의 학습'));
    expect(LocaleService.tr('exit_dialog_confirm'), '앱 종료');
    expect(LocaleService.tr('exit_dialog_cancel'), '취소');

    // Check ja
    await LocaleService.changeLocale('ja');
    expect(LocaleService.tr('exit_dialog_title'), 'アプリを終了しますか？');
    expect(LocaleService.tr('exit_dialog_confirm'), 'アプリ終了');

    // Check en
    await LocaleService.changeLocale('en');
    expect(LocaleService.tr('exit_dialog_title'), 'Exit the app?');
    expect(LocaleService.tr('exit_dialog_confirm'), 'Exit App');
  });
}
