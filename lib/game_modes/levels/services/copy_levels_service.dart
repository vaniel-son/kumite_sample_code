import 'dart:async';
import 'package:dojo_app/game_modes/levels/services/database_service_levels.dart';

class CopyLevelService {
  String levelGroupID;
  String userID;
  String nickname;
  DatabaseServicesLevels databaseService = DatabaseServicesLevels();

  /// Constructor
  CopyLevelService({required this.levelGroupID, required this.userID, required this.nickname}) {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// Populate user's level cards when user doesn't have any yet
  Future<void> addInitialLevelsWhenUserHasNone() async {
    // by default, new levels will not be added unless the below check is true
    bool addLevel = false;

    // check if new levels should be added to the user
    // returns true (add levels) or false (do not add levels)
    addLevel = await databaseService.hasLevelsForThisLevelGroupCheck(levelGroupID: levelGroupID, userID: userID);

    // if user doesn't have any levels for this challenge, then add them
    if (addLevel) {
      // copy levels from levelTemplates to current user's levels collection
      await databaseService.copyLevelsToUserAccount(levelGroupID: levelGroupID, userID: userID, nickname: nickname);
    } // end the if statement
  }
}