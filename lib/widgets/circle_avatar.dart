import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  CustomCircleAvatar(
      {this.avatarFirstLetter = 'X',
      this.radius = 26.0,
      this.avatarImage = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/assets_app%2Fimages%2FDojo-Player-Avatar-Kora.png?alt=media&token=90640f1b-136f-4708-a43e-6cc01fdda822',
      this.enableAvatarImage = false});

  final String avatarFirstLetter;
  final double radius;
  final String avatarImage;
  final bool enableAvatarImage;

  /// Determine size of font size
  Widget getTextStyle(String textToStyle){
    if (radius < 16.0) {
      return Text(textToStyle, style: PrimaryCaption1());
    } else if (radius < 24) {
      return Text(textToStyle, style: PrimaryBT1());
    } else {
      return Text(textToStyle, style: PrimaryStyleH5());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarAsLetter;
    TextStyle? avatarLetterStyle;

    if (enableAvatarImage == true) {
      return CircleAvatar(
        radius: radius,
        //backgroundImage: AssetImage(avatarImage),
        backgroundImage: NetworkImage(avatarImage),
        backgroundColor: primaryDojoColorLighter,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: primaryDojoColorLighter,
        child: getTextStyle(avatarFirstLetter.toUpperCase()),
      );
    }
  }
}
