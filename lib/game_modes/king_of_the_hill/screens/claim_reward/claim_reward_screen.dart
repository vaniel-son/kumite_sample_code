import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'claim_reward_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class ClaimRewardScreen extends StatefulWidget {
  ClaimRewardScreen({required this.gameRulesID, required this.competitionID, required this.userID}) {
    // Constructor
  }

  String gameRulesID;
  String competitionID;
  String userID;

  @override
  _ClaimRewardScreenState createState() => _ClaimRewardScreenState();
}

class _ClaimRewardScreenState extends State<ClaimRewardScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String nickname;
  late String userID = globals.dojoUser.uid;

  /// Manage state of player so this leaderboard knows what to load
  // labeled as "leaderboardStatus" on the leaderboard collection
  // the state is based on the leaderboard 'status' field
  // options are: pending (no judge consensus yet), confirmed (judge consensus met), winner (a winner has been picked)
  // in method setup(), this is set to the correct state base on the player's leaderboard "status"
  late String playerState = 'pending'; // default

  // Initialize services required
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();
  GameServiceKOH gameService = GameServiceKOH();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late ClaimRewardBloc claimRewardController;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Init / Dispose
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setup() async {
    /// Instantiate controller for this Game Mode page
    claimRewardController = ClaimRewardBloc(userID: userID, gameRulesID: widget.gameRulesID, competitionID: widget.competitionID);
    await claimRewardController.preloadScreenSetup();

    /// Transition from 'loading' to Load UI and widgets on the screen
    claimRewardController.loadUIOnScreen();
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
    return StreamBuilder<Map>(
        stream: claimRewardController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
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
                            height: (MediaQuery.of(context).size.height),
                            child: Stack(
                              children: <Widget>[
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          headLine: '${claimRewardController.nickname}',
                                          bodyText:
                                          'Claim your reward'),
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

            } else {
              return Stack(
                  children: [
                  LoadingScreen(displayVisual: 'loading icon'),
                  BackgroundOpacity(opacity: 'medium'),
                  ],
              );
            }
          } else {
            return Stack(
              children: [
                LoadingScreen(displayVisual: 'loading icon'),
                BackgroundOpacity(opacity: 'medium'),
              ],
            );
          }
        });
    // top module
  }
}
