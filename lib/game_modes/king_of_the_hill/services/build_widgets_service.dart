import 'dart:async';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/game_score_form.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/loading_icon.dart';
import 'package:dojo_app/widgets/timer_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;

/// The service returns widgets with content
/// They sometimes have some logic to process before returning the widget


class BuildWidgets {
  static void addWidgetsToScreen(List listOfWidgetsToAddToCurrentlyDisplayingWidgets, myWidgets, gameScreenUISink){
    /// Build host chat cards and display on UI
    // List introList = buildIntro(gameInfo);

    int timerDuration = 750;

    // loop to display each widget
    listOfWidgetsToAddToCurrentlyDisplayingWidgets.forEach((element) {
      Timer(Duration(milliseconds: timerDuration), () {
        /// Remind the user what they're about to get into
        myWidgets.add(element);

        /// add widgets to sink so it appears on the game screen view
        gameScreenUISink.add(myWidgets);

      });

      // increment timer so that the widgets display with a delay one after the other
      timerDuration = timerDuration + 750;
    });
  }

  static List<Widget> clearScreenWidgets(List<Widget> myWidgets, Sink gameScreenUISink) {
    myWidgets = [];
    gameScreenUISink.add(myWidgets);
    return myWidgets;
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Game Screen / Bloc
  /// ***************************************************************
  /// ***************************************************************

  static List buildIntro() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLine: 'HOW TO PLAY',
      bodyText: 'Win by performing the most PUSHUPS in 60 seconds.',
      transparency: true,
    );

    hostCards.add(hostCard1);
    return hostCards;
  }

  static List buildPositionYourPhone() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLine: 'POSITION YOUR PHONE',
      bodyText: 'Can you see yourself in pushup position?',
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildGetInFrame() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLineVisibility: false,
      bodyText: 'Show your body fully in the camera frame',
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildGetInFrameVideoPlayer(String videoURL) {
    List videoPlayers = [];
    VideoFullScreen videoPlayer = VideoFullScreen(videoMap: {'localVideoFile': 'none'}, videoURL: videoURL, videoConfiguration: 7);

    Widget resizedVideoPlayer = SizedBox(width:200, height:225, child: videoPlayer);

    videoPlayers.add(resizedVideoPlayer);
    return videoPlayers;
  }

  static List buildShowMeYourForm() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Show me your pushup form.',
      headLineVisibility: false,
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildCountdownStarting() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'GET READY',
      headLineVisibility: false,
      transparency: true,
    );

    HostCard hostCard2 = HostCard(
      bodyText: 'Countdown starting...',
      headLineVisibility: false,
      transparency: true,
    );

    hostCards.add(hostCard1);
    hostCards.add(hostCard2);

    return hostCards;
  }

  static List buildGameStop() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
        headLineVisibility: false,
        bodyText: 'STOP!',
        transparency: true,
        variation: 3,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildEndGameCelebrationDance() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
        headLineVisibility: false,
        bodyText: 'CELEBRATE!',
        transparency: true,
        variation: 4,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildNextStepsKOH() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Excellent work! Your video has been submitted',
      headLineVisibility: false,
      transparency: true,
    );

    HostCard hostCard2 = HostCard(
      bodyText: 'Our judges are reviewing your video',
      headLineVisibility: false,
      transparency: true,
    );

    HostCard hostCard3 = HostCard(
      bodyText: 'Soon, a pushup master will be announced and rewarded.',
      headLineVisibility: false,
      transparency: true,
    );

    hostCards.add(hostCard1);
    hostCards.add(hostCard2);
    hostCards.add(hostCard3);

    return hostCards;
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Timers
  /// ***************************************************************
  /// ***************************************************************

  static buildCountdown(
      {
        required constantsKOH.GameStage nextStageToLoad,
        required TimerService timer,
        required Sink loadGameStageSink,
        required Sink gameScreenUISink,
        required List<Widget> myCurrentDisplayingWidgets,
      })

  {
    List<Widget> _myWidgets = myCurrentDisplayingWidgets;
    timer.startTimer();

    timer.timeStream.listen((int _count) {
      if (_count == 0) {
        // the timer will auto cancel

        // automatically load next game stage
        loadGameStageSink.add(nextStageToLoad);
      } else {
        _myWidgets = [];
        _myWidgets.add(
          HostCard(
            headLine: 'Get Ready Countdown',
            bodyText: '$_count',
            transparency: true,
            variation: 3,
          ),
        );

        BuildWidgets.buildCountdownSFX(_count);
        gameScreenUISink.add(_myWidgets);
      }
    });
  }

  static void buildGameTimerNew({
    required int gameDuration,
    required constantsKOH.GameStage nextStageToLoad,
    required TimerService timer,
    required List<Widget> myCurrentDisplayingWidgets,
    required Sink loadGameStageSink,
    required Sink gameScreenUISink,
  })
  {
    timer.startTimer();

    timer.timeStream.listen((int _count) {
      if (_count == 0) {
        myCurrentDisplayingWidgets = [];
        myCurrentDisplayingWidgets.add(TimerCard(timer: _count));

        // automatically load next game stage
        loadGameStageSink.add(nextStageToLoad);
      } else {
        myCurrentDisplayingWidgets = [];
        myCurrentDisplayingWidgets.add(TimerCard(timer: _count));

        /// First 3 seconds of game timer, display host card
        if (_count == gameDuration || _count == gameDuration - 1 || _count == gameDuration - 2) {
          myCurrentDisplayingWidgets.add(
            HostCard(
              headLineVisibility: false,
              bodyText: 'Go!',
              variation: 3,
              transparency: true,
            ),
          );
        }
        gameScreenUISink.add(myCurrentDisplayingWidgets);
      }
    });
  }

  /// This is the workout timer
  static buildGameTimer(
      {
        required int gameDuration,
        required constantsKOH.GameStage nextStageToLoad,
        required TimerService timer,
        required Sink loadGameStageSink,
        required Sink gameScreenUISink,
        required List<Widget> myCurrentDisplayingWidgets,
      })
  {
    List<Widget> _myWidgets = myCurrentDisplayingWidgets;
    timer.startTimer();

    timer.timeStream.listen((int _count) {
      if (_count == 0) {
        _myWidgets = [];
        _myWidgets.add(TimerCard(timer: _count));

        // automatically load next game stage
        loadGameStageSink.add(nextStageToLoad);
      } else {
        _myWidgets = [];
        _myWidgets.add(TimerCard(timer: _count));

        /// First 3 seconds of game timer, display host card
        if (_count == gameDuration || _count == gameDuration - 1 || _count == gameDuration - 2) {
          _myWidgets.add(
            HostCard(
              headLineVisibility: false,
              bodyText: 'Go!',
              variation: 3,
              transparency: true,
            ),
          );
        }
        gameScreenUISink.add(_myWidgets);
      }
    });
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Shared between game screen and judge view replay
  /// ***************************************************************
  /// ***************************************************************

  static List buildSaving() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Saving your video...',
      headLineVisibility: false,
      transparency: true,
      variation: 4,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static void buildCountdownSFX(_countdown) {
    /// play countdown SFX
    PlayAudio countdownBeep = PlayAudio(audioToPlay: 'assets/audio/f1_beep.mp3');

    switch (_countdown) {
      case 5:
        {
          countdownBeep.play();
        }
        break;

      case 4:
        {
          countdownBeep.play();
        }
        break;

      case 3:
        {
          PlayAudio countdown3 = PlayAudio(audioToPlay: 'assets/audio/countdown_3.mp3');
          countdown3.play();
          countdownBeep.play();
        }
        break;

      case 2:
        {
          PlayAudio countdown2 = PlayAudio(audioToPlay: 'assets/audio/countdown_2.mp3');
          countdown2.play();
          countdownBeep.play();
        }
        break;

      case 1:
        {
          PlayAudio countdown1 = PlayAudio(audioToPlay: 'assets/audio/countdown_1.mp3');
          countdown1.play();
          countdownBeep.play();
        }
        break;

      default:
        {
          print("count: $_countdown");
        }
        break;
    }
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Specific to Judging View Replay
  /// ***************************************************************
  /// ***************************************************************

  static Widget buildSaveScoreDescription() {
    return HostCard(
      headLine: 'Input # of Pushups',
      bodyText: 'How many reps did the player perform?',
      transparency: true,
    );
  }

  static Widget buildJudgeNextSteps() {
    return HostCard(
      headLine: 'Thank you for judging',
      bodyText: 'We need more people to judge and reach a score consensus. If your score matches what others say, then we will deposit 100 DOJO tokens into your account. We will let you know!',
      transparency: true,
    );
  }

  static Widget buildJudgeConsensusReached() {
    return HostCard(
      headLine: 'A consensus in score has been met!',
      bodyText: 'Several judges have agreed with the score you put in, so you and all the matching judges will receive 100 DOJO tokens',
      transparency: true,
    );
  }

  ///New combined form and button for saving game score.  This was done to have validation.
  static Widget buildSaveGameScoreForm(saveScoreInputFieldAction, saveScoreButtonAction) {
    return GameScoreForm(
      inputLabel: 'Completed Reps',
      saveScoreInputFieldAction: saveScoreInputFieldAction,
      keyboardType: TextInputType.number,
      title: 'SAVE REPS',
      saveScoreButtonAction: saveScoreButtonAction,

    );
  }

  static Widget buildSavingDescription() {
    return Container(
        child: Column(
          children: [
            LoadingAnimatedIcon(),
            Text('Saving results...', style: GameHostChatStyleBT1()),
          ],
        )
    );
  }

}