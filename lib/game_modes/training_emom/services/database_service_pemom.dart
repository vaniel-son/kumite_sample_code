import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';
import 'package:dojo_app/services/general_service.dart';

class DatabaseServicesPEMOM {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Game Rules, Competition Info
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get SNAPSHOT: details for a single match
  Future<Map<String, dynamic>> fetchGameRules({required String gameRulesID}) async {
    final gameRulesQuery = await FirebaseFirestore.instance
        .collection('gameRules')
        .where('id', isEqualTo: gameRulesID)
        .get();

    Map<String, dynamic> result;
    if (gameRulesQuery.docs.isNotEmpty) {
      result = gameRulesQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Get Game Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get snapshot of competitions and their details
  /// - ordered by dateStart desc
  /// - with competitionStatus of open, winnerAnnounced
  Future<QuerySnapshot> getTrainingGames(String gameRulesID, String userID) async {
    final dataStream = await FirebaseFirestore.instance
        .collection('games')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .where('userID', isEqualTo: userID)
        .orderBy('dateStart', descending: true)
        .limit(4)
        .get();

    var result;
    result = dataStream;
    return result;
  }

  /// Get a game for today
  Future<Map<String, dynamic>> getTodaysTrainingGame(String gameRulesID, String userID) async {
    final dataStream = await FirebaseFirestore.instance
        .collection('games')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .where('userID', isEqualTo: userID)
        .orderBy('dateStart', descending: true)
        .limit(1)
        .get();

    Map<String, dynamic> result;
    if (dataStream.docs.isNotEmpty) {
      result = dataStream.docs.first.data();
      if (result['dateStart'].toDate().difference(GeneralService.previousMidnight()).inDays == 0) { // is the game for today?
        result = dataStream.docs.first.data();
      } else {
        result = {};
      }
    } else {
      result = {};
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Save or Update Game Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create match for Marvin and Van
  Future<void> savePushupEMOMGame({required Map<String, dynamic> gameInfo}) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Update game document after a game has finished
  Future<void> updateEntireGame(GameModelPEMOM gameInfo) async {
    /// Obtain reference for match document that will be updated
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('games')
        .doc(gameInfo.id);

    gameInfo.dateUpdated = DateTime.now();
    updateGame.update(gameInfo.toMap());
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain scores for 60 second match
  Future<Map<String, dynamic>> fetchPlayerRecordsByGameRules({userID, gameRulesID}) async {
    Map<String, dynamic> result = {};

    final playerRecordsQuery = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .get();

    if (playerRecordsQuery.docs.isNotEmpty) {
      result = playerRecordsQuery.docs.first.data();
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  Future<Map<String, dynamic>> createPlayerRecords({required String userID, required String gameRulesID, required int maxPushupsIn60Seconds, required int pushupsPerRound}) async {
    // reference for updating this document
    DocumentReference updatePlayerRecordsReference = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);

    // fetch game rules info
    Map<String, dynamic> _gameRules = await fetchGameRules(gameRulesID: gameRulesID);

    // create map of data to save
    Map<String, dynamic> playerRecords = {
      "gameRulesID": gameRulesID,
      "gameRules": _gameRules,
      "emomRepGoalsEachMinute": pushupsPerRound, // default value
      "maxPushupsIn60Seconds": maxPushupsIn60Seconds, // default value
      "userID": userID,
    };

    // create document with default values
    await updatePlayerRecordsReference.set(playerRecords);

    return playerRecords;
  }

  /// Update player Records with new reps per minute goal and game history
  Future<void> updatePlayerRecordsAfterAGame(GameModelPEMOM gameInfo, newPushupGoalPerMinute) async {
    // Extract required data
    String userID = gameInfo.userID;
    String gameRulesID = gameInfo.gameRulesID;
    Map gameToAdd = { // save this game's data to player's records for historical reporting
      'date': DateTime.now(),
      'playerGoals': gameInfo.playerGoals[gameInfo.userID],
      'playerScores': gameInfo.playerScores[gameInfo.userID],
      'playerGameOutcome': gameInfo.playerGameOutcome,
      'playerGameRoundStatus': gameInfo.playerGameRoundStatus,
      'gameScore': gameInfo.gameScore,
    };

    // get the player's records before the modification
    Map<String, dynamic> currentPlayerRecords = gameInfo.playerRecords;

    // remove the max reps score from the map (value is probably 0, so we don't want so save this as 0)
    currentPlayerRecords.remove('maxPushupsIn60Seconds');

    // update the records locally
    currentPlayerRecords['emomRepGoalsEachMinute'] = newPushupGoalPerMinute;
    currentPlayerRecords['dateUpdated'] = DateTime.now();

    // add to game history
    if (currentPlayerRecords['games'] == null) {
      currentPlayerRecords['games'] = {}; // games map field does not exist, so create it
    }
    currentPlayerRecords['games'][gameInfo.id] = gameToAdd;

    // update records on DB
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);
    updateGame.update(currentPlayerRecords);
  }

  /// Update player Records with new reps per minute and max pushup count
  Future<void> updatePlayerRecordPushups({required String userID,required String gameRulesID, required int maxPushupCount, required int pushupCountPerMinute}) async {
    // update records on DB
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);

    updateGame.update({
      'emomRepGoalsEachMinute': pushupCountPerMinute,
      'maxPushupsIn60Seconds': maxPushupCount,
    }); // end
  }

  /// Update player Records with new reps per minute goal and game history
  Future<void> updatePlayerRecordsAfterEMOMGame(GameModelPEMOM gameInfo, newPushupGoalPerMinute) async {
    // Extract required data
    String userID = gameInfo.userID;
    String gameRulesID = gameInfo.gameRulesID;
    Map gameToAdd = {
      'date': DateTime.now(),
      'playerGoals': gameInfo.playerGoals[gameInfo.userID],
      'playerScores': gameInfo.playerScores[gameInfo.userID],
      'playerGameOutcome': gameInfo.playerGameOutcome,
      'playerGameRoundStatus': gameInfo.playerGameRoundStatus,
      'gameScore': gameInfo.gameScore,
    };

    // get the player's records before the modification
    Map<String, dynamic> currentPlayerRecords = gameInfo.playerRecords;

    // update the records locally
    currentPlayerRecords['emomRepGoalsEachMinute'] = newPushupGoalPerMinute;
    currentPlayerRecords['dateUpdated'] = DateTime.now();

    // add to game history
    if (currentPlayerRecords['games'] == null) {
      currentPlayerRecords['games'] = {}; // games map field does not exist, so create it
    }
    currentPlayerRecords['games'][gameInfo.id] = gameToAdd;

    // update records on DB
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);

    updateGame.update(currentPlayerRecords); // end
  }

  /// Increment or deduct phoBowls
  // old, remove this
  Future<void> updateResourceInventory(GameModelPEMOM gameInfo) async {
    // Extract required data
    String userID = gameInfo.userID;
    int rewardsEarned = gameInfo.rewards;

    // update records on DB
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('inventory')
        .doc('resources');

    updateGame.update({"phoBowls": FieldValue.increment(rewardsEarned)});
  }

} // end database service class