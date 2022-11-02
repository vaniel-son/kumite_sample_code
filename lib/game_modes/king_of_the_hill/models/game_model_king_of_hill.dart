class GameModelKOH {
  GameModelKOH({
    this.competitionID = '0',
    this.gameMode = 'king of the hill',
    required this.gameRulesID,
    this.id = '0',
    this.gameStatus = '0',
    this.duration = 60,
    required this.userID,
    this.playerNicknames = const {'Empty': '0'},
    this.playerScores = const {},
    this.playerVideos = const {},
    this.playerAvatars = const {},
    this.movement = const {'Empty': '0'},
    this.gameRules = const {},
    this.judging = const {},
    this.dates = const {},

    this.ipfsURL = '',
    this.paymentReceived = false,
    this.ethereumAddressForPayment = 'unknown',

    required this.dateCreated,
    required this.dateUpdated,
  });

  String competitionID;
  String gameMode;
  String gameRulesID;
  String id;
  String gameStatus;
  int duration;

  String userID;
  Map<String, dynamic> playerNicknames;
  Map<String, dynamic> playerScores;
  Map<String, dynamic> playerVideos;
  Map<String, dynamic> playerAvatars;
  Map<String, dynamic> movement;
  Map<String, dynamic> gameRules;
  Map<dynamic, dynamic> judging;
  Map<dynamic, dynamic> dates;

  String ipfsURL;
  bool paymentReceived;
  String ethereumAddressForPayment;

  DateTime dateCreated;
  DateTime dateUpdated;

  bool isGameEmpty = false;

  Map<String, dynamic> toMap() {
    return {
    'competitionID': competitionID,
    'gameMode': gameMode,
    'gameRulesID': gameRulesID,
    'id': id,
    'gameStatus': gameStatus,
    'duration': duration,

    'userID': userID,
    'playerNicknames': playerNicknames,
    'playerScores': playerScores,
    'playerVideos': playerVideos,
    'playerAvatars': playerAvatars,
    'movement': movement,
    'gameRules': gameRules,
    'judging': judging,
    'dates': dates,

    'ipfsURL': ipfsURL,
    'paymentReceived': paymentReceived,
    'ethereumAddressForPayment': ethereumAddressForPayment,

    'dateCreated': dateCreated,
    'dateUpdated': dateUpdated,
    };
  }
}
