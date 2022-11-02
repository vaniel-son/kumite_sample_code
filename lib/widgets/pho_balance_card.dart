import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/tool_tip_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

class PhoBalanceWidgetCard extends StatelessWidget {
  const PhoBalanceWidgetCard({this.phoBowlsEarned = 0, this.phoBowlsOnEthereumWallet = 0.0,
    Key? key,
  }) : super(key: key);

  final int phoBowlsEarned;
  final double phoBowlsOnEthereumWallet;

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
                              Text('${phoBowlsEarned}', style: PrimaryCaption1()),
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
                              Text('${phoBowlsOnEthereumWallet}', style: PrimaryCaption1()),
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
