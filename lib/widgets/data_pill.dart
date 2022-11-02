import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';

class DataPill extends StatelessWidget {
  const DataPill({Key? key, this.data = 'Data: 0',}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 4, 8, 8),
      decoration: BoxDecoration(
        color: primaryColor,
        //borderRadius: roundCornersRadius(),
      ),
      child: Text('$data', style: PrimaryCaption1(color: onPrimaryWhite)),
      //Text('  Personal Record: $personalRecord  ', style: Theme.of(context).textTheme.caption)
    );
  }
}
