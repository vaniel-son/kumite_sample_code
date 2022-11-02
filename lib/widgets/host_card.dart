import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HostCard extends StatelessWidget {
  HostCard(
      {this.headLine = '',
      required this.bodyText,
      this.headLineVisibility = true,
      this.transparency = false,
      this.variation = 1,
      this.boxCard = true,
      this.avatar = 'avatar-host-Sensei.png',
      this.avatarName = '',
     });

  final String headLine;
  final String bodyText;
  final bool headLineVisibility;
  final bool transparency;
  final int variation;
  final bool boxCard;
  final String avatar;
  final String avatarName;

  @override
  Widget build(BuildContext context) {
    final Widget bodyTextToDisplay;


    if (variation == 3) {
      // host card for ViewReplayScreen()'s countdown
      bodyTextToDisplay = Container(
          alignment: Alignment.center, child: Text('$bodyText', style: GameStyleH4Bold()));
    } else if (variation == 4){
      // host card for seeing text during game xp, but you are far away from the phone
      bodyTextToDisplay = Container(
          alignment: Alignment.center, child: Text('$bodyText', style: GameHostChatStyleBT1()));
    } else if (variation == 5){
      // regular size, but no text animation
      bodyTextToDisplay = Container(
          alignment: Alignment.center, child: Text('$bodyText', style: PrimaryHostChatStyleBT1()));
    } else {
      /// host card for most scenarios: regular title and body size
      // has animation
      bodyTextToDisplay = AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            '$bodyText',
            textStyle: Theme.of(context).textTheme.bodyText2,
            speed: const Duration(milliseconds: 25),
          ),
        ],
        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      );
    }

    /// This version: has a box card surrounding the text
    if (boxCard == true) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('images/$avatar'),
              ),
              SizedBox(height:4),
              Visibility(
                  visible: (avatarName != '') ? true : false,
                  child: Text(avatarName, textAlign: TextAlign.center,style: PrimaryCaption2())),
            ],
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Material(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                //color: primarySolidCardColor,
                color: transparency
                    ? primaryTransparentCardColor
                    : primarySolidCardColor,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                          visible: headLineVisibility,
                          child: Column(
                            children: [
                              Text('$headLine', style: GameStyleHostChatBTBold1(fontStyle: FontStyle.italic)),
                              spaceVertical2(context: context),
                            ],
                          )),
                      bodyTextToDisplay,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    /// This version: has no box card in the background
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
            ),
            SizedBox(
              width: 16,
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: headLineVisibility,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$headLine', style: PrimaryHostChatStyleBoldBT1(fontStyle: FontStyle.italic)),
                            spaceVertical2(context: context),
                            //spaceVertical2(context: context, half: true),
                          ],
                        ),
                      ),
                      bodyTextToDisplay,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
