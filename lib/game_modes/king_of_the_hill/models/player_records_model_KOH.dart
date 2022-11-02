class PlayerRecordsModelKOH {
  PlayerRecordsModelKOH({
    this.gameRules = const {},
    required this.gameRulesID,
    this.movement = const {},
    required this.personalRecord,
    required this.scoresArray,
    required this.scores,
    required this.scoresOverTime,
    required this.userID,
  });

  Map gameRules;
  String gameRulesID;
  Map movement;
  int personalRecord;
  List scoresArray;
  List scores;
  List scoresOverTime;
  String userID;

  Map<String, dynamic> toMap(){
    return {
    'gameRules': gameRules,
    'gameRulesID': gameRulesID,
    'movement': movement,
    'personalRecord': personalRecord,
    'scoresArray': scoresArray,
    'scores': scores,
    'scoresOverTime': scoresOverTime,
    'userID': userID,
    };
  }

}
