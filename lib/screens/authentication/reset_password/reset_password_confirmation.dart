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

class ResetPasswordConfirmation extends StatefulWidget {
  const ResetPasswordConfirmation({Key? key,}) : super(key: key);

  @override
  State<ResetPasswordConfirmation> createState() => _ResetPasswordConfirmationState();
}

class _ResetPasswordConfirmationState extends State<ResetPasswordConfirmation> with SingleTickerProviderStateMixin {

  // Redirect the user back to the logged out state, and sign them out
  // note: when registering, you are auto signed in, but app blocks you from moving forward if your email address is not verified
  gotoSignIn() async {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: SignIn(existingUser: false,)), (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
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

                              /// Host Card
                              HostCard(
                                headLine: 'Email sent',
                                headLineVisibility: true,
                                bodyText: 'Please check your email for instructions to reset your Dojo password.',
                                boxCard: false,
                              ),

                              ToolTipCardV2(message: 'Don\'t forget to check your email spam folder'),

                              spaceVertical2(context: context),

                              /// Start Over
                              MediumEmphasisButton(
                                title: 'Go back to Sign In',
                                onPressAction: gotoSignIn,
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
