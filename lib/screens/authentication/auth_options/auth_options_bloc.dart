import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/screens/onboarding/onboarding_start/onboarding_start_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/globals.dart' as globals;

class AuthOptionsBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  AuthOptionsBloc() {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  // Manage locking this screen
  bool lockScreenEnabled = false;
  String lockScreenType = 'none';

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
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Lock screen check
    // if locked, then UI will display a lock screen with a message
    Map<String, dynamic> lockScreenStatus = await GeneralService.lockScreenCheck();
    lockScreenType = lockScreenStatus['lockScreenType']; // none = nothing is locked
  }

  // determine which types would lock this screen
  bool thisScreenLocked(lockScreenType) {
    if (lockScreenType == constants.lockAppStatusType.updateAppVersion) {
      return true;
    }

    if (lockScreenType == constants.lockAppStatusType.maintenanceMode) {
      return true;
    }

    if (lockScreenType == constants.lockAppStatusType.accountCreationSuspended) {
      return true;
    }

    return false;
  }

  loadUIOnScreen() {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapperMap = {
      'ready': true,
      'lockScreenType': lockScreenType,
    };
    wrapperSink.add(wrapperMap);
  }

  afterGoogleOrAppleAuthThenRouteUserHere(dojoUser, context, userID) async {
    GeneralService.setGlobalUser(dojoUser); // store in global file
    await GeneralService.getNickname(userID); // get nickname and store in global

    if (dojoUser != null && (globals.nickname == 'Default' || globals.nickname == 'Player')) {
      /// auth was successful, but their nickname is "default" or 'Player', which infers they have not yet provided a nickname
      // so lets push them to the onboarding screen since the are most likely a brand new user
      Navigator.pushAndRemoveUntil(
          context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: OnboardingStartScreen()), (
          Route<dynamic> route) => false);

    } else if (dojoUser != null && globals.nickname != 'Default'){
      /// authentication was successful, and globals nickname != default
      // so they have nickname, which means we can route user to the home page
      Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter, child: Wrapper()),(Route<dynamic> route) => false);
    } else {
      GeneralService.printBig('error', 'error after google or apple authentication');
    }
  }
}
