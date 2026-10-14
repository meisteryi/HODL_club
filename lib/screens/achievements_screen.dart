import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final achievements = provider.achievements;
    final unlockedCount = provider.unlockedCount;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🏆', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          '금딸 명예의 전당',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unlockedCount / $totalCount 달성',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.cardSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '수많은 딸잡이들이 10초의 쾌락에 패닉셀할 때, 끝까지 손 묶고 버텨낸 자만이 갓생을 산다.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Achievement cards
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: achievements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ach = achievements[index];
              final isUnlocked = ach.isUnlocked;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.cardSurface : AppColors.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnlocked
                        ? AppColors.neonGreen.withValues(alpha: 0.35)
                        : AppColors.border.withValues(alpha: 0.5),
                    width: isUnlocked ? 1.2 : 0.8,
                  ),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: AppColors.neonGreen.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.neonGreen.withValues(alpha: 0.15)
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.neonGreen.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isUnlocked ? ach.icon : '🔒',
                          style: TextStyle(
                            fontSize: 22,
                            color: isUnlocked ? null : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                ach.title,
                                style: TextStyle(
                                  color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? AppColors.darkGreen
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ach.rewardTitle,
                                  style: TextStyle(
                                    color: isUnlocked ? AppColors.neonGreen : AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ach.subtitle,
                            style: TextStyle(
                              color: isUnlocked ? AppColors.gold : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ach.description,
                            style: TextStyle(
                              color: isUnlocked ? AppColors.textSecondary : AppColors.textMuted.withValues(alpha: 0.6),
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                          if (isUnlocked && ach.unlockedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '달성일: ${DateFormat('yyyy.MM.dd HH:mm').format(ach.unlockedAt!)}',
                              style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 9,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
}
