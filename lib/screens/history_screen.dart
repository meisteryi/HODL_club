import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/liquidation_record.dart';
import '../providers/hodl_provider.dart';
import '../widgets/relapse_calendar_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isCalendarView = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final history = provider.liquidationHistory;

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
                        '총 ${history.length}회의 발사 흑역사 박제 (이불킥 주의)',
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
          const SizedBox(height: 14),

          // View Switcher: [ 📅 발사 캘린더 | 📜 전체 회고록 ]
          Row(
            children: [
              Expanded(
                child: _buildViewTab(
                  icon: Icons.calendar_month_rounded,
                  title: '발사 캘린더',
                  isSelected: _isCalendarView,
                  onTap: () {
                    setState(() {
                      _isCalendarView = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewTab(
                  icon: Icons.format_list_bulleted_rounded,
                  title: '전체 회고록',
                  isSelected: !_isCalendarView,
                  onTap: () {
                    setState(() {
                      _isCalendarView = false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isCalendarView) ...[
            RelapseCalendarWidget(
              records: history,
              onRecordTap: (record) => _showDetailModal(context, record),
            ),
          ] else if (history.isEmpty)
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
                    '상장폐지(발사) 이력이 없다 이기!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '단 한 번도 패닉셀하지 않은 전설의 다이아몬드 고추다.\n손 묶고 버틴 갓생 갤러 인정한다 ㅋㅋ 이 페이스 쭉 유지해라!',
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
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _showDetailModal(context, record),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Ticker Badge & Timestamp & Duration
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
                                      child: Text(
                                        record.tickerType == 'yadongspi' ? '🔞 야동스피 상폐' : '🍆 딸스피 상폐',
                                        style: const TextStyle(
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
                            const SizedBox(height: 12),

                            // 2. 패닉셀 원인
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 68,
                                  child: Text(
                                    '원인',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    record.reason,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 3. 증발한 값
                            Row(
                              children: [
                                const SizedBox(
                                  width: 68,
                                  child: Text(
                                    '증발한 값',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text(
                                        '-2,000 P',
                                        style: TextStyle(
                                          color: AppColors.electricRed,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(직전 달성: +${record.returnRateAchieved.toStringAsFixed(1)} P)',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 4. 한 마디 (현타 반성문)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 68,
                                  child: Text(
                                    '한 마디',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    record.note.isNotEmpty ? '“${record.note}”' : '“할 말이 없다... 깊은 반성 중”',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 8),

                            // 5. 탭하여 상세 정보 확인 안내
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  record.achievedBadges.isNotEmpty
                                      ? '달성 도전과제 ${record.achievedBadges.length}개 보관 중'
                                      : '달성 도전과제 없음',
                                  style: TextStyle(
                                    color: record.achievedBadges.isNotEmpty ? AppColors.gold : AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '상세 정보 보기',
                                      style: TextStyle(
                                        color: AppColors.electricBlue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: AppColors.electricBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showDetailModal(BuildContext context, LiquidationRecord record) {
    final dateStr = DateFormat('yyyy년 MM월 dd일 HH:mm:ss').format(record.timestamp);
    final durationStr = _formatDuration(record.durationHeld);
    final isYadong = record.tickerType == 'yadongspi';
    final List<String> badges = List<String>.from(record.achievedBadges);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AppColors.electricRed, width: 1.5),
                  left: BorderSide(color: AppColors.border, width: 1),
                  right: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        // Header Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.darkRed,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.electricRed.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                isYadong ? '🔞' : '🍆',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isYadong ? '야동스피 (YDSP)' : '딸스피 (DOSP)',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkRed,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          '상장폐지 상세 명세서',
                                          style: TextStyle(
                                            color: AppColors.electricRed,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
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
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Stats Summary Grid
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow('⏱️ 존버 유지 시간', durationStr, isHighlight: true),
                              const Divider(color: AppColors.border, height: 16),
                              _buildDetailRow('💥 패닉셀 원인', record.reason),
                              const Divider(color: AppColors.border, height: 16),
                              _buildDetailRow(
                                '📉 증발한 값 (페널티)',
                                '-2,000.0 P',
                                valueColor: AppColors.electricRed,
                              ),
                              const Divider(color: AppColors.border, height: 16),
                              _buildDetailRow(
                                '📈 폭락 직전 달성 포인트',
                                '+${record.returnRateAchieved.toStringAsFixed(1)} P',
                                valueColor: AppColors.neonGreen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reflection Note
                        if (record.note.isNotEmpty) ...[
                          const Text(
                            '✍️ 현타 반성문 (그때의 심정)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              '“${record.note}”',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Achieved Badges List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '🏆 이번 런에서 지켜냈던 도전과제',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '총 ${badges.length}개',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (badges.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Column(
                              children: [
                                Text('🥀', style: TextStyle(fontSize: 28)),
                                SizedBox(height: 8),
                                Text(
                                  '달성한 도전과제가 없습니다',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '10분도 못 버티고 조기 상장폐지되었습니다.\n다음 런에서는 최소 1개 이상의 배지를 수확해봅시다!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
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
                            itemCount: badges.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 6),
                            itemBuilder: (context, badgeIndex) {
                              final badge = badges[badgeIndex];
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.gold.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text('✨', style: TextStyle(fontSize: 14)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        badge,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.gold,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // Close button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.elevatedSurface,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: AppColors.borderLight),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              '뼈저리게 반성하고 닫기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isHighlight ? AppColors.gold : AppColors.textPrimary),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: label.contains('포인트') || label.contains('값') ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildViewTab({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkRed.withValues(alpha: 0.35) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.electricRed : AppColors.border,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.electricRed : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.electricRed : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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

