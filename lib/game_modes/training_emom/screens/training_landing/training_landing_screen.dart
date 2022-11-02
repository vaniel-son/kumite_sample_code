import 'package:dojo_app/game_modes/training_emom/screens/game/game_screen.dart';
import 'package:dojo_app/game_modes/training_emom/screens/max_rep_form/max_rep_form_screen.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/widgets/emom_score_box.dart';
import 'package:dojo_app/game_modes/training_emom/widgets/pho_leaderboard.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/resource_earned_small.dart';
import 'package:dojo_app/widgets/smallDataPill.dart';
import 'package:page_transition/page_transition.dart';
import 'training_landing_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/constants.dart' as constants;
import 'package:intl/intl.dart';

//ignore: must_be_immutable
class TrainingLandingScreen extends StatefulWidget {
  TrainingLandingScreen() {
    // Constructor
  }

  @override
  _TrainingLandingScreenState createState() => _TrainingLandingScreenState();
}

class _TrainingLandingScreenState extends State<TrainingLandingScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  String gameRulesID = constants.GameRulesConstants.pemomPushups;
  late String userID = globals.dojoUser.uid;

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late TrainingLandingBloc trainingLandingController;

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
    trainingLandingController = TrainingLandingBloc(userID: userID, gameRulesID: gameRulesID);
    await trainingLandingController.preloadScreenSetup();

    /// Load the widgets and UI on the screen
    trainingLandingController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    Navigator.pop(context);
  }

  /// Normally, sends the user to the game screen
  // but this is hijacked when we discover the user has never provided
  // a max rep score. By default, a user has a max pushup rep score of 0
  // so when this is 0, send the user to the max rep form to collect this #
  trainNowButtonAction() async {
    SoundService.pressPlay(); // play SFX

    // send to screen that asks for their max rep count
    if (trainingLandingController.maxRepCount == 0) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: MaxRepFormScreen()));

    } else if(trainingLandingController.maxRepCount > 0) {

      // they have a max rep count, so sen them to the game screen
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRightWithFade,
              child: GameScreen(
                userID: userID,
                gameRulesID: gameRulesID,)));
    }
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

  List<Widget> getTabBarViewItems() {
    List<Widget> tabBarViewItems = [];
    for (int i = 0; i < trainingLandingController.getPlayerTrainingGames.length; i++) {
      tabBarViewItems.add(trainingPage(context, i));
    }

    return tabBarViewItems;
  }

  ///  Store UI tab data dynamically
  // why: the UI will always show a minimum of 2 tabs (1 for each game)
  // if there are more than 2 tabs, then the tabs need to update to reflect this
  // so based on the # of game docs, we will create that many tabs

  // create tabBar items list
  /*List<Tab> tabBarItems = [];

  tabBarItems = [
  Tab(text: 'today'),
  Tab(text: 'previous'),
  ];*/

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: trainingLandingController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return DefaultTabController(
                // length: trainingLandingController.getPlayerTrainingGames.length, // 2
                length: 2,
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: primarySolidBackgroundColor,
                  appBar: AppBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Training', style: PrimaryBT1()),
                        Row(
                          children: [
                            Container(child: DataPillSmall(data: 'LVL ${trainingLandingController.getPlayerLevel}'),),
                            SizedBox(width:8),
                            ResourceEarnedSmall(resourceEarnedCount: trainingLandingController.getPhoBowlEarnedCount),],
                        ),
                      ],
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        backButtonAction();
                      },
                    ),
                    backgroundColor: primaryColorLight1,
                    bottom: TabBar(
                      isScrollable: false,
                      tabs: [
                        Tab(text: 'Today'),
                        Tab(text: '${getFriendlyDateFormat(trainingLandingController.playerTrainingGames[1].gameInfo.dateStart)}'),
                      ],
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      trainingPage(context, 0), // today
                      trainingPage(context, 1), // previous competition
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

  Scaffold trainingPage(BuildContext context, int index) {
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
                        opacity: 0.50,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('images/dojo_train_bg2.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
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
                                  visible: trainingLandingController.playerTrainingGames[index].widgetVisibilityConfig.isVisibleHostCardOne,
                                  //visible: true,
                                  child: HostCard(
                                    headLineVisibility: false,
                                    bodyText: trainingLandingController.playerTrainingGames[index].hostCardMessages.message1,
                                    avatarName: 'SIFU',
                                  ),
                                ),
                                Visibility(
                                  visible: trainingLandingController.playerTrainingGames[index].widgetVisibilityConfig.isVisiblePlayButton,
                                  //visible: true,
                                  child: playButton(),
                                ),
                                SizedBox(height: 16),
                                Visibility(
                                  visible: trainingLandingController.playerTrainingGames[index].widgetVisibilityConfig.isVisibleEmomScoreBox,
                                  child: Column(
                                    children: [
                                      spaceVertical2(context: context, half: true),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context, half: true),]
                                  ),
                                ),
                                Visibility(
                                  visible: trainingLandingController.playerTrainingGames[index].widgetVisibilityConfig.isVisibleEmomScoreBox,
                                  //visible: true,
                                  child: EMOMScoreBox(playerRoundOutcomes: trainingLandingController.playerTrainingGames[index].playerRoundOutcomes, playerLevel: trainingLandingController.playerTrainingGames[index].playerLevel),
                                ),

                                spaceVertical2(context: context, half: true),
                                Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                spaceVertical2(context: context, half: true),

                                /// Pho Leaderboard
                                Builder(
                                  builder: (context) {
                                    if (index == 0) {
                                      return Leaderboard(
                                          leaderboardRecordsList: trainingLandingController.getPhoBowlLeaderboardRecords, title: 'SEND PHO TO PLAYERS');
                                    } else {
                                      return Container();
                                    }
                                  }
                                )
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
          title: 'TRAIN NOW',
          onPressAction: trainNowButtonAction,
        ),
      ),
    );
  }
}
