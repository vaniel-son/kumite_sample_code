import 'dart:async';
import 'package:dojo_app/screens/authentication/register.dart';
import 'package:dojo_app/screens/authentication/sign_in.dart';
import 'package:dojo_app/screens/lock_screen/lock_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:page_transition/page_transition.dart';
import 'auth_options_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'dart:io' show Platform;

//ignore: must_be_immutable
class AuthOptionsScreen extends StatefulWidget {
  AuthOptionsScreen() {
    // Constructor
  }

  @override
  _AuthOptionsScreenState createState() => _AuthOptionsScreenState();
}

class _AuthOptionsScreenState extends State<AuthOptionsScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String nickname;
  late String userID = globals.dojoUser.uid;
  final AuthService _auth = AuthService();

  /// Manage state of player so this leaderboard knows what to load
  // labeled as "leaderboardStatus" on the leaderboard collection
  // the state is based on the leaderboard 'status' field
  // options are: pending (no judge consensus yet), confirmed (judge consensus met), winner (a winner has been picked)
  // in method setup(), this is set to the correct state base on the player's leaderboard "status"
  late String playerState = 'pending'; // default

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late AuthOptionsBloc authOptionsController;

  /// StreamController to manage loading required data before moving forward
  // to load this screen
  final _authOptionsWrapperController = StreamController<Map>();
  Stream<Map> get authOptionsWrapperStream => _authOptionsWrapperController.stream;
  Sink<Map> get authOptionsWrapperSink => _authOptionsWrapperController.sink;

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    _authOptionsWrapperController.close();
    super.dispose();
  }

  void setup() async {
    /// *******************************************
    /// Preload required data before loading screen or bloc
    /// ********************************************

    /// Instantiate controller for this Game Mode page
    authOptionsController = AuthOptionsBloc();
    await authOptionsController.preloadScreenSetup();
    await authOptionsController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    print('do nothing');
  }

  void createAccountWithEmailButtonOnPress() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: Register()), (Route<dynamic> route) => false);
  }

  void signInButtonOnPress() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false,)), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google / Apple Sign in methods
  /// ***********************************************************************
  /// ***********************************************************************

  void signInWithGoogleButtonOnPress() async {
    try {
      GeneralService.displaySnackBar(context,'Opening Dojo gates...');
      dynamic dojoUser = await _auth.signInWithGoogle(context: context);
      authOptionsController.afterGoogleOrAppleAuthThenRouteUserHere(dojoUser, context, userID);
    } catch(e) {
      // catch with firebase analytics
    }
  }

  void signInWithAppleButtonPress() async {
    try {
      GeneralService.displaySnackBar(context, 'Opening Dojo gates...');
      dynamic dojoUser = await _auth.signInWithApple();
      authOptionsController.afterGoogleOrAppleAuthThenRouteUserHere(dojoUser, context, userID);
    } catch(e) {
      // catch with firebase analytics
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Widget determineThirdPartySignUpOptions(BuildContext context) {
    if (Platform.isAndroid) {
      return GoogleOrAppleSignInButton(
        slaveMaster: 'google',
        title: 'Continue with Google',
        onPressAction: signInWithGoogleButtonOnPress,
      );
    } else if (Platform.isIOS) {
      return Column(
          children: [
            GoogleOrAppleSignInButton(
              slaveMaster: 'google',
              title: ' Continue with Google',
              onPressAction: signInWithGoogleButtonOnPress,
            ),
            SizedBox(
              height: 16,
            ),
            GoogleOrAppleSignInButton(
              slaveMaster: 'apple',
              title: ' Continue with Apple',
              onPressAction: signInWithAppleButtonPress,
              primaryColor: Colors.black,
            )
          ],
        );
    } else {
      return Container();
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: authOptionsController.wrapperStream,
        initialData: {
          'ready': false,
          'lockScreenType': 'none',
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {

            /// Lock screen management
            if (authOptionsController.thisScreenLocked(snapshot.data!['lockScreenType'])) {
              return LockScreen(lockScreenType: snapshot.data!['lockScreenType']);
            }

            /// Load full UI
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: primarySolidBackgroundColor,
                body: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    //TODO: I believe there is a videoController that isn't getting disposed here, need to fix this in the future.
                    VideoFullScreen(videoURL: 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/hackathon_videos%2Fbq-Assibey-stairs-short.mp4?alt=media&token=b42965a4-879a-4cf2-888f-9f5dea60b1b2', videoConfiguration: 3),
                    BackgroundOpacity(opacity: 'medium'),
                    Column(
                      children: [
                        spaceVertical2(context: context, half: false),
                        spaceVertical2(context: context, half: false),
                        spaceVertical2(context: context, half: false),
                        spaceVertical2(context: context, half: false),
                        Image.asset(
                        'images/dojo_logo_2.png',
                        //height: 245.96,
                        width: 150,
                      ),
                      HostCard(
                        bodyText: 'Train everyday with Dojo to become a pushup master.',
                        headLineVisibility: false,
                        boxCard: false,
                      ),
                    ],),
                    Positioned(
                      bottom:40,
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            MediumEmphasisButton(
                              title: 'Register with Email',
                              onPressAction: createAccountWithEmailButtonOnPress,
                            ),

                            SizedBox(height:15),

                            determineThirdPartySignUpOptions(context),

                            spaceVertical2(context: context, half: true),
                            Divider(height: 10.0, thickness: 1.0, indent: 24.0, endIndent: 24, color: greenSuccess),
                            spaceVertical2(context: context, half: true),

                            MediumEmphasisButton(title: 'Login with Email',onPressAction: signInButtonOnPress,onPrimaryColor: captionColor,)
                          ],
                        ),
                      ),
                    ),
                  ],
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
