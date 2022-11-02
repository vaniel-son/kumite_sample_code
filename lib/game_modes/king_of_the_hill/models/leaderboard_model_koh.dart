
class LeaderboardModelKOH {
  LeaderboardModelKOH({
    required this.dateAdded,
    required this.id,
    required this.competitionID,
    required this.gameRulesID,
    required this.gameID,
    required this.nickname,
    required this.score,
    this.playerVideo = '0',
    required this.userID,
  });

  String id; // document identifier
  DateTime dateAdded;

  String competitionID;
  String gameRulesID;
  String gameID;
  String nickname;
  int score;
  String playerVideo;
  String userID;

  Map<String, dynamic> toMap(){
    return {
    'id': id,
    'dateAdded': dateAdded,

    'competitionID': competitionID,
    'gameRulesID': gameRulesID,
    'gameID': gameID,
    'nickname': nickname,
    'score': score,
    'playerVideo': playerVideo,
    'userID': userID,
    };
  }

}
