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
      // 1. 초기 생존 구간
      const Achievement(
        id: 'FIRST_CANDLE',
        title: '첫 10분 돌파',
        subtitle: '바지에서 손 빼기 성공',
        description: '지퍼 내리려던 손을 멈추고 10분간 버텼습니다. 뇌내 차트에 첫 초록색 양봉 출현!',
        icon: '🛑',
        rewardTitle: '손 묶인 개미',
      ),
      const Achievement(
        id: 'MIN_30',
        title: '30분 생존: 지퍼 방어',
        subtitle: '위기일발 지퍼 사수',
        description: '손이 무의식중에 벨트를 풀 뻔했으나 온 힘을 다해 주머니로 피신시켰습니다.',
        icon: '👖',
        rewardTitle: '지퍼 수호신',
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
        id: 'HOUR_3',
        title: '3시간 수성: 돋보기 봉인',
        subtitle: '도파민 절단기 가동',
        description: '알고리즘의 여캠 댄스 유혹을 피눈물 흘리며 뒤로가기 눌렀습니다.',
        icon: '📵',
        rewardTitle: '알고리즘 분쇄자',
      ),
      const Achievement(
        id: 'HOUR_6',
        title: '6시간 돌파: 뇌세포 산소 호흡',
        subtitle: '안개 낀 전두엽 정화',
        description: '반나절 동안 야한 생각을 안 하니 전두엽에 피가 돌고 눈앞이 맑아집니다.',
        icon: '🧠',
        rewardTitle: '맑은 뇌세포',
      ),
      const Achievement(
        id: 'HOUR_12',
        title: '12시간 무사고: 크리넥스 폭락',
        subtitle: '휴지 절약 지구환경 지킴이',
        description: '12시간 동안 휴지를 단 한 장도 낭비하지 않았습니다. 유한킴벌리가 긴장합니다.',
        icon: '🧻',
        rewardTitle: '휴지 세이버',
      ),

      // 2. 일 단위 돌파 구간
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
        id: 'DAY_3',
        title: '3일의 벽: 마의 작심삼일 격파',
        subtitle: '딸잡이 90%가 멸망하는 구간',
        description: '온몸의 신경이 폭발할 것 같던 3일차 고비를 넘기고 살아남은 진또배기.',
        icon: '🧱',
        rewardTitle: '삼일천하 파괴자',
      ),
      const Achievement(
        id: 'DAY_4',
        title: '4일차 각성: 눈빛에 서리는 살기',
        subtitle: '야수의 눈빛 장착',
        description: '흐리멍텅하던 동태눈깔에서 맹수의 안광이 뿜어져 나오기 시작합니다.',
        icon: '👁️',
        rewardTitle: '호랑이 안광',
      ),
      const Achievement(
        id: 'DAY_5',
        title: '5일차 저음: 동굴 목소리 발동',
        subtitle: '테스토스테론 급증 현상',
        description: '목소리가 1옥타브 내려앉아 전화받을 때 중후한 동굴 저음이 튀어나옵니다.',
        icon: '🎙️',
        rewardTitle: '동굴 보이스',
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
        id: 'DAY_10',
        title: '10일의 기적: 꿀피부 발현',
        subtitle: '개기름 퇴치 및 여드름 실종',
        description: '얼굴에 흐르던 칙칙한 개기름이 사라지고 자연산 물광 피부가 돋아납니다.',
        icon: '✨',
        rewardTitle: '무결점 피부',
      ),
      const Achievement(
        id: 'DAY_14',
        title: '2주 완주: 몽정 배당락 방어',
        subtitle: '무의식의 세계마저 정복',
        description: '꿈속 악마의 유혹마저 방어벽으로 튕겨낸 상위 0.1% 무적의 존버러.',
        icon: '🛡️',
        rewardTitle: '꿈속 퇴마사',
      ),
      const Achievement(
        id: 'DAY_21',
        title: '3주(21일): 습관 형성 완성',
        subtitle: '뇌 가소성 완벽 리셋',
        description: '이제 폰 쥐고 침대에 누워도 바지에 손이 가지 않는 자연인의 경지.',
        icon: '🧘',
        rewardTitle: '도파민 해탈자',
      ),
      const Achievement(
        id: 'DAY_30',
        title: '30일 몽크 모드: 인간계 초월',
        subtitle: '현자 타임 없는 영구 현자',
        description: '한 달간 무발사! 눈빛만으로 주변 양아치들을 기선제압할 수 있습니다.',
        icon: '🧙‍♂️',
        rewardTitle: '대마법사 후보',
      ),
      const Achievement(
        id: 'DAY_50',
        title: '50일 반백의 신화: 전설의 거목',
        subtitle: '뿌리 깊은 나무는 흔들리지 않는다',
        description: '어떤 유혹의 바람이 불어도 미동조차 하지 않는 강철의 멘탈.',
        icon: '🌲',
        rewardTitle: '거목 존버러',
      ),
      const Achievement(
        id: 'DAY_100',
        title: '100일 웅녀 모드: 신선 등극',
        subtitle: '마늘과 쑥을 씹어삼킨 인내',
        description: '곰도 사람이 된다는 100일 금딸 완성. 당신은 이미 신의 영역에 있습니다.',
        icon: '👑',
        rewardTitle: '다이아몬드 신선',
      ),

      // 3. 야간 및 기상 긴급 상황
      const Achievement(
        id: 'MIDNIGHT_SAVIOR',
        title: '새벽 2시 마귀 퇴치',
        subtitle: '새벽 감성 음란마귀 컷',
        description: '새벽 2시에 시크릿 모드 켜려다 스마트폰 엎어두고 이불 덮었습니다.',
        icon: '🌙',
        rewardTitle: '새벽 순찰대',
      ),
      const Achievement(
        id: 'DAWN_WARRIOR',
        title: '새벽 4시 악마의 속삭임 진압',
        subtitle: '외로움의 쓰나미 방어',
        description: '모두가 잠든 고요한 시간, 끓어오르는 충동을 팔굽혀펴기로 승화했습니다.',
        icon: '🥊',
        rewardTitle: '새벽의 파이터',
      ),
      const Achievement(
        id: 'MORNING_WOOD',
        title: '모닝 텐트 강제 기상 승리',
        subtitle: '일어나자마자 찬물 한 컵',
        description: '아침에 바지가 찢어질 듯 솟아오른 텐트를 보고도 덤벨을 쥐었습니다.',
        icon: '⛺',
        rewardTitle: '모닝 덤벨러',
      ),

      // 4. 웃긴 돌발 행동 및 물리치료
      const Achievement(
        id: 'COLD_SHOWER',
        title: '얼음물 샤워: 급속 냉각 요원',
        subtitle: '온수 끄고 냉수 다이렉트 투하',
        description: '욕정에 불타던 하반신을 얼음장 같은 찬물로 단숨에 냉각시켰습니다.',
        icon: '🚿',
        rewardTitle: '빙하시대 생존자',
      ),
      const Achievement(
        id: 'DUMBBELL_REP',
        title: '피의 대이동: 삼두/이두 펌핑',
        subtitle: '하체 혈류 상체로 강제 징집',
        description: '엉뚱한 곳으로 쏠리던 혈류를 덤벨 컬 50회로 팔뚝에 전부 몰아넣었습니다.',
        icon: '🏋️',
        rewardTitle: '혈류 징집관',
      ),
      const Achievement(
        id: 'CLEAN_BROWSER',
        title: '시크릿 탭 0개: 결백한 사나이',
        subtitle: '검은 창을 잊어버린 자',
        description: '브라우저 시크릿 탭 개수가 0개입니다. 경찰이 폰 검사해도 당당합니다.',
        icon: '🕵️',
        rewardTitle: '청정 시민',
      ),
      const Achievement(
        id: 'PAPER_HAND_SHAME',
        title: '휴지 뽑다 집어던지기',
        subtitle: '종이손(Paper Hand) 탈출기',
        description: '휴지 한 장 뽑았다가 "내가 짐승이냐!" 소리치며 쓰레기통에 처박았습니다.',
        icon: '🗑️',
        rewardTitle: '탈인간 선언',
      ),
      const Achievement(
        id: 'MIRROR_SLAP',
        title: '거울 보고 자아성찰',
        subtitle: '정신 번쩍 드는 싸대기',
        description: '거울 속 멍청한 표정을 보고 뺨을 한 대 후려쳐 이성을 되찾았습니다.',
        icon: '🪞',
        rewardTitle: '자아성찰가',
      ),
      const Achievement(
        id: 'GIGA_CHAD',
        title: '기가 차드(Giga Chad) 모드',
        subtitle: '턱선에 면도날 박힘',
        description: '금딸로 축적된 테스토스테론이 온몸을 지배하여 걸음걸이부터 달라졌습니다.',
        icon: '🗿',
        rewardTitle: '상남자 기가차드',
      ),
      const Achievement(
        id: 'CHART_OBSESSED',
        title: '차트 중독자: 돋보기 검증',
        subtitle: '분봉 주봉 무한 순회',
        description: '1분봉, 10분봉, 일봉, 주봉을 쉼 없이 번갈아 확인하며 자산 가치를 감상함.',
        icon: '📊',
        rewardTitle: '차트 감정사',
      ),

      // 5. 서킷 브레이커 & SOS
      const Achievement(
        id: 'CIRCUIT_BREAKER_HERO',
        title: '현타 직전 발작 진압',
        subtitle: '서킷브레이커 15회 연타 성공',
        description: '팬티 속으로 들어가려던 손을 미친 듯이 쳐내고 이성을 되찾았습니다.',
        icon: '⚡',
        rewardTitle: '현타 특공대',
      ),
      const Achievement(
        id: 'CIRCUIT_BREAKER_3',
        title: '서킷브레이커 3회: 긴급 타격대',
        subtitle: '손바닥 물리치료 마스터',
        description: '폭락 위기 때마다 SOS 버튼을 3회 이상 발동시켜 갓생을 수호했습니다.',
        icon: '🚨',
        rewardTitle: '긴급 출동대',
      ),
      const Achievement(
        id: 'CIRCUIT_BREAKER_10',
        title: '서킷브레이커 10회: 액정 파괴자',
        subtitle: '빛의 속도로 15타 연타',
        description: '화면 액정이 깨질 정도로 탭하여 도파민 마귀를 무자비하게 폭행했습니다.',
        icon: '💥',
        rewardTitle: '화면 파괴범',
      ),

      // 6. 수익률 & 시가총액 폭등
      const Achievement(
        id: 'RETURN_10',
        title: '수익률 +10%: 국장 코스피 압살',
        subtitle: '삼전보다 높은 존버 수익률',
        description: '가만히 손만 안 댔을 뿐인데 내 인생 자산 가치가 +10% 떡상했습니다.',
        icon: '📈',
        rewardTitle: '양봉 개미',
      ),
      const Achievement(
        id: 'RETURN_50',
        title: '수익률 +50%: 로켓 점화',
        subtitle: '테슬라 뺨치는 수직 상승',
        description: '주변 친구들 딸치고 누워있을 때 나 혼자 갓생 가치 1.5배 폭등 중.',
        icon: '🔥',
        rewardTitle: '로켓 홀더',
      ),
      const Achievement(
        id: 'WHALE_CLUB',
        title: '수익률 +100% 돌파',
        subtitle: '원금 2배 떡상 (갓생 고래 주주)',
        description: '자산 가치가 원금 대비 2배로 폭등했습니다. 헬스장 덤벨 다 뽑아버릴 기세입니다.',
        icon: '🦾',
        rewardTitle: '테스토스테론 괴물',
      ),
      const Achievement(
        id: 'RETURN_200',
        title: '수익률 +200%: 트리플 텐배거',
        subtitle: '원금 3배 떡상의 주인공',
        description: '자산 가치가 원금의 3배를 찍었습니다. 길거리 걸을 때 어깨가 벽에 걸립니다.',
        icon: '🦍',
        rewardTitle: '알파 메일',
      ),
      const Achievement(
        id: 'RETURN_500',
        title: '수익률 +500%: 비트코인 씹어먹기',
        subtitle: '인생 시가총액 5배 대폭발',
        description: '존버의 힘으로 원금 대비 500% 수익률을 돌파했습니다. 걸어 다니는 대기업.',
        icon: '🪙',
        rewardTitle: '도파민 재벌',
      ),

      // 7. 부활 및 환생 (로그라이크)
      const Achievement(
        id: 'RESURRECTION',
        title: '불사조 금딸러',
        subtitle: '발사 후 재상장 성공',
        description: '휴지 버리고 천장 보며 흘린 눈물을 딛고 다시 신규 상장했습니다. 다음엔 진짜다.',
        icon: '🔥',
        rewardTitle: '참회의 현자',
      ),
      const Achievement(
        id: 'PHOENIX_5',
        title: '칠전팔기 불사조: 5회 환생',
        subtitle: '넘어져도 다시 서는 불굴의 의지',
        description: '5번의 상폐(발사)를 겪고도 끝끝내 다시 일어난 미친 집념의 좀비.',
        icon: '🧟',
        rewardTitle: '불사신 좀비',
      ),
    ];
  }
}
