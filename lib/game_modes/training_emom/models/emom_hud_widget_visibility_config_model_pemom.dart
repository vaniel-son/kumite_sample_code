class EmomHUDWidgetVisibilityModel {
  EmomHUDWidgetVisibilityModel({
    this.isEMOMHudVisible = false,
    this.isRoundStatusVisible = false,
    this.isStaticWorkoutTimerVisible = false,
    this.isDynamicWorkoutTimerVisible = false,
    this.isCurrentRepCounterVisible = false, // used to be set to true
    this.isYourResultsVisible = false,
    this.isYourRewardsVisible = true,
    this.isYourNewGoalVisible = false,
    this.isBackUpMessageVisible = false,
  });

  bool isEMOMHudVisible;
  bool isRoundStatusVisible;
  bool isStaticWorkoutTimerVisible;
  bool isDynamicWorkoutTimerVisible;
  bool isCurrentRepCounterVisible;
  bool isYourResultsVisible;
  bool isYourRewardsVisible;
  bool isYourNewGoalVisible;
  bool isBackUpMessageVisible;

  Map<String, dynamic> toMap(){
    return {
      'isEMOMHudVisible': isEMOMHudVisible,
      'isRoundStatusVisible': isRoundStatusVisible,
      'isStaticWorkoutTimerVisible': isStaticWorkoutTimerVisible,
      'isDynamicWorkoutTimerVisible': isDynamicWorkoutTimerVisible,
      'isCurrentRepCounterVisible': isCurrentRepCounterVisible,
      'isYourResultsVisible': isYourResultsVisible,
      'isYourRewardsVisible': isYourRewardsVisible,
      'isYourNewGoalVisible': isYourNewGoalVisible,
      'isBackUpMessageVisible': isBackUpMessageVisible,
    };
  }

}
