import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/competition_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/judge_request_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboard_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboards_all_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/player_records_model_KOH.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;
import 'package:dojo_app/services/helper_functions.dart' as helper;

class GameServiceKOH {
  // Initialize DB object with methods to call DB
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();

  /// Constructor
  GameServiceKOH() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Create Objects from Maps
  /// ***********************************************************************
  /// ***********************************************************************

// Takes a parameter of gameMap, which contains a replica of a match document
  GameModelKOH createGameObject(gameMap) {
    GameModelKOH _gameInfo = GameModelKOH(
      competitionID: (gameMap['competitionID'] != null) ? gameMap['competitionID'] : '0',
      gameMode: (gameMap['gameMode'] != null) ? gameMap['gameMode'] : '0',
      gameRulesID: (gameMap['gameRulesID'] != null) ? gameMap['gameRulesID'] : '0',
      id: (gameMap['id'] != null) ? gameMap['id'] : '0',
      gameStatus: (gameMap['gameStatus'] != null) ? gameMap['gameStatus'] : '0',
      duration: (gameMap['duration'] != null) ? gameMap['duration'] : 0,
      userID: (gameMap['userID'] != null) ? gameMap['userID'] : '0',
      playerNicknames: (gameMap['playerNicknames'] != null) ? gameMap['playerNicknames'] : {},
      playerScores: (gameMap['playerScores'] != null) ? gameMap['playerScores'] : {},
      playerVideos: (gameMap['playerVideos'] != null) ? gameMap['playerVideos'] : {},
      playerAvatars: (gameMap['playerAvatars'] != null) ? gameMap['playerAvatars'] : {},
      movement: (gameMap['movement'] != null) ? gameMap['movement'] : {},
      gameRules: (gameMap['gameRules'] != null) ? gameMap['gameRules'] : {},
      judging: (gameMap['judging'] != null) ? gameMap['judging'] : {},
      dates: (gameMap['dates'] != null) ? gameMap['dates'] : {},
      ipfsURL: (gameMap['ipfsURL'] != null) ? gameMap['ipfsURL'] : '0',
      paymentReceived: (gameMap['paymentReceived'] != null) ? gameMap['paymentReceived'] : false,
      ethereumAddressForPayment: (gameMap['ethereumAddressForPayment'] != null) ? gameMap['ethereumAddressForPayment'] : '0',
      dateCreated: (gameMap['dateCreated'] != null)
          ? ((gameMap['dateCreated'] is Timestamp) ? gameMap['dateCreated'].toDate() : gameMap['dateCreated'])
          : DateTime.now(),
      dateUpdated: (gameMap['dateUpdated'] != null)
          ? ((gameMap['dateUpdated'] is Timestamp) ? gameMap['dateUpdated'].toDate() : gameMap['dateUpdated'])
          : DateTime.now(),
      // (gameMap['dateUpdated'] != null) ? gameMap['dateUpdated'].toDate() : DateTime.now(),
      /*dateStart: (gameMap['dateStart'] != null)
          ? ((gameMap['dateStart'] is Timestamp) ? gameMap['dateStart'].toDate() : gameMap['dateStart'])
          : DateTime.now(),
      // (gameMap['dateStart'] != null) ? gameMap['dateStart'].toDate() : DateTime.now(),
      dateEnd: (gameMap['dateEnd'] != null)
          ? ((gameMap['dateEnd'] is Timestamp) ? gameMap['dateEnd'].toDate() : gameMap['dateEnd'])
          : DateTime.now(), // (gameMap['dateEnd'] != null) ? gameMap['dateEnd'].toDate() : DateTime.now(),*/
    );

    return _gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Create Game
  /// ***********************************************************************
  /// ***********************************************************************

  Future<GameModelKOH> createKingOfTheHillGame({userID, nickname, gameRulesID, competitionID}) async {
    // Get Game Rules Information
    Map<String, dynamic> _gameRules = await databaseServicesShared.gameRules(gameRulesID: gameRulesID);

    //Get Public Wallet Address
    final ethAddress = await getWalletAddress();


    // Set some parameters
    DateTime _rightNow = DateTime.now();
    String gameID = createUUID();
    String playerAvatar = 'images/avatar-blank.png';

    /// Create game info object
    GameModelKOH gameInfo = GameModelKOH(
      competitionID: competitionID,
      gameMode: _gameRules['gameMode'],
      gameRulesID: gameRulesID,
      id: gameID,
      gameStatus: constants.cGameStatusOpen,
      duration: 60,
      userID: userID,
      playerNicknames: {userID: nickname},
      playerScores: {},
      playerVideos: {},
      playerAvatars: {userID: playerAvatar},
      movement: {},
      gameRules: _gameRules,
      judging: {},
      dates: {'dateCreated': _rightNow},
      ipfsURL: '',
      paymentReceived: false,
      ethereumAddressForPayment: ethAddress,
      dateCreated: _rightNow,
      dateUpdated: _rightNow,
    );

    /// Save game to games collection
    await databaseServices.saveKingOfTheHillGame(gameInfo.toMap());

    /// return id so you can identify which game was created
    return gameInfo;
  }

  /// Checks whether a gameMap has data
  // if not, then this creates a new game doc for the competitionID and gameRules passed in
  Future<GameModelKOH> createGameWhenNotExisting({required String nickname, required String userID, required Map gameMap, required String competitionID, required String gameRulesID}) async {
    late GameModelKOH gameInfo;

    if (gameMap.isEmpty) {
      // create a game document for this competition
      gameInfo = await createKingOfTheHillGame(userID: userID, nickname: nickname, gameRulesID: gameRulesID, competitionID: competitionID);
    } else {
      // a game doc exists for this competitionID
      // so convert it into an object
      gameInfo = createGameObject(gameMap);
    }

    // return true or false whether competitions collection was updated
    return gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Competitions
  /// ***********************************************************************
  /// ***********************************************************************

  CompetitionModelKOH createCompetitionObject({required Map competitionMap}) {
    CompetitionModelKOH competitionObject = CompetitionModelKOH(
      competitionStatus: competitionMap['competitionStatus'],
      dateCreated: competitionMap['dateCreated'].toDate(),
      dateEnd: competitionMap['dateEnd'].toDate(),
      dateStart: competitionMap['dateStart'].toDate(),
      dateUpdated: competitionMap['dateUpdated'].toDate(),
      gameRulesID: competitionMap['gameRulesID'],
      id: competitionMap['id'],
    );

    return competitionObject;
  }

  CompetitionModelKOH createNewCompetitionObjectForToday({required String gameRulesID}) {
    // create a competition object with desired data
    String competitionID = createUUID();

    CompetitionModelKOH competitionInfo = CompetitionModelKOH(
      competitionStatus: constantsKOH.CompetitionStatus.open,
      dateStart: helper.previousMidnight(),
      dateEnd: helper.nextMidnight(),
      gameRulesID: gameRulesID,
      id: competitionID,
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
    );

    return competitionInfo;
  }

  /*Future<void> createCompetitionDocument({required String gameRulesID}) async {
    // create a competition object with desired data
    CompetitionModelKOH competitionObject = createNewCompetitionObjectForToday(gameRulesID: gameRulesID);

    /// add document to competitions collection
    await databaseServices.createCompetition(competitionInfo: competitionObject);
  }*/

  /*/// Handle these cases:
  /// - no competition exists at all... so create one
  /// - latest competition is not for today... so create one
  ///-  and returns true if the competition collection was updated
  Future<bool> createCompetitionWhenNotExisting({required QuerySnapshot competitionSnapshot, required String gameRulesID}) async {
    bool competitionSnapshotUpdated = false;

    if (competitionSnapshot.docs.isEmpty) {
      // create a competition with a dateStart of today
      // and return a competitionSnapshot with the added competition
      createCompetitionDocument(gameRulesID: gameRulesID);
      competitionSnapshotUpdated = true;
    } else if (competitionSnapshot.docs.isNotEmpty) {
      // does the latest match for today?
      Map competitionItem = competitionSnapshot.docs.first.data() as Map;
      DateTime dateStart = competitionItem['dateStart'].toDate();

      // if not, create it
      // and return a competitionSnapshot with all of the open/winner announce competitions
      if (dateStart != previousMidnight()) {
        await createCompetitionDocument(gameRulesID: gameRulesID);
        competitionSnapshotUpdated = true;
      }
    }

    // return true or false whether competitions collection was updated
    return competitionSnapshotUpdated;
  }*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Leaderboard
  /// ***********************************************************************
  /// ***********************************************************************

  LeaderboardModelKOH createLeaderboardObject({required GameModelKOH gameInfo}) {
    // Create game object with required data so we can update match documents
    LeaderboardModelKOH _leaderboardItem = LeaderboardModelKOH(
      id: createUUID(),
      competitionID: gameInfo.competitionID,
      gameRulesID: gameInfo.gameRules['id'],
      gameID: gameInfo.id,
      nickname: gameInfo.playerNicknames[gameInfo.userID],
      score: gameInfo.playerScores[gameInfo.userID],
      playerVideo: gameInfo.playerVideos[gameInfo.userID],
      userID: gameInfo.userID,
      dateAdded: DateTime.now(),
    );

    return _leaderboardItem;
  }

  Future<LeaderboardAndPlayerRankModelKOH> getLeaderboardAndPlayerRank({
    required String gameRulesID,
    required String competitionID,
    required String userID,
    required String gameStatus}) async {

    /// Contains all db calls from local and globally shared file
    DatabaseServicesKOH databaseService = DatabaseServicesKOH();

    /// Contains general services used by this game mode/rules type
    GameServiceKOH gameService = GameServiceKOH();

    /// get a list of all leaderboard records for a specific competition
    QuerySnapshot singleCompetitionLeaderboardRecords =
        await databaseService.getLeaderboardByGameRules(gameRulesID: gameRulesID, competitionID: competitionID);

    // singleCompetitionLeaderboardRecordsList is consumed by the leaderboard widget
    List singleCompetitionLeaderboardRecordsList =
        gameService.convertQuerySnapshotToListOfMaps(singleCompetitionLeaderboardRecords);

    /// Determine player rank
    int playerRank = 0; // if they haven't played or have not been judged yet, then their rank will be 0
    // only look at players who have submitted a video
    if (gameStatus == constantsKOH.GameStatus.judgingCompleted) {
      for (int i = 0; i < singleCompetitionLeaderboardRecordsList.length; i++) {
        if (singleCompetitionLeaderboardRecordsList[i]['userID'] == userID) {
          playerRank = i + 1;
          break;
        }
      }
    }

    /// Create leaderboards object, contains a competition's leaderboard and this player's rank of
    LeaderboardAndPlayerRankModelKOH leaderboardAndPlayerRank = LeaderboardAndPlayerRankModelKOH(
        leaderboardRecords: singleCompetitionLeaderboardRecordsList, rank: playerRank, playerUserID: userID);

    return leaderboardAndPlayerRank;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging
  /// ***********************************************************************
  /// ***********************************************************************

  JudgeRequestModelKOH createJudgeObject({required GameModelKOH gameInfo}) {
    // Create game object with required data so we can update match documents
    JudgeRequestModelKOH _judgeRequestItem = JudgeRequestModelKOH(
      id: createUUID(),
      gameID: gameInfo.id,
      competitionID: gameInfo.competitionID,
      gameRulesID: gameInfo.gameRules['id'],
      consensusScore: 0,
      status: constantsKOH.JudgeStatus.open,
      judgeCountThreshold: constants.GameRulesConstants.kohPushupMax60JudgeThreshold,
      // 1

      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),

      userID: gameInfo.userID,
      playerNickname: gameInfo.playerNicknames[gameInfo.userID],
      playerVideo: gameInfo.playerVideos[gameInfo.userID],

      gameRules: gameInfo.gameRules,
    );

    return _judgeRequestItem;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Get player personal records
  /// ***********************************************************************
  /// ***********************************************************************

  /// From matches doc, get the scores map and personal record
  // iterate through the map to build a LIST that will be used later by charts
  Future<PlayerRecordsModelKOH> getPlayerRecords(String gameRulesID, String userID) async {
    List scoresOverTime = [];
    int personalRecord = 0;

    /// Store player records document as a map
    Map playerRecordsData = await databaseServices.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesID);

    /// Store and sort all scores for this gameRulesID
    if (playerRecordsData['scores'] != null) {
      scoresOverTime = playerRecordsData['scores'];

      /// Sort List by date
      scoresOverTime.sort((a, b) {
        var aDate = a['dateTime'].toDate(); //before -> var adate = a.expiry;
        var bDate = b['dateTime'].toDate(); //var bDate = b.expiry;
        return -bDate.compareTo(aDate);
      });
    }

    /// Store personal record for total points
    if (playerRecordsData['personalRecord'] != null) {
      personalRecord = playerRecordsData['personalRecord'];
    }

    /// Remove all but the last 6 items in the scores list
    // so that we only display the most 6 recent items
    // so we don't overload the chart with too many data points
    if (scoresOverTime.length > 6) {
      int excessNumberOfItems = scoresOverTime.length - 6;
      scoresOverTime.removeRange(0, excessNumberOfItems);
    }

    /// Store scores, personal record, and win loss record in map
    PlayerRecordsModelKOH playerRecords = PlayerRecordsModelKOH(
        gameRulesID: (playerRecordsData['gameRulesID'] != null) ? playerRecordsData['gameRulesID'] : '0',
        personalRecord: personalRecord,
        scoresArray: (playerRecordsData['scoresArray'] != null) ? playerRecordsData['scoresArray'] : [],
        scores: (playerRecordsData['scores'] != null) ? playerRecordsData['scores'] : [],
        scoresOverTime: scoresOverTime,
        userID: userID);

    return playerRecords;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Cloud functions for game
  /// ***********************************************************************
  /// ***********************************************************************

  //Calls cloud function which generates unique eth address to accept invite.
  Future <String> getWalletAddress() async {

    final httpCall = await FirebaseFunctions.instance.httpsCallable('createWallet').call();
    final walletAddress = httpCall.data;
    return walletAddress;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc
  /// ***********************************************************************
  /// ***********************************************************************

  List convertQuerySnapshotToListOfMaps(QuerySnapshot snapshot) {
    List snapshotList = [];

    snapshot.docs.forEach((value) {
      var dataAsMap = value.data() as Map<String, dynamic>;
      snapshotList.add(dataAsMap);
    });

    return snapshotList;
  }

  /// cycle through snapshots
  /// and from each one, create an object, that is added to a list
  List convertQuerySnapshotToListOfObjects(QuerySnapshot snapshot, String objectType) {
    List objectList = [];
    var test = snapshot.docs.first.data() as Map;
    Timestamp firebaseTimeStamp = test['dateStart'];
    Timestamp codeTimeStamp = Timestamp.now();

    snapshot.docs.forEach((value) {
      var dataAsMap = value.data() as Map<String, dynamic>; // save as a map
      if (objectType == 'competition') {
        CompetitionModelKOH object = createCompetitionObject(competitionMap: dataAsMap);
        objectList.add(object);
      }
    });

    return objectList;
  }
}
