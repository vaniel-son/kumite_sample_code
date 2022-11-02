import 'package:dojo_app/screens/authentication/auth_options/auth_options_screen.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class StartScreen extends StatefulWidget {
  StartScreen({Key? key,}) : super(key: key);

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  onPressAction() {
    SoundService.pressPlay();
    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: AuthOptionsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        //resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  //left: 10,
                  right:10,
                  bottom: 0,
                  child: Image.asset(
                    'images/sifu.png',
                    height: 450,
                  ),
                ),
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
                      height: 16,
                    ),
                    HostCard(
                      headLineVisibility: false,
                        headLine: 'headline',
                        bodyText: 'Who can do the most pushups in the world?',
                        boxCard: false,
                    ),
                    //Center(child: CircularProgressIndicator()),
                    Container(
                      height: 16,
                    ),
                  ],
                ),
                Positioned(
                  bottom: 40,
                  child: HighEmphasisButtonWithAnimation(
                    id: 1,
                    title: 'I\'M READY TO COMPETE',
                    onPressAction: onPressAction,
                  ),
                 ),
              ],
            ),
        ),
      ),
    );
  }
}
