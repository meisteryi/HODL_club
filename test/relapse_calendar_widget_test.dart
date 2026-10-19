import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/models/liquidation_record.dart';
import 'package:hodl_club/widgets/relapse_calendar_widget.dart';

void main() {
  testWidgets('RelapseCalendarWidget renders calendar and displays records', (WidgetTester tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 14, 30);
    final earlierToday = DateTime(now.year, now.month, now.day, 10, 0);

    final records = [
      LiquidationRecord(
        id: 'rec-1',
        timestamp: earlierToday,
        durationHeld: const Duration(days: 3, hours: 2),
        returnRateAchieved: 45.0,
        simulatedLossAmount: 150000,
        reason: '유튜브 쇼츠 보다가 뇌 정지',
        note: '진짜 오늘부터 금욕한다',
        tickerType: 'ttalspi',
      ),
      LiquidationRecord(
        id: 'rec-2',
        timestamp: today,
        durationHeld: const Duration(hours: 4),
        returnRateAchieved: 5.0,
        simulatedLossAmount: 20000,
        reason: '호기심에 트위터 접속',
        note: '두 번이나 뺐네 하...',
        tickerType: 'yadongspi',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RelapseCalendarWidget(
              records: records,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check month stats summary
    expect(find.text('🍆 1회'), findsOneWidget);
    expect(find.text('🔞 1회'), findsOneWidget);

    // Check multiple overlapping badge counter 'x2'
    expect(find.text('x2'), findsOneWidget);

    // Tap on today cell to view details
    final todayFinder = find.text('${now.day}');
    expect(todayFinder, findsWidgets);
    await tester.ensureVisible(todayFinder.first);
    await tester.tap(todayFinder.first, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Day detail panel should show records
    expect(find.text('유튜브 쇼츠 보다가 뇌 정지'), findsOneWidget);
    expect(find.text('호기심에 트위터 접속'), findsOneWidget);
  });
}
