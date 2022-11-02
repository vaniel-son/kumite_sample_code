import 'package:dojo_app/game_modes/training_emom/screens/game/game_screen.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class MaxRepsResultScreen extends StatefulWidget {
  const MaxRepsResultScreen({this.pushupGoalPerMinute = 0, required this.userID, required this.gameRulesID,
    Key? key,
  }) : super(key: key);

  final int pushupGoalPerMinute;
  final String userID;
  final String gameRulesID;

  @override
  State<MaxRepsResultScreen> createState() => _MaxRepsResultScreenState();
}

class _MaxRepsResultScreenState extends State<MaxRepsResultScreen> with SingleTickerProviderStateMixin {
  void buttonAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: GameScreen(
        userID: widget.userID,
        gameRulesID: widget.gameRulesID)));
  }

  @override
  void initState() {
    super.initState();

    // play sound fx
    SoundService.roundSuccess();
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
                    width: double.infinity,
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
                              HostCard(
                                headLine: 'YOUR CUSTOM PROGRAM',
                                headLineVisibility: true,
                                bodyText: 'Every minute, complete ${widget.pushupGoalPerMinute} standard pushups',
                                boxCard: false,
                              ),
                              spaceVertical(context),
                              spaceVertical(context),
                              spaceVertical(context),
                              spaceVertical(context),
                              Text('GOAL', style: PrimaryCaption1()),
                              spaceVertical(context),
                              Text('${widget.pushupGoalPerMinute}', textAlign: TextAlign.center, style: GameStyleH4Bold()),
                              spaceVertical(context),
                              Text('PUSHUPS PER MINUTE', style: PrimaryCaption1()),
                              spaceVertical(context),
                              spaceVertical(context),
                              spaceVertical(context),
                              MediumEmphasisButton(
                                  title: 'START TRAINING PROGRAM',
                                  onPressAction: () {
                                    buttonAction();
                                  }
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
