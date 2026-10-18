enum TickerType {
  ttalspi,   // 딸스피 (금딸/무발사 지수)
  yadongspi, // 야동스피 (시크릿모드/음란물 금지 지수)
}

extension TickerTypeExtension on TickerType {
  String get id => name;

  String get nameKo {
    switch (this) {
      case TickerType.ttalspi:
        return '딸스피';
      case TickerType.yadongspi:
        return '야동스피';
    }
  }

  String get code {
    switch (this) {
      case TickerType.ttalspi:
        return 'DOSP';
      case TickerType.yadongspi:
        return 'YDSP';
    }
  }

  String get symbol {
    switch (this) {
      case TickerType.ttalspi:
        return 'KRW-DOSP';
      case TickerType.yadongspi:
        return 'KRW-YDSP';
    }
  }

  String get icon {
    switch (this) {
      case TickerType.ttalspi:
        return '🍆';
      case TickerType.yadongspi:
        return '🔞';
    }
  }

  String get tagLine {
    switch (this) {
      case TickerType.ttalspi:
        return '손 떼라';
      case TickerType.yadongspi:
        return '창 닫아라';
    }
  }

  String get subTitle {
    switch (this) {
      case TickerType.ttalspi:
        return 'KRW-DOSP • 뇌 안개(브레인포그) 청산 중';
      case TickerType.yadongspi:
        return 'KRW-YDSP • 시크릿탭/음란마귀 청산 중';
    }
  }

  String get timerLabel {
    switch (this) {
      case TickerType.ttalspi:
        return '실시간 금딸(무발사) 존버 타이머';
      case TickerType.yadongspi:
        return '실시간 노야동(청정뇌) 존버 타이머';
    }
  }

  String get timerStatus {
    switch (this) {
      case TickerType.ttalspi:
        return '손 묶고 버티는 중 🔒';
      case TickerType.yadongspi:
        return '시크릿탭 0개 유지 중 🛡️';
    }
  }

  String get panicButtonText {
    switch (this) {
      case TickerType.ttalspi:
        return '결국 충동에 굴복 (한 발 빼기 & -2000P 폭락)';
      case TickerType.yadongspi:
        return '결국 유혹에 굴복 (야동 시청 & -2000P 폭락)';
    }
  }

  String get delistedTitle {
    switch (this) {
      case TickerType.ttalspi:
        return '[딸스피] 상장 폐지 & 폭락';
      case TickerType.yadongspi:
        return '[야동스피] 상장 폐지 & 폭락';
    }
  }

  String get delistedSubtitle {
    switch (this) {
      case TickerType.ttalspi:
        return '도파민 몰수! 지수 -2,000P 폭락 & 현타 100%';
      case TickerType.yadongspi:
        return '음란마귀 침투! 지수 -2,000P 폭락 & 자괴감 100%';
    }
  }

  String get restartButtonText {
    switch (this) {
      case TickerType.ttalspi:
        return '눈물 닦고 딸스피 재도전';
      case TickerType.yadongspi:
        return '시크릿탭 끄고 야동스피 재도전';
    }
  }

  List<String> get defaultReasons {
    switch (this) {
      case TickerType.ttalspi:
        return [
          '🔞 야동/트위터 5분만 보려다가',
          '📱 침대에서 인스타 돋보기 보다가',
          '🛌 무기력하게 눕방하다 무의식중에 쥐고 흔듦',
          '🌙 새벽 2시 외로움과 잡념에 굴복',
          '🚿 샤워하다 충동 못 참고 그만...',
          '😵 “딱 한 번만 치고 내일부터 갓생” 합리화',
        ];
      case TickerType.yadongspi:
        return [
          '🕵️ 크롬 시크릿 모드 슬그머니 켬',
          '🐦 트위터/X 검색창에 은밀한 단어 검색',
          '🔞 폰허브/야동 사이트 북마크 못 참고 클릭',
          '📱 인스타 돋보기에서 여캠 릴스 30분 시청',
          '💭 뇌 속 음란마귀 망상에 결국 검색창 실행',
          '😵 "미리보기 1분만 보고 끈다" 자기합리화',
        ];
    }
  }
}
