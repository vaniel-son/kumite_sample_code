import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class EndGameBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  EndGameBloc() {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  // String competitionID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Parameters accessible here and as getters
  late String nickname;

  /// Declare getters
  String competitionToEndID = 'none'; // none by default
  DateTime competitionToEndDateStart = DateTime.now(); // none by default

  void dispose() {
    _templateDataController.close();
    _wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage whether to load the ui screen or not
  // to load level selection page
  final _wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => _wrapperController.stream;
  Sink<Map> get wrapperSink => _wrapperController.sink;

  /// Stores stream of data for this getter
  // unused
  late Stream<QuerySnapshot> _competitionsStreamData;
  Stream<QuerySnapshot> get competitionsStreamData {
    return _competitionsStreamData;
  }

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

  /// Store Map data, and get it via this getter
  // unused
  late Map _templateOneData;
  Map get templateOneData {
    return _templateOneData;
  }

  String get getCompetitionToEndID {
    return competitionToEndID;
  }

  DateTime get getCompetitionToEndStartDate {
    return competitionToEndDateStart;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Fetch latest open competition
    Map competition = await databaseService.fetchOldestActiveCompetition();

    // these values are used by the UI
    competitionToEndID = competition['id'];
    competitionToEndDateStart = competition['dateStart'].toDate();
  }

  loadUIOnScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {'ready': true};
    wrapperSink.add(wrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  endCompetition() async {
    await databaseService.closeCompetition(competitionID: competitionToEndID);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for changes
  /// ***********************************************************************
  /// ***********************************************************************

  /// Anytime this stream has data changes, the following is executed
  listenForChanges() async {
    _competitionsStreamData.listen((event) async {
      List someList = [];
      if (event.docs.isNotEmpty) {

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
