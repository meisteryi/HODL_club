import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';
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
          Consumer<HodlProvider>(
            builder: (context, provider, child) {
              final activeTicker = provider.activeTicker;
              return Padding(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.heart_broken_outlined,
                          color: AppColors.electricRed, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        activeTicker.panicButtonText,
                        style: const TextStyle(
                          color: AppColors.electricRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
