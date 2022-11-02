import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

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
                        return PlayerResultRow(
                          rank: index + 1,
                          score: leaderboardValue,
                          playerNickname: someData['nickname'],
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
                ],),
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
                    Text(score.toString(), style: PrimaryStyleH5(fontSize: 20)),
                    SizedBox(width:4),
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
