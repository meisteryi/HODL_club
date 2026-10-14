import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/hodl_rank.dart';
import '../models/liquidation_record.dart';

class OrderBookItem {
  final String time;
  final String title;
  final String amount;
  final bool isBuy;

  OrderBookItem({
    required this.time,
    required this.title,
    required this.amount,
    required this.isBuy,
  });
}

class HodlProvider extends ChangeNotifier {
  static const String _keyStartTime = 'hodl_start_time';
  static const String _keyHistory = 'hodl_liquidation_history';
  static const String _keyAchievements = 'hodl_unlocked_achievements';
  static const String _keySafariDismissed = 'hodl_safari_dismissed';

  DateTime? _startTime;
  bool _isInitialized = false;
  Duration _elapsedDuration = Duration.zero;

  // Initial simulated seed: 100,000 KRW (10만원 - 현실적이고 직관적인 시드머니)
  final int _initialDeposit = 100000;
  double _returnRate = 0.0;
  double _jitter = 0.0;

  List<Achievement> _achievements = Achievement.getDefaultAchievements();
  List<LiquidationRecord> _liquidationHistory = [];
  bool _safariPromptDismissed = false;

  Timer? _tickerTimer;
  final Random _random = Random();

  // Simulated live trade stream (호가 / 체결창)
  final List<OrderBookItem> _liveOrders = [];

  // Chart data points
  List<FlSpot> _chartSpots = [];

  // Getters
  bool get isInitialized => _isInitialized;
  DateTime? get startTime => _startTime;
  Duration get elapsedDuration => _elapsedDuration;
  int get initialDeposit => _initialDeposit;
  double get returnRate => _returnRate;
  int get currentValuation => (_initialDeposit * (1 + _returnRate / 100)).round();
  int get profitAmount => currentValuation - _initialDeposit;
  List<Achievement> get achievements => _achievements;
  List<LiquidationRecord> get liquidationHistory => _liquidationHistory;
  bool get safariPromptDismissed => _safariPromptDismissed;
  List<OrderBookItem> get liveOrders => _liveOrders;
  List<FlSpot> get chartSpots => _chartSpots;
  HodlRank get currentRank => HodlRank.getRank(_elapsedDuration);

  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;

  HodlProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStartTimeStr = prefs.getString(_keyStartTime);
    if (savedStartTimeStr != null) {
      _startTime = DateTime.tryParse(savedStartTimeStr) ?? DateTime.now();
    } else {
      _startTime = DateTime.now();
      await prefs.setString(_keyStartTime, _startTime!.toIso8601String());
    }

    _safariPromptDismissed = prefs.getBool(_keySafariDismissed) ?? false;

    // Load Liquidation History
    final historyListJson = prefs.getStringList(_keyHistory) ?? [];
    _liquidationHistory = historyListJson
        .map((str) => LiquidationRecord.fromJson(str))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Load Achievements
    final unlockedIds = prefs.getStringList(_keyAchievements) ?? [];
    _achievements = _achievements.map((ach) {
      if (unlockedIds.contains(ach.id)) {
        return ach.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return ach;
    }).toList();

    _updateCalculations();
    _generateInitialOrders();
    _buildChartSpots();

    _isInitialized = true;
    notifyListeners();

    // Start 1-second ticker timer for live stock experience
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (_startTime == null) return;

    _updateCalculations();

    // Occasional subtle fluctuation for live market effect
    _jitter = (_random.nextDouble() - 0.45) * 0.15;

    // Check automatic achievements
    _checkAutomaticAchievements();

    // Occasionally add simulated live trade (every ~3-5 seconds)
    if (_random.nextInt(10) < 4) {
      _addSimulatedLiveTrade();
    }

    // Refresh chart spots smoothly
    _buildChartSpots();

    notifyListeners();
  }

  void _updateCalculations() {
    if (_startTime == null) return;
    _elapsedDuration = DateTime.now().difference(_startTime!);

    final totalSeconds = _elapsedDuration.inSeconds;
    final totalMinutes = totalSeconds / 60.0;
    final totalHours = totalMinutes / 60.0;
    final totalDays = totalHours / 24.0;

    // Rebalanced Growth Formula:
    // 0-60초: 0% ~ +0.3%
    // 1시간: 약 +3.0%
    // 24시간(1일): 딱 +30.0% (국내 일일 상한가 제한폭 안착)
    // 7일(일주일): 약 +135.0% (원금 2배 이상 떡상)
    // 30일(한 달): 약 +296.0% (수익률 약 3배)
    // 30일 이후: 로그 스케일로 완만하게 증가하여 수십억 인플레이션 방지
    double baseRate;
    if (totalSeconds < 60) {
      baseRate = totalSeconds * 0.005;
    } else if (totalMinutes < 60) {
      baseRate = 0.3 + (totalMinutes * 0.045);
    } else if (totalHours < 24) {
      baseRate = 3.0 + ((totalHours - 1) * 1.17);
    } else if (totalDays < 7) {
      baseRate = 30.0 + ((totalDays - 1) * 17.5);
    } else if (totalDays < 30) {
      baseRate = 135.0 + ((totalDays - 7) * 7.0);
    } else {
      baseRate = 296.0 + (log(totalDays - 29) * 35.0);
    }

    _returnRate = max(0.0, baseRate + _jitter);
  }

  void _buildChartSpots() {
    _chartSpots = getSpotsForPeriod(0);
  }

  List<FlSpot> getSpotsForPeriod(int periodIndex) {
    final effectiveRate = max(15.0, _returnRate);
    final List<FlSpot> spots = [];

    switch (periodIndex) {
      case 0: // 1분봉: 실시간 초단타 (격렬한 덤핑과 V자 반등)
        final factors = [
          0.85, 0.90, 0.95, 0.72, 0.68, 0.79, 0.88, 0.97, 0.92, 1.05, 0.98, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y = effectiveRate * factors[i];
          if (i == factors.length - 1) {
            y = _returnRate;
          } else {
            y += (i % 2 == 0 ? _jitter : -_jitter);
          }
          spots.add(FlSpot(i.toDouble(), max(0.5, y)));
        }
        break;

      case 1: // 10분봉: 스윙 파동 (쌍바닥 W자 패턴과 개미털기)
        final factors = [
          0.45, 0.62, 0.42, 0.68, 0.44, 0.75, 0.86, 0.80, 0.94, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y = effectiveRate * factors[i];
          if (i == factors.length - 1) y = _returnRate;
          spots.add(FlSpot(i.toDouble(), max(0.5, y)));
        }
        break;

      case 2: // 일봉: 계단식 상승 (횡보 매집 → 장대 양봉 갭상승)
        final factors = [
          0.15, 0.16, 0.38, 0.35, 0.64, 0.61, 0.88, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y = effectiveRate * factors[i];
          if (i == factors.length - 1) y = _returnRate;
          spots.add(FlSpot(i.toDouble(), max(0.5, y)));
        }
        break;

      case 3: // 주봉: 장기 거시 상승 (다이아몬드 핸즈 대세 폭등 곡선)
      default:
        final factors = [0.05, 0.14, 0.28, 0.48, 0.74, 1.00];
        for (int i = 0; i < factors.length; i++) {
          double y = effectiveRate * factors[i];
          if (i == factors.length - 1) y = _returnRate;
          spots.add(FlSpot(i.toDouble(), max(0.5, y)));
        }
        break;
    }

    return spots;
  }

  String getPeriodCommentary(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return '🚨 [1분봉] 세력의 인스타 덤핑 공격(-28%) 발생! 지지선에서 V자 반등 중 📈';
      case 1:
        return '📊 [10분봉] 쌍바닥(W패턴) 지지선 구축 완료, 악성 매도 물량 전량 소화';
      case 2:
        return '🚀 [일봉] 횡보 매집 끝! 거래량 터지며 전고점 돌파 장대양봉 출현';
      case 3:
      default:
        return '💎 [주봉] 월가 세력도 두 손 든 다이아몬드 고추 대세 상승 랠리';
    }
  }

  String getEventLabel(int periodIndex, int spotIndex) {
    if (periodIndex == 0) {
      // 1분봉 이벤트
      if (spotIndex == 3 || spotIndex == 4) return '🚨 세력의 릴스 투하 폭락';
      if (spotIndex == 5 || spotIndex == 6) return '🛡️ 폰 던지고 푸쉬업 반등';
      if (spotIndex == 9) return '🔥 신고가 돌파 폭등';
      if (spotIndex == 11) return '● 실시간 호가';
      return 'T-${(11 - spotIndex)}분';
    } else if (periodIndex == 1) {
      // 10분봉 이벤트
      if (spotIndex == 2) return '1차 저점 (충동 위기)';
      if (spotIndex == 4) return '2차 쌍바닥 지지';
      if (spotIndex == 9) return '● 현재가';
      return 'T-${(9 - spotIndex) * 10}분';
    } else if (periodIndex == 2) {
      // 일봉
      if (spotIndex == 2) return '상한가 돌파';
      if (spotIndex == 7) return '● 오늘';
      return 'D-${7 - spotIndex}';
    } else {
      // 주봉
      if (spotIndex == 5) return '● 이번 주';
      return 'W-${5 - spotIndex}';
    }
  }

  void _generateInitialOrders() {
    _liveOrders.clear();
    final sampleOrders = [
      OrderBookItem(time: '방금', title: '금딸 3일차 게이', amount: '피부에 광 돌기 시작함 (+120%)', isBuy: true),
      OrderBookItem(time: '1분 전', title: '헬창 홀더', amount: '폰 집어던지고 푸쉬업 50개 완료', isBuy: true),
      OrderBookItem(time: '2분 전', title: '뇌내 세력', amount: '인스타 릴스 덤핑 공격 방어 성공', isBuy: false),
      OrderBookItem(time: '3분 전', title: '다이아몬드 손', amount: '+1,200,000 NOFAP 풀매수', isBuy: true),
      OrderBookItem(time: '5분 전', title: '찬물샤워 장인', amount: '쿠퍼액 분비 전량 차단 완료', isBuy: true),
    ];
    _liveOrders.addAll(sampleOrders);
  }

  void _addSimulatedLiveTrade() {
    final buyTitles = [
      '금딸 5일차 게이', '다이아몬드 고추', '갓생 현자', '찬물샤워 전도사', '헬스장 상주인', '테스토스테론 괴물'
    ];
    final buyActions = [
      '폰 던지고 스쿼트 30개 매수 (+50%)',
      '눈빛에서 레이저 나오는 중 (상한가)',
      '여사친이 먼저 말 걸었다 이기 (+800%)',
      '+1,500,000 NOFAP 영구 락업',
      '휴지통 전량 폐기 처분 완료'
    ];
    final defenseActions = [
      '새벽 2시 트위터 검색 유혹 덤핑 방어',
      '침대 눕방 중 바지 침투 손가락 격퇴',
      '음란물 사이트 접속 차단 방화벽 가동',
      '현타 직전 서킷브레이커 멘탈 수성'
    ];

    final isPositive = _random.nextDouble() > 0.15;
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    if (isPositive) {
      final title = buyTitles[_random.nextInt(buyTitles.length)];
      final amount = buyActions[_random.nextInt(buyActions.length)];
      _liveOrders.insert(0, OrderBookItem(time: timeStr, title: title, amount: amount, isBuy: true));
    } else {
      final action = defenseActions[_random.nextInt(defenseActions.length)];
      _liveOrders.insert(0, OrderBookItem(time: timeStr, title: '도파민 거래소', amount: action, isBuy: false));
    }

    if (_liveOrders.length > 20) {
      _liveOrders.removeLast();
    }
  }

  int _circuitBreakerCount = 0;
  int get circuitBreakerCount => _circuitBreakerCount;

  Future<void> _checkAutomaticAchievements() async {
    final minutes = _elapsedDuration.inMinutes;
    final hours = _elapsedDuration.inHours;

    // 1. 초기 및 시간 단위
    if (minutes >= 10) await unlockAchievement('FIRST_CANDLE');
    if (minutes >= 30) await unlockAchievement('MIN_30');
    if (hours >= 1) await unlockAchievement('HOUR_HOLDER');
    if (hours >= 3) await unlockAchievement('HOUR_3');
    if (hours >= 6) await unlockAchievement('HOUR_6');
    if (hours >= 12) await unlockAchievement('HOUR_12');

    // 2. 일 단위 돌파
    if (hours >= 24) await unlockAchievement('UPPER_LIMIT');
    if (hours >= 48) await unlockAchievement('WEEKEND_SHIELD');
    if (hours >= 72) await unlockAchievement('DAY_3');
    if (hours >= 96) await unlockAchievement('DAY_4');
    if (hours >= 120) await unlockAchievement('DAY_5');
    if (hours >= 168) await unlockAchievement('STEEL_MENTAL'); // 7 days
    if (hours >= 240) await unlockAchievement('DAY_10');
    if (hours >= 336) await unlockAchievement('DAY_14');
    if (hours >= 504) await unlockAchievement('DAY_21');
    if (hours >= 720) await unlockAchievement('DAY_30');
    if (hours >= 1200) await unlockAchievement('DAY_50');
    if (hours >= 2400) await unlockAchievement('DAY_100');

    // 3. 수익률 단위
    if (_returnRate >= 10.0) await unlockAchievement('RETURN_10');
    if (_returnRate >= 50.0) await unlockAchievement('RETURN_50');
    if (_returnRate >= 100.0) await unlockAchievement('WHALE_CLUB');
    if (_returnRate >= 200.0) await unlockAchievement('RETURN_200');
    if (_returnRate >= 500.0) await unlockAchievement('RETURN_500');

    // 4. 현실 시간대 트리거 (새벽 / 아침)
    final currentHour = DateTime.now().hour;
    if (currentHour >= 2 && currentHour <= 3) {
      await unlockAchievement('MIDNIGHT_SAVIOR');
    } else if (currentHour >= 4 && currentHour <= 5) {
      await unlockAchievement('DAWN_WARRIOR');
    } else if (currentHour >= 6 && currentHour <= 8) {
      await unlockAchievement('MORNING_WOOD');
    }

    // 5. 심리 & 돌발 행동 마일스톤
    if (hours >= 2) await unlockAchievement('CLEAN_BROWSER');
    if (hours >= 5) await unlockAchievement('PAPER_HAND_SHAME');
    if (hours >= 18) await unlockAchievement('COLD_SHOWER');
    if (hours >= 36) await unlockAchievement('DUMBBELL_REP');
    if (hours >= 60) await unlockAchievement('MIRROR_SLAP');
    if (hours >= 144) await unlockAchievement('GIGA_CHAD');

    // 6. 상폐/환생 횟수 마일스톤
    if (_liquidationHistory.length >= 5) {
      await unlockAchievement('PHOENIX_5');
    }
  }

  Future<void> recordChartInspect() async {
    await unlockAchievement('CHART_OBSESSED');
  }

  Future<void> unlockAchievement(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      final prefs = await SharedPreferences.getInstance();
      final unlockedIds = _achievements
          .where((a) => a.isUnlocked)
          .map((a) => a.id)
          .toList();
      await prefs.setStringList(_keyAchievements, unlockedIds);
      notifyListeners();
    }
  }

  // Called when user clears the SOS Circuit Breaker 3-sec tap game
  Future<void> triggerCircuitBreakerSuccess() async {
    _circuitBreakerCount++;
    await unlockAchievement('CIRCUIT_BREAKER_HERO');
    if (_circuitBreakerCount >= 3) {
      await unlockAchievement('CIRCUIT_BREAKER_3');
    }
    if (_circuitBreakerCount >= 10) {
      await unlockAchievement('CIRCUIT_BREAKER_10');
    }
    _addSimulatedLiveTrade();
    notifyListeners();
  }

  // Panic Sell / Liquidation (상장폐지 및 리셋)
  Future<void> panicSellAndLiquidate({
    required String reason,
    required String note,
  }) async {
    // 1. 달성했던 업적 목록 수집 (박제용)
    final achievedBadges = _achievements
        .where((a) => a.isUnlocked)
        .map((a) => '${a.icon} ${a.title}')
        .toList();

    final record = LiquidationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      durationHeld: _elapsedDuration,
      returnRateAchieved: _returnRate,
      simulatedLossAmount: profitAmount > 0 ? profitAmount : _initialDeposit,
      reason: reason,
      note: note,
      achievedBadges: achievedBadges,
    );

    _liquidationHistory.insert(0, record);

    // 2. 명예의 전당(도전과제) 초기화 (새로운 코인 시즌 시작)
    _achievements = Achievement.getDefaultAchievements();

    // Reset Start Time to NOW
    _startTime = DateTime.now();
    _elapsedDuration = Duration.zero;
    _returnRate = 0.0;
    _jitter = 0.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStartTime, _startTime!.toIso8601String());

    final historyJsonList = _liquidationHistory.map((r) => r.toJson()).toList();
    await prefs.setStringList(_keyHistory, historyJsonList);

    // Save reset achievements (초기화 저장)
    await prefs.setStringList(_keyAchievements, []);

    // Resurrection achievement if they restart
    await unlockAchievement('RESURRECTION');

    _updateCalculations();
    _buildChartSpots();
    _generateInitialOrders();

    notifyListeners();
  }

  Future<void> dismissSafariPrompt() async {
    _safariPromptDismissed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySafariDismissed, true);
    notifyListeners();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}
