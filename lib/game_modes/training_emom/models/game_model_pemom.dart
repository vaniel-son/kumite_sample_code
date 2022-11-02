class GameModelPEMOM {
  GameModelPEMOM({
    this.competitionID = '0',
    this.gameMode = 'king of the hill',
    required this.gameRulesID,
    this.id = '0',
    this.gameStatus = '0',
    this.duration = 60,
    required this.userID,
    this.playerNicknames = const {'Empty': '0'},
    this.playerScores = const {},
    this.playerGameRoundStatus = const [],
    this.playerGoals = const {},
    this.playerVideos = const {},
    this.playerAvatars = const {},
    this.playerGameOutcome = '0',
    this.movement = const {'Empty': '0'},
    this.gameRules = const {},
    this.judging = const {},
    this.dates = const {},
    this.rewards = 0,
    this.gameScore = 0.0,
    this.playerRecords = const {},

    this.ipfsURL = '',
    this.paymentReceived = false,
    this.ethereumAddress = 'unknown',

    required this.dateStart,
    required this.dateEnd,
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
  List playerGameRoundStatus;
  Map<String, dynamic> playerGoals;
  Map<String, dynamic> playerVideos;
  Map<String, dynamic> playerAvatars;
  String playerGameOutcome;
  Map<String, dynamic> movement;
  Map<String, dynamic> gameRules;
  Map<dynamic, dynamic> judging;
  Map<dynamic, dynamic> dates;
  int rewards;
  double gameScore;
  Map<String, dynamic> playerRecords;

  String ipfsURL;
  bool paymentReceived;
  String ethereumAddress;

  DateTime dateStart;
  DateTime dateEnd;
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
    'playerGameRoundStatus': playerGameRoundStatus,
    'playerGoals': playerGoals,
    'playerVideos': playerVideos,
    'playerAvatars': playerAvatars,
    'playerGameOutcome': playerGameOutcome,
    'movement': movement,
    'gameRules': gameRules,
    'judging': judging,
    'dates': dates,
    'rewards': rewards,
    'gameScore': gameScore,
    'playerRecords': playerRecords,

    'ipfsURL': ipfsURL,
    'paymentReceived': paymentReceived,
    'ethereumAddress': ethereumAddress,

    'dateStart': dateStart,
    'dateEnd': dateEnd,
    'dateCreated': dateCreated,
    'dateUpdated': dateUpdated,
    };
  }
}
