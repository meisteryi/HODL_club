import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/hodl_rank.dart';
import '../models/liquidation_record.dart';
import '../models/ticker_type.dart';

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
  // SharedPreferences keys
  static const String _keyTtalspiStartTime = 'hodl_start_time';
  static const String _keyTtalspiBasePoints = 'hodl_ttalspi_base_points';
  static const String _keyYadongspiStartTime = 'hodl_yadongspi_start_time';
  static const String _keyYadongspiBasePoints = 'hodl_yadongspi_base_points';
  static const String _keyActiveTicker = 'hodl_active_ticker';
  static const String _keyHistory = 'hodl_liquidation_history';
  static const String _keyAchievements = 'hodl_unlocked_achievements'; // legacy
  static const String _keyTtalspiAchievements = 'hodl_ttalspi_unlocked_achievements';
  static const String _keyYadongspiAchievements = 'hodl_yadongspi_unlocked_achievements';
  static const String _keySafariDismissed = 'hodl_safari_dismissed';
  static const String _keyIsLeverage2x = 'hodl_is_leverage_2x';
  static const String _keyTtalspiDividendPayouts = 'hodl_ttalspi_dividend_payouts';
  static const String _keyYadongspiDividendPayouts = 'hodl_yadongspi_dividend_payouts';

  TickerType _activeTicker = TickerType.ttalspi;
  bool _isInitialized = false;
  bool _isLeverage2x = false;

  // 딸스피 (DOSP) state
  DateTime? _ttalspiStartTime;
  double _ttalspiBasePoints = 0.0;
  Duration _ttalspiElapsed = Duration.zero;
  double _ttalspiPoints = 0.0;
  Set<String> _ttalspiUnlockedIds = {};
  int _ttalspiDividendPayouts = 0;

  // 야동스피 (YDSP) state
  DateTime? _yadongspiStartTime;
  double _yadongspiBasePoints = 0.0;
  Duration _yadongspiElapsed = Duration.zero;
  double _yadongspiPoints = 0.0;
  Set<String> _yadongspiUnlockedIds = {};
  int _yadongspiDividendPayouts = 0;

  double _jitter = 0.0;

  List<LiquidationRecord> _liquidationHistory = [];
  bool _safariPromptDismissed = false;

  Timer? _tickerTimer;
  bool _isDisposed = false;
  final Random _random = Random();

  // Simulated live trade stream (호가 / 체결창)
  final List<OrderBookItem> _liveOrders = [];

  // Chart data points
  List<FlSpot> _chartSpots = [];

  int _circuitBreakerCount = 0;

  // In-app achievement notification queue
  final List<Achievement> _achievementNotificationQueue = [];
  Achievement? _currentAchievementNotification;
  Achievement? get currentAchievementNotification => _currentAchievementNotification;

  void dismissCurrentAchievementNotification() {
    if (_achievementNotificationQueue.isNotEmpty) {
      _currentAchievementNotification = _achievementNotificationQueue.removeAt(0);
    } else {
      _currentAchievementNotification = null;
    }
    notifyListeners();
  }

  // Getters
  bool get isInitialized => _isInitialized;
  TickerType get activeTicker => _activeTicker;
  bool get isLeverage2x => _isLeverage2x;

  // Active ticker specific getters
  DateTime? get startTime =>
      _activeTicker == TickerType.ttalspi ? _ttalspiStartTime : _yadongspiStartTime;

  Duration get elapsedDuration =>
      _activeTicker == TickerType.ttalspi ? _ttalspiElapsed : _yadongspiElapsed;

  // Current index points (시작 0, 하루에 +1000P, 딸 시 -1000P / 야동 시 -2000P)
  double get currentPoints =>
      _activeTicker == TickerType.ttalspi ? _ttalspiPoints : _yadongspiPoints;

  // 상폐 페널티 (딸스피: 1X -1,000P / 2X -2,000P, 야동스피: 1X -2,000P / 2X -4,000P)
  int get currentLossAmount => getLossAmountFor(_activeTicker);

  int getLossAmountFor(TickerType ticker) {
    final isYadong = ticker == TickerType.yadongspi;
    final baseLoss = isYadong ? 2000 : 1000;
    return _isLeverage2x ? baseLoss * 2 : baseLoss;
  }

  // 5일 연속 존버 정기 배당금 (회당 +1,500P) 상태
  int get ttalspiDividendPayouts => _ttalspiDividendPayouts;
  int get yadongspiDividendPayouts => _yadongspiDividendPayouts;
  int get activeDividendPayouts =>
      _activeTicker == TickerType.ttalspi ? _ttalspiDividendPayouts : _yadongspiDividendPayouts;

  Duration get nextDividendRemaining {
    final elapsed = elapsedDuration;
    const cycleSeconds = 5 * 86400;
    final currentCycleSec = elapsed.inSeconds % cycleSeconds;
    return Duration(seconds: cycleSeconds - currentCycleSec);
  }

  int get nextDividendDaysRemaining {
    final remaining = nextDividendRemaining;
    return remaining.inDays + 1;
  }

  // Legacy compatibility getters for widgets expecting currency/rate
  int get initialDeposit => 0; // 시작가 0
  double get returnRate => currentPoints;
  int get currentValuation => currentPoints.round();
  int get profitAmount => currentPoints.round();

  // Dual values for header ticker display
  double get ttalspiPoints => _ttalspiPoints;
  double get yadongspiPoints => _yadongspiPoints;
  Duration get ttalspiElapsed => _ttalspiElapsed;
  Duration get yadongspiElapsed => _yadongspiElapsed;
  DateTime? get ttalspiStartTime => _ttalspiStartTime;
  DateTime? get yadongspiStartTime => _yadongspiStartTime;

  // 테스토스테론 종합 지수: 딸스피와 야동스피의 평균
  double get testosteronePoints => (_ttalspiPoints + _yadongspiPoints) / 2.0;

  List<Achievement> getAchievementsFor(TickerType ticker) {
    final unlockedSet =
        ticker == TickerType.yadongspi ? _yadongspiUnlockedIds : _ttalspiUnlockedIds;
    return Achievement.getDefaultAchievements().map((ach) {
      if (unlockedSet.contains(ach.id)) {
        return ach.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
      return ach;
    }).toList();
  }

  List<Achievement> get achievements => getAchievementsFor(_activeTicker);

  List<LiquidationRecord> get liquidationHistory => _liquidationHistory;
  bool get safariPromptDismissed => _safariPromptDismissed;
  List<OrderBookItem> get liveOrders => _liveOrders;
  List<FlSpot> get chartSpots => _chartSpots;
  HodlRank get currentRank =>
      HodlRank.getRank(elapsedDuration, ticker: _activeTicker);
  int get circuitBreakerCount => _circuitBreakerCount;

  // Filtered achievements by active ticker category
  List<Achievement> get currentTickerAchievements {
    final cat = _activeTicker.name;
    return achievements
        .where((a) => a.category == 'all' || a.category == cat)
        .toList();
  }

  int get unlockedCount =>
      currentTickerAchievements.where((a) => a.isUnlocked).length;
  int get totalCount => currentTickerAchievements.length;

  int getUnlockedCountFor(TickerType ticker) {
    final list = getAchievementsFor(ticker)
        .where((a) => a.category == 'all' || a.category == ticker.name)
        .toList();
    return list.where((a) => a.isUnlocked).length;
  }

  int getTotalCountFor(TickerType ticker) {
    return getAchievementsFor(ticker)
        .where((a) => a.category == 'all' || a.category == ticker.name)
        .length;
  }

  // Filtered liquidation history by active ticker
  List<LiquidationRecord> get currentTickerHistory {
    return _liquidationHistory
        .where((r) => r.tickerType == _activeTicker.name)
        .toList();
  }

  HodlProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Active ticker
    final savedTickerName = prefs.getString(_keyActiveTicker);
    if (savedTickerName != null) {
      _activeTicker = TickerType.values.firstWhere(
        (t) => t.name == savedTickerName,
        orElse: () => TickerType.ttalspi,
      );
    }

    // 2. 딸스피 State
    final ttalStartTimeStr = prefs.getString(_keyTtalspiStartTime);
    if (ttalStartTimeStr != null) {
      _ttalspiStartTime = DateTime.tryParse(ttalStartTimeStr) ?? DateTime.now();
    } else {
      _ttalspiStartTime = DateTime.now();
      await prefs.setString(_keyTtalspiStartTime, _ttalspiStartTime!.toIso8601String());
    }
    _ttalspiBasePoints = prefs.getDouble(_keyTtalspiBasePoints) ?? 0.0;

    // 3. 야동스피 State
    final yadongStartTimeStr = prefs.getString(_keyYadongspiStartTime);
    if (yadongStartTimeStr != null) {
      _yadongspiStartTime = DateTime.tryParse(yadongStartTimeStr) ?? DateTime.now();
    } else {
      _yadongspiStartTime = DateTime.now();
      await prefs.setString(_keyYadongspiStartTime, _yadongspiStartTime!.toIso8601String());
    }
    _yadongspiBasePoints = prefs.getDouble(_keyYadongspiBasePoints) ?? 0.0;

    _safariPromptDismissed = prefs.getBool(_keySafariDismissed) ?? false;
    _isLeverage2x = prefs.getBool(_keyIsLeverage2x) ?? false;
    _ttalspiDividendPayouts = prefs.getInt(_keyTtalspiDividendPayouts) ?? 0;
    _yadongspiDividendPayouts = prefs.getInt(_keyYadongspiDividendPayouts) ?? 0;

    // 4. Liquidation History
    final historyListJson = prefs.getStringList(_keyHistory) ?? [];
    _liquidationHistory = historyListJson
        .map((str) => LiquidationRecord.fromJson(str))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 5. Achievements migration & load
    final legacyUnlocked = prefs.getStringList(_keyAchievements) ?? [];
    final ttalUnlocked =
        prefs.getStringList(_keyTtalspiAchievements) ?? legacyUnlocked;
    final yadongUnlocked =
        prefs.getStringList(_keyYadongspiAchievements) ?? [];

    _ttalspiUnlockedIds = ttalUnlocked.toSet();
    _yadongspiUnlockedIds = yadongUnlocked.toSet();

    _updateCalculations();
    _generateInitialOrders();
    _buildChartSpots();
    await _checkDividends();

    _isInitialized = true;
    notifyListeners();

    // Start 1-second ticker timer for live stock experience
    if (_isDisposed) return;
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void switchTicker(TickerType ticker) async {
    if (_activeTicker == ticker) return;
    _activeTicker = ticker;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveTicker, ticker.name);

    _updateCalculations();
    _generateInitialOrders();
    _buildChartSpots();
    await unlockAchievement('TICKER_SWITCHER');
    notifyListeners();
  }

  Future<void> toggleLeverage() async {
    final now = DateTime.now();
    // Snapshot base points so switching leverage rate preserves previously accumulated points
    _updateCalculations();
    _ttalspiBasePoints = _ttalspiPoints;
    _ttalspiStartTime = now;
    _yadongspiBasePoints = _yadongspiPoints;
    _yadongspiStartTime = now;

    _isLeverage2x = !_isLeverage2x;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLeverage2x, _isLeverage2x);
    await prefs.setDouble(_keyTtalspiBasePoints, _ttalspiBasePoints);
    await prefs.setString(_keyTtalspiStartTime, now.toIso8601String());
    await prefs.setDouble(_keyYadongspiBasePoints, _yadongspiBasePoints);
    await prefs.setString(_keyYadongspiStartTime, now.toIso8601String());

    if (_isLeverage2x) {
      _liveOrders.insert(
        0,
        OrderBookItem(
          time: '방금',
          title: '야수의 심장',
          amount: '신용 2X 풀미수 몰빵!! 뇌 녹아내리는 중 ㅋㅋㅋ',
          isBuy: true,
        ),
      );
    } else {
      _liveOrders.insert(
        0,
        OrderBookItem(
          time: '방금',
          title: '쫄보 갤러',
          amount: '1X 정석 존버 모드로 안전 복귀',
          isBuy: true,
        ),
      );
    }

    _updateCalculations();
    _buildChartSpots();
    notifyListeners();
  }

  void _tick() {
    _updateCalculations();

    // Occasional subtle fluctuation for live market effect
    _jitter = (_random.nextDouble() - 0.45) * 0.15;

    // Check automatic achievements
    _checkAutomaticAchievements();

    // Check 5-day HODL dividend payouts
    _checkDividends();

    // Occasionally add simulated live trade (every ~3-5 seconds)
    if (_random.nextInt(10) < 4) {
      _addSimulatedLiveTrade();
    }

    // Refresh chart spots smoothly
    _buildChartSpots();

    notifyListeners();
  }

  // 5일 연속 무발사/노야동 존버 시 정기 배당금 (+1,500P) 지급
  Future<void> _checkDividends() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. 딸스피 5일 주기 배당 체크
    final ttalDays = _ttalspiElapsed.inDays;
    final ttalspiEligible = ttalDays ~/ 5;
    if (ttalspiEligible > _ttalspiDividendPayouts) {
      final newPayouts = ttalspiEligible - _ttalspiDividendPayouts;
      final bonus = newPayouts * 1500.0;
      _ttalspiBasePoints += bonus;
      _ttalspiDividendPayouts = ttalspiEligible;
      await prefs.setDouble(_keyTtalspiBasePoints, _ttalspiBasePoints);
      await prefs.setInt(_keyTtalspiDividendPayouts, _ttalspiDividendPayouts);

      _liveOrders.insert(
        0,
        OrderBookItem(
          time: '방금',
          title: '💰 정기 배당금 입금',
          amount: '딸스피 ${ttalspiEligible * 5}일 연속 존버 달성! 주주 환원 배당금 +${bonus.toInt()}P 입금',
          isBuy: true,
        ),
      );
      await unlockAchievement('DIVIDEND_5DAYS', ticker: TickerType.ttalspi);
    }

    // 2. 야동스피 5일 주기 배당 체크
    final yadongDays = _yadongspiElapsed.inDays;
    final yadongEligible = yadongDays ~/ 5;
    if (yadongEligible > _yadongspiDividendPayouts) {
      final newPayouts = yadongEligible - _yadongspiDividendPayouts;
      final bonus = newPayouts * 1500.0;
      _yadongspiBasePoints += bonus;
      _yadongspiDividendPayouts = yadongEligible;
      await prefs.setDouble(_keyYadongspiBasePoints, _yadongspiBasePoints);
      await prefs.setInt(_keyYadongspiDividendPayouts, _yadongspiDividendPayouts);

      _liveOrders.insert(
        0,
        OrderBookItem(
          time: '방금',
          title: '💰 정기 배당금 입금',
          amount: '야동스피 ${yadongEligible * 5}일 연속 존버 달성! 주주 환원 배당금 +${bonus.toInt()}P 입금',
          isBuy: true,
        ),
      );
      await unlockAchievement('DIVIDEND_5DAYS', ticker: TickerType.yadongspi);
    }
  }

  void _updateCalculations() {
    final now = DateTime.now();

    // 1X: 1000 P / day, 2X Leverage: 2000 P / day
    final double multiplier = _isLeverage2x ? 2.0 : 1.0;
    final double pointsPerSecond = (1000.0 / 86400.0) * multiplier;

    // 1. 딸스피 계산
    if (_ttalspiStartTime != null) {
      _ttalspiElapsed = now.difference(_ttalspiStartTime!);
      final accumulated = _ttalspiElapsed.inSeconds * pointsPerSecond;
      _ttalspiPoints = _ttalspiBasePoints + accumulated;
    }

    // 2. 야동스피 계산
    if (_yadongspiStartTime != null) {
      _yadongspiElapsed = now.difference(_yadongspiStartTime!);
      final accumulated = _yadongspiElapsed.inSeconds * pointsPerSecond;
      _yadongspiPoints = _yadongspiBasePoints + accumulated;
    }
  }

  void _buildChartSpots() {
    _chartSpots = getSpotsForPeriod(0);
  }

  List<FlSpot> getSpotsForPeriod(int periodIndex) {
    // 테스토스테론 지수: 딸스피와 야동스피의 평균으로 통일
    final tPoint = testosteronePoints;
    final List<FlSpot> spots = [];

    switch (periodIndex) {
      case 0: // 1분봉: 실시간 초단타 (격렬한 덤핑과 V자 반등)
        final factors = [
          0.85, 0.90, 0.95, 0.72, 0.68, 0.79, 0.88, 0.97, 0.92, 1.05, 0.98, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y;
          if (i == factors.length - 1) {
            y = tPoint;
          } else {
            y = tPoint >= 0
                ? max(0.0, tPoint * factors[i] + (i % 2 == 0 ? _jitter : -_jitter))
                : tPoint * (2.0 - factors[i]);
          }
          spots.add(FlSpot(i.toDouble(), y));
        }
        break;

      case 1: // 10분봉: 스윙 파동 (쌍바닥 W자 패턴과 개미털기)
        final factors = [
          0.45, 0.62, 0.42, 0.68, 0.44, 0.75, 0.86, 0.80, 0.94, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y = i == factors.length - 1
              ? tPoint
              : (tPoint >= 0 ? max(0.0, tPoint * factors[i]) : tPoint * (2.0 - factors[i]));
          spots.add(FlSpot(i.toDouble(), y));
        }
        break;

      case 2: // 일봉: 계단식 상승 (횡보 매집 → 장대 양봉 갭상승)
        final factors = [
          0.15, 0.16, 0.38, 0.35, 0.64, 0.61, 0.88, 1.00
        ];
        for (int i = 0; i < factors.length; i++) {
          double y = i == factors.length - 1
              ? tPoint
              : (tPoint >= 0 ? max(0.0, tPoint * factors[i]) : tPoint * (2.0 - factors[i]));
          spots.add(FlSpot(i.toDouble(), y));
        }
        break;

      case 3: // 주봉: 장기 거시 상승 (다이아몬드 핸즈 대세 폭등 곡선)
      default:
        final factors = [0.05, 0.14, 0.28, 0.48, 0.74, 1.00];
        for (int i = 0; i < factors.length; i++) {
          double y = i == factors.length - 1
              ? tPoint
              : (tPoint >= 0 ? max(0.0, tPoint * factors[i]) : tPoint * (2.0 - factors[i]));
          spots.add(FlSpot(i.toDouble(), y));
        }
        break;
    }

    return spots;
  }

  String getPeriodCommentary(int periodIndex) {
    switch (periodIndex) {
      case 0:
        return '🚨 [1분봉] 실시간 유혹 덤핑 방어 중! 테스토스테론 떡상 V자 반등 📈';
      case 1:
        return '📊 [10분봉] 쌍바닥(W패턴) 개미털기 끝났다 이기, 매도 물량 전량 소화';
      case 2:
        return '🚀 [일봉] 딸스피+야동스피 동반 매집! 장대양봉 폭등 랠리 가즈아';
      case 3:
      default:
        return '💎 [주봉] 7일차 테스토스테론 145.7% 피크! 야수의 심장 대세 폭등';
    }
  }

  String getEventLabel(int periodIndex, int spotIndex) {
    final isYadong = _activeTicker == TickerType.yadongspi;
    if (periodIndex == 0) {
      if (spotIndex == 3 || spotIndex == 4) {
        return isYadong ? '🚨 시크릿탭 켤 뻔하다 대가리 깸' : '🚨 세력의 여캠 릴스 융단폭격';
      }
      if (spotIndex == 5 || spotIndex == 6) {
        return isYadong ? '🛡️ 브라우저 끄고 찬물 한 사발' : '🛡️ 폰 집어던지고 푸쉬업 50개';
      }
      if (spotIndex == 9) return '🔥 신고가 돌파 가즈아';
      if (spotIndex == 11) return '● 실시간 호가';
      return 'T-${(11 - spotIndex)}분';
    } else if (periodIndex == 1) {
      if (spotIndex == 2) return '1차 저점 (유혹 위기)';
      if (spotIndex == 4) return '2차 쌍바닥 지지';
      if (spotIndex == 9) return '● 현재가';
      return 'T-${(9 - spotIndex) * 10}분';
    } else if (periodIndex == 2) {
      if (spotIndex == 2) return '+1,000P 돌파';
      if (spotIndex == 7) return '● 오늘';
      return 'D-${7 - spotIndex}';
    } else {
      if (spotIndex == 5) return '● 이번 주';
      return 'W-${5 - spotIndex}';
    }
  }

  void _generateInitialOrders() {
    _liveOrders.clear();
    final isYadong = _activeTicker == TickerType.yadongspi;
    final sampleOrders = isYadong
        ? [
            OrderBookItem(time: '방금', title: '노야동 2일차 게이', amount: '시크릿탭 0개 유지 중 (+2,000P)', isBuy: true),
            OrderBookItem(time: '1분 전', title: '클린 브라우저', amount: '트위터 음란 검색 차단 성공 ㅋㅋㅋ', isBuy: true),
            OrderBookItem(time: '2분 전', title: '전두엽 수호대', amount: '폰 집어던지고 현실 독서 30분', isBuy: true),
            OrderBookItem(time: '3분 전', title: '청정 갓생러', amount: '야동스피 +1,000P 풀매수 가즈아', isBuy: true),
            OrderBookItem(time: '5분 전', title: '퇴마사 갤러', amount: '음란마귀 침투 전량 방어 완료', isBuy: true),
          ]
        : [
            OrderBookItem(time: '방금', title: '금딸 3일차 게이', amount: '얼굴에 개기름 빠지고 광 돈다 (+3,000P)', isBuy: true),
            OrderBookItem(time: '1분 전', title: '헬창 갤러', amount: '폰 집어던지고 푸쉬업 50개 조짐', isBuy: true),
            OrderBookItem(time: '2분 전', title: '도파민 세력', amount: '인스타 릴스 융단폭격 쳐내기 성공', isBuy: false),
            OrderBookItem(time: '3분 전', title: '다이아몬드 손', amount: '+1,000P 딸스피 영구 락업', isBuy: true),
            OrderBookItem(time: '5분 전', title: '찬물샤워 장인', amount: '쿠퍼액 분비 전량 차단 완료 ㅋㅋ', isBuy: true),
          ];
    _liveOrders.addAll(sampleOrders);
  }

  void _addSimulatedLiveTrade() {
    final isYadong = _activeTicker == TickerType.yadongspi;
    final buyTitles = isYadong
        ? ['노야동 3일차', '시크릿탭 분쇄자', '청정 전두엽', '트위터 삭제러', '안광 레이저 갤러', '야수의 심장 2X']
        : ['금딸 5일차 게이', '다이아몬드 손', '갓생 현자', '찬물샤워 전도사', '헬스장 상주인', '흑우 탈출러'];

    final buyActions = isYadong
        ? [
            '폰 던지고 스쿼트 30개 매수 (+50P)',
            '시크릿 모드 대신 플러터 코딩 (+200P)',
            '동태눈깔 탈출하고 집중력 떡상 중',
            '+1,000P 야동스피 추가 락업 가즈아',
            '브라우저 즐겨찾기 전량 삭제 완료 ㅋㅋ',
            '인스타 돋보기 여캠 차단 박았다 이기',
          ]
        : [
            '바지 속 손 몽둥이로 쳐냄 (+50P)',
            '눈빛에서 테스토스테론 레이저 발사',
            '여사친이 먼저 카톡 왔다 이기 (+800P)',
            '+1,000P 딸스피 영구 락업 완료',
            '방구석 휴지통 전량 폐기 처분 ㅋㅋ',
            '딸 치면 한강 간다 손 묶어라 (+500P)',
          ];

    final defenseActions = isYadong
        ? [
            '새벽 2시 폰허브 북마크 유혹 덤핑 방어',
            '인스타 돋보기 여캠 릴스 융단폭격 방어',
            '시크릿창 켜려던 손가락 응급 물리치료',
            '음란마귀 속삭임 차단 방화벽 가동',
            '검색창에 칠 뻔한 거 키보드 뽑음 ㅋㅋ',
          ]
        : [
            '새벽 2시 트위터 검색 유혹 덤핑 방어',
            '침대 눕방 중 바지 침투 손가락 격퇴',
            '음란물 사이트 접속 차단 방화벽 가동',
            '현타 직전 서킷브레이커 멘탈 수성',
            '쿠퍼액 누출 경보 발령 후 찬물 세수',
          ];

    final isPositive = _random.nextDouble() > 0.15;
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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
    // 0. 공통 첫 시작
    await unlockAchievement('APP_FIRST_LAUNCH');

    // 1. 딸스피 자동 체크
    final ttalMin = _ttalspiElapsed.inMinutes;
    final ttalHrs = _ttalspiElapsed.inHours;

    // 딸스피 시간(분)
    if (ttalMin >= 1) await unlockAchievement('TT_MIN_1', ticker: TickerType.ttalspi);
    if (ttalMin >= 3) await unlockAchievement('TT_MIN_3', ticker: TickerType.ttalspi);
    if (ttalMin >= 5) await unlockAchievement('TT_MIN_5', ticker: TickerType.ttalspi);
    if (ttalMin >= 10) await unlockAchievement('FIRST_CANDLE', ticker: TickerType.ttalspi);
    if (ttalMin >= 15) await unlockAchievement('TT_MIN_15', ticker: TickerType.ttalspi);
    if (ttalMin >= 20) await unlockAchievement('TT_MIN_20', ticker: TickerType.ttalspi);
    if (ttalMin >= 30) await unlockAchievement('MIN_30', ticker: TickerType.ttalspi);
    if (ttalMin >= 45) await unlockAchievement('TT_MIN_45', ticker: TickerType.ttalspi);

    // 딸스피 시간(시간/일)
    if (ttalHrs >= 1) await unlockAchievement('HOUR_HOLDER', ticker: TickerType.ttalspi);
    if (ttalMin >= 90) await unlockAchievement('TT_HOUR_1_5', ticker: TickerType.ttalspi);
    if (ttalHrs >= 2) await unlockAchievement('TT_HOUR_2', ticker: TickerType.ttalspi);
    if (ttalHrs >= 3) await unlockAchievement('HOUR_3', ticker: TickerType.ttalspi);
    if (ttalHrs >= 4) await unlockAchievement('TT_HOUR_4', ticker: TickerType.ttalspi);
    if (ttalHrs >= 5) await unlockAchievement('TT_HOUR_5', ticker: TickerType.ttalspi);
    if (ttalHrs >= 6) await unlockAchievement('HOUR_6', ticker: TickerType.ttalspi);
    if (ttalHrs >= 8) await unlockAchievement('TT_HOUR_8', ticker: TickerType.ttalspi);
    if (ttalHrs >= 10) await unlockAchievement('TT_HOUR_10', ticker: TickerType.ttalspi);
    if (ttalHrs >= 12) await unlockAchievement('HOUR_12', ticker: TickerType.ttalspi);
    if (ttalHrs >= 15) await unlockAchievement('TT_HOUR_15', ticker: TickerType.ttalspi);
    if (ttalHrs >= 18) await unlockAchievement('TT_HOUR_18', ticker: TickerType.ttalspi);
    if (ttalHrs >= 21) await unlockAchievement('TT_HOUR_21', ticker: TickerType.ttalspi);
    if (ttalHrs >= 24) await unlockAchievement('UPPER_LIMIT', ticker: TickerType.ttalspi);
    if (ttalHrs >= 30) await unlockAchievement('TT_HOUR_30', ticker: TickerType.ttalspi);
    if (ttalHrs >= 36) await unlockAchievement('TT_HOUR_36', ticker: TickerType.ttalspi);
    if (ttalHrs >= 42) await unlockAchievement('TT_HOUR_42', ticker: TickerType.ttalspi);
    if (ttalHrs >= 48) await unlockAchievement('WEEKEND_SHIELD', ticker: TickerType.ttalspi);
    if (ttalHrs >= 60) await unlockAchievement('TT_HOUR_60', ticker: TickerType.ttalspi);
    if (ttalHrs >= 72) await unlockAchievement('DAY_3', ticker: TickerType.ttalspi);
    if (ttalHrs >= 96) await unlockAchievement('DAY_4', ticker: TickerType.ttalspi);
    if (ttalHrs >= 120) await unlockAchievement('DAY_5', ticker: TickerType.ttalspi);
    if (ttalHrs >= 144) await unlockAchievement('TT_DAY_6', ticker: TickerType.ttalspi);
    if (ttalHrs >= 168) await unlockAchievement('STEEL_MENTAL', ticker: TickerType.ttalspi);
    if (ttalHrs >= 192) await unlockAchievement('TT_DAY_8', ticker: TickerType.ttalspi);
    if (ttalHrs >= 216) await unlockAchievement('TT_DAY_9', ticker: TickerType.ttalspi);
    if (ttalHrs >= 240) await unlockAchievement('DAY_10', ticker: TickerType.ttalspi);
    if (ttalHrs >= 336) await unlockAchievement('DAY_14', ticker: TickerType.ttalspi);
    if (ttalHrs >= 504) await unlockAchievement('DAY_21', ticker: TickerType.ttalspi);
    if (ttalHrs >= 720) await unlockAchievement('DAY_30', ticker: TickerType.ttalspi);
    if (ttalHrs >= 1200) await unlockAchievement('DAY_50', ticker: TickerType.ttalspi);
    if (ttalHrs >= 2400) await unlockAchievement('DAY_100', ticker: TickerType.ttalspi);

    // 딸스피 포인트 마일스톤
    if (_ttalspiPoints >= 10.0) await unlockAchievement('TT_PTS_10', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 50.0) await unlockAchievement('TT_PTS_50', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 100.0) await unlockAchievement('RETURN_10', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 250.0) await unlockAchievement('TT_PTS_250', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 500.0) await unlockAchievement('RETURN_50', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 750.0) await unlockAchievement('TT_PTS_750', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 1000.0) await unlockAchievement('WHALE_CLUB', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 1500.0) await unlockAchievement('TT_PTS_1500', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 2000.0) await unlockAchievement('RETURN_200', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 3000.0) await unlockAchievement('TT_PTS_3000', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 4000.0) await unlockAchievement('TT_PTS_4000', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 5000.0) await unlockAchievement('RETURN_500', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 7000.0) await unlockAchievement('TT_PTS_7000', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 10000.0) await unlockAchievement('TT_PTS_10000', ticker: TickerType.ttalspi);
    if (_ttalspiPoints >= 20000.0) await unlockAchievement('TT_PTS_20000', ticker: TickerType.ttalspi);

    // 딸스피 신체/심리/상황 변화 마일스톤
    if (ttalHrs >= 2) await unlockAchievement('TT_BELT_LOCK', ticker: TickerType.ttalspi);
    if (ttalHrs >= 4) await unlockAchievement('PAPER_HAND_SHAME', ticker: TickerType.ttalspi);
    if (ttalHrs >= 7) await unlockAchievement('TT_SOAP_DROP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 9) await unlockAchievement('TT_BED_ESCAPE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 11) await unlockAchievement('TT_PIGEON_STARE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 14) await unlockAchievement('TT_MUKBANG_PUPA', ticker: TickerType.ttalspi);
    if (ttalHrs >= 17) await unlockAchievement('TT_VOICE_CAVE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 20) await unlockAchievement('TT_HAND_MUSCLE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 26) await unlockAchievement('TT_GIRL_LASER', ticker: TickerType.ttalspi);
    if (ttalHrs >= 28) await unlockAchievement('TT_PANTS_SNAP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 32) await unlockAchievement('TT_NIGHT_RUN', ticker: TickerType.ttalspi);
    if (ttalHrs >= 38) await unlockAchievement('TT_STAIR_3STEP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 44) await unlockAchievement('TT_PROTEIN_SHOT', ticker: TickerType.ttalspi);
    if (ttalHrs >= 50) await unlockAchievement('TT_HERMIT_MODE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 56) await unlockAchievement('TT_WING_BACK', ticker: TickerType.ttalspi);
    if (ttalHrs >= 65) await unlockAchievement('TT_TISSUE_CRASH', ticker: TickerType.ttalspi);
    if (ttalHrs >= 80) await unlockAchievement('TT_SUBWAY_GRIP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 90) await unlockAchievement('TT_SHAVE_DANGER', ticker: TickerType.ttalspi);
    if (ttalHrs >= 110) await unlockAchievement('TT_CAFE_ORDER', ticker: TickerType.ttalspi);
    if (ttalHrs >= 130) await unlockAchievement('TT_ENERGY_SURGE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 150) await unlockAchievement('TT_CHEST_PUMP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 180) await unlockAchievement('TT_COLD_FACE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 200) await unlockAchievement('TT_SQUAT_BURST', ticker: TickerType.ttalspi);
    if (ttalHrs >= 220) await unlockAchievement('TT_FIST_CLENCH', ticker: TickerType.ttalspi);
    if (ttalHrs >= 260) await unlockAchievement('TT_SMILE_MIRROR', ticker: TickerType.ttalspi);
    if (ttalHrs >= 300) await unlockAchievement('TT_BRAIN_FOG_0', ticker: TickerType.ttalspi);
    if (ttalHrs >= 360) await unlockAchievement('TT_DEEP_SLEEP', ticker: TickerType.ttalspi);
    if (ttalHrs >= 420) await unlockAchievement('TT_DOPAMINE_CLEAN', ticker: TickerType.ttalspi);
    if (ttalHrs >= 480) await unlockAchievement('TT_NO_TEMPTATION', ticker: TickerType.ttalspi);
    if (ttalHrs >= 550) await unlockAchievement('TT_CHAD_WALK', ticker: TickerType.ttalspi);
    if (ttalHrs >= 620) await unlockAchievement('TT_FAMILY_PEACE', ticker: TickerType.ttalspi);
    if (ttalHrs >= 700) await unlockAchievement('TT_DREAM_CONTROL', ticker: TickerType.ttalspi);

    // 딸스피 부활 마일스톤
    final ttalLiquidations = _liquidationHistory.where((r) => r.tickerType == 'ttalspi').length;
    if (ttalLiquidations >= 1) await unlockAchievement('RESURRECTION', ticker: TickerType.ttalspi);
    if (ttalLiquidations >= 5) await unlockAchievement('PHOENIX_5', ticker: TickerType.ttalspi);
    if (ttalLiquidations >= 10) await unlockAchievement('TT_PHOENIX_10', ticker: TickerType.ttalspi);

    // 2. 야동스피 자동 체크
    final ydMin = _yadongspiElapsed.inMinutes;
    final ydHrs = _yadongspiElapsed.inHours;

    await unlockAchievement('YD_INCOGNITO_0S', ticker: TickerType.yadongspi);
    if (ydMin >= 3) await unlockAchievement('YD_MIN_3', ticker: TickerType.yadongspi);
    if (ydMin >= 5) await unlockAchievement('YD_MIN_5', ticker: TickerType.yadongspi);
    if (ydMin >= 10) await unlockAchievement('YD_SECRET_10M', ticker: TickerType.yadongspi);
    if (ydMin >= 15) await unlockAchievement('YD_MIN_15', ticker: TickerType.yadongspi);
    if (ydMin >= 20) await unlockAchievement('YD_MIN_20', ticker: TickerType.yadongspi);
    if (ydMin >= 30) await unlockAchievement('YD_MIN_30', ticker: TickerType.yadongspi);
    if (ydMin >= 45) await unlockAchievement('YD_MIN_45', ticker: TickerType.yadongspi);

    if (ydHrs >= 1) await unlockAchievement('YD_HOUR_1', ticker: TickerType.yadongspi);
    if (ydMin >= 90) await unlockAchievement('YD_HOUR_1_5', ticker: TickerType.yadongspi);
    if (ydHrs >= 2) await unlockAchievement('YD_HOUR_2', ticker: TickerType.yadongspi);
    if (ydHrs >= 3) await unlockAchievement('YD_TWITTER_DELETE', ticker: TickerType.yadongspi);
    if (ydHrs >= 4) await unlockAchievement('YD_HOUR_4', ticker: TickerType.yadongspi);
    if (ydHrs >= 5) await unlockAchievement('YD_HOUR_5', ticker: TickerType.yadongspi);
    if (ydHrs >= 6) await unlockAchievement('YD_HOUR_6', ticker: TickerType.yadongspi);
    if (ydHrs >= 8) await unlockAchievement('YD_HOUR_8', ticker: TickerType.yadongspi);
    if (ydHrs >= 10) await unlockAchievement('YD_HOUR_10', ticker: TickerType.yadongspi);
    if (ydHrs >= 12) await unlockAchievement('YD_HOUR_12', ticker: TickerType.yadongspi);
    if (ydHrs >= 15) await unlockAchievement('YD_HOUR_15', ticker: TickerType.yadongspi);
    if (ydHrs >= 18) await unlockAchievement('YD_HOUR_18', ticker: TickerType.yadongspi);
    if (ydHrs >= 21) await unlockAchievement('YD_HOUR_21', ticker: TickerType.yadongspi);
    if (ydHrs >= 24) await unlockAchievement('YD_CLEAN_24H', ticker: TickerType.yadongspi);
    if (ydHrs >= 30) await unlockAchievement('YD_HOUR_30', ticker: TickerType.yadongspi);
    if (ydHrs >= 36) await unlockAchievement('YD_HOUR_36', ticker: TickerType.yadongspi);
    if (ydHrs >= 42) await unlockAchievement('YD_HOUR_42', ticker: TickerType.yadongspi);
    if (ydHrs >= 48) await unlockAchievement('YD_DAY_2', ticker: TickerType.yadongspi);
    if (ydHrs >= 60) await unlockAchievement('YD_HOUR_60', ticker: TickerType.yadongspi);
    if (ydHrs >= 72) await unlockAchievement('YD_DOPAMINE_DETOX', ticker: TickerType.yadongspi);
    if (ydHrs >= 96) await unlockAchievement('YD_DAY_4', ticker: TickerType.yadongspi);
    if (ydHrs >= 120) await unlockAchievement('YD_DAY_5', ticker: TickerType.yadongspi);
    if (ydHrs >= 144) await unlockAchievement('YD_DAY_6', ticker: TickerType.yadongspi);
    if (ydHrs >= 168) await unlockAchievement('YD_MONK_7D', ticker: TickerType.yadongspi);
    if (ydHrs >= 192) await unlockAchievement('YD_DAY_8', ticker: TickerType.yadongspi);
    if (ydHrs >= 216) await unlockAchievement('YD_DAY_9', ticker: TickerType.yadongspi);
    if (ydHrs >= 240) await unlockAchievement('YD_DAY_10', ticker: TickerType.yadongspi);
    if (ydHrs >= 336) await unlockAchievement('YD_DAY_14', ticker: TickerType.yadongspi);
    if (ydHrs >= 504) await unlockAchievement('YD_DAY_21', ticker: TickerType.yadongspi);
    if (ydHrs >= 720) await unlockAchievement('YD_DAY_30', ticker: TickerType.yadongspi);
    if (ydHrs >= 1200) await unlockAchievement('YD_DAY_50', ticker: TickerType.yadongspi);
    if (ydHrs >= 2400) await unlockAchievement('YD_DAY_100', ticker: TickerType.yadongspi);

    // 야동스피 포인트 마일스톤
    if (_yadongspiPoints >= 10.0) await unlockAchievement('YD_PTS_10', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 50.0) await unlockAchievement('YD_PTS_50', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 100.0) await unlockAchievement('YD_PTS_100', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 250.0) await unlockAchievement('YD_PTS_250', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 500.0) await unlockAchievement('YD_POINTS_500', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 750.0) await unlockAchievement('YD_PTS_750', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 1000.0) await unlockAchievement('YD_PTS_1000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 1500.0) await unlockAchievement('YD_PTS_1500', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 2000.0) await unlockAchievement('YD_POINTS_2000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 3000.0) await unlockAchievement('YD_PTS_3000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 4000.0) await unlockAchievement('YD_PTS_4000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 5000.0) await unlockAchievement('YD_POINTS_5000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 7000.0) await unlockAchievement('YD_PTS_7000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 10000.0) await unlockAchievement('YD_PTS_10000', ticker: TickerType.yadongspi);
    if (_yadongspiPoints >= 20000.0) await unlockAchievement('YD_PTS_20000', ticker: TickerType.yadongspi);

    // 야동스피 디톡스/행동 마일스톤
    if (ydHrs >= 2) await unlockAchievement('YD_CLEAN_HISTORY', ticker: TickerType.yadongspi);
    if (ydHrs >= 4) await unlockAchievement('YD_BOOKMARK_PURGE', ticker: TickerType.yadongspi);
    if (ydHrs >= 7) await unlockAchievement('YD_COLD_WATER', ticker: TickerType.yadongspi);
    if (ydHrs >= 9) await unlockAchievement('YD_PUSHUP_DEFENSE', ticker: TickerType.yadongspi);
    if (ydHrs >= 11) await unlockAchievement('YD_AIRPLANE_MODE', ticker: TickerType.yadongspi);
    if (ydHrs >= 14) await unlockAchievement('YD_FAR_CHARGER', ticker: TickerType.yadongspi);
    if (ydHrs >= 17) await unlockAchievement('YD_CLASSIC_SEARCH', ticker: TickerType.yadongspi);
    if (ydHrs >= 20) await unlockAchievement('YD_NATURE_DOCU', ticker: TickerType.yadongspi);
    if (ydHrs >= 26) await unlockAchievement('YD_RAIN_SOUND', ticker: TickerType.yadongspi);
    if (ydHrs >= 28) await unlockAchievement('YD_CEILING_WATCH', ticker: TickerType.yadongspi);
    if (ydHrs >= 32) await unlockAchievement('YD_SQUAT_STOP', ticker: TickerType.yadongspi);
    if (ydHrs >= 38) await unlockAchievement('YD_SCREEN_TIME', ticker: TickerType.yadongspi);
    if (ydHrs >= 44) await unlockAchievement('YD_BROWSER_RESET', ticker: TickerType.yadongspi);
    if (ydHrs >= 50) await unlockAchievement('YD_CAFE_PEOPLE', ticker: TickerType.yadongspi);
    if (ydHrs >= 56) await unlockAchievement('YD_ICE_WATER_CHUG', ticker: TickerType.yadongspi);
    if (ydHrs >= 65) await unlockAchievement('YD_BED_LEAP', ticker: TickerType.yadongspi);
    if (ydHrs >= 80) await unlockAchievement('YD_SNS_LOGOUT', ticker: TickerType.yadongspi);
    if (ydHrs >= 90) await unlockAchievement('YD_DARK_MODE_OFF', ticker: TickerType.yadongspi);
    if (ydHrs >= 110) await unlockAchievement('YD_GRASS_TOUCH', ticker: TickerType.yadongspi);
    if (ydHrs >= 130) await unlockAchievement('YD_BOOK_FINISH', ticker: TickerType.yadongspi);
    if (ydHrs >= 150) await unlockAchievement('YD_PENCIL_WRITE', ticker: TickerType.yadongspi);
    if (ydHrs >= 180) await unlockAchievement('YD_WINDOW_AIR', ticker: TickerType.yadongspi);
    if (ydHrs >= 200) await unlockAchievement('YD_SHOWER_SING', ticker: TickerType.yadongspi);
    if (ydHrs >= 220) await unlockAchievement('YD_CLEAN_ROOM', ticker: TickerType.yadongspi);
    if (ydHrs >= 260) await unlockAchievement('YD_PULLUP_BAR', ticker: TickerType.yadongspi);
    if (ydHrs >= 300) await unlockAchievement('YD_FACE_SLAP', ticker: TickerType.yadongspi);
    if (ydHrs >= 360) await unlockAchievement('YD_HOT_TEA', ticker: TickerType.yadongspi);
    if (ydHrs >= 420) await unlockAchievement('YD_FOOD_TASTE', ticker: TickerType.yadongspi);
    if (ydHrs >= 480) await unlockAchievement('YD_EAR_MASSAGE', ticker: TickerType.yadongspi);
    if (ydHrs >= 550) await unlockAchievement('YD_DESK_PUSHUP', ticker: TickerType.yadongspi);
    if (ydHrs >= 620) await unlockAchievement('YD_NO_CURIOUS', ticker: TickerType.yadongspi);
    if (ydHrs >= 700) await unlockAchievement('YD_REAL_TALK', ticker: TickerType.yadongspi);

    // 야동스피 부활 마일스톤
    final ydLiquidations = _liquidationHistory.where((r) => r.tickerType == 'yadongspi').length;
    if (ydLiquidations >= 1) await unlockAchievement('YD_RESURRECTION', ticker: TickerType.yadongspi);
    if (ydLiquidations >= 5) await unlockAchievement('YD_PHOENIX_5', ticker: TickerType.yadongspi);
    if (ydLiquidations >= 10) await unlockAchievement('YD_PHOENIX_10', ticker: TickerType.yadongspi);

    // 3. 공통 마일스톤
    final maxHrs = ttalHrs > ydHrs ? ttalHrs : ydHrs;
    if (maxHrs >= 18) await unlockAchievement('COLD_SHOWER');
    if (maxHrs >= 24) await unlockAchievement('NO_PULLBACK');
    if (maxHrs >= 36) await unlockAchievement('DUMBBELL_REP');
    if (maxHrs >= 60) await unlockAchievement('MIRROR_SLAP');
    if (maxHrs >= 72) await unlockAchievement('DIAMOND_MIND');
    if (maxHrs >= 144) await unlockAchievement('GIGA_CHAD');

    // 현실 시간대 트리거 (새벽 / 아침)
    final currentHour = DateTime.now().hour;
    if (currentHour >= 2 && currentHour <= 3) {
      await unlockAchievement('MIDNIGHT_SAVIOR');
    } else if (currentHour >= 4 && currentHour <= 5) {
      await unlockAchievement('DAWN_WARRIOR');
    } else if (currentHour >= 6 && currentHour <= 8) {
      await unlockAchievement('MORNING_WOOD');
    }
  }

  Future<void> recordChartInspect() async {
    await unlockAchievement('CHART_OBSESSED');
  }

  Future<void> unlockAchievement(String id, {TickerType? ticker}) async {
    final targetTicker = ticker ?? _activeTicker;
    final isYadong = targetTicker == TickerType.yadongspi;
    final targetSet = isYadong ? _yadongspiUnlockedIds : _ttalspiUnlockedIds;

    if (!targetSet.contains(id)) {
      targetSet.add(id);
      final prefs = await SharedPreferences.getInstance();
      if (isYadong) {
        await prefs.setStringList(_keyYadongspiAchievements, targetSet.toList());
      } else {
        await prefs.setStringList(_keyTtalspiAchievements, targetSet.toList());
      }

      // Enqueue in-app toast notification
      final ach = achievements.firstWhere(
        (a) => a.id == id,
        orElse: () => Achievement(
          id: id,
          title: '도전과제 달성!',
          subtitle: '',
          description: '',
          icon: '🏆',
          rewardTitle: '',
        ),
      );
      if (_currentAchievementNotification == null) {
        _currentAchievementNotification = ach;
      } else {
        _achievementNotificationQueue.add(ach);
      }

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

  // Panic Sell / Liquidation (상장폐지 및 딸스피 -1,000P / 야동스피 -2,000P 폭락, 2X 레버리지 시 2배)
  Future<void> panicSellAndLiquidate({
    required String reason,
    required String note,
  }) async {
    final isYadong = _activeTicker == TickerType.yadongspi;
    final now = DateTime.now();
    final int baseLoss = isYadong ? 2000 : 1000;
    final int lossAmount = _isLeverage2x ? baseLoss * 2 : baseLoss;
    final formattedReason = _isLeverage2x ? '$reason [2X 레버리지 반대매매 깡통]' : reason;

    // 1. 이번 종목 달성 업적 목록 수집 (박제용)
    final achievedBadges = currentTickerAchievements
        .where((a) => a.isUnlocked)
        .map((a) => '${a.icon} ${a.title}')
        .toList();

    final record = LiquidationRecord(
      id: now.millisecondsSinceEpoch.toString(),
      timestamp: now,
      durationHeld: elapsedDuration,
      returnRateAchieved: currentPoints,
      simulatedLossAmount: lossAmount,
      reason: formattedReason,
      note: note,
      achievedBadges: achievedBadges,
      tickerType: _activeTicker.name,
    );

    _liquidationHistory.insert(0, record);

    final prefs = await SharedPreferences.getInstance();

    // 2. 포인트 감점 적용 및 타이머/배당금 카운트 재설정
    if (isYadong) {
      _yadongspiBasePoints = _yadongspiPoints - lossAmount.toDouble();
      _yadongspiStartTime = now;
      _yadongspiElapsed = Duration.zero;
      _yadongspiPoints = _yadongspiBasePoints;
      _yadongspiDividendPayouts = 0;
      await prefs.setDouble(_keyYadongspiBasePoints, _yadongspiBasePoints);
      await prefs.setString(_keyYadongspiStartTime, now.toIso8601String());
      await prefs.setInt(_keyYadongspiDividendPayouts, 0);

      // 야동스피 도전과제만 리셋
      _yadongspiUnlockedIds.clear();
      await prefs.setStringList(_keyYadongspiAchievements, []);

      // 부활 업적 부여
      await unlockAchievement('YD_RESURRECTION', ticker: TickerType.yadongspi);
    } else {
      _ttalspiBasePoints = _ttalspiPoints - lossAmount.toDouble();
      _ttalspiStartTime = now;
      _ttalspiElapsed = Duration.zero;
      _ttalspiPoints = _ttalspiBasePoints;
      _ttalspiDividendPayouts = 0;
      await prefs.setDouble(_keyTtalspiBasePoints, _ttalspiBasePoints);
      await prefs.setString(_keyTtalspiStartTime, now.toIso8601String());
      await prefs.setInt(_keyTtalspiDividendPayouts, 0);

      // 딸스피 도전과제만 리셋
      _ttalspiUnlockedIds.clear();
      await prefs.setStringList(_keyTtalspiAchievements, []);

      // 부활 업적 부여
      await unlockAchievement('RESURRECTION', ticker: TickerType.ttalspi);
    }

    // 3. 회고록 저장
    final historyJsonList = _liquidationHistory.map((r) => r.toJson()).toList();
    await prefs.setStringList(_keyHistory, historyJsonList);

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

  // 브라우저 SharedPreferences 데이터 전체 JSON 내보내기 (Export)
  Future<String> exportBackupData() async {
    _updateCalculations();

    final data = <String, dynamic>{
      'app': 'HODL_CLUB',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'activeTicker': _activeTicker.name,
      'isLeverage2x': _isLeverage2x,
      'safariPromptDismissed': _safariPromptDismissed,
      'circuitBreakerCount': _circuitBreakerCount,
      'ttalspi': {
        'startTime': _ttalspiStartTime?.toIso8601String(),
        'basePoints': _ttalspiBasePoints,
        'points': _ttalspiPoints,
        'elapsedSeconds': _ttalspiElapsed.inSeconds,
        'dividendPayouts': _ttalspiDividendPayouts,
        'unlockedAchievements': _ttalspiUnlockedIds.toList(),
      },
      'yadongspi': {
        'startTime': _yadongspiStartTime?.toIso8601String(),
        'basePoints': _yadongspiBasePoints,
        'points': _yadongspiPoints,
        'elapsedSeconds': _yadongspiElapsed.inSeconds,
        'dividendPayouts': _yadongspiDividendPayouts,
        'unlockedAchievements': _yadongspiUnlockedIds.toList(),
      },
      'liquidationHistory': _liquidationHistory.map((r) => r.toJson()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // 백업 JSON 데이터를 파싱하여 로컬 브라우저 SharedPreferences에 복원 (Import)
  Future<bool> importBackupData(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('유효하지 않은 백업 데이터 포맷입니다.');
      }

      if (decoded['app'] != 'HODL_CLUB') {
        throw const FormatException('HODL 클럽 전용 백업 파일이 아닙니다.');
      }

      final prefs = await SharedPreferences.getInstance();

      // 1. Settings & Ticker
      if (decoded.containsKey('activeTicker') && decoded['activeTicker'] is String) {
        final tickerName = decoded['activeTicker'] as String;
        _activeTicker = TickerType.values.firstWhere(
          (t) => t.name == tickerName,
          orElse: () => TickerType.ttalspi,
        );
        await prefs.setString(_keyActiveTicker, _activeTicker.name);
      }

      if (decoded.containsKey('isLeverage2x') && decoded['isLeverage2x'] is bool) {
        _isLeverage2x = decoded['isLeverage2x'] as bool;
        await prefs.setBool(_keyIsLeverage2x, _isLeverage2x);
      }

      if (decoded.containsKey('safariPromptDismissed') && decoded['safariPromptDismissed'] is bool) {
        _safariPromptDismissed = decoded['safariPromptDismissed'] as bool;
        await prefs.setBool(_keySafariDismissed, _safariPromptDismissed);
      }

      if (decoded.containsKey('circuitBreakerCount') && decoded['circuitBreakerCount'] is num) {
        _circuitBreakerCount = (decoded['circuitBreakerCount'] as num).toInt();
      }

      // 2. 딸스피 State
      if (decoded['ttalspi'] is Map<String, dynamic>) {
        final ttalMap = decoded['ttalspi'] as Map<String, dynamic>;
        if (ttalMap['startTime'] != null) {
          _ttalspiStartTime = DateTime.tryParse(ttalMap['startTime'].toString()) ?? DateTime.now();
          await prefs.setString(_keyTtalspiStartTime, _ttalspiStartTime!.toIso8601String());
        }
        if (ttalMap['basePoints'] != null) {
          _ttalspiBasePoints = (ttalMap['basePoints'] as num).toDouble();
          await prefs.setDouble(_keyTtalspiBasePoints, _ttalspiBasePoints);
        }
        if (ttalMap['dividendPayouts'] != null) {
          _ttalspiDividendPayouts = (ttalMap['dividendPayouts'] as num).toInt();
          await prefs.setInt(_keyTtalspiDividendPayouts, _ttalspiDividendPayouts);
        }
        if (ttalMap['unlockedAchievements'] is List) {
          final list = (ttalMap['unlockedAchievements'] as List).map((e) => e.toString()).toList();
          _ttalspiUnlockedIds = list.toSet();
          await prefs.setStringList(_keyTtalspiAchievements, list);
        }
      }

      // 3. 야동스피 State
      if (decoded['yadongspi'] is Map<String, dynamic>) {
        final yadongMap = decoded['yadongspi'] as Map<String, dynamic>;
        if (yadongMap['startTime'] != null) {
          _yadongspiStartTime = DateTime.tryParse(yadongMap['startTime'].toString()) ?? DateTime.now();
          await prefs.setString(_keyYadongspiStartTime, _yadongspiStartTime!.toIso8601String());
        }
        if (yadongMap['basePoints'] != null) {
          _yadongspiBasePoints = (yadongMap['basePoints'] as num).toDouble();
          await prefs.setDouble(_keyYadongspiBasePoints, _yadongspiBasePoints);
        }
        if (yadongMap['dividendPayouts'] != null) {
          _yadongspiDividendPayouts = (yadongMap['dividendPayouts'] as num).toInt();
          await prefs.setInt(_keyYadongspiDividendPayouts, _yadongspiDividendPayouts);
        }
        if (yadongMap['unlockedAchievements'] is List) {
          final list = (yadongMap['unlockedAchievements'] as List).map((e) => e.toString()).toList();
          _yadongspiUnlockedIds = list.toSet();
          await prefs.setStringList(_keyYadongspiAchievements, list);
        }
      }

      // 4. 청산/회고록 이력
      if (decoded['liquidationHistory'] is List) {
        final list = decoded['liquidationHistory'] as List;
        _liquidationHistory = list
            .map((item) => LiquidationRecord.fromJson(item is String ? item : jsonEncode(item)))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final historyJsonList = _liquidationHistory.map((r) => r.toJson()).toList();
        await prefs.setStringList(_keyHistory, historyJsonList);
      }

      _updateCalculations();
      _generateInitialOrders();
      _buildChartSpots();
      await _checkDividends();

      _liveOrders.insert(
        0,
        OrderBookItem(
          time: '방금',
          title: '🔄 데이터 복원 완료',
          amount: 'MTS 백업 데이터 복구 완료! 갓생 이어가기',
          isBuy: true,
        ),
      );

      notifyListeners();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tickerTimer?.cancel();
    super.dispose();
  }
}
