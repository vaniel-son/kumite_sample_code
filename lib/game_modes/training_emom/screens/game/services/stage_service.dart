import 'dart:async';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/models/emom_hud_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/services/build_widgets_service.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:dojo_app/services/timer_service.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;

class StageService{

  StageService({
    required this.gameScreenUISink,
    required this.videoPlayerControllerSink,
    required this.cameraUIControllerSink,
    required this.buttonControllerSink,
    required this.loadGameStageSink,
    required this.fullBackground2UISink,
    required this.emomTimerSink,
    required this.emomHUDControllerSink,
});

  Sink gameScreenUISink;
  Sink videoPlayerControllerSink;
  Sink cameraUIControllerSink;
  Sink buttonControllerSink;
  Sink loadGameStageSink;
  Sink fullBackground2UISink;
  Sink emomTimerSink;
  Sink<EmomHUDWidgetVisibilityModel> emomHUDControllerSink;

  List<Widget> myCurrentDisplayingWidgets = []; // contains what is currently displayed on the game screen UI
  List<Widget> myWidgets = []; // contains next set of widgets that are being built, to show next

  updateEMOMHud(EmomHUDWidgetVisibilityModel emomHUDVisibility){
    emomHUDControllerSink.add(emomHUDVisibility);
  }

  /// *******************************
  /// Host Card Chat Management
  /// *******************************

  // the receiving end of the sink (stream) displays the list of widgets
  // in this case, we are returning an empty array, which it will display no widgets
  // primarily, gameScreenUISink handles the host chat cards
  List<Widget> clearHostChatWidgets() {
    myWidgets = [];
    gameScreenUISink.add(myWidgets);
    myCurrentDisplayingWidgets = myWidgets;
    return myWidgets;
  }

  /// display widgets: host cards, small img/vid, checkmark/x, timer, countdown
  // display begins at top of screen
  // This will loop through each widget in the list, and insert a timer between each one
  // ex. if the goal is to display 2 widgets, then it would build: widget, 750s timer, widget
  // ... and then add that to the game screen so they display with pauses between each widget being displayed
  displayHostChatCards(List<dynamic> widgetsToDisplay) {
    widgetsToDisplay.forEach((element){
      int timerDuration = 750; // time between each host card displaying
      element.forEach((element) {
        Timer(Duration(milliseconds: timerDuration), () {
          // add widgets to sink so it appears on the game screen view
          myWidgets.add(element);
          gameScreenUISink.add(myWidgets);
        });

        // increment timer so that the widgets display with a delay one after the other
        timerDuration = timerDuration + 750;
      });
    });
  }

  /// *******************************
  /// Video Player Management
  /// *******************************

  /// Play network video
  void playNetworkVideo(String networkVideoToPlay) {
    videoPlayerControllerSink.add({'videoPlayerMode': networkVideoToPlay});
  }

  /// Play local video file that was just recorded
  void playSelfieVideo() {
    videoPlayerControllerSink.add({'videoPlayerMode': 'self'});
  }

  /// Hide the video player
  void hideVideoPlayer() {
    videoPlayerControllerSink.add({'videoPlayerMode': 'hidden'});
  }

  /// *******************************
  /// Button, Next Stage to load Management
  /// *******************************

  /// Displays a button on the bottom of the screen
  // required which stage to load next upon button tap
  // optional: on tap, should the camera record, stop recording, or do nothing (default)
  void displayButton({required bool display, String buttonText = 'Next', constantsPEMOM.GameStage nextStageToLoad = constantsPEMOM.GameStage.DoNothing, constantsPEMOM.RecordingEnum nextStageCameraAction = constantsPEMOM.RecordingEnum.DoNothing}) {
    late Map buttonConfig;
    if (display == true) {
      Timer(Duration(milliseconds: 1500), () {
        /// Manage game screen button settings
        buttonConfig = {
          'buttonVisibility': true,
          'buttonText': buttonText,
          'onPressButtonAction': nextStageToLoad,
          'cameraRecordAction': nextStageCameraAction,
        };
        buttonControllerSink.add(buttonConfig);
      });
    } else if (display == false) {
      buttonConfig = {
        'buttonVisibility': false,
        'buttonText': 'NEXT', // won't display
        'onPressButtonAction': constantsPEMOM.GameStage.DoNothing,
        'cameraRecordAction': constantsPEMOM.RecordingEnum.DoNothing,
      };
      buttonControllerSink.add(buttonConfig);
    }
  }

  /// After x seconds, automatically load the next stage
  moveToNextStageAfterDuration({required int duration, required constantsPEMOM.GameStage nextStageToLoad}){
    Timer(Duration(milliseconds: duration), () {
      loadGameStageSink.add(nextStageToLoad);
    });
  }

  /// *******************************
  /// Camera Management
  /// *******************************

  enableStreamForML(bool enabled) {
    if (enabled) {
      cameraUIControllerSink.add({'cameraMode': 'repCountMode'});
    } else {
      cameraUIControllerSink.add({'cameraMode': 'hidden'});
    }
  }

  enablePhoneCamera(bool enabled) {
    if (enabled) {
      cameraUIControllerSink.add({'cameraMode': 'full'});
    } else {
      cameraUIControllerSink.add({'cameraMode': 'hidden'});
    }
  }

  enableRecordingIcon(bool isRecordingIconVisible){
    if (isRecordingIconVisible == true) {
      fullBackground2UISink.add(true);
    } else {
      fullBackground2UISink.add(false);
    }
  }

  /// *******************************
  /// Timer Management
  /// *******************************

  startCountdown(countdownTimer, GameStage nextStageToLoad){
    BuildWidgets.buildCountdown(
      nextStageToLoad: nextStageToLoad, //constantsPEMOM.GameStage.Play,
      timer: countdownTimer,
      loadGameStageSink: loadGameStageSink,
      gameScreenUISink: gameScreenUISink,
      myCurrentDisplayingWidgets: myWidgets,
    );
  }

  startWorkoutTimer(workoutTimer, nextStageToLoad, maxEMOMRounds, currentEMOMRound, giphyImages){
    BuildWidgets gameTimer = BuildWidgets();
    gameTimer.buildGameTimerEMOM(
      gameDuration: constantsPEMOM.cWorkoutTimer,
      nextStageToLoad: nextStageToLoad,
      repeatStageToLoad: constantsPEMOM.GameStage.Play,
      timer: workoutTimer,
      myCurrentDisplayingWidgets: myWidgets,
      loadGameStageSink: loadGameStageSink,
      gameScreenUISink: gameScreenUISink,
      emomTimerSink: emomTimerSink,
      maxEMOMRounds: maxEMOMRounds,
      currentEMOMRound: currentEMOMRound,
      giphyImages: giphyImages,
    );
  }

  /// *******************************
  /// Audio to play
  /// *******************************

  playLongFormAudio(PlayAudio audio){
    audio.play();
  }

  stopLongFormAudio(PlayAudio audio){
    audio.stop();
  }

  /// *******************************
  /// OLD / ARCHIVED BELOW
  /// *******************************

  List<Widget> stageBasic(
  {
    required List<Widget> myCurrentDisplayingWidgets,
    required EmomHUDWidgetVisibilityModel emomHUDVisibility,
    int maxEMOMRounds = 3,
    int currentEMOMRound = 1,
    bool clearWidgets = true,
    List<dynamic> widgetsToDisplay = const [],
    List<Widget> emomHUDWidgetsToDisplay = const [],
    TimerService? countdownTimer,
    TimerService? workoutTimer,
    List<PlayAudio> audioToPlay = const [],
    List<PlayAudio> audioToStop = const [],
    bool videoPlayerEnabled = false,
    bool videoToPlayLocalFileSelfie = false,
    String videoToPlayNetwork = 'none',
    bool streamForMLEnabled = false,
    bool cameraEnabled = false,
    constantsPEMOM.RecordingEnum nextStageCameraAction = constantsPEMOM.RecordingEnum.DoNothing,
    bool savingEnabled = false,
    // required saveScoreCallback,
    bool moveToNextStageWithButton = false,
    constantsPEMOM.GameStage nextStageToLoad = constantsPEMOM.GameStage.DoNothing,
    constantsPEMOM.GameStage repeatStageToLoad = constantsPEMOM.GameStage.DoNothing,
    String buttonText = 'Next',
    bool moveToNextStageAfterDuration = false,
    bool moveToNextStageAfterTrigger = false, // unused
    int moveToNextStageAfterDurationTime = 1000, // 1 second by default
    bool isRecordingIconVisible = false,
    bool buttonPositionTargetBottom = false,
    bool halfScreenVideoEnabled = false,
    List giphyImages = const [],
  })

  {
    /// *******************************
    /// Clear Widgets currently displaying on UI?
    /// *******************************

    List<Widget> _myWidgets;
    if (clearWidgets = true) {
      _myWidgets = BuildWidgets.clearScreenWidgets(myCurrentDisplayingWidgets, gameScreenUISink);
    } else {
      _myWidgets = myCurrentDisplayingWidgets;
    }

    /// *******************************
    /// Displays widgets on top of screen UI
    /// *******************************

    /// display widgets: host cards, small img/vid, checkmark/x, timer, countdown
    // display begins at top of screen
    widgetsToDisplay.forEach((element){
      BuildWidgets.addWidgetsToScreen(element, myCurrentDisplayingWidgets, gameScreenUISink);  // add each list of widgets to the game screen
    });

    /// Display timer widget? ex. countdown, workout timer
    if (countdownTimer != null) {
      BuildWidgets.buildCountdown(
        nextStageToLoad: constantsPEMOM.GameStage.Play,
        timer: countdownTimer,
        loadGameStageSink: loadGameStageSink,
        gameScreenUISink: gameScreenUISink,
        myCurrentDisplayingWidgets: _myWidgets,
      );
    }

    /// Display timer widget? ex. countdown, workout timer
    if (workoutTimer != null) {
      BuildWidgets gameTimer = BuildWidgets();
      gameTimer.buildGameTimerEMOM(
        gameDuration: constantsPEMOM.cWorkoutTimer,
        nextStageToLoad: nextStageToLoad,
        repeatStageToLoad: constantsPEMOM.GameStage.Play,
        timer: workoutTimer,
        myCurrentDisplayingWidgets: _myWidgets,
        loadGameStageSink: loadGameStageSink,
        gameScreenUISink: gameScreenUISink,
        emomTimerSink: emomTimerSink,
        maxEMOMRounds: maxEMOMRounds,
        currentEMOMRound: currentEMOMRound,
        giphyImages: giphyImages,
      );
    }

    /// *******************************
    /// Displays on Background, Full Screen
    /// *******************************

    /// video enable? video location
    if (videoPlayerEnabled == true) {
      if (videoToPlayLocalFileSelfie == true) {
        videoPlayerControllerSink.add({'videoPlayerMode': 'self'});
      } else {
        videoPlayerControllerSink.add({'videoPlayerMode': videoToPlayNetwork});
      }
    } else {
      videoPlayerControllerSink.add({'videoPlayerMode': 'hidden'});
    }

    /// streaming enabled for ML?
    if (streamForMLEnabled == true) {
      cameraUIControllerSink.add({'cameraMode': 'repCountMode'});
    }

    /// camera enable?
    if (cameraEnabled == true) {
      cameraUIControllerSink.add({'cameraMode': 'full'});
    }

    /// disable camera mode if both are false
    if (cameraEnabled == false && streamForMLEnabled == false) {
      cameraUIControllerSink.add({'cameraMode': 'hidden'});
    }

    if (halfScreenVideoEnabled == true) {
      cameraUIControllerSink.add({'cameraMode': 'halfScreenVideoPlayer'});
    }

    /// *******************************
    /// Manage recording icon visibility
    /// *******************************

    if (isRecordingIconVisible == true) {
      fullBackground2UISink.add(true);
    } else {
      fullBackground2UISink.add(false);
    }

    /// *******************************
    /// Bottom UI: Displays EMOM HUD
    /// *******************************
    // this manages the visibility of widgets in the EMOM HUD
    // displays round statuses, timer, current pushup rep count, max pushup reps for a round
    // at the bottom of the UI screen
    emomHUDControllerSink.add(emomHUDVisibility);


    /// *******************************
    /// Audio to play
    /// *******************************

    /// play music?
    audioToPlay.forEach((PlayAudio element){
      element.play();
    });

    /// Stop music?
    audioToStop.forEach((element){
      element.stop();
    });

    /// *******************************
    /// Saving
    /// *******************************

    /// saving enabled?
    // currently, saving is handled in the gameBloc
    if (savingEnabled == true) {
      // saveScoreCallback();
    }

    /// *******************************
    /// Getting to the next Game Stage
    /// *******************************
    // Button Displays @ bottom of screen
    // or no button is displayed, instead, stage auto moves forward after X duration
    // or all are false and a separate timer (ex. countdown timer) will auto move to the next stage

    /// set button
    late Map buttonConfig;
    if (moveToNextStageWithButton == true) {
      Timer(Duration(milliseconds: 1500), () {
        /// Manage game screen button settings
        buttonConfig = {
          'buttonVisibility': true,
          'buttonText': buttonText,
          'onPressButtonAction': nextStageToLoad,
          'cameraRecordAction': nextStageCameraAction,
          'buttonPositionTargetBottom': buttonPositionTargetBottom, // determine if the button should be displayed low on the screen, or up higher so it does not cover the HUD
        };
        buttonControllerSink.add(buttonConfig);
      });
    } else if (moveToNextStageWithButton == false) {
      buttonConfig = {
        'buttonVisibility': false,
        'buttonText': buttonText,
        'onPressButtonAction': nextStageToLoad,
        'cameraRecordAction': nextStageCameraAction,
        'buttonPositionTargetBottom': buttonPositionTargetBottom, // determine if the button should be displayed low on the screen, or up higher so it does not cover the HUD
      };
      buttonControllerSink.add(buttonConfig);
    }

    /// automatically move to next stage after x time
    if (moveToNextStageAfterDuration == true) {
      Timer(Duration(milliseconds: moveToNextStageAfterDurationTime), () {
        loadGameStageSink.add(nextStageToLoad);
        });
    }

    /// automatically move forward when triggered
    if (moveToNextStageAfterTrigger == true) {
      // listen to stageStream events
      // use cases: In frame success, form success, saving success
    }

    /// *******************************
    /// The Return Value...
    /// *******************************

    return _myWidgets;
  }
}