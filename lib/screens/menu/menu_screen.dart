import 'package:dojo_app/game_modes/king_of_the_hill/screens/end_game/end_game_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/judge_king_of_hill/screens/judge_list/judge_list_screen.dart';
import 'package:dojo_app/screens/delete_user_account/delete_user_screen.dart';
import 'package:dojo_app/screens/game_mode_select/game_mode_select_screen.dart';
import 'package:dojo_app/screens/update_wallet_address/update_wallet_address_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../../style/colors.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:dojo_app/playground/moralis_poc/moralis_api_test_screen.dart';



/// Simple template that can be starting point for any Screen.

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  DatabaseServices databaseServices = DatabaseServices();
  final AuthService _auth = AuthService();

  late Future<String> nickname;

  // Manage admin view
  bool enableAdminView = false;

  @override
  void initState() {
    super.initState();

    // get nickname to display on UI
    nickname = GeneralService.getNickname(globals.dojoUser.uid);

    // determine if admin view should be enabled
    if (globals.dojoUser.uid == constants.admin1 ||
        globals.dojoUser.uid == constants.admin2 ||
        globals.dojoUser.uid == constants.admin3 ||
        globals.dojoUser.uid == constants.admin4 ||
        globals.dojoUser.uid == constants.admin5) {
      enableAdminView = true;
    }
  }

  backButtonAction() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primarySolidBackgroundColor,
      appBar: AppBar(
        //title: PageTitle(title: 'TURN BASED 2 PLAYER'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              CustomCircleAvatar(avatarFirstLetter: globals.nickname[0].toUpperCase()),
                              SizedBox(width: 16),
                              Text(globals.nickname, style: Theme.of(context).textTheme.headline4),
                            ],
                          ),
                          SizedBox(
                            height: 32,
                          ),

                          /// Home

                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModeSelectScreen()), (Route<dynamic> route) => false);
                                  print('tap');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.new_label,
                                        size: 32),
                                    SizedBox(width: 16),
                                    Text('Home', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),
                          /// Eth address form
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade,
                                      child: UpdateWalletAddressScreen(
                                        updateCheck: true,
                                        updatePageHostCardVisibility:true ,
                                        updatePageButtonVisibility: true,
                                        newPageButtonVisibility: false,
                                        newPageHostCardVisibility: false,
                                        skipButtonVisibility: false,
                                        backButtonVisibility: true,
                                      )
                                  )
                                      , (Route<dynamic> route) => false);
                                  print('tap');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.wallet_travel_outlined,
                                        size: 32),
                                    SizedBox(width: 16),
                                    Text('Update wallet address', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ),

                          /// Judging

                          enableAdminView ? Column(
                            children: [
                              SizedBox(height: 16),
                              Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: JudgeListScreen()), (Route<dynamic> route) => false);
                                  print('tap');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.sports_score_outlined,
                                        size: 36),
                                    SizedBox(width: 16),
                                    Text('Judging', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          ) : Container(),

                          /// End Game
                          enableAdminView ? Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: EndGameScreen()), (Route<dynamic> route) => false);
                                  print('tap');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.new_label,
                                        size: 32),
                                    SizedBox(width: 16),
                                    Text('End Game', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ) : Container(),

                          SizedBox(height: 16),
                          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                          SizedBox(height: 16),

                          /// Discord
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var url = "https://discord.gg/jq3yVjFZvQ";
                                  if (await canLaunch(url)) {
                                    await launch(url, forceWebView: false);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    FaIcon(FontAwesomeIcons.discord, size: 32),
                                    SizedBox(width: 16),
                                    Text('Discord Community', style: Theme.of(context).textTheme.bodyText1)
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),

                          /// Twitter
                          /*Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var url = "https://twitter.com/dojothegame";
                                  if (await canLaunch(url)) {
                                    await launch(url, forceWebView: false);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    FaIcon(FontAwesomeIcons.discord, size: 32),
                                    SizedBox(width: 16),
                                    Text('Discord Community', style: Theme.of(context).textTheme.bodyText1)
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),*/

                          /// Share Feedback
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  var url = "https://docs.google.com/forms/d/e/1FAIpQLSfMh8UU3IcrJpeNfSPbfibHKWEpr67c74akx0Rng-tq7ShLxg/viewform";
                                  if (await canLaunch(url)) {
                                    await launch(url, forceWebView: false, enableJavaScript: false);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.feedback,
                                        size: 32),
                                    SizedBox(width: 16),
                                    Text('Share your feedback', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),

                          /// MLKit Test
                          /*enableAdminView ? Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: ComputerVisionTest()), (Route<dynamic> route) => false);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    FaIcon(FontAwesomeIcons.database, size: 32),
                                    SizedBox(width: 16),
                                    Text('MLKit Test', style: Theme.of(context).textTheme.bodyText1)
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ) : Container(),*/

                          /// Moralis API
                          enableAdminView ? Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: MoralisApi()), (Route<dynamic> route) => false);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    FaIcon(FontAwesomeIcons.bitcoin, size: 32),
                                    SizedBox(width: 16),
                                    Text('Moralis API', style: Theme.of(context).textTheme.bodyText1)
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ) : Container(),

                          /// Video NFT Mint

                          /*enableAdminView ? Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: VideoNft()), (Route<dynamic> route) => false);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    FaIcon(FontAwesomeIcons.ethereum, size: 32),
                                    SizedBox(width: 16),
                                    Text('Video NFT Mint', style: Theme.of(context).textTheme.bodyText1)
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ) : Container(),*/

                          SizedBox(height: 16),
                          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                          SizedBox(height: 16),

                          /// Logout

                          Column(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Wrapper()), (Route<dynamic> route) => false);
                                  await _auth.signOut();
                                  print('tap');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: 8),
                                    Icon(Icons.logout,
                                        size: 32),
                                    SizedBox(width: 16),
                                    Text('Log out', style: Theme.of(context).textTheme.bodyText1),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),

                              SizedBox(height: 16),
                              Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                              SizedBox(height: 16),

                              /// Version Number
                              Row(
                                children: [
                                  SizedBox(width: 8),
                                  /*Icon(Icons.logout,
                                      size: 32),*/
                                  SizedBox(width: 16),
                                  Text('Version: ${globals.appVersion.version} b${globals.appVersion.buildNumber}', style: PrimaryCaption1(color: onPrimaryWhite)),
                                ],
                              ),

                              SizedBox(height: 16),
                              Divider(height: 1.0, thickness: 1.0, indent: 0.0),
                              SizedBox(height: 16),


                              /// Delete Account
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: DeleteUserScreen()));
                                    },
                                    child: Row(
                                      children: [
                                        SizedBox(width: 8),
                                        Icon(Icons.delete,
                                            size: 32),
                                        SizedBox(width: 16),
                                        Text('Delete Account', style: Theme.of(context).textTheme.bodyText1),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // top module
  }
}
