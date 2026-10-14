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
    final effectiveMaxY = maxY <= 0 ? 10.0 : maxY * 1.15;
    final effectiveMinY = max(0.0, minY * 0.85);

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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.show_chart, color: AppColors.neonGreen, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '테스토스테론 폭등 차트',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
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
          const SizedBox(height: 14),

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
                        return LineTooltipItem(
                          '${touchedSpot.y.toStringAsFixed(1)}%\n',
                          const TextStyle(
                            color: AppColors.neonGreen,
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
                  horizontalInterval: effectiveMaxY > effectiveMinY
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
                      reservedSize: 45,
                      interval: effectiveMaxY > effectiveMinY
                          ? (effectiveMaxY - effectiveMinY) / 3
                          : 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '+${value.toInt()}%',
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
                    color: AppColors.neonGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // 1분봉에서는 딥 저점과 현재 고점에 점 표시
                        if (_selectedCandleIndex == 0) {
                          return spot.x == 3 || spot.x == spots.last.x;
                        }
                        return spot.x == spots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        final isDip = _selectedCandleIndex == 0 && spot.x == 3;
                        return FlDotCirclePainter(
                          radius: isDip ? 4 : 5,
                          color: isDip ? AppColors.electricRed : AppColors.neonGreen,
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
                          AppColors.neonGreen.withValues(alpha: 0.35),
                          AppColors.neonGreen.withValues(alpha: 0.0),
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

  String _formatXLabel(int candleIndex, int totalSpots, int currentIndex) {
    final diff = totalSpots - 1 - currentIndex;
    if (diff == 0) return 'NOW';

    switch (candleIndex) {
      case 0:
        return 'T-${diff}m';
      case 1:
        return 'T-${diff * 10}m';
      case 2:
        return 'D-$diff';
      case 3:
      default:
        return 'W-$diff';
    }
  }
}
