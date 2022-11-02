import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/main_event_landing_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/request_event_access/get_event_access_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/request_event_access_web3/get_event_access_web3_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'get_event_access_options_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class GetEventAccessOptionsScreen extends StatefulWidget {
  GetEventAccessOptionsScreen({required this.userID, required this.gameMap}) {
    // Constructor
  }

  String userID;
  Map<String, dynamic> gameMap;

  @override
  _GetEventAccessOptionsScreenState createState() => _GetEventAccessOptionsScreenState();
}

class _GetEventAccessOptionsScreenState extends State<GetEventAccessOptionsScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  // Initialize services required
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();
  GameServiceKOH gameService = GameServiceKOH();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late GetEventAccessOptionsBloc getEventAccessOptionsController;

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

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************


  void setup() async {
    /// Instantiate controller for this Game Mode page
    getEventAccessOptionsController = GetEventAccessOptionsBloc(
        userID: widget.userID,
        gameMap: widget.gameMap);

    /// Setup page and fetch required data before loading the UI
    await getEventAccessOptionsController.preloadScreenSetup();

    /// Load the UI on this screen
    await getEventAccessOptionsController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backAction() {
    Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: MainEventLandingScreen()));
  }

  getEventAccessWithDojoBalance(){
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GetEventAccessScreen(
              userID: widget.userID,
              gameMap: widget.gameMap,
            )));
  }

  getEventAccessWithYourEthWallet() async {
   /* Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GetEventAccessWeb3Screen(
              userID: widget.userID,
              gameMap: widget.gameMap,
            )));*/

    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: GetEventAccessWeb3Screen(
              userID: widget.userID,
              gameMap: widget.gameMap,
            )));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Snack bar message
  /// ***********************************************************************
  /// ***********************************************************************

  final snackBar = SnackBar(
    content: Text('A special message for you'),
  );

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: getEventAccessOptionsController.wrapperStream,
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(title: 'GET EVENT ACCESS'),
                      // ResourceEarnedSmall(resourceEarnedCount: getEventAccessController.phoBowlsEarned),
                  ],
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      backAction();
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
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/door-01.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),

                                      HostCard(
                                          transparency: true,
                                          avatar: 'avatar-host-Sensei.png',
                                          headLineVisibility: false,
                                          bodyText:
                                          'How will you gain access to the main event?',
                                      avatarName: 'SIFU'),
                                      SizedBox(height: 16),

                                      optionCardOne(
                                          buttonAction: getEventAccessWithYourEthWallet,
                                          description: 'Send 1 invite token to officer Murtaugh.',
                                          buttonTitle: 'Visit Murtaugh'),

                                      spaceVertical2(context: context),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context),

                                      optionCardTwo(
                                          buttonAction: getEventAccessWithDojoBalance,
                                          description: 'Send pho bowls to Leo. ',
                                          buttonTitle: 'Visit Leo'),

                                      /*Container(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: MediumEmphasisButton(
                                            id: 1,
                                            title: 'USE MY DOJO BALANCE',
                                            onPressAction: getEventAccessWithDojoBalance,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height:8),
                                      Text('${getEventAccessTypeController.getPhoBowlsEarnedFromFirebase} pho bowls available', style: PrimaryCaption1()),

                                      spaceVertical2(context: context),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context),

                                      Container(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: MediumEmphasisButton(
                                            id: 1,
                                            title: 'USE MY ETH WALLET',
                                            onPressAction: getEventAccessWithYourEthWallet,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height:8),
                                      Text('You have ${getEventAccessTypeController.getPhoBowlsEarnedFromETHWallet} pho bowls', style: PrimaryCaption1()),*/
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

// FaIcon(FontAwesomeIcons.scroll, size: 40, color: Colors.yellow,)

class optionCardOne extends StatelessWidget {
  const optionCardOne({required this.buttonAction, required this.description, required this.buttonTitle,
    Key? key,
  }) : super(key: key);

  final buttonAction;
  final String description;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      padding: EdgeInsets.all(24.0),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: borderRadius1(),
        color: primarySolidCardColor.withOpacity(0.7),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //FaIcon(FontAwesomeIcons.scroll, size: 40, color: Colors.yellow,),
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('images/avatar-Murtaugh-01.jpg'),
              ),
              SizedBox(width: 16),
              Flexible(
                child: Text(
                    description, style: PrimaryCaption1()),
              ),
            ],
          ),
          spaceVertical2(context: context),
          MediumEmphasisButton(
            title: buttonTitle,
            onPressAction: () {
              buttonAction();
            },
          ),
          spaceVertical2(context: context, half: true),
        ],
      ),
    );
  }
}

class optionCardTwo extends StatelessWidget {
  const optionCardTwo({required this.buttonAction, required this.description, required this.buttonTitle, this.dojoBalance = 0,
    Key? key,
  }) : super(key: key);

  final buttonAction;
  final String description;
  final String buttonTitle;
  final int dojoBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      padding: EdgeInsets.all(24.0),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: borderRadius1(),
        color: primarySolidCardColor.withOpacity(0.7),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('images/avatar-leo-04.jpg'),
              ),
              /*Image.asset(
                'images/avatar-leo-04.jpg',
                height: 40,
              ),*/
              SizedBox(width: 16),
              Flexible(
                child: Text(
                    description, style: PrimaryCaption1()),
              ),
            ],
          ),
          spaceVertical2(context: context),
          MediumEmphasisButton(
            title: buttonTitle,
            onPressAction: () {
              buttonAction();
            },
          ),
          spaceVertical2(context: context, half: true),
        ],
      ),
    );
  }
}
