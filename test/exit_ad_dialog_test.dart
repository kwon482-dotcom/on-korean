import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:on_korean/services/locale_service.dart';
import 'package:on_korean/widgets/exit_ad_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ExitAdDialog renders correctly and dismisses on cancel', (tester) async {
    await LocaleService.changeLocale('ko');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExitAdDialog(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('앱을 종료하시겠습니까?'), findsOneWidget);
    expect(find.text('취소'), findsOneWidget);
    expect(find.text('앱 종료'), findsOneWidget);

    // Tap cancel button
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
  });
}
