import 'package:dojo_app/main.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:page_transition/page_transition.dart';
import 'delete_user_bloc.dart';

class DeleteUserScreen extends StatefulWidget {
  const DeleteUserScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteUserScreen> createState() => _DeleteUserScreenState();
}

class _DeleteUserScreenState extends State<DeleteUserScreen> {
  final String headline = 'DELETE YOUR ACCOUNT' ;
  final String bodyText = 'Are you sure you want to permanently delete your account and user data?';

  String userID = globals.dojoUser.uid;
  late DeleteUserBloc deleteUserController = DeleteUserBloc(userID: userID);

  ///OTHER METHODS
  void backButtonAction() {
    Navigator.pop(context, []);
  }

  @override
  void initState() {
    super.initState();
  }

  tapAction(){
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: DojoApp()),
            (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: primaryBackgroundColor,
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
                            Container(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: () {
                                    print('tap');
                                    backButtonAction();
                                  },
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            HostCard(
                              headLine: '$headline',
                              bodyText:
                                  '$bodyText',
                              // 'Almost every week, your pho bowls will be auth withdrawn to the Ethereum address you provided (Optimism chain).',
                              boxCard: false,
                            ),
                            HighEmphasisButton(title: 'DELETE MY ACCOUNT',
                                onPressAction: () async {
                                  await deleteUserController.deleteUserAccount();
                                  tapAction();
                                }
                            )
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
    );
  }
}
