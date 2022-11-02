import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboard_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/build_widgets_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/view_replay_hud.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;


// Used to determine which widgets or actions to take place
// based on the user's location in the game
enum ViewReplayStage {
  Start,
  HowToPlay,
  Countdown,
  Play,
  PlayAndRateForm,
  TimerExpires,
  ProvideScore,
  FormResults,
  ShowAllResults,
  ConsensusReached,
  NextSteps,
  Exit,
}

class ViewReplayBloc {
  /// ***********************************************************************
  /// Matches Bloc Constructor
  /// ***********************************************************************

  ViewReplayBloc({
    required this.judgeMap,
    required this.playerOneUserID,
    required this.judgeRequestID,});

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup parameters that are passed in
  Map judgeMap;
  String playerOneUserID;
  String judgeRequestID;

  /// Instantiate DB service objects so we can perform actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// The stream returns match document from playerOne point of view
  GameServiceKOH gameServiceKOH = GameServiceKOH();

  // Contains widgets that will be added to the view replay screen UI sink
  List<Widget> myWidgets = [];

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  late GameModelKOH lgGameInfo;

  // Instantiate different timers
  late TimerService countdownTimer; // plays before the game starts
  late TimerService workoutTimer; // duration of the workout
  int cSaveGameTimer = 20; // max timeout for saving a video file, specifically, waiting for gameScreen stopRecording() method to generate an uploadURL

  // Store this user's userID and nickname
  late String userID = globals.dojoUser.uid;
  late String nickname = globals.nickname;

  // determines if a judging consensus was achieved
  bool consensus = false;
  int consensusScore = 0;

  /// ***********************************************************************
  /// ***********************************************************************
  /// View Replay Configurations
  /// ***********************************************************************
  /// ***********************************************************************

  // Consensus Count required to approve validate a game's score
  int consensusCountAppearances = 1;

  // Timers
  int cCountdownTimerDuration = constantsKOH.cCountdownTimer; // pre workout countdown to start
  int cWorkoutTimerDuration = constantsKOH.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document

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

  /// Handles incoming events to signal UI changes (ex. the UI informs the stream something has happened)
  final _eventController = StreamController<ViewReplayStage>();
  Stream<ViewReplayStage> get eventStream => _eventController.stream;
  Sink<ViewReplayStage> get eventSink => _eventController.sink;

  /// Handles what should be displayed on UI (ex. since something happened, go do something like update the UI)
  final _uiController = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiStream => _uiController.stream;
  Sink<List<Widget>> get uiSink => _uiController.sink;

  /// Manage P1 UI
  final _uiPlayerOne = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiPlayerOneStream => _uiPlayerOne.stream;
  Sink<List<Widget>> get uiPlayerOneSink => _uiPlayerOne.sink;

  /// Handle the game button's config: visibility, text, action
  final _buttonController = StreamController<Map>();
  Stream<Map> get buttonControllerStream => _buttonController.stream;
  Sink<Map> get buttonControllerSink => _buttonController.sink;

  /// Save Score stream
  final _saveScoreController = StreamController<String>();
  Stream<String> get saveScoreControllerStream => _saveScoreController.stream;
  Sink<String> get saveScoreControllerSink => _saveScoreController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup Methods
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID); // store in global variable for everywhere access

    // get the latest gameMap for this game
    Map _gameMap = await databaseService.fetchGameByID(id: judgeMap['gameID']);

    // Create gameInfo object
    lgGameInfo = gameServiceKOH.createGameObject(_gameMap);

    // set timers by passing in duration (seconds)
    setTimers(cCountdownTimerDuration, cWorkoutTimerDuration);

    // Start listening for stage events that controls what is displayed on the UI
    listenUiEventStream(lgGameInfo);

    // Start the first stage of viewReplayStages
    eventSink.add(ViewReplayStage.Start);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {
      'ready': true,
    };
    wrapperSink.add(wrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  void setTimers (int _countDownTimerDuration, int _workoutTimerDuration) {
    countdownTimer = TimerService(countdown: _countDownTimerDuration);
    workoutTimer = TimerService(countdown: _workoutTimerDuration);
  }

  void dispose() {
    printBig('dispose called on view replay bloc', 'true');
    _wrapperController.close();
    _saveScoreController.close();
    _eventController.close();
    _buttonController.close();
    _uiController.close();
    _uiPlayerOne.close();
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// Timer Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is the 10,9,8... 3,2,1 Go countdown
  /// which plays before the workout starts
  void buildCountdown({required ViewReplayStage nextStage}) {
    countdownTimer.startTimer();

    countdownTimer.timeStream.listen((int _count) {
      if (_count == 0) {
        eventSink.add(nextStage);
      } else {
        List<Widget> _myWidgets = [];
        _myWidgets.add(
          HostCard(
            headLine: 'Get Ready Countdown',
            bodyText: '$_count',
            variation: 3,
            transparency: true,
          ),
        );

        BuildWidgets.buildCountdownSFX(_count);
        uiSink.add(_myWidgets);
      }
    });
  }

  /// This is the workout timer
  void buildGameTimer({required int gameDuration, required nextStage}) {
    workoutTimer.startTimer();

    workoutTimer.timeStream.listen((int _count) {
      if (_count >= 0) {
        /// Update timer with new count
        List<Widget> _myWidgets = [];
        _myWidgets.add(ViewReplayHud(timer: _count, playerOneNickname: '${lgGameInfo.playerNicknames[lgGameInfo.userID]}'));
        uiSink.add(_myWidgets);
      }

      // && userPointOfView == UserPointOfView.Player
      if (_count <= 0) {
        eventSink.add(ViewReplayStage.TimerExpires);
      }
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Input Field
  /// ***********************************************************************
  /// ***********************************************************************

  /// Input field (saving score) onChange action
  // Add input value to Sink, where it will be stored in the game model object
  void saveScoreInputFieldAction(value) {
    saveScoreControllerSink.add(value);
  }

  /// Listen to changes on the score input field
  /// And store in the gameInfo Object
  // This is called anytime a value is added to the saveScoreControllerSink
  listenToScoreInputField() {
    saveScoreControllerStream.listen((value) {
      // store value in the game model object so we can reference it later
      dynamic repScoreInputFieldValue = value;

      // save the total score to playerScore GameInfo object
      lgGameInfo = setPlayerScoreToGameObject(lgGameInfo, repScoreInputFieldValue.toString());
    });
  }

  /// this function is passed into the score input field button onPress
  // on tap of "save score" button, the following events take place
  saveScoreButtonAction() async {
    /// User just tapped save button, so display a "Saving" or "Loading" type message
    // add to widgetList: host card with "saving video..." message
    myWidgets = [];
    myWidgets.add(BuildWidgets.buildSavingDescription());
    uiSink.add(myWidgets);

    /// has consensus score been reached?

    /// Save data
    // save a new list of judges to judges document
    // determines if consensus was met and gets that score
    // if consensus met: saves the score and updates status to closed on judging document
    // if consensus met: update game document
    // if consensus met: add leaderboard item
    await saveGameData();


    /// Was consensus met?
    if (consensus) {
      eventSink.add(ViewReplayStage.ConsensusReached);
    } else {
      eventSink.add(ViewReplayStage.NextSteps);
    }
  }

  /// ***********************************************************************
  /// Save Data for King of the Hill
  /// ***********************************************************************

  /// This houses all logic of when and where to save game data to firebase
  Future<void> saveGameData() async {
    /// Get latest judge document
    Map judgeDoc = await databaseService.getSingleJudgeDocument(id: judgeRequestID);

    /// Save judging score and this judges user ID to existing judging doc
    // get a list of the the judges who have judged so far
    Map judgeScores = Map.from(judgeDoc['judgeScores']);
    judgeScores[lgGameInfo.userID] = lgGameInfo.playerScores[lgGameInfo.userID];

    // append this new judge to this list
    judgeDoc['judges'].add(lgGameInfo.userID);

    // Save this list back to the judging doc
    databaseService.updateJudgingWithScore(
      judgeScores: judgeScores,
        judges: judgeDoc['judges'],
        id: judgeRequestID,
    );

    /// Have judges reached consensus on a score?
    // judgeScores needs to contains n scores that are the same, in order to meet consensus
    // this method determines if consensus was met, and that would be the final score
    // for now, we set to true since we only need 1 score to meet consensus
    // Map winningJudges = getWinningJudges(judgeScores); // method to obtain existing judges on this game
    consensus = true;

    /// Set the consensus score
    // no need to calculate via "winning judges" method because the first judge to add a score
    // is the one who has the final consensus score
    consensusScore = lgGameInfo.playerScores[playerOneUserID];

    /// If we have consensus, then do the following
    if (consensus) {
      // if score = consensus...
      // - then judging doc: consensus score = score
      // - then judging doc: status = closed
      databaseService.updateJudgingWithConsensus(consensusScore: consensusScore, id: judgeRequestID);

      /// Update games document
      // with new score
      // with date playerScoreUpdated
      lgGameInfo.playerScores[playerOneUserID] = consensusScore;
      lgGameInfo.gameStatus = constantsKOH.GameStatus.judgingCompleted;
      lgGameInfo.dates[constantsKOH.cPlayersScoreUpdated] = DateTime.now();

      // update game document
      databaseService.updateEntireGame(lgGameInfo);

      /// add leaderboard item
      // create leaderboard object from gameInfo
      LeaderboardModelKOH leaderboardItem = gameServiceKOH.createLeaderboardObject(gameInfo: lgGameInfo);
      databaseService.addUserToLeaderboard(leaderboardItem: leaderboardItem);

      /// add game to the player's personal records
      databaseService.savePlayerRecordsScore(gameInfo: lgGameInfo);
    }

  }

  /// ***********************************************************************
  /// Consensus Logic
  /// ***********************************************************************

  Map getWinningJudges(judgeScores) {
    // find the judgeScores that contains 3 scores that are the same
    Map groupedScores = {};

    for (var k in judgeScores.keys) {
      // print("Key : $k, value : ${judgeScores[k]}");

      // tally up number of times each number appears
      if(!groupedScores.containsKey(judgeScores[k])) {
        groupedScores[judgeScores[k]] = 1;
      } else {
        groupedScores[judgeScores[k]] +=1;
      }
    }

    // determine which number map key exceeds a count of 3
    // because that number is the correct score
    consensusScore = 0;
    for (var k in groupedScores.keys) {
      // print("Key : $k, value : ${judgeScores[k]}");
      if (groupedScores[k] >= consensusCountAppearances) {
        consensusCountAppearances = groupedScores[k];
        consensusScore = k;
        consensus = true;
      }
    }

    print(consensusScore); // this is the correct score
    print(consensusCountAppearances); // this is the number of times this score appears

    // build a map of the winning judges
    Map judgeWinners = {}; // {judgeUserID: score}
    for (var k in judgeScores.keys) {
      if (judgeScores[k] == consensusScore) {
        judgeWinners[k] = judgeScores[k];
      }

    }
    print(judgeWinners);
    return judgeWinners;
  }

  /// *********************************************************************

  GameModelKOH setPlayerScoreToGameObject(GameModelKOH gameInfo, String scoreInputFieldValue) {
    gameInfo.playerScores[gameInfo.userID] = int.parse(scoreInputFieldValue);
    return gameInfo;
  }

  /// Close the judge request status to closed, in judge collection
  void qaCloseJudgingRequest(String judgeRequestID) {
    databaseService.closeJudgingRequest(judgeRequestID, userID, nickname);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Manage game stages, what to show, and what to do on the GameScreen UI
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is called when a new event is added to eventSink of _uiController
  listenUiEventStream(GameModelKOH gameInfo) {
    eventStream.listen((ViewReplayStage event) {
      /// ***************************************************************
      ///                 STAGE: START
      /// ***************************************************************
      /// When viewReplay screen loads, start the 10s countdown timer
      if (event == ViewReplayStage.Start) {
        event = ViewReplayStage.HowToPlay;
      }

      /// ***************************************************************
      ///                STAGE: INSTRUCTIONS HOW TO PLAY
      /// ***************************************************************
      /// Stage = Game timer expires

      if (event == ViewReplayStage.HowToPlay) {
        Timer(Duration(milliseconds: 100), () {
          /// manage button visibility, text, and onPress actions

          HostCard hostCardIntro1 = HostCard(
            headLine: 'Count the number of pushup reps',
            bodyText: 'You\'ll earn 10 Dojo tokens for providing the same score as several other judges',
            transparency: true,
          );

          // default buttonConfig
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Start judging',
            'onPressButtonAction': ViewReplayStage.Countdown,
          };

          myWidgets.add(hostCardIntro1);
          uiSink.add(myWidgets);
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: COUNTDOWN
      /// ***************************************************************
      /// Stage = 10,9...3,2,1 countdown to start
      if (event == ViewReplayStage.Countdown) {

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Display the 10,9...3,2,1 countdown
        // When timer service reaches 0, it auto starts the GameStage passed into this function
        buildCountdown(nextStage: ViewReplayStage.Play);
      }

      /// ***************************************************************
      ///               STAGE: Game Timer Starts
      /// ***************************************************************
      /// Stage = Game in progress so show the game timer

      if (event == ViewReplayStage.Play) {
        /// Clear the list so the view removes previous widgets
        myWidgets = [];

        /// Display game timer
        // When timer reaches 0, it auto starts the next game stage
        // passes gameDuration so it knows when to show GO GO GO message
        // passes Game stage to load when timer reaches 0
        buildGameTimer(gameDuration: cWorkoutTimerDuration, nextStage: ViewReplayStage.TimerExpires);
      }

      /// ***************************************************************
      ///                STAGE: PLAY TIMER EXPIRES
      /// ***************************************************************
      /// Stage = Game timer expires

      if (event == ViewReplayStage.TimerExpires) {
        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions

          // default buttonConfig
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Next',
            'onPressButtonAction': ViewReplayStage.ProvideScore,
          };

          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Collect Score Input field
      /// ***************************************************************
      if (event == ViewReplayStage.ProvideScore) {

        /// start listening to the score input field values
        listenToScoreInputField();

        /// clear the list so the view removes previous widgets
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(BuildWidgets.buildSaveScoreDescription());

          /// Display Save score form and button with actions
          myWidgets.add(BuildWidgets.buildSaveGameScoreForm(saveScoreInputFieldAction,saveScoreButtonAction));

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });
      }

      /// ***************************************************************
      ///                STAGE: Consensus reached
      /// ***************************************************************
      if (event == ViewReplayStage.ConsensusReached) {

        /// Clear widgets from game screen
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Build host chat cards and display on UI
        int timerDuration = 500;
        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(BuildWidgets.buildJudgeConsensusReached());

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage button visibility and text
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': ViewReplayStage.Exit,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Next Steps
      /// ***************************************************************
      /// Stage = Let the player what they should do next
      if (event == ViewReplayStage.NextSteps) {

        /// Clear widgets from game screen
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Build host chat cards and display on UI
        int timerDuration = 500;
        /// Collect players rep count
        Timer(Duration(milliseconds: 500), () {
          myWidgets.add(BuildWidgets.buildJudgeNextSteps());

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: timerDuration), () {
          /// Manage button visibility and text
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': ViewReplayStage.Exit,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

    });
  }
}