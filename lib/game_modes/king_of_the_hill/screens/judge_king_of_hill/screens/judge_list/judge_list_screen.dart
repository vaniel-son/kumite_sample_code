import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/models/judge_counts_model_koh.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/judge_card.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:dojo_app/widgets/widget_collection_title.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/judge_king_of_hill/screens/judge_list/judge_list_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/globals.dart' as globals;

//ignore: must_be_immutable
class JudgeListScreen extends StatefulWidget {
  JudgeListScreen() {
    // Constructor
  }

  @override
  _JudgeListScreenState createState() => _JudgeListScreenState();
}

class _JudgeListScreenState extends State<JudgeListScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  late String nickname;
  late String userID = globals.dojoUser.uid;

  // Initialize services required
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  GameServiceKOH matchService = GameServiceKOH();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late JudgeListBloc judgeListController;

  /// StreamController to manage loading required data before moving forward
  // to load level selection page
  final _judgeListWrapperController = StreamController<Map>();
  Stream<Map> get judgeListWrapperStream => _judgeListWrapperController.stream;
  Sink<Map> get judgeListWrapperSink => _judgeListWrapperController.sink;

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
    printBig('Judge List Dispose Called', 'true');
    super.dispose();
    _judgeListWrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  void setup() async {
    // Instantiate controller for this Game Mode page
    judgeListController = JudgeListBloc(userID: userID);

    // Preload required data before loading screen or bloc
    await judgeListController.preloadScreenSetup();
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
        stream: judgeListController.wrapperStream,
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
                  title: PageTitle(title: 'DOJO JUDGING'),
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
                            height: (MediaQuery.of(context).size.height) + 100,
                                /*(MediaQuery.of(context).padding).top -
                                (MediaQuery.of(context).padding).bottom,*/
                            child: Stack(
                              children: <Widget>[
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      StreamBuilder<JudgeCountsModelKOH>(
                                        stream: judgeListController.gamesForJudgingCountStream,
                                        initialData: JudgeCountsModelKOH(),
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final counts = snapshot.data as JudgeCountsModelKOH;
                                            return Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text('${judgeListController.competitionDate}', style:Theme.of(context).textTheme.bodyText1)
                                                    ],
                                                  ),
                                                  SizedBox(height:16),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Column(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Text('OPEN GAMES', style: PrimaryCaption1()),
                                                              ]
                                                          ),
                                                          SizedBox(height:8),
                                                          Row(
                                                              children: [
                                                                SizedBox(width:8),
                                                                Text('${counts.openCount}', style: PrimaryStyleH5()),
                                                              ]
                                                          ),
                                                        ],
                                                      ),
                                                      //SizedBox(width: 16),
                                                      Column(
                                                        children: [
                                                          Row(
                                                              children: [
                                                                Text('CLOSED GAMES', style: PrimaryCaption1()),
                                                              ]
                                                          ),
                                                          SizedBox(height:8),
                                                          Row(
                                                              children: [
                                                                SizedBox(width:8),
                                                                Text('${counts.totalClosedCount}', style: PrimaryStyleH5()),
                                                              ]
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }
                                      ),
                                      SizedBox(height: 16),
                                      WidgetCollectionTitle(title: 'Games open for judging'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.gamesOpenForJudgingStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesOpenForJudging = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesOpenForJudging.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesOpenForJudging[index]['userID'];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesOpenForJudging[index]['playerNickname']}',
                                                      gameID: '${listOfMatchesOpenForJudging[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesOpenForJudging[index]['playerNickname']}',
                                                      playerOneScore:
                                                      '${listOfMatchesOpenForJudging[index]['playerScores']}',
                                                      playerOneVideo:
                                                      '${listOfMatchesOpenForJudging[index]['playerVideo']}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesOpenForJudging[index]['id']}',
                                                      dateUpdated: '${listOfMatchesOpenForJudging[index]['dateUpdated']}',
                                                      gameTitle: '${listOfMatchesOpenForJudging[index]['gameRules']['title']}',
                                                      gameMap: listOfMatchesOpenForJudging[index],
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      /*WidgetCollectionTitle(title: 'Games pending consensus'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.gamesPendingConsensusStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesPendingConsensus = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesPendingConsensus.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesPendingConsensus[index]['userID'];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesPendingConsensus[index]['playerNickname']}',
                                                      gameID: '${listOfMatchesPendingConsensus[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesPendingConsensus[index]['playerNickname']}',
                                                      playerOneScore:
                                                      '${listOfMatchesPendingConsensus[index]['playerScore']}',
                                                      playerOneVideo:
                                                      '${listOfMatchesPendingConsensus[index]['playerVideo']}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesPendingConsensus[index]['id']}',
                                                      dateUpdated: '${listOfMatchesPendingConsensus[index]['dateUpdated']}',
                                                      cardType: 'pending',
                                                      gameTitle: '${listOfMatchesPendingConsensus[index]['gameRules']['title']}',
                                                      gameMap: listOfMatchesPendingConsensus[index],
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      WidgetCollectionTitle(title: 'You Successfully Judged'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.gamesClosedSuccessJudgementStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesSuccessJudgement = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesSuccessJudgement.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesSuccessJudgement[index]['userID'];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesSuccessJudgement[index]['playerNickname']}',
                                                      gameID: '${listOfMatchesSuccessJudgement[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesSuccessJudgement[index]['playerNickname']}',
                                                      playerOneScore:
                                                      '${listOfMatchesSuccessJudgement[index]['playerScore']}',
                                                      playerOneVideo:
                                                      '${listOfMatchesSuccessJudgement[index]['playerVideo']}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesSuccessJudgement[index]['id']}',
                                                      dateUpdated: '${listOfMatchesSuccessJudgement[index]['dateUpdated']}',
                                                      cardType: 'success',
                                                      gameTitle: '${listOfMatchesSuccessJudgement[index]['gameRules']['title']}',
                                                      gameMap: listOfMatchesSuccessJudgement[index],
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),
                                      WidgetCollectionTitle(title: 'You Failed in Judgement'),
                                      StreamBuilder<List>(
                                        stream: judgeListController.gamesClosedFailedJudgementStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final listOfMatchesFailedJudgement = snapshot.data as List;
                                            return SizedBox(
                                              height: 95,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: listOfMatchesFailedJudgement.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    String playerOneUserID = listOfMatchesFailedJudgement[index]['userID'];
                                                    return JudgeCard(
                                                      avatarImage: 'images/avatar-blank.png',
                                                      avatarFirstLetter: 'M',
                                                      title:
                                                      '${listOfMatchesFailedJudgement[index]['playerNickname']}',
                                                      gameID: '${listOfMatchesFailedJudgement[index]['gameID']}',
                                                      playerOneNickname:
                                                      '${listOfMatchesFailedJudgement[index]['playerNickname']}',
                                                      playerOneScore:
                                                      '${listOfMatchesFailedJudgement[index]['playerScore']}',
                                                      playerOneVideo:
                                                      '${listOfMatchesFailedJudgement[index]['playerVideo']}',
                                                      playerOneUserID: playerOneUserID,
                                                      judgeRequestID: '${listOfMatchesFailedJudgement[index]['id']}',
                                                      dateUpdated: '${listOfMatchesFailedJudgement[index]['dateUpdated']}',
                                                      cardType: 'fail',
                                                      gameTitle: '${listOfMatchesFailedJudgement[index]['gameRules']['title']}',
                                                      gameMap: listOfMatchesFailedJudgement[index],
                                                    );
                                                  }),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        },
                                      ),*/
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
