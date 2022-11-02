import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/training_emom/screens/max_rep_form/max_rep_form_bloc.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/close_icon_button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:page_transition/page_transition.dart';

class MaxRepFormScreen extends StatefulWidget {
  const MaxRepFormScreen({Key? key}) : super(key: key);

  @override
  State<MaxRepFormScreen> createState() => _MaxRepFormScreenState();
}

class _MaxRepFormScreenState extends State<MaxRepFormScreen> {

  late String reps;
  final _formKey = GlobalKey<FormState>();
  late CollectionReference users = FirebaseFirestore.instance.collection('users');
  late User? dojoUser = FirebaseAuth.instance.currentUser;
  late String userID = dojoUser!.uid;
  int actualEmomReps = 0;


  MaxRepBloc maxRepController = MaxRepBloc();

  void repInputFieldOnChange(value) {
    setState(() => reps = value.trim() );
    print('Rep Count: $value');
  }

  // Execute a series of methods are called to submit the rep data
  Future<void> submitRepData() async {
    final FormState? form = _formKey.currentState;

    if(_formKey.currentState!.validate()) {
      form!.save();

      //Convert Reps to integer
      int repsInt = int.parse(reps);

      //Calculate training reps target
      actualEmomReps = maxRepController.calculateRepsForTraining(reps);

      // Save rep data to firebase and then route the user to the next screen (results / success screen)
      await maxRepController.saveRepDataAndNavigate(userID, constants.GameRulesConstants.pemomPushups, repsInt, actualEmomReps, context);
    }
  }

  quitGameIconOnPress() {
    // Quit icon is available in game xp in upper left hand corner at all times
    // dispose() is automatically called
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
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
                                height: 40,
                              ),
                              HostCard(
                                bodyText: '',
                                headLine: 'Welcome! Enter your max push-up count to calibrate your training',
                                boxCard: false,
                              ),
                              Form(
                                key: _formKey,
                                child: CustomTextFieldRepCount(
                                    inputLabel: 'Enter Max Reps',
                                    hint: 'Tell the truth!',
                                    onSaved: repInputFieldOnChange,
                                    validator: repsValidator,
                                    keyboardType: TextInputType.text),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              HighEmphasisButton(
                                title: 'Submit',
                                onPressAction: submitRepData,
                              ),
                            ],
                          ),
                          Positioned(top: 2, left:2,child: QuitGameIcon(quitGameIconOnPress: quitGameIconOnPress)),
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

String? repsValidator(String? value) {
  if (value!.isEmpty) return '* Required';
  if (value.length < 1) {
    return 'Must provide a max rep count to play';
  }
  else if(value.length > 5) {
    return 'Impossible';
  }
  else if(int.parse(value) > 120){
    return 'Impossible';
  }
  else{
    return null;
  }
}
