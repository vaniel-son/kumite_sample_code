class TrainingScreenWidgetVisibilityModel {
  TrainingScreenWidgetVisibilityModel({
    this.isVisibleHostCardOne = false,
    this.isVisibleEmomScoreBox = false,
    this.isVisiblePlayButton = false,
    this.isVisibleEarnInfoTip = true,
    this.isVisibleSifuEncouragement = false,
  });

  bool isVisibleHostCardOne;
  bool isVisibleEmomScoreBox;
  bool isVisiblePlayButton;
  bool isVisibleEarnInfoTip;
  bool isVisibleSifuEncouragement;

  Map<String, dynamic> toMap(){
    return {
    'isVisibleHostCardOne': isVisibleHostCardOne,
      'isVisibleEmomScoreBox': isVisibleEmomScoreBox,
      'isVisiblePlayButton': isVisiblePlayButton,
      'isVisibleEarnInfoTip': isVisibleEarnInfoTip,
      'isVisibleSifuEncouragement': isVisibleSifuEncouragement,
    };
  }

}
