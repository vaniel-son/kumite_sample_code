import 'package:dojo_app/screens/update_wallet_address/update_wallet_address_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/globals.dart' as globals;

class NicknameScreen extends StatefulWidget {
  const NicknameScreen({Key? key}) : super(key: key);

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  String nickname = '';
  final _formKey = GlobalKey<FormState>();
  DatabaseServices databaseServiceShared = DatabaseServices();

  late CollectionReference users = FirebaseFirestore.instance.collection('users');

  late User? dojoUser = FirebaseAuth.instance.currentUser;
  late String userID = dojoUser!.uid;

  Future<void> submitNickname() async {
    final FormState? form = _formKey.currentState;

    if(_formKey.currentState!.validate()) {
      GeneralService.displaySnackBar(context, 'Informing everyone that you have arrived...');

      form!.save();

      // save nickname to firebase
      await databaseServiceShared.updateNickname(userID: userID, nickname: nickname);

      // store user in global variable
      GeneralService.setGlobalUser(dojoUser);

      // store nickname
      globals.nickname = nickname;

      // route to next screen
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter,
          child: UpdateWalletAddressScreen(
            updateCheck: false,
            updatePageHostCardVisibility: false ,
            updatePageButtonVisibility: false,
            newPageButtonVisibility: true,
            newPageHostCardVisibility: true,
            skipButtonVisibility: true,
            backButtonVisibility: false,
          )
      )
      );

      /*return users
          .doc(userID)
          .update({'Nickname': nickname})
          .then(
              (value) =>
              AfterAuthRoutingService.afterNicknameAddRouteUserHere(dojoUser,context)
      )
          .catchError((error) => print("Failed to update user: $error"));*/
    }
  }

  void nicknameInputFieldOnChange(value) {
    setState(() => nickname = value.trim());
    print('Nickname: $value');
  }

  void backButtonAction() {
    Navigator.pop(context, []);
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
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          /*appBar: AppBar(
            backgroundColor: primarySolidBackgroundColor,
            centerTitle: true,
          ),*/
          body: SafeArea(
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
                      alignment: Alignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Image.asset(
                              'images/dojo_logo_2.png',
                              //height: 245.96,
                              width: 200,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            HostCard(
                              bodyText: 'Every Dojo competitor needs a good nickname!',
                              headLineVisibility: false,
                              boxCard: false,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Form(
                              key: _formKey,
                              child: CustomTextFieldRegistration(
                                  inputLabel: 'Provide a nickname',
                                  hint: 'What can I call you?',
                                  onSaved: nicknameInputFieldOnChange,
                                  validator: nicknameValidator,
                                  keyboardType: TextInputType.text),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 40,
                          child: HighEmphasisButton(
                            title: 'Save',
                            onPressAction: submitNickname,
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

String? nicknameValidator(String? value) {
  if (value!.isEmpty) return '* Required';
  if (value.length < 1) {
    return 'Must provide a nickname to play!';
  }
  else if(value.length > 20) {
    return 'Nickname is too long';
  }
  else{
    return null;
  }
}