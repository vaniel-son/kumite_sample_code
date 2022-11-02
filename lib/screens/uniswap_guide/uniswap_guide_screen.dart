import 'package:dojo_app/screens/uniswap_guide/uniswap_guide_bloc.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/resource_card.dart';
import 'package:dojo_app/widgets/tool_tip_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class UniswapGuideScreen extends StatefulWidget {
  UniswapGuideScreen() {
    // Constructor
  }

  @override
  _UniswapGuideScreenState createState() => _UniswapGuideScreenState();
}

class _UniswapGuideScreenState extends State<UniswapGuideScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  String userID = globals.dojoUser.uid;
  late UniswapGuideBloc uniswapGuideController;

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
    uniswapGuideController = UniswapGuideBloc(userID: userID);
    await uniswapGuideController.preloadScreenSetup();

    /// Load the widgets and UI on the screen
    uniswapGuideController.loadUIOnScreen();

    /// Play Luna SFX
    SoundService.lunaTalk(); // play SFX
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backAction() {
    Navigator.pop(context, []);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
      stream: uniswapGuideController.wrapperStream,
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
                  PageTitle(title: 'GET AN INVITE TOKEN'),
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
                            Opacity(opacity: 0.65, child: BackgroundTopImage(imageURL: 'images/luna-bull-village-01.jpg')),
                            Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 16,
                                  ),
                                  HostCard(
                                      transparency: true,
                                      avatar: 'avatar-luna.jpg',
                                      headLineVisibility: false,
                                      bodyText:
                                      'I\'m a Terra Luna bull and lost all my money to feed my baby bulls. \n\nFor ${uniswapGuideController.getPhoBowlFee} pho bowls, I\'ll give you my INVITE token. \n\nDeal?',
                                      avatarName: 'LUNA'),
                                  spaceVertical2(context: context, half: true),
                                  Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24.0,),
                                  spaceVertical2(context: context, half: true),
                                  UniswapLinkCard(phoBowlFee: uniswapGuideController.getPhoBowlFee),
                                  spaceVertical2(context: context, half: true),
                                  Divider(height: 1.0, thickness: 1.0, indent: 24.0, endIndent: 24.0,),
                                  spaceVertical2(context: context, half: true),
                                  PhoBalanceCard(uniswapGuideController: uniswapGuideController),
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
  }
}

class UniswapLinkCard extends StatelessWidget {
  const UniswapLinkCard({this.phoBowlFee = 100,
    Key? key,
  }) : super(key: key);

  final int phoBowlFee;

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
          Text(
              'Swap on UNISWAP.COM', style: PrimaryCaption1()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResourceCard(type: 'image', resourceCount: phoBowlFee, resourceName: 'PHO BOWLS', imageAsset: 'images/pho-bowl-01.png'),
              SizedBox(width: 16),
              Column(
                children: [
                  FaIcon(FontAwesomeIcons.arrowRight, size: 16, color: Colors.blue,),
                  FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: Colors.white,),
                ],
              ),
              SizedBox(width: 16),
              ResourceCard(type: 'icon', resourceCount: 1, resourceName: 'INVITE', icon: FontAwesomeIcons.scroll),
            ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              /*Image.asset(
                'images/pho-bowl-01.png',
                height: 40,
              ),*/
              SizedBox(width: 16),
              Flexible(
                child: Text(
                    'Trade on Uniswap, ROPSTEN testnet chain. Steps: (1) open uniswap app in a browser (2) then paste this link into your browser to load pho/invite trading pair.', style: PrimaryCaption1()),
              ),
            ],
          ),
          spaceVertical2(context: context),
          MediumEmphasisButton(
            title: 'Copy UNISWAP link',
            onPressAction: () {
              print('tap');
              Clipboard.setData(ClipboardData(text: "https://app.uniswap.org/#/swap?chain=ropsten&inputCurrency=0xbe5a7FC4abdBB335A508FdC4b81Cd1Fea46ac90A&outputCurrency=0x595ee94Ef08AA90940d674151907eE5Ad512ae8e&exactField=output&exactAmount=1&use=v1"));
              GeneralService.displaySnackBar(context, 'Uniswap link copied');

            },
          ),
          spaceVertical2(context: context, half: true),
        ],
      ),
    );
  }
}

class PhoBalanceCard extends StatelessWidget {
  const PhoBalanceCard({required this.uniswapGuideController,
    Key? key,
  }) : super(key: key);

  final UniswapGuideBloc uniswapGuideController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withOpacity(0.5),
          //onTap: onPressAction,
          onTap: () {
            Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: ToolTipScreen(
              headline: 'YOUR PHO BOWLS',
              bodyText: 'DOJO WALLET \n\nDOJO rewards are instantly stored in your DOJO wallet. \n\n\nYOUR ETH WALLET \n\n📅 Every week, your DOJO WALLET balance is auto transferred to your Ethereum Wallet (use OPTIMISM CHAIN). \n\n\nON UNISWWAP.COM \n\nUse your Ethereum wallet to swap ➡️ for a main event invite token.',
            )));
          },
          child: Container(
            width: (MediaQuery.of(context).size.width) * .90,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: borderRadius1(),
              color: onPrimaryBlack.withOpacity(0.6),
            ),
            child: Column(
              children: [

                /// Headline
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        Row(
                          children: [
                            Text('YOUR PHO BOWLS', style: PrimaryCaption1()),
                            SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.solidQuestionCircle,
                              size: 12,
                              color: Colors.yellow,
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                spaceVertical2(context: context, half: true),

                /// DOJO Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 4),
                              Flexible(child: Text('DOJO WALLET', style: PrimaryCaption1())),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${uniswapGuideController.phoBowlsEarned}', style: PrimaryCaption1()),
                              SizedBox(width:8),
                              Image.asset(
                                'images/pho-bowl-01.png',
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                spaceVertical2(context: context, half: true),

                /// ETH Balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 4),
                              Flexible(child: Text('YOUR ETH WALLET', style: PrimaryCaption1())),
                              SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('${uniswapGuideController.phoBowlsOnEthereumWallet}', style: PrimaryCaption1()),
                              SizedBox(width:8),
                              Image.asset(
                                'images/pho-bowl-01.png',
                                height: 24,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                spaceVertical2(context: context, half: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
