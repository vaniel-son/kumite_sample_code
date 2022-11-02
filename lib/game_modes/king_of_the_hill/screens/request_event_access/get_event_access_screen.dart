import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/main_event_landing_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/pho_balance_card.dart';
import 'package:dojo_app/widgets/resource_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'get_event_access_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class GetEventAccessScreen extends StatefulWidget {
  GetEventAccessScreen({required this.userID, required this.gameMap}) {
    // Constructor
  }

  String userID;
  Map<String, dynamic> gameMap;

  @override
  _GetEventAccessScreenState createState() => _GetEventAccessScreenState();
}

class _GetEventAccessScreenState extends State<GetEventAccessScreen> {
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
  late GetEventAccessBloc getEventAccessController;

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
    getEventAccessController = GetEventAccessBloc(
        userID: widget.userID,
        gameMap: widget.gameMap);

    /// Setup page and fetch required data before loading the UI
    await getEventAccessController.preloadScreenSetup();

    /// Load the UI on this screen
    await getEventAccessController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backAction() {
    //Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: MainEventLandingScreen()));
    if (getEventAccessController.screenState == getEventAccessController.screenStatePaid) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: MainEventLandingScreen()));
    }
    Navigator.pop(context);
  }

  endCompetitionButtonAction() async {
    // display success message when complete
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        stream: getEventAccessController.wrapperStream,
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
                      PageTitle(title: 'PAY WITH YOUR DOJO WALLET'),
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
                                //Opacity(opacity: 0.35, child: BackgroundTopImage(imageURL: 'images/dojo-village-day-02.jpg')),
                                Opacity(opacity: 0.65, child: BackgroundTopImage(imageURL: 'images/luna-bull-village-01.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          transparency: true,
                                          avatar: 'avatar-leo-04.jpg',
                                          headLineVisibility: false,
                                          bodyText:
                                          '${getEventAccessController.hostCardBody}',
                                      avatarName: 'LEO'),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ResourceCard(type: 'image', resourceCount: getEventAccessController.getPhoBowlFee, resourceTitle: 'COST', resourceName: 'PHO BOWLS', imageAsset: 'images/pho-bowl-01.png'),
                                          SizedBox(width: 16),
                                          Column(
                                            children: [
                                              FaIcon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.blue,),
                                              //FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: Colors.white,),
                                            ],
                                          ),
                                          SizedBox(width: 16),
                                          ResourceCard(type: 'avatar', imageAsset: 'images/avatar-leo-04.jpg'),
                                        ],
                                      ),

                                      Visibility(
                                        visible: getEventAccessController.isGivePhoBowlButtonVisible,
                                        child: Container(
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: (getEventAccessController.isGivePhoBowlButtonEnabled) ? HighEmphasisButton(
                                              id: 1,
                                              title: 'SWAP',
                                              onPressAction: getEventAccessController.givePhoBowls,
                                            ) : DisabledButton(title: 'PAY WITH DOJO WALLET'),
                                          ),
                                        ),
                                      ),

                                      spaceVertical2(context: context),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context, half: true),

                                      PhoBalanceWidgetCard(phoBowlsEarned: getEventAccessController.phoBowlsEarnedFromFirebase, phoBowlsOnEthereumWallet: getEventAccessController.getPhoBowlsEarnedFromETHWallet)
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
