import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/judge_request_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/build_widgets_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/game/service/video_processing_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/game/service/stage_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;
import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';

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
  // To Do: game_screen switches from loading to game experience
  // gameStage.start to populate game_screen with initial widgets and play music

// then follow listenUiEventStream code
  // both methods will call the other methods in this class and other files like...
  // files in services folder: database_service, helper_functions, build_game_screen_widgets

// Player1 is the player using the app, and player2 is the opponent
// Use this point of view to understand how to handle the data and for who

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
    required this.competitionID,
    required this.cameraController,
    this.gameMap = const {},});

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  // unique game ID for each game a player starts
  // late String gameID;

  /// Get passed in parameters required for GameBloc
  // helps determine the type of game so the bloc can decide how to configure this game
  // the globals are initially populated on the game_screen.dart
  late String playerOneUserID; // this user
  late String gameRulesID;
  late String competitionID;
  late Map gameMap; // contains all fields from the game doc, and can be mapped to gameInfoKOH model

  /// Initialize other parameters
  late String nickname;
  late String gameID;

  // Instantiate general databaseServices object that contains methods to CRUD on firebase
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();

  // Instantiate services that are used in the controller
  GameServiceKOH gameServiceKOH = GameServiceKOH(); // general services
  late StageService stageService; // builds the game stages

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  // GameInfo is a replica of the game document document
  late GameModelKOH lgGameInfo;

  // For level games only: determines how data should be saved and UX logic
  bool currentPlayerIsWinner = false;

  // Contains widgets that will be added to the game UI sink
  List<Widget> myWidgets = []; // list that populates game screen dynamically

  // Store cached videos
  var cachedMovementTutorialVideo;

  // Game screen stopRecording() method will update these values to inform game bloc to move forward from the saving stage
  String videoURLtoSave = ''; // currently unused
  bool videoURLAvailable = false; // Game Screen StopRecording() method updates this when it's completed a process that needs to happen before game bloc saving can move forward

  // Declare music parameters here when you want them to be disposed when dispose() is called
  late PlayAudio introMusic;
  late PlayAudio workoutMusic;
  late PlayAudio workoutMusic01;
  late PlayAudio timerExpiresSFX;

  // Setup workout timer so they can be closed when dispose() is called
  late TimerService countdownTimer;
  late TimerService workoutTimer;
  late TimerService saveGameTimer;
  late TimerService updateGameTimer;

  ///Camera and Video Variables
  late XFile videoFile; // Stores video file after its recorded
  final CameraController cameraController;
  late VideoProcessingServiceKOH videoProcessingServiceKOH;
  late File localSelfieVideoToPlay;

  /// Misc
  late String tutorialVideo;
  late String getInFrameVideo;

  /// ***********************************************************************
  /// Game Configurations
  /// ***********************************************************************

  // Timers
  int cCountdownTimer = constantsKOH.cCountdownTimer; // pre workout countdown to start
  int cWorkoutTimer = constantsKOH.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document
  int cSaveGameTimer = 300; // max timeout (seconds) for waiting for their video to upload and return a video replay URL
  int cUpdateGameTimer = 300; // unused

  // Music
  String cIntroMusic =  'assets/audio/formula1_song_1st_half.mp3';
  String cWorkoutMusic = 'assets/audio/diggy_2017_4_song.mp3';
  String cYourResultsMusic = 'assets/audio/trumpet_songB.mp3';

  // Workout Music
  String cWorkoutMusic01 = 'assets/audio/conan01.mp3';

  // SFX
  String cTimerExpiresSFX = 'assets/audio/basketball_buzzer.mp3';
  String cGoAudio = 'assets/audio/countdown_go_beep.mp3';
  String cYourResultsSFX1 = 'assets/audio/cheer1.mp3';
  String cAllResultsSFX1 = 'assets/audio/cheer1.mp3';
  String cDrumRollSFX = 'assets/audio/SFX_drumrollB.mp3';
  String cAllResultsSFX = 'assets/audio/SFX_all_results_reveal.mp3';
  String cYouWinVoice = 'assets/audio/SFX_you_winB.mp3';
  String cYouLoseVoice = 'assets/audio/SFX_you_loseB.mp3';
  String cYouWinSFX = 'assets/audio/cheer1.mp3';
  String cYouLoseSFX = 'assets/audio/SFX_lose_laugh.mp3';
  String cUnlockLevel = 'assets/audio/SFX_unlock_levelB.mp3';

  void setTimers () {
    countdownTimer = TimerService(countdown: cCountdownTimer);
    workoutTimer = TimerService(countdown: cWorkoutTimer);
    saveGameTimer = TimerService(countdown: cSaveGameTimer);
    updateGameTimer = TimerService(countdown: cUpdateGameTimer);
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
  final _loadGameStageController = StreamController<constantsKOH.GameStage>();
  Stream<constantsKOH.GameStage> get loadGameStageStream => _loadGameStageController.stream;
  Sink<constantsKOH.GameStage> get loadGameStageSink => _loadGameStageController.sink;

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

  /// Save Score stream
  final _saveScoreController = StreamController<String>();
  Stream<String> get saveScoreControllerStream => _saveScoreController.stream;
  Sink<String> get saveScoreControllerSink => _saveScoreController.sink;

  /// Stage trigger
  // for when you need to dynamically trigger a game stage to move to the next stage
  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _fullBackground2UIController = StreamController<bool>();
  Stream<bool> get fullBackground2UIStream => _fullBackground2UIController.stream;
  Sink<bool> get fullBackground2UISink => _fullBackground2UIController.sink;

  ///VideoURL trigger
  final _videoURLController = StreamController<String>();
  Stream<String> get videoURLStream => _videoURLController.stream;
  Sink<String> get videoURLSink => _videoURLController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************
  /// This method is the starting point for all methods to start this bloc

  void preSetupGameScreen() async {
    /// get nickname
    nickname = await GeneralService.getNickname(playerOneUserID);

    /// Does a game exist for this user today yet?
    /// If game does NOT exist, create the game document
    // the home screen passes in a game map, it either has data (game exists) or isEmpty (no game)
    if (gameMap.isEmpty) {
      // no, so create a new game for the user by adding a game document to the games collection
      GameModelKOH gameInfo = await gameServiceKOH.createKingOfTheHillGame(userID: playerOneUserID, nickname: nickname, gameRulesID: gameRulesID, competitionID: competitionID);

      gameID = gameInfo.id;

      // fetch this game and store as a game map
      gameMap = gameInfo.toMap();
    }

    /// Create game object that will be referenced
    // the game object is used throughout the rest of this class
    // gameInfo is used to create / save to the game document
    lgGameInfo = gameServiceKOH.createGameObject(gameMap);

    /// Store gameID for use by the game screen
    gameID = lgGameInfo.id;

    /// Store game rules tutorial video
    tutorialVideo = lgGameInfo.gameRules['tutorialVideo'];

    /// Store get in frame tutorial video
    getInFrameVideo = lgGameInfo.gameRules['getInFrameVideo'];

    /// Instantiate timers now, rather than later...
    // note: if the user exits early, and the timer isn't set yet, an error will occur, so they are set now
    setTimers();

    /// Preload a few of the music tracks
    introMusic = PlayAudio(audioToPlay: cIntroMusic);
    workoutMusic = PlayAudio(audioToPlay: cWorkoutMusic);
    workoutMusic01 = PlayAudio(audioToPlay: cWorkoutMusic01);
    timerExpiresSFX = PlayAudio(audioToPlay: cTimerExpiresSFX);

    /// Init Stage Service
    // helps build each game's stage
    stageService = StageService(
        gameScreenUISink: gameScreenUISink,
        videoPlayerControllerSink: videoPlayerControllerSink,
        cameraUIControllerSink: cameraUIControllerSink,
        buttonControllerSink: buttonControllerSink,
        loadGameStageSink: loadGameStageSink,
        fullBackground2UISink: fullBackground2UISink,
    );

    /// Start listening for event changes
    // this listens for signals to manage what is shown on the game_screen.dart
    listenForLoadGameStageRequests();

    /// Triggers initial widgets to display on game screen
    loadGameStageSink.add(constantsKOH.GameStage.Start);
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

  /// When the user is finished playing, the video must upload and provide a videoURL
  // this value will be updated by the game screen when it becomes available
  // which is used on the bloc / controller to trigger moving to the next game stage
  // and saving this video URL to the game document
  set setVideoURL(String uploadedVideoURL){
    videoURLtoSave = uploadedVideoURL;
  }

  /// Game Screen stop recording method informs Game Bloc when an uploadURL is available
  // so that game bloc knows it can move forward from "wait while we save" message
  set updateVideoURLAvailable(bool isAvailable) {
    videoURLAvailable = isAvailable;
  }

  //Returns video file to play locally after recording is stopped.
  File get playbackVideo {
   return localSelfieVideoToPlay;
  }

  String get getTutorialVideoURL {
    return tutorialVideo;
  }



  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// close objects to prevent performance issues
  void dispose() {
    printBig('Gamebloc dispose called', 'TRUE');
    _loadGameStageController.close();
    _buttonController.close();
    _uiController.close();
    _saveScoreController.close();
    _videoPlayerController.close();
    _cameraUIController.close();
    introMusic.dispose();
    workoutMusic.dispose();
    workoutMusic01.dispose();
    countdownTimer.dispose();
    workoutTimer.dispose();
    saveGameTimer.dispose();
    updateGameTimer.dispose();
    _gameScreenWrapperController.close();
    _fullBackground2UIController.close();
    _videoURLController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Save Score methods
  /// ***********************************************************************
  /// ***********************************************************************

  saveGame(constantsKOH.GameStage nextStageToLoad) async {
    saveGameTimer.startTimer();

    saveGameTimer.timeStream.listen((int _count) async {
      // Wait until we have the URL, or saveGameTimer expires
      if (videoURLAvailable == true || _count == 1) {
        // exit saveGameTimer loop because we finally have a video URL
        saveGameTimer.cancelTimer();

        /// Save video URL to game object
        lgGameInfo.playerVideos = {playerOneUserID: videoURLtoSave};

        /// Set overall game status
        // the user has submit ted a video, but no score has been assigned yet
        lgGameInfo.gameStatus = constantsKOH.GameStatus.videoSubmitted;

        /// Set the date a video was submitted
        // this is used by the discord bot to determine what was updated last
        lgGameInfo.dates[constantsKOH.GameUpdateTypes.videoSubmitted] = DateTime.now();

        /// update game doc in games collection
        await databaseServices.updateEntireGame(lgGameInfo);

        /// add judging request
        // create judge request object from gameInfo
        JudgeRequestModelKOH judgeRequestItem = gameServiceKOH.createJudgeObject(gameInfo: lgGameInfo);
        await databaseServices.addJudgeRequest(judgeRequestItem: judgeRequestItem);

        /// Trigger next stage to load
        // stageSink.add(true);
        loadNextGameStageController(constantsKOH.GameStage.NextSteps);

      } // end if statement
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// TBD
  /// ***********************************************************************
  /// ***********************************************************************


  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for event changes
  /// ***********************************************************************
  /// ***********************************************************************
  /// King of the Hill stages (each section of the game xp)

  // this can be used to allow other parts of app to force a stage to display
  // to use: pass in the gameStage, and it will load that stage
  void loadNextGameStageController(constantsKOH.GameStage stageEvent){
    loadGameStageSink.add(stageEvent);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Camera Methods
  /// for Scoring:
  /// - Record,
  /// - Stop Recording to Process video,
  /// - ML method not handled in the gameBloc for now.
  /// ***********************************************************************
  /// ***********************************************************************

  ///Main Method to determine what camera action to use

  void manageCameraAction (cameraRecordAction) {
    if (cameraRecordAction == constantsKOH.RecordingEnum.StartRecording) {
      startRecordingButtonAction();
    }

    if (cameraRecordAction == constantsKOH.RecordingEnum.StopRecording) {
      stopRecordingButtonAction();
    }
  }

  ///Starts video recording
  void startRecordingButtonAction() async {

    try {
      await cameraController.startVideoRecording();

      printBig('gameBloc: video recording starting', 'true');
    } catch (e) {
      printBig('gameBloc: video recording starting error...', 'true');
      print(e);
    }
  }

  Future <void> stopRecordingButtonAction() async {
    videoProcessingServiceKOH = VideoProcessingServiceKOH(gameID: gameID, playerOneUserID: playerOneUserID,cameraController: cameraController, videoURLSink: videoURLSink);

    ///Video Upload Process
    videoFile = await videoProcessingServiceKOH.generateVideoUploadFile();
    localSelfieVideoToPlay = await videoProcessingServiceKOH.generateVideoPlaybackFile(videoFile);
    await videoProcessingServiceKOH.saveVideoRecord(videoFile);
    await videoProcessingServiceKOH.videoUpload(videoFile);

    videoURLStream.listen((event) {
      videoURLtoSave = event;
      updateVideoURLAvailable = true;
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for event changes
  /// ***********************************************************************
  /// ***********************************************************************

  /// King of the Hill stages
  // - what to do / how to win / pushup tutorial (video, next button)
  // - position your phone (camera, next button)
  // - get your body in frame (MLStream, auto next --> inframe --> auto next)
  // - show a test rep (MLStream, auto next --> correct --> auto next next)
  // - countdown starting (camera, auto next --> 2 seconds
  // - 10s countdown timer (camera, auto next --> 10s)
  // - 60s workout timer, GO (camera, auto next --> 60s)
  // - celebration dance time (camera, auto next --> 10s)
  // - next steps (video, next button)

  /// This is called when a new event is added to eventSink of loadGgameStageSink
  /// Each stage is a section of the game experience
  // which takes parameters to load host card, display timers, display videos
  // activate the camera, activate ML stream, play/stop music, initiate saving
  // stage to load after the current stage, button information
  listenForLoadGameStageRequests() {
    loadGameStageStream.listen((constantsKOH.GameStage event) {
      /// ***************************************************************
      ///              STAGE: START
      /// ***************************************************************
      /// When game screen loads, then display these widgets initially

      /// Start is the first stage
      // it doesn't really display anything,
      // rather, it informs you what the first stage to display widgets, pre-load some things
      if (event == constantsKOH.GameStage.Start) {

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 0, nextStageToLoad: constantsKOH.GameStage.HowToPlay);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: false,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.HowToPlay,
          buttonText: 'none',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterTrigger: false,
          moveToNextStageAfterDurationTime: 0,
        );*/

      }

      /// ***************************************************************
      ///              STAGE: How To Play
      /// ***************************************************************

      if (event == constantsKOH.GameStage.HowToPlay) {

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildIntro()]);

        // play pushup tutorial video in full screen mode
        stageService.playNetworkVideo('pushupTutorial');

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsKOH.GameStage.PositionYourPhone);
      }

      /// ***************************************************************
      ///              Stage: Position your phone tutorial
      /// ***************************************************************

      if (event == constantsKOH.GameStage.PositionYourPhone) {

        // hide video player
        stageService.hideVideoPlayer();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildPositionYourPhone(), BuildWidgets.buildGetInFrameVideoPlayer(getInFrameVideo)]);

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsKOH.GameStage.CountdownStarting, buttonText: 'Yes. Start countdown.');

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildPositionYourPhone(), BuildWidgets.buildGetInFrameVideoPlayer(getInFrameVideo)],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsKOH.GameStage.CountdownStarting,
          buttonText: 'Yes. Start countdown.',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Get your body in frame
      /// ***************************************************************

      if (event == constantsKOH.GameStage.GetInFrame) {

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildGetInFrame()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsKOH.GameStage.ShowForm, buttonText: 'I am in frame', nextStageCameraAction: constantsKOH.RecordingEnum.StartStreamWithoutRecording);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildGetInFrame()],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsKOH.RecordingEnum.StartStreamWithoutRecording,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsKOH.GameStage.ShowForm,
          buttonText: 'I am in frame',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Show me your pushup form
      /// ***************************************************************

      if (event == constantsKOH.GameStage.ShowForm) {

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildShowMeYourForm()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enableStreamForML(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsKOH.GameStage.CountdownStarting, buttonText: 'My pushup form is good', nextStageCameraAction: constantsKOH.RecordingEnum.StopStreamWithoutRecording);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildShowMeYourForm()],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: true,
          cameraEnabled: false,
          nextStageCameraAction: constantsKOH.RecordingEnum.StopStreamWithoutRecording,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsKOH.GameStage.CountdownStarting,
          buttonText: 'My pushup form is good',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Countdown starting...
      /// ***************************************************************

      if (event == constantsKOH.GameStage.CountdownStarting) {

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildCountdownStarting()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 3000, nextStageToLoad: constantsKOH.GameStage.Countdown);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildCountdownStarting()],
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.StartRecording,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.Countdown,
          buttonText: 'Start the countdown',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterDurationTime: 3000,
          moveToNextStageAfterTrigger: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Countdown timer
      /// ***************************************************************



      if (event == constantsKOH.GameStage.Countdown) {

        // start recording
        manageCameraAction(constantsKOH.RecordingEnum.StartRecording);

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        // none

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // display recording icon
        stageService.enableRecordingIcon(true);

        // start the countdown
        stageService.startCountdown(countdownTimer, constantsKOH.GameStage.Play);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [],
          countdownTimer: countdownTimer,
          workoutTimer: null,
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.Play,
          buttonText: 'noneCountdown',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: true,
          isRecordingIconVisible: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Play (Game Timer)
      /// ***************************************************************

      if (event == constantsKOH.GameStage.Play) {

        // play some sound effects
        SoundService.goGoGo();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        // none

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // display recording icon
        stageService.enableRecordingIcon(true);

        // start the countdown
        stageService.startWorkoutTimer(workoutTimer);

        // play long form audio (music)
        stageService.playLongFormAudio(workoutMusic01);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [],
          countdownTimer: null,
          workoutTimer: workoutTimer,
          audioToPlay: [workoutMusic01],
          audioToStop: [],
          videoToPlayLocalFileSelfie: false,
          videoPlayerEnabled: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.TimerExpires,
          buttonText: 'noneX',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: true,
          isRecordingIconVisible: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: STOP / TIMER Expires
      /// ***************************************************************

      if (event == constantsKOH.GameStage.TimerExpires) {

        // play some sound effects
        SoundService.timerExpires();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildGameStop()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 4000, nextStageToLoad: constantsKOH.GameStage.CelebrationDance);

        // display recording icon
        stageService.enableRecordingIcon(true);

        // stop long form audio (music)
        stageService.stopLongFormAudio(workoutMusic01);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildGameStop()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [],
          audioToStop: [workoutMusic01],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.CelebrationDance,
          buttonText: 'none',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterDurationTime: 4000,
          moveToNextStageAfterTrigger: false,
          isRecordingIconVisible: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: End of game celebration
      /// ***************************************************************

      if (event == constantsKOH.GameStage.CelebrationDance) {

        // play some sound effects
        SoundService.cheer();
        SoundService.trumpetSong();

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildEndGameCelebrationDance()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // move to next stage after x seconds
        stageService.moveToNextStageAfterDuration(duration: 5000, nextStageToLoad: constantsKOH.GameStage.Saving);

        // display recording icon
        stageService.enableRecordingIcon(true);

        // stop long form audio (music)
        stageService.stopLongFormAudio(workoutMusic01);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildEndGameCelebrationDance()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.StopRecording,
          savingEnabled: false,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.Saving,
          buttonText: 'Stop Recording',
          moveToNextStageAfterDuration: true,
          moveToNextStageAfterTrigger: false,
          moveToNextStageAfterDurationTime: 5000,
          isRecordingIconVisible: true,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Saving...
      /// ***************************************************************

      if (event == constantsKOH.GameStage.Saving) {

        // stop recording
        manageCameraAction(constantsKOH.RecordingEnum.StopRecording);

        // Start the saving process
        // once complete, will move to the next game stage provided
        saveGame(constantsKOH.GameStage.NextSteps);

        // play some sound effects
        // none

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildSaving()]);

        // hide video player
        stageService.hideVideoPlayer();

        // set camera mode
        stageService.enablePhoneCamera(true);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: false);

        // display recording icon
        stageService.enableRecordingIcon(false);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildSaving()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: false,
          videoToPlayLocalFileSelfie: false,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: true,
          // saveScoreCallback: saveScoreActionNew,
          moveToNextStageWithButton: false,
          nextStageToLoad: constantsKOH.GameStage.NextSteps,
          buttonText: 'none',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
          isRecordingIconVisible: false,
        );*/

      }

      /// ***************************************************************
      ///              Stage: Next Steps (EXIT after this)
      /// ***************************************************************

      if (event == constantsKOH.GameStage.NextSteps) {

        // play some sound effects
        // none

        // clear host chat widgets, returns an empty array
        stageService.clearHostChatWidgets();

        // display host chat cards
        stageService.displayHostChatCards([BuildWidgets.buildNextStepsKOH()]);

        // display video player and play the just recorded video
        stageService.playSelfieVideo();

        // set camera mode
        stageService.enablePhoneCamera(false);

        // display one button that will load the next stage, default button text is 'Next'
        stageService.displayButton(display: true, nextStageToLoad: constantsKOH.GameStage.Exit, buttonText: 'Exit');

        // display recording icon
        stageService.enableRecordingIcon(false);

        /*myWidgets = stageService.stageBasic(
          myCurrentDisplayingWidgets: myWidgets,
          clearWidgets: true,
          widgetsToDisplay: [BuildWidgets.buildNextStepsKOH()],
          countdownTimer: null,
          workoutTimer: null,
          audioToPlay: [],
          audioToStop: [],
          videoPlayerEnabled: true,
          videoToPlayLocalFileSelfie: true,
          videoToPlayNetwork: 'none',
          streamForMLEnabled: false,
          cameraEnabled: true,
          nextStageCameraAction: constantsKOH.RecordingEnum.DoNothing,
          savingEnabled: false,
          moveToNextStageWithButton: true,
          nextStageToLoad: constantsKOH.GameStage.Exit,
          buttonText: 'Exit the DOJO',
          moveToNextStageAfterDuration: false,
          moveToNextStageAfterTrigger: false,
        );*/
      }

    });
  }

}
