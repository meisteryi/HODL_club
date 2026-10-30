import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/models/ticker_type.dart';
import 'package:hodl_club/providers/hodl_provider.dart';
import 'package:hodl_club/widgets/start_time_picker_modal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'StartTimePickerModal renders cleanly for ttalspi without locale exception',
    (WidgetTester tester) async {
      final provider = HodlProvider();

      try {
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: provider,
            child: MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () =>
                        StartTimePickerModal.show(context, TickerType.ttalspi),
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Tap to open modal
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        // Verify modal contents
        expect(find.textContaining('딸스피 마지막 발사 시점 설정'), findsOneWidget);
        expect(find.text('빠른 선택 프리셋'), findsOneWidget);
        expect(find.text('1일 전'), findsOneWidget);
        expect(find.textContaining('타이머에 적용하기'), findsOneWidget);

        // Tap preset chip '1일 전'
        await tester.tap(find.text('1일 전'));
        await tester.pumpAndSettle();

        expect(find.textContaining('1일 0시간'), findsOneWidget);
      } finally {
        provider.dispose();
      }
    },
  );

  testWidgets('StartTimePickerModal renders cleanly for yadongspi', (
    WidgetTester tester,
  ) async {
    final provider = HodlProvider();

    try {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () =>
                      StartTimePickerModal.show(context, TickerType.yadongspi),
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap to open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Verify modal contents
      expect(find.textContaining('야동스피 마지막 야동 시청 시점 설정'), findsOneWidget);
    } finally {
      provider.dispose();
    }
  });
}
