import 'dart:async';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;

class HowToPlayBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  HowToPlayBloc() {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Tutorial videos
  // these videos are stored on PROD firebase storage
  // TODO: get from a firebase document
  String videoURLStageOne = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Fonboarding%2Fkoh_pushups%2FonboardingA-v2.mp4?alt=media&token=4fadf9fc-590d-446a-b98d-afb89d1649b5';
  String videoURLStageTwo = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Fonboarding%2Fkoh_pushups%2FonboardingB-v2.mp4?alt=media&token=ffd7f2ea-53e9-42f4-a189-8ba19a615d5f';
  String videoURLStageThree = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Fonboarding%2Fkoh_pushups%2FonboardingC-v2.mp4?alt=media&token=57bb7392-9b65-4115-989d-c80699845dbd';

  void dispose() {
    _howToPlayDataController.close();
    _howToPlayTutorialStagesController.close();
    _wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams, Getters
  /// ***********************************************************************
  /// ***********************************************************************

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => _wrapperController.stream;
  Sink<Map> get wrapperSink => _wrapperController.sink;

  /// Manage data stream and sync between bloc and UI
  final _howToPlayTutorialStagesController = StreamController<constantsKOH.TutorialStage>();
  Stream<constantsKOH.TutorialStage> get howToPlayTutorialStagesStream => _howToPlayTutorialStagesController.stream;
  Sink<constantsKOH.TutorialStage> get howToPlayTutorialStagesSink => _howToPlayTutorialStagesController.sink;

  /// Manage data stream and sync between bloc and UI
  final _howToPlayDataController = StreamController<Map>();
  Stream<Map> get howToPlayDataStream => _howToPlayDataController.stream;
  Sink<Map> get howToPlayDataSink => _howToPlayDataController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    listenForChanges();

    ///Load first stage in Tutorial.
    howToPlayTutorialStagesSink.add(constantsKOH.TutorialStage.training);
  }

  loadUIOnScreen() {

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapperMap = {
      'ready': true,
    };
    wrapperSink.add(wrapperMap);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for event changes
  /// ***********************************************************************
  /// ***********************************************************************

  /// Anytime this stream has data changes, the following is executed
  listenForChanges() async {
    howToPlayTutorialStagesStream.listen((constantsKOH.TutorialStage event) async {

      ///Tutorial steps and the data needed for each UI component corresponding to each step
      if(event == constantsKOH.TutorialStage.training) {

        Map<String, dynamic> howtoPlayDataMap = {
          'hostCardBodyText': 'Train everyday to become a pushup master.',
          'buttonTitle': 'Next',
          'nextTutorialStage': constantsKOH.TutorialStage.earnPho,
          'videoURL': videoURLStageOne
        };

        howToPlayDataSink.add(howtoPlayDataMap);
      }

      if(event == constantsKOH.TutorialStage.earnPho) {

        Map<String, dynamic> howtoPlayDataMap = {
          'hostCardBodyText': 'Earn pho bowls to swap for a Main Event Invite.',
          'buttonTitle': 'Next',
          'nextTutorialStage': constantsKOH.TutorialStage.mainEvent,
          'videoURL': videoURLStageOne
        };

        howToPlayDataSink.add(howtoPlayDataMap);
      }

      if(event == constantsKOH.TutorialStage.mainEvent) {

        Map<String, dynamic> howtoPlayDataMap = {
          'hostCardBodyText': 'In the global main event, do as many push-ups as you can in 60 seconds.',
          'buttonTitle': 'How are players judged?',
          'nextTutorialStage': constantsKOH.TutorialStage.howToWin,
          'videoURL': videoURLStageOne
        };

        howToPlayDataSink.add(howtoPlayDataMap);
      }

      if(event == constantsKOH.TutorialStage.howToWin) {
        Map<String, dynamic> howtoPlayDataMap = {
          'hostCardBodyText': 'Judges review video submissions and only count reps with great form.',
          'buttonTitle': 'How do I win?',
          'nextTutorialStage': constantsKOH.TutorialStage.ready,
          'videoURL': videoURLStageTwo
        };

        howToPlayDataSink.add(howtoPlayDataMap);
      }

      if(event == constantsKOH.TutorialStage.ready) {

        Map<String, dynamic> howtoPlayDataMap = {
          'hostCardBodyText': 'From around the world, one DOJO athlete is deemed the master.',
          'buttonTitle': "I'm Ready",
          'nextTutorialStage': constantsKOH.TutorialStage.end,
          'videoURL': videoURLStageThree
        };

        howToPlayDataSink.add(howtoPlayDataMap);
      }

    });
  }
}
