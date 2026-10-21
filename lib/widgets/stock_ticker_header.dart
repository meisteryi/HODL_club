import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class StockTickerHeader extends StatelessWidget {
  final ValueChanged<TickerType>? onTickerSelected;
  final TickerType? selectedTicker;

  const StockTickerHeader({
    super.key,
    this.onTickerSelected,
    this.selectedTicker,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = selectedTicker ?? provider.activeTicker;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 1. Dual Ticker Selector Tabs (MTS 전광판 탭)
          Row(
            children: [
              Expanded(
                child: _buildTickerTab(
                  ticker: TickerType.ttalspi,
                  title: '딸스피 (DOSP)',
                  points: provider.ttalspiPoints,
                  elapsed: provider.ttalspiElapsed,
                  isSelected: activeTicker == TickerType.ttalspi,
                  onTap: () {
                    provider.switchTicker(TickerType.ttalspi);
                    onTickerSelected?.call(TickerType.ttalspi);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTickerTab(
                  ticker: TickerType.yadongspi,
                  title: '야동스피 (YDSP)',
                  points: provider.yadongspiPoints,
                  elapsed: provider.yadongspiElapsed,
                  isSelected: activeTicker == TickerType.yadongspi,
                  onTap: () {
                    provider.switchTicker(TickerType.yadongspi);
                    onTickerSelected?.call(TickerType.yadongspi);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Slide Gesture Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_outlined,
                size: 13,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 5),
              Text(
                '화면 좌우 슬라이드로 종목 이동 (스와이프)',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTickerTab({
    required TickerType ticker,
    required String title,
    required double points,
    required Duration elapsed,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final pointsStr = points >= 0
        ? '+${points.toStringAsFixed(1)} P'
        : '${points.toStringAsFixed(1)} P';
    final pointsColor = points >= 0 ? AppColors.neonGreen : AppColors.electricRed;
    final durationStr = elapsed.inDays > 0
        ? '${elapsed.inDays}일 ${elapsed.inHours % 24}시간'
        : '${elapsed.inHours}시간 ${elapsed.inMinutes % 60}분';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardSurface : AppColors.background.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ticker.icon, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.neonGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pointsStr,
                  style: TextStyle(
                    color: pointsColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  durationStr,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StockTickerSummaryCard extends StatefulWidget {
  final TickerType ticker;

  const StockTickerSummaryCard({
    super.key,
    required this.ticker,
  });

  @override
  State<StockTickerSummaryCard> createState() => _StockTickerSummaryCardState();
}

class _StockTickerSummaryCardState extends State<StockTickerSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final ticker = widget.ticker;

    final startDate = ticker == TickerType.ttalspi
        ? provider.ttalspiStartTime
        : provider.yadongspiStartTime;

    final startDateStr = startDate != null
        ? DateFormat('yyyy.MM.dd HH:mm').format(startDate)
        : '-';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(ticker.icon, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${ticker.nameKo} (${ticker.code})',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.electricRed.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.electricRed.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  ticker.tagLine,
                                  style: const TextStyle(
                                    color: AppColors.electricRed,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticker.subTitle,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Live status indicator
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.neonGreen.withValues(
                          alpha: 0.3 + (_blinkController.value * 0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.neonGreen.withValues(
                              alpha: 0.4 + (_blinkController.value * 0.6),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonGreen.withValues(
                                  alpha: _blinkController.value * 0.8,
                                ),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          ticker == TickerType.ttalspi ? '존버 중' : '클린 중',
                          style: const TextStyle(
                            color: AppColors.neonGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Quick Info strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTag(
                  ticker == TickerType.ttalspi ? '마지막 발사' : '마지막 시청',
                  startDateStr,
                ),
                _buildInfoTag(
                  '통합 테스토스테론',
                  '${provider.testosteronePoints >= 0 ? '+' : ''}${provider.testosteronePoints.toStringAsFixed(1)} P ⚡',
                ),
                _buildInfoTag(
                  ticker == TickerType.ttalspi ? '멘탈 상태' : '브라우저 상태',
                  ticker == TickerType.ttalspi
                      ? '뇌 녹음 차단 🛡️'
                      : '시크릿탭 영봉인 🔒',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
