import 'package:dojo_app/screens/authentication/nickname_screen.dart';
import 'package:dojo_app/screens/start/start_screen.dart';
import 'package:dojo_app/screens/game_mode_select/game_mode_select_screen.dart';
import 'package:dojo_app/screens/wrapper_bloc.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'authentication/verify_email_screen.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late WrapperBloc wrapperController = WrapperBloc();

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() async {}

  @override
  Widget build(BuildContext context) {
    // Get user information
    final user = Provider.of<DojoUser?>(context);

    // store user object in globals file
    GeneralService.setGlobalUser(user);

    // execute bloc methods, and then load this screens UI
    if (user != null) {
      String userID = user.uid;
      wrapperController.preloadScreenSetup(userID);
    } else {
      return StartScreen();
    }

    return StreamBuilder<Map>(
        stream: wrapperController.wrapperStream,
        initialData: {'ready': false},
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;

            /// Determine where to route the user
            if (ready == true) {
              User? fireBaseAuthUser = FirebaseAuth.instance.currentUser;

              // users who registered via email must verify their email address to continue
              // note: providerID == 'password' infers they used an email address to create an account
              if (user.providerData[0].providerId == 'password' && fireBaseAuthUser != null && !fireBaseAuthUser.emailVerified && false) { /// ChangeForProduction, remove false ///
                return VerifyEmailScreen(emailAddress: user.emailAddress, dojoUser: user);

              } else if (globals.nickname == 'Default' || globals.nickname == 'Player') {
                // if the nickname is 'default' or 'player' then they have never visited the nickname form so send the user there
                return NicknameScreen();

              } else {
                return GameModeSelectScreen();
              }

              /// Return loading screen
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
  }
}
