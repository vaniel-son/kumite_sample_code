import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/models/main_event_landing_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/services/main_event_content_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class PlayNowBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  PlayNowBloc({required this.userID, required this.gameRulesID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;
  String gameRulesID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Parameters accessible here and as getters
  late String nickname;
  late List<MainEventLandingContentModel> playerCompetitions;

  // this URL is from PROD firebase storage
  // TODO: get from a firebase document
  String backgroundVideo = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Fmisc%2Fbg-assibey-car-418.mp4?alt=media&token=90c1cee2-c2b7-408f-a644-7b2f17c22259';

  void dispose() {
    _templateDataController.close();
    wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => wrapperController.stream;
  Sink<Map> get wrapperSink => wrapperController.sink;

  /// Store one time fetched data via this getter
  late Map _templateOneData;
  Map get templateOneData => _templateOneData;

  /// Stores stream of data for this getter
  late Stream<QuerySnapshot> _templateStreamData;
  Stream<QuerySnapshot> get templateStreamData => _templateStreamData;

  /// Manage data stream and sync between bloc and UI
  final _templateDataController = StreamController<List>();
  Stream<List> get templateDataStream => _templateDataController.stream;
  Sink<List> get templateDataSink => _templateDataController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID); // store in global variable for everywhere access

    /// Fetch all competitions
    // TODO: getCompetitions should return games of a specific gameRulesID
    QuerySnapshot competitionSnapshot = await databaseService.getCompetitions('x');

    /// Get all the content to display on the main event landing
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

    /// Listen for event changes that will affect the UI
    // listenForChanges();
  }

  loadUIOnScreen() {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
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

  /// Anytime this stream has data changes, the following is executed
  listenForChanges() async {
    _templateStreamData.listen((event) async {
      List someList = [];
      if (event.docs.isNotEmpty) {
        /// When leaderboard docs exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        someList = GeneralService.convertQuerySnapshotToListOfMaps(event);

      } else {
        // do nothing
      }

      /// Update sink so UI updates with the stream connected to this sink
      templateDataSink.add(someList);
    });
  }
}
