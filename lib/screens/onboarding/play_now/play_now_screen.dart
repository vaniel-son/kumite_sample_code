import 'package:dojo_app/game_modes/training_emom/screens/training_landing/training_landing_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'play_now_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/constants.dart' as constants;

//ignore: must_be_immutable
class PlayNowScreen extends StatefulWidget {
  PlayNowScreen() {
    // Constructor
  }

  @override
  _PlayNowScreenState createState() => _PlayNowScreenState();
}

class _PlayNowScreenState extends State<PlayNowScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  String gameRulesID = constants.GameRulesConstants.kohPushupMax60;
  String competitionID = '8Ik0hbNSZzkHcJaJ16WX';

  late String userID = globals.dojoUser.uid;
  Map gameMap = {};
  late String nickname;

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late PlayNowBloc playNowController;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    playNowController.dispose();
    super.dispose();
  }

  void setup() async {
    /// *******************************************
    /// Preload required data before loading screen or bloc
    /// ********************************************

    /// Instantiate controller for this Game Mode page
    playNowController = PlayNowBloc(userID: userID, gameRulesID: gameRulesID);
    await playNowController.preloadScreenSetup();

    /// Load Widgets and UI on this screen
    playNowController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    //
  }

  nextButtonAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: TrainingLandingScreen()));
    _sendAnalyticsEventPlayButtonOnBoarding();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsEventPlayButtonOnBoarding() async {
    await globals.Analytics.analytics.logEvent(
      name: 'play_game_onboarding',
      parameters: <String, dynamic>{
        'Game Button Pressed': true,
      },
    );
  }



  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: playNowController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: primarySolidBackgroundColor,
                body: SafeArea(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      VideoFullScreen(videoURL: '${playNowController.backgroundVideo}', videoConfiguration: 3),
                      BackgroundOpacity(opacity: 'medium'),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 92,
                          ),
                          Image.asset(
                            'images/dojo_logo_2.png',
                            //height: 245.96,
                            width: 200,
                          ),
                          SizedBox(height: 64),
                          /*CompetitionEndsSoon(
                            competitionEndDate: playNowController.playerCompetitions[0].competitionInfo.dateEnd!,
                            // buttonVisible: homeController.playerCompetitions[index].widgetVisibilityConfig.isVisiblePlayButton,
                            playButtonVisible: true,
                            playButtonAction: nextButtonAction,
                          ),*/
                        ],
                      ),
                      Positioned(
                        bottom: 40,
                        child: HighEmphasisButtonWithAnimation(
                          id: 1,
                          title: 'PLAY',
                          onPressAction: nextButtonAction,
                        ),
                      ),
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
}
