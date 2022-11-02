import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/game_modes/matches/services/database_service_matches.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart' as helperMatches;
import 'package:flutter/material.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;
import 'package:dojo_app/game_modes/matches/constants_matches.dart' as constantsMatches;
import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_screen.dart';
import 'package:dojo_app/game_modes/matches/services/game_service_matches.dart';

/// The purpose of Matches wrapper
// The class will obtain data that the level page requires
// while the class fetches the data, a loading screen will be displayed to the user
// once all required data is completed
// the stream in the widget is updated with this data
// which informs the app to move forward

class MatchesWrapper extends StatefulWidget {
  MatchesWrapper() {
    //
  }

  /// determine the type of game/match we're dealing with
  // pulls from global file because there aren't any other categories or match types yet
  // so it is currently hard coded in globals
  final String matchGroupID = globalsMatches.matchGroupID;
  final String gameMode = 'matches';

  // Obtain this user's UID
  final String userID = globals.dojoUser.uid;

  @override
  _MatchesWrapperState createState() => _MatchesWrapperState();
}

class _MatchesWrapperState extends State<MatchesWrapper> {
  /// ***********************************************************************
  /// Setup variables
  /// ***********************************************************************

  // Setup variables for passed in data
  late String userID = widget.userID;
  late String matchGroupID = widget.matchGroupID;
  late String gameMode = widget.gameMode;

  // Initialize services required
  DatabaseServicesMatches databaseServices = DatabaseServicesMatches();
  GameServiceMatches matchService = GameServiceMatches();

  // Setup getting nickname
  late String nickname;

  // Setup getting initial background video to play on levels
  late String videoURL;
  late Map matchesVideoMap;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _matchesWrapperController = StreamController<Map>();
  Stream<Map> get matchesWrapperStream => _matchesWrapperController.stream;
  Sink<Map> get matchesWrapperSink => _matchesWrapperController.sink;

  /// ***********************************************************************
  /// Initialization methods
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Primary method acting as the hub for this class
    setupMatchesWrapper();
  }

  @override
  void dispose() {
    _matchesWrapperController.close();
    super.dispose();
  }

  /// ***********************************************************************
  /// Primary function
  /// ***********************************************************************

  Future<void> setupMatchesWrapper() async {
    /// If there are any video collection docs for this user that have not been processed...
    // where video files have been background uploaded, but the videoURL has not been extracted
    // and saved to their match documents
    // if found, the method will update the player's match documents for both players
    await databaseServices.fetchVideoURLandUpdateMatches(gameMode, userID);

    /// get nickname
    nickname = await getNickname(userID);
    setGlobalNickname(nickname); // store in global variable for everywhere access

    /// Check if an open match has expired
    // if it has, then expire the game and forfeit for both or one player
    await checkMatchStateAndExpire(matchGroupID, userID);

    /// get latest match info
    // obtain this again because the match expiration may have changed its data
    // QuerySnapshot matchDetails = await databaseServices.fetchLatestSingleGameDetails('matches', matchGroupID, userID);
    QuerySnapshot matchDetails = await databaseServices.fetchLatestStartingGameDetails('matches', matchGroupID, userID);

    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;
    } else {
      printBig('empty', 'empty');
    }

    /// Get notifications for match
    List<Widget> notificationWidgetList = getNotifications(matchDetails);

    /// get default video background that should play on initial load of level select page
    matchesVideoMap = await getVideoURL(userID, matchDetails);

    /// Create map data to send to stream
    // currently, we do not use the Map's nickname or videoURL fields
    // TODO: later, consider storing values in widget tree and passing via GetX, or provider so we can
    // avoid using global variables
    Map<String, dynamic> matchesWrapperMap = {
      'ready': true,
      'gameMode': 'matches',
      'groupID': matchGroupID,
      'matchesVideoMap': matchesVideoMap,
      'nickname': nickname,
      'userID': userID,
      'notificationWidgetList': notificationWidgetList,
    };

    /// set global data that levels page will use
    // TODO remove usage of global data, instead use getX for state management
    await helperMatches.setGlobalWrapperMap('matches', matchesWrapperMap);

    /// IF everything is ready, then add 'ready: true" to stream sink so the
    // app moves forward
    matchesWrapperSink.add(matchesWrapperMap);
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

  Future<Map> getVideoURL(userID, QuerySnapshot matchDetails) async {
    bool displayBackgroundVideo = false;
    String backgroundVideo = '';

    /// Determine which video to display
    if (matchDetails.docs.isNotEmpty) {
      var details = matchDetails.docs.first.data() as Map<dynamic, dynamic>;

      // GameStatus = closed so display this user's video, if it's available
      if (details['gameStatus'] == constants.cGameStatusClosed) {
        if (details['playerVideos'][userID] != null) {
          displayBackgroundVideo = true;
          backgroundVideo = details['playerVideos'][userID];
        }
      } else {
        // GameStatus = open so display the player video that is available
        // this also checks if the video is available in the document
        // because it may still be uploading, even though the player has completed the game
        String opponentUserID = helperMatches.getOpponentUserID(details, userID);
        if (details['playerGameOutcomes'][userID] == constantsMatches.cPlayerGameOutcomePending && details['playerVideos'][userID] != null) {
          // this player has played and their video is available to display
          displayBackgroundVideo = true;
          backgroundVideo = details['playerVideos'][userID];
        } else if (details['playerGameOutcomes'][opponentUserID] == constantsMatches.cPlayerGameOutcomePending && details['playerVideos'][opponentUserID] != null) {
          // the opponent has played so show their video
          displayBackgroundVideo = true;
          backgroundVideo = details['playerVideos'][opponentUserID];
        } else {
          // no video is available so fetch one from the previous match
          String opponentUserID = helperMatches.getOpponentUserID(details, userID);
          QuerySnapshot opponentMatchDetails = await databaseServices.fetchLatestStartingGameDetails('matches', matchGroupID, opponentUserID);
          int index = 0;
          if (opponentMatchDetails.docs.isNotEmpty) {
            opponentMatchDetails.docs.forEach((doc) {
              if (index == 1) {
                backgroundVideo = doc['playerVideos'][opponentUserID];
                displayBackgroundVideo = true;
              }
            });
          }
        }
      }
    }

    Map matchesVideoMap = {
      'displayBackgroundVideo': displayBackgroundVideo,
      'backgroundVideo': backgroundVideo,
    };

    return matchesVideoMap;
  }

  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: matchesWrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return MatchesScreen();
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
