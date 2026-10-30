import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/models/hodl_rank.dart';
import 'package:hodl_club/models/ticker_type.dart';
import 'package:hodl_club/providers/hodl_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HodlRank tests', () {
    test('Correct rank returned based on duration', () {
      expect(HodlRank.getRank(Duration.zero).level, 0);
      expect(HodlRank.getRank(const Duration(minutes: 59)).level, 0);
      expect(HodlRank.getRank(const Duration(hours: 1)).level, 1);
      expect(HodlRank.getRank(const Duration(hours: 6)).level, 2);
      expect(HodlRank.getRank(const Duration(hours: 24)).level, 3);
      expect(HodlRank.getRank(const Duration(days: 3)).level, 4);
      expect(HodlRank.getRank(const Duration(days: 8)).level, 5);
    });
  });

  group('HodlProvider tests', () {
    test('Initialization and calculation properties', () async {
      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isInitialized, isTrue);
      expect(provider.initialDeposit, 0.0);
      expect(provider.currentValuation, greaterThanOrEqualTo(0.0));
      expect(provider.achievements.length, 196);
      expect(provider.liveOrders.isNotEmpty, isTrue);

      provider.dispose();
    });

    test('Panic sell & Liquidation resets timer and applies reduced ttalspi penalty', () async {
      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.panicSellAndLiquidate(
        reason: '📱 숏츠/릴스 무한스크롤',
        note: '의지력 방전 반성문',
      );

      expect(provider.liquidationHistory.length, 1);
      expect(provider.liquidationHistory.first.simulatedLossAmount, 1000); // 딸스피는 1,000P
      expect(provider.liquidationHistory.first.reason, '📱 숏츠/릴스 무한스크롤');
      expect(provider.liquidationHistory.first.note, '의지력 방전 반성문');
      expect(provider.liquidationHistory.first.achievedBadges, isNotNull);

      // Resurrection achievement should be unlocked for the new run
      final resurrection = provider.achievements.firstWhere((a) => a.id == 'RESURRECTION');
      expect(resurrection.isUnlocked, isTrue);

      // Other achievements (like FIRST_CANDLE) should be reset (locked)
      final firstCandle = provider.achievements.firstWhere((a) => a.id == 'FIRST_CANDLE');
      expect(firstCandle.isUnlocked, isFalse);

      provider.dispose();
    });

    test('Circuit breaker success triggers achievement', () async {
      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.triggerCircuitBreakerSuccess();

      final cbAch = provider.achievements.firstWhere((a) => a.id == 'CIRCUIT_BREAKER_HERO');
      expect(cbAch.isUnlocked, isTrue);

      provider.dispose();
    });

    test('2X Leverage mode toggles and applies double liquidation penalty', () async {
      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.isLeverage2x, isFalse);

      await provider.toggleLeverage();
      expect(provider.isLeverage2x, isTrue);

      // 딸스피 2X 레버리지: 2,000P
      await provider.panicSellAndLiquidate(
        reason: '야수의 심장 2X 청산 테스트',
        note: '미수 깡통 찼노',
      );
      expect(provider.liquidationHistory.first.simulatedLossAmount, 2000);
      expect(provider.liquidationHistory.first.reason, contains('[2X 레버리지 반대매매 깡통]'));

      // 야동스피 2X 레버리지: 4,000P
      provider.switchTicker(TickerType.yadongspi);
      await provider.panicSellAndLiquidate(
        reason: '시크릿 2X 청산 테스트',
        note: '야동 미수 깡통',
      );
      expect(provider.liquidationHistory.first.simulatedLossAmount, 4000);

      await provider.toggleLeverage();
      expect(provider.isLeverage2x, isFalse);

      provider.dispose();
    });

    test('5-day streak dividend payout test', () async {
      // 5일 전 시작 시뮬레이션
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5, hours: 1));
      SharedPreferences.setMockInitialValues({
        'hodl_start_time': fiveDaysAgo.toIso8601String(),
        'hodl_ttalspi_base_points': 0.0,
        'hodl_ttalspi_dividend_payouts': 0,
      });

      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 60));

      // 5일 이상이므로 1회 배당금(+1,500P)이 지급되어야 함
      expect(provider.ttalspiDividendPayouts, 1);
      expect(provider.currentPoints, greaterThan(1500.0));

      final dividendAch = provider.achievements.firstWhere((a) => a.id == 'DIVIDEND_5DAYS');
      expect(dividendAch.isUnlocked, isTrue);

      provider.dispose();
    });
  });
}
