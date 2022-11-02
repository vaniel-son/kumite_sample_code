import 'dart:async';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/game_modes/training_emom/widgets/timer_card.dart';
import 'package:flutter/material.dart';

/// The service returns widgets with content
/// They sometimes have some logic to process before returning the widget
class BuildWidgets {
  static void addWidgetsToScreen(List listOfWidgetsToAddToCurrentlyDisplayingWidgets, myWidgets, gameScreenUISink){
    /// Build host chat cards and display on UI
    int timerDuration = 750;

    // loop to display each widget
    listOfWidgetsToAddToCurrentlyDisplayingWidgets.forEach((element) {
      Timer(Duration(milliseconds: timerDuration), () {
        // Add to List, which this list will be cycled through and displayed on the UI
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
  ///  Game Screen - Host (SIFU) messages
  /// ***************************************************************
  /// ***************************************************************

  static List buildIntro({required int repGoal}) {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLine: 'HOW TO PLAY',
      bodyText: 'Win by performing $repGoal pushups at the start of each minute.',
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

    // double width = MediaQuery.of(context).size.width * .36;
    // double height = MediaQuery.of(context).size.height * .36
    Widget resizedVideoPlayer = SizedBox(width:175, height:200, child: videoPlayer);

    videoPlayers.add(resizedVideoPlayer);
    return videoPlayers;
  }

  static List buildShowMeYourForm() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Perform one high quality pushup, and I will start the game countdown.',
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

  static List buildResults() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLineVisibility: false,
      bodyText: 'Done!',
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildRewards() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLineVisibility: false,
      bodyText: 'Based on total # of pushups, here are your PHO bowl rewards.',
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  static List buildNextStepsKOH(int newPushupGoalPerMinute) {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Excellent work today. You are now level $newPushupGoalPerMinute. \n\nCome back and train tomorrow.',
      headLineVisibility: false,
      transparency: true,
    );

    HostCard hostCard2 = HostCard(
      bodyText: 'The main event is coming up so you must continue to improve your pushup mastery.',
      headLineVisibility: false,
      transparency: true,
    );

    hostCards.add(hostCard1);
    hostCards.add(hostCard2);

    return hostCards;
  }

  static List buildLevelKOH(int newPushupGoalPerMinute) {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Excellent work.',
      headLineVisibility: false,
      transparency: true,
    );

    HostCard hostCard2 = HostCard(
      bodyText: 'Check out your goal for tomorrow.',
      headLineVisibility: false,
      transparency: true,
    );

    hostCards.add(hostCard1);
    hostCards.add(hostCard2);

    return hostCards;
  }

  static List buildPlayerGameOutcome(message) {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      headLineVisibility: false,
      bodyText: message,
      transparency: true,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Timers
  /// ***************************************************************
  /// ***************************************************************

  /// This is the 10, 9, 8, 7.... 3,2,1 countdown
  static buildCountdown(
      {
        required constantsPEMOM.GameStage nextStageToLoad,
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

        // SoundService.f1Beep();
        buildCountdownSFX(_count);
        gameScreenUISink.add(_myWidgets);
      }
    });
  }

  /// This is the 60 second workout timer
  void buildGameTimerEMOM({
    required int gameDuration,
    required constantsPEMOM.GameStage nextStageToLoad,
    required constantsPEMOM.GameStage repeatStageToLoad,
    required TimerService timer,
    required List<Widget> myCurrentDisplayingWidgets,
    required Sink loadGameStageSink,
    required Sink gameScreenUISink,
    required Sink emomTimerSink,
    required int currentEMOMRound,
    required int maxEMOMRounds,
    List giphyImages = const [],
  })
  {
    timer.startTimer();
    List<Widget> timerWidgetToDisplay = [];

    Widget giphyImage;
    Widget resizedGiphyImage;

    timer.timeStream.listen((int _count) {

      /// END OF TIMER
      if (_count == 0) { // timer has reached the end
        timerWidgetToDisplay = [];
        timerWidgetToDisplay.add(EMOMTimerCard(timer: _count));

        timer.setCountdownToZero();

        // automatically load next game stage
        if (currentEMOMRound == maxEMOMRounds) { // they just played their final round
          loadGameStageSink.add(nextStageToLoad);
        } else { // there is another round after this current one
          loadGameStageSink.add(repeatStageToLoad);
        }

      /// TIMER IS COUNTING DOWN (TIME > 0)
      } else {
        // display timer widget with new count
        timerWidgetToDisplay = []; // clear list of existing widgets in the list that display in EMOM HUD
        timerWidgetToDisplay.add(EMOMTimerCard(timer: _count));

        /// First 3 seconds of game timer, display host card saying "GO!"
        // myCurrentDisplayingWidgets = []; // clear list of existing widgets that display at top of UI
        if (_count == gameDuration + 1 || _count == gameDuration || _count == gameDuration - 1) {
          myCurrentDisplayingWidgets = []; // clear list of existing widgets that display at top of UI
          myCurrentDisplayingWidgets.add(
            HostCard(
              headLineVisibility: false,
              bodyText: 'Go!',
              transparency: true,
              variation: 3,
            ),
          );
        } else if (_count == gameDuration - 3) { // hide the GO message
          myCurrentDisplayingWidgets = []; // clear list of existing widgets that display at top of UI
        }

        /// Display a GIPHY to delight or motivate the user
        // use case: near the end of a round, display a random giphy
        if (_count == 15) {
          if (giphyImages.length > 0) { // we have images in the list!
            String? randomGiphyImage = GeneralService.getRandomItemFromThisListOfStrings(listOfStrings: giphyImages);
            if (randomGiphyImage != null) {
              giphyImage = Image.network(randomGiphyImage, fit: BoxFit.cover);
              resizedGiphyImage = Center(child: SizedBox(width:300, height:200, child: giphyImage));
              myCurrentDisplayingWidgets.add(resizedGiphyImage);
            }
          }
        }

        /// Last 3 seconds of game timer, play SFX
        // why: informs player that they should get ready to play again soon
        if (_count == 3 || _count == 2 || _count == 1) {
          myCurrentDisplayingWidgets = [];
          SoundService.f1Beep();
        }

        /// Display widgets on UI
        emomTimerSink.add(timerWidgetToDisplay); // displays in bottom of UI in the EMOM HUD
        gameScreenUISink.add(myCurrentDisplayingWidgets); // displays at top of UI
      }
    });
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Misc Copy
  /// ***************************************************************
  /// ***************************************************************

  static String determineSIFUMessageBasedOnOutcome(pushupScore){
    String message = 'You must always train harder';
    if (pushupScore == 100) {
      message = 'Perfect!';
    } else if (pushupScore < 100 && pushupScore >= 90) {
      message = 'Superb training day!';
    } else if (pushupScore < 100 && pushupScore >= 90) {
      message = 'Excellent training day.';
    } else if (pushupScore < 90 && pushupScore >= 80) {
      message = 'Good training day.';
    } else if (pushupScore < 80 && pushupScore >= 70) {
      message = 'Good, but can be better.';
    } else if (pushupScore < 70 && pushupScore >= 60) {
      message = 'You will need a lot of training to meet my standards';
    } else if (pushupScore < 60 && pushupScore >= 50) {
      message = 'You will need a lot of training to meet my standards.';
    } else if (pushupScore < 50 && pushupScore >= 10) {
      message = 'You will need a lot of training to meet my standards.';
    } else if (pushupScore < 10) {
      message = 'You did not try. I may have to reconsider you as my pupil.';
    }
    return message;
  }

  /// ***************************************************************
  /// ***************************************************************
  ///  Shared between game screen and judge view replay
  /// ***************************************************************
  /// ***************************************************************

  static List buildSaving() {
    List hostCards = [];

    HostCard hostCard1 = HostCard(
      bodyText: 'Saving your results...',
      headLineVisibility: false,
      transparency: true,
      variation: 4,
    );

    hostCards.add(hostCard1);

    return hostCards;
  }

  /// play countdown SFX only on last 5 seconds of countdown
  static void buildCountdownSFX(_countdown) {
    switch (_countdown) {
      case 5:
        {
          SoundService.f1Beep();
        }
        break;

      case 4:
        {
          SoundService.f1Beep();
        }
        break;

      case 3:
        {
          SoundService.countdownThree();
          SoundService.f1Beep();
        }
        break;

      case 2:
        {
          SoundService.countdownTwo();
          SoundService.f1Beep();
        }
        break;

      case 1:
        {
          SoundService.countdownOne();
          SoundService.f1Beep();
        }
        break;

      default:
        {
          print("count: $_countdown");
        }
        break;
    }
  }

  /// play countdown SFX on every count
  static void buildCountdownSFX2(_countdown) {

    PlayAudio countdownBeep = PlayAudio(audioToPlay: 'assets/audio/f1_beep.mp3');
    countdownBeep.play();
  }


}