import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class ResourceEarnedSmall extends StatelessWidget {
  ResourceEarnedSmall({
    Key? key, this.resourceEarnedCount = 55,
  }) : super(key: key);

  final int resourceEarnedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Image.asset(
          'images/pho-bowl-01.png',
          height: 32,
        ),
        SizedBox(width: 8),
        Text('$resourceEarnedCount', style: PrimaryBT1()),
      ],
    );
  }
}
