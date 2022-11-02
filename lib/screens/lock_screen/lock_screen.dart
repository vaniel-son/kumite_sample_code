import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:url_launcher/url_launcher.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({required this.lockScreenType,
    Key? key,
  }) : super(key: key);

  final String lockScreenType;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  /*void buttonAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: GameScreen(
        userID: widget.userID,
        gameRulesID: widget.gameRulesID)));
  }*/

  void googlePlayStoreButtonAction() async {
    String googlePlayURL = 'https://play.google.com/store/apps/details?id=com.mydojo.dojo_app.prod&hl=en_US&gl=US';
    if (await canLaunch(googlePlayURL)) {
      await launch(googlePlayURL, forceWebView: false, enableJavaScript: false);
    } else {
      throw 'Could not launch $googlePlayURL';
    }
  }

  void applePlayStoreButtonAction() async {
    String applyStoreURL = 'https://apps.apple.com/au/app/dojo-fit/id1569206722';
    if (await canLaunch(applyStoreURL)) {
      await launch(applyStoreURL, forceWebView: false, enableJavaScript: false);
    } else {
      throw 'Could not launch $applyStoreURL';
    }
  }

  String headline = 'headline';
  String message = 'message body';

  determineCopy(){
    if (widget.lockScreenType == constants.lockAppStatusType.updateAppVersion) {
      headline = 'Please update your app by visiting the app store!';
      message = 'DOJO has improved to enhance your experience. \n\nTo continue using DOJO, please visit the app store to update.';
    } else if (widget.lockScreenType == constants.lockAppStatusType.maintenanceMode) {
      headline = 'DOJO MAINTENANCE';
      message = 'I apologize but Dojo is unavailable so I can sweep the floors. \n\nPlease check back later when I re-open.';
    } else if (widget.lockScreenType == constants.lockAppStatusType.accountCreationSuspended) {
      headline = 'DOJO MAINTENANCE...';
      message = 'I apologize but Dojo is unavailable so I can sweep the floors. \n\nPlease check back later when I re-open.';
    }
  }

  @override
  void initState() {
    super.initState();
    determineCopy();

    /// play sound fx
    //SoundService.roundSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColorDark1,
          ],
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity * .9,
                    height: (MediaQuery.of(context).size.height) -
                        (MediaQuery.of(context).padding).top -
                        (MediaQuery.of(context).padding).bottom,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              spaceVertical(context),
                              spaceVertical(context),

                              /// Host Card
                              HostCard(
                                headLine: '${headline}',
                                headLineVisibility: true,
                                bodyText: '${message}',
                                boxCard: false,
                              ),

                              /// Google / Apple app store buttons
                              Builder(
                                builder: (context) {
                                  if (widget.lockScreenType == constants.lockAppStatusType.updateAppVersion) {
                                    return Column(
                                      children: [
                                        GoogleOrAppleSignInButton(
                                          slaveMaster: 'google',
                                          title: ' Google Play Store',
                                          onPressAction: googlePlayStoreButtonAction,
                                        ),
                                        spaceVertical2(context:context),
                                        GoogleOrAppleSignInButton(
                                          slaveMaster: 'apple',
                                          title: ' Apple App Store',
                                          onPressAction: applePlayStoreButtonAction,
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Container();
                                  }
                                }
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
