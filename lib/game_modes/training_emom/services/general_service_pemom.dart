import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/database_service_pemom.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;

class GeneralServicePEMOM {
  // Initialize DB object with methods to call DB
  DatabaseServicesPEMOM databaseServices = DatabaseServicesPEMOM();

  /// Constructor
  GeneralServicePEMOM() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Create Objects from Maps
  /// ***********************************************************************
  /// ***********************************************************************

// Takes a parameter of gameMap, which contains a replica of a match document
  GameModelPEMOM createGameObjectFromMap(gameMap) {
    GameModelPEMOM _gameInfo = GameModelPEMOM(
      competitionID: (gameMap['competitionID'] != null) ? gameMap['competitionID'] : '0',
      gameMode: (gameMap['gameMode'] != null) ? gameMap['gameMode'] : '0',
      gameRulesID: (gameMap['gameRulesID'] != null) ? gameMap['gameRulesID'] : '0',
      id: (gameMap['id'] != null) ? gameMap['id'] : '0',
      gameStatus: (gameMap['gameStatus'] != null) ? gameMap['gameStatus'] : '0',
      duration: (gameMap['duration'] != null) ? gameMap['duration'] : 0,
      userID: (gameMap['userID'] != null) ? gameMap['userID'] : '0',
      playerNicknames: (gameMap['playerNicknames'] != null) ? gameMap['playerNicknames'] : {},
      playerScores: (gameMap['playerScores'] != null) ? gameMap['playerScores'] : {},
      playerGameRoundStatus: (gameMap['playerGameRoundStatus'] != null) ? gameMap['playerGameRoundStatus'] : [],
      playerGoals: (gameMap['playerGoals'] != null) ? gameMap['playerGoals'] : {},
      playerVideos: (gameMap['playerVideos'] != null) ? gameMap['playerVideos'] : {},
      playerGameOutcome: (gameMap['playerGameOutcome'] != null) ? gameMap['playerGameOutcome'] : constantsPEMOM.PlayerTrainingOutcome.pending,
      playerAvatars: (gameMap['playerAvatars'] != null) ? gameMap['playerAvatars'] : {},
      movement: (gameMap['movement'] != null) ? gameMap['movement'] : {},
      gameRules: (gameMap['gameRules'] != null) ? gameMap['gameRules'] : {},
      judging: (gameMap['judging'] != null) ? gameMap['judging'] : {},
      dates: (gameMap['dates'] != null) ? gameMap['dates'] : {},
      rewards: (gameMap['rewards'] != null) ? gameMap['rewards'] : 0,
      playerRecords: (gameMap['playerRecords'] != null) ? gameMap['playerRecords'] : {},
      ipfsURL: (gameMap['ipfsURL'] != null) ? gameMap['ipfsURL'] : '0',
      paymentReceived: (gameMap['paymentReceived'] != null) ? gameMap['paymentReceived'] : false,
      ethereumAddress: (gameMap['ethereumAddress'] != null) ? gameMap['ethereumAddress'] : '0',
      dateCreated: (gameMap['dateCreated'] != null)
          ? ((gameMap['dateCreated'] is Timestamp) ? gameMap['dateCreated'].toDate() : gameMap['dateCreated'])
          : DateTime.now(),
      dateUpdated: (gameMap['dateUpdated'] != null)
          ? ((gameMap['dateUpdated'] is Timestamp) ? gameMap['dateUpdated'].toDate() : gameMap['dateUpdated'])
          : DateTime.now(),
      // (gameMap['dateUpdated'] != null) ? gameMap['dateUpdated'].toDate() : DateTime.now(),
      dateStart: (gameMap['dateStart'] != null)
          ? ((gameMap['dateStart'] is Timestamp) ? gameMap['dateStart'].toDate() : gameMap['dateStart'])
          : DateTime.now(),
      dateEnd: (gameMap['dateEnd'] != null)
          ? ((gameMap['dateEnd'] is Timestamp) ? gameMap['dateEnd'].toDate() : gameMap['dateEnd'])
          : DateTime.now(),
    );

    return _gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Create Game
  /// ***********************************************************************
  /// ***********************************************************************

  /// Creates a new game object
  /// Then saves it to firebase
  /// Then returns the game object
  Future<GameModelPEMOM> createDefaultPushupEMOMGame({userID, nickname, gameRulesID}) async {
    // Get Game Rules Information
    Map<String, dynamic> _gameRules = await databaseServices.fetchGameRules(gameRulesID: gameRulesID);

    // Set some parameters
    DateTime _rightNow = DateTime.now();
    String gameID = createUUID();
    String playerAvatar = 'images/avatar-blank.png';

    // get player records with goals and max pushup rep count
    // - if the record doesn't exist, this will create a new playerRecord with default values
    Map<String, dynamic> playerRecords = await getTrainingEmomPlayerRecords2(userID: userID, gameRulesID: gameRulesID);
    if (playerRecords.isEmpty) {
      // create the record
      playerRecords = await createTrainingEmomPlayerRecords2(userID: userID, gameRulesID: gameRulesID, maxPushupsIn60Seconds: 0, pushupsPerRound: 1);
    }

    // set the pushup goal per round
    int emomRepGoal = playerRecords['emomRepGoalsEachMinute'];
    List emomRepGoalsEachMinute = [emomRepGoal,emomRepGoal,emomRepGoal];
    Map<String, dynamic> playerGoals = {userID: emomRepGoalsEachMinute};

    // Set player's default initial emom scores
    List emomRepScoresEachMinute = [0, 0, 0]; // while the user plays, this is updated and saved
    Map<String, dynamic> playerScores = {userID: emomRepScoresEachMinute};

    // Set default game round status, informs if they failed or succeeded each round: rep score per round >= rep goal per round
    // while the user plays, this is updated to success or fail
    List playerGameRoundStatus = [constantsPEMOM.PlayerGameRoundStatus.pending, constantsPEMOM.PlayerGameRoundStatus.pending, constantsPEMOM.PlayerGameRoundStatus.pending];

    /// Create game info object
    GameModelPEMOM gameInfo = GameModelPEMOM(
      gameMode: _gameRules['gameMode'],
      gameRulesID: gameRulesID,
      id: gameID,
      gameStatus: constants.cGameStatusOpen,
      duration: 60,
      userID: userID,
      playerNicknames: {userID: nickname},
      playerScores: playerScores,
      playerGameRoundStatus: playerGameRoundStatus,
      playerGoals: playerGoals,
      playerVideos: {},
      playerAvatars: {userID: playerAvatar},
      playerGameOutcome: constantsPEMOM.PlayerTrainingOutcome.pending,
      movement: {},
      gameRules: _gameRules,
      judging: {},
      dates: {'dateCreated': _rightNow},
      rewards: 0,
      ipfsURL: '',
      playerRecords: playerRecords,
      paymentReceived: false,
      ethereumAddress: 'unknown',
      dateCreated: _rightNow,
      dateUpdated: _rightNow,
      dateStart: previousMidnight(),
      dateEnd: nextMidnight(),
    );

    /// Save game to games collection
    await databaseServices.savePushupEMOMGame(gameInfo: gameInfo.toMap());

    /// return id so you can identify which game was created
    return gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Get player personal records
  /// ***********************************************************************
  /// ***********************************************************************

  /// fetch a player's records
  Future<Map<String, dynamic>> getTrainingEmomPlayerRecords2({required String userID, required String gameRulesID}) async {
    // get player record from db
    Map<String, dynamic> playerRecord = await databaseServices.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesID);

    return playerRecord;
  }

  /// create a player's records for training emom
  Future<Map<String, dynamic>> createTrainingEmomPlayerRecords2({required String userID, required String gameRulesID, required int maxPushupsIn60Seconds, required int pushupsPerRound}) async {
    Map<String, dynamic> playerRecord = await databaseServices.createPlayerRecords(userID: userID, gameRulesID: gameRulesID, maxPushupsIn60Seconds: maxPushupsIn60Seconds, pushupsPerRound: pushupsPerRound);
    return playerRecord;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc
  /// ***********************************************************************
  /// ***********************************************************************

  /// cycle through snapshots
  /// and from each one, create an object, that is added to a list
  List convertQuerySnapshotToListOfObjects(QuerySnapshot snapshot, String objectType) {
    List objectList = [];

    snapshot.docs.forEach((value) {
      var dataAsMap = value.data() as Map<String, dynamic>; // save as a map
      if (objectType == 'training') {
        GameModelPEMOM object = createGameObjectFromMap(dataAsMap);
        objectList.add(object);
      }
    });

    return objectList;
  }
}
