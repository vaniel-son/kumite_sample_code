import 'dart:async';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/constants.dart' as constants;

class UniswapGuideBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  UniswapGuideBloc({required this.userID}) {
    // Constructor
  }

  String userID;

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Instantiate database service object so we can perform db actions from a consolidated file
  // DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Game Configurations
  int phoBowlFee = 100; // amount of pho bowls required to access event
  int phoBowlsEarned = 0;
  double phoBowlsOnEthereumWallet = 0;
  String gameRulesID = constants.GameRulesConstants.kohPushupMax60; // currently, only one type of main event competition so this is hard coded

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

  int get getPhoBowlsEarned {
    return phoBowlsEarned;
  }

  double get getPhoBowlsOnEthereumWallet {
    return phoBowlsOnEthereumWallet;
  }

  int get getPhoBowlFee {
    return phoBowlFee;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Get pho bowls earned from firebase
    phoBowlsEarned = 0; // default value
    phoBowlsEarned = await GeneralService.getEarnedPhoBowlsFromFirebase(userID: userID);

    /// Get pho bowls from user's ETH wallet
    String userEthereumWalletAddress = await databaseServiceShared.retrieveWalletAddress(userID);
    phoBowlsOnEthereumWallet = await GeneralService.getPhoBowlsFromEthereumAccount(userEthereumWalletAddress);

    /// Get pho bowl fee for latest competition
    Map<String, dynamic> competitionInfo = await databaseServiceShared.latestCompetitionInformation(gameRulesID);
    if (GeneralService.mapHasFieldValue(competitionInfo, 'phoBowlsRequired')) {
      phoBowlFee = competitionInfo['phoBowlsRequired'];
    }
    phoBowlFee = (phoBowlFee / 2).round();

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

  /// ***********************************************************************
  /// ***********************************************************************
  /// Listen for changes
  /// ***********************************************************************
  /// ***********************************************************************
}
