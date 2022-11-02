import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';

class GetEventAccessWeb3Bloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GetEventAccessWeb3Bloc({required this.userID, required this.gameMap}) {
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

  /// Screen content
  String hostCardBody = 'Hi, I am Jiriya';
  String paymentAddress = 'Unavailable'; // default value
  bool userHasPaid = false;

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

  String get getPaymentAddress {
    return paymentAddress;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Get ethereum address
    if (gameMap['ethereumAddressForPayment'] == 'unknown' || gameMap.isEmpty) {
      paymentAddress = 'Unavailable';
    } else {
      print(gameMap['id']);
      paymentAddress = gameMap['ethereumAddressForPayment'];
    }

    // has not paid yet
    if (gameMap['paymentReceived'] == true) {
      userHasPaid = true;
    }
  }

  // Force UI to display UI elements
  loadUIOnScreen() async {
    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // UI will move away from loading to intended UI
    Map<String, dynamic> wrapper = {'ready': true};
    wrapperSink.add(wrapper);
  }

  // Force the UI screen to display a loading screen
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
