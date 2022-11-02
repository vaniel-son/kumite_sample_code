import 'dart:async';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/judge_matches/services/database_service_judge_matches.dart';

class JudgeListBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  JudgeListBloc({required this.userID}) {
    /// Setup game modes page
    setupGameModes();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesJudgeMatches databaseService = DatabaseServicesJudgeMatches();
  late Stream<QuerySnapshot> _matchesOpenForJudging;

  void dispose() {
    _matchesOpenForJudgingController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Stores stream of data for matches that are available for judging
  Stream<QuerySnapshot> get matchesOpenForJudging => _matchesOpenForJudging;

  /// Send open matches for judging stream to UI
  final _matchesOpenForJudgingController = StreamController<List>();

  Stream<List> get matchesOpenForJudgingStream => _matchesOpenForJudgingController.stream;
  Sink<List> get matchesOpenForJudgingSink => _matchesOpenForJudgingController.sink;


  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupGameModes() {
    /// Fetch all matches open for judging
    _matchesOpenForJudging = databaseService.fetchMatchesForJudgingStream(globals.dojoUser.uid);

    listenForChanges();
  }

  listenForChanges() async {
    _matchesOpenForJudging.listen((event) async {
      // Map<dynamic, dynamic> matchesOpenForJudgingMap = {};
      List listOfMatchesOpenForJudging = [];
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          listOfMatchesOpenForJudging.add(dataAsMap);

        });

      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      matchesOpenForJudgingSink.add(listOfMatchesOpenForJudging);
    });
  }
}