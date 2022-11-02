import 'package:dojo_app/game_modes/training_emom/screens/max_rep_form/max_rep_results_screen.dart';
import 'package:dojo_app/game_modes/training_emom/services/database_service_pemom.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MaxRepBloc {

  MaxRepBloc();
  DatabaseServicesPEMOM dataServicePEMOM = DatabaseServicesPEMOM();

  /// Calculates the training reps.
  int calculateRepsForTraining(String reps) {

    //Convert Reps to integer
    int repsInt = int.parse(reps);

    //Calculate training reps target
    int actualEmomReps = (repsInt*.33).round() + 2;

    printBig('actual emom reps', '$actualEmomReps');

    return actualEmomReps;
  }

  /// Saves the rep data and navigates to the game screen.
  Future <void> saveRepDataAndNavigate(String userID, String gameRulesID, int repsInt, int actualEmomReps, BuildContext context ) async {
    await dataServicePEMOM.updatePlayerRecordPushups(userID: userID,gameRulesID: gameRulesID,maxPushupCount: repsInt, pushupCountPerMinute: actualEmomReps);

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            child: MaxRepsResultScreen(
                pushupGoalPerMinute: actualEmomReps,
                userID: userID,
                gameRulesID: gameRulesID)));
  }
}