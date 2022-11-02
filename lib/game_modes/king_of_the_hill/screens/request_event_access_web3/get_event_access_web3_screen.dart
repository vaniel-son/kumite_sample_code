import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/screens/uniswap_guide/uniswap_guide_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/resource_card.dart';
import 'package:dojo_app/widgets/tool_tip_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'get_event_access_web3_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//ignore: must_be_immutable
class GetEventAccessWeb3Screen extends StatefulWidget {
  GetEventAccessWeb3Screen({required this.userID, required this.gameMap}) {
    // Constructor
  }

  String userID;
  Map<String, dynamic> gameMap;

  @override
  _GetEventAccessWeb3ScreenState createState() => _GetEventAccessWeb3ScreenState();
}

class _GetEventAccessWeb3ScreenState extends State<GetEventAccessWeb3Screen> {
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
  late GetEventAccessWeb3Bloc getEventAccessController;

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
    getEventAccessController = GetEventAccessWeb3Bloc(userID: widget.userID, gameMap: widget.gameMap);

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
    // Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rightToLeftWithFade, child: MainEventLandingScreen()));
    Navigator.pop(context);
  }

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
                      PageTitle(title: 'SEND YOUR INVITE TOKEN'),
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
                                Opacity(opacity: 0.5, child: BackgroundTopImage(imageURL: 'images/dojo-village-day-02.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          transparency: true,
                                          avatar: 'avatar-Murtaugh-01.jpg',
                                          headLineVisibility: false,
                                          bodyText: 'Send me 1 INVITE token to the below address...\n\n... and I can give you main event access because I know folks in high places.',
                                          avatarName: 'COP\n\nMURTAUGH'),

                                      spaceVertical2(context: context, half: true),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context, half: true),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ResourceCard(type: 'icon', resourceCount: 1, resourceTitle: 'COST', resourceName: 'INVITE', icon:FontAwesomeIcons.scroll),
                                          SizedBox(width: 16),
                                          Column(
                                            children: [
                                              FaIcon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.blue,),
                                              //FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: Colors.white,),
                                            ],
                                          ),
                                          SizedBox(width: 16),
                                          ResourceCard(type: 'avatar', imageAsset: 'images/avatar-Murtaugh-01.jpg'),
                                        ],
                                      ),

                                      /// Ethereum Address Card
                                      InkWell(
                                        splashColor: Colors.red,
                                        highlightColor: Colors.red.withOpacity(0.5),
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: getEventAccessController.getPaymentAddress));
                                          GeneralService.displaySnackBar(context, 'ETH address copied');
                                        },
                                        child: Container(
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
                                                  Text("ETH OPTIMISM ADDRESS", style: PrimaryCaption1(color: captionColor)),
                                                ],
                                              ),
                                              SizedBox(height: 24),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  //BodyText1(text: getEventAccessController.getPaymentAddress),
                                                  Expanded(
                                                    child: Text(
                                                      getEventAccessController.getPaymentAddress,
                                                      overflow: TextOverflow.fade,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                    ),
                                                  ),
                                                  FaIcon(FontAwesomeIcons.solidCopy, size: 20),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      spaceVertical2(context: context, half: true),
                                      Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24),
                                      spaceVertical2(context: context, half: true),

                                      ToolTipCard(
                                        text: 'How to get an INVITE token',
                                        imageAsset: 'images/pho-bowl-01.png',
                                        widgetToDisplayOnTap: UniswapGuideScreen(),
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
