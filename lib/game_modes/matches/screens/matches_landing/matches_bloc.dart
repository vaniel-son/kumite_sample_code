import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2_extras.dart';
import 'package:dojo_app/game_modes/matches/services/database_service_matches.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart' as helperMatches;
import 'package:dojo_app/game_modes/matches/services/game_service_matches.dart';
import 'package:dojo_app/game_modes/matches/constants_matches.dart' as constants;
import 'package:intl/intl.dart';

class MatchesBloc {
  /// ***********************************************************************
  /// Matches Bloc Constructor
  /// ***********************************************************************

  MatchesBloc({required this.gameMode, required this.matchGroupID, required this.playerOneUserID}) {
    /// Setup match page
    setupMatchScreen();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String gameMode;
  String matchGroupID;
  String playerOneUserID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesMatches databaseService = DatabaseServicesMatches();
  late Stream<QuerySnapshot> _matchesStream;
  GameServiceMatches matchService = GameServiceMatches();

  void dispose() {
    _matchDetailsController.close();
    _matchNotificationController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Contains all match details from database
  Stream<QuerySnapshot> get matchesStream => _matchesStream;

  /// Manages displaying match details on view
  final _matchDetailsController = StreamController<Map>();
  Stream<Map> get matchDetailsStream => _matchDetailsController.stream;
  Sink<Map> get matchDetailsSink => _matchDetailsController.sink;

  /// Manages match notifications on UI
  final _matchNotificationController = StreamController<Map>();
  Stream<Map> get matchNotificationStream => _matchNotificationController.stream;
  Sink<Map> get matchNotificationSink => _matchNotificationController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupMatchScreen() async {
    /// Fetch all match data
    // Match screen displays the most recent match, whether its still open or completed
    _matchesStream = databaseService.fetchLatestStartingGamesStream(gameMode, matchGroupID, playerOneUserID);

    /// Listen for database changes to match data
    listenToMatchChanges();
  }

  /// Listen for database changes to match data
  listenToMatchChanges() async {
    _matchesStream.listen((event) async {
      Map<dynamic, dynamic> matchesMapWithExtraData = {};
      if (event.docs.isNotEmpty) {
        /// When a match does exist, build all required data and send to the view.
        // Store first document, which will be the only one returned
        // and cast as a map
        matchesMapWithExtraData = event.docs.first.data() as Map<dynamic, dynamic>;

        /// Determine whether to display default message or a matchVersusCard widget, on match screen
        matchesMapWithExtraData['matchExists'] = true;

        /// Determine the opponent's user ID
        String playerTwoUserID = helperMatches.getOpponentUserID(matchesMapWithExtraData, playerOneUserID);

        /// Get the state of the players within a match
        // types of status is found in constants. ex. cGameOpenBothPlayersHaveNotPlayed
        String playersStatusInAMatch = matchService.getPlayersStatusInAMatch(event);

        /// Build host card content
        matchesMapWithExtraData = _buildHostCardContent(matchesMapWithExtraData, playersStatusInAMatch);

        /// Build content for match versus card
        matchesMapWithExtraData = matchService.buildMatchVersusCardContent(
            matchesMapWithExtraData, // contains all fields from match document
            playersStatusInAMatch, // contains status of players in the match
            playerTwoUserID,
            playerOneUserID);

        /// Determine if we display the challenge button
        // based on whether the game is open/closed, and if this player has played or not
        // also obtains button text
        matchesMapWithExtraData = getChallengeButtonStatusAndText(matchesMap: matchesMapWithExtraData, playersStatus: playersStatusInAMatch);

        /// The challenge button is hidden until Main Event day
        // determine whether to show the challenge button or not
        matchesMapWithExtraData['challengeButtonStatus'] = displayChallengeButtonOnGameDay(matchesMapWithExtraData);

        /// Get player records which will be used to draw the line chart module pushup count over time, personal record, and win/loss/record
        Map playerOneRecords = await matchService.getPlayerRecords(matchesMapWithExtraData['gameRules']['id'], playerOneUserID);
        Map playerTwoRecords = await matchService.getPlayerRecords(matchesMapWithExtraData['gameRules']['id'], playerTwoUserID);
        matchesMapWithExtraData['playerOneRecords'] = playerOneRecords;
        matchesMapWithExtraData['playerTwoRecords'] = playerTwoRecords;

        /// Create and store game info objects
        // this is shared with the game bloc
        GameModel2 gameInfo = matchService.createGameObject(matchesMapWithExtraData);
        GameModel2Extras gameInfoExtras = matchService.createGameExtrasObject(matchesMapWithExtraData, playerOneUserID, playerTwoUserID);
        matchesMapWithExtraData['gameInfo'] = gameInfo;
        matchesMapWithExtraData['gameInfoExtras'] = gameInfoExtras;

        /// Store judge form questions
        matchesMapWithExtraData['questions'] = matchesMapWithExtraData['questions'] as Map;

        /// Determine whether to display food button
        matchesMapWithExtraData['addFoodButtonVisibility'] = displayActivityAddButton(matchesMap: matchesMapWithExtraData, activityType: constants.nutritionActivityType, userID: playerOneUserID);
        //matchesMapWithExtraData['addFoodButtonVisibility'] = true;

        // Determine whether to display
        matchesMapWithExtraData['addSleepButtonVisibility'] = displayActivityAddButton(matchesMap: matchesMapWithExtraData, activityType: constants.sleepActivityType, userID: playerOneUserID);

      } else {
        matchesMapWithExtraData['matchExists'] = false; // informs UI to not show a match
      }

      /// Update sink so Match page updates on UI with this data
      matchDetailsSink.add(matchesMapWithExtraData);

    });
  }
}

/// Determine what Dojo Host Avatar should say to describe the current match
Map _buildHostCardContent(matchesMap, String matchStatus) {
  Map matchesMapWithExtraData = matchesMap;
  Map hostMessage = {};

  /// ***********************************************************************
  /// GameStatus: Closed
  /// ***********************************************************************

  /// game closed, both players lose by forfeit
  if (matchStatus == constants.cGameClosedBothPlayersLoseByForfeit) {
    hostMessage = {
      'title': 'The Results are in...',
      'message': 'you both lose the 60 second pushup sprint because you both never showed up! SMH'
    };

    /// game closed, this player has won case
  } else if (matchStatus == constants.cGameClosedPlayerOneWinsPlayerTwoLoses) {
    hostMessage = {'title': 'The Results are in...', 'message': 'you win the 60 second pushup sprint!'};

    /// game closed, this player has lost
  } else if (matchStatus == constants.cGameClosedPlayerOneLosesPlayerTwoWins) {
    hostMessage = {'title': 'The Results are in...', 'message': 'you lose the 60 second pushup sprint!'};

    /// game closed, this player wins by forfeit
  } else if (matchStatus == constants.cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit) {
    hostMessage = {'title': 'The Results are in...', 'message': 'you win the 60 second pushup sprint!'};

    /// game closed, this player loses by forfeit
  } else if (matchStatus == constants.cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit) {
    hostMessage = {
      'title': 'The Results are in...',
      'message': 'you lose the 60 second pushup sprint because you never showed up. Where is your sportsmanship!?'
    };

    /// game closed, both players tied
  } else if (matchStatus == constants.cGameClosedPlayerOneTiesPlayerTwoTies) {
    hostMessage = {'title': 'The Results are in...', 'message': 'you both tied the 60 second pushup sprint!'};

    /// ***********************************************************************
    /// GameStatus: Open
    /// ***********************************************************************

    /// game open: no one has played, this player has played, or opponent has played
  } else if (matchStatus == constants.cGameOpenBothPlayersHaveNotPlayed || matchStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed || matchStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
    hostMessage = {'title': 'PUSHUP SPRINT', 'message': 'who can perform MORE pushups in 60 seconds?'};

    /// we didn't handle a case.. so show some error
  } else {
    hostMessage = {
      'title': 'Uh oh',
      'message': 'Something went wrong. I told the game masters and they\'re looking into the issue.'
    };
  }

  matchesMapWithExtraData['hostMessage'] = hostMessage;
  return matchesMapWithExtraData;
}

/// Calculate the time remaining between now and the match end. This is used to determine whether to show challenge button or not.
Duration timeDifferenceCalc(Map matchesMapWithExtraData) {
  var timeDifference;
  final matchExpirationDate = matchesMapWithExtraData['dateMatchExpiration'].toDate();
  final timeNow = DateTime.now();
  timeDifference = matchExpirationDate.difference(timeNow);

  return timeDifference;
}

/// Manages whether to show the button based on if the match is less than 24 hours to expiring
String displayChallengeButtonOnGameDay(matchesMapWithExtraData) {
  String challengeButtonStatus = constants.cChallengeButtonStatusHidden;

  // Determine if its match day to show the challenge button
  if (matchesMapWithExtraData['matchExists'] == true &&
      timeDifferenceCalc(matchesMapWithExtraData) <= Duration(hours:24) &&
      matchesMapWithExtraData['challengeButtonStatus'] == constants.cChallengeButtonStatusEnabled) {
    challengeButtonStatus = constants.cChallengeButtonStatusEnabled;
    return challengeButtonStatus;
  } else if (matchesMapWithExtraData['matchExists'] == true && timeDifferenceCalc(matchesMapWithExtraData) > Duration(hours:24)) {
    challengeButtonStatus = constants.cChallengeButtonStatusHidden;
    return challengeButtonStatus;
  }
  return challengeButtonStatus;
}

/// Determien whether to show the challenge button based on game status

Map getChallengeButtonStatusAndText({required Map matchesMap, required String playersStatus}) {
  Map _matchesMap = matchesMap;

  /// Set default values in case no if statements are executed
  String challengeButtonText = "No upcoming match, yet";
  String challengeButtonStatus = constants.cChallengeButtonStatusHidden;

  /// Get status of overall game
  // option: OPEN (one or both players to play)
  // option: CLOSED (both have played, or there are forfeits)
  String gameStatus = _matchesMap['gameStatus'];

  /// ***********************************************************************
  /// GameStatus = closed
  /// ***********************************************************************

  /// Both players played so the game has closed
  if (gameStatus == 'closed') {
    _matchesMap['challengeButtonText'] = 'No upcoming match, yet';
    _matchesMap['challengeButtonStatus'] = constants.cChallengeButtonStatusHidden;
  }

  /// ***********************************************************************
  /// Game Status = open
  /// ***********************************************************************
  /// This game is open so...
  // this player has played, or has not played yet

  if (_matchesMap['gameStatus'] == 'open') {
    /// Case: both players have NOT played yet
    if (playersStatus == constants.cGameOpenBothPlayersHaveNotPlayed) {
      challengeButtonText = 'START CHALLENGE';
      challengeButtonStatus = constants.cChallengeButtonStatusEnabled;

      /// Case: This player played
      // but opponent has not played
    } else if (playersStatus == constants.cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed) {
      challengeButtonText = 'WAITING FOR OPPONENT TO PLAY';
      challengeButtonStatus = constants.cChallengeButtonStatusHidden;

      /// Case: Opponent has played
      // but this player has not played
    } else if (playersStatus == constants.cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed) {
      challengeButtonText = 'START CHALLENGE';
      challengeButtonStatus = constants.cChallengeButtonStatusEnabled;

      /// A case we didn't handle so do this...
    } else {
      challengeButtonText = 'Sorry, something is awry';
      challengeButtonStatus = constants.cChallengeButtonStatusHidden;
    }

    _matchesMap['challengeButtonText'] = challengeButtonText;
    _matchesMap['challengeButtonStatus'] = challengeButtonStatus;
  }

  return _matchesMap;
}

bool displayActivityAddButton({required Map matchesMap, required String activityType, required String userID}){
  // Default value to return
  bool displayButton = false;

  // Get today's date in a specific format
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final String formattedDate = formatter.format(now);

  // Check if the keys exist before moving forward
  bool hasKey = false;
  if (matchesMap['matchActivityTracker'].containsKey(userID)) {
    if (matchesMap['matchActivityTracker'][userID].containsKey(formattedDate)) {
      if (matchesMap['matchActivityTracker'][userID][formattedDate].containsKey(activityType)) {
        hasKey = true;
      }
    }
  }

  if (hasKey == true){
    if (matchesMap['matchActivityTracker'][userID][formattedDate][activityType] == false) {
      displayButton = true;
    } else
      displayButton = false;
  }

  return displayButton;
}

