/// Manages the game mode and game rules ID
class GameRulesConstants{
  static String kingOfTheHillTitle = 'king of the hill';
  static String kohPushupMax60 = 'DLdsgABrmYpoLWw2x2C0';
  static int kohPushupMax60JudgeThreshold = 1;

  static String trainingPushupEmomTitle = 'training pushup emom';
  static String pemomPushups = 'Y6w3XZdRimjWHTNbrEmL';
}

/// Different reasons Dojo team can lock app remotely
class lockAppStatusType{
  static String updateAppVersion = 'updateAppVersion';
  static String maintenanceMode = 'maintenanceMode';
  static String accountCreationSuspended = 'accountCreationSuspended';
}

/// Discord constants
const int discordChannel = 936234726937739295; // dojo server
// const int discordChannel = 937736813253103728; // vanielson server

/// Overall Game Status
// Determines the overall state of a match
// the values are used to help determine UI, game logic
// where the states of individual matches are saved in match documents
const String cGameStatusOpen = 'open'; // not all players have played
const String cGameStatusClosed = 'closed'; // all players have played

/// Admin UIDs
String admin1 = 'AI22rzMxuphgmK5Zr8lVGht3O3D3'; // dev Van
String admin2 = 'eKv2KuKDJNNba7OUy1SNo3ilfiq2'; // dev Marvin
String admin3 = 'IaNoVdiaMtWiiyD7HFlRf5MqqSE3'; // prod Van
String admin4 = 'RRmF9OaRW1Ue6kHtczyILqq9Fyc2'; // prod Marvin
String admin5 = 'OUbllyr5PzfsYzFlXxyrSvjF8hm1'; // prod Jamie's mom Debbie
String admin6 = '6n5A87DnNMNdj0qOtjemKS5CYn43'; // prod Jamie

/// View Replay: determine point of view of current user
// when viewing the replay, the experience changes based on who is watching
enum UserPointOfView {
  Player,
  Judge,
  Spectator,
  KingOfHillJudge,
}

// Determine competition status based on time
class competitionStatus {
  static const String inThePast = 'in the past'; // already has happened
  static const String open = 'open'; // it is open right now and can be played
  static const String announced = 'announced'; // has not happened yet
}