import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/screens/update_wallet_address/update_wallet_address_bloc.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/custom_text_field.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:page_transition/page_transition.dart';

class UpdateWalletAddressScreen extends StatefulWidget {
  const UpdateWalletAddressScreen({Key? key,
    required this.updateCheck,
    required this.updatePageHostCardVisibility,
    required this.newPageHostCardVisibility,
    required this.updatePageButtonVisibility,
    required this.newPageButtonVisibility,
    required this.skipButtonVisibility,
    required this.backButtonVisibility
  }) : super(key: key);

  final bool updateCheck; //If true show update screen config.
  final bool updatePageHostCardVisibility;
  final bool newPageHostCardVisibility;
  final bool updatePageButtonVisibility;
  final bool newPageButtonVisibility;
  final bool skipButtonVisibility;
  final bool backButtonVisibility;


  @override
  State<UpdateWalletAddressScreen> createState() => _UpdateWalletAddressScreenState();
}

class _UpdateWalletAddressScreenState extends State<UpdateWalletAddressScreen> {

  String ethAddress = '0x3b01E62f3734533C492a3C49dd4A72A1512d1547';
  final _formKey = GlobalKey<FormState>();

  late CollectionReference users = FirebaseFirestore.instance.collection('users');
  late User? dojoUser = FirebaseAuth.instance.currentUser;
  late String userID = dojoUser!.uid;
  late Future<bool> futureApiMessage;
  late Future<String> prePopulatedEthAddress; //Variable stores the existing eth wallet address if it exists.

  /// ***********************************************************************
  /// ***********************************************************************
  /// Validation Methods
  /// ***********************************************************************
  /// ***********************************************************************

  void ethAddressInputFieldOnChange(value) {
    setState(() => ethAddress = value.trim() );
  }

  //Adds eth address to the user table.
  Future<void> submitEthAddress() async {
    final FormState? form = _formKey.currentState;


    if(_formKey.currentState!.validate()) {
      form!.save();

      if(widget.updateCheck == true) {
        futureApiMessage =
            verifyAndSaveEthereumAddress(context, ethAddress, userID, true);
      } else {
        futureApiMessage =
            verifyAndSaveEthereumAddress(context, ethAddress, userID, false);
      }
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  skipEthAddressInput() {
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Wrapper()));
  }

  //Displays messages regarding the moralis API, which checks if its a proper address.
  Widget apiMessages(BuildContext context) {
    return FutureBuilder<bool>(
      future: futureApiMessage,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Something went wrong', style: PrimaryStyleH5()),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        } else return Container();
      },
    );
  }

  void backButtonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.topToBottom, alignment: Alignment.bottomCenter, child: Wrapper()),(Route<dynamic> route) => false);
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Wrapper()));
    }

  @override
  void initState() {

    super.initState();
    futureApiMessage = verifyAndSaveEthereumAddress(context,ethAddress,userID,false);//Running this method during the initstate in order to be able to use it for the futureBuilder to display message.
    prePopulatedEthAddress = fetchWalletAddress(userID);

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
                              Visibility(
                                visible: widget.backButtonVisibility,
                                child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_back),
                                      onPressed: () {
                                        print('tap');
                                        backButtonAction();
                                      },
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Visibility(
                                visible: widget.updatePageHostCardVisibility,
                                child: HostCard(
                                  bodyText: 'Make sure your wallet supports the ERC-20 standard',
                                  headLine: 'Update your wallet address',
                                  boxCard: false,
                                ),
                              ),
                              Visibility(
                                visible: widget.newPageHostCardVisibility,
                                child: HostCard(
                                  bodyText: '',
                                  headLine: 'To receive Dojo rewards please put in your ethereum wallet address',
                                  boxCard: false,
                                ),
                              ),
                              FutureBuilder<String>(
                                future: prePopulatedEthAddress,
                                builder:(context, snapshot) {
                                 if (snapshot.hasData) {
                                   print(snapshot.data);
                                   return Form(
                                     key: _formKey,
                                     child: CustomTextFieldRegistration(
                                         inputLabel: 'Enter Ethereum Address',
                                         hint: 'Make sure to input address correctly',
                                         onSaved: ethAddressInputFieldOnChange,
                                         validator: ethAddressValidator,
                                         keyboardType: TextInputType.text,
                                         initialValue: snapshot.data),
                                   );
                                 } else {
                                   return Container();
                                 }
                                }
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Visibility(
                                visible: widget.updatePageButtonVisibility,
                                child: HighEmphasisButton(
                                  title: 'Update',
                                  onPressAction: submitEthAddress,
                                ),
                              ),
                              Visibility(
                                visible: widget.newPageButtonVisibility,
                                child: HighEmphasisButton(
                                  title: 'Submit',
                                  onPressAction: submitEthAddress,
                                ),
                              ),
                              Visibility(
                                  visible: widget.skipButtonVisibility,
                                  child: LowEmphasisButton(title: 'Skip',onPressAction: skipEthAddressInput,)
                              ),
                              apiMessages(context)

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

String? ethAddressValidator(String? value) {
  if (value!.isEmpty) return '* Required';
  if (value.length < 42) {
    return 'Incorrect Eth Address';
  }
  else if(value.length > 42) {
    return 'Incorrect Eth Address';
  }
  else{
    return null;
  }
}
