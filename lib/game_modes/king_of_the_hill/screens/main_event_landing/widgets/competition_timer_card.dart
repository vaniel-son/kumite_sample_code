import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/widgets/competition_expiration_timer.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dojo_app/style/colors.dart';

/// About the constructor parameters
// if you do not want to display a button, then pass buttonAction an empty method, and buttonVisible as false

//ignore: must_be_immutable
class CompetitionTimerCard extends StatelessWidget {
  CompetitionTimerCard({
    Key? key,
    required this.competitionTimeToCountdownTowards,
    this.playButtonVisible = false,
    required this.playButtonAction,
    this.requestEventAccessButtonVisible = false,
    required this.requestEventAccessButtonAction,
    this.competitionStartsSoon = false,
    this.competitionEndsSoon = false,
  }) : super(key: key);

  final DateTime competitionTimeToCountdownTowards;
  final bool playButtonVisible;
  final Function playButtonAction;
  final bool requestEventAccessButtonVisible;
  final Function requestEventAccessButtonAction;
  final bool competitionStartsSoon;
  final bool competitionEndsSoon;

  String title = 'COMPETITION STARTS IN';
  final String body = '16h 32m 16s';

  String determineCompetitionTimerTitle(){
    if (competitionStartsSoon == true) {
      title = 'COMPETITION STARTS IN';
    } else if (competitionEndsSoon == true) {
      title = 'COMPETITION ENDS IN';
    } else {
      title = 'Something went wrong';
    }

    return title;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: primarySolidCardColor.withOpacity(0.7),
          ),
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(determineCompetitionTimerTitle(), style: PrimaryCaption1(color: secondaryTextColor)),
                  ],
                ),
                SizedBox(height:4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FaIcon(FontAwesomeIcons.hourglassHalf, size: 16),
                    SizedBox(width:8),
                    CompetitionExpirationTimer(expirationDateTime: competitionTimeToCountdownTowards),
                  ],
                ),
                //SizedBox(height:8),

                /// Play Button
                Visibility(
                  visible: playButtonVisible,
                  child: Container(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: HighEmphasisButtonWithAnimation(
                        id: 1,
                        title: 'PLAY NOW',
                        onPressAction: playButtonAction,
                      ),
                    ),
                  ),
                ),


                /// Request Main event access button
                Visibility(
                  visible: requestEventAccessButtonVisible,
                  child: Container(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: HighEmphasisButtonWithAnimation(
                        id: 1,
                        title: 'Get main event access',
                        onPressAction: requestEventAccessButtonAction,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
