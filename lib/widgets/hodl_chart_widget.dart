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
    final spots = provider.chartSpots;

    if (spots.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen),
        ),
      );
    }

    final maxY = spots.map((s) => s.y).reduce(max);
    final effectiveMaxY = maxY <= 0 ? 10.0 : maxY * 1.15;

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
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1.0,
                minY: 0,
                maxY: effectiveMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: effectiveMaxY > 0 ? effectiveMaxY / 3 : 1,
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
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'T-${(spots.length - 1 - value.toInt()) * 2}m',
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
                      interval: effectiveMaxY > 0 ? effectiveMaxY / 3 : 1,
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
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.neonGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) {
                        // only show glowing dot on the last active spot
                        return spot.x == spots.last.x;
                      },
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.neonGreen,
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
          const SizedBox(height: 6),
          const Center(
            child: Text(
              '※ 본 차트는 순수 참을성으로 빚어낸 뇌 청정 무한 떡상 차트입니다 📈',
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
}
