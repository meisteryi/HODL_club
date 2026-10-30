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
        return '손 떼라 게이야';
      case TickerType.yadongspi:
        return '창 닫아라 게이야';
    }
  }

  String get subTitle {
    switch (this) {
      case TickerType.ttalspi:
        return 'KRW-DOSP • 뇌 녹아내림 방지 & 테스토스테론 떡상';
      case TickerType.yadongspi:
        return 'KRW-YDSP • 시크릿탭 0개 & 전두엽 심폐소생';
    }
  }

  String get timerLabel {
    switch (this) {
      case TickerType.ttalspi:
        return '실시간 금딸 무발사 존버 타이머';
      case TickerType.yadongspi:
        return '실시간 노야동 청정뇌 존버 타이머';
    }
  }

  String get timerStatus {
    switch (this) {
      case TickerType.ttalspi:
        return '바지 속 손 묶고 버티는 중 🔒';
      case TickerType.yadongspi:
        return '시크릿탭 전량 차단 유지 🛡️';
    }
  }

  String get panicButtonText {
    switch (this) {
      case TickerType.ttalspi:
        return '결국 뇌 녹아서 발사 (딸치고 깡통 차기 📉)';
      case TickerType.yadongspi:
        return '결국 시크릿 모드 켬 (야동 보고 깡통 차기 📉)';
    }
  }

  String get delistedTitle {
    switch (this) {
      case TickerType.ttalspi:
        return '🚨 [딸스피] 전량 매도 & 깡통 상폐';
      case TickerType.yadongspi:
        return '🚨 [야동스피] 시크릿 침투 & 깡통 상폐';
    }
  }

  String get delistedSubtitle {
    switch (this) {
      case TickerType.ttalspi:
        return '10초의 쾌락에 -1,000P 폭락! 현타 500배 & 천장 응시';
      case TickerType.yadongspi:
        return '음란마귀에 전두엽 털림! -2,000P 폭락 & 자괴감 500배';
    }
  }

  String get restartButtonText {
    switch (this) {
      case TickerType.ttalspi:
        return '눈물 닦고 딸스피 재매수 (한강 안 간다)';
      case TickerType.yadongspi:
        return '시크릿탭 끄고 야동스피 재매수 (갓생 복귀)';
    }
  }

  List<String> get defaultReasons {
    switch (this) {
      case TickerType.ttalspi:
        return [
          '🔞 트위터/야동 5분만 눈팅하려다 대참사',
          '📱 침대 눕방 중 인스타 돋보기 여캠에 뇌 녹음',
          '🛌 멍때리다 무의식중에 손이 바지 속으로 들어감',
          '🌙 새벽 2시 외로움에 굴복하고 휴지 뽑음',
          '🚿 샤워하다 충동 못 이기고 거품 매도',
          '😵 "딱 오늘만 치고 내일부터 갓생" 개소리 시전',
        ];
      case TickerType.yadongspi:
        return [
          '🕵️ 크롬 시크릿 모드 은밀하게 켜버림',
          '🐦 트위터 검색창에 위험한 단어 입력',
          '🔞 북마크 사이트 유혹 못 참고 광클',
          '📱 알고리즘 여캠 릴스 30분 보다가 결국 서핑',
          '💭 뇌내 음란마귀 망상에 못 이겨 검색 실행',
          '😵 "1분만 미리보기하고 끈다" 자기합리화 실패',
        ];
    }
  }
}
