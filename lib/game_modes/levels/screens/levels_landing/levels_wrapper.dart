import 'dart:async';
import 'package:dojo_app/game_modes/levels/screens/levels_landing/levels_selection.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/game_modes/levels/services/copy_levels_service.dart';
import 'package:dojo_app/game_modes/levels/services/database_service_levels.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/levels/globals_levels.dart' as globalsLevels;

/// The purpose of LevelsWrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class LevelsWrapper extends StatefulWidget {
  LevelsWrapper() {
    //
  }

  /// determine the level group we're dealing with
  // pulls from global file because there aren't any other level groups yet
  // so it is currently hard coded in globals
  final String gameMode = globalsLevels.gameModeLevelsMap['gameMode'];
  final String levelGroupID = globalsLevels.gameModeLevelsMap['groupID'];


  // Obtain this user's UID
  final String userID = globals.dojoUser.uid;

  @override
  _LevelsWrapperState createState() => _LevelsWrapperState();
}

class _LevelsWrapperState extends State<LevelsWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String gameMode = widget.gameMode;
  late String levelGroupID = widget.levelGroupID;

  // Setup getting nickname
  late String nickname;

  // Setup getting initial background video to play on levels
  DatabaseServicesLevels databaseServices = DatabaseServicesLevels();
  late String videoURL;

  // Setup variable to help us determine if all levels are completed
  // so that we can handle UI cases when the user reaches this state
  bool allLevelsCompleted = false;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _levelSelectionLoaderController = StreamController<Map>();
  Stream<Map> get levelSelectionLoaderStream => _levelSelectionLoaderController.stream;
  Sink<Map> get levelSelectionLoaderSink => _levelSelectionLoaderController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub
    setupLevelSelection();
    print('levels selection printing');
  }

  @override
  void dispose () {
    _levelSelectionLoaderController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setupLevelSelection() async {
    /// If there are any video collection docs for this user that have not been processed...
    // where video files have been background uploaded, but the videoURL has not been extracted
    // and saved to their level documents
    // if found, the method will update the player's level documents for both players
    await databaseServices.fetchVideoURLandUpdateMatches(gameMode, userID);

    /// get nickname
    nickname = await getNickname(userID);
    setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Copy Levels
    // if user does not have initial levels added to their profile, this will add them
    await copyLevels(userID, levelGroupID, nickname);

    /// get default video background that should play on initial load of level select page
    videoURL = await getVideoURL(userID, levelGroupID);

    /// Determine if they beat all the levels
    // so we can handle that case when level_select.dart loads
    allLevelsCompleted = await databaseServices.hasUserCompletedAllLevels(levelGroupID: levelGroupID, userID: userID);

    /// Create map data to send to stream
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    Map<String, dynamic> levelSelectionLoaderMap = {
      'ready': true,
      'gameMode': gameMode,
      'groupID': levelGroupID,
      'backgroundVideo': videoURL,
      'allLevelsCompleted': allLevelsCompleted,
      'nickname': nickname,
      'userID': userID,
    };

    /// set global data that levels page will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('levels', levelSelectionLoaderMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    levelSelectionLoaderSink.add(levelSelectionLoaderMap);
  }

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  Future<String> getNickname(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchNicknameWhenDefault(userID: userID);
  }

  Future<String> getVideoURL(userID, levelGroupID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchLevelSelectBackgroundVideo(levelGroupID: levelGroupID, userID: userID);
  }

  Future<void> copyLevels(userID, levelGroupID, nicknameX) async {
    /// Check if the user has initial levels added for this specific levelGroupID
    // if user does not have levels, this will add them so they show up on the level selection screen
    CopyLevelService levelObject = CopyLevelService(levelGroupID: levelGroupID, userID: userID, nickname: nicknameX);
    await levelObject.addInitialLevelsWhenUserHasNone();
  }

  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
      stream: levelSelectionLoaderStream,
      initialData: {
        'ready': false,
      },
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final ready = snapshot.data!['ready'] as bool;
          if (ready == true) {
            return LevelSelection();
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
      }
    );
  }
}
