import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';

//ignore: must_be_immutable
class InfoAndTip extends StatelessWidget {
  InfoAndTip({
    Key? key, this.message = 'Earn Pho bowls by training',
  }) : super(key: key);

  final String message;

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Earn Pho bowls by training', style: PrimaryCaption1(color: onPrimaryWhite)),
                  ],
                ),
                SizedBox(height:4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
