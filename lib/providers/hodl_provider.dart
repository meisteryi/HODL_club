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

  // Initial simulated deposit: 1,000,000 KRW
  final int _initialDeposit = 1000000;
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
    _jitter = (_random.nextDouble() - 0.35) * 0.8;

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

    // Formula:
    // Starts with steady breakout, accelerating into exponential gains
    // Minute 1-10: +0.5% ~ +15%
    // Hour 1: +45%
    // Day 1: +350%
    // Day 3: +1,200%
    // Day 7+: +5,000%+
    double baseRate;
    if (totalSeconds < 60) {
      baseRate = totalSeconds * 0.15; // 0% ~ 9% in first minute
    } else if (totalMinutes < 60) {
      baseRate = 9.0 + (totalMinutes * 0.6); // Up to ~45%
    } else if (totalHours < 24) {
      baseRate = 45.0 + (totalHours * 12.5); // Up to ~345%
    } else if (totalDays < 7) {
      baseRate = 345.0 + (totalDays * 150.0) + pow(totalDays, 1.8) * 40.0;
    } else {
      baseRate = 1800.0 + (totalDays * 350.0);
    }

    _returnRate = max(0.0, baseRate + _jitter);
  }

  void _buildChartSpots() {
    const int spotCount = 12;
    final List<FlSpot> spots = [];

    for (int i = 0; i < spotCount; i++) {
      final progress = i / (spotCount - 1);

      // Realistic stock curve: upward trend with simulated support bounces
      double yVal = pow(progress, 1.5) * _returnRate;
      if (i > 0 && i < spotCount - 1) {
        // add slight dip and rally
        final wave = sin(i * 1.2) * (progress * 5.0);
        yVal = max(0.0, yVal + wave);
      }
      if (i == spotCount - 1) {
        yVal = _returnRate;
      }
      spots.add(FlSpot(i.toDouble(), yVal));
    }

    _chartSpots = spots;
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

  Future<void> _checkAutomaticAchievements() async {
    final minutes = _elapsedDuration.inMinutes;
    final hours = _elapsedDuration.inHours;

    if (minutes >= 10) await unlockAchievement('FIRST_CANDLE');
    if (hours >= 1) await unlockAchievement('HOUR_HOLDER');
    if (hours >= 24) await unlockAchievement('UPPER_LIMIT');
    if (hours >= 48) await unlockAchievement('WEEKEND_SHIELD');
    if (hours >= 168) await unlockAchievement('STEEL_MENTAL'); // 7 days
    if (_returnRate >= 1000.0) await unlockAchievement('WHALE_CLUB');
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
    await unlockAchievement('CIRCUIT_BREAKER_HERO');
    _addSimulatedLiveTrade();
    notifyListeners();
  }

  // Panic Sell / Liquidation (상장폐지 및 리셋)
  Future<void> panicSellAndLiquidate({
    required String reason,
    required String note,
  }) async {
    final record = LiquidationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      durationHeld: _elapsedDuration,
      returnRateAchieved: _returnRate,
      simulatedLossAmount: profitAmount > 0 ? profitAmount : _initialDeposit,
      reason: reason,
      note: note,
    );

    _liquidationHistory.insert(0, record);

    // Reset Start Time to NOW
    _startTime = DateTime.now();
    _elapsedDuration = Duration.zero;
    _returnRate = 0.0;
    _jitter = 0.0;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStartTime, _startTime!.toIso8601String());

    final historyJsonList = _liquidationHistory.map((r) => r.toJson()).toList();
    await prefs.setStringList(_keyHistory, historyJsonList);

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
