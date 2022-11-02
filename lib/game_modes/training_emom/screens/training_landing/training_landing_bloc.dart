import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/models/training_landing_content_model_penom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/services/training_landing_content_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;

class TrainingLandingBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  TrainingLandingBloc({required this.userID, required this.gameRulesID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;
  String gameRulesID;

  /// Contains all db calls from local and globally shared file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Contains general services used by this game mode/rules type
  GameServiceKOH gameService = GameServiceKOH();
  GeneralService generalServiceGlobal = GeneralService();

  /// Other Parameters
  late Map<String, dynamic> todaysGameMap = {};
  int phoBowlsEarned = 0;
  List playerRoundOutcomes = [constantsPEMOM.PlayerTrainingOutcome.pending, constantsPEMOM.PlayerTrainingOutcome.pending, constantsPEMOM.PlayerTrainingOutcome.pending];
  int playerLevel = 1;

  /// Parameters that are used as getters
  late String nickname;
  late List<TrainingLandingContentModel> playerTrainingGames;
  int maxRepCount = 0;
  List phoBowlLeaderboardRecords = [];

  void dispose() {
    wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams // Getters
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage: fetch required data before loading screen UI widgets
  final wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => wrapperController.stream;
  Sink<Map> get wrapperSink => wrapperController.sink;

  /// Stores some stream of data
  // currently unused
  late Stream<QuerySnapshot> _competitionsStreamData;
  Stream<QuerySnapshot> get competitionsStreamData => _competitionsStreamData;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
  }

  // returns the gameMap associated with the most recent competition
  Map get getTodaysGameMap {
    return todaysGameMap;
  }

  List get getPlayerTrainingGames {
    return playerTrainingGames;
  }

  int get getPhoBowlEarnedCount {
    return phoBowlsEarned;
  }

  int get getMaxRepCount {
    return maxRepCount;
  }

  List get getPhoBowlLeaderboardRecords {
    return phoBowlLeaderboardRecords;
  }

  int get getPlayerLevel {
    return playerLevel;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID); // store in global variable for everywhere access

    /// Get content for each game tab that will display on the UI screen
    // Stores player's trainingGameStatus, game information. widget visibility, host card message
    // Each of these objects are then stored in a list, sorted by dateStart descending order
    // - if a competition does not exist for today, the service will create one
    playerTrainingGames = await TrainingLandingContentService.start(
      userID: userID,
      gameRulesID: gameRulesID,
      nickname: nickname,
    );

    /// Get pho bowls count
    // - if this record does not exist, then this will create one with default value of 0 pho bowls
    // - this is not specific to a game, so it is not part of the playerTrainingGames object
    phoBowlsEarned = await GeneralService.getEarnedPhoBowlsFromAllLocations(userID: userID);

    /// Get player level
    // this level is the overall level for training emom (player records), and not the level that is specific to a game doc
    Map<String, dynamic> playerRecord = await databaseServiceShared.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesID);
    if (GeneralService.mapHasFieldValue(playerRecord, 'emomRepGoalsEachMinute')) {
      playerLevel = playerRecord['emomRepGoalsEachMinute'];
    }

    /// Get max rep count
    if (GeneralService.mapHasFieldValue(playerRecord, 'maxPushupsIn60Seconds')) {
      maxRepCount = playerRecord['maxPushupsIn60Seconds'];
    }

    /// Make game map, for today, available so the UI screen can access it
    // which is then passed to game screen
    todaysGameMap = (playerTrainingGames[0].gameInfo.id != '0') ? playerTrainingGames[0].gameInfo.toMap() : {};

    /// Get pho leaderboard data as a list of maps, where each map is a leaderboard record
    /// get a list of all leaderboard records for a specific competition
    QuerySnapshot allPhoBowlRecords = await databaseServiceShared.getAllPhoBowlRecordsFromFirebase(); // fetches pho bowl count from firebase only
    phoBowlLeaderboardRecords = GeneralService.convertQuerySnapshotToListOfMaps(allPhoBowlRecords);
  }

  /// IF everything is ready, then add 'ready: true" to stream sink so the
  // UI will move away from loading to intended UI
  loadUIOnScreen() {
    Map<String, dynamic> templateWrapper = {
      'ready': true,
    };
    wrapperSink.add(templateWrapper);
  }
}
