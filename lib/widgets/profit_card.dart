import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/hodl_rank.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class ProfitCard extends StatelessWidget {
  final TickerType? ticker;

  const ProfitCard({super.key, this.ticker});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = ticker ?? provider.activeTicker;
    final currentPoints = ticker != null
        ? (ticker == TickerType.ttalspi ? provider.ttalspiPoints : provider.yadongspiPoints)
        : provider.currentPoints;
    final duration = ticker != null
        ? (ticker == TickerType.ttalspi ? provider.ttalspiElapsed : provider.yadongspiElapsed)
        : provider.elapsedDuration;

    final pointsStr = currentPoints >= 0
        ? '+${currentPoints.toStringAsFixed(2)} P'
        : '${currentPoints.toStringAsFixed(2)} P';
    final pointsColor = currentPoints >= 0 ? AppColors.neonGreen : AppColors.electricRed;

    final rank = HodlRank.getRank(duration, ticker: activeTicker);
    final nextRank = _getNextRank(rank, activeTicker);
    final progress = _calculateProgress(duration, rank, nextRank);

    final statusCommentary = currentPoints >= 0
        ? (provider.isLeverage2x
            ? '⚡ 2X 레버리지 야수의 심장 탑승 중'
            : (activeTicker == TickerType.ttalspi
                ? '🔥 테스토스테론 떡상 랠리 중'
                : '🛡️ 전두엽 도파민 정상화 랠리 중'))
        : (provider.isLeverage2x
            ? '🚨 2X 깡통(-4,000P) 복구 중 ㅠㅠ'
            : '🚨 깡통 페널티(-2,000P) 복구 진행 중');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: provider.isLeverage2x
              ? AppColors.gold.withValues(alpha: 0.6)
              : pointsColor.withValues(alpha: 0.3),
          width: provider.isLeverage2x ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (provider.isLeverage2x ? AppColors.gold : pointsColor)
                .withValues(alpha: 0.1),
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
              Text(
                statusCommentary,
                style: TextStyle(
                  color: provider.isLeverage2x ? AppColors.gold : pointsColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Index Points
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                pointsStr,
                style: TextStyle(
                  color: pointsColor,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: pointsColor.withValues(alpha: 0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                currentPoints >= 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: pointsColor,
                size: 26,
              ),
              if (provider.isLeverage2x) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gold, width: 1),
                  ),
                  child: const Text(
                    '2X 곱버스',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            provider.isLeverage2x
                ? '실시간 ${activeTicker.nameKo} 2X 레버리지 (하루 +2,000P 떡상 / 패닉셀 시 -4,000P 깡통)'
                : '실시간 ${activeTicker.nameKo} 지수 (시작 0P • 1일 +1,000P)',
            style: TextStyle(
              color: provider.isLeverage2x ? AppColors.gold : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Index Specs Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem('시작 기준 지수', '0.0 P'),
                _buildSpecItem(
                  '상승 속도',
                  provider.isLeverage2x ? '+2,000 P / 1일 (2X)' : '+1,000 P / 1일',
                  isAccent: provider.isLeverage2x,
                ),
                _buildSpecItem(
                  '상폐 페널티',
                  provider.isLeverage2x ? '-4,000 P (반대매매)' : '-2,000 P',
                  isDanger: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ⚡ 상남자 2X 레버리지 모드 토글 카드
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: provider.isLeverage2x
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.isLeverage2x
                    ? AppColors.gold
                    : AppColors.border,
                width: provider.isLeverage2x ? 1.2 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: provider.isLeverage2x
                        ? AppColors.gold.withValues(alpha: 0.25)
                        : AppColors.cardSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    provider.isLeverage2x ? '⚡' : '🛡️',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '상남자 2X 레버리지 모드',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: provider.isLeverage2x
                                  ? AppColors.electricRed.withValues(alpha: 0.2)
                                  : AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              provider.isLeverage2x ? '신용 풀미수' : '1X 정석',
                              style: TextStyle(
                                color: provider.isLeverage2x
                                    ? AppColors.electricRed
                                    : AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.isLeverage2x
                            ? '야수의 심장 탑승! 하루 +2,000P 폭등 / ${activeTicker == TickerType.ttalspi ? "발사" : "시청"} 시 -4,000P 깡통 청산 ㅋㅋ'
                            : '안전제일 1X 존버 중 (하루 +1,000P / ${activeTicker == TickerType.ttalspi ? "발사" : "시청"} 시 -2,000P)',
                        style: TextStyle(
                          color: provider.isLeverage2x
                              ? AppColors.gold
                              : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.isLeverage2x,
                  onChanged: (val) {
                    provider.toggleLeverage();
                  },
                  activeThumbColor: AppColors.gold,
                  activeTrackColor: AppColors.gold.withValues(alpha: 0.4),
                  inactiveThumbColor: AppColors.textSecondary,
                  inactiveTrackColor: AppColors.cardSurface,
                ),
              ],
            ),
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

  Widget _buildSpecItem(String label, String value, {bool isDanger = false, bool isAccent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isDanger
                ? AppColors.electricRed
                : (isAccent ? AppColors.gold : AppColors.textPrimary),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  HodlRank? _getNextRank(HodlRank current, TickerType ticker) {
    final ranks = HodlRank.getRanksFor(ticker);
    final nextLevel = current.level + 1;
    final index = ranks.indexWhere((r) => r.level == nextLevel);
    return index != -1 ? ranks[index] : null;
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
