import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final history = provider.liquidationHistory;
    final currencyFormat = NumberFormat('#,###');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.electricRed.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricRed.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.electricRed),
                  ),
                  child: const Text('📜', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '폭락 & 현타 회고록',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '총 ${history.length}회의 발사(상장폐지) 흑역사 박제',
                        style: const TextStyle(
                          color: AppColors.electricRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (history.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Text('💎', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    '상장폐지(발사) 이력이 없습니다!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '단 한 번도 패닉셀하지 않은 전설의 다이아몬드 고추입니다.\n손 묶고 버틴 갓생러 인정한다 이기. 이 페이스를 유지하라!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final record = history[index];
                final dateStr = DateFormat('yyyy.MM.dd HH:mm').format(record.timestamp);
                final durationStr = _formatDuration(record.durationHeld);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.darkRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '발사(상폐)',
                                  style: TextStyle(
                                    color: AppColors.electricRed,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            durationStr,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('패닉셀 원인:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          Text(
                            record.reason,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('증발된 테스토스테론:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          Text(
                            '+${currencyFormat.format(record.simulatedLossAmount)} 원 (+${record.returnRateAchieved.toStringAsFixed(1)}%)',
                            style: const TextStyle(
                              color: AppColors.electricRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 이번 코인 달성 도전과제
                      if (record.achievedBadges.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '달성 도전과제: ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: record.achievedBadges.map((badge) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: AppColors.gold.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      badge,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Row(
                          children: [
                            Text(
                              '달성 도전과제: ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '없음 (10분도 못 버티고 발사)',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (record.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '“${record.note}”',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}일 ${d.inHours % 24}시간 존버 후 발사';
    } else if (d.inHours > 0) {
      return '${d.inHours}시간 ${d.inMinutes % 60}분 존버 후 발사';
    } else {
      return '${d.inMinutes}분 ${d.inSeconds % 60}초 존버 후 발사';
    }
  }
}
