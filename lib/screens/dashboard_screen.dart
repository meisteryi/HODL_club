import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/hodl_chart_widget.dart';
import '../widgets/hodl_timer_widget.dart';
import '../widgets/liquidation_modal.dart';
import '../widgets/live_order_book_widget.dart';
import '../widgets/profit_card.dart';
import '../widgets/safari_install_prompt.dart';
import '../widgets/stock_ticker_header.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SafariInstallPrompt(),
          const StockTickerHeader(),
          const ProfitCard(),
          const HodlTimerWidget(),
          const HodlChartWidget(),
          const LiveOrderBookWidget(),

          // Panic Sell / Reset Button at the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AppColors.electricRed.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                backgroundColor: AppColors.darkRed.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => LiquidationModal.show(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken_outlined, color: AppColors.electricRed, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '결국 충동에 굴복 (한 발 빼기 & 상폐 리셋)',
                    style: TextStyle(
                      color: AppColors.electricRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
