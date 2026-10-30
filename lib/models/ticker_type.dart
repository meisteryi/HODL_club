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
          '📱 침대 눕방 중 인스타/SNS 돋보기 여캠에 뇌 녹음',
          '🌙 새벽 2시 외로움과 불면에 굴복하고 패닉셀',
          '🍺 불금 음주 후 자제력 0% 상태에서 대참사',
          '😵 "딱 오늘만 치고 내일부터 갓생" 자기합리화 시전',
          '🛌 주말 무료함에 침대와 합체되어 무기력하게 손실',
          '🚿 샤워하다 순간 충동 못 이기고 거품 매도',
          '💼 시험/업무 스트레스 보상 심리로 매도 버튼 광클',
          '🥱 잠 안 온다고 폰 만지작거리다 호기심 폭발',
          '🛑 "손 떼자" 결심해놓고 3초 만에 뇌 정지',
          '⚡ 모닝 텐트 제어 실패하고 아침부터 계좌 청산',
          '🍕 야식 먹고 도파민 폭주 상태에서 연쇄 폭락',
          '🚪 혼자 있는 방 안의 정적을 견디지 못하고 매도',
        ];
      case TickerType.yadongspi:
        return [
          '🕵️ 크롬/사파리 시크릿 모드 은밀하게 켜버림',
          '📱 알고리즘 여캠 릴스/쇼츠 30분 보다가 결국 웹서핑',
          '🐦 SNS 검색창에 자극적인 키워드 입력 후 유혹 굴복',
          '😵 "1분만 미리보기하고 끈다" 자기합리화 대실패',
          '🔞 예전 북마크/클라우드 흔적 못 참고 광클',
          '💭 뇌내 잡념과 망상에 못 이겨 시크릿 탭 오픈',
          '🌙 새벽 감성에 이성 마비되어 유혹 사이트 접속',
          '💻 컴퓨터 앞에서 멍때리다 손가락이 자동 이동',
          '☕ 카페인 과다로 심장 뛰고 폰 잡았다가 알고리즘 함정',
          '🚫 팝업 광고 유혹에 홀려 클릭 후 뇌 정지',
          '🛌 피곤한데 폰 끄기 싫어서 스크롤 내리다 유혹 패배',
          '📉 "오늘 하루만 눈팅해야지" 흑우 마인드 발동',
        ];
    }
  }
}
