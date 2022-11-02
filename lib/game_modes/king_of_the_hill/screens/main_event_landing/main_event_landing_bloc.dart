import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboards_all_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/models/main_event_landing_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/player_records_model_KOH.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/services/main_event_content_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class MainEventLandingBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  MainEventLandingBloc({required this.userID, required this.gameRulesID}) {
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

  /// General Service, global
  GeneralService generalServiceShared = GeneralService();

  /// Other Parameters
  late Map<String, dynamic> todaysGameMap = {};

  /// Parameters that are used as getters
  late String nickname;
  late String gameRulesTitle;
  late String gameModesTitle;
  late PlayerRecordsModelKOH playerRecords;
  late List singleCompetitionLeaderboardRecordsList;
  late List<MainEventLandingContentModel> playerCompetitions;
  List<LeaderboardAndPlayerRankModelKOH> leaderboards = [];

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

  // returns the gameMap associated with the most recent competition
  Map<String, dynamic> get getTodaysGameMap {
    return todaysGameMap;
  }

  List get getCompetitions {
    return playerCompetitions;
  }

  PlayerRecordsModelKOH get getPlayerRecords {
    return playerRecords;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID);
    // await databaseServiceShared.fetchNicknameWhenDefault(userID: userID);
    // helper.setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Fetch all competitions
    QuerySnapshot competitionSnapshot = await databaseService.getCompetitions(gameRulesID);

    /// Get all the content to display on the home screen
    // Stores competition, player's competitionGameStatus, gameStatus, game information. leaderboard, rank, etc
    // Each of these objects are then stored in a list, sorted by dateStart descending order
    // - if a competition does NOT exist, the service will create one
    // - if a competition does not exist for today, the service will create one
    playerCompetitions = await MainEventContentServiceService.start(
      competitionSnapshot: competitionSnapshot,
      userID: userID,
      gameRulesID: gameRulesID,
      nickname: nickname,
    );

    /// Make this available so the UI screen can access it
    // which is then passed to game screen
    todaysGameMap = (playerCompetitions[0].gameInfo.id != '0') ? playerCompetitions[0].gameInfo.toMap() : {};

    /// Get player records
    // TODO convert playerRecords to an object
    playerRecords = await gameService.getPlayerRecords(gameRulesID, userID);
  }

  /// IF everything is ready, then add 'ready: true" to stream sink so the
  // UI will move away from loading to intended UI
  loadUIOnScreen() {
    Map<String, dynamic> templateWrapper = {
      'ready': true,
    };
    wrapperSink.add(templateWrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for event changes
  /// ***********************************************************************
  /// ***********************************************************************
}
