class JudgeRequestModelKOH {
  JudgeRequestModelKOH({
    required this.id,
    required this.gameID, // id of the game to be judged
    required this.competitionID,
    required this.gameRulesID,
    required this.consensusScore,
    required this.status, // options: open, judgingCompleted, archived
    required this.judgeCountThreshold, // # of judges who need to review before a score is final

    required this.dateCreated,
    required this.dateUpdated,

    required this.userID,
    required this.playerNickname,
    required this.playerVideo, // url of the player's video

    this.judges = const [], // judge names and their nicknames {judgeID: nicknames}
    this.judgeScores = const {}, // if there are multiple judges, this is the score {judgeID: score}
    this.gameRules = const {},
  });


  String id; // document identifier
  String gameID;
  String competitionID;
  String gameRulesID;
  int consensusScore;
  String status;

  DateTime dateCreated;
  DateTime dateUpdated;

  String userID;
  String playerNickname;
  String playerVideo;

  List judges;
  Map<String, dynamic> judgeScores;
  int judgeCountThreshold;

  Map<String, dynamic> gameRules;

  Map<String, dynamic> toMap() {
    return {
    'id' : id,
    'gameID': gameID,
    'competitionID': competitionID,
    'gameRulesID': gameRulesID,
    'consensusScore': consensusScore,
    'status': status,

    'dateCreated': dateCreated,
    'dateUpdated': dateUpdated,

    'userID': userID,
    'playerNickname': playerNickname,
    'playerVideo': playerVideo,

    'judges': judges,
    'judgeScores': judgeScores,
    'judgeCountThreshold': judgeCountThreshold,

    'gameRules': gameRules,
    };
  }
}
