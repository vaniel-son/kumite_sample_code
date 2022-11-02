import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2_extras.dart';
import 'package:dojo_app/models/video_model.dart';
import 'package:dojo_app/game_modes/matches/services/game_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dojo_app/services/background_upload_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/matches/constants_matches.dart' as constantsMatches;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dojo_app/globals.dart' as globals;

class DatabaseServicesMatches {
  /// ***********************************************************************
  /// ***********************************************************************
  /// User
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain nickname based on userID
  Future<String> fetchNicknameWhenDefault({userID}) async {
    // We use two generic nicknames when the user does not have one
    // 1. globals.nickname starts with the nickname 'player', so anytime we encounter that, we know globals has never been updated
    // 2. after an account is initially created, we set nickname = Default
    // which during sign up uses to infer that the user has no nickname yet and should route the user to the nickname add screen
    if (globals.nickname != 'Default' || globals.nickname != 'Player') {
      final nicknameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('User_ID', isEqualTo: userID)
          .get();

      if (nicknameQuery.docs.isEmpty) {
        return 'Default';
      } else {
        var result = nicknameQuery.docs.first.data();
        return result['Nickname'];
      }
    }

    return globals.nickname;
  }

  /// Obtain user info based on userID
  Future<Map> fetchUserInfo({userID}) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('User_ID', isEqualTo: userID)
        .get();

    if (userQuery.docs.isEmpty) {
      return {};
    } else {
      var result = userQuery.docs.first.data();
      return result;
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Matches, Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get STREAM: details for a single match
  Stream<QuerySnapshot> fetchLatestStartingGamesStream(String gameMode, String matchGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .where('dateStart', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dateStart', descending: true)
        .snapshots();
  }

  /// Get SNAPSHOT: details for a single match
  Future<QuerySnapshot> fetchLatestStartingGameDetails(String gameMode, String matchGroupID, String userID) async {
    final matchDetailQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(matchGroupID)
        .collection(userID) // userID as collection name
        .where('dateStart', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dateStart', descending: true)
        .get();

    var result;
    result = matchDetailQuery;
    return result;
  }

  /// **********************************************************************

  /// Get SNAPSHOT: details for a single match
  Future<Map> gameRules({required String gameRulesID}) async {
    final gameRulesQuery = await FirebaseFirestore.instance
        .collection('gameRules')
        .where('id', isEqualTo: gameRulesID)
        .get();

    Map<dynamic, dynamic> result;
    if (gameRulesQuery.docs.isNotEmpty) {
      result = gameRulesQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Matches: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /*/// Create match for Marvin and Van
  Future<void> createMatchForMV(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameInfo['groupID'])
        .collection(gameInfo['userID'])
        .doc(gameInfo['id'])
        .set(gameInfo);
  }*/

  /// Create match for Marvin and Van
  Future<void> createMatchForMVFlat(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Create match for Marvin and Van
  Future<void> createGame(gameInfo) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('matchesAll2')
        .doc(gameInfo['id'])
        .set(gameInfo);
  }

  /// Update match document
  // uses GameModel2 which is a replica of the match document model
  // uses GameModel2Extras which contains extra data that is useful for matches
  void updateMatchesFlat(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) async {
    // Extract required data
    String id = gameInfo.id;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores;
    Map playerGameOutcomes = gameInfo.playerGameOutcomes;
    Map questions = gameInfo.questions;
    Map judging = gameInfo.judging;
    Map playerSubScores = gameInfo.playerSubScores;
    Map dates = gameInfo.dates;

    /// Obtain reference for match document that will be updated
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll2')
        .doc(id);

    updateMatch.update({
      "playerScores": playerScores,
      "playerGameOutcomes": playerGameOutcomes,
      "dateUpdated": DateTime.now(),
      "gameStatus": gameStatus,
      "questions": questions,
      "judging": judging,
      "playerSubScores": playerSubScores,
      "dates": dates,
    }); // end
  }

  /*/// Called as part of the process when a player forfeits
  Future<void> updateForfeitedMatch(Map matchDetails) async {
    /// Set reference for player 1 match doc (this player)
    DocumentReference updateMatchForPlayer0 = FirebaseFirestore.instance
        .collection(matchDetails['gameMode'])
        .doc(matchDetails['groupID'])
        .collection(matchDetails['players'][0])
        .doc(matchDetails['id']);

    /// Update for player 1 (this player)
    updateMatchForPlayer0.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });

    /// Set reference for player 2 match document (opponent)
    DocumentReference updateMatchForPlayer1 = FirebaseFirestore.instance
        .collection(matchDetails['gameMode'])
        .doc(matchDetails['groupID'])
        .collection(matchDetails['players'][1])
        .doc(matchDetails['id']);

    /// Update for player 2 (opponent)
    updateMatchForPlayer1.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });
  }*/

  /// Called as part of the process when a player forfeits
  Future<void> updateForfeitedMatchFlat(Map matchDetails) async {
    /// Set reference to match document
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(matchDetails['id']);

    /// Update match document
    updateMatch.update({
      "playerGameOutcomes": matchDetails['playerGameOutcomes'],
      "playerScores": matchDetails['playerScores'],
      "gameStatus": matchDetails['gameStatus'],
      "dateUpdated": DateTime.now(),
    });
  }

  /// ***********************************************************************
  /// Matches - Judging: Save Data
  /// ***********************************************************************

  /*void updateMatchWithJudgingStatus(Map matchInfo, String _judgingStatus, String _playerOneUserID, String _playerTwoUserID) async {
    // Extract required data
    String groupID = matchInfo['groupID'];
    String id = matchInfo['id'];
    String playerOneUserID = _playerOneUserID;
    String playerTwoUserID = _playerTwoUserID;
    Map judging = matchInfo['judging'];
    Map dates = matchInfo['dates'];

    /// Set updated secondary gameStatus
    judging['status'] = _judgingStatus;

    /// Set dateUpdated
    judging['dateUpdated'] = DateTime.now();

    /// Set when judging was specifically updated
    // discord bot uses this to determine what changed last about a match
    dates['judgingUpdated'] = DateTime.now();

    /// Update for this user
    DocumentReference updateMatchForThisUser = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerOneUserID)
        .doc(id);

    updateMatchForThisUser.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end

    /// Update for opponent
    DocumentReference updateMatchForOpponent = FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(playerTwoUserID)
        .doc(id);

    updateMatchForOpponent.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end
  }*/

  void updateMatchWithJudgingStatusFlat(Map matchInfo, String _judgingStatus, String _playerOneUserID, String _playerTwoUserID) async {
    // Extract required data
    String id = matchInfo['id'];
    Map judging = matchInfo['judging'];
    Map dates = matchInfo['dates'];

    /// Set updated secondary gameStatus
    judging['status'] = _judgingStatus;

    /// Set dateUpdated
    judging['dateUpdated'] = DateTime.now();

    /// Set when judging was specifically updated
    // discord bot uses this to determine what changed last about a match
    dates[constantsMatches.cJudgingUpdated] = DateTime.now();

    /// Update for this user
    DocumentReference updateMatch = FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(id);

    updateMatch.update({
      "judging": judging,
      "dateUpdated": DateTime.now(),
      "dates": dates,
    }); // end
  }

  /// ***********************************************************************
  /// Matches - Video, Food: Save Data
  /// ***********************************************************************

  /// Update match or level collection with player videos
  Future<void> updateMatchWithVideoURLFlat(gameMode, groupID, id, userID, videoOwnerUserID, videoURL) async {
    /// Fetch data
    final gameQuery = await FirebaseFirestore.instance
        .collection('matchesAll2')
        .where('id', isEqualTo: id)
        .get();

    if (gameQuery.docs.isNotEmpty) {
      var result = gameQuery.docs.first.data();
      Map playerVideoMap = result['playerVideos'];

      /// Update Map with this user's video
      playerVideoMap[videoOwnerUserID] = videoURL;

      /// Update userID's document
      DocumentReference updateMatch = FirebaseFirestore.instance
          .collection('matchesAll2')
          .doc(id);

      updateMatch.update({
        "playerVideos": playerVideoMap,
      }); // end
    }
  }

  Future<void> saveFoodImageURLtoMatch({required Map picMap, required String groupID, required String userID, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(userID)
        .doc(matchID)
        .update({
          'playerFoodPics':FieldValue.arrayUnion([picMap]),
          'dateUpdated': DateTime.now(),
          'dates': dates,
    });
  }

  Future<void> saveFoodImageURLtoMatchFlat({required Map picMap, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(matchID)
        .update({
      'playerFoodPics':FieldValue.arrayUnion([picMap]),
      'dateUpdated': DateTime.now(),
      'dates': dates,});
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get matches that have requested 3rd party judging and are still open
  Future<QuerySnapshot> fetchMatchesForJudging(String userID) async {
    final matchesForJudging = await FirebaseFirestore.instance
        .collection('judging')
    //.where('userAccess', arrayContains: userID)
        .where('status', isEqualTo: constantsMatches.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .get();

    var result;
    result = matchesForJudging;
    return result;
  }

  Stream<QuerySnapshot> fetchMatchesForJudgingStream(String userID) {
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging')
    //.where('userAccess', arrayContains: userID)
        .where('status', isEqualTo: constantsMatches.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// Games that a user has NOT judged, and is open
  Stream<QuerySnapshot> fetchMatchesForJudgingStream2(String userID) {
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging2')
        //.where('judgesUserID', arrayContains: userID)
        .where('status', isEqualTo: constantsMatches.cJudgeMatchStatusOpen)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// Games that a user has judged, and is closed
  Stream<QuerySnapshot> fetchMatchesForJudgingStream3(String userID) {
    final Stream<QuerySnapshot> matchesForJudging = FirebaseFirestore.instance
        .collection('judging2')
        .where('judges', arrayContains: userID)
        .where('status', isEqualTo: constantsMatches.cJudgeMatchStatusClosed)
    //.orderBy('dateUpdated', descending: false)
        .snapshots();

    var result;
    result = matchesForJudging;
    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create doc signaling a 3rd party judge is requested
  Future<void> create3rdPartyJudgeRequest(gameMap) async {
    // set data to be saved
    Map<String, dynamic> gameInfo = {};
    gameInfo['id'] = createUUID();
    gameInfo['dateCreated'] = DateTime.now();
    gameInfo['dateUpdated'] = DateTime.now();
    gameInfo['gameID'] = gameMap['id'];
    gameInfo['playerNicknames'] = gameMap['playerNicknames'];
    gameInfo['playerScores'] = gameMap['playerScores'];
    gameInfo['playerVideos'] = gameMap['playerVideos'];
    gameInfo['players'] =  gameMap['players'];
    gameInfo['status'] = 'open';
    gameInfo['userAccess'] = ['AI22rzMxuphgmK5Zr8lVGht3O3D3', 'eKv2KuKDJNNba7OUy1SNo3ilfiq2', 'RRmF9OaRW1Ue6kHtczyILqq9Fyc2', 'IaNoVdiaMtWiiyD7HFlRf5MqqSE3','6n5A87DnNMNdj0qOtjemKS5CYn43', 'OUbllyr5PzfsYzFlXxyrSvjF8hm1'];

    // save data to firebase
    await FirebaseFirestore.instance
        .collection('judging')
        .doc(gameInfo['id'])
        .set(gameInfo);
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
      "status": constantsMatches.cJudgeMatchStatusClosed,
      'judgeSignature': judgeSignature,
    }); // end
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Other
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain game mode details
  Future<Map> fetchGameModeDetails() async {
    final levelDetailsQuery = await FirebaseFirestore.instance
        .collection('gameModes')
        .where('gameMode', isEqualTo: 'matches')
        .get();

    var result = levelDetailsQuery.docs.first.data();
    return result;
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
  void savePlayerRecordsScore({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from gameInfo
    String playerOneUserID = gameInfoExtras.playerOneUserID;
    int score = gameInfo.playerScores[playerOneUserID];
    String gameID = gameInfo.id;
    String movementID = gameInfo.movement['id'];
    Map movementInfo = gameInfo.movement;
    String gameRulesID = gameInfo.gameRules['id'];
    Map gameRulesInfo = gameInfo.gameRules;
    int reps = gameInfo.playerSubScores[playerOneUserID]['reps'];

    List scoreMapToSave = [];
    List scoresArrayToSave = [];
    List repsArrayToSave = [];
    int personalRecord;
    int personalRecordReps;

    /// Create map containing an individual games score
    Map scoreMap = {
      'gameID': gameID,
      'dateTime': DateTime.now(),
      'score': score,
      'reps': reps,
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
      repsArrayToSave = [reps];

      // create document with one score so far
      await updatePlayerRecordsReference.set({
        "movementID": movementID,
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

      // obtain existing personal record for TOTAL REPS
      if (result['personalRecordReps'] != null) {
        personalRecordReps = result['personalRecordReps'];

        // set new personal record
        if (GameService.isThisANewPersonalRecord(newScore: reps, existingScore: personalRecordReps)) {
          personalRecordReps = reps;
        }
      } else {
        // no personal record exists yet, so set one
        personalRecordReps = reps;
      }

      // append our score data to this existing map of data
      scoreMapToSave.add(scoreMap);
      scoresArrayToSave.add(score);
      repsArrayToSave.add(reps);

      // update document
      await updatePlayerRecordsReference.update({
        "scores": scoreMapToSave,
        "scoresArray": scoresArrayToSave,
        "personalRecord": personalRecord,
        'personalRecordReps': personalRecordReps,
        "repsArray": repsArrayToSave,
      });
    }
  }

  void updateWinLossTieRecord(userID, gameRulesID, newWinLossTieRecord) async {
    /// reference for updating this document
    // what if it doesn't exist yet? SetOptions(merge: true) handles this case
    DocumentReference updatePlayerRecordsReference = FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .doc(gameRulesID);

    // update document
    await updatePlayerRecordsReference.set({
      "winLossTieRecord": newWinLossTieRecord,
    },
        SetOptions(merge:true));

    //set(data, SetOptions(merge: true))
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get videos
  Stream<QuerySnapshot> fetchVideosByID(String videoName) {
    return FirebaseFirestore.instance
        .collection('videos')
        .where('videoName', isEqualTo: videoName)
        .snapshots();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// After downloadURL is generated this method writes to that URL to the relevant document
  Future<void> saveVideoURLtoVideoCollection(String? videoName, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }

  Future<void> uploadVideo(videoName, videoFile) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        print('Document exists in the database');
        final data = ds.data();
        final uploadUrL = (data as dynamic)['uploadUrl'];
        print(uploadUrL);
        var video = VideoModel(uploadUrl: uploadUrL);
        uploadFileBackground(videoName, videoFile.path, video.uploadUrl);
      } else {
        print('Document does not exist');
      }
    });
  }

  Future<void> fetchVideoURLandUpdateMatches(gameMode, userID,) async {
    /// Fetch video collection documents for this user, or their opponent, who have their video background uploaded
    /// but not saved to both players' match or level document
    final query = await FirebaseFirestore.instance.collection('videos')
        .where('finishedProcessing',isEqualTo: false)
        .where('gameMode',isEqualTo: gameMode)
        .where('players', arrayContains: userID)
        .where('uploadComplete',isEqualTo: true).get();

    if (query.docs.isNotEmpty) {
      var doc = query.docs.first.data();

      String videoURL = await FirebaseStorage.instance.ref('user_videos/${doc['videoName']}.mp4').getDownloadURL();
      String gameMode = doc['gameMode'];
      String groupID = doc['groupID'];
      String gameID = doc['gameID'];
      String userID = doc['userID'];
      String videoName = doc['videoName'];

      /// For this user: Saves videoURL to matches collection
      //await updateLevelOrMatchWithVideoURL(gameMode, groupID, gameID, userID, userID, videoURL);
      await updateMatchWithVideoURLFlat(gameMode, groupID, gameID, userID, userID, videoURL);

      /// Saves the videoURL to videos collection and set finishedProcessing to true
      await saveVideoURLtoVideoCollection(videoName, videoURL);
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Firebase Storage
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> saveFoodPictureToStorage(String picLocation, File imageFile) async {
    await FirebaseStorage.instance.ref(picLocation).putFile(imageFile);
  }

  Future<String> fetchFoodPicture(String picLocation) async {
    return await FirebaseStorage.instance.ref(picLocation).getDownloadURL();
  }

  Future <void> updateMatchActivityTrackerField(Map gameMap) async{

    DateTime timeNow = DateTime.now();
    DateTime dateForMatchActivityMapUpdate = DateTime(timeNow.year,timeNow.month,timeNow.day);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    String dateForMatchActivityMapUpdateString = formatter.format(dateForMatchActivityMapUpdate);



    String userID = gameMap['userID'];
    String opponentID = gameMap['opponentPlayer']['userID'];

    ///Update current user match document
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameMap['groupID'])
        .collection(userID)
        .doc(gameMap['id'])
        .update({
      'matchActivityTracker.$userID.$dateForMatchActivityMapUpdateString.nutritionImagePosted': true
    });

    ///Update opponent user match document
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(gameMap['groupID'])
        .collection(opponentID)
        .doc(gameMap['id'])
        .update({
      'matchActivityTracker.$userID.$dateForMatchActivityMapUpdateString.nutritionImagePosted': true
    });

  }

} // end database service class
