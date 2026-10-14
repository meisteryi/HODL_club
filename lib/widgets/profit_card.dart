import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/hodl_rank.dart';
import '../providers/hodl_provider.dart';

class ProfitCard extends StatelessWidget {
  const ProfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final currencyFormat = NumberFormat('#,###');
    final returnRateStr = provider.returnRate >= 0
        ? '+${provider.returnRate.toStringAsFixed(2)}%'
        : '${provider.returnRate.toStringAsFixed(2)}%';
    final profitStr = provider.profitAmount >= 0
        ? '+${currencyFormat.format(provider.profitAmount)} 원'
        : '${currencyFormat.format(provider.profitAmount)} 원';

    final rank = provider.currentRank;
    final nextRank = _getNextRank(rank);
    final progress = _calculateProgress(provider.elapsedDuration, rank, nextRank);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neonGreen.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank & Tier header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rank.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: rank.color.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(rank.icon, size: 14, color: rank.color),
                    const SizedBox(width: 5),
                    Text(
                      rank.title,
                      style: TextStyle(
                        color: rank.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '🔥 테스토스테론 폭등 랠리 중',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Return Rate & Profit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                returnRateStr,
                style: const TextStyle(
                  color: AppColors.neonGreen,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: AppColors.neonGreen,
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.neonGreen,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Total Simulated Valuation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '추정 갓생 자산 가치',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currencyFormat.format(provider.currentValuation)} 원',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '세이브된 도파민 이득',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profitStr,
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Rank commentary & Level Up Progress
          Row(
            children: [
              Expanded(
                child: Text(
                  rank.commentary,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(rank.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재: ${rank.title.split(' ')[0]}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
              Text(
                nextRank != null
                    ? '다음: ${nextRank.title.split(' ')[0]} (${_getRemainingTimeStr(nextRank.requiredDuration - provider.elapsedDuration)})'
                    : '최고 등급 도달 (월가 세력)',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  HodlRank? _getNextRank(HodlRank current) {
    final nextLevel = current.level + 1;
    final index = HodlRank.allRanks.indexWhere((r) => r.level == nextLevel);
    return index != -1 ? HodlRank.allRanks[index] : null;
  }

  double _calculateProgress(
      Duration current, HodlRank currentRank, HodlRank? nextRank) {
    if (nextRank == null) return 1.0;
    final startSec = currentRank.requiredDuration.inSeconds;
    final endSec = nextRank.requiredDuration.inSeconds;
    final currentSec = current.inSeconds;

    if (endSec <= startSec) return 1.0;
    final p = (currentSec - startSec) / (endSec - startSec);
    return p.clamp(0.0, 1.0);
  }

  String _getRemainingTimeStr(Duration remaining) {
    if (remaining.isNegative) return '완료';
    if (remaining.inDays > 0) return '${remaining.inDays}일 남음';
    if (remaining.inHours > 0) return '${remaining.inHours}시간 남음';
    if (remaining.inMinutes > 0) return '${remaining.inMinutes}분 남음';
    return '${remaining.inSeconds}초 남음';
  }
}
