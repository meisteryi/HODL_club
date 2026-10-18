import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';

class HodlChartWidget extends StatefulWidget {
  const HodlChartWidget({super.key});

  @override
  State<HodlChartWidget> createState() => _HodlChartWidgetState();
}

class _HodlChartWidgetState extends State<HodlChartWidget> {
  int _selectedCandleIndex = 0;
  final List<String> _candleLabels = ['1분봉', '10분봉', '일봉', '주봉'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final spots = provider.getSpotsForPeriod(_selectedCandleIndex);

    if (spots.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen),
        ),
      );
    }

    final maxY = spots.map((s) => s.y).reduce(max);
    final minY = spots.map((s) => s.y).reduce(min);
    final effectiveMaxY = maxY <= 0 ? (minY < 0 ? 0.0 : 10.0) : maxY * 1.15;
    final effectiveMinY = minY < 0 ? minY * 1.15 : max(0.0, minY * 0.85);

    final isPositive = provider.testosteronePoints >= 0;
    final chartColor = isPositive ? AppColors.neonGreen : AppColors.electricRed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.show_chart, color: chartColor, size: 18),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            '통합 테스토스테론 차트',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '평균 ${isPositive ? '+' : ''}${provider.testosteronePoints.toStringAsFixed(1)} P',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '딸스피(${provider.ttalspiPoints.toStringAsFixed(0)}P) • 야동스피(${provider.yadongspiPoints.toStringAsFixed(0)}P) 평균 지수',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(_candleLabels.length, (index) {
                  final isSelected = index == _selectedCandleIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCandleIndex = index;
                      });
                      provider.recordChartInspect();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkGreen : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? AppColors.neonGreen : AppColors.border,
                        ),
                      ),
                      child: Text(
                        _candleLabels[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.neonGreen : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Period commentary banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedCandleIndex == 0
                    ? AppColors.electricRed.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
            ),
            child: Text(
              provider.getPeriodCommentary(_selectedCandleIndex),
              style: TextStyle(
                color: _selectedCandleIndex == 0 ? AppColors.gold : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 165,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1.0,
                minY: effectiveMinY,
                maxY: effectiveMaxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final idx = touchedSpot.x.toInt();
                        final event = provider.getEventLabel(_selectedCandleIndex, idx);
                        final val = touchedSpot.y;
                        final pointsText = val >= 0
                            ? '+${val.toStringAsFixed(1)} P'
                            : '${val.toStringAsFixed(1)} P';

                        return LineTooltipItem(
                          '$pointsText\n',
                          TextStyle(
                            color: val >= 0 ? AppColors.neonGreen : AppColors.electricRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                          children: [
                            TextSpan(
                              text: event,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (effectiveMaxY - effectiveMinY) > 0
                      ? (effectiveMaxY - effectiveMinY) / 3
                      : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (spots.length / 4).clamp(1.0, 10.0),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        final label = _formatXLabel(_selectedCandleIndex, spots.length, idx);
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      interval: (effectiveMaxY - effectiveMinY) > 0
                          ? (effectiveMaxY - effectiveMinY) / 3
                          : 1,
                      getTitlesWidget: (value, meta) {
                        final formatted = value >= 0 ? '+${value.toInt()}P' : '${value.toInt()}P';
                        return Text(
                          formatted,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontFamily: 'monospace',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: _selectedCandleIndex != 2, // 일봉은 계단식 감성
                    curveSmoothness: 0.35,
                    color: chartColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        if (_selectedCandleIndex == 0) {
                          return spot.x == 3 || spot.x == spots.last.x;
                        }
                        return spot.x == spots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        final isDip = _selectedCandleIndex == 0 && spot.x == 3;
                        return FlDotCirclePainter(
                          radius: isDip ? 4 : 5,
                          color: isDip ? AppColors.electricRed : chartColor,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          chartColor.withValues(alpha: 0.35),
                          chartColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '※ 차트를 터치하면 당시의 유혹/반등 멘탈 이벤트를 확인할 수 있습니다 👆',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatXLabel(int periodIndex, int totalSpots, int idx) {
    if (idx >= totalSpots) return '';
    if (periodIndex == 0) {
      if (idx == totalSpots - 1) return '현재';
      return '${totalSpots - 1 - idx}분전';
    } else if (periodIndex == 1) {
      if (idx == totalSpots - 1) return '현재';
      return '${(totalSpots - 1 - idx) * 10}분전';
    } else if (periodIndex == 2) {
      if (idx == totalSpots - 1) return '오늘';
      return '${totalSpots - 1 - idx}일전';
    } else {
      if (idx == totalSpots - 1) return '이번주';
      return '${totalSpots - 1 - idx}주전';
    }
  }
}
