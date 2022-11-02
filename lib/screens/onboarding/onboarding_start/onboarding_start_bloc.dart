import 'dart:async';

class OnboardingStartBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  OnboardingStartBloc() {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  void dispose() {
    _wrapperController.close();
  }

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
    // do nothing
  }

  loadUIOnScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapperMap = {
      'ready': true,
    };
    wrapperSink.add(wrapperMap);
  }

}
