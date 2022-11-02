import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/judge_king_of_hill/screens/judge_list/judge_list_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/archive/globals_archive.dart' as globalsArchive;
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';

/// The purpose of GamesWrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class JudgeListWrapper extends StatefulWidget {
  JudgeListWrapper() {
    //
  }



  // Obtain this user's UID
  final String userID = globalsArchive.dojoUser.uid;

  @override
  _JudgeListWrapperState createState() => _JudgeListWrapperState();
}

class _JudgeListWrapperState extends State<JudgeListWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;

  // Setup getting nickname
  late String nickname;

  // Initialize services required
  DatabaseServices databaseServices = DatabaseServices();
  GameServiceKOH matchService = GameServiceKOH();

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _judgeListWrapperController = StreamController<Map>();
  Stream<Map> get gameModesWrapperStream => _judgeListWrapperController.stream;
  Sink<Map> get gameModesWrapperSink => _judgeListWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub
    setupLevelSelection();
  }

  @override
  void dispose() {
    _judgeListWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setupLevelSelection() async {
    /// get nickname
    nickname = await GeneralService.getNickname(userID); // store in global variable for everywhere access

    /// get a list of matches available for judging
    // QuerySnapshot matchesForJudging = await databaseServices.fetchMatchesForJudging(userID);

    /// Create map data to send to stream
    // currently, we do not use the Map's nickname or videoURL fields
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    Map<String, dynamic> judgeListWrapperMap = {
      'ready': true,
      'nickname': nickname,
      'userID': userID,
      //'matchesForJudging': matchesForJudging,
    };

    /// set global data that levels page will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('judgeList', judgeListWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    gameModesWrapperSink.add(judgeListWrapperMap);
  }

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: gameModesWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return JudgeListScreen();
            } else {
              return Stack(
                children: [
                  LoadingScreen(displayVisual: 'loading icon'),
                  BackgroundOpacity(opacity: 'medium'),
                ],
              );
            }
          } else {
            return Stack(
              children: [
                LoadingScreen(displayVisual: 'loading icon'),
                BackgroundOpacity(opacity: 'medium'),
              ],
            );
          }
        });
  }
}
