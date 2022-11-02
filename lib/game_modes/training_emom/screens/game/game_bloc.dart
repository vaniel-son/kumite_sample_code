import 'package:dojo_app/game_modes/training_emom/models/emom_hud_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/services/build_widgets_service.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/services/video_processing_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/services/stage_service.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;
import 'package:dojo_app/game_modes/training_emom/screens/game/services/game_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/general_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/database_service_pemom.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/constants.dart' as constants;

/// ***********************************************************************
/// ***********************************************************************
/// The game bloc has a few major jobs
/// 1. Load gamebloc with gameInfo object for a new game or existing game
/// 2. navigate through the game screen
/// 3. Display widgets on the screen based on game stage
/// 4. Save data for players
///
/// IMPORTANT DATA:
/// GameInfo object: this is extensively used throughout the class

/// How to follow the logic in this class
// follow SetupGame code
  // Initialize game config variables (timers, music, content, etc)
  // create GameInfo Object (info from levels and matches doc)
  // setup timers
  // start listening to game_screen
  // gameStage.start to populate game_screen with initial widgets and play music

// then follow listenUiEventStream code
  // both methods will call the other methods in this class and other files like...
  // files in services folder: database_service, helper_functions, build_game_screen_widgets

// Player1 is the player using the app

/// ***********************************************************************
/// ***********************************************************************

enum cameraSize { Full, Small } // Size of the recording camera game_screen UI screen
enum videoPlayerConfig {none, opponent, self} // which video should display on the game_screen UI

class GameBloc {
  /// ***********************************************************************
  /// GameBloc Constructor
  /// ***********************************************************************
  GameBloc({
    required this.playerOneUserID,
    required this.gameRulesID,
    required this.cameraController,
    this.gameMap = const {},});

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Get passed in parameters required for GameBloc
  // helps determine the type of game so the bloc can decide how to configure this game
  // the globals are initially populated on the game_screen.dart
  late String playerOneUserID; // this user
  late String gameRulesID;
  late Map gameMap; // contains all fields from the game doc, and can be mapped to gameInfoKOH model

  /// Get main event gameRulesID
  // there is only 1 main event as of now, so this can be hardcoded. Once we have more main event types, this will need to be dynmaically obtained
  String mainEventGameRulesID = constants.GameRulesConstants.kohPushupMax60;

  // Instantiate general databaseServices object that contains methods to CRUD on firebase
  DatabaseServicesPEMOM databaseServices = DatabaseServicesPEMOM();
  DatabaseServices databaseServicesShared = DatabaseServices();

  // Instantiate services that are used in the controller
  GeneralServicePEMOM generalServicePEMOM = GeneralServicePEMOM(); // general services used by training emom screens
  late StageService stageService; // helps build each stage of the game
  GameServicePEMOM gameServicePEMOM = GameServicePEMOM(); // services specific to the game

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  // GameInfo is a replica of the game document document
  late GameModelPEMOM lgGameInfo;

  /// Initialize other parameters
  late String nickname;
  late String gameID;

  // Number of required pho bowls required for the upcoming main event
  int phoBowlsRequiredForLatestMainEventInvite = 100; // this will be pulled from the competition document dynamically, 100 is a default value that will be over ridden
  int phoBowlsInventoryCount = 0; // how many you currently own. 0 is default value
  int phoBowlsEarned = 0; // how many you earned after playing this game. Shared with pho bowl progress screen so it knows how many the user just earned from playing this game

  // enable/disables rep counter for rep testing stage
  bool checkForTestRep = false;

  // Contains widgets that will be added to the game UI sink
  List<Widget> myWidgets = []; // list that populates game screen dynamically

  // Store cached videos
  var cachedMovementTutorialVideo; // unused

  // Camera and Video Variables
  late XFile videoFile; // Stores video file after its recorded
  final CameraController cameraController;
  late VideoProcessingServicePEMOM videoProcessingServiceKOH;
  late File localSelfieVideoToPlay;

  // Videos that play during the game
  late String tutorialVideo;
  late String getInFrameVideo;
  String rewardsBackgroundVideo = ''; // default value

  // Giphy images that display at the end of each round
  List giphyImages = [];

  /// When the round ends, a method that ends the round early is triggered, and should only be triggered once
  // why do we have this trigger: currently, it fires repetitively, executing some logic over and over
  // so we use this trigger to prevent it from running more than once per round
  bool triggeredOnce = false;

  /// ***********************************************************************
  /// Game Configurations
  /// ***********************************************************************

  // Emom Config
  int maxEMOMRounds = 3;
  int currentEMOMRound = 0; // changes as the rounds increment, where 0 is not a round

  // For managing rounds information for game screen UI
  int pushupCountForCurrentRound = 0; // increments up as camera captures pushup reps
  bool countPushupsEnabled = false; // prevents pushups from counting when you want the feature disabled

  // default values
  int newPushupGoalPerMinute = 0; // pushup goal the user has at the END of the training session
  int startingPushupGoalPerMinute = 0; // pushup goal the user has at the START of the training session

  // default value of which stage to load after this stage
  constantsPEMOM.GameStage stageToLoadAfterShowFormStage = constantsPEMOM.GameStage.CountdownStarting;

  // Workout timers init here so they can be closed when dispose() is called
  late TimerService countdownTimer;
  int cCountdownTimer = constantsPEMOM.cCountdownTimer; // pre workout countdown to start
  late TimerService workoutTimer;
  int cWorkoutTimer = constantsPEMOM.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document

  // Music
  String cIntroMusic =  'assets/audio/formula1_song_1st_half.mp3';
  String cYourResultsMusic = 'assets/audio/trumpet_songB.mp3';

  // Workout music options
  String cWorkoutMusic = 'assets/audio/diggy_2017_4_song.mp3';
  String cWorkoutMusic01 = 'assets/audio/diggy_2017_4_song.mp3';
  String cWorkoutMusic02 = 'assets/audio/taiko-kodo-01.mp3';
  late List workoutMusicPlaylist = [cWorkoutMusic01, cWorkoutMusic02];

  // Declare music parameters here
  // so that when they are disposed by dispose();
  // they exist and can be disposed
  late PlayAudio introMusic;
  late PlayAudio workoutMusic;
  late PlayAudio workoutMusic01;
  late PlayAudio workoutMusic02;

  void setTimers () {
    countdownTimer = TimerService(countdown: cCountdownTimer);
    workoutTimer = TimerService(countdown: cWorkoutTimer);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage: fetch required data before loading screen UI widgets
  final _gameScreenWrapperController = StreamController<Map>();
  Stream<Map> get gameScreenWrapperStream => _gameScreenWrapperController.stream;
  Sink<Map> get gameScreenWrapperSink => _gameScreenWrapperController.sink;

  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _loadGameStageController = StreamController<constantsPEMOM.GameStage>();
  Stream<constantsPEMOM.GameStage> get loadGameStageStream => _loadGameStageController.stream;
  Sink<constantsPEMOM.GameStage> get loadGameStageSink => _loadGameStageController.sink;

  /// Handles what should be displayed on UI (ex. since something happened, go do something like update the UI)
  final _uiController = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiStream => _uiController.stream;
  Sink<List<Widget>> get gameScreenUISink => _uiController.sink;

  /// Handle the game button's config: visibility, text, action
  final _buttonController = StreamController<Map>();
  Stream<Map> get buttonControllerStream => _buttonController.stream;
  Sink<Map> get buttonControllerSink => _buttonController.sink;

  final _videoPlayerController = StreamController<Map>();
  Stream<Map> get videoPlayerControllerStream => _videoPlayerController.stream;
  Sink<Map> get videoPlayerControllerSink => _videoPlayerController.sink;

  ///Managing Camera for Video
  final _cameraUIController = StreamController<Map>();
  Stream<Map> get cameraUIControllerStream => _cameraUIController.stream;
  Sink<Map> get cameraUIControllerSink => _cameraUIController.sink;

  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _fullBackground2UIController = StreamController<bool>();
  Stream<bool> get fullBackground2UIStream => _fullBackground2UIController.stream;
  Sink<bool> get fullBackground2UISink => _fullBackground2UIController.sink;

  ///VideoURL trigger
  final _videoURLController = StreamController<String>();
  Stream<String> get videoURLStream => _videoURLController.stream;
  Sink<String> get videoURLSink => _videoURLController.sink;

  /// Streams sent to EMOM HUD

  /// EMOM Hud: show/hide widgets on the game screen's EMOM HUD
  final _emomHUDController = StreamController<EmomHUDWidgetVisibilityModel>();
  Stream<EmomHUDWidgetVisibilityModel> get emomHUDControllerStream => _emomHUDController.stream;
  Sink<EmomHUDWidgetVisibilityModel> get emomHUDControllerSink => _emomHUDController.sink;

  /// Manage the status of all rounds
  final _roundStatusController = StreamController<List>();
  Stream<List> get roundStatusControllerStream => _roundStatusController.stream;
  Sink<List> get roundStatusControllerSink => _roundStatusController.sink;

  /// Sends the pushup count to the game screen
  final _currentRoundRepCountController = StreamController<int>();
  Stream<int> get currentRoundRepCountControllerStream => _currentRoundRepCountController.stream;
  Sink<int> get currentRoundRepCountControllerSink => _currentRoundRepCountController.sink;

  /// Sends EMOM timer to game screen
  final _emomTimerController = StreamController<List<Widget>>();
  Stream<List<Widget>> get emomTimerControllerStream => _emomTimerController.stream;
  Sink<List<Widget>> get emomTimerControllerSink => _emomTimerController.sink;

  /// Listens for pushups from game screen then sends to game bloc to process
  final _pushupListenerController = StreamController<int>();
  Stream<int> get pushupListenerControllerStream => _pushupListenerController.stream;
  Sink<int> get pushupListenerControllerSink => _pushupListenerController.sink;

  /// Manages EMOM rounds so it can update the EMOM HUD and Game Screen
  final _emomRoundListenerController = StreamController<int>();
  Stream<int> get emomRoundListenerControllerStream => _emomRoundListenerController.stream;
  Sink<int> get emomRoundListenerControllerSink => _emomRoundListenerController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************
  /// This method is the starting point for all methods to start this bloc

  void preSetupGameScreen() async {
    /// get nickname
    nickname = await GeneralService.getNickname(playerOneUserID); // store in global variable for everywhere access

    /// Does a game exist for this user today yet?
    // 'training landing screen' passes in a game map, it either has data (game exists) or isEmpty (no game)
    // 'max rep form' does not pass in a game map
    // ideally, we should always pass in the game map from a prior route, when available in cases where a previous screen required it
    if (gameMap.isEmpty) {
      /// Get today's game Map from DB, if it exists
      // one may or may not exist for today
      gameMap = await databaseServices.getTodaysTrainingGame(gameRulesID, playerOneUserID);

      /// get latest player records to update the game's goal
      // so we have the latest reps per round count for this game
      if (gameMap.isNotEmpty) {
        Map<String, dynamic> playerRecord = await generalServicePEMOM.getTrainingEmomPlayerRecords2(userID: playerOneUserID, gameRulesID: gameRulesID);
        if (GeneralService.mapHasFieldValue(playerRecord, 'emomRepGoalsEachMinute')) {
          gameMap['playerGoals'] = {playerOneUserID: [playerRecord['emomRepGoalsEachMinute'],playerRecord['emomRepGoalsEachMinute'],playerRecord['emomRepGoalsEachMinute']]};
        }

        /// get the latest max pushup count from player records and store in the game map
        // why: when a first time user visits the training landing screen, a game doc is created with a max pushup rep count of 0
        // - when the user tries to play, they will be asked to provide their max pushup score and their player records is updated with this new rep count
        // - but the game doc still has the original value of 0, so at this point, we want to get the latest value and store in game map
        // - because when the game saves, it will save this value back to the player records, which is unnecessary, so this is a check to make sure that problem does not persist
        if (GeneralService.mapHasFieldValue(playerRecord, 'maxPushupsIn60Seconds')) {
          gameMap['playerRecords']['maxPushupsIn60Seconds'] = playerRecord['maxPushupsIn60Seconds'];
        }
      }

      /// if game map remains empty, then one does not exist for today so let's create one
      if (gameMap.isEmpty) {
        lgGameInfo = await generalServicePEMOM.createDefaultPushupEMOMGame(userID: playerOneUserID, nickname: nickname, gameRulesID: gameRulesID);
      } else {
        // a game map was found, so create the game object from this game map
        lgGameInfo = generalServicePEMOM.createGameObjectFromMap(gameMap);
      }
    } else {
      // a game map was passed in, so use that one for this game
      lgGameInfo = generalServicePEMOM.createGameObjectFromMap(gameMap);
    }

    /// Store gameID for use by the game screen
    gameID = lgGameInfo.id;

    /// Store game rules tutorial video
    tutorialVideo = lgGameInfo.gameRules['tutorialVideo'];

    /// Store get in frame tutorial video
    getInFrameVideo = lgGameInfo.gameRules['getInFrameVideo'];

    /// Store original starting pushup goal
    startingPushupGoalPerMinute = lgGameInfo.playerGoals[playerOneUserID][0];

    // Store giphy images to display at end of each round
    if (lgGameInfo.gameRules['giphyImages'] != null) {
      GeneralService.printBig('has giphy images', 'has giphy images');
      giphyImages = lgGameInfo.gameRules['giphyImages'];
    } else {
      GeneralService.printBig('no giphy images', 'no giphy images');
    }



    /// Get Competition Info of the next upcoming main event
    // why: used to get max pho bowls required to access the main event
    Map<String, dynamic> competitionInfo = await databaseServicesShared.latestCompetitionInformation(mainEventGameRulesID);
    if (GeneralService.mapHasFieldValue(competitionInfo, 'phoBowlsRequired')) {
      phoBowlsRequiredForLatestMainEventInvite = competitionInfo['phoBowlsRequired'];
    }

    /// get video that plays in the background of the rewards stage
    if (GeneralService.mapHasFieldValue(competitionInfo, 'rewardsVideo')) {
      rewardsBackgroundVideo = competitionInfo['rewardsVideo'];
    }

    /// Get total pho bowls earned by this user
    phoBowlsInventoryCount = await GeneralService.getEarnedPhoBowlsFromAllLocations(userID: playerOneUserID); // new version fetching from player inventory collection

    /// Instantiate timers now, rather than later...
    // note: if the user exits early, and the timer isn't set yet, an error will occur, so that's why they are set now
    setTimers();

    /// Preload a few of the music tracks
    introMusic = PlayAudio(audioToPlay: cIntroMusic);
    workoutMusic = PlayAudio(audioToPlay: cWorkoutMusic);
    workoutMusic01 = PlayAudio(audioToPlay: cWorkoutMusic01);
    workoutMusic02 = PlayAudio(audioToPlay: cWorkoutMusic02, volume: 100.0);

    /// Init Stage Service
    // helps build each game's stage
    stageService = StageService(
        gameScreenUISink: gameScreenUISink,
        videoPlayerControllerSink: videoPlayerControllerSink,
        cameraUIControllerSink: cameraUIControllerSink,
        buttonControllerSink: buttonControllerSink,
        loadGameStageSink: loadGameStageSink,
        fullBackground2UISink: fullBackground2UISink,
        emomTimerSink: emomTimerControllerSink,
        emomHUDControllerSink: emomHUDControllerSink,
    );

    /// Start listening for event changes
    // this listens for signals to manage what is shown on the game_screen.dart
    listenForLoadGameStageRequests();

    /// Triggers initial widgets to display on game screen
    loadGameStageSink.add(constantsPEMOM.GameStage.Start);
  }

  /// IF everything is ready, then add 'ready: true" to stream sink so the
  // UI will stop displaying "loading" and display intended UI
  loadUIOnScreen() {
    Map<String, dynamic> gameScreenWrapper = {
      'ready': true,
    };
    gameScreenWrapperSink.add(gameScreenWrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setters / Getters
  /// ***********************************************************************
  /// ***********************************************************************

  //Returns video file to play locally after recording is stopped.
  File get playbackVideo {
   return localSelfieVideoToPlay;
  }

  String get getTutorialVideoURL {
    return tutorialVideo;
  }

  int get getMaxRepsPerRound {
    return lgGameInfo.playerGoals[playerOneUserID][0];
  }

  int get getWorkoutTimerStatic {
    return cWorkoutTimer;
  }

  int get getRewards {
    return lgGameInfo.rewards;
  }

  double get getPushupScore {
    return lgGameInfo.gameScore;
  }

  int get getNewPushupGoal {
    return newPushupGoalPerMinute;
  }

  // returns the goal the user had at the start of the training session
  int get getStartingPushupGoal {
    return startingPushupGoalPerMinute;
  }

  int get getPhoBowlsRequiredForNextMainEvent {
    return phoBowlsRequiredForLatestMainEventInvite;
  }

  int get getPhoBowlsInventoryCount {
    return phoBowlsInventoryCount;
  }

  String get getRewardsBackgroundVideo {
    return rewardsBackgroundVideo;
  }

  int get getPhoBowlsEarned {
    return phoBowlsEarned;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Dispose
  /// ***********************************************************************
  /// ***********************************************************************

  /// close objects to prevent performance issues
  void dispose() {
    printBig('Gamebloc dispose called', 'TRUE');
    _loadGameStageController.close();
    _buttonController.close();
    _uiController.close();
    _videoPlayerController.close();
    _cameraUIController.close();
    introMusic.dispose();
    workoutMusic.dispose();
    workoutMusic02.dispose();
    countdownTimer.dispose();
    workoutTimer.dispose();
    _gameScreenWrapperController.close();
    _fullBackground2UIController.close();
    _videoURLController.close();
    _roundStatusController.close();
    _currentRoundRepCountController.close();
    _pushupListenerController.close();
    _emomRoundListenerController.close();
    _emomTimerController.close();
    _emomHUDController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Save Game method
  /// ***********************************************************************
  /// ***********************************************************************

  /// Execute a series of methods to properly save the game
  saveGame(constantsPEMOM.GameStage nextStageToLoad) async {
    /// Set overall game status
    // the user has submitted a video, but no score has been assigned yet
    lgGameInfo.gameStatus = constantsPEMOM.GameStatus.closed;

    /// Set the date training was completed
    // .dates is used by the external discord bot to determine what was updated last
    lgGameInfo.dates[constantsPEMOM.GameUpdateTypes.trainingCompleted] = DateTime.now();

    /// Set rewards earned an save
    lgGameInfo.rewards = gameServicePEMOM.determineEndOfGameRewards(lgGameInfo); // set so UI can access
    databaseServicesShared.updateResourcePhoBowl(lgGameInfo.userID, lgGameInfo.rewards); // save to DB (player Inventory) - new
    phoBowlsInventoryCount = phoBowlsInventoryCount + lgGameInfo.rewards; // set new pho bowls earned count
    phoBowlsEarned = lgGameInfo.rewards;

    /// Set game score earned based on performance
    lgGameInfo.gameScore = gameServicePEMOM.determinePlayerFeedbackScore(lgGameInfo);

    /// Determine player overall game outcome (success, failure)
    lgGameInfo.playerGameOutcome = gameServicePEMOM.determineTrainingGameOutcome(lgGameInfo.gameScore);

    /// Set and save new pushup count goal per minute
    newPushupGoalPerMinute = gameServicePEMOM.determinePushupCountLevelUp(lgGameInfo); // set so UI can access
    await databaseServices.updatePlayerRecordsAfterAGame(lgGameInfo, newPushupGoalPerMinute); // save to DB (playerRecords)

    /// update game doc in games collection
    await databaseServices.updateEntireGame(lgGameInfo);

    /// Trigger next stage to load
    loadNextGameStageController(nextStageToLoad);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc
  /// ***********************************************************************
  /// ***********************************************************************

  // this can be used to allow other parts of app to force a stage to display
  // to use: pass in the gameStage, and it will load that stage
  void loadNextGameStageController(constantsPEMOM.GameStage stageEvent){
    loadGameStageSink.add(stageEvent);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Successful pushup trigger
  /// ***********************************************************************
  /// ***********************************************************************

  /// Whenever there is a good rep completed, the game screen UI will call this method
  successfulPushupTrigger() {
    /// Should we count this rep? Ex. the countdown timer is currently displayed so reps shouldn't count
    // - only include reps during the play stage
    // - and only count reps if they have not exceeded their round goal
    if (countPushupsEnabled == true && lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1] <= lgGameInfo.playerGoals[playerOneUserID][currentEMOMRound - 1] - 1) {
      // play successful audio SFX
      SoundService.popBonus();

      // increment pushup count
      lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1] = lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1] + 1;

      // update UI with pushup count
      currentRoundRepCountControllerSink.add(lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1]);
    }

    /// Round Success
    /// ...did the user just meet their round goal? if so, update UI to indicate this
    if (countPushupsEnabled == true && currentEMOMRound <= maxEMOMRounds) {
      if (lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1] >= lgGameInfo.playerGoals[playerOneUserID][currentEMOMRound - 1]) {
        // set countPushupsEnabled to false so it stops recording pushup data
        // this will re-set to true when the next round starts
        countPushupsEnabled = false;

        // play SFX
        SoundService.roundSuccess();

        // update UI
        // does this do anything???
        emomRoundListenerControllerSink.add(currentEMOMRound);

        // Update round status so it displays "success" for the round
        lgGameInfo.playerGameRoundStatus = gameServicePEMOM.determineRoundStatus(roundStatusControllerSink: roundStatusControllerSink, currentEMOMRound: currentEMOMRound, maxEMOMRounds: maxEMOMRounds, lgGameInfo: lgGameInfo, playerOneUserID: playerOneUserID);
        roundStatusControllerSink.add(lgGameInfo.playerGameRoundStatus);

        /// If this was the final round, then end the game early
        // so they do not need to wait for the remainder of the time
        if (currentEMOMRound == maxEMOMRounds && triggeredOnce == false) { // if current round = round 3
          workoutTimer.setCountdownToZero(); // when count reaches 0, it will auto dispose itself and move to the next game stage passed to the timer widget
          triggeredOnce = true; // prevent this logic from triggering more than once. Why: it will force the next game stage to load several times in one second
        }
      }
    }

    /// Are they performing a pushup after they had a successful round, and the round has not ended yet?
    // play a sound effect so they know not to keep working
    // using currentEMOMRound > 0 so it does not trigger before the game has started
    if (countPushupsEnabled == false && currentEMOMRound <= maxEMOMRounds && currentEMOMRound > 0) {
      if (lgGameInfo.playerScores[playerOneUserID][currentEMOMRound - 1] >= lgGameInfo.playerGoals[playerOneUserID][currentEMOMRound - 1]) {
        SoundService.roundPerfect();
      }
    }

    /// Manage user doing a test rep
    // after successful test rep, start the countdown time
    if (checkForTestRep) {
      checkForTestRep = false; // disable this so the user can no longer trigger this logic
      SoundService.popBonus(); // play successful audio SFX
      loadNextGameStageController(stageToLoadAfterShowFormStage);
    }
  }
  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for event changes
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is called when a new event is added to eventSink of loadGgameStageSink
  /// Each stage is a section of the game experience
  // which takes parameters to load host card, display timers, display videos
  // activate the camera, activate ML stream, play/stop music, initiate saving
  // stage to load after the current stage, button information
  listenForLoadGameStageRequests() {
    loadGameStageStream.listen((constantsPEMOM.GameStage event) {
      /// ***************************************************************
      ///              STAGE: START
      /// ***************************************************************
      /// When game screen loads, then display these widgets initially

      /// Start is the first stage
      // it doesn't really display anything,
      // rather, it informs you what the first stage to display widgets, pre-load some things
      if (event == constantsPEMOM.GameStage.Start) {

        /// Pre-stage actions
        // Manage round status
        lgGameInfo.playerGameRoundStatus = gameServicePEMOM.determineRoundStatus(roundStatusControllerSink: roundStatusControllerSink, currentEMOMRound: currentEMOMRound, maxEMOMRounds: maxEMOMRounds, lgGameInfo: lgGameInfo, playerOneUserID: playerOneUserID);
        roundStatusControllerSink.add(lgGameInfo.playerGameRoundStatus); // passes to UI so it can display this information

        // manage EMOM HUD widget visibility (visible, not visible)
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 0, nextStageToLoad: constantsPEMOM.GameStage.HowToPlay);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.HowToPlay,
          buttonText: 'none',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterTrigger: false,
          moveToNextStageAfterDurationTime: 0,
        );*/
      }

      /// ***************************************************************
      ///              STAGE: How To Play
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.HowToPlay) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildIntro(repGoal: lgGameInfo.playerGoals[playerOneUserID][0])]);

        // play pushup tutorial video in full screen mode
        stageService.playNetworkVideo('pushupTutorial');

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.PositionYourPhone);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildIntro(repGoal: lgGameInfo.playerGoals[playerOneUserID][0])],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: true,
          videoToPlayNetwork: 'pushupTutorial',
          streamForMLEnabled: false,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.StartStreamWithoutRecording,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.PositionYourPhone,
          buttonText: 'Next',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
          buttonPositionTargetBottom: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Position your phone tutorial
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.PositionYourPhone) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // hide video player
        stageService.hideVideoPlayer();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildPositionYourPhone(), BuildWidgets.buildGetInFrameVideoPlayer(getInFrameVideo)]);

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.ShowForm, buttonText: 'I see my body in frame.', nextStageCameraAction: constantsPEMOM.RecordingEnum.StartStreamWithoutRecording); // Change to "CountdownStarting" when testing, back to "ShowForm" for prod //changeForProduction//

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildPositionYourPhone(), BuildWidgets.buildGetInFrameVideoPlayer(getInFrameVideo)],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.ShowForm, /// Change to "CountdownStarting" when testing, back to "ShowForm" for prod //changeForProduction//
          buttonText: 'I see my body in frame',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Get your body in frame
      /// ***************************************************************

      /*if (event == constantsPEMOM.GameStage.GetInFrame) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildGetInFrame()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.ShowForm, buttonText: 'I am in frame', nextStageCameraAction: constantsKOH.RecordingEnum.StartStreamWithoutRecording);

        myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildGetInFrame()],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.ShowForm,
          buttonText: 'I am in frame',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );
      }*/

      /// ***************************************************************
      ///              Stage: Show me your pushup form
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.ShowForm) {

        /// Pre stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // after user completes a proper rep, the game will auto move this next stage
        stageToLoadAfterShowFormStage = constantsPEMOM.GameStage.CountdownStarting;

        // Start listening for a test rep
        // - upon successful rep, the next stage will be triggered. See successfulPushupTrigger() method
        checkForTestRep = true;

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildShowMeYourForm()]);

        // hide video player
        // stageService.hideVideoPlayer();

        // set camera mode
        stageService.enableStreamForML(true);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildShowMeYourForm()],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.CountdownStarting,
          buttonText: 'My pushup form is good',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Countdown starting...
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.CountdownStarting) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // Stop listening for a test rep
        // - upon successful rep, the next stage will be triggered. See successfulPushupTrigger() method
        checkForTestRep = false;

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildCountdownStarting()]);

        // hide video player
        // stageService.hideVideoPlayer();

        // set camera mode
        // stageService.enablePhoneCamera(true);

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // play music
        stageService.playLongFormAudio(workoutMusic02);

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 3000, nextStageToLoad: constantsPEMOM.GameStage.Countdown);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildCountdownStarting()],
          audioToPlay: [workoutMusic02],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.Countdown,
          buttonText: 'Start the countdown',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterDurationTime: 3000,
          moveToNextStageAfterTrigger: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Countdown timer
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.Countdown) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        // none

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // start the countdown
        stageService.startCountdown(countdownTimer, constantsPEMOM.GameStage.Play);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [],
          countdownTimer: countdownTimer,
          workoutTimer: null,
          audioToPlay: [], // workoutMusic
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.Play,
          buttonText: 'noneCountdown',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: true,
          isRecordingIconVisible: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Play (Game Timer)
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.Play) {

        /// Pre-stage actions
        // tell user to  "GO GO GO"
        SoundService.goGoGo();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        // none

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // create a new timer because this stage will re-use this object over and over
        workoutTimer = TimerService(countdown: cWorkoutTimer);

        // increment to the next round
        currentEMOMRound = currentEMOMRound + 1;

        // start the countdown
        // - provide additional context so timer reflects the emom round
        stageService.startWorkoutTimer(workoutTimer, constantsPEMOM.GameStage.Play, maxEMOMRounds, currentEMOMRound, []);

        // inform the pushup listener the play stage is active so it starts counting pushup reps
        countPushupsEnabled = true;

        // a new round is starting so reset game screen's round pushup counter to 0
        currentRoundRepCountControllerSink.add(0);

        // Manage round status
        lgGameInfo.playerGameRoundStatus = gameServicePEMOM.determineRoundStatus(roundStatusControllerSink: roundStatusControllerSink, currentEMOMRound: currentEMOMRound, maxEMOMRounds: maxEMOMRounds, lgGameInfo: lgGameInfo, playerOneUserID: playerOneUserID);
        roundStatusControllerSink.add(lgGameInfo.playerGameRoundStatus);

        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        /*myWidgets = stageService.stageBasic(
          maxEMOMRounds: maxEMOMRounds,
          emomHUDVisibility: emomHudVisibility,
          currentEMOMRound: currentEMOMRound,
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [],
          countdownTimer: null,
          workoutTimer: workoutTimer,
          audioToPlay: [goAudio],
          audioToStop: [],
          videoToPlayLocalFileSelfie: false,
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.TimerExpires,
          repeatStageToLoad: constantsPEMOM.GameStage.Play,
          buttonText: 'noneX',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: true,
          isRecordingIconVisible: true,
          giphyImages: giphyImages,
        );*/
      }

      /// ***************************************************************
      ///              Stage: STOP / TIMER Expires
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.TimerExpires) {

        /// Pre-stage actions
        // prevent pushup listener from counting more reps
        countPushupsEnabled = false;

        // Manage round status
        // this handles the case where it looks at the final round to determine if it was a failure
        // incrementing the current round sets the current round higher than the max rounds,
        // which allows our logic to check a previous round
        currentEMOMRound = currentEMOMRound + 1;
        lgGameInfo.playerGameRoundStatus = gameServicePEMOM.determineRoundStatus(roundStatusControllerSink: roundStatusControllerSink, currentEMOMRound: currentEMOMRound, maxEMOMRounds: maxEMOMRounds, lgGameInfo: lgGameInfo, playerOneUserID: playerOneUserID);
        roundStatusControllerSink.add(lgGameInfo.playerGameRoundStatus);

        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // play some sound effects
        SoundService.timerExpires();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildGameStop()]);

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 4000, nextStageToLoad: constantsPEMOM.GameStage.Saving);

        // stop long form audio (music)
        stageService.stopLongFormAudio(workoutMusic01);

        /*/// Stage
        myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildGameStop()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [timerExpiresSFX],
          audioToStop: [workoutMusic02],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.Saving,
          buttonText: 'none',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterDurationTime: 4000,
          moveToNextStageAfterTrigger: false,
          isRecordingIconVisible: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Saving...
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.Saving) {

        /// Pre stage actions
        // Start the saving process and pass which stage should load after saving is complete
        saveGame(constantsPEMOM.GameStage.ShowAllResults);

        // play some sound effects
        SoundService.cheer();
        SoundService.trumpetSong();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildSaving()]);

        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);


        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildSaving()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [yourResultsMusic,yourResultsSFX1],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: true,
          // saveScoreCallback: saveScoreActionNew,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsPEMOM.GameStage.ShowAllResults,
          buttonText: 'none',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
          isRecordingIconVisible: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Results
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.ShowAllResults) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // determine SIFU message
        String message = BuildWidgets.determineSIFUMessageBasedOnOutcome(lgGameInfo.gameScore);

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildResults(), BuildWidgets.buildPlayerGameOutcome(message)]);

        // play SFX
        SoundService.slot1();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.Level);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildResults(), BuildWidgets.buildPlayerGameOutcome(message)],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [postGameSFX01],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.Level,
          buttonText: 'Next',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Level
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.Level) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildLevelKOH(newPushupGoalPerMinute)]);

        // play SFX
        SoundService.slot2();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.Rewards, nextStageCameraAction: constantsPEMOM.RecordingEnum.StopStreamWithoutRecording);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildLevelKOH(newPushupGoalPerMinute)],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [postGameSFX02],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.StopStreamWithoutRecording,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.Rewards,
          buttonText: 'Next',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/
      }

      /// ***************************************************************
      ///              Stage: Rewards
      /// ***************************************************************

      if (event == constantsPEMOM.GameStage.Rewards) {

        /// Pre-stage actions
        // manage EMOM HUD widget visibility
        EmomHUDWidgetVisibilityModel emomHudVisibility = gameServicePEMOM.determineEMOMHUDWidgetVisibility(event);
        stageService.updateEMOMHud(emomHudVisibility); // update game screen's EMOM HUD

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildRewards()]);

        // play SFX
        SoundService.slot3();

        // set camera mode
        stageService.enableStreamForML(false);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsPEMOM.GameStage.Exit, buttonText: 'Next Steps',);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          emomHUDVisibility: emomHudVisibility,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildRewards()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [postGameSFX03],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: false,
          nextStageCameraAction: constantsPEMOM.RecordingEnum.DoNothing,
          halfScreenVideoEnabled: true,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsPEMOM.GameStage.Exit,
          buttonText: 'Next Steps',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/
      }
    });
  }

}
