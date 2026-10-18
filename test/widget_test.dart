import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Dopamine HODL App renders main dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const DopamineHodlApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('딸스피 (DOSP)'), findsWidgets);
    expect(find.text('대시보드'), findsOneWidget);
    expect(find.text('명예의 전당'), findsOneWidget);
    expect(find.text('현타 회고록'), findsOneWidget);
  });
}
