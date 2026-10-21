import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isAnimating = false;

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
      _isAnimating = true;
      _pageController
          .animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final activeTicker = provider.activeTicker;
    final expectedPage = activeTicker == TickerType.ttalspi ? 0 : 1;

    // External change sync (e.g. if activeTicker changes from dashboard or notification)
    if (!_isAnimating &&
        _currentPage != expectedPage &&
        _pageController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients && !_isAnimating) {
          _isAnimating = true;
          _pageController
              .animateToPage(
                expectedPage,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
              )
              .then((_) {
            _isAnimating = false;
          });
        }
      });
    }

    final ttalspiUnlocked = provider.getUnlockedCountFor(TickerType.ttalspi);
    final ttalspiTotal = provider.getTotalCountFor(TickerType.ttalspi);
    final yadongspiUnlocked =
        provider.getUnlockedCountFor(TickerType.yadongspi);
    final yadongspiTotal = provider.getTotalCountFor(TickerType.yadongspi);

    final selectedTicker =
        _currentPage == 0 ? TickerType.ttalspi : TickerType.yadongspi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Ticker Filter Segment
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterTab(
                      title: '🍆 딸스피',
                      countStr: '$ttalspiUnlocked / $ttalspiTotal',
                      isSelected: selectedTicker == TickerType.ttalspi,
                      onTap: () {
                        provider.switchTicker(TickerType.ttalspi);
                        _animateToTicker(TickerType.ttalspi);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterTab(
                      title: '🔞 야동스피',
                      countStr: '$yadongspiUnlocked / $yadongspiTotal',
                      isSelected: selectedTicker == TickerType.yadongspi,
                      onTap: () {
                        provider.switchTicker(TickerType.yadongspi);
                        _animateToTicker(TickerType.yadongspi);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Slide Gesture Hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_outlined,
                    size: 13,
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '화면 좌우 슬라이드로 종목 이동 (스와이프)',
                    style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Swipable Achievements PageView
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
                _buildAchievementsList(context, provider, TickerType.ttalspi),
                _buildAchievementsList(context, provider, TickerType.yadongspi),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsList(
    BuildContext context,
    HodlProvider provider,
    TickerType ticker,
  ) {
    final achievements = provider
        .getAchievementsFor(ticker)
        .where((a) => a.category == 'all' || a.category == ticker.name)
        .toList();

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final isYadong = ticker == TickerType.yadongspi;

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
                    Row(
                      children: [
                        Text(ticker.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '${ticker.nameKo} 명예의 전당',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isYadong
                      ? '수많은 개미들이 시크릿 모드 검은 창에 뇌를 녹일 때, 전두엽 방화벽을 사수한 자만이 청정뇌를 얻는다.'
                      : '수많은 딸잡이들이 10초의 쾌락에 패닉셀할 때, 끝까지 손 묶고 버텨낸 자만이 갓생을 산다.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.electricRed.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.electricRed,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isYadong
                              ? '※ 야동 시청 시 [야동스피] 명예의 전당은 즉시 리셋되며, 달성한 도전과제는 [현타 회고록]에 영구 박제됩니다.'
                              : '※ 패닉셀(한발빼기) 시 [딸스피] 명예의 전당은 즉시 리셋되며, 달성한 도전과제는 [현타 회고록]에 영구 박제됩니다.',
                          style: const TextStyle(
                            color: AppColors.electricRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  color: isUnlocked
                      ? AppColors.cardSurface
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isUnlocked
                        ? AppColors.gold.withValues(alpha: 0.4)
                        : AppColors.border,
                    width: isUnlocked ? 1.2 : 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUnlocked
                              ? AppColors.gold.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          ach.icon,
                          style: TextStyle(
                            fontSize: 22,
                            color: isUnlocked ? null : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ach.title,
                                  style: TextStyle(
                                    color: isUnlocked
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isUnlocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '달성 완료',
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const Text(
                                  '🔒 미달성',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ach.subtitle,
                            style: TextStyle(
                              color: isUnlocked
                                  ? AppColors.neonGreen
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ach.description,
                            style: TextStyle(
                              color: isUnlocked
                                  ? AppColors.textSecondary
                                  : AppColors.textMuted.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                          if (isUnlocked && ach.unlockedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              '달성일: ${DateFormat('yyyy.MM.dd HH:mm').format(ach.unlockedAt!)}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
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
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String title,
    required String countStr,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cardSurface
              : AppColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonGreen.withValues(alpha: 0.2)
                    : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                countStr,
                style: TextStyle(
                  color: isSelected ? AppColors.neonGreen : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
