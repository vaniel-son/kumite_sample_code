class MainEventLandingWidgetVisibilityModel {
  MainEventLandingWidgetVisibilityModel({
    this.isVisibleHostCardOne = false,
    this.isVisibleHostCardTwo = false,
    this.isVisibleCompetitionTimerEndsSoon = false,
    this.isVisibleCompetitionTimerStartsSoon = false,
    this.isVisiblePlayButton = false,
    this.isVisibleRequestAccessButton = false,
    this.isVisiblePushupsOverTimeChart = true,
    this.isVisibleLeaderboard = false,
    this.isVisibleInvitationPaid = false,
  });

  bool isVisibleHostCardOne;
  bool isVisibleHostCardTwo;
  bool isVisibleCompetitionTimerEndsSoon;
  bool isVisibleCompetitionTimerStartsSoon;
  bool isVisibleRequestAccessButton;
  bool isVisiblePlayButton;
  bool isVisiblePushupsOverTimeChart;
  bool isVisibleLeaderboard;
  bool isVisibleInvitationPaid;

  Map<String, dynamic> toMap(){
    return {
    'isVisibleHostCardOne': isVisibleHostCardOne,
    'isVisibleHostCardTwo': isVisibleHostCardTwo,
      'isVisibleCompetitionTimer': isVisibleCompetitionTimerEndsSoon,
      'isVisibleCompetitionTimerStartsSoon': isVisibleCompetitionTimerStartsSoon,
      'isVisibleRequestAccessButton': isVisibleRequestAccessButton,
      'isVisiblePlayButton': isVisiblePlayButton,
      'isVisiblePushupsOverTimeChart': isVisiblePushupsOverTimeChart,
      'isVisibleLeaderboard': isVisibleLeaderboard,
      'isVisibleInvitationPaid': isVisibleInvitationPaid,
    };
  }

}
