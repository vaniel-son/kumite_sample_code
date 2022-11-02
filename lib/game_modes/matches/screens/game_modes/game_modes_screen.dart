import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_wrapper.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/game_mode_card_matches.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/game_modes/matches/screens/game_modes/game_modes_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  //print(message.notification!.title);
}

//ignore: must_be_immutable
class GameModesScreen extends StatefulWidget {
  GameModesScreen() {
    // Constructor
  }

  @override
  _GameModesScreenState createState() => _GameModesScreenState();
}

class _GameModesScreenState extends State<GameModesScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  // the global values are set in the levels_wrapper
  String defaultBackgroundVideo = globalsMatches.gameModesWrapperMap['backgroundVideo'];
  bool allLevelsCompleted = globalsMatches.gameModesWrapperMap['allLevelsCompleted'];
  String nickname = globalsMatches.gameModesWrapperMap['nickname'];
  String userID = globalsMatches.gameModesWrapperMap['userID'];
  List<Widget> notificationWidgetList = globalsMatches.gameModesWrapperMap['notificationWidgetList'] as List<Widget>;
  String winLossTieRecord = globalsMatches.gameModesWrapperMap['winLossTieRecord'];

  /// Declare variable where mot of the logic is managed for this page
  // majority of the logic is in this object
  late GameModesBloc gameModesController;

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'medium';

  @override
  void initState() {
    super.initState();

    /// Instantiate controller for this Game Mode page
    gameModesController = GameModesBloc(userID: userID);
  }

  @override
  void dispose() {
    printBig('Game Modes Dispose Called', 'true');
    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    print('do nothing');
  }

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        title: PageTitle(title: 'DOJO'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            print('tap');
            menuAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(0),
            child: Column(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width),
                  height: (MediaQuery.of(context).size.height) - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                  child: Stack(
                    children: <Widget>[
                      VideoFullScreen(videoURL: defaultBackgroundVideo, videoConfiguration: 3),
                      BackgroundOpacity(opacity: videoOpacity),
                      Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            HostCard(headLine: 'Welcome $nickname', bodyText: 'Test your strength with pushup challenges.'),
                            SizedBox(height: 16),
                            /* GameModeCard(
                                onPressAction: () {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: LevelsWrapper()),
                                      (Route<dynamic> route) => false);
                                },
                                subtitleIcon: FontAwesomeIcons.universalAccess,
                                subtitle: 'Single Player',
                                title: 'Campaign',
                                description: 'Can you defeat all Dojo bosses?'),*/
                            /* SizedBox(height: 16),
                            Divider(height: 1.0, thickness: 1.0, indent: 16.0, endIndent: 16.0),
                            SizedBox(height: 16),*/
                            Container(
                              width: (MediaQuery.of(context).size.width) * .90,
                              child: Column(
                                children: notificationWidgetList,
                              ),
                            ),
                            SizedBox(height: 8),
                            GameModeCard(
                              onPressAction: () {
                                Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: MatchesWrapper()),
                                        (Route<dynamic> route) => false);
                              },
                              subtitleIcon: FontAwesomeIcons.universalAccess,
                              subtitle: 'Two Player',
                              title: 'Turn Based Matches',
                              description: 'Face-off against other players',
                              icon2x: true,
                              displayWinLossTieRecord: true,
                              winLossTieRecord: winLossTieRecord,
                            ),
                            SizedBox(height: 16),
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
    );
    // top module
  }
}