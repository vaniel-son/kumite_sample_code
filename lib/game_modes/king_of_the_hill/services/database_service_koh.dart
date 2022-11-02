import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/competition_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/judge_request_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboard_model_koh.dart';
import 'package:dojo_app/game_modes/matches/services/game_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;

class DatabaseServicesKOH {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Game Rules, Competition Info
  /// ***********************************************************************
  /// ***********************************************************************

  Future<Map> competitionInformation({required String competitionID}) async {
    final competitionQuery = await FirebaseFirestore.instance
        .collection('competitions')
        .where('id', isEqualTo: competitionID)
        .get();

    Map<dynamic, dynamic> result;
    if (competitionQuery.docs.isNotEmpty) {
      result = competitionQuery.docs.first.data();
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

  /// Get MAP: details for a single match
  Future<Map> fetchGameByID({required String id}) async {
    final gameQuery = await FirebaseFirestore.instance
        .collection('games')
        .where('id', isEqualTo: id)
        .get();

    Map<dynamic, dynamic> result;
    if (gameQuery.docs.isNotEmpty) {
      result = gameQuery.docs.first.data();
    } else {
      result = {};
    }
    return result;
  }

  /// Get MAP: details for a single match
  Future<Map> fetchGameByCompetitionID({required String userID, required String competitionID}) async {
    final gameQuery = await FirebaseFirestore.instance
        .collection('games')
        .where('userID', isEqualTo: userID)
        .where('competitionID', isEqualTo: competitionID)
        .get();

    Map<dynamic, dynamic> result;
    if (gameQuery.docs.isNotEmpty) {
      result = gameQuery.docs.first.data();
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
  Future<void> saveKingOfTheHillGame(gameInfo) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Update match document
  // uses GameModel2 which is a replica of the match document model
  // uses GameModel2Extras which contains extra data that is useful for matches
  Future<void> updateEntireGame(GameModelKOH gameInfo) async {
    // Extract required data
    String id = gameInfo.id;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores;
    Map playerVideos = gameInfo.playerVideos;
    Map judging = gameInfo.judging;
    Map dates = gameInfo.dates;

    /// Obtain reference for match document that will be updated
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('games')
        .doc(id);

    updateGame.update({
      "playerScores": playerScores,
      "playerVideos": playerVideos,
      "dateUpdated": DateTime.now(),
      "gameStatus": gameStatus,
      "judging": judging,
      "dates": dates,
    }); // end
  }

  /// Update game doc when player has paid to gain access to the main event
  Future<void> paymentReceived({required Map<String, dynamic> gameInfo}) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameInfo['id'])
        .set(gameInfo);

    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('games')
        .doc(gameInfo['id']);

    updateGame.update({
      "paymentReceived": true,
      "dateUpdated": DateTime.now(),
    }); // end
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Leaderboard
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create match for Marvin and Van
  Future<void> addUserToLeaderboard({required LeaderboardModelKOH leaderboardItem}) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(leaderboardItem.competitionID)
        .collection('leaderboard')
        .doc(leaderboardItem.id)
        .set(leaderboardItem.toMap());
  }

  Future<QuerySnapshot<Object?>> getLeaderboardByGameRules({required String gameRulesID, required String competitionID}) async {
    final leaderboardStream = FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionID)
        .collection('leaderboard')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .orderBy('score', descending: true)
        .get();

    var result;
    result = leaderboardStream;

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create doc signaling a 3rd party judge is requested
  Future<void> addJudgeRequest({required JudgeRequestModelKOH judgeRequestItem}) async {
    // save data to firebase
    await FirebaseFirestore.instance
        .collection('judging')
        .doc(judgeRequestItem.id)
        .set(judgeRequestItem.toMap());
  }

  /// Games that a user has NOT judged, and is open
  Stream<QuerySnapshot> fetchOpenGamesForJudging({required String competitionID}) {
    final Stream<QuerySnapshot> gamesForJudging = FirebaseFirestore.instance
        .collection('judging')
        .where('competitionID', isEqualTo: competitionID)
        .where('status', isEqualTo: constantsKOH.JudgeStatus.open)
        .orderBy('dateCreated', descending: true)
        .snapshots();

    var result;
    result = gamesForJudging;
    return result;
  }

  /// Games that a user has NOT judged, and is open
  Stream<QuerySnapshot> fetchClosedGamesForJudging({required String competitionID}) {
    final Stream<QuerySnapshot> gamesForJudging = FirebaseFirestore.instance
        .collection('judging')
        .where('competitionID', isEqualTo: competitionID)
        .where('status', isEqualTo: constantsKOH.JudgeStatus.judgingCompleted)
        .orderBy('dateCreated', descending: true)
        .snapshots();

    var result;
    result = gamesForJudging;
    return result;
  }

  Future<Map> getSingleJudgeDocument({required String id}) async {
    Map result = {};

    final judgeRecordsQuery = await FirebaseFirestore.instance
        .collection('judging')
        .where('id', isEqualTo: id)
        .get();

    if (judgeRecordsQuery.docs.isNotEmpty) {
      result = judgeRecordsQuery.docs.first.data();
    }

    return result;
  }

  Stream<QuerySnapshot> fetchMatchesForJudgingStream(String userID) {
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging')
    //.where('userAccess', arrayContains: userID)
        .where('status', isEqualTo: constantsKOH.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: saving
  /// ***********************************************************************
  /// ***********************************************************************

  void updateJudgingWithConsensus({required int consensusScore, required String id}) async {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging')
        .doc(id);

    updateMatchForThisUser.update({
      "consensusScore": consensusScore,
      'status': constantsKOH.JudgeStatus.judgingCompleted,
    }); // end
  }

  void updateJudgingWithScore({required Map judgeScores, required List judges, required String id}) async {
    /// Fetch judge doc

    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging')
        .doc(id);

    updateMatchForThisUser.update({
      "judgeScores": judgeScores,
      'judges': judges,
    }); // end
  }

  void closeJudgingRequest(String id, String userID, String nickname) {
    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('judging')
        .doc(id);

    // Save signature of judge closing the request
    Map judgeSignature = {
      'userID': userID,
      'nickname': nickname,
    };

    updateMatchForThisUser.update({
      "status": constantsKOH.cJudgeMatchStatusClosed,
      'judgeSignature': judgeSignature,
    }); // end
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Competitions
  /// ***********************************************************************
  /// ***********************************************************************

  /// List of open competitions
  // TODO: pass in gameRulesID, to handle cases when we have more game types
  Future<Map> fetchOldestActiveCompetition() async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('competitions')
        //.where('competitionStatus', isEqualTo: constantsKOH.CompetitionStatus.open)
        .where('competitionStatus', whereIn: [constantsKOH.CompetitionStatus.open,constantsKOH.CompetitionStatus.pendingJudgment])
        .orderBy('dateStart', descending: false)
        .get();

    // value to be returned
    Map<String, dynamic> competitionDocument;

    if (matchDetailQuery.docs.isNotEmpty) {
      competitionDocument = matchDetailQuery.docs.first.data();
    } else {
      competitionDocument = {};
    }

    return competitionDocument;
  }

  /// Get snapshot of competitions and their details
  /// - ordered by dateStart desc
  /// - with competitionStatus of open, winnerAnnounced
  Future<QuerySnapshot> getCompetitions(gameRulesID) {
    final dataStream = FirebaseFirestore.instance
        .collection('competitions')
        .where('competitionStatus', whereIn: [constantsKOH.CompetitionStatus.open, constantsKOH.CompetitionStatus.winnerAnnounced, constantsKOH.CompetitionStatus.announced, constantsKOH.CompetitionStatus.pendingJudgment])
        .where('gameRulesID', isEqualTo: gameRulesID)
        .orderBy('dateStart', descending: true)
        //.where('status', isEqualTo: constantsKOH.CompetitionStatus.open)
        .get();

    var result;
    result = dataStream;
    return result;
  }

  /// Get a list of all competitions
  // store each competition in a competition model object
  // then add to a list and return that list

  /// ***********************************************************************
  /// ***********************************************************************
  /// Competitions: Creating / Updating
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create match for Marvin and Van
  Future<void> createCompetition({required CompetitionModelKOH competitionInfo}) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionInfo.id)
        .set(competitionInfo.toMap());
  }

  closeCompetition({required String competitionID}) {
    /// Update for this user
    DocumentReference updateCompetitionStatus = FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionID);

    updateCompetitionStatus.update({
      "competitionStatus": constantsKOH.CompetitionStatus.winnerAnnounced,
      'dateUpdated': DateTime.now(),
    }); // end
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain scores for 60 second match
  Future<Map> fetchPlayerRecordsByGameRules({userID, gameRulesID}) async {
    Map result = {};

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

  /// Saves their scores to player records collection
  void savePlayerRecordsScore({required GameModelKOH gameInfo}) async {
    // Extract required data from gameInfo
    String playerOneUserID = gameInfo.userID;
    int score = gameInfo.playerScores[playerOneUserID];
    String gameID = gameInfo.id;
    Map movementInfo = gameInfo.movement;
    String gameRulesID = gameInfo.gameRules['id'];
    Map gameRulesInfo = gameInfo.gameRules;

    List scoreMapToSave = [];
    List scoresArrayToSave = [];
    List repsArrayToSave = [];
    int personalRecord;

    /// Create map containing an individual games score
    Map scoreMap = {
      'gameID': gameID,
      'dateTime': DateTime.now(),
      'score': score,
    };

    /// obtain player record collection and locate the specific document
    final userPlayerRecordQuery = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(playerOneUserID)
        .collection('byGameRules')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .get();

    /// reference for updating this document
    // what if it doesn't exist yet? what happens? how do I make one?
    DocumentReference updatePlayerRecordsReference = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(playerOneUserID)
        .collection('byGameRules')
        .doc(gameRulesID);

    /// if nothing returned, then record doesn't exist yet. So create it
    if (userPlayerRecordQuery.docs.isEmpty) {
      scoreMapToSave.add(scoreMap);
      scoresArrayToSave = [score];
      personalRecord = score;

      // create document with one score so far
      await updatePlayerRecordsReference.set({
        "movement": movementInfo,
        "gameRulesID": gameRulesID,
        "gameRules": gameRulesInfo,
        "scores": scoreMapToSave,
        "scoresArray": scoresArrayToSave,
        "personalRecord": personalRecord,
        "repsArray": repsArrayToSave,
      });
    } else {
      /// Get the existing data so we can append to it
      // there should only be one result so set result to this document
      var result = userPlayerRecordQuery.docs.first.data();

      // obtain existing scores so we can add to it later
      if (result['scores'] != null) {
        scoreMapToSave = result['scores'];
      }

      // obtain existing scoresArray so we can add to it later
      if (result['scoresArray'] != null) {
        scoresArrayToSave = result['scoresArray'];
      }

      // obtain existing repsArray so we can add to it later
      if (result['repsArray'] != null) {
        repsArrayToSave = result['repsArray'];
      }

      // obtain existing personal record for TOTAL POINTS
      if (result['personalRecord'] != null) {
        personalRecord = result['personalRecord'];

        // set new personal record
        if (GameService.isThisANewPersonalRecord(newScore: score, existingScore: personalRecord)) {
          personalRecord = score;
        }
      } else {
        // no personal record exists yet, so set one
        personalRecord = score;
      }

      // append our score data to this existing map of data
      scoreMapToSave.add(scoreMap);
      scoresArrayToSave.add(score);

      // update document
      await updatePlayerRecordsReference.update({
        "scores": scoreMapToSave,
        "scoresArray": scoresArrayToSave,
        "repsArray": repsArrayToSave,
        "personalRecord": personalRecord,
      });
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// TBD
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// TBD
  /// ***********************************************************************
  /// ***********************************************************************


} // end database service class