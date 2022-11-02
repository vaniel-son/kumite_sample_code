import 'package:dojo_app/screens/onboarding/how_to_play/how_to_play_screen.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'onboarding_start_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class OnboardingStartScreen extends StatefulWidget {
  OnboardingStartScreen() {
    // Constructor
  }

  @override
  _OnboardingStartScreenState createState() => _OnboardingStartScreenState();
}

class _OnboardingStartScreenState extends State<OnboardingStartScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late OnboardingStartBloc onboardingStartController;

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
    /// Instantiate controller for this Game Mode page
    onboardingStartController = OnboardingStartBloc();

    /// Load required data before loading this screen's widgets
    await onboardingStartController.preloadScreenSetup();

    /// Load this screen's UI
    await onboardingStartController.loadUIOnScreen();
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
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: HowToPlayScreen()));
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
        stream: onboardingStartController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff00528E),
                      Color(0xff002A60),
                    ],
                  ),
                ),
                child: Scaffold(
                  //resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  body: SafeArea(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        /*Positioned(
                          right:10,
                          bottom: 0,
                          child: Image.asset(
                            'images/sifu.png',
                            height: 450,
                          ),
                        ),*/
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Image.asset(
                              'images/dojo_logo_2.png',
                              //height: 245.96,
                              width: 150,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            HostCard(
                              headLineVisibility: true,
                              headLine: 'SUCCESS!',
                                bodyText:
                                'Next, I must teach you how to play so you can become a master.',
                                boxCard: false,
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                        Positioned(
                          bottom:40,
                          child: HighEmphasisButtonWithAnimation(
                            id: 1,
                            title: 'TEACH ME HOW TO PLAY',
                            onPressAction: nextButtonAction,
                          ),
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
        });
    // top module
  }
}
