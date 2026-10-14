import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
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
  String _selectedReason = '🔞 야동/트위터 5분만 보려다가';
  final TextEditingController _noteController = TextEditingController();

  final List<String> _reasons = [
    '🔞 야동/트위터 5분만 보려다가',
    '📱 침대에서 인스타 돋보기 보다가',
    '🛌 무기력하게 눕방하다 무의식중에 쥐고 흔듦',
    '🌙 새벽 2시 외로움과 잡념에 굴복',
    '🚿 샤워하다 충동 못 참고 그만...',
    '😵 “딱 한 번만 치고 내일부터 갓생” 합리화',
  ];

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
    context.read<HodlProvider>().panicSellAndLiquidate(
          reason: _selectedReason,
          note: _noteController.text.trim().isEmpty
              ? '10초의 쾌락 뒤에 찾아온 건 휴지와 자괴감뿐이었다...'
              : _noteController.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final currencyFormat = NumberFormat('#,###');

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
              ? _buildReasonForm(provider, currencyFormat)
              : _buildDelistedPlunge(provider, currencyFormat),
        ),
      ),
    );
  }

  Widget _buildReasonForm(HodlProvider provider, NumberFormat currencyFormat) {
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '결국 발사해버렸노 게이야...',
                    style: TextStyle(
                      color: AppColors.electricRed,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '지금 리셋하면 전 재산(도파민) 몰수 처리됩니다',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('증발할 갓생 가치', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text(
                '${currencyFormat.format(provider.currentValuation)} 원',
                style: const TextStyle(
                  color: AppColors.electricRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '패닉셀(발사) 원인을 고백하라 (폭락 회고록 박제):',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reasons.map((reason) {
            final isSelected = reason == _selectedReason;
            return ChoiceChip(
              label: Text(reason),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedReason = reason;
                  });
                }
              },
              selectedColor: AppColors.darkRed,
              backgroundColor: AppColors.cardSurface,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.electricRed : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.electricRed : AppColors.border,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          '휴지 찢고 울면서 쓰는 참회의 한 줄 (선택):',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _noteController,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            hintText: '예: 10초 쾌락 뒤엔 현타뿐... 다음엔 진짜 손 묶어둔다.',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            filled: true,
            fillColor: AppColors.cardSurface,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.electricRed),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('아니다! 더 참아본다', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  backgroundColor: AppColors.electricRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _proceedToDelist,
                child: const Text('패닉셀(발사) 인정', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDelistedPlunge(HodlProvider provider, NumberFormat currencyFormat) {
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
          child: const Center(
            child: Text('💀', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '[금딸코인] 상장 폐지',
          style: TextStyle(
            color: AppColors.electricRed,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '도파민 전액 몰수! 평가 잔고 0원 (현타 100%)',
          style: TextStyle(
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
              _buildSummaryRow('최종 존버 시간', '${provider.elapsedDuration.inHours}시간 ${provider.elapsedDuration.inMinutes % 60}분'),
              const SizedBox(height: 6),
              _buildSummaryRow('증발된 테스토스테론', '+${provider.returnRate.toStringAsFixed(1)}% 📉', color: AppColors.electricRed),
              const SizedBox(height: 6),
              _buildSummaryRow('패닉셀 사유', _selectedReason),
              const Divider(color: AppColors.border, height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('이번 코인 달성 도전과제', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '총 ${provider.achievements.where((a) => a.isUnlocked).length}개',
                    style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final unlocked = provider.achievements.where((a) => a.isUnlocked).toList();
                  if (unlocked.isEmpty) {
                    return const Text(
                      '달성 도전과제 없음 (10분도 못 버티고 컷)',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                    );
                  }
                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: unlocked.map((a) {
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
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '※ 재도전 시 명예의 전당은 초기화되며,\n이번 코인의 도전과제 내역은 [현타 회고록]에 영구 박제됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.electricRed,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          '“손 씻고 거울 봐라 게이야...\n그래도 다시 일어나서 덤벨 들어야 사람새끼 된다.”',
          textAlign: TextAlign.center,
          style: TextStyle(
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
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh, size: 20),
                SizedBox(width: 8),
                Text(
                  '눈물 닦고 신규 상장 (재도전)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
