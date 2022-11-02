import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/screens/game_modes/game_modes_screen.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/game_modes/levels/services/copy_levels_service.dart';
import 'package:dojo_app/game_modes/matches/services/database_matches.dart';
import 'package:dojo_app/game_modes/matches/services/database_service_matches.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;
import 'package:dojo_app/game_modes/matches/services/game_service_matches.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dojo_app/services/local_notification_service.dart';
import 'dart:math';

/// The purpose of GamesWrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class GameModesWrapper extends StatefulWidget {
  GameModesWrapper() {
    //
  }

  /// determine the type of match we're dealing with
  // pulls from global file because there aren't any other categories or match types yet
  // so it is currently hard coded in globals
  final String category = globalsMatches.category;
  final String levelGroupID = globalsMatches.levelGroupID;
  final String matchGroupID = globalsMatches.matchGroupID;
  final List gameModes = globalsMatches.fitnessGameModesList;

  // Obtain this user's UID
  final String userID = globals.dojoUser.uid;

  @override
  _GameModesWrapperState createState() => _GameModesWrapperState();
}

class _GameModesWrapperState extends State<GameModesWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String levelGroupID = widget.levelGroupID;
  late String matchGroupID = widget.matchGroupID;
  late List gameModeList =
      widget.gameModes; // not used yet, but should migrate to using this so that gameMode screen knows which active gameModes and groupIDs to display

  // Setup getting nickname
  late var databaseService = DatabaseServiceOldMatches(uid: userID);
  late String nickname;

  // Initialize services required
  DatabaseServicesMatches databaseServices = DatabaseServicesMatches();
  GameServiceMatches matchService = GameServiceMatches();

  // Setup getting initial background video to play on levels
  VideoDatabaseService videoDatabaseServices = VideoDatabaseService();
  late String gameModeBackgroundVideoURL;

  // Setup variable to help us determine if all levels are completed
  // so that we can handle UI cases when the user reaches this state
  bool allLevelsCompleted = false;

  // Setup player records
  String winLossTieRecord = '0W-0L-0T';

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _gameModesWrapperController = StreamController<Map>();
  Stream<Map> get gameModesWrapperStream => _gameModesWrapperController.stream;
  Sink<Map> get gameModesWrapperSink => _gameModesWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Run method to refresh user token and if new save to DB.
    videoDatabaseServices.generateUserToken();

    /// Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(videoDatabaseServices.saveTokenToDatabase);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    LocalNotificationService.initialize(context);

    /// Handles App notification when app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];
      }
    });

    // Foreground listening
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }

      LocalNotificationService.display(message);
    });

    /// Message received while app is background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      // Navigator.of(context).pushNamed(routeFromMessage);
    });

    /// Primary method acting as the hub
    setupLevelSelection();
  }

  @override
  void dispose() {
    _gameModesWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  void setupLevelSelection() async {
    /// get nickname
    nickname = await getNickname(userID);
    setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Copy Levels
    // if user does not have initial levels added to their profile, this will add them
    await copyLevels(userID, levelGroupID, nickname);

    /// Check if an open match has expired
    // if it has, then expire the game and forfeit for both or one player
    await checkMatchStateAndExpire(matchGroupID, userID);

    /// get match info
    // QuerySnapshot matchDetails = await databaseServices.fetchLatestSingleGameDetails('matches', matchGroupID, userID);
    QuerySnapshot matchDetails = await databaseServices.fetchLatestStartingGameDetails('matches', matchGroupID, userID);

    /// Get notifications for match
    List<Widget> notificationWidgetList = getNotifications(matchDetails);

    /// get default video background that should play on initial load of game mode page
    gameModeBackgroundVideoURL = await getGameModeBackgroundVideoURL();

    /// Determine if they beat all the levels
    // so we can handle that case when level_select.dart loads
    // allLevelsCompleted = await databaseServices.hasUserCompletedAllLevels(levelGroupID: levelGroupID, userID: userID);

    /// Set game rules ID
    // currently, Dojo only has 1 game so there is only 1 game rule
    String gameRulesID = 'ZlYBWj4jbLddLJEDZbLK';

    /// get this user's pushup count over time, personal record, and win/loss/record
    winLossTieRecord = await getWinLossTieRecord(matchDetails, userID, gameRulesID);

    /// Create map data to send to stream
    // currently, we do not use the Map's nickname or videoURL fields
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    Map<String, dynamic> gameModesWrapperMap = {
      'ready': true,
      'backgroundVideo': gameModeBackgroundVideoURL,
      'allLevelsCompleted': allLevelsCompleted,
      'nickname': nickname,
      'userID': userID,
      'gameModes': gameModeList,
      'notificationWidgetList': notificationWidgetList,
      'winLossTieRecord': winLossTieRecord,
    };

    /// set global data that levels page will use
    // TODO remove usage of global data, instead use getX for state management
    await setGlobalWrapperMap('gameModes', gameModesWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    gameModesWrapperSink.add(gameModesWrapperMap);
  }

  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************

  Future<String> getNickname(userID) async {
    // get default background video to play on level selection
    return await databaseServices.fetchNicknameWhenDefault(userID: userID);
  }

  Future<void> checkMatchStateAndExpire(matchGroupID, userID) async {
    // QuerySnapshot matchDetails = await databaseServices.fetchLatestSingleGameDetails('matches', matchGroupID, userID);
    QuerySnapshot matchDetails = await databaseServices.fetchLatestStartingGameDetails('matches', matchGroupID, userID);

    if (matchDetails.docs.isNotEmpty) {
      /// Get match state
      String matchStatus = matchService.getPlayersStatusInAMatch(matchDetails);

      /// Check whether match has expired
      bool expireMatch = matchService.isMatchExpired(matchDetails);

      /// update match so both or one player forfeits
      if (expireMatch == true) {
        await matchService.forfeitMatch(matchDetails, matchStatus, userID);
      }
    }
  }

  List<Widget> getNotifications(QuerySnapshot matchDetails) {
    List<Widget> notificationWidgetList = [Container()];

    if (matchDetails.docs.isNotEmpty) {
      GameServiceMatches matchService = GameServiceMatches();
      notificationWidgetList = matchService.getMatchNotifications(matchDetails);
    }
    return notificationWidgetList;
  }

  Future<String> getGameModeBackgroundVideoURL() async {
    // obtain gameMode details, which contains the a video URL
    Map gameModeDetailsMap = await databaseServices.fetchGameModeDetails();

    // instantiate random number class
    Random random = Random();

    // generate random number based on length of background videos array
    int randomNumber = random.nextInt(gameModeDetailsMap['backgroundVideos'].length);

    // set background video to play on game modes screen
    String defaultVideo = gameModeDetailsMap['backgroundVideos'][randomNumber];

    return defaultVideo;
  }

  Future<void> copyLevels(userID, levelGroupID, nicknameX) async {
    /// Check if the user has initial levels added for this specific level group
    // if user does not have levels, this will add them so they show up on the level selection screen
    CopyLevelService levelObject = CopyLevelService(levelGroupID: levelGroupID, userID: userID, nickname: nicknameX);
    await levelObject.addInitialLevelsWhenUserHasNone();
  }

  Future<String> getWinLossTieRecord(QuerySnapshot matchDetails, userID, gameRulesID) async {
    String winLossTieRecord = '0W-0L-0T';

    //if (matchDetails.docs.isNotEmpty) {
    /// Store as a map and obtain data
    //var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;

    Map playerOneRecords = await matchService.getPlayerRecords(gameRulesID, userID);

    if (playerOneRecords['winLossTieRecord'] != null) {
      winLossTieRecord = playerOneRecords['winLossTieRecord'];
    }
    //}

    return winLossTieRecord;
  }

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
              return GameModesScreen();
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