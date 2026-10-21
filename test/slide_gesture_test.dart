import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/models/ticker_type.dart';
import 'package:hodl_club/providers/hodl_provider.dart';
import 'package:hodl_club/screens/achievements_screen.dart';
import 'package:hodl_club/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DashboardScreen switches ticker on horizontal slide gesture', (WidgetTester tester) async {
    final provider = HodlProvider();

    try {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: DashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Initial state is ttalspi
      expect(provider.activeTicker, TickerType.ttalspi);
      expect(find.text('딸스피 (DOSP)'), findsWidgets);

      // Swipe Left (drag finger from right to left, negative dx)
      await tester.fling(find.byType(PageView), const Offset(-500.0, 0.0), 1500.0);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Now activeTicker should have switched to yadongspi
      expect(provider.activeTicker, TickerType.yadongspi);
      expect(find.text('야동스피 (YDSP)'), findsWidgets);

      // Swipe Right (drag finger from left to right, positive dx)
      await tester.fling(find.byType(PageView), const Offset(500.0, 0.0), 1500.0);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));

      // Now activeTicker should have switched back to ttalspi
      expect(provider.activeTicker, TickerType.ttalspi);
    } finally {
      provider.dispose();
    }
  });

  testWidgets('AchievementsScreen switches ticker on horizontal slide gesture', (WidgetTester tester) async {
    final provider = HodlProvider();

    try {
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: AchievementsScreen(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Initial state
      expect(provider.activeTicker, TickerType.ttalspi);

      // Swipe Left
      await tester.fling(find.byType(PageView), const Offset(-500.0, 0.0), 1500.0);
      await tester.pumpAndSettle();

      // Should have switched to yadongspi
      expect(provider.activeTicker, TickerType.yadongspi);

      // Swipe Right
      await tester.fling(find.byType(PageView), const Offset(500.0, 0.0), 1500.0);
      await tester.pumpAndSettle();

      // Should have switched back to ttalspi
      expect(provider.activeTicker, TickerType.ttalspi);
    } finally {
      provider.dispose();
    }
  });
}
