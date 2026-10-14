import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HodlRank {
  final int level;
  final String title;
  final String subtitle;
  final String commentary;
  final Duration requiredDuration;
  final Color color;
  final IconData icon;

  const HodlRank({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.commentary,
    required this.requiredDuration,
    required this.color,
    required this.icon,
  });

  static const List<HodlRank> allRanks = [
    HodlRank(
      level: 0,
      title: 'Lv.0 방구석 딸잡이',
      subtitle: '손가락 바지 속 침투 직전',
      commentary: '손 떼라 게이야!! 지금 한 발 빼면 오늘 하루도 휴지 버리고 현타 와서 천장만 본다!',
      requiredDuration: Duration.zero,
      color: AppColors.textSecondary,
      icon: Icons.front_hand_outlined,
    ),
    HodlRank(
      level: 1,
      title: 'Lv.1 1일차 금딸러',
      subtitle: '쿠퍼액 분비 경보 발령',
      commentary: '단타 치려는 뇌의 충동을 겨우 버텨냈다 이기. 폰 덮고 찬물 한 잔 마셔라.',
      requiredDuration: Duration(hours: 1),
      color: AppColors.electricBlue,
      icon: Icons.shield_outlined,
    ),
    HodlRank(
      level: 2,
      title: 'Lv.2 3일차 몽정 경계병',
      subtitle: '온 세상이 야애니로 보임',
      commentary: '스윙 구간 진입! 시선 닿는 곳마다 음란마귀가 씌었지만 멘탈로 짓밟고 있다.',
      requiredDuration: Duration(hours: 6),
      color: AppColors.purple,
      icon: Icons.visibility_outlined,
    ),
    HodlRank(
      level: 3,
      title: 'Lv.3 7일차 갓생 현자',
      subtitle: '브레인포그 소멸, 눈빛 충전',
      commentary: '상한가 안착! 뇌내 안개(브레인포그) 걷히고 눈빛에서 테스토스테론 레이저 뿜어져 나온다.',
      requiredDuration: Duration(hours: 24),
      color: AppColors.neonGreen,
      icon: Icons.bolt,
    ),
    HodlRank(
      level: 4,
      title: 'Lv.4 슈퍼 금딸러 (다이아몬드)',
      subtitle: '매도 버튼 영구 압수 완료',
      commentary: '3일 연속 존버! 뇌가 완전히 도파민 리셋 중이다. 헬스장 덤벨 다 뽑아버린다.',
      requiredDuration: Duration(days: 3),
      color: AppColors.gold,
      icon: Icons.diamond_outlined,
    ),
    HodlRank(
      level: 5,
      title: 'Lv.5 30일+ 금딸 대현자',
      subtitle: '공중부양 직전, 도파민의 신',
      commentary: '일주일 이상 돌파! 세력의 모든 유혹을 초월했다. 넌 이미 인간을 넘어선 도인이다.',
      requiredDuration: Duration(days: 7),
      color: AppColors.gold,
      icon: Icons.workspace_premium,
    ),
  ];

  static HodlRank getRank(Duration duration) {
    for (int i = allRanks.length - 1; i >= 0; i--) {
      if (duration >= allRanks[i].requiredDuration) {
        return allRanks[i];
      }
    }
    return allRanks.first;
  }
}
