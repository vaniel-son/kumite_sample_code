import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:confetti/confetti.dart';

class PhoBowlProgressScreen extends StatefulWidget {
  const PhoBowlProgressScreen({this.phoBowlsInventoryCount = 0, this.phoBowlsRequiredForUpcomingMainEventInvite = 0, this.phoBowlsEarned = 0,
    Key? key,
  }) : super(key: key);

  final int phoBowlsInventoryCount;
  final int phoBowlsRequiredForUpcomingMainEventInvite;
  final int phoBowlsEarned;

  @override
  State<PhoBowlProgressScreen> createState() => _PhoBowlProgressScreenState();
}

class _PhoBowlProgressScreenState extends State<PhoBowlProgressScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late final ConfettiController _controllerTopCenter = ConfettiController(duration: const Duration(seconds: 10));

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  void buttonAction() {
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
  }

  bool ranAlready = false; // band-aid hack: only allows certain functions to be ran once, even though the tree is rebuilt many times for the progress bar animation
  int SFXCounter = 0; // increments to inform UI how many max times the SFX has played vs phoBowlsEarned
  int maxProgressBarStepCount = 60; // the progress bar will break the UI if it exceeds X. this is a temp bandaid to fix this problem

  @override
  void initState() {
    super.initState();

    if (widget.phoBowlsRequiredForUpcomingMainEventInvite < 60) {
      maxProgressBarStepCount = widget.phoBowlsRequiredForUpcomingMainEventInvite;
    }

    // controller to animate the progress bar
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );

    // for animating the progress bar
    _animation = Tween<double>(
      begin: 0,
      end: widget.phoBowlsInventoryCount.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
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
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConfettiWidget(
                            confettiController: _controllerTopCenter,
                            blastDirectionality: BlastDirectionality.explosive,
                            maxBlastForce: 100, // set a lower max blast force
                            minBlastForce: 50, // set a lower min blast force
                            emissionFrequency: 0.03,
                            numberOfParticles: 50, // a lot of particles at once
                            gravity: 0.3,
                            shouldLoop: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              spaceVertical(context),
                              spaceVertical(context),
                              Image.asset(
                                'images/pho-bowl-01.png',
                                height: 64
                              ),
                              Text('${widget.phoBowlsInventoryCount} out of ${widget.phoBowlsRequiredForUpcomingMainEventInvite}', textAlign: TextAlign.center, style: GameStyleH5Bold()),
                              spaceVertical(context),
                              StepProgressIndicator(
                                totalSteps: maxProgressBarStepCount,
                                currentStep: _animation.value.toInt(),
                                size: 24,
                                selectedColor: primaryColorExtraLight1,
                                unselectedColor: inactiveSolidCardColor,
                              ),
                              spaceVertical(context),
                              Builder(
                                builder: (context) {
                                  if (widget.phoBowlsInventoryCount >= widget.phoBowlsRequiredForUpcomingMainEventInvite) {
                                    if (ranAlready == false) {
                                      ranAlready = true;
                                      _controllerTopCenter.play(); // play confetti
                                      SoundService.cheer();
                                      SoundService.youWin();
                                    }

                                    // only play this SFX based on the number of pho bowls they just earned
                                    if (SFXCounter >= widget.phoBowlsEarned) {
                                      SFXCounter++;
                                    } else {
                                      SoundService.singleCoin();
                                      SFXCounter++;
                                    }
                                    return Text('You earned 100% of the pho bowls required to trade for a main event invite!!', textAlign: TextAlign.center, style: PrimaryBT1());
                                  } else {
                                    // only play this SFX based on the number of pho bowls they just earned
                                    if (SFXCounter >= widget.phoBowlsEarned) {
                                      SFXCounter++;
                                    } else {
                                      SoundService.singleCoin();
                                      SFXCounter++;
                                    }

                                    if (ranAlready == false) {
                                      ranAlready = true;
                                      // do nothing as of now
                                    }
                                    int phoBowlsNeededToEarn = widget.phoBowlsRequiredForUpcomingMainEventInvite - widget.phoBowlsInventoryCount;
                                    return Text('You need $phoBowlsNeededToEarn more pho bowls to access the main event.', textAlign: TextAlign.center, style: PrimaryBT1());
                                  }

                                }
                              ),
                              spaceVertical(context),
                              MediumEmphasisButton(
                                  title: 'EXIT',
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
