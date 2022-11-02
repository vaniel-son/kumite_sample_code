import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/levels/services/database_service_levels.dart';
import 'package:dojo_app/widgets/opponent_details.dart';
import 'package:flutter/material.dart';

class LevelSelectorBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  // Bloc constructor: pass in level group ID so bloc knows which level group to manage
  LevelSelectorBloc({required this.gameMode, required this.levelGroupID, required this.userID}) {

    /// Setup level page
    setupLevelSelection();
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed
  String gameMode;
  String levelGroupID;
  String userID;

  /// Instantiate database service object so we can perform db actions from a consolidated file
  DatabaseServicesLevels databaseService = DatabaseServicesLevels();
  late Stream<QuerySnapshot> _levelsStream;

  void dispose() {
    _levelCardTapController.close();
    _opponentDetailWidgetController.close();
    _levelCardListController.close();
    _levelButtonController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams
  /// ***********************************************************************
  /// ***********************************************************************

  /// Stream for the view so it can display list of level cards to user
  Stream<QuerySnapshot> get levelsStream => _levelsStream;

  /// StreamController listens for level_card taps
  final _levelCardTapController = StreamController<String>();
  Stream<String> get levelCardTapStream => _levelCardTapController.stream;
  Sink<String> get levelCardTapSink => _levelCardTapController.sink;

  /// StreamController listens for level cards to display
  final _levelCardListController = StreamController<Map>();
  Stream<Map> get levelCardListStream => _levelCardListController.stream;
  Sink<Map> get levelCardListSink => _levelCardListController.sink;

  /// OpponentDetail Widget Controller
  final _opponentDetailWidgetController = StreamController<Widget>();
  Stream<Widget> get opponentDetailWidgetStream => _opponentDetailWidgetController.stream;
  Sink<Widget> get opponentDetailWidgetSink => _opponentDetailWidgetController.sink;

  /// level button controller manages display of button
  final _levelButtonController = StreamController<Map>();
  Stream<Map> get levelButtonStream => _levelButtonController.stream;
  Sink<Map> get levelButtonSink => _levelButtonController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  setupLevelSelection() {
    /// Fetch all levels data to populate the level cards
    _levelsStream = databaseService.fetchLevelsByLevelGroup(levelGroupID, userID);

    /// Run method to start listening for level card taps
    listenForLevelCardTaps();
  }

  /// Create map with a single opponent's details with button configuration
  Map determineLevelButtonAttributes(levelMap) {
    Map tempButtonAttributes = levelMap;

    if (levelMap['status'] == 'active') {
      tempButtonAttributes["buttonText"] = 'CHALLENGE ' + levelMap['opponentNickname'].toUpperCase();
      tempButtonAttributes["isButtonDisabled"] = false;
      return tempButtonAttributes;
    } else if (levelMap['status'] == 'completed') {
      tempButtonAttributes["buttonText"] = 'YOU DEFEATED ' + levelMap['opponentNickname'].toUpperCase();
      tempButtonAttributes["isButtonDisabled"] = true;
      return tempButtonAttributes;
    } else {
      tempButtonAttributes["buttonText"] = 'LOCKED';
      tempButtonAttributes["isButtonDisabled"] = true;
      return tempButtonAttributes;
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// MManage level_selection.dart view with streams
    // ...manage which opponent details displays based on which card is selected
    // ...manage the button text and route
  /// ***********************************************************************
  /// ***********************************************************************

  listenForLevelCardTaps() {
    /// When a user taps a level card, the stream is notified
    /// so that this function is called
    levelCardTapStream.listen((String levelID) async {

      /// get one opponent's detail data
      QuerySnapshot<Map<String, dynamic>> singleLevelDetailQuery = await databaseService.fetchSingleGameDetails(
          gameMode: gameMode,
          groupID: levelGroupID,
          id: levelID,
          userID: userID);
      // store query results in a map. There will only be 1 result so grab the first one
      Map<String, dynamic> levelMap = singleLevelDetailQuery.docs.first.data();

      /// add opponentDetail widget to sink so it shows up on UI
      Widget myOpponentDetailWidget = OpponentDetails(levelMap: levelMap);
      opponentDetailWidgetSink.add(myOpponentDetailWidget);

      /// update button text and button's levelID that is used when routing to the game screen
      Map<dynamic, dynamic> levelMapWithButtonData = determineLevelButtonAttributes(levelMap);
      levelButtonSink.add(levelMapWithButtonData);
    });
  }
}