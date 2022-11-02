import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/matches/screens/game/game_screen_wrapper.dart';
import 'package:dojo_app/game_modes/matches/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart' as helperLevels;
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/level_select_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'levels_selection_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/levels/globals_levels.dart' as globalsLevels;

//ignore: must_be_immutable
class LevelSelection extends StatefulWidget {
  LevelSelection() {
    //
  }

  @override
  _LevelSelectionState createState() => _LevelSelectionState();
}

class _LevelSelectionState extends State<LevelSelection> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  // the global values are set in the levels_wrapper
  String userID = globalsLevels.levelsWrapperMap['userID'];
  String nickname = globalsLevels.levelsWrapperMap['nickname'];
  String gameMode = globalsLevels.levelsWrapperMap['gameMode'];
  String levelGroupID = globalsLevels.levelsWrapperMap['groupID'];
  String defaultBackgroundVideo = globalsLevels.levelsWrapperMap['backgroundVideo'];
  bool allLevelsCompleted = globalsLevels.levelsWrapperMap['allLevelsCompleted'];

  /// Instantiate object where most of the logic is managed for this page
  // majority of the logic is in this object
  late LevelSelectorBloc levelObject = LevelSelectorBloc(
      gameMode: gameMode,
      levelGroupID: levelGroupID,
      userID: userID);

  /// This informs the level select cards that it's the first time loading
  // so that when level cards are rendering for the first time
  // the function levelCardOnPressAction() is called, which will set the active level and auto load that opponents details
  bool firstTimePageIsLoading = true;

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'high';

  @override
  void initState() {
    super.initState();

    /// determine if the video's opacity layer should be set to none
    setVideoOpacity();
  }

  @override
  void dispose() {
    printBig('Level Selection Dispose Called', 'true');
    super.dispose();
  }



  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytics Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************
  Future<void> _sendAnalyticsEventChallengeButton(levelMap) async {
    await globals.Analytics.analytics.logEvent(
      name: 'challenge_button',
      parameters: <String, dynamic>{
        'Level': levelMap['level'],
      },
    );
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()), (Route<dynamic> route) => false);
  }

  levelsButtonAction(levelMap) {

    /// Analytics event
    _sendAnalyticsEventChallengeButton(levelMap);

    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter, child: GameScreenWrapper(
      userID: userID,
      gameMode: levelMap['gameMode'],
      groupID: levelMap['groupID'],
      id: levelMap['id'],
      gameMap: levelMap,
    )));
  }

  levelCardOnPressAction(Map levels) {
      // inform bloc that this card was tapped
      levelObject.levelCardTapSink.add(levels['id']);

      // display nothing for the opponent card
      levelObject.opponentDetailWidgetSink.add(Container());

      // update video URL to play in background
      // which will inform the video widget which background video should display
      //defaultBackgroundVideo = levels['opponentVideoURL'];
      defaultBackgroundVideo = helperLevels.getOpponentVideo(levels['playerVideos'], userID);
  }

  setVideoOpacity() {
    // are all levels completed?
    if (allLevelsCompleted == true) {
      videoOpacity = 'none';
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************


  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'SINGLE PLAYER CAMPAIGN'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(0),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.height)
                      - (MediaQuery.of(context).padding).top
                      - (MediaQuery.of(context).padding).bottom,
                  child: Stack(
                    children: <Widget>[
                      VideoFullScreen(videoURL: defaultBackgroundVideo, videoConfiguration: 2),
                      BackgroundOpacity(opacity: videoOpacity),
                      Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            HostCard(
                                headLine: 'PUSHUP SPRINT',
                                bodyText: '$nickname, can you perform MORE pushups than your opponent in 60 seconds?'),
                            SizedBox(height: 16),
                            /// Level Selection Cards
                            Container(
                              height: 124,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: levelObject.levelsStream,
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.data != null) {
                                    return ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: snapshot.data!.docs.map<Widget>((DocumentSnapshot document) {

                                        /// convert stream's current item into a map
                                        Map<String, dynamic> levelMap = document.data() as Map<String, dynamic>;

                                        /// When this is the first time the page is loading
                                        // then by default, have the active level's opponent details displayed
                                        if (levelMap['status'] == 'active') {
                                          if (firstTimePageIsLoading == true) {
                                            levelCardOnPressAction(levelMap);
                                            firstTimePageIsLoading = false;
                                            videoOpacity = 'high';
                                          }
                                        }
                                        /// Display a level card
                                        return LevelSelectCard(
                                          levelMap: levelMap,
                                          status: levelMap['status'],
                                          onPressAction: () {
                                            /// opponentVideoURL will update with the newest opponentVideoURL
                                            // so that the background video updates on tap of card
                                            if (levelMap['status'] == 'active' || levelMap['status'] == 'completed') {
                                              // this updates the tap stream so the opponent details displays
                                              // and updates opponentVideoURL with the latest URL
                                              levelCardOnPressAction(levelMap);
                                              setState(() {
                                                defaultBackgroundVideo = helperLevels.getOpponentVideo(levelMap['playerVideos'], userID);
                                                // note: if you comment out the above line, but keep setState, this still works.
                                              });
                                            }
                                          },
                                        );
                                      }).toList(),
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 16),
                            /// Opponent Details
                            StreamBuilder<Widget>(
                              stream: levelObject.opponentDetailWidgetStream,
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  final opponentDetailWidget = snapshot.data as Widget;
                                  return opponentDetailWidget;
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            /// Challenge Button
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: StreamBuilder<Map>(
                                  stream: levelObject.levelButtonStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null) {
                                      final levelMapWithButtonData = snapshot.data as Map;
                                      return HighEmphasisButtonWithAnimation(
                                        id: 1,
                                        title: levelMapWithButtonData['buttonText'],
                                        onPressAction: levelMapWithButtonData['isButtonDisabled']
                                            ? null
                                            : () {levelsButtonAction(levelMapWithButtonData);},
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // top module
  }
}
