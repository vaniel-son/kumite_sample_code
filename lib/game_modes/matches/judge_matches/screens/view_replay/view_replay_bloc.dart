import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2.dart';
import 'package:dojo_app/game_modes/matches/models/game_model2_extras.dart';
import 'package:dojo_app/game_modes/matches/screens/game/build_game_screen_widgets.dart';
import 'package:dojo_app/game_modes/matches/services/database_service_matches.dart';
import 'package:dojo_app/game_modes/matches//services/helper_functions.dart' as helperMatches;
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/matches/services/game_service_matches.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/rate_form_questions.dart';
import 'package:dojo_app/widgets/view_replay_hud.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/matches/constants_matches.dart' as constantsMatches;

// Used to determine which widgets or actions to take place
// based on the user's location in the game
enum ViewReplayStage {
  Start,
  Countdown,
  Play,
  PlayAndRateForm,
  TimerExpires,
  ProcessAndSave,
  FormResults,
  SubScores,
  ShowAllResults,
  Exit,
}

class ViewReplayBloc {
  /// ***********************************************************************
  /// Matches Bloc Constructor
  /// ***********************************************************************

  ViewReplayBloc({
    required this.gameMap,
    required this.gameMode,
    required this.groupID,
    required this.playerOneUserID,
    required this.userPointOfView,
    required this.judgeRequestID,}) {
    /// The method kicks off a running series of methods to set this page up
    setupViewReplayScreen();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  Map gameMap;
  String gameMode;
  String groupID;
  String playerOneUserID;
  constantsMatches.UserPointOfViewMatches userPointOfView;
  String judgeRequestID;

  /// Instantiate DB service objects so we can perform actions from a consolidated file
  DatabaseServicesMatches databaseService = DatabaseServicesMatches();

  /// The stream returns match document from playerOne point of view
  late Stream<QuerySnapshot> _matchesStream;
  GameServiceMatches matchService = GameServiceMatches();

  // Contains widgets that will be added to the view replay screen UI sink
  List<Widget> myWidgets = [];

  // GameInfo contains game related info (ex. player names, scores, title, etc)
  // cGameInfo is for higher level scope access
  late GameModel2 lgGameInfo;
  late GameModel2Extras lgGameInfoExtras;

  // Setup workout timer so they can be closed when dispose() is called
  late TimerService countdownTimer;
  late TimerService workoutTimer;

  // Store this user's userID and nickname
  late String userID = globals.dojoUser.uid;
  late String nickname = globals.nickname;

  // Manage if a judge is done answering all questions
  bool playerOneHasBeenJudged = false;
  bool playerTwoHasBeenJudged = false;

  // Setup other variables
  late String playerTwoUserID;
  int qaFormIndex = 0; // manage which form question to display
  int qaSetCount = 0; // for judges, manage when to display the next set of questions
  int qaQuestionsPerSet = 2; // how many questions are there for each set of questions?

  /// ***********************************************************************
  /// ***********************************************************************
  /// View Replay Configurations
  /// ***********************************************************************
  /// ***********************************************************************

  // Timers
  int cCountdownTimer = constantsMatches.cCountdownTimer; // pre workout countdown to start
  int cWorkoutTimer = constantsMatches.cWorkoutTimer; // workout duration. this should be refactored to dynamically obtain the time from the gameRules document

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

  /// Contains all match details from database
  Stream<QuerySnapshot> get matchesStream => _matchesStream;

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

  /// Manage P2 UI
  final _uiPlayerTwo = StreamController<List<Widget>>();
  Stream<List<Widget>> get uiPlayerTwoStream => _uiPlayerTwo.stream;
  Sink<List<Widget>> get uiPlayerTwoSink => _uiPlayerTwo.sink;

  /// Handle the game button's config: visibility, text, action
  final _buttonController = StreamController<Map>();
  Stream<Map> get buttonControllerStream => _buttonController.stream;
  Sink<Map> get buttonControllerSink => _buttonController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupViewReplayScreen() async {
    setTimers(cCountdownTimer, cWorkoutTimer);

    // Get opponentUserID;
    playerTwoUserID = helperMatches.getOpponentUserID(gameMap, playerOneUserID);

    // Create gameInfo object
    //lgGameInfo = matchService.createGameObject(gameMap);
    // lgGameInfoExtras = matchService.createGameExtrasObject(gameMap, playerOneUserID, playerTwoUserID);

    // Start listening for stage events that controls what is displayed on the UI
    listenUiEventStream(lgGameInfo, lgGameInfoExtras);

    // Start the first stage of viewReplayStages
    eventSink.add(ViewReplayStage.Start);
  }

  void setTimers (int _countDownTimer, int _workoutTimer) {
    countdownTimer = TimerService(countdown: _countDownTimer);
    workoutTimer = TimerService(countdown: _workoutTimer);
  }

  void dispose() {
    printBig('dispose called on view replay bloc', 'true');
    _eventController.close();
    _buttonController.close();
    _uiController.close();
    _uiPlayerOne.close();
    _uiPlayerTwo.close();
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

        buildCountdownSFX(_count);
        uiSink.add(_myWidgets);
      }
    });
  }

  /// This is the workout timer
  void buildGameTimer({required int gameDuration, required nextStage}) {
    workoutTimer.startTimer();

    workoutTimer.timeStream.listen((int _count) {
      if (_count >= 0) {
        /// Begin displaying questions
        if (_count == cWorkoutTimer - 3) {
          eventSink.add(ViewReplayStage.PlayAndRateForm);
        }

        /// Update timer with new count
        List<Widget> _myWidgets = [];
        _myWidgets.add(ViewReplayHud(timer: _count, playerOneNickname: '${lgGameInfo.playerNicknames[lgGameInfoExtras.playerOneUserID]}', playerTwoNickname: '${lgGameInfo.playerNicknames[lgGameInfoExtras.playerTwoUserID]}'));
        uiSink.add(_myWidgets);

      }

      /// When time reaches 0, only move forward to the desired next stage if this is the player viewing it
      // otherwise, the displayQuestion method handles moving forward to the next stage (saving and processing)
      if (_count <= 0 && userPointOfView == constantsMatches.UserPointOfViewMatches.Player) {
        eventSink.add(nextStage);
      }
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Question / Judging Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// display questions based on the current questionIndex
  /// When user has answered the final question of this set of questions, save the file
  /// and move to the next game stage
  void displayQuestion({required List questionsForPlayer, required int qJudgeFormQuestionIndex, required String userID, required ViewReplayStage nextStage, required String playerNickname, required int questionPosition}){
    // Initialize list and start empty
    List<Widget>_myWidgets = [];

    if (qJudgeFormQuestionIndex < questionsForPlayer.length) {
      if (questionsForPlayer[qJudgeFormQuestionIndex] != null) {
        _myWidgets.add(
          RateFormQuestions(
            title: 'Rate $playerNickname\'s ${questionsForPlayer[qJudgeFormQuestionIndex]['shortDescription']}',
            question: '${questionsForPlayer[qJudgeFormQuestionIndex]['question']}',
            playerUserID: userID,
            answerOptions: questionsForPlayer[qJudgeFormQuestionIndex]['answerOptions'],
            saveButtonAction: qaFormButtonAction,
            questionIndex: qJudgeFormQuestionIndex,
          ),
        );

        /// Display the question overlaid on which player video?
        if (questionPosition == 1) {
          uiPlayerOneSink.add(_myWidgets);
        } else if (questionPosition == 2) {
          uiPlayerTwoSink.add(_myWidgets);
        }

      }
    } else if (qJudgeFormQuestionIndex == questionsForPlayer.length) {
      /// User has reached end of questions

      /// Only move to next stage if both question sets are complete
      // determine which player has been fully judged
      if (questionPosition == 1) {
        playerOneHasBeenJudged = true;
      } else if (questionPosition == 2) {
        playerTwoHasBeenJudged = true;
      }

      // move forward only if both players have been judged
      if (playerOneHasBeenJudged & playerTwoHasBeenJudged) {
        eventSink.add(nextStage);
      }

    }
  }

  /// Upon pressing one of the question buttons, the following events occur
  void qaFormButtonAction(String userID, int buttonQuestionIndex, int answer) {
    // save game to gameInfo object so we can save to DB at a later point in time
    lgGameInfo.questions['form'][userID][buttonQuestionIndex]['answer'] = answer;

    // Increment this counter, which manages # of answered questions per question SET
    // note: currently, there are 2 questions per question set (the same question asked to player 1 and player 2)
    qaSetCount++;

    /// increment so the next question will be displayed
    // for a PLAYER, one question is asked at a time
    // for a JUDGE, both questions are displayed and both must be answered before moving forward to see the next set of questions
    if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
      // check if both questions have answers, if so, then increment to display the next set of questions
      // String otherPlayerUserID = getOpponentUserID2(cGameInfo, userID);
      if (qaSetCount % qaQuestionsPerSet == 0) {
        /// qaSetCount is the # of questions answered in the set so far
        /// qaQuestionsPerSet is the # of questions per set (ex. 2)
        /// if both questions have been answered in the set, then we can proceed to display the next set of questions

        // increment question index to inform which question to display next
        qaFormIndex++;

        // Show next question on UI
        eventSink.add(ViewReplayStage.PlayAndRateForm);
      } else {
        // the judge hasn't finished answering all questions in a set
        // so clear the question they just answered while we wait
        // for the remaining question in the set to be answered
        if (userID == playerOneUserID) {
          uiPlayerOneSink.add(<Widget>[]);
        } else if (userID == playerTwoUserID) {
          uiPlayerTwoSink.add(<Widget>[]);
        }
      }
    }
  }

  /// Update gameInfo object with 3rd party judge 'signature'
  GameModel2 qaUpdateJudgingRequest(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
    if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
      gameInfo.judging['nickname'] = nickname;
      gameInfo.judging['userID'] = userID;
      gameInfo.judging['dateUpdated'] = DateTime.now();
      gameInfo.dates[constantsMatches.cJudgingUpdated] = DateTime.now();

      // update judging request to closed only if this is a judge who has completed judging
      gameInfo.judging['status'] = constantsMatches.cGameStatusSecondaryJudgeClosed;
    }

    return gameInfo;
  }

  /// Save answers to match document, for both players, in match collection
  Future<void> qaSaveFormAnswers(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) async {
    /// update match document
    // databaseService.updateMatches(gameInfo, gameInfoExtras);

    /// in matchesAll collection, update match document
    // databaseService.updateMatchesFlat(gameInfo, gameInfoExtras);
  }

  /// Processes the points to deduct based on their form judgement
  GameModel2 processFormPointsToDeduct({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}){
    int playerOneFormPointsToDeduct = 0;
    int playerTwoFormPointsToDeduct = 0;

    /// Determine amount of points to deduct
    // playerOneFormPointsToDeduct = matchService.calculateFormPointsToDeduct(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, userID: gameInfoExtras.playerOneUserID);
    // playerTwoFormPointsToDeduct = matchService.calculateFormPointsToDeduct(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, userID: gameInfoExtras.playerTwoUserID);

    /// Deduct the points from their total score
    // the service will add the sub score to the game info object
    // then tally up new totalScore and save to game info object
    //gameInfo = matchService.processPlayerSubScores(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, userID: playerOneUserID, subScoreType: constants.cSubScoreTypeForm, points: playerOneFormPointsToDeduct, saveMatch: false);
    //gameInfo = matchService.processPlayerSubScores(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, userID: playerTwoUserID, subScoreType: constants.cSubScoreTypeForm, points: playerTwoFormPointsToDeduct, saveMatch: false);

    return gameInfo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Manage game stages, what to show, and what to do on the GameScreen UI
  /// ***********************************************************************
  /// ***********************************************************************

  /// This is called when a new event is added to eventSink of _uiController
  listenUiEventStream(GameModel2 gameInfo, GameModel2Extras gameInfoExtras) {
    eventStream.listen((ViewReplayStage event) {
      /// ***************************************************************
      ///                 STAGE: START
      /// ***************************************************************
      /// When viewReplay screen loads, start the 10s countdown timer
      if (event == ViewReplayStage.Start) {
        event = ViewReplayStage.Countdown;
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
        buildGameTimer(gameDuration: cWorkoutTimer, nextStage: ViewReplayStage.TimerExpires);
      }

      /// ***************************************************************
      ///           STAGE: Ask form judgement questions
      /// ***************************************************************

      if (event == ViewReplayStage.PlayAndRateForm) {
        /// Clear the list so the view removes previous widgets
        myWidgets = [];
        uiPlayerOneSink.add(myWidgets);
        uiPlayerTwoSink.add(myWidgets);

        /// Display judge FORM questions
        /// Players will answer the question their opponent (ex. p1 judges p2 form)
        Timer(Duration(milliseconds: 500), () {
          int _qJudgeFormIndex = qaFormIndex;

          /// Player answers the question for the other player
          /// or Judge answers the question for both players
          // this question displays on top of player 2 video
          if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
            displayQuestion(
                questionsForPlayer: lgGameInfo.questions['form'][lgGameInfoExtras.playerTwoUserID],
                qJudgeFormQuestionIndex: _qJudgeFormIndex,
                userID: lgGameInfoExtras.playerTwoUserID,
                nextStage: ViewReplayStage.ProcessAndSave,
                playerNickname: lgGameInfo.playerNicknames[lgGameInfoExtras.playerTwoUserID],
                questionPosition: 2);
          }

          /// Judge answers the question for both players
          // this question appears on top of player 1 video
          if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
            // this question displays on top of player 1 video
            // ex. and ask them to judge player 1's form
            displayQuestion(
                questionsForPlayer: lgGameInfo.questions['form'][lgGameInfoExtras.playerOneUserID],
                qJudgeFormQuestionIndex: _qJudgeFormIndex,
                userID: lgGameInfoExtras.playerOneUserID,
                nextStage: ViewReplayStage.ProcessAndSave,
                playerNickname: lgGameInfo.playerNicknames[lgGameInfoExtras.playerOneUserID],
                questionPosition: 1);
          }
        });
      }

      /// ***************************************************************
      ///                STAGE: PLAY TIMER EXPIRES
      /// ***************************************************************
      /// Stage = Game timer expires

      if (event == ViewReplayStage.TimerExpires) {
        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Show me who won',
            'onPressButtonAction': ViewReplayStage.ShowAllResults,
          };

          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Process and save data
      /// ***************************************************************

      if (event == ViewReplayStage.ProcessAndSave) {
        /// Cancel timer if it is still running
        if (workoutTimer.getRemainingTime() > 0) {
          workoutTimer.cancelTimer();
        }

        /// For judges watching and reviewing the match, these extra steps are taken
        if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
          /// Determine how many points to deduct for form
          lgGameInfo = processFormPointsToDeduct(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras);

          /// Update the judge request to closed and add signature of the user judging it
          lgGameInfo = qaUpdateJudgingRequest(lgGameInfo, lgGameInfoExtras);

          /// Store current playerGameOutcomes
          // so that we can compare to the new playerGameOutcomes to help determine
          // how we will update the win loss tie record
          Map<String, String> previousPlayerGameOutcomes = {
            '${lgGameInfoExtras.playerOneUserID}': '${lgGameInfo.playerGameOutcomes[lgGameInfoExtras.playerOneUserID]}',
            '${lgGameInfoExtras.playerTwoUserID}': '${lgGameInfo.playerGameOutcomes[lgGameInfoExtras.playerTwoUserID]}',
          };

          /// Determine playerGameOutcomes
          //  determine if currentUserID (player1) and opponentUserID (player2) has a win, lose, tie
          //lgGameInfo = matchService.setPlayerGameOutcomesToGameObject(gameInfo: lgGameInfo, gameInfoExtras: lgGameInfoExtras);

          /// Update the win loss record to reflect the new game outcomes
          // for player one
          //matchService.reCalculateWinLossRecord(gameInfo: lgGameInfo, gameInfoExtras: lgGameInfoExtras, userID: lgGameInfoExtras.playerOneUserID, previousPlayerGameOutcomes: previousPlayerGameOutcomes);
          // for player two
          //matchService.reCalculateWinLossRecord(gameInfo: lgGameInfo, gameInfoExtras: lgGameInfoExtras, userID: lgGameInfoExtras.playerTwoUserID, previousPlayerGameOutcomes: previousPlayerGameOutcomes);

          /// Update JUDGE collection so the request is closed
          // so that it does not show up on the judging screen as a clickable item to judge
          databaseService.closeJudgingRequest(judgeRequestID, userID, nickname);
        }

        /// Save data to firebase (match document)
        qaSaveFormAnswers(lgGameInfo, lgGameInfoExtras);

        /// Manage button visibility, text, and onPress actions
        Timer(Duration(milliseconds: 1), () {
          // default buttonConfig
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Next',
            'onPressButtonAction': ViewReplayStage.ShowAllResults,
          };

          /// Display judging results instead
          if (userPointOfView == constantsMatches.UserPointOfViewMatches.Judge) {
            buttonConfig = {
              'buttonVisibility': true,
              'buttonText': 'Next',
              'onPressButtonAction': ViewReplayStage.SubScores,
            };
          }

          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Show Results of Questions
      /// ***************************************************************

      if (event == ViewReplayStage.FormResults) {
        /// Clear the main list so the view removes previous widgets (ex. timer)
        myWidgets = [];
        uiSink.add(myWidgets);

        Timer(Duration(milliseconds: 1), () {
          /// Display from question results
          myWidgets.add(buildQuestionFormResults(qJudgeForm: lgGameInfo.questions['form'] as Map, gameInfo: lgGameInfo, gameInfoExtras: lgGameInfoExtras));

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Tell me who won2',
            'onPressButtonAction': ViewReplayStage.SubScores,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Show All Sub Scores
      /// ***************************************************************

      if (event == ViewReplayStage.SubScores) {
        /// Clear the main list so the view removes previous widgets (ex. timer)
        myWidgets = [];
        uiSink.add(myWidgets);

        Timer(Duration(milliseconds: 1), () {
          /// Display from question results
          // myWidgets.add(buildScoreCard(lgGameInfo, lgGameInfoExtras));

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 1), () {
          /// manage button visibility, text, and onPress actions
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Tell me who won',
            'onPressButtonAction': ViewReplayStage.ShowAllResults,
          };
          buttonControllerSink.add(buttonConfig);
        });
      }

      /// ***************************************************************
      ///                STAGE: Show both player results
      /// ***************************************************************
      /// Stage = Show both player results

      if (event == ViewReplayStage.ShowAllResults) {
        /// Clear list so view removes previous widgets
        myWidgets = [];
        uiSink.add(myWidgets);

        /// Play both player results SFX
        PlayAudio allResultsSFX1 = PlayAudio(audioToPlay: cAllResultsSFX1);
        PlayAudio drumRollSFX = PlayAudio(audioToPlay: cDrumRollSFX);
        PlayAudio allResultsSFX = PlayAudio(audioToPlay: cAllResultsSFX);
        allResultsSFX1.play();
        drumRollSFX.play();

        Timer(Duration(milliseconds: 500), () {
          /// Explain what they are about to see
          myWidgets.add(buildAllResultsDescription());

          /// Add widgets to game screen view
          uiSink.add(myWidgets);
        });

        Timer(Duration(milliseconds: 1700), () {
          /// Play SFX
          allResultsSFX.play();
        });

        Timer(Duration(milliseconds: 2000), () {
          /// Display both player results
          myWidgets.add(buildAllResultsCardWithGameObject(lgGameInfo, lgGameInfoExtras));

          /// add widgets to game screen view
          uiSink.add(myWidgets);
        });

        /// Timer + display win or lose
        // this is only relevant if this is a player
        if (userPointOfView == constantsMatches.UserPointOfViewMatches.Player) {
          Timer(Duration(milliseconds: 3500), () {
            /// Play SFX based on win or loss
            playWinnerOrLoserSFX2(
              sfxTrackWin: cYouWinVoice,
              sfxTrackLose: cYouLoseVoice,
              playerGameOutcomes: lgGameInfo.playerGameOutcomes,
              userID: playerOneUserID,
            );

            Timer(Duration(milliseconds: 800), () {
              playWinnerOrLoserSFX2(
                  sfxTrackWin: cYouWinSFX,
                  sfxTrackLose: cYouLoseSFX,
                  playerGameOutcomes: lgGameInfo.playerGameOutcomes,
                  userID: playerOneUserID);
            });

            /// Inform the player won or lost or tie
            myWidgets.add(buildYouWinOrLoseOrTieDescription(lgGameInfo.playerGameOutcomes, lgGameInfoExtras.playerOneUserID));

            /// Add widgets to game screen view
            uiSink.add(myWidgets);
          });
        }

        /// Manage button visibility and text
        Timer(Duration(milliseconds: 3500), () {
          Map buttonConfig = {
            'buttonVisibility': true,
            'buttonText': 'Exit',
            'onPressButtonAction': ViewReplayStage.Exit,
          };
          buttonControllerSink.add(buttonConfig);
        });
      } // end if statement
      // end gameStage next steps

    });
  }
}