import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'ticker_type.dart';

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

  static const List<HodlRank> ttalspiRanks = [
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

  static const List<HodlRank> yadongspiRanks = [
    HodlRank(
      level: 0,
      title: 'Lv.0 시크릿탭 중독자',
      subtitle: '검은 창 속에서 썩어가는 동태눈깔',
      commentary: '창 닫아라 게이야!! 지금 시크릿 모드 켜면 도파민 전액 몰수되고 뇌 녹는다!',
      requiredDuration: Duration.zero,
      color: AppColors.textSecondary,
      icon: Icons.phonelink_erase,
    ),
    HodlRank(
      level: 1,
      title: 'Lv.1 1일차 청정 브라우저',
      subtitle: '시크릿 모드 봉인 & 찬물 세수',
      commentary: '검색창 유혹을 쳐내고 첫 단계를 넘겼다. 폰 던지고 현실 책을 펴라.',
      requiredDuration: Duration(hours: 1),
      color: AppColors.electricBlue,
      icon: Icons.security,
    ),
    HodlRank(
      level: 2,
      title: 'Lv.2 3일차 도파민 수호병',
      subtitle: '알고리즘 릴스 유혹 격퇴',
      commentary: '탐색탭의 자극적인 썸네일을 피눈물 흘리며 차단했다. 전두엽 회복 진행 중!',
      requiredDuration: Duration(hours: 6),
      color: AppColors.purple,
      icon: Icons.vpn_lock,
    ),
    HodlRank(
      level: 3,
      title: 'Lv.3 7일차 청정뇌 현자',
      subtitle: '시각적 폭력 탈출, 동태눈깔 탈출',
      commentary: '하루 돌파! 뇌 속 도파민 수용체가 다시 살아나 세상이 선명하게 보인다.',
      requiredDuration: Duration(hours: 24),
      color: AppColors.neonGreen,
      icon: Icons.auto_awesome,
    ),
    HodlRank(
      level: 4,
      title: 'Lv.4 슈퍼 클린러 (다이아몬드)',
      subtitle: '뇌 가소성 정상화 완료, 집중력 극대화',
      commentary: '3일 연속 노야동! 시각적 자극 없이도 삶에 몰입할 수 있는 강철 전두엽 장착.',
      requiredDuration: Duration(days: 3),
      color: AppColors.gold,
      icon: Icons.diamond_outlined,
    ),
    HodlRank(
      level: 5,
      title: 'Lv.5 30일+ 노야동 득도자',
      subtitle: '음란마귀 완벽 퇴마! 전두엽 극락왕생',
      commentary: '일주일 이상 완전 청정! 어떤 야동 사이트도 널 흔들 수 없다. 갓생 마스터.',
      requiredDuration: Duration(days: 7),
      color: AppColors.gold,
      icon: Icons.workspace_premium,
    ),
  ];

  static List<HodlRank> getRanksFor(TickerType ticker) {
    return ticker == TickerType.yadongspi ? yadongspiRanks : ttalspiRanks;
  }

  static List<HodlRank> get allRanks => ttalspiRanks;

  static HodlRank getRank(Duration duration, {TickerType ticker = TickerType.ttalspi}) {
    final ranks = getRanksFor(ticker);
    for (int i = ranks.length - 1; i >= 0; i--) {
      if (duration >= ranks[i].requiredDuration) {
        return ranks[i];
      }
    }
    return ranks.first;
  }
}
