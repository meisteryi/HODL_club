import 'dart:ui';
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isAnimatingPage = false;

  @override
  void initState() {
    super.initState();
    final initialTicker =
        Provider.of<HodlProvider>(context, listen: false).activeTicker;
    _currentPage = initialTicker == TickerType.ttalspi ? 0 : 1;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, HodlProvider provider) {
    setState(() {
      _currentPage = index;
    });
    final targetTicker = index == 0 ? TickerType.ttalspi : TickerType.yadongspi;
    if (provider.activeTicker != targetTicker) {
      provider.switchTicker(targetTicker);
    }
  }

  void _animateToTicker(TickerType ticker) {
    final targetPage = ticker == TickerType.ttalspi ? 0 : 1;
    if (_currentPage != targetPage && _pageController.hasClients) {
      _isAnimatingPage = true;
      _pageController
          .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
        _isAnimatingPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = provider.activeTicker;
    final expectedPage = activeTicker == TickerType.ttalspi ? 0 : 1;

    // External change sync (e.g. from toast or app bar)
    if (!_isAnimatingPage &&
        _currentPage != expectedPage &&
        _pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients && !_isAnimatingPage) {
          _isAnimatingPage = true;
          _pageController
              .animateToPage(
                expectedPage,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              )
              .then((_) {
            _isAnimatingPage = false;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SafariInstallPrompt(),
        StockTickerHeader(
          selectedTicker:
              _currentPage == 0 ? TickerType.ttalspi : TickerType.yadongspi,
          onTickerSelected: (ticker) {
            _animateToTicker(ticker);
          },
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: PageView(
              controller: _pageController,
              physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
              onPageChanged: (index) => _onPageChanged(index, provider),
              children: [
                _buildTickerDashboard(context, provider, TickerType.ttalspi),
                _buildTickerDashboard(context, provider, TickerType.yadongspi),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTickerDashboard(
    BuildContext context,
    HodlProvider provider,
    TickerType ticker,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StockTickerSummaryCard(ticker: ticker),
          ProfitCard(ticker: ticker),
          HodlTimerWidget(ticker: ticker),
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
              onPressed: () {
                if (provider.activeTicker != ticker) {
                  provider.switchTicker(ticker);
                }
                LiquidationModal.show(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.heart_broken_outlined,
                    color: AppColors.electricRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ticker.panicButtonText,
                    style: const TextStyle(
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
