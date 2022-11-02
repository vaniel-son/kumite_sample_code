import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/models/judge_counts_model_koh.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:intl/intl.dart';

class JudgeListBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  JudgeListBloc({required this.userID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Parameters accessible here and as getters
  late String nickname;
  late String competitionDate = DateTime.now().toString();

  /// Mange counts of games
  JudgeCountsModelKOH judgeCount = JudgeCountsModelKOH();

  void dispose() {
    _gamesOpenForJudgingController.close();
    _wrapperController.close();
    _gamesPendingConsensusController.close();
    _gamesClosedSuccessJudgementController.close();
    _gamesClosedFailedJudgementController.close();
    _gamesForJudgingCount.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => _wrapperController.stream;
  Sink<Map> get wrapperSink => _wrapperController.sink;

  /// Stores stream of data for matches that are available for judging
  late Stream<QuerySnapshot> _gamesOpenForJudging;
  Stream<QuerySnapshot> get gamesOpenForJudging => _gamesOpenForJudging;

  /// Stores stream of data for matches that was judged by this user and are CLOSED
  late Stream<QuerySnapshot> _gamesClosedForJudging;
  Stream<QuerySnapshot> get gamesClosedForJudging => _gamesClosedForJudging;

  /// Send games open for judging but HAVE NOT been judged by this user yet
  final _gamesOpenForJudgingController = StreamController<List>();
  Stream<List> get gamesOpenForJudgingStream => _gamesOpenForJudgingController.stream;
  Sink<List> get gamesOpenForJudgingSink => _gamesOpenForJudgingController.sink;

  /// Send games open for judging but HAVE been judged by this user yet
  final _gamesPendingConsensusController = StreamController<List>();
  Stream<List> get gamesPendingConsensusStream => _gamesPendingConsensusController.stream;
  Sink<List> get gamesPendingConsensusSink => _gamesPendingConsensusController.sink;

  /// Send games closed that this user has succeeded in judging
  final _gamesClosedSuccessJudgementController = StreamController<List>();
  Stream<List> get gamesClosedSuccessJudgementStream => _gamesClosedSuccessJudgementController.stream;
  Sink<List> get gamesClosedSuccessJudgementSink => _gamesClosedSuccessJudgementController.sink;

  /// Send games closed that this user has failed judging
  final _gamesClosedFailedJudgementController = StreamController<List>();
  Stream<List> get gamesClosedFailedJudgementStream => _gamesClosedFailedJudgementController.stream;
  Sink<List> get gamesClosedFailedJudgementSink => _gamesClosedFailedJudgementController.sink;

  /// ***********************************************************************
  /// Streams to manage the count of games
  /// ***********************************************************************

  /// Send games open for judging but HAVE NOT been judged by this user yet
  final _gamesForJudgingCount = StreamController<JudgeCountsModelKOH>();
  Stream<JudgeCountsModelKOH> get gamesForJudgingCountStream => _gamesForJudgingCount.stream;
  Sink<JudgeCountsModelKOH> get gamesForJudgingCountSink => _gamesForJudgingCount.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
  }

  String get getCompetitionDate {
    return competitionDate;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID);

    /// Fetch the competitionID of the games to judge
    // returns the oldest dateStart competition, where status is open
    // if there are multiple competitions open
    Map competitionDocument = await databaseService.fetchOldestActiveCompetition();
    String competitionID;

    /// Store competitionID and formatted competitionDate, if available
    // otherwise, return default values
    if (competitionDocument.isNotEmpty) {
      competitionID = competitionDocument['id'];

      // Store the day of the competition so the UI can access
      DateTime _competitionDate = competitionDocument['dateStart'].toDate();
      DateFormat formatter = DateFormat('MMMd');
      competitionDate = formatter.format(_competitionDate);
    } else {
      competitionID = '0';
      competitionDate = 'No competitions available';
    }

    /// Fetch games open for judging
    _gamesOpenForJudging = databaseService.fetchOpenGamesForJudging(competitionID: competitionID);
    _gamesClosedForJudging = databaseService.fetchClosedGamesForJudging(competitionID: competitionID);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    Map<String, dynamic> wrapperMap = {
      'ready': true,
    };
    wrapperSink.add(wrapperMap);

    /// Start listening for events so that we can alter the UI an data accordingly
    listenForChanges();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  listenForChanges() async {
    /// Uses the stream of data to..
    // loop through each document of this stream
    // convert to map and add to a list
    // pass this list to the screen UI to display the matches

    /// OPEN FOR USER TO JUDGE
    _gamesOpenForJudging.listen((event) async {
      List listOfGamesOpenForJudging = [];
      List listOfGamesPendingConsensus= [];
      int openGamesCount = 0;

      if (event.docs.isNotEmpty) {
        /// When a games exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        // which the UI will use to render the widgets
        event.docs.forEach((value) {
          // 'judges' contains a list of userIDs (can be empty),
          // which have judged this current judge document already
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          List judges = dataAsMap['judges'];

          /// Judges are only allowed to judge a video once
          // so do not let them judge games they have already judged but are still open
          // this will categorize the games into two buckets: open and pending (judge has judged the video)
          // note: 1 to n Judges must provide the same score to validate a score and close a judging request
          if (judges.contains(userID)) {
           /// this user has judged this game and game is OPEN
            // add to list so UI can process list and display items under pending category
            listOfGamesPendingConsensus.add(dataAsMap);
          } else {
            /// this user has NOT judged the game and game is open
            // add to list so UI can process this list to display the items
            listOfGamesOpenForJudging.add(dataAsMap);
          }

          // tally up number of open games remaining to judge
          openGamesCount = openGamesCount + 1;
          // judgeCount.openCount = judgeCount.openCount + 1;
        });
      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      gamesOpenForJudgingSink.add(listOfGamesOpenForJudging);
      gamesPendingConsensusSink.add(listOfGamesPendingConsensus);

      /// update object with # of open games
      judgeCount.openCount = openGamesCount;

      // update sink for game counts
      gamesForJudgingCountSink.add(judgeCount);
    });

    /// USER HAS JUDGED BUT CLOSED
    // if a game is closed, it can be in two states:
    // you were part of the judges who met consensus
    // you were NOT in the group of judges who provided similar scores
    _gamesClosedForJudging.listen((event) async {
      List listOfGamesSuccessJudgement = [];
      List listOfGamesFailedJudgement = [];
      if (event.docs.isNotEmpty) {
        /// When a matches exist, build all required data and send to the view.

        /// Store documents
        // loop through the collection of documents
        // Store each document as a list of maps
        event.docs.forEach((value)
        {
          var dataAsMap = value.data() as Map<dynamic, dynamic>;
          List judges = dataAsMap['judges'];
          Map judgeScores = dataAsMap['judgeScores'];
          int consensusScore = dataAsMap['consensusScore'];

          if (judgeScores[userID] == consensusScore) {
            // user succeeded: provided a score similar to other judges to reach consensus
            listOfGamesSuccessJudgement.add(dataAsMap);
          } else if (judgeScores[userID] != consensusScore) {
            // user failed: did NOT provide a similar score as the general consensus
            listOfGamesFailedJudgement.add(dataAsMap);
          }

          // tally up number of open games remaining to judge
          judgeCount.totalClosedCount = judgeCount.totalClosedCount + 1;
        });
      } else {
        // do nothing
      }

      /// Update sink so UI updates with this data
      gamesClosedSuccessJudgementSink.add(listOfGamesSuccessJudgement);
      gamesClosedFailedJudgementSink.add(listOfGamesFailedJudgement);

      // update sink for game counts
      gamesForJudgingCountSink.add(judgeCount);
    });
  }
}
