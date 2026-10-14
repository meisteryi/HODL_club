class Achievement {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final String rewardTitle;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.rewardTitle,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      icon: icon,
      rewardTitle: rewardTitle,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      const Achievement(
        id: 'FIRST_CANDLE',
        title: '첫 10분 돌파',
        subtitle: '바지에서 손 빼기 성공',
        description: '지퍼 내리려던 손을 멈추고 10분간 버텼습니다. 뇌내 차트에 첫 초록색 양봉 출현!',
        icon: '🛑',
        rewardTitle: '손 묶인 개미',
      ),
      const Achievement(
        id: 'HOUR_HOLDER',
        title: '1시간 금딸 방어',
        subtitle: '초기 뇌 녹음 진압',
        description: '인스타 돋보기와 릴스 유혹을 이겨내고 1시간 동안 손을 바깥으로 유지했습니다.',
        icon: '🛡️',
        rewardTitle: '찬물샤워 러버',
      ),
      const Achievement(
        id: 'UPPER_LIMIT',
        title: '24시간 돌파 (첫 상한가)',
        subtitle: '1일 3딸 탈출 축하',
        description: '하루 종일 단 한 발도 빼지 않았습니다! 종가 기준 일일 가격제한폭(+30%)에 안착했습니다.',
        icon: '🚀',
        rewardTitle: '상한가 홀더',
      ),
      const Achievement(
        id: 'WEEKEND_SHIELD',
        title: '주말 48시간 수성',
        subtitle: '방구석 텐트 방어 사수',
        description: '뒹굴거리기 쉬운 토/일요일 방구석 유혹을 완벽히 격퇴했습니다.',
        icon: '⛺',
        rewardTitle: '강철 텐트',
      ),
      const Achievement(
        id: 'STEEL_MENTAL',
        title: '7일 연속 금딸',
        subtitle: '다이아몬드 고추 달성',
        description: '일주일 무발사! 뇌가 완전히 정화되어 피부에 윤기가 흐르고 눈빛이 살아납니다.',
        icon: '💎',
        rewardTitle: '살아있는 갓생러',
      ),
      const Achievement(
        id: 'CIRCUIT_BREAKER_HERO',
        title: '현타 직전 발작 진압',
        subtitle: '서킷브레이커 15회 연타 성공',
        description: '팬티 속으로 들어가려던 손을 미친 듯이 쳐내고 이성을 되찾았습니다.',
        icon: '⚡',
        rewardTitle: '현타 특공대',
      ),
      const Achievement(
        id: 'WHALE_CLUB',
        title: '수익률 +1,000% 폭등',
        subtitle: '테스토스테론 풀충전',
        description: '도파민이 주식 차트마냥 10배 폭등했습니다. 헬스장 덤벨 다 뽑아버릴 기세입니다.',
        icon: '🦾',
        rewardTitle: '테스토스테론 괴물',
      ),
      const Achievement(
        id: 'RESURRECTION',
        title: '불사조 금딸러',
        subtitle: '발사 후 재상장 성공',
        description: '휴지 버리고 천장 보며 흘린 눈물을 딛고 다시 신규 상장했습니다. 다음엔 진짜다.',
        icon: '🔥',
        rewardTitle: '참회의 현자',
      ),
    ];
  }
}
