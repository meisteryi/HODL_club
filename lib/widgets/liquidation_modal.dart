import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class LiquidationModal extends StatefulWidget {
  const LiquidationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LiquidationModal(),
    );
  }

  @override
  State<LiquidationModal> createState() => _LiquidationModalState();
}

class _LiquidationModalState extends State<LiquidationModal> {
  int _step = 0; // 0: Form, 1: Delisted Plunge Screen
  String? _selectedReason;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _proceedToDelist() {
    setState(() {
      _step = 1;
    });
  }

  void _confirmResetAndRestart() {
    final provider = context.read<HodlProvider>();
    final activeTicker = provider.activeTicker;
    final defaultReason = activeTicker.defaultReasons.first;

    final defaultNote = activeTicker == TickerType.yadongspi
        ? '시크릿 모드의 은밀한 유혹에 굴복해 자괴감에 빠졌다...'
        : '10초의 쾌락 뒤에 찾아온 건 휴지와 자괴감뿐이었다...';

    provider.panicSellAndLiquidate(
      reason: _selectedReason ?? defaultReason,
      note: _noteController.text.trim().isEmpty
          ? defaultNote
          : _noteController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.electricRed.withValues(alpha: 0.8),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricRed.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: _step == 0
              ? _buildReasonForm(provider)
              : _buildDelistedPlunge(provider),
        ),
      ),
    );
  }

  Widget _buildReasonForm(HodlProvider provider) {
    final activeTicker = provider.activeTicker;
    final isYadong = activeTicker == TickerType.yadongspi;
    final reasons = activeTicker.defaultReasons;

    _selectedReason ??= reasons.first;
    if (!reasons.contains(_selectedReason)) {
      _selectedReason = reasons.first;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkRed,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.electricRed),
              ),
              child: const Icon(Icons.dangerous, color: AppColors.electricRed, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isYadong ? '결국 시크릿 모드 켜버렸노 게이야...' : '결국 뇌 녹아서 발사해버렸노 게이야...',
                    style: const TextStyle(
                      color: AppColors.electricRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    provider.isLeverage2x
                        ? '🚨 2X 레버리지 반대매매! ${activeTicker.nameKo} 지수 -${provider.currentLossAmount}P 깡통 청산'
                        : '지금 리셋하면 ${activeTicker.nameKo} 지수 -${provider.currentLossAmount}P 폭락 처리됩니다',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: provider.isLeverage2x ? AppColors.gold.withValues(alpha: 0.5) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.isLeverage2x
                    ? '${activeTicker.nameKo} 2X 곱버스 깡통 페널티'
                    : '${activeTicker.nameKo} 폭락 페널티',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                provider.isLeverage2x
                    ? '-${provider.currentLossAmount} P (반대매매)'
                    : '-${provider.currentLossAmount} P 폭락',
                style: TextStyle(
                  color: provider.isLeverage2x ? AppColors.gold : AppColors.electricRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isYadong
              ? '야동 시청(깡통 상폐) 원인을 고백하라 (폭락 회고록 박제):'
              : '패닉셀(발사) 원인을 고백하라 (폭락 회고록 박제):',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Radio List of reasons
        ...reasons.map((r) {
          final isSelected = _selectedReason == r;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedReason = r;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkRed.withValues(alpha: 0.3) : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.electricRed : AppColors.border,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 16,
                      color: isSelected ? AppColors.electricRed : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r,
                        style: TextStyle(
                          color: isSelected ? AppColors.electricRed : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 10),
        const Text(
          '현타 한 줄 메모 (반성문):',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            hintText: isYadong
                ? '예: 시크릿 모드 켜자마자 뇌 녹았다... 다음엔 진짜 키보드 뽑는다.'
                : '예: 10초의 쾌락 뒤에 찾아온 건 휴지와 자괴감뿐이었다... 흑우 탈출 언제 하노',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            filled: true,
            fillColor: AppColors.cardSurface,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.electricRed),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소하고 손 묶기 (한강 안 간다)', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricRed,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _proceedToDelist,
                child: const Text('상장폐지 확정 (깡통)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDelistedPlunge(HodlProvider provider) {
    final activeTicker = provider.activeTicker;
    final isYadong = activeTicker == TickerType.yadongspi;
    final unlockedBadges = provider.currentTickerAchievements.where((a) => a.isUnlocked).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.darkRed,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.electricRed, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricRed.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Center(
            child: Text(activeTicker.icon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          activeTicker.delistedTitle,
          style: const TextStyle(
            color: AppColors.electricRed,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          activeTicker.delistedSubtitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(
                '최종 존버 시간',
                '${provider.elapsedDuration.inHours}시간 ${provider.elapsedDuration.inMinutes % 60}분',
              ),
              const SizedBox(height: 6),
              _buildSummaryRow(
                '지수 변동',
                provider.isLeverage2x
                    ? '-${provider.currentLossAmount} P (2X 깡통 청산) 📉'
                    : '-${provider.currentLossAmount} P 폭락 📉',
                color: AppColors.electricRed,
              ),
              const SizedBox(height: 6),
              _buildSummaryRow('패닉셀 사유', _selectedReason ?? '-'),
              const Divider(color: AppColors.border, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('이번 ${activeTicker.nameKo} 달성 도전과제',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '총 ${unlockedBadges.length}개',
                    style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (unlockedBadges.isEmpty)
                const Text(
                  '달성 도전과제 없음 (10분도 못 버티고 컷 당했노 ㅋㅋ)',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: unlockedBadges.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${a.icon} ${a.title}',
                        style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '※ 재도전 시 ${activeTicker.nameKo} 명예의 전당은 초기화되며,\n이번 도전과제 내역은 [현타 회고록]에 영구 박제됩니다.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.electricRed,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isYadong
              ? '“시크릿 탭 닫고 찬물 세수해라 게이야...\n자괴감 털고 일어나야 뇌세포 살아난다 ㅋㅋ”'
              : '“휴지 치우고 거울 봐라 게이야...\n그래도 다시 일어나서 푸쉬업 박아야 사람새끼 된다 ㅋㅋ”',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 12,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.textInverse,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _confirmResetAndRestart,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh, size: 20),
                const SizedBox(width: 8),
                Text(
                  activeTicker.restartButtonText,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
