import 'package:dojo_app/game_modes/training_emom/screens/give_pho/give_pho_screen.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import '../../../style/colors.dart';
import 'package:dojo_app/globals.dart' as globals;

/// Example for how to use this leaderboard
// QuerySnapshot allPhoBowlRecords = await databaseServiceShared.getAllPhoBowlRecords(); // get the data as a snapshot
// phoBowlLeaderboardRecords = GeneralService.convertQuerySnapshotToListOfMaps(allPhoBowlRecords); // convert into a list of maps
// Leaderboard(leaderboardRecordsList: gameModeSelectController.getPhoBowlLeaderboardRecords) // pass list into widget

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    Key? key, required this.leaderboardRecordsList, this.title = 'LEADERBOARD',
  }) : super(key: key);

  final List leaderboardRecordsList;
  final String title;

  buttonAction({context, userID, recipientUserID, recipientNickname}) {
    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            child: GivePhoScreen(
              userID: userID,
              recipientUserID: recipientUserID,
                recipientNickname: recipientNickname)));
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width) * .90,
          padding: EdgeInsets.all(16.0),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: borderRadius1(),
            color: primarySolidCardColor.withOpacity(0.7),
          ),
          child: Container(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Image.asset(
                      'images/pho-bowl-01.png',
                      height: 24,
                    ),
                    spaceHorizontal(context),
                    Text(title, style: PrimaryCaption1()),
                  ],
                ),
                SizedBox(height:16),
                SizedBox(
                  height: 275,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: leaderboardRecordsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map someData = leaderboardRecordsList[index];
                        /// get the name of the key containing the leaderboard number value
                        // for pushup contests the map key is 'score'
                        // for pho bowl leaderboard, map key is 'phoBowls'
                        int leaderboardValue = 0;
                        if (someData['phoBowls'] != null) {
                          leaderboardValue = someData['phoBowls'];
                        } else if (someData['score'] != null) {
                          leaderboardValue = someData['score'];
                        }

                        return Ink(
                          child: InkWell(
                            splashColor: Colors.red.withAlpha(100),
                            onTap: () {
                              print('tap');
                              buttonAction(context: context, userID: globals.dojoUser.uid, recipientUserID: someData['userID'], recipientNickname: someData['nickname']);
                            },
                            child: Column(
                              children: [
                                PlayerResultRow(
                                  rank: index + 1,
                                  score: leaderboardValue,
                                  playerNickname: GeneralService.capitalizeFirstLetter(someData['nickname']),
                                ),
                                spaceVertical2(context: context, half: true),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PlayerResultRow extends StatelessWidget {
  const PlayerResultRow({
    Key? key,
    required this.score, required this.rank, required this.playerNickname,
    this.scoreType = 'MAKES',
  }) : super(key: key);

  final int score;
  final String scoreType;
  final int rank;
  final String playerNickname;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width) * .90,
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Row(children: [
                  Text(
                    '$rank.', style: PrimaryCaption1(color: onPrimaryWhite)
                  ),
                  SizedBox(width: 8),
                  Text(
                    playerNickname, style: PrimaryBT1()
                  ),
                  spaceHorizontal(context),
                  //CaptionText(text: 'give pho', fontSize: 7.0, fontColor: secondaryColor),
                ],),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //FaIcon(FontAwesomeIcons.longArrowAltRight, size: 28),
                    //CaptionText(text: 'transfer', fontSize: 7.0),
                    spaceHorizontal(context),
                    Text(score.toString(), style: PrimaryStyleH5(fontSize: 22)),
                    SizedBox(width:4),
                    Baseline(
                        baseline: 30,
                        baselineType: TextBaseline.alphabetic,
                        child: FaIcon(FontAwesomeIcons.arrowCircleRight, size: 24, color: secondaryColor)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
    );
  }
}
