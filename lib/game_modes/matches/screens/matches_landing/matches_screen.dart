import 'package:dojo_app/game_modes/matches/screens/game_modes/game_modes_wrapper.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/form_judgment_card.dart';
import 'package:dojo_app/widgets/line_chart.dart';
import 'package:dojo_app/widgets/matches_versus_card.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globals;
import 'package:dojo_app/widgets/nutrition_card.dart';
import 'package:dojo_app/widgets/match_score_card.dart';

//ignore: must_be_immutable
class MatchesScreen extends StatefulWidget {
  MatchesScreen() {
    //
  }

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in variables
  // the global values are set in the levels_wrapper
  String defaultBackgroundVideo = globals.matchesWrapperMap['matchesVideoMap']['backgroundVideo'];
  bool displayBackgroundVideo = globals.matchesWrapperMap['matchesVideoMap']['displayBackgroundVideo'];
  String gameMode = globals.matchesWrapperMap['gameMode'];
  String matchGroupID = globals.matchesWrapperMap['groupID'];
  String nickname = globals.matchesWrapperMap['nickname'];
  String playerOneUserID = globals.matchesWrapperMap['userID'];
  List<Widget> notificationWidgetList = globals.matchesWrapperMap['notificationWidgetList'] as List<Widget>;

  /// Declare variable where most of the logic is managed for this page
  // majority of the logic is in this object
  late MatchesBloc matchesController;
  late var matchInfo;

  /// Manage opacity of layer on top of background video
  String videoOpacity = 'high';

  @override
  void initState() {
    super.initState();

    /// Instantiate controller for this Matches page
    matchesController = MatchesBloc(gameMode: gameMode, matchGroupID: matchGroupID, playerOneUserID: playerOneUserID);
  }

  @override
  void dispose() {
    printBig('Matches Dispose Called', 'true');
    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backButtonAction() {
    Navigator.pushAndRemoveUntil(
        context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: GameModesWrapper()), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Active Match Screen Widget
  /// ***********************************************************************
  /// ***********************************************************************

  Widget activeMatchCard(Map matchesMapWithExtraData, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Column(
            children: notificationWidgetList,
          ),
          SizedBox(
            height: 16,
          ),
          HostCard(
              headLine: '${matchesMapWithExtraData['hostMessage']['title']}', bodyText: '$nickname, ${matchesMapWithExtraData['hostMessage']['message']}'),
          SizedBox(height: 16),
          MatchesVersusCard(
            thisPlayer: matchesMapWithExtraData['thisPlayer'],
            opponentPlayer: matchesMapWithExtraData['opponentPlayer'],
            opponentStatus: '${matchesMapWithExtraData['opponentStatus']}',
            challengeButtonStatus: matchesMapWithExtraData['challengeButtonStatus'],
            challengeButtonText: matchesMapWithExtraData['challengeButtonText'],
            playerOneRecords: matchesMapWithExtraData['playerOneRecords'],
            playerTwoRecords: matchesMapWithExtraData['playerTwoRecords'],
            matchesMap: matchesMapWithExtraData, // full match details
          ),
          SizedBox(
            height: 16,
          ),
          MatchScoreCard(matchDetailsMap: matchesMapWithExtraData),
          matchesMapWithExtraData['addFoodButtonVisibility'] ? addFoodImageButton(matchesMapWithExtraData, context) : Container(),
          NutritionCard(matchDetailsMap: matchesMapWithExtraData),
          FormJudgementCard(questions: matchesMapWithExtraData['questions']['form'], gameInfo: matchesMapWithExtraData['gameInfo'], gameInfoExtras: matchesMapWithExtraData['gameInfoExtras']),
          SizedBox(height: 16),
          LineChart(playerRecords: matchesMapWithExtraData['playerOneRecords'], title: '${matchesMapWithExtraData['thisPlayer']['playerNickname']} Pushups (Reps)'),
          LineChart(
              playerRecords: matchesMapWithExtraData['playerTwoRecords'], title: '${matchesMapWithExtraData['opponentPlayer']['playerNickname']} Pushups (Reps)'),
        ],
      ),
    );
  }

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
        title: PageTitle(title: 'TURN BASED 2 PLAYER'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            backButtonAction();
          },
        ),
        backgroundColor: primarySolidBackgroundColor,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            displayBackgroundVideo ? VideoFullScreen(videoURL: defaultBackgroundVideo, videoConfiguration: 4) : Container(),
            BackgroundOpacity(opacity: videoOpacity),
            displayBackgroundVideo ? Container() : Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
            StreamBuilder<Map>(
                stream: matchesController.matchDetailsStream,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    final matchesMapWithExtraData = snapshot.data as Map;
                    if (matchesMapWithExtraData['matchExists'] == true){
                      return activeMatchCard(matchesMapWithExtraData, context);
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                }),
          ],
        ),
      ),
    );
  }
}
