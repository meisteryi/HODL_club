import 'package:flutter_test/flutter_test.dart';
import 'package:hodl_club/models/hodl_rank.dart';
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
      expect(provider.initialDeposit, 1000000);
      expect(provider.currentValuation, greaterThanOrEqualTo(1000000));
      expect(provider.achievements.length, 8);
      expect(provider.liveOrders.isNotEmpty, isTrue);

      provider.dispose();
    });

    test('Panic sell & Liquidation resets timer and records history', () async {
      final provider = HodlProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      await provider.panicSellAndLiquidate(
        reason: '📱 숏츠/릴스 무한스크롤',
        note: '의지력 방전 반성문',
      );

      expect(provider.liquidationHistory.length, 1);
      expect(provider.liquidationHistory.first.reason, '📱 숏츠/릴스 무한스크롤');
      expect(provider.liquidationHistory.first.note, '의지력 방전 반성문');

      // Resurrection achievement should be unlocked
      final resurrection = provider.achievements.firstWhere((a) => a.id == 'RESURRECTION');
      expect(resurrection.isUnlocked, isTrue);

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
  });
}
