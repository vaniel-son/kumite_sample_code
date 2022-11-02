import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

//ignore: must_be_immutable
class ToolTipCard extends StatelessWidget {
  ToolTipCard({
    Key? key,
    this.text = 'Uh, oh, tooltip unavailable',
    this.imageAsset,
    //this.onPressAction,
    required this.widgetToDisplayOnTap,
  }) : super(key: key);

  final String text;
  final String? imageAsset;
  // final dynamic onPressAction;
  final dynamic widgetToDisplayOnTap;

  tapAction(context) {
    Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: widgetToDisplayOnTap));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withOpacity(0.5),
          //onTap: onPressAction,
          onTap: () {
            tapAction(context);
          },
          child: Container(
            width: (MediaQuery.of(context).size.width) * .90,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: borderRadius1(),
              color: onPrimaryBlack.withOpacity(0.6),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 4),
                              Builder(builder: (context) {
                                if (imageAsset != null) {
                                  return Image.asset(
                                    imageAsset!,
                                    height: 24,
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                              SizedBox(width: 16),
                              Flexible(child: Text('$text', style: PrimaryCaption1(color: onPrimaryWhite))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidQuestionCircle,
                            size: 24,
                            color: Colors.yellow,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
