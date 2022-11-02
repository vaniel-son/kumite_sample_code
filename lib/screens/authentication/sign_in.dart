import 'package:dojo_app/screens/authentication/auth_options/auth_options_screen.dart';
import 'package:dojo_app/screens/authentication/reset_password/reset_password_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:flutter/cupertino.dart';


class SignIn extends StatefulWidget {

  SignIn({required this.existingUser});

  // This variable gets passed into auth method to check if their is existing user.
  final bool existingUser;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String headline = '';

  void emailInputFieldOnChange(value) {
    setState(() => email = value.trim());
    print('Email: $value');
  }

  void passwordInputFieldOnChange(value) {
    setState(() => password = value.trim());
    print('Password: $value');
  }

  void submitSignInFromOnPress() async {
    final FormState? form = _formKey.currentState;

    if (_formKey.currentState!.validate()) {
      dynamic dojoUser;

      form!.save();

      try {
        GeneralService.displaySnackBar(context, 'Opening Dojo gates...');
        dojoUser = await _auth.signInWithEmailAndPassword(email, password, context);
      } catch(e) {
        // catch error via firebase and..
        GeneralService.displaySnackBar(context, 'Error signing in. Dojo team has been notified.');
      }

      if (dojoUser != null) {
        _sendAnalyticsLoginEvent();
        SoundService.cheer(); // sfx
        SoundService.popBonus(); // sfx
        Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.topToBottom, child: Wrapper()), (Route<dynamic> route) => false);
        // AfterAuthRoutingService.afterEmailSignInOrCreateRouteTheUserHere(dojoUser, context);
      } else {
        GeneralService.displaySnackBar(context, 'Sign in failed, please try again');
      }
    }
  }

  /*void afterSignIn(dojoUser) {
    //_auth.routeAfterSignUpOrSignIn(dojoUser, context);
    AfterAuthRoutingService.afterGoogleOrAppleAuthThenRouteUserHere(dojoUser, context);
  }*/

  void backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: AuthOptionsScreen()), (Route<dynamic> route) => false);
  }

  void forgotPasswordButton() {
    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: ResetPasswordScreen()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsLoginEvent() async {
    await globals.Analytics.analytics.logLogin(); //Google Analytics tracking
  }

  @override
  void initState() {
    if(widget.existingUser == true)
      {
        headline = "YOU'VE ALREADY SIGNED UP";
      }
    else {
      headline = 'SIGN IN';
    }
    super.initState();
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
                          Opacity(opacity: 0.3, child: BackgroundTopImage(imageURL: 'images/luna-bull-village-01.jpg')),
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
                                      headLine: headline,
                                      bodyText:
                                          '',
                                      boxCard: false,
                                    ),
                                    CustomTextFieldRegistration(
                                        inputLabel: 'Email Address',
                                        hint: '',
                                        onSaved: emailInputFieldOnChange,
                                        validator: emailValidator,
                                        keyboardType: TextInputType.emailAddress),
                                    CustomTextFieldRegistration(
                                        inputLabel: 'Password',
                                        hint: '',
                                        onSaved: passwordInputFieldOnChange,
                                        validator: isPasswordValid,
                                        keyboardType: TextInputType.visiblePassword),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    HighEmphasisButton(
                                      title: 'SIGN IN',
                                      onPressAction: submitSignInFromOnPress,
                                    ),
                                    spaceVertical2(context: context),

                                    SizedBox(
                                      width:  (MediaQuery.of(context).size.width),
                                      child: LowEmphasisButton(
                                        title: 'Forgot password?',
                                        onPressAction: forgotPasswordButton,
                                      ),
                                    )

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
          ),
        ),
      ),
    );
  }
}


///Checks if email is valid format and trim any trailing space
String? emailValidator(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);

  var trimmedValue = value!.trim();  //trims input

  if (trimmedValue.isEmpty) return '* Required';
  if (!regex.hasMatch(trimmedValue))
    return '*Enter a valid email';
  else
    return null;
}


///Checks if password is at least 6 characters
String? isPasswordValid(String? password) {
  if (password!.length < 6) {
    return '6 character minimum';
  } else {
    return null;
  }
}
