import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/main_event_landing_screen.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/training_landing_screen.dart';
import 'package:dojo_app/screens/lock_screen/lock_screen.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/game_mode_card.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'game_mode_select_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class GameModeSelectScreen extends StatefulWidget {
  GameModeSelectScreen() {
    // Constructor
  }

  @override
  _GameModeSelectScreenState createState() => _GameModeSelectScreenState();
}

class _GameModeSelectScreenState extends State<GameModeSelectScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String userID = globals.dojoUser.uid;

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late GameModeSelectBloc gameModeSelectController;

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
    gameModeSelectController = GameModeSelectBloc(userID: userID);
    await gameModeSelectController.preloadScreenSetup(); // get required data before loading the UI on this screen
    gameModeSelectController.loadUIOnScreen(); // Load the widgets and UI on the screen
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    // print('do nothing');
  }

  nextButtonAction() {
    // do something
  }

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  pushupEMOM() {
    SoundService.buttonClickOne(); // play SFX
    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: TrainingLandingScreen()));
  }

  mainEvent() {
    SoundService.buttonClickOne();
    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: MainEventLandingScreen()));
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
    return StreamBuilder<Map>(
        stream: gameModeSelectController.wrapperStream,
        initialData: {
          'ready': false,
          'lockScreenType': 'none',
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {

            /// Lockscreen management
            // if this screen type has a lock enabled, then the lock screen will display
            if (gameModeSelectController.thisScreenLocked(snapshot.data!['lockScreenType'])) {
              return LockScreen(lockScreenType: snapshot.data!['lockScreenType']);
            }

            /// Load full UI
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return DefaultTabController(
                length: 2,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: primarySolidBackgroundColor,
                  appBar: AppBar(
                    title: Image.asset(
                      'images/dojo_logo_2.png',
                      fit: BoxFit.cover,
                      height: AppBar().preferredSize.height * .33,
                      //height: 245.96,
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        menuAction();
                      },
                    ),
                    backgroundColor: primarySolidBackgroundColor,
                    bottom: TabBar(
                      isScrollable: false,
                      tabs: [
                        Tab(text: 'Train'),
                        Tab(text: 'Main Event'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      trainPage(context, 0), // previous competition
                      mainEventPage(context, 1), // today
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

  Scaffold mainEventPage(BuildContext context, int index) {
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
                            videoURL: gameModeSelectController.getBackgroundVideo, videoConfiguration: 5),
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
                                Visibility(
                                  visible: true,
                                  child: HostCard(
                                    headLineVisibility: false,
                                    bodyText: gameModeSelectController.sifuCopy,
                                    avatarName: 'SIFU',
                                  ),
                                ),
                                GameModeCard(
                                  onPressAction: () {
                                    mainEvent();
                                  },
                                  subtitleIcon: FontAwesomeIcons.universalAccess,
                                  subtitle: 'Main Event',
                                  title: 'Pushups: 60s',
                                  description: 'How many reps can you perform in 60s?',
                                  icon2x: true,
                                  dataPillContent1: '${gameModeSelectController.latestCompetitionStartDateFormatted}',
                                ),
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

  Scaffold trainPage(BuildContext context, int index) {
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
                        opacity: .8,
                        //child: VideoFullScreen(videoURL: videoURLTemp, videoConfiguration: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/bg_train_app_01.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
                                Visibility(
                                  visible: true,
                                  child: HostCard(
                                    headLineVisibility: false,
                                    bodyText: "${gameModeSelectController.getNickname}, train once per day to earn Pho bowls.",
                                    avatarName: 'SIFU',
                                  ),
                                ),
                                SizedBox(height:16),
                                GameModeCard(
                                  onPressAction: () {
                                    pushupEMOM();
                                  },
                                  subtitleIcon: FontAwesomeIcons.universalAccess,
                                  subtitle: 'Training',
                                  title: 'Pushup EMOM',
                                  description: 'Pushups every minute, on the minute: 3 mins',
                                  icon2x: false,
                                  dataPillContent1: 'Level ${gameModeSelectController.getPlayerLevel}',
                                  dataPillContent2: '${gameModeSelectController.getPhoBowlsEarnedCount} pho bowls',
                                ),
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
}
