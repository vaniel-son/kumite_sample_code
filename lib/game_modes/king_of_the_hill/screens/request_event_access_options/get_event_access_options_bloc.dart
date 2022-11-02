import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';

class GetEventAccessOptionsBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GetEventAccessOptionsBloc({required this.userID, required this.gameMap}) {
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
  }

  loadUIOnScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {'ready': true};
    wrapperSink.add(wrapper);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************


  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for changes
  /// ***********************************************************************
  /// ***********************************************************************
}
