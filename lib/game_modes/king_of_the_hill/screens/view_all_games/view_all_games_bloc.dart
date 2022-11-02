import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class TemplateBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  TemplateBloc({required this.userID, required this.gameRulesID, required this.competitionID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;
  String gameRulesID;
  String competitionID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Parameters accessible here and as getters
  late String nickname;
  late String gameRulesTitle;
  late String gameModesTitle;

  void dispose() {
    _templateDataController.close();
    _wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage flag to either load screen UI's widget, ,or display loading
  final _wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => _wrapperController.stream;
  Sink<Map> get wrapperSink => _wrapperController.sink;

  /// Store one time fetched data via this getter
  // unused
  late Map _templateOneData;
  Map get templateOneData => _templateOneData;

  /// Stores stream of data for this getter
  // unused
  late Stream<QuerySnapshot> _templateStreamData;
  Stream<QuerySnapshot> get templateStreamData => _templateStreamData;

  /// Manage data stream and sync between bloc and UI
  // unused
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

  String get getGameRulesTitle {
    return gameRulesTitle;
  }

  String get getGameModesTitle {
    return gameModesTitle;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID); // store in global variable for everywhere access

    /// Store one time data in this Map
    _templateOneData = // await databaseService.getLeaderboardByUserID(userID: userID);

    await blocSetup();

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> templateWrapper = {
      'ready': true,
    };
    wrapperSink.add(templateWrapper);
  }

  blocSetup() async {
    /// Fetch collection as a stream
    _templateStreamData = databaseServiceShared.fetchAllUsers();

    listenForChanges();
  }

  /// Anytime this stream has data changes, the following is executed
  listenForChanges() async {
    _templateStreamData.listen((event) async {
      List someList = [];
      if (event.docs.isNotEmpty) {
        /// When leaderboard docs exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          someList.add(dataAsMap);

        });

      } else {
        // do nothing
      }

      /// Update sink so UI updates with the stream connected to this sink
      templateDataSink.add(someList);
    });
  }
}
