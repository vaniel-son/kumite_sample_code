import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/models/training_landing_content_model_penom.dart';
import 'package:dojo_app/game_modes/training_emom/models/training_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/database_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/general_service_pemom.dart';
import 'package:dojo_app/models/host_messages_model.dart';
import 'package:dojo_app/services/general_service.dart';

/// Manages / Determines the state of the player
/// based on their game document status and the day we are dealing with (today, or the past)
// this is used by the training screen UI to build the UI and content, based on potential different states

class TrainingLandingContentService {
  // Init some stuff

  /// Constructor
  TrainingLandingContentService() {
    //
  }

  /// Get player's status from latest game, and previous game
  static Future<List<TrainingLandingContentModel>> start({required String userID, required String gameRulesID, required String nickname}) async {
    /// *********************************************************
    /// INIT
    /// *********************************************************

    /// Contains all db calls from local and globally shared file
    DatabaseServicesPEMOM databaseService = DatabaseServicesPEMOM();

    /// Contains general services used by this game mode/rules type
    GeneralServicePEMOM generalService = GeneralServicePEMOM();

    /// Value to be returned
    // this will contain a list of playerGameCompetition objects
    List<TrainingLandingContentModel> playerTrainingGames = [];

    /// *********************************************************
    /// If game doc does not exist for TODAY, then create one
    /// *********************************************************
    // this is done so the rest of the logic to build content for each game doc flows without edge cases

    Map<String, dynamic> todaysGame = await databaseService.getTodaysTrainingGame(gameRulesID, userID);
    if (todaysGame.isEmpty) {
      // game does not exist toady so create one
      await generalService.createDefaultPushupEMOMGame(userID: userID, nickname: nickname, gameRulesID: gameRulesID);
    }

    /// *********************************************************
    /// Get LIST of games
    /// *********************************************************

    /// Get a user's COMPLETED games with this gameRulesID
    // note: if gameMap does not exist then one will be created when they visit game_screen
    // games are sorted by create date descending order
    QuerySnapshot gameMapSnapshot = await databaseService.getTrainingGames(gameRulesID, userID);

    /// Store all games as a list of maps
    // index 0 is latest, index 1 is the 2nd most recent game (if it exists)
    // if there are no games, then this will be an empty list
    List gamesList;

    // Store all games as a list of game objects
    gamesList = generalService.convertQuerySnapshotToListOfObjects(gameMapSnapshot, 'training');

    /// *********************************************************
    /// Determine max # of games to display
    /// *********************************************************
    /// Only the latest 2 games will be added to the games list
    // if there are no games, then the logic handles this case so it shows something for today /  yesterday

    int maxGameIndex = 6;
    if (gamesList.length <= 2) {
      maxGameIndex = 2; // at a minimum, show two training days on the UI
    } else if (gamesList.length <= 6 && gamesList.length >= 2) {
      maxGameIndex = gamesList.length;
    }

    /// *********************************************************
    /// Loop through each game and build a list of objects that is used by the training screen
    /// *********************************************************

    for (int i = 0; i <= maxGameIndex - 1; i++) {

      /// *********************************************************
      /// Determine player's game status
      /// *********************************************************

      String playerGameTrainingStatus = constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExist; // default value

      // two scenarios to manage right now
      // 1. only 1 game exists (today)
      // 2. 2 games exists (today, 5 days ago, but didn't play)

      // do NOT run this method when 0 games exist
      // instead, rely on the default playerGameTrainingStatus value
      if (gamesList.length - 1 >= i) {
        playerGameTrainingStatus = getPlayerStatusForATrainingGame(gamesList[i]);
      }

      /// *********************************************************
      ///  Store the game map
      /// *********************************************************

      late GameModelPEMOM _gameInfo;
      if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExist) {
        // create a blank one, for today, because none exist
        _gameInfo = generalService.createGameObjectFromMap({});
      } else {
        _gameInfo = gamesList[i];
      }

      /// *********************************************************
      ///  Edge case: change dateStart under special circumstances
      /// *********************************************************
      // when a player has never played before, then a game is created for today
      // but then the user will have no game for yesterday so this class will store one in memory but with a start date of today.. which is wrong.
      // ... Instead, we want a date of yesterday, as a temporary solution
      // hack solution: in this scenario, hijack the game's dateStart and change it to yesterdays date

      // if diff = 0, then competition date is today
      // if diff < 0, then comp date is in the past
      // if diff > 0, then competition is in the future
      if (i == 1) { // this case only affects the previous game from today, so in this case, index 1
        if (_gameInfo.dateStart.difference(GeneralService.previousMidnight()).inDays == 0) {
          _gameInfo.dateStart = _gameInfo.dateStart.subtract(Duration(days:1));
        }
      }

      /// *********************************************************
      /// Get data for EMOM Score Box
      /// *********************************************************

      // store required values that we need
      Map<String, dynamic> gameMap = _gameInfo.toMap();

      // set default values
      List playerRoundOutcomes = [constantsPEMOM.PlayerTrainingOutcome.pending, constantsPEMOM.PlayerTrainingOutcome.pending, constantsPEMOM.PlayerTrainingOutcome.pending];
      int playerLevel = 1;

      // get outcomes for each round
      if (GeneralService.mapHasFieldValue(gameMap, 'playerGameRoundStatus') && gameMap['gameStatus'] == constantsPEMOM.GameStatus.closed) { // validate the field has a value
        playerRoundOutcomes = gameMap['playerGameRoundStatus'];
      }

      // get the game level
      if (GeneralService.mapHasFieldValue(gameMap, 'playerGoals')) { // validate the field has a value
        if (gameMap['playerGoals'][userID] != null) { // validate the field has a value
          playerLevel = gameMap['playerGoals'][userID][0]; // get the first item in the index and set this as the level
        }
      }

      /// *********************************************************
      /// Get copy for host cards
      /// *********************************************************

      // get up to two messages back to display on the home screen
      HostCardMessagesModel hostCardMessages = getHostMessages(
          playerGameTrainingStatus: playerGameTrainingStatus, pushupsPerMinute: playerLevel);

      /// *********************************************************
      /// Get configuration for which widget to display and hide
      /// *********************************************************

      // To determine the widgets on the home page
      // look at the player's competition and game status to inform which ones should display
      TrainingScreenWidgetVisibilityModel trainingScreenWidgetVisibilityConfig = getTrainingScreenWidgetVisibilityConfiguration(
          playerGameTrainingStatus: playerGameTrainingStatus
      );

      /// *********************************************************
      /// Create object with a player's competition and game data
      /// *********************************************************
      TrainingLandingContentModel playerTrainingAndGameInfo = TrainingLandingContentModel(
        playerGameTrainingStatus: playerGameTrainingStatus,
        gameInfo: _gameInfo,
        hostCardMessages: hostCardMessages,
        widgetVisibilityConfig: trainingScreenWidgetVisibilityConfig,
        playerRoundOutcomes: playerRoundOutcomes,
        playerLevel: playerLevel,
      );

      /// Add this object to a list
      playerTrainingGames.add(playerTrainingAndGameInfo);
    }

    /// Return a list of objects that is used by the training screen
    return playerTrainingGames;
  }

  /// *********************************************************
  /// *********************************************************
  /// Methods below support main method above
  /// *********************************************************
  /// *********************************************************

   /// Determine the status for a game
  // the gamesList is sorted by dateCreated descending
  static String getPlayerStatusForATrainingGame(GameModelPEMOM gameInfo) {
    String playerStatusForATrainingGame = constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExist;
    bool playerSuccess = playerSuccessWithTrainingGame(gameInfo);

    if (gameInfo.gameStatus == constantsPEMOM.GameStatus.closed) {
      if (playerSuccess == true) {
        playerStatusForATrainingGame = constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithSuccess;
      } else {
        playerStatusForATrainingGame = constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithFailure;
      }
    } else if (gameInfo.gameStatus == constantsPEMOM.GameStatus.open) {
      if (GeneralService.gameIsForToday(gameInfo.dateStart)) {
        playerStatusForATrainingGame = constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenPlayerHasNotPlayed;
      } else if (!GeneralService.gameIsForToday(gameInfo.dateStart)) {
        playerStatusForATrainingGame = constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenForPreviousDayPlayerHasNotPlayed;
      }
    }

    return playerStatusForATrainingGame;
  }

  /// Determine if a closed game was successful or a failure
  // success is where all rounds were a win
  static bool playerSuccessWithTrainingGame(GameModelPEMOM gameInfo) {
    bool playerSuccess = false;

    if (gameInfo.playerGameOutcome == constantsPEMOM.PlayerTrainingOutcome.failure) {
      playerSuccess = false;
    } else if (gameInfo.playerGameOutcome == constantsPEMOM.PlayerTrainingOutcome.success) {
      playerSuccess = true;
    }

    return playerSuccess;
  }

  /// Based on the player training game status, determine the host card messaging copy
  static HostCardMessagesModel getHostMessages({required String playerGameTrainingStatus, required int pushupsPerMinute}) {

    // set default messages
    String hostMessage1 = 'Train everyday to prepare yourself for the Main Event!';

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExist) {
      hostMessage1 = 'You did not train this day.';
    }

    /*if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExistForToday) {
      hostMessage1 = 'Train everyday to prepare yourself for the Main Event!';
    }*/

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenPlayerHasNotPlayed) {
      if (pushupsPerMinute == 1) {
        hostMessage1 = 'Build your muscular endurance by performing pushups every minute.';
      } else {
        hostMessage1 = 'Build your muscular endurance by performing $pushupsPerMinute pushups every minute.';
      }
    }

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenForPreviousDayPlayerHasNotPlayed) {
      hostMessage1 = 'You did not train this day.';
    }

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithSuccess) {
      hostMessage1 = 'Very good, my student. \n\nCome back tomorrow when training re-opens.';
    }

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithFailure) {
      hostMessage1 = 'SMH. Train harder. \n\nCome back tomorrow when training re-opens.';
    }

    HostCardMessagesModel hostCardMessages = HostCardMessagesModel(
      message1: hostMessage1,
    );

    return hostCardMessages;
  }

  /// Based on the player training game status,
  // determine which widgets will be visible on the training screen
  static TrainingScreenWidgetVisibilityModel getTrainingScreenWidgetVisibilityConfiguration({required String playerGameTrainingStatus}) {

    // set default visibility
    bool isVisibleHostCardOne = true;
    bool isVisibleEmomScoreBox = false;
    bool isVisiblePlayButton = false;
    bool isVisibleEarnInfoTip = false;
    bool isVisibleSifuEncouragement = false;

    // #1
    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExistForToday) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = true;
      isVisiblePlayButton = true;
      isVisibleEarnInfoTip = true;
      isVisibleSifuEncouragement = false;
    }

    // #2
    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameDoesNotExist) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = false;
      isVisiblePlayButton = false;
      isVisibleEarnInfoTip = false;
      isVisibleSifuEncouragement = false;
    }

    // #3
    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenPlayerHasNotPlayed) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = true;
      isVisiblePlayButton = true;
      isVisibleEarnInfoTip = true;
      isVisibleSifuEncouragement = false;
    }

    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameOpenForPreviousDayPlayerHasNotPlayed) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = false;
      isVisiblePlayButton = false;
      isVisibleEarnInfoTip = false;
      isVisibleSifuEncouragement = false;
    }

    // #4
    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithSuccess) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = true;
      isVisiblePlayButton = false;
      isVisibleEarnInfoTip = false;
      isVisibleSifuEncouragement = true;
    }

    // #5
    if (playerGameTrainingStatus == constantsPEMOM.PlayerTrainingGameStatus.trainingGameClosedPlayerHasPlayedWithFailure) {
      isVisibleHostCardOne = true;
      isVisibleEmomScoreBox = true;
      isVisiblePlayButton = false;
      isVisibleEarnInfoTip = false;
      isVisibleSifuEncouragement = true;
    }

    TrainingScreenWidgetVisibilityModel trainingScreenWidgetVisibility = TrainingScreenWidgetVisibilityModel(
      isVisibleHostCardOne: isVisibleHostCardOne,
      isVisibleEmomScoreBox: isVisibleEmomScoreBox,
      isVisiblePlayButton: isVisiblePlayButton,
      isVisibleEarnInfoTip: isVisibleEarnInfoTip,
      isVisibleSifuEncouragement: isVisibleSifuEncouragement,
    );

    return trainingScreenWidgetVisibility;
  }

}
