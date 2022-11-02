import 'dart:async';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class WrapperBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  WrapperBloc() {
    //
  }

  DatabaseServices databaseServiceShared = DatabaseServices();

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

  preloadScreenSetup(userID) async {
    if (userID != null) {
      await GeneralService.getNickname(userID);
      loadUIOnScreen();
    } else {
      loadUIOnScreen();
    }
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
