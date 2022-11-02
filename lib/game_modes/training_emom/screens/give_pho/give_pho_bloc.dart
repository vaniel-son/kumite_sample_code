import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'give_pho_screen.dart';

class GivePhoBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GivePhoBloc({required this.userID, required this.recipientUserID, required this.recipientNickname, required this.context}) {
    // Constructor
  }

  String userID;
  String recipientUserID;
  String recipientNickname;
  var context;

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Game Configurations
  int phoBowlsEarned = 0; // default value

  void dispose() {
    _wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage whether to load the ui screen or not
  // to load level selection page
  final _wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => _wrapperController.stream;
  Sink<Map> get wrapperSink => _wrapperController.sink;

  final _stateController = StreamController<Map>();
  Stream<Map> get stateStream => _stateController.stream;
  Sink<Map> get stateSink => _stateController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  /*int get getPhoBowlFee {
    return phoBowlFee;
  }*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  /// Before the page UI displays, load these items
  preloadScreenSetup() async {
    /// Get pho bowls earned so far
    Map resourcesEarned = await databaseServiceShared.fetchPlayerInventoryResources(userID);
    phoBowlsEarned = 0; // default value
    if (resourcesEarned.isNotEmpty) {
      if (resourcesEarned['phoBowls'] != null) {
        phoBowlsEarned = resourcesEarned['phoBowls'];
      }
    }
  }

  /// IF everything is ready, then add 'ready: true" to stream sink so the
  // UI will move away from loading to intended UI
  loadUIOnScreen() async {
    Map<String, dynamic> wrapper = {'ready': true};
    wrapperSink.add(wrapper);
  }

  /// Display the loading state on the UI
  showLoadingOnUIScreen() async {
    Map<String, dynamic> wrapper = {'ready': false};
    wrapperSink.add(wrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  giveFivePhoBowls(){
    givePhoBowls('one'); // pass in five
  }

  giveAllPhoBowls(){
    givePhoBowls('all'); // pass in all
  }

  givePhoBowls(String amount) async{
    String snackBarMessage = ''; // on reload of screen, display this snackbar message, by default it won't show unless provided text

    // users cannot send tokens to themself
    bool isNotSendingToSelf = false;
    if (recipientUserID != userID) {
      isNotSendingToSelf = true;
    } else {
      snackBarMessage = 'Stop giving away PHO to yourself...';
      requestEventAccessAction(snackBarMessage);
    }

    // determine number of pho bowls to send to recipient
    int phoBowlsToSend = 1;
    if (amount == 'one') {
      phoBowlsToSend = 1;
      snackBarMessage = 'Sent one PHO bowls to $recipientNickname';
    } else if (amount == 'all') {
      phoBowlsToSend = phoBowlsEarned;
      snackBarMessage = 'OMG. Sent all your PHO bowls to $recipientNickname';
    }

    // check if they have enough pho bowls
    if (phoBowlsEarned >= phoBowlsToSend && isNotSendingToSelf && phoBowlsEarned > 0) {
      /// play SFX
      PlayAudio swapResource = PlayAudio(audioToPlay: 'assets/audio/swap-resource02.mp3');
      swapResource.play();

      /// deduct pho bowls from this user
      databaseServiceShared.updateResourcePhoBowl(userID, -phoBowlsToSend);

      /// add pho bowls to the recipient user
      databaseServiceShared.updateResourcePhoBowl(recipientUserID, phoBowlsToSend);

      /// display loading on UI
      showLoadingOnUIScreen();

      // re-draw the UI so it has the new messaging
      requestEventAccessAction(snackBarMessage);
      // await preloadScreenSetup();
      // loadUIOnScreen();
    } else {
      snackBarMessage = 'You don\'t have enough PHO bowls to send.';
      requestEventAccessAction(snackBarMessage);
    }
  }

  requestEventAccessAction(String snackBarMessage) {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.topToBottom,
            child: GivePhoScreen(
              userID: userID,
              recipientNickname: recipientNickname,
              recipientUserID: recipientUserID,
              snackBarMessage: snackBarMessage,
              )));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for changes
  /// ***********************************************************************
  /// ***********************************************************************
}
