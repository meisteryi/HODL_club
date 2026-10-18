import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';

class SafariInstallPrompt extends StatelessWidget {
  const SafariInstallPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    if (provider.safariPromptDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.install_mobile,
              color: AppColors.electricBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Text(
                      '사파리 PWA 전용 모드',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'iOS Safari',
                      style: TextStyle(
                        color: AppColors.electricBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3),
                    children: [
                      TextSpan(text: '하단 공유 버튼('),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.ios_share, color: AppColors.electricBlue, size: 14),
                      ),
                      TextSpan(text: ') 누른 후 '),
                      TextSpan(
                        text: '[홈 화면에 추가]',
                        style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: '를 탭하면 딸 충동 올 때마다 0.5초만에 켜서 손 쳐낼 수 있다 게이야.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
            onPressed: () {
              provider.dismissSafariPrompt();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '닫기',
          ),
        ],
      ),
    );
  }
}
