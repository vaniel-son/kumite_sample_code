import '../style/colors.dart';
import 'package:flutter/material.dart';

// Future: dynamic sizing
bool mobileApp = true;
bool screenSmall = false;
bool ios = false;

/// **************************************************************
/// Primary Standard Sizes
/// **************************************************************

TextStyle PrimaryBT1({Color color = onPrimaryWhite, double fontSize = 12.0, FontStyle fontStyle: FontStyle.normal}) {
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  print(mobileApp);

  // Web: cannot access font PressStart2P, font sizes must be larger
  if (!mobileApp) {
    dFontFamily = 'Open Sans';
    dFontSize = fontSize + 2;
  }

  // Web: cannot access font PressStart2P, font sizes must be larger
  if (ios) {
    dFontFamily = 'Open Sans';
    dFontSize = fontSize + 1;
  }

  // Smaller screens: font sizes must be smaller
  if (screenSmall) {
    dFontSize = fontSize - 2;
  }

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
  );
}

TextStyle PrimaryBTBold1({Color color = onPrimaryWhite, double fontSize = 12.0, FontStyle fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
  );
}

TextStyle PrimaryCaption1({Color color = captionColor, double fontSize = 10.0, FontStyle fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
    height: 1.5,
  );
}

TextStyle PrimaryCaption2({Color color = captionColor, double fontSize = 8.0, FontStyle fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
    height: 1.5,
  );
}

/// **************************************************************
/// Primary Headers
/// **************************************************************

TextStyle PrimaryStyleH5({Color color = onPrimaryWhite, double fontSize = 22.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
      color: color,
      fontWeight: FontWeight.normal,
      fontFamily: dFontFamily,
      fontStyle:  FontStyle.normal,
      fontSize: dFontSize,
  );
}

TextStyle PrimaryStyleH6({Color color = onPrimaryWhite, double fontSize = 16.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
  );
}

/// **************************************************************
/// Host Card
/// **************************************************************

TextStyle PrimaryHostChatStyleBT1({Color color = onPrimaryWhite, double fontSize = 14.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
  );
}

TextStyle PrimaryHostChatStyleBoldBT1({Color color = onPrimaryWhite, double fontSize = 14.0, FontStyle fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
  );
}

/// **************************************************************
/// Game Style Host Card Text (large font, more vertical spacing)
/// **************************************************************

TextStyle GameHostChatStyleBT1({Color color = onPrimaryWhite, double fontSize = 14.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
    height: 1.5,
  );
}

TextStyle GameStyleHostChatBTBold1({Color color = onPrimaryWhite, double fontSize = 14.0, FontStyle fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
    height: 1.5,
  );
}

/// **************************************************************
/// Game Style (Large fonts)
/// **************************************************************

TextStyle GameStyleH5Bold({Color color = onPrimaryWhite, double fontSize = 24.0, fontStyle: FontStyle.normal}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  fontStyle,
    fontSize: dFontSize,
  );
}

TextStyle GameStyleH4Bold({Color color = onPrimaryWhite, double fontSize = 42.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
  );
}

TextStyle GameStyleH1Bold({Color color = onPrimaryWhite, double fontSize = 60.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.bold,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
  );
}

/// **************************************************************
/// Misc
/// **************************************************************

TextStyle EmojiTextStyle({Color color = onPrimaryWhite, double fontSize = 32.0}) {
  // future: dynamically choose the font size and family based on device and screen real estate
  String dFontFamily = 'PressStart2P';
  double dFontSize = fontSize;

  return TextStyle(
    color: color,
    fontWeight: FontWeight.normal,
    fontFamily: dFontFamily,
    fontStyle:  FontStyle.normal,
    fontSize: dFontSize,
  );
}