import 'package:dojo_app/game_modes/training_emom/models/emom_hud_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';

class GameServicePEMOM {

  /// Constructor
  GameServicePEMOM() {
    //
  }

  /// Returns true/false booleans for which widgets to show on the EMOM HUD
  EmomHUDWidgetVisibilityModel determineEMOMHUDWidgetVisibility(constantsPEMOM.GameStage stage) {
    late EmomHUDWidgetVisibilityModel emomHudVisibility;

    if (stage == constantsPEMOM.GameStage.Start) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: false,
        isRoundStatusVisible: false,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.HowToPlay) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: false,
        isRoundStatusVisible: false,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.PositionYourPhone) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: false,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
        isBackUpMessageVisible: true,
      );
    } else if (stage == constantsPEMOM.GameStage.GetInFrame) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: false,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
        isBackUpMessageVisible: true,
      );
    } else if (stage == constantsPEMOM.GameStage.ShowForm) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: true,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.CountdownStarting) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: true,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.Countdown) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: true,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.Play) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: true,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.TimerExpires) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: true,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.Saving) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: true,
        isCurrentRepCounterVisible: true,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.ShowAllResults) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: true,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.Rewards) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: true,
        isYourNewGoalVisible: false,
      );
    } else if (stage == constantsPEMOM.GameStage.Level) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: true,
      );
    } else if (stage == constantsPEMOM.GameStage.NextSteps) {
      emomHudVisibility = EmomHUDWidgetVisibilityModel(
        isEMOMHudVisible: true,
        isRoundStatusVisible: true,
        isStaticWorkoutTimerVisible: false,
        isDynamicWorkoutTimerVisible: false,
        isCurrentRepCounterVisible: false,
        isYourResultsVisible: false,
        isYourRewardsVisible: false,
        isYourNewGoalVisible: true,
      );
    } else {
      emomHudVisibility = EmomHUDWidgetVisibilityModel();
    }

    return emomHudVisibility;
  }

  /// Determines the round status (current, pending, success, failure) for each round
  List determineRoundStatus({required roundStatusControllerSink, required int currentEMOMRound, required int maxEMOMRounds, required GameModelPEMOM lgGameInfo, required String playerOneUserID}) {
    List roundStatus = [];

    /// Calculate status off each round
    // round status options: pending, current, success, failure
    // go through every single one, every time, and calculate the status of all rounds
    for (int roundToCheck = 1; roundToCheck <= maxEMOMRounds; roundToCheck++) {
      // round 0: 1 > 0, 2 > 0, 3 > 0 ... these are use cases to test this logic
      // round 1: 1 > 1, 2 > 1, 3 > 1 ... each row is a full run though of this for loop
      // round 2: 1 > 2, 2 > 2, 3 > 2
      // round 3: 1 > 3, 2 > 3, 3 > 3
      // round 4: 1 > 4, 2 > 4, 3 > 4 (post round 3, but there is no round 4 actually. Why: do this so we can check the previous round

      // is this round pending?
      if (roundToCheck > currentEMOMRound) {
        lgGameInfo.playerGameRoundStatus[roundToCheck - 1] = constantsPEMOM.PlayerGameRoundStatus.pending;
      }

      // is this round current?
      if (roundToCheck == currentEMOMRound) {
        lgGameInfo.playerGameRoundStatus[roundToCheck - 1] = constantsPEMOM.PlayerGameRoundStatus.current;
      }

      // is this round a success?
      if (roundToCheck == currentEMOMRound) {
        if (lgGameInfo.playerScores[playerOneUserID][roundToCheck - 1] >= lgGameInfo.playerGoals[playerOneUserID][roundToCheck - 1]) {
          lgGameInfo.playerGameRoundStatus[roundToCheck - 1] = constantsPEMOM.PlayerGameRoundStatus.success;
        }
      }

      // is the previous round a failure?
      if (roundToCheck < currentEMOMRound) {
        if (lgGameInfo.playerScores[playerOneUserID][roundToCheck - 1] < lgGameInfo.playerGoals[playerOneUserID][roundToCheck - 1]) {
          lgGameInfo.playerGameRoundStatus[roundToCheck - 1] = constantsPEMOM.PlayerGameRoundStatus.failure;
        }
      }

      /// Push this data to the game screen
      // roundStatusControllerSink.add(lgGameInfo.playerGameRoundStatus);
    }
    roundStatus = lgGameInfo.playerGameRoundStatus;
    return roundStatus;
  }

  /// Provide feedback score to the user on their performance
  double determinePlayerFeedbackScore(GameModelPEMOM lgGameInfo) {
    double feedbackScore = 0;
    int totalPushupsCompleted = sumPushupsInAllRounds(countOfItemsInList: lgGameInfo.playerScores[lgGameInfo.userID].length, pushupsPerRound: lgGameInfo.playerScores[lgGameInfo.userID]);
    int totalPushupsGoal = sumPushupsInAllRounds(countOfItemsInList: lgGameInfo.playerScores[lgGameInfo.userID].length, pushupsPerRound: lgGameInfo.playerGoals[lgGameInfo.userID]);
    feedbackScore = ((totalPushupsCompleted / totalPushupsGoal) * 100).roundToDouble();
    return feedbackScore;
  }

  int sumPushupsInAllRounds({required int countOfItemsInList, required List pushupsPerRound}){
    int totalPushupsInAllRound = 0;
    for (int i = 0; i < countOfItemsInList; i++) {
      totalPushupsInAllRound = (totalPushupsInAllRound + pushupsPerRound[i]) as int;
    }

    return totalPushupsInAllRound;
  }

  /// Determine overall training game outcome (success or failure)
  String determineTrainingGameOutcome(double gameScore) {
    String playerGameOutcome = constantsPEMOM.PlayerTrainingOutcome.failure; // set default value

    if (gameScore == 100.0) {
      playerGameOutcome = constantsPEMOM.PlayerTrainingOutcome.success;
    } else {
      playerGameOutcome = constantsPEMOM.PlayerTrainingOutcome.failure;
    }

    return playerGameOutcome;
  }

  /// Determine count of rewards to give player
  // Reward amount is currently based on average pushups completed per round
  int determineEndOfGameRewards(GameModelPEMOM lgGameInfo) {
    // how many pho bowls do they deserve?
    int rewards = 0;

    // calculate total number of pushups completed
    int totalPushupRepCount = 0;
    for (int i = 0; i < lgGameInfo.playerScores[lgGameInfo.userID].length; i++) {
      totalPushupRepCount = (totalPushupRepCount + lgGameInfo.playerScores[lgGameInfo.userID][i]) as int;
    }

    // determine average number of pushups completed per minute
    double pushupCountAverage;
    if (totalPushupRepCount > 0) {
      pushupCountAverage = (totalPushupRepCount / lgGameInfo.playerScores[lgGameInfo.userID].length);
    } else {
      pushupCountAverage = 0;
    }

    // calculate rewards
    if (pushupCountAverage >= 40.0) {
      rewards = 5;
    } else if (pushupCountAverage >= 30.0) {
      rewards = 4;
    } else if (pushupCountAverage >= 20) {
      rewards = 3;
    } else if (pushupCountAverage >= 10) {
      rewards = 2;
    } else {
      rewards = 1;
    }

    return rewards;
  }

  /// Determine the number of pushups to complete each  minute, next time they train
  int determinePushupCountLevelUp(GameModelPEMOM gameInfo) {

    // fetch average score completed
    int totalPushupsCompleted = sumPushupsInAllRounds(countOfItemsInList: gameInfo.playerScores[gameInfo.userID].length, pushupsPerRound: gameInfo.playerScores[gameInfo.userID]);
    double averagePushupsCompleted = (totalPushupsCompleted / gameInfo.playerScores[gameInfo.userID].length);
    int averagePushupsCompletedRounded = averagePushupsCompleted.round();

    // increment the average score
    int newPushupCountPerRound = averagePushupsCompletedRounded + 1;

    return newPushupCountPerRound;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// TBD
  /// ***********************************************************************
  /// ***********************************************************************

}
