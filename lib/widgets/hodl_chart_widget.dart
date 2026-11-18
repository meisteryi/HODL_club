import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class HodlChartWidget extends StatefulWidget {
  const HodlChartWidget({super.key});

  @override
  State<HodlChartWidget> createState() => _HodlChartWidgetState();
}

class _HodlChartWidgetState extends State<HodlChartWidget> {
  int _selectedCandleIndex = 0;
  final List<String> _candleLabels = ['일봉', '주봉', '월봉', '연봉'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = provider.activeTicker;
    final series = provider.getChartSeries(_selectedCandleIndex, ticker: activeTicker);
    final spots = series.spots;

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
    final ySpan = maxY - minY;
    final padding = ySpan < 0.05 ? 0.5 : ySpan * 0.15;
    final effectiveMaxY = maxY + padding;
    final effectiveMinY = minY - padding;
    final effectiveRange = effectiveMaxY - effectiveMinY;

    final currentPts = provider.currentPoints;
    final isPositive = currentPts >= 0;
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
                        Flexible(
                          child: Text(
                            '${activeTicker.icon} ${activeTicker.nameKo} 실시간 차트',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
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
                            color: (isPositive ? AppColors.neonGreen : AppColors.electricRed)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (isPositive ? AppColors.neonGreen : AppColors.electricRed)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}${currentPts.toStringAsFixed(2)} P',
                            style: TextStyle(
                              color: isPositive ? AppColors.neonGreen : AppColors.electricRed,
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
                      '통합 지수 ${provider.testosteronePoints >= 0 ? '+' : ''}${provider.testosteronePoints.toStringAsFixed(1)} P • 실거래가/청산 내역 실시간 반영',
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
              provider.getPeriodCommentary(
                _selectedCandleIndex,
                ticker: activeTicker,
                relapseCount: series.relapseCountInWindow,
              ),
              style: TextStyle(
                color: series.relapseCountInWindow > 0
                    ? AppColors.electricRed
                    : (_selectedCandleIndex == 0 ? AppColors.gold : AppColors.textSecondary),
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
                maxX: series.maxX,
                minY: effectiveMinY,
                maxY: effectiveMaxY,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final spotIdx = touchedSpot.spotIndex;
                        final pointData = (spotIdx >= 0 && spotIdx < series.points.length)
                            ? series.points[spotIdx]
                            : null;
                        final event = pointData?.label ?? '';
                        final val = touchedSpot.y;
                        final pointsText = val >= 0
                            ? '+${val.toStringAsFixed(2)} P'
                            : '${val.toStringAsFixed(2)} P';

                        return LineTooltipItem(
                          '$pointsText\n',
                          TextStyle(
                            color: (pointData?.isRelapseDrop ?? false) || val < 0
                                ? AppColors.electricRed
                                : AppColors.neonGreen,
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
                  horizontalInterval: effectiveRange > 0 ? effectiveRange / 3 : 1,
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
                      interval: _selectedCandleIndex == 1
                          ? 1.0
                          : (_selectedCandleIndex == 2 ? 5.0 : 3.0),
                      getTitlesWidget: (value, meta) {
                        final idx = value.round();
                        if ((value - idx).abs() > 0.05) {
                          return const SizedBox.shrink();
                        }
                        if (_selectedCandleIndex == 1 &&
                            idx != 0 &&
                            idx != 2 &&
                            idx != 5 &&
                            idx != 7) {
                          return const SizedBox.shrink();
                        }
                        final label = _formatXLabel(_selectedCandleIndex, series.maxX.toInt(), idx);
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
                      reservedSize: 60,
                      interval: effectiveRange > 0 ? effectiveRange / 3 : 1,
                      getTitlesWidget: (value, meta) {
                        String formatted;
                        if (effectiveRange < 5) {
                          formatted = value >= 0
                              ? '+${value.toStringAsFixed(2)}P'
                              : '${value.toStringAsFixed(2)}P';
                        } else if (effectiveRange < 50) {
                          formatted = value >= 0
                              ? '+${value.toStringAsFixed(1)}P'
                              : '${value.toStringAsFixed(1)}P';
                        } else {
                          formatted = value >= 0
                              ? '+${value.toInt()}P'
                              : '${value.toInt()}P';
                        }
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
                    isCurved: false,
                    color: chartColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        final isLast = (spot.x - series.maxX).abs() < 0.0001;
                        if (isLast) return true;
                        return series.points.any((p) =>
                            p.isRelapseDrop &&
                            (p.x - spot.x).abs() < 0.0001 &&
                            (p.y - spot.y).abs() < 0.0001);
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        final isDip = index >= 0 &&
                            index < series.points.length &&
                            series.points[index].isRelapseDrop;
                        return FlDotCirclePainter(
                          radius: isDip ? 4.5 : 5,
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
              '※ 차트를 터치하면 시점별 실제 포인트와 청산(폭락) 사유를 확인할 수 있습니다 👆',
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

  String _formatXLabel(int periodIndex, int maxSteps, int idx) {
    if (idx < 0 || idx > maxSteps) return '';
    final remaining = maxSteps - idx;
    if (periodIndex == 0) {
      if (remaining == 0) return '현재';
      return '${remaining * 2}h전';
    } else if (periodIndex == 1) {
      if (remaining == 0) return '오늘';
      return '$remaining일전';
    } else if (periodIndex == 2) {
      if (remaining == 0) return '오늘';
      return '${remaining * 2}일전';
    } else {
      if (remaining == 0) return '이번달';
      return '$remaining달전';
    }
  }
}
