import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsPEMOM;

//ignore: must_be_immutable
class EMOMScoreBox extends StatelessWidget {
  EMOMScoreBox({
    Key? key, required this.playerRoundOutcomes, this.playerLevel = 1,
  }) : super(key: key);

 final List playerRoundOutcomes;
 final int playerLevel;

  Widget determineSuccessOrFailureIcon2(String roundOutcome){
    if (roundOutcome == constantsPEMOM.PlayerGameRoundStatus.success) {
      return FaIcon(FontAwesomeIcons.solidCheckCircle, size: 32, color: Colors.green,);
    } else if (roundOutcome == constantsPEMOM.PlayerGameRoundStatus.failure) {
      return FaIcon(FontAwesomeIcons.windowClose, size: 32, color: Colors.red,);
    } else {
      return Text('?', style: PrimaryStyleH5()); // player has not played
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: borderRadius1(),
        color: primarySolidCardColor.withOpacity(0.7),
      ),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LEVEL $playerLevel', style: PrimaryCaption1()),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TRAINING RESULTS', style: PrimaryCaption1()),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('MIN 1', style: PrimaryCaption1(color: onPrimaryWhite)),
                      SizedBox(height: 8),
                      determineSuccessOrFailureIcon2(playerRoundOutcomes[0]),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('MIN 2', style: PrimaryCaption1(color: onPrimaryWhite)),
                      SizedBox(height: 8),
                      determineSuccessOrFailureIcon2(playerRoundOutcomes[1]),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('MIN 3', style: PrimaryCaption1(color: onPrimaryWhite)),
                      SizedBox(height: 8),
                      determineSuccessOrFailureIcon2(playerRoundOutcomes[2]),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
