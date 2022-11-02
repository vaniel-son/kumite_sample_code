import 'package:dojo_app/game_modes/matches/constants_matches.dart' as constantsMatches;
// import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;
import 'package:dojo_app/game_modes/matches/judge_matches/screens/judge_list/judge_list_wrapper.dart';
import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_wrapper.dart';
import 'package:dojo_app/game_modes/matches/judge_matches/screens/view_replay/view_replay_bloc.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:page_transition/page_transition.dart';

// TODO create new page that will display this split screen widget. Part of matches folder or a new screen ex "watch_two_videos_screen"
// TODO add video loading screen

class ViewReplayScreen extends StatefulWidget {
  ViewReplayScreen({Key? key, required this.viewReplayWrapperMap, required this.playerOneVideo, required this.playerTwoVideo})
      : super(key: key);

  final String playerOneVideo;
  final String playerTwoVideo;
  final Map viewReplayWrapperMap;

  @override
  _ViewReplayScreenState createState() => _ViewReplayScreenState();
}

class _ViewReplayScreenState extends State<ViewReplayScreen> {
  /// Force these videos to display regardless if a video is available (for testing)
  // String playerOneVideo =
  //    'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/701732f0-27c2-11ec-a00d-1bd2e9f830f4.mp4?alt=media&token=bec4952a-d481-4e25-aa6a-79da72fa083f';
  // String playerTwoVideo =
  //    'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/701732f0-27c2-11ec-a00d-1bd2e9f830f4.mp4?alt=media&token=bec4952a-d481-4e25-aa6a-79da72fa083f';

  /// Obtain passed in variables
  late String playerOneVideo = widget.playerOneVideo;
  late String playerTwoVideo = widget.playerTwoVideo;
  late final Map gameMap = widget.viewReplayWrapperMap['gameMap'];
  late final String playerOneUserID = widget.viewReplayWrapperMap['playerOneUserID'];
  late final String gameMode = gameMap['gameMode'];
  late final String groupID = gameMap['groupID'];
  late final String redirect = widget.viewReplayWrapperMap['redirect'];
  late final constantsMatches.UserPointOfViewMatches userPointOfView = widget.viewReplayWrapperMap['userPointOfView'];
  late final String judgeRequestID = widget.viewReplayWrapperMap['judgeRequestID'];

  // init the video players for this player (player1) and opponent (player2)
  final FijkPlayer player1 = FijkPlayer();
  final FijkPlayer player2 = FijkPlayer();

  // init primary bloc object that primarily controls this screen's data and logic
  late ViewReplayBloc viewReplayBloc = ViewReplayBloc(
    gameMap: gameMap,
    gameMode: gameMode,
    groupID: groupID,
    playerOneUserID: playerOneUserID,
    userPointOfView: userPointOfView,
    judgeRequestID: judgeRequestID,
  );

  @override
  void initState() {
    super.initState();

    // set player video dataSources
    setPlayerVideos();
  }

  @override
  void dispose() {
    printBig('dispose called', 'view replay screen');
    super.dispose();
    player1.release();
    player2.release();
  }

  void setPlayerVideos() {
    player1.setDataSource(playerOneVideo, autoPlay: true);
    player2.setDataSource(playerTwoVideo, autoPlay: true);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  void onPressButtonAction(viewReplayStage, buttonControls) {
    /// hide button and set default button label
    Map buttonConfig = {
      'buttonVisibility': false,
      'buttonText': 'Disabled',
      'onPressButtonAction': 0,
    };
    viewReplayBloc.buttonControllerSink.add(buttonConfig);

    if (viewReplayStage == ViewReplayStage.Exit) {
      backButtonAction();
    } else {
      viewReplayBloc.eventSink.add(viewReplayStage);
    }
  }

  /// Exit view replay screen
  void backButtonAction() {
    if (redirect == 'JudgeListWrapper()') {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.bottomToTop, alignment: Alignment.bottomCenter, child: JudgeListWrapper()));
    } else if (redirect == 'MatchesWrapper()') {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.bottomToTop, alignment: Alignment.bottomCenter, child: MatchesWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'TURN BASED 2 PLAYER'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: Material(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: StreamBuilder<List<Widget>>(
                      stream: viewReplayBloc.uiPlayerOneStream,
                      initialData: [],
                      builder: (context, snapshot) {
                        List<Widget> widgetList = [
                          Container(),
                        ];
                        if (snapshot.data != null) {
                          widgetList = snapshot.data as List<Widget>;
                        }
                        return Stack(
                          children: [
                            FijkView(
                              player: player1,
                              fit: FijkFit.cover,
                            ),
                            Column(
                              children: widgetList,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Expanded(
                    //child: VideoFullScreen(videoMap: videoMap, videoURL: selfieVideoToPlay, videoConfiguration: 2),
                    child: StreamBuilder<List<Widget>>(
                      stream: viewReplayBloc.uiPlayerTwoStream,
                      initialData: [],
                      builder: (context, snapshot) {
                        List<Widget> widgetList = [
                          Container(),
                        ];
                        if (snapshot.data != null) {
                          widgetList = snapshot.data as List<Widget>;
                          widgetList.insert(0, SizedBox(height: 16));
                        }
                        return Stack(
                          children: [
                            FijkView(
                              player: player2,
                              fit: FijkFit.cover,
                            ),
                            Column(
                              children: widgetList,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  StreamBuilder<List<Widget>>(
                    stream: viewReplayBloc.uiStream,
                    initialData: [],
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        final widgetList = snapshot.data as List<Widget>;
                        return SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: widgetList,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder<Map>(
                      stream: viewReplayBloc.buttonControllerStream,
                      initialData: {'buttonVisibility': false, 'buttonText': 'Disabled', 'onPressButtonAction': 0},
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          final buttonControls = snapshot.data as Map;
                          return Visibility(
                            visible: buttonControls['buttonVisibility'],
                            child: MediumEmphasisButton(
                              title: buttonControls['buttonText'],
                              onPressAction: () {
                                onPressButtonAction(buttonControls['onPressButtonAction'], buttonControls);
                              },
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                  SizedBox(height: 16, width: double.infinity),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}