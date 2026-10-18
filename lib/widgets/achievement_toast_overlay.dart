import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/achievement.dart';
import '../providers/hodl_provider.dart';

class AchievementToastOverlay extends StatefulWidget {
  final VoidCallback? onOpenAchievements;

  const AchievementToastOverlay({
    super.key,
    this.onOpenAchievements,
  });

  @override
  State<AchievementToastOverlay> createState() => _AchievementToastOverlayState();
}

class _AchievementToastOverlayState extends State<AchievementToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _dismissTimer;
  Achievement? _displayedAchievement;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _handleNewNotification(Achievement achievement, HodlProvider provider) {
    if (_displayedAchievement?.id == achievement.id && _animController.isAnimating) {
      return;
    }

    _displayedAchievement = achievement;
    _dismissTimer?.cancel();

    // Haptic vibration feedback on achievement unlock
    HapticFeedback.mediumImpact();

    _animController.forward(from: 0.0).then((_) {
      _dismissTimer = Timer(const Duration(milliseconds: 3600), () {
        _dismiss(provider);
      });
    });
  }

  void _dismiss(HodlProvider provider) {
    _dismissTimer?.cancel();
    if (mounted) {
      _animController.reverse().then((_) {
        if (mounted) {
          _displayedAchievement = null;
          provider.dismissCurrentAchievementNotification();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final notification = provider.currentAchievementNotification;

    if (notification != null && _displayedAchievement?.id != notification.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleNewNotification(notification, provider);
        }
      });
    }

    if (_displayedAchievement == null) {
      return const SizedBox.shrink();
    }

    final achievement = _displayedAchievement!;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dismissible(
            key: ValueKey(achievement.id + DateTime.now().millisecondsSinceEpoch.toString()),
            direction: DismissDirection.up,
            onDismissed: (_) {
              _dismiss(provider);
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  _dismiss(provider);
                  widget.onOpenAchievements?.call();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface,
                        AppColors.cardSurface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Golden glowing achievement icon container
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppColors.gold,
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            achievement.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.emoji_events_rounded,
                                      size: 13,
                                      color: AppColors.gold,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '도전과제 달성!',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '터치하여 확인 ›',
                                    style: TextStyle(
                                      color: AppColors.neonGreen,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              achievement.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              achievement.rewardTitle.isNotEmpty
                                  ? '🏅 칭호: [${achievement.rewardTitle}] 획득'
                                  : achievement.subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
