import 'package:dojo_app/screens/authentication/sign_in.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/widgets/tool_tip_card_v2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({required this.emailAddress, required this.dojoUser,
    Key? key,
  }) : super(key: key);

  final String? emailAddress;
  final dynamic dojoUser;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> with SingleTickerProviderStateMixin {

  // check if the user has been verified
  void checkVerification() async {
    User? user = FirebaseAuth.instance.currentUser;

    // if user is verified => route to after auth class, which determines: send user to nickname page OR wrapper
    if (user!= null && user.emailVerified) {
      // AfterAuthRoutingService.afterEmailSignInOrCreateRouteTheUserHere(widget.dojoUser, context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter, child: Wrapper()));
    }

    // if user is not verified => display snack bar message that the user is not verified
    if (user!= null && !user.emailVerified) {
      Navigator.pop(context);
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false)));
      GeneralService.displaySnackBar(context, 'Sign in with your verified email address');
    }

    // if no user then ask them to sign in an try again
    // in this case, the dojoUser variable must have expired
    if (user == null || widget.dojoUser == null) {
      Navigator.pop(context);
      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: SignIn(existingUser: false)));
      GeneralService.displaySnackBar(context, 'Too much time has passed... please login to try again');
    }
  }

  // Redirect the user back to the logged out state, and sign them out
  // note: when registering, you are auto signed in, but app blocks you from moving forward if your email address is not verified
  startOver() async {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Wrapper()), (Route<dynamic> route) => false);
    GeneralService.signOut();
  }

  backButtonAction(){
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    // send verification email to user
    User? firebaseAuthUser = FirebaseAuth.instance.currentUser;
    firebaseAuthUser!.sendEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColorDark1,
          ],
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity * .9,
                    height: (MediaQuery.of(context).size.height) -
                        (MediaQuery.of(context).padding).top -
                        (MediaQuery.of(context).padding).bottom,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              spaceVertical(context),
                              spaceVertical(context),

                              /// Host Card
                              HostCard(
                                headLine: 'Verify your email to continue',
                                headLineVisibility: true,
                                bodyText: 'An email has been sent to you. \n\nIn the email, click on the link to verify you own the email address.',
                                boxCard: false,
                              ),

                              ToolTipCardV2(message: 'Don\'t forget to check your email spam folder'),

                              spaceVertical2(context: context),
                              spaceVertical2(context: context),

                              /// Try to move forward
                              HighEmphasisButtonWithAnimation(
                                title: 'I verified my email',
                                onPressAction: checkVerification,
                              ),

                              spaceVertical2(context: context),

                              /// Start Over
                              MediumEmphasisButton(
                                title: 'Restart',
                                onPressAction: startOver,
                                //buttonEnabled: false,
                                onPrimaryColor: captionColor,
                              ),

                            ],
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
      ),
    );
  }
}
