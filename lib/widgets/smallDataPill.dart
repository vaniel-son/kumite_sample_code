import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';

//ignore: must_be_immutable
class DataPillSmall extends StatelessWidget {
  DataPillSmall({
    Key? key, this.data = '', this.bgColor = primaryColor,
  }) : super(key: key);

  final String data;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$data', style: PrimaryCaption1(color: onPrimaryWhite)),
      ),
    );
  }
}
