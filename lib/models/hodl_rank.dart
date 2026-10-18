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
      subtitle: '손가락 바지 침투 1초 전',
      commentary: '손 떼라 게이야!! 지금 치면 또 휴지 버리고 벽 보고 자괴감 든다 ㅋㅋ',
      requiredDuration: Duration.zero,
      color: AppColors.textSecondary,
      icon: Icons.front_hand_outlined,
    ),
    HodlRank(
      level: 1,
      title: 'Lv.1 1일차 흑우 탈출러',
      subtitle: '쿠퍼액 분비 경보 발령',
      commentary: '단타 치려는 뇌세포 대가리 깨고 버텼노. 찬물 한 사발 들이켜라 이기.',
      requiredDuration: Duration(hours: 1),
      color: AppColors.electricBlue,
      icon: Icons.shield_outlined,
    ),
    HodlRank(
      level: 2,
      title: 'Lv.2 3일차 몽정 경계병',
      subtitle: '온 세상이 야애니로 보임',
      commentary: '스윙 구간 진입! 릴스 여캠 썸네일도 쳐내고 있다. 멘탈 다이아몬드 인정.',
      requiredDuration: Duration(hours: 6),
      color: AppColors.purple,
      icon: Icons.visibility_outlined,
    ),
    HodlRank(
      level: 3,
      title: 'Lv.3 7일차 갓생 현자',
      subtitle: '동태눈깔 탈출, 안광 발사',
      commentary: '상한가 안착! 뇌 안개(브레인포그) 싹 걷히고 테스토스테론 레이저 뿜는 중.',
      requiredDuration: Duration(hours: 24),
      color: AppColors.neonGreen,
      icon: Icons.bolt,
    ),
    HodlRank(
      level: 4,
      title: 'Lv.4 슈퍼 금딸러 (다이아몬드)',
      subtitle: '매도 버튼 영구 압수 완료',
      commentary: '3일 이상 돌파! 뇌 가소성 리셋됐다. 덤벨 다 뽑아버릴 기세노 ㅋㅋ',
      requiredDuration: Duration(days: 3),
      color: AppColors.gold,
      icon: Icons.diamond_outlined,
    ),
    HodlRank(
      level: 5,
      title: 'Lv.5 30일+ 금딸 대현자',
      subtitle: '공중부양 직전, 도파민의 신',
      commentary: '일주일 넘겼다 이기! 세력의 모든 유혹을 초월한 인간 승리자.',
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
      commentary: '창 닫아라 게이야!! 지금 시크릿 켜면 도파민 전액 몰수되고 뇌 녹는다!',
      requiredDuration: Duration.zero,
      color: AppColors.textSecondary,
      icon: Icons.phonelink_erase,
    ),
    HodlRank(
      level: 1,
      title: 'Lv.1 1일차 청정 브라우저',
      subtitle: '시크릿 모드 봉인 & 찬물 세수',
      commentary: '검색창 유혹 쳐내고 첫 관문 뚫었다. 폰 던지고 밖으로 나가라 이기.',
      requiredDuration: Duration(hours: 1),
      color: AppColors.electricBlue,
      icon: Icons.security,
    ),
    HodlRank(
      level: 2,
      title: 'Lv.2 3일차 전두엽 수호병',
      subtitle: '알고리즘 릴스 유혹 격퇴',
      commentary: '자극적인 썸네일 피눈물 흘리며 차단했다 이기. 뇌세포 회복 중!',
      requiredDuration: Duration(hours: 6),
      color: AppColors.purple,
      icon: Icons.vpn_lock,
    ),
    HodlRank(
      level: 3,
      title: 'Lv.3 7일차 청정뇌 현자',
      subtitle: '시각 테러 탈출, 맑은 눈의 광인',
      commentary: '하루 돌파! 도파민 수용체 살아나서 세상이 HD 화질로 보인다.',
      requiredDuration: Duration(hours: 24),
      color: AppColors.neonGreen,
      icon: Icons.auto_awesome,
    ),
    HodlRank(
      level: 4,
      title: 'Lv.4 슈퍼 클린러 (다이아몬드)',
      subtitle: '강철 전두엽 장착 완료',
      commentary: '3일 연속 노야동! 자극적인 짤 없이도 현실에 100% 몰입 가능.',
      requiredDuration: Duration(days: 3),
      color: AppColors.gold,
      icon: Icons.diamond_outlined,
    ),
    HodlRank(
      level: 5,
      title: 'Lv.5 30일+ 노야동 득도자',
      subtitle: '음란마귀 완벽 퇴마! 전두엽 극락왕생',
      commentary: '일주일 이상 완전 청정! 어떤 사이트도 널 흔들 수 없다. 갓생 완성.',
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
