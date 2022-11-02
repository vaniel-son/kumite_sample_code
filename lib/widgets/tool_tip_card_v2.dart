import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

//ignore: must_be_immutable
class ToolTipCardV2 extends StatelessWidget {
  const ToolTipCardV2({required this.message,
    Key? key,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.all(16),
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      padding: EdgeInsets.fromLTRB(24.0, 8.0, 8.0, 8.0),
      width: (MediaQuery.of(context).size.width) * .80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: borderRadius1(),
        color: primarySolidCardColor.withOpacity(0.7),
      ),
      //color: primaryBackgroundColor,
      child: Text(message, style: PrimaryBT1(fontSize:10)),
    );
  }
}
