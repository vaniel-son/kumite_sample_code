import 'package:dojo_app/game_modes/king_of_the_hill/screens/judge_king_of_hill/screens/judge_list/judge_list_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/judge_king_of_hill/screens/view_replay/view_replay_bloc.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:page_transition/page_transition.dart';

class ViewReplayScreen extends StatefulWidget {
  ViewReplayScreen({Key? key, required this.playerOneUserID, required this.playerOneVideo, required this.gameID, required this.judgeRequestID, required this.judgeMap})
      : super(key: key);

  final String playerOneVideo;
  final String playerOneUserID;
  final String gameID;
  final String judgeRequestID;
  final Map judgeMap;

  @override
  _ViewReplayScreenState createState() => _ViewReplayScreenState();
}

class _ViewReplayScreenState extends State<ViewReplayScreen> {
  /// Force these videos to display regardless if a video is available (for testing)
  // String playerOneVideo =
  //    'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/701732f0-27c2-11ec-a00d-1bd2e9f830f4.mp4?alt=media&token=bec4952a-d481-4e25-aa6a-79da72fa083f';

  /// Obtain passed in parameters
  late String playerOneVideo = widget.playerOneVideo;
  late final String playerOneUserID = widget.playerOneUserID;
  late final String judgeRequestID = widget.judgeRequestID;
  late final Map judgeMap = widget.judgeMap;

  // init the video players for this player (player1) and opponent (player2)
  final FijkPlayer player1 = FijkPlayer();

  // init primary bloc object that primarily controls this screen's data and logic
  late ViewReplayBloc  viewReplayBloc;

  // Calling video method requires video map, but for our use case here, we can leave it blank
  Map videoMap = {};

  /// ***********************************************************************
  /// ***********************************************************************
  /// Init / Dispose
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    printBig('dispose called', 'view replay screen');
    super.dispose();
    player1.release();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  void setup() async {
    /// Instantiate controller for this Game Mode page
    viewReplayBloc = ViewReplayBloc(
      judgeMap: judgeMap,
      playerOneUserID: playerOneUserID,
      judgeRequestID: judgeRequestID,
    );

    /// Load required data before loading this screen's widgets
    await viewReplayBloc.preloadScreenSetup();

    // set player video dataSources
    setPlayerVideos();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  void setPlayerVideos() {
    player1.setDataSource(playerOneVideo, autoPlay: false, showCover: true);
    //player1.pause();
    // player1.start();
  }

  void playVideo(){
    player1.start();
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

    if (viewReplayStage == ViewReplayStage.Countdown) {
      playVideo();
    }
  }

  /// Exit view replay screen
  void backButtonAction() {
      Navigator.pushReplacement(context,
          PageTransition(type: PageTransitionType.bottomToTop, alignment: Alignment.bottomCenter, child: JudgeListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
      stream: viewReplayBloc.wrapperStream,
      initialData: {'ready': false},
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final ready = snapshot.data!['ready'] as bool;
          if (ready == true) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: primarySolidBackgroundColor,
              appBar: AppBar(
                title: PageTitle(title: 'KING OF THE HILL JUDGING'),
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
                                    //VideoFullScreen(videoMap: videoMap, videoURL: playerOneVideo, videoConfiguration: 2),
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
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
