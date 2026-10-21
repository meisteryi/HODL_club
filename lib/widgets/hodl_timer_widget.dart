import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class HodlTimerWidget extends StatelessWidget {
  final TickerType? ticker;

  const HodlTimerWidget({super.key, this.ticker});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = ticker ?? provider.activeTicker;
    final duration = ticker != null
        ? (ticker == TickerType.ttalspi ? provider.ttalspiElapsed : provider.yadongspiElapsed)
        : provider.elapsedDuration;

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: AppColors.gold, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        activeTicker.timerLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  activeTicker.timerStatus,
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(days.toString().padLeft(2, '0'), 'DAYS (일)'),
              _buildColon(),
              _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HOURS (시)'),
              _buildColon(),
              _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'MINS (분)'),
              _buildColon(),
              _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'SECS (초)', isAccent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: AppColors.neonGreen,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label, {bool isAccent = false}) {
    return Column(
      children: [
        Container(
          width: 58,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAccent ? AppColors.neonGreen.withValues(alpha: 0.6) : AppColors.borderLight,
              width: isAccent ? 1.4 : 1,
            ),
            boxShadow: isAccent
                ? [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isAccent ? AppColors.neonGreen : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
