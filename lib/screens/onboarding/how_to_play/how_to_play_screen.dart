import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/screens/authentication/nickname_screen.dart';
import 'package:dojo_app/screens/authentication/verify_email_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'how_to_play_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;

//ignore: must_be_immutable
class HowToPlayScreen extends StatefulWidget {
  HowToPlayScreen() {
    // Constructor
  }

  @override
  _HowToPlayScreenState createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late HowToPlayBloc howToPlayController;
  String bodyText = 'Do as many push-ups as you can in 60 seconds';

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// *******************************************
  /// Preload required data before loading screen or bloc
  /// ********************************************

  void setup() async {
    /// Instantiate controller for this Game Mode page
    howToPlayController = HowToPlayBloc();
    await howToPlayController.preloadScreenSetup();

    /// Load the UI on this screen
    howToPlayController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    //
  }

  finishTutorial(user) {
    if (user.providerData[0].providerId == 'password') {
      // provider = 'password' infers they used their email to sign up, so route them to verify their email address
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: VerifyEmailScreen(emailAddress: user.emailAddress, dojoUser: user)));
    } else {
      // For other provider types (apple, google), direct directly to nickname screen
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: NicknameScreen()));
    }

  }

  onPressButtonAction(constantsKOH.TutorialStage tutorialStage, user) {
    /// either exit the game, or
    // move to the next gameStage
    if (tutorialStage == constantsKOH.TutorialStage.end) {
      finishTutorial(user);
    } else {
      howToPlayController.howToPlayTutorialStagesSink.add(tutorialStage);
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
    return StreamBuilder<Map>(
        stream: howToPlayController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return StreamBuilder<Map>(
                stream: howToPlayController.howToPlayDataStream,
                builder: (context, snapshot2) {
                  if(snapshot2.data != null){
                  final uiDataMap = snapshot2.data as Map;
                  return Scaffold(
                    backgroundColor: primarySolidBackgroundColor,
                    body: SafeArea(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          VideoFullScreen(videoURL: uiDataMap['videoURL'], videoConfiguration: 6, newKey: UniqueKey(),),
                          Column(
                            children: [
                              SizedBox(height: 60,),
                              Container(
                                child: HostCard(bodyText: uiDataMap['hostCardBodyText'],
                                  headLineVisibility: false,
                                  // headLine: howToPlayController.getNickname,
                                  variation:5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Positioned(
                            bottom:40,
                            child: HighEmphasisButtonWithAnimation(
                              id: 1,
                              title: uiDataMap['buttonTitle'],
                              onPressAction: () {
                                final user = Provider.of<DojoUser?>(context, listen: false); // provides user auth data
                                onPressButtonAction(uiDataMap['nextTutorialStage'], user);
                                },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                 } else{
                    return Stack(
                      children: [
                        LoadingScreen(displayVisual: 'loading icon'),
                        BackgroundOpacity(opacity: 'medium'),
                      ],
                    );
                  }
                }
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
    // top module
  }
}
