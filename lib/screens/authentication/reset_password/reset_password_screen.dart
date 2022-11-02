import 'package:dojo_app/screens/authentication/auth_options/auth_options_screen.dart';
import 'package:dojo_app/screens/authentication/reset_password/reset_password_confirmation.dart';
import 'package:dojo_app/screens/onboarding/onboarding_start/onboarding_start_screen.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:dojo_app/widgets/tool_tip_card_v2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:keyboard_dismisser/keyboard_dismisser.dart';


class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String errorMsg = '';
  String email = '';
  // String password = '';
  // bool isChecked = false;
  // String nickname = 'Default';

  void emailInputFieldOnChange(value) {
    setState(() => email = value.trim());
    print('Email: $value');
  }

  void submitSignInInfo() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate() == true) {
      form!.save();

      final FirebaseAuth _auth2 = FirebaseAuth.instance;
      try {
        // send email
        await _auth2.sendPasswordResetEmail(email: email);

        // route to success page
        Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: ResetPasswordConfirmation()));
      } catch(e) {
        // send error to firebase

        // inform the user
        GeneralService.displaySnackBar(context, 'Sorry, something went wrong. Dojo team was informed!');
      }
    }
  }

  void backButtonAction() {
    Navigator.pop(context);
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsSignUpEvent() async {
    await globals.Analytics.analytics.logSignUp(signUpMethod: 'email'); //Google Analytics tracking
  }


  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: [
        GestureType.onTap,
        GestureType.onPanUpdateAnyDirection
      ],
      child: Container(
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
            resizeToAvoidBottomInset: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  margin: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: (MediaQuery.of(context).size.height) -
                            (MediaQuery.of(context).padding).top -
                            (MediaQuery.of(context).padding).bottom,
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () {
                                            print('tap');
                                            backButtonAction();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Form(
                                  key: _formKey,
                                  autovalidateMode: AutovalidateMode.always,
                                  child: Column(
                                    children: <Widget>[
                                      HostCard(
                                        bodyText: 'Enter your email address to receive reset instructions.',
                                        headLine: 'RESET PASSWORD',
                                        boxCard: false,
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      ToolTipCardV2(message: 'Don\'t forget to check your email spam folder'),
                                      spaceVertical2(context: context, half: true),
                                      CustomTextFieldRegistration(
                                          inputLabel: 'Email Address',
                                          hint: '',
                                          onSaved: emailInputFieldOnChange,
                                          validator: emailValidator,
                                          keyboardType: TextInputType.emailAddress),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HighEmphasisButton(
                                        title: 'SEND RESET EMAIL',
                                        onPressAction: submitSignInInfo,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

String? emailValidator(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);

  var trimmedValue = value!.trim(); //trims input

  if (trimmedValue.isEmpty) return '* Required';
  if (!regex.hasMatch(trimmedValue))
    return '* Enter a valid email';
  else
    return null;
}

String? isPasswordValid(String? password) {
  if (password!.length < 6) {
    return '6 character minimum';
  } else {
    return null;
  }
}
