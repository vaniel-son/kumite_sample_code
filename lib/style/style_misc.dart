import 'package:flutter/material.dart';

/// ***********************************************************************
/// Borders
/// ***********************************************************************

borderRadius1() {
  return BorderRadius.only(
    topLeft: Radius.circular(6),
    topRight: Radius.circular(6),
    bottomLeft: Radius.circular(6),
    bottomRight: Radius.circular(6),
  );
}

borderRadius2() {
  return BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
  );
}

roundCornersRadius() {
  return BorderRadius.only(
    topLeft: Radius.circular(80),
    topRight: Radius.circular(80),
    bottomLeft: Radius.circular(80),
    bottomRight: Radius.circular(80),
  );
}

/// ***********************************************************************
/// Shadows
/// ***********************************************************************

boxShadow1() {
  return BoxShadow(
    color: Colors.black.withOpacity(0.3),
    blurRadius: 5,
    offset: Offset(5, 5),
  );
}

/// ***********************************************************************
/// Spacing
/// ***********************************************************************

// Dynamically create spacing based on screen real estate size
spaceVertical(context) {
  return SizedBox(height: (MediaQuery.of(context).size.height * .03).roundToDouble());
}

// Dynamically create spacing based on screen real estate size
spaceHorizontal(context) {
  return SizedBox(width: (MediaQuery.of(context).size.height * .01).roundToDouble());
}

// Dynamically create spacing based on screen real estate size
spaceVertical2({context, bool half = false}) {
  double multiplier = 0.03;
  if (half) {
    multiplier = 0.03/2;
  }

  return SizedBox(height: (MediaQuery.of(context).size.height * multiplier).roundToDouble());
}

/// Current Screen Height and relevant sizes
// Screen height: (MediaQuery.of(context).size.height)
// Screen width: (MediaQuery.of(context).size.width)
// (MediaQuery.of(context).padding).top -
// (MediaQuery.of(context).padding).bottom,
// Toolbar height:import 'package:flutter/cupertino.dart';

/// Edge insets (padding, margins)
// TBD