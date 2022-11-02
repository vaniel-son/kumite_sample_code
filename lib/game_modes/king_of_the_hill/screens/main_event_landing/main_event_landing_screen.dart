import 'package:dojo_app/game_modes/king_of_the_hill/screens/game/game_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/request_event_access_options/get_event_access_options_screen.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/widgets/competition_timer_card.dart';
import 'package:dojo_app/widgets/leaderboard.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/widgets/line_chart.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'main_event_landing_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/constants.dart' as constants;
import 'package:intl/intl.dart';

//ignore: must_be_immutable
class MainEventLandingScreen extends StatefulWidget {
  MainEventLandingScreen() {
    // Constructor
  }

  @override
  _MainEventLandingScreenState createState() => _MainEventLandingScreenState();
}

class _MainEventLandingScreenState extends State<MainEventLandingScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  String gameRulesID = constants.GameRulesConstants.kohPushupMax60;
  late String userID = globals.dojoUser.uid;

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late MainEventLandingBloc mainEventLandingController;
  late DateTime competitionTimeToCountDownTowards;

  // testing
  // String videoURLTemp = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/assets_app%2Fvideos%2Fmisc%2Fbg-assibey-punchout-stair-pushup.mp4?alt=media&token=e82ed8dd-c28e-4fd1-aea7-ff8375325352';

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setup() async {
    /// *******************************************
    /// Preload required data before loading screen or bloc
    /// ********************************************

    /// Instantiate controller for this Game Mode page
    mainEventLandingController = MainEventLandingBloc(userID: userID, gameRulesID: gameRulesID);
    await mainEventLandingController.preloadScreenSetup();

    /// Load the widgets and UI on the screen
    mainEventLandingController.loadUIOnScreen();
  }

  /// Widgets to display
  /// timer, play button, chart, text, bg video, leaderboard,
  /// see all player videos

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    Navigator.pop(context);
  }

  nextButtonAction() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.leftToRightWithFade,
            child: GameScreen(
                userID: userID,
                gameMap: mainEventLandingController.getTodaysGameMap,
                gameRulesID: gameRulesID,
                competitionID: mainEventLandingController.playerCompetitions[0].competitionInfo.id)));
  }

  playMainEventAction() {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GameScreen(
                userID: userID,
                gameMap: mainEventLandingController.getTodaysGameMap,
                gameRulesID: gameRulesID,
                competitionID: mainEventLandingController.playerCompetitions[0].competitionInfo.id)));
  }

  requestEventAccessAction() {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GetEventAccessOptionsScreen(
              userID: userID,
              gameMap: mainEventLandingController.getTodaysGameMap,
            )));
  }

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// convert time to user friendly format
  String getFriendlyDateFormat(DateTime dateToConvert) {
    DateFormat formatter = DateFormat('MMMd');
    return formatter.format(dateToConvert);
  }

  /// convert time to user friendly format
  String getFriendlyDateFormatForDay(DateTime dateToConvert) {
    DateFormat formatter = DateFormat('d');
    return formatter.format(dateToConvert);
  }

  /// Determine to use dateEnd (competition open: accepting submissions) or dateStart (competition announced) when counting down
  DateTime determineTimeToCountdownTowards(index) {
    DateTime competitionTimeToCountDownTowards;
    if (mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerStartsSoon == true) {
      competitionTimeToCountDownTowards = mainEventLandingController.playerCompetitions[index].competitionInfo.dateStart!.toUtc();
    } else if (mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerEndsSoon == true) {
      competitionTimeToCountDownTowards = mainEventLandingController.playerCompetitions[index].competitionInfo.dateEnd!.toUtc();
    } else {
      competitionTimeToCountDownTowards = DateTime.now().toUtc();
    }

    return competitionTimeToCountDownTowards;
  }

  bool determineDisplayCompetitionTimer(index) {
    bool displayTimer = false;
    if (mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerEndsSoon == true) {
      displayTimer = true;
    } else if (mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerStartsSoon == true) {
      displayTimer = true;
    }

    return displayTimer;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: mainEventLandingController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return DefaultTabController(
                length: mainEventLandingController.getCompetitions.length, // 2
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: primaryDojoColor,
                  appBar: AppBar(
                    title: Text('Main Event', style: PrimaryBT1()),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        print('tap');
                        backButtonAction();
                      },
                    ),
                    backgroundColor: primaryDojoColorLighter,
                    bottom: TabBar(
                      isScrollable: false,
                      tabs: [
                        Tab(text: '${getFriendlyDateFormat(mainEventLandingController.playerCompetitions[0].competitionInfo.dateEnd!)}'),
                        Tab(text: '${getFriendlyDateFormat(mainEventLandingController.playerCompetitions[1].competitionInfo.dateEnd!)}'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      competitionPage(context, 0), // today
                      competitionPage(context, 1), // previous competition
                    ],
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
        });
    // top module
  }

  Scaffold competitionPage(BuildContext context, int index) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.height * 1),
                  child: Stack(
                    children: <Widget>[
                      Opacity(
                        opacity: 0.70,
                        child: VideoFullScreen(
                            videoURL: mainEventLandingController.playerCompetitions[index].backgroundVideo, videoConfiguration: 5),
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                          height: (MediaQuery.of(context).size.height * 1.5),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row( // this ROW is a hack to force the app to consume the entire width of the screen
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16,
                                ),

                                /// SIFU Host Card
                                Visibility(
                                  visible: mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleHostCardOne,
                                  //visible: true,
                                  child: HostCard(
                                    headLineVisibility: false,
                                    bodyText: mainEventLandingController.playerCompetitions[index].hostCardMessages.message1,
                                    avatarName: 'SIFU',
                                  ),
                                ),
                                Visibility(
                                  visible: mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleHostCardTwo,
                                  child: HostCard(
                                      headLineVisibility: false,
                                      bodyText: mainEventLandingController.playerCompetitions[index].hostCardMessages.message2),
                                ),
                                SizedBox(height: 16),

                                /// competition ends soon (timer, button)
                                Visibility(
                                  visible:
                                  determineDisplayCompetitionTimer(index),
                                  child: CompetitionTimerCard(
                                    competitionTimeToCountdownTowards: determineTimeToCountdownTowards(index), // determines to pass a competitions start date or end date
                                    playButtonVisible:
                                        mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisiblePlayButton,
                                    playButtonAction: playMainEventAction,
                                    requestEventAccessButtonVisible:
                                    mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleRequestAccessButton,
                                    requestEventAccessButtonAction: requestEventAccessAction,
                                    competitionStartsSoon: mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerStartsSoon,
                                    competitionEndsSoon: mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleCompetitionTimerEndsSoon
                                  ),
                                ),

                                /// Leaderboard
                                Visibility(
                                  visible: mainEventLandingController.playerCompetitions[index].widgetVisibilityConfig.isVisibleLeaderboard,
                                  child: Leaderboard(
                                      leaderboardRecordsList:
                                          mainEventLandingController.playerCompetitions[index].leaderboardAndPlayerRank.leaderboardRecords),
                                ),
                                SizedBox(height: 16),

                                /// Pushup Line Chart
                                Visibility(
                                    visible: mainEventLandingController
                                        .playerCompetitions[index].widgetVisibilityConfig.isVisiblePushupsOverTimeChart,
                                    child: LineChart(playerRecords: mainEventLandingController.getPlayerRecords, title: 'Your Pushups Reps')),
                              ],
                            ),
                          ),
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
  }

  Container playButton() {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: HighEmphasisButtonWithAnimation(
          id: 1,
          title: 'PLAY NOW',
          onPressAction: nextButtonAction,
        ),
      ),
    );
  }
}
