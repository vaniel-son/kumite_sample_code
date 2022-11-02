import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/request_event_access/get_event_access_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/services/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class GetEventAccessBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GetEventAccessBloc({required this.userID, required this.gameMap}) {
    // Constructor
  }

  String userID;
  Map<String, dynamic> gameMap;

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Game Configurations
  int phoBowlFee = 8; // amount of pho bowls required to access event
  int phoBowlsEarnedFromFirebase = 0;
  double phoBowlsEarnedFromETHWallet = 0.0;

  /// Screen States
  String screenStateNotPaidSufficientPhoBowls = 'not paid, sufficient pho bowls';
  String screenStateNotPaidInsufficientPhoBowls = 'not paid, insufficient pho bowls';
  String screenStatePaid = 'paid';
  late String screenState = screenStateNotPaidInsufficientPhoBowls;

  /// Screen content
  String hostCardBody = 'Hi, I am Jiriya';
  bool isGivePhoBowlButtonVisible = false;
  bool isGivePhoBowlButtonEnabled = false;

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

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  int get getPhoBowlFee {
    return phoBowlFee;
  }

  int get getPhoBowlsEarnedFromFirebase {
    return phoBowlsEarnedFromFirebase;
  }

  double get getPhoBowlsEarnedFromETHWallet {
    return phoBowlsEarnedFromETHWallet;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Get pho bowls earned from firebase
    phoBowlsEarnedFromFirebase = 0; // default value
    phoBowlsEarnedFromFirebase = await GeneralService.getEarnedPhoBowlsFromFirebase(userID: userID);

    /// Get pho bowls from user's ETH wallet
    String userEthereumWalletAddress = await databaseServiceShared.retrieveWalletAddress(userID);
    phoBowlsEarnedFromETHWallet = await GeneralService.getPhoBowlsFromEthereumAccount(userEthereumWalletAddress);

    /// Get pho bowl fee for this competition
    Map<String, dynamic> competitionInfo = await databaseServiceShared.fetchCompetitionInformation(gameMap['competitionID']);
    if (GeneralService.mapHasFieldValue(competitionInfo, 'phoBowlsRequired')) {
      phoBowlFee = competitionInfo['phoBowlsRequired'];
    }

    /// Has this player paid yet?
    // has paid
    if (gameMap['paymentReceived'] == true) {
      screenState = screenStatePaid;
    }

    // has not paid yet
    if (gameMap['paymentReceived'] == false) {
      if (phoBowlsEarnedFromFirebase >= phoBowlFee) {
        screenState = screenStateNotPaidSufficientPhoBowls;
      } else {
        screenState = screenStateNotPaidInsufficientPhoBowls;
      }
    }

    /// Determine host card content
    if (screenState == screenStatePaid) {
      hostCardBody = 'Thank you! I can feed everyone in my village. Good luck at the main event!';
    } else if (screenState == screenStateNotPaidInsufficientPhoBowls) {
      hostCardBody = 'Donate $phoBowlFee Pho bowls, and I\'ll hook ya up with access to the main event. \n\nI need help cuz I\'m feeding all the volunteers planting 100s of trees around my village.';
      //hostCardBody = 'Yooo, everyone in my village is volunteering to plant 100s of trees. A lotta calories are gonna be burned so I want to reward peeps with food. \n\nIf you give me $phoBowlFee Pho bowls, I\'ll hook ya up with instant access to the upcoming main event.';
      // hostCardBody = 'Yooo, I\'m holding a block party, and need help with feeding everyone. \n\nIf you give me $phoBowlFee Pho bowls, I\'ll hook ya up with instant access to the upcoming main event.';
    } else if (screenState == screenStateNotPaidSufficientPhoBowls) {
      hostCardBody = 'Donate $phoBowlFee Pho bowls, and I\'ll hook ya up with access to the main event. \n\nI need help cuz I\'m feeding all the volunteers planting 100s of trees around my village.';
    }

    /// Is 'give pho bowls' button visible?
    if (screenState == screenStatePaid) {
      isGivePhoBowlButtonVisible = false;
    } else if (screenState == screenStateNotPaidInsufficientPhoBowls) {
      isGivePhoBowlButtonVisible = true;
    } else if (screenState == screenStateNotPaidSufficientPhoBowls) {
      isGivePhoBowlButtonVisible = true;
    }

    /// Is 'give pho bowls' button enabled?
    if (screenState == screenStatePaid) {
      isGivePhoBowlButtonEnabled = false;
    } else if (screenState == screenStateNotPaidInsufficientPhoBowls) {
      isGivePhoBowlButtonEnabled = false;
    } else if (screenState == screenStateNotPaidSufficientPhoBowls) {
      isGivePhoBowlButtonEnabled = true;
    }
  }

  loadUIOnScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {'ready': true};
    wrapperSink.add(wrapper);
  }

  showLoadingOnUIScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {'ready': false};
    wrapperSink.add(wrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  givePhoBowls() async{
    printBig('give pho bowls', 'triggered');
    // check if they have enough pho bowls
    if (phoBowlsEarnedFromFirebase >= phoBowlFee && gameMap['paymentReceived'] == false) {
      // play SFX
      PlayAudio swapResource = PlayAudio(audioToPlay: 'assets/audio/swap-resource02.mp3');
      swapResource.play();

      /// deduct pho bowls
      //databaseServiceShared.updatePhoBowlResourceInventory(userID, -phoBowlFee);
      databaseServiceShared.updateResourcePhoBowl(userID, -phoBowlFee);

      // display loading on UI
      showLoadingOnUIScreen();

      // update game doc with payment = true
      await databaseService.paymentReceived(gameInfo: gameMap);

      // update local copies so the screen can react correctly
      gameMap['paymentReceived'] = true; // update the local copy with paid
      screenState = screenStatePaid;

      // re-draw the UI so it has the new messaging
      // requestEventAccessAction(context);
      await preloadScreenSetup();
      loadUIOnScreen();
    }
  }

  requestEventAccessAction(context) {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GetEventAccessScreen(
              userID: userID,
              gameMap: gameMap,)));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for changes
  /// ***********************************************************************
  /// ***********************************************************************
}
