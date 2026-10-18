import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';

class CircuitBreakerModal extends StatefulWidget {
  const CircuitBreakerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CircuitBreakerModal(),
    );
  }

  @override
  State<CircuitBreakerModal> createState() => _CircuitBreakerModalState();
}

class _CircuitBreakerModalState extends State<CircuitBreakerModal>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _sirenController;

  int _tapCount = 0;
  final int _targetTaps = 15;
  int _secondsLeft = 5;
  Timer? _countdownTimer;
  bool _isGameOver = false;
  bool _isSuccess = false;
  bool _isGameStarted = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _sirenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _confettiController.dispose();
    _sirenController.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isGameStarted = true;
      _tapCount = 0;
      _secondsLeft = 5;
      _isGameOver = false;
      _isSuccess = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        _onTimeExpired();
      }
    });
  }

  void _handleTap() {
    if (!_isGameStarted || _isGameOver) return;

    setState(() {
      _tapCount++;
    });

    if (_tapCount >= _targetTaps) {
      _countdownTimer?.cancel();
      _confettiController.play();
      setState(() {
        _isGameOver = true;
        _isSuccess = true;
      });
      context.read<HodlProvider>().triggerCircuitBreakerSuccess();
    }
  }

  void _onTimeExpired() {
    if (_tapCount < _targetTaps) {
      setState(() {
        _isGameOver = true;
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isSuccess
                    ? AppColors.neonGreen
                    : AppColors.electricRed.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isSuccess ? AppColors.neonGreen : AppColors.electricRed)
                      .withValues(alpha: 0.25),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Header
                AnimatedBuilder(
                  animation: _sirenController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isSuccess
                            ? AppColors.darkGreen
                            : Color.lerp(
                                AppColors.darkRed,
                                AppColors.electricRed.withValues(alpha: 0.4),
                                _sirenController.value,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSuccess ? AppColors.neonGreen : AppColors.electricRed,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.warning_amber_rounded,
                            color: _isSuccess ? AppColors.neonGreen : AppColors.electricRed,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSuccess
                                ? '서킷브레이커 발동 완료!'
                                : '🚨 [속보] 바지 속 그 녀석 기상! 서킷브레이커!',
                            style: TextStyle(
                              color: _isSuccess ? AppColors.neonGreen : AppColors.electricRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Humor News Content
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '“뇌내 세력의 ‘딱 한 발만 빼자’ 악성 선동 포착!”',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '손 떼라 게이야!! 지금 치면 또 휴지 치우고 벽 보면서 현타 온다 ㅋㅋ\n5초 안에 매도 버튼(손)을 미친 듯이 광클해서 손가락 쳐내라!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (!_isGameStarted) ...[
                  // Start Game Button
                  const Text(
                    '제한시간 5초 안에 15회 광클로 손 쳐내기',
                    style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricRed,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      onPressed: _startGame,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '이성 사수 연타 미니게임 시작',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (_isGameOver && _isSuccess) ...[
                  // Success State
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkGreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.neonGreen),
                    ),
                    child: const Column(
                      children: [
                        Text('🎉 텐트 강제 철거 및 이성 사수 성공!', style: TextStyle(color: AppColors.neonGreen, fontSize: 15, fontWeight: FontWeight.w900)),
                        SizedBox(height: 6),
                        Text(
                          '손가락이 바지 밖으로 강제 퇴출되었습니다.\n쿠퍼액 누출이 중단되고 뇌세포가 살아났습니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonGreen,
                        foregroundColor: AppColors.textInverse,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('전선으로 복귀 (존버 가즈아)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (_isGameOver && !_isSuccess) ...[
                  // Failed Game State
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.electricRed),
                    ),
                    child: Column(
                      children: [
                        const Text('⚠️ 손 떼기 지연! 뇌 녹는 중', style: TextStyle(color: AppColors.electricRed, fontSize: 15, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        Text(
                          '광클 속도가 부족했다 게이야 ($_tapCount/$_targetTaps).\n심호흡 크게 하고 푸쉬업 20개 박고 다시 쳐내라!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('닫기', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _startGame,
                          child: const Text('다시 손 쳐내기', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Active Mini Game Tap frenzy
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '남은 시간: $_secondsLeft초',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        '$_tapCount / $_targetTaps 회',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _tapCount / _targetTaps,
                      backgroundColor: AppColors.cardSurface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _handleTap,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.electricRed, Color(0xFFB91C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.electricRed.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.back_hand, color: Colors.white, size: 28),
                            const SizedBox(height: 4),
                            Text(
                              '💥 손 쳐내기!! (${_targetTaps - _tapCount}회 남음)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              '바지 속 손을 향해 화면을 미친 듯이 탭하세요!',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                if (!_isGameStarted || _isGameOver)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('창 닫기', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
              ],
            ),
          ),

          // Confetti widget
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.neonGreen,
              AppColors.gold,
              AppColors.electricBlue,
              Colors.white,
            ],
          ),
        ],
      ),
    );
  }
}
