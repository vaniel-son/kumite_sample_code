import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

double buttonOpacityFull = 1;
double buttonOpacityHalf = 0.5;

void buttonPressAction(x){
  SoundService.buttonClickOne();
  x();
}

/// ***********************************************************************
/// High Emphasis, NO animation
/// ***********************************************************************

class HighEmphasisButton extends StatelessWidget {
  const HighEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = primaryDojoColor,
    this.onPrimaryColor = Colors.white,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.90,
      height: 48,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 5,
          offset: Offset(5, 5),
        ),
      ], borderRadius: BorderRadius.all(Radius.circular(80))),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor, // background
          onPrimary: onPrimaryColor, // foreground
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: () {
          buttonPressAction(onPressAction);
        },
        child: Text(title, style: PrimaryBT1()),
      ),
    );
  }
}

/// ***********************************************************************
/// High Emphasis w/ animation
/// ***********************************************************************

/// Animated Button
class HighEmphasisButtonWithAnimation extends StatefulWidget {
  const HighEmphasisButtonWithAnimation({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = primaryDojoColor,
    this.onPrimaryColor = Colors.white,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction;

  @override
  _HighEmphasisButtonWithAnimationState createState() => _HighEmphasisButtonWithAnimationState();
}

class _HighEmphasisButtonWithAnimationState extends State<HighEmphasisButtonWithAnimation> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this, value: 0.0);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        margin: const EdgeInsets.all(6.0),
        width: (MediaQuery.of(context).size.width) * 0.90,
        height: 48,
        decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              //boxShadow1(),
              BoxShadow(
                color: Colors.grey.shade500,
                offset: Offset(6,6),
                blurRadius: 15,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white,
                offset: Offset(-6,-6),
                blurRadius: 15,
                spreadRadius: 1,
              ),

        ], borderRadius: BorderRadius.all(Radius.circular(80))),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: widget.primaryColor, // background
            onPrimary: widget.onPrimaryColor, // foreground
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
          ),
          onPressed: () {
            buttonPressAction(widget.onPressAction);
          },
          //van57onPressed: widget.onPressAction,
          child: Text(widget.title, style: PrimaryBT1()),
        ),
      ),
    );
  }
}

/// ***********************************************************************
/// Medium Emphasis
/// ***********************************************************************

class MediumEmphasisButton extends StatelessWidget {
  const MediumEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.black,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction; // a function

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.90,
      height: 48,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        boxShadow1(),
      ], borderRadius: BorderRadius.all(Radius.circular(80))),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor, // background
          onPrimary: onPrimaryColor, // foreground
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: () {
          buttonPressAction(onPressAction);
        },
        child: Text(title, style: PrimaryBT1(color: onPrimaryColor)),
      ),
    );
  }
}

/// ***********************************************************************
/// Low Emphasis
/// ***********************************************************************

class LowEmphasisButton extends StatelessWidget {
  const LowEmphasisButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String title;
  final onPressAction;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        buttonPressAction(onPressAction);
      },
      child: Text(title, style: Theme.of(context).textTheme.bodyText2),
    );
  }
}

/// ***********************************************************************
/// Low Emphasis, with border
/// ***********************************************************************

class LowEmphasisButtonWithBorder extends StatelessWidget {
  const LowEmphasisButtonWithBorder({
    Key? key,
    this.id = 0,
    required this.title,
    this.onPressAction,
    this.buttonColor = onPrimaryBlack,
    this.buttonEnabled = true,
  }) : super(key: key);

  final int id;
  final String title;
  final onPressAction;
  final Color buttonColor;
  final bool buttonEnabled;

  @override
  Widget build(BuildContext context) {
    double opacity = buttonOpacityFull;
    if (buttonEnabled == false) {
      opacity = buttonOpacityHalf;
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.all(Radius.circular(80))),
        height: 48,
        width: (MediaQuery.of(context).size.width) * .9,
        child: TextButton(
          onPressed: () {
            buttonPressAction(onPressAction);
          },
          child: Text('$title', style: Theme.of(context).textTheme.bodyText2),
        ),
      ),
    );
  }
}

/// ***********************************************************************
/// Emoji Button
/// ***********************************************************************

class EmojiButton extends StatelessWidget {
  const EmojiButton({
    Key? key,
    this.id = 0,
    required this.emoji,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.black,
    this.onPressAction,
  }) : super(key: key);

  final int id;
  final String emoji;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction; // a function

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        boxShadow1(),
      ], borderRadius: BorderRadius.all(Radius.circular(80))),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          primary: primaryColor.withOpacity(0.3), // background
          onPrimary: onPrimaryColor.withOpacity(0.8), // foreground
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: onPressAction,
        child: Text(emoji, style: EmojiTextStyle()),
      ),
    );
  }
}

/// ***********************************************************************
/// Disabled Button
/// ***********************************************************************

class DisabledButton extends StatelessWidget {
  const DisabledButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.grey,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;

  onPressActionDefault() {
    print('do nothing');
    // do nothing
    // ... there is a better way to handle this, but do not know how right now
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.90,
      height: 48,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(80))),
      child: OutlinedButton(
        style: ElevatedButton.styleFrom(
          onSurface: primaryColor ,
          primary: primaryColor, // background
          onPrimary: onPrimaryColor, // foreground
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: onPressActionDefault(),
        child: Text(title, style: PrimaryBT1(color: onPrimaryBlack)),
      ),
    );
  }
}

/// ***********************************************************************
/// Google or Apple Sign In button
/// ***********************************************************************

class GoogleOrAppleSignInButton extends StatelessWidget {
  const GoogleOrAppleSignInButton({
    Key? key,
    this.id = 0,
    required this.title,
    this.primaryColor = Colors.white,
    this.onPrimaryColor = Colors.black,
    this.onPressAction,
    required this.slaveMaster,
  }) : super(key: key);

  final int id;
  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final onPressAction;
  final String slaveMaster;

  Widget logo() {
    if (slaveMaster == 'google') {
      return CircleAvatar(
        backgroundColor: onPrimaryWhite,
        child: Image.network('https://pngimg.com/uploads/google/google_PNG19635.png', fit: BoxFit.cover),
        radius: 16.0,
      );

      return Container(
        color: onPrimaryWhite,
        width: 32,
        height: 32,
        child: Image.network('https://pngimg.com/uploads/google/google_PNG19635.png', fit: BoxFit.cover),
      );
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.network('https://pngimg.com/uploads/google/google_PNG19635.png', fit: BoxFit.cover),
      );
    } else {
      return SizedBox(
        width: 32,
        height: 32,
        child: Image.asset('images/apple-logo-white.png', fit: BoxFit.cover),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * 0.90,
      height: 48,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 5,
          offset: Offset(5, 5),
        ),
      ], borderRadius: BorderRadius.all(Radius.circular(80))),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: slaveMaster == 'google' ? googleBackground : onPrimaryColor, // background
          onPrimary: slaveMaster == 'google' ? primaryColor : primaryColor, // foreground
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        ),
        onPressed: () {
          buttonPressAction(onPressAction);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: logo(),
            ),
            SizedBox(width: 8),
            slaveMaster == 'google' ? Text(title, style: PrimaryBT1(color: onPrimaryWhite)) : Text(title, style: PrimaryBT1()),
          ],
        ),
      ),
    );
  }
}