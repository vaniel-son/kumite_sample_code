import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';

//ignore: must_be_immutable
class ResourceEarned extends StatelessWidget {
  ResourceEarned({
    Key? key, this.resourceEarnedCount = 55,
  }) : super(key: key);

  final int resourceEarnedCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(8.0),
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
                    Image.asset(
                      'images/pho-bowl-01.png',
                      height: 40,
                    ),
                    SizedBox(width: 8),
                    Text('$resourceEarnedCount pho bowls earned', style: PrimaryCaption1(color: onPrimaryWhite)),
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
