/// Manage the life cycle of a game document
// helps us determine the state of the game, specific to the game mode type;
class GameStatus{
  static String open = 'open'; // a game doc has been created but they did not complete the game yet
  static String closed = 'closed';
}

/// Types of game document updates so we can track specifically what was update.
// uses: discord bot
class GameUpdateTypes{
  static String trainingCompleted = 'trainingCompleted';
}

/// Used on games document, to identify when a specific field was updated
class EventDates{
  static String trainingCompleted = 'training completed';
}

/// Manage the life cycle of a player and their relationship to a game
class PlayerTrainingGameStatus{
  // static String trainingGameExistsForTodayPlayerHasNotPlayed = 'game exists for today but player has not played';
  static String trainingGameDoesNotExistForToday = 'game does not exist for today';
  static String trainingGameDoesNotExist = 'game does not exist';
  static String trainingGameOpenPlayerHasNotPlayed = 'game open but player has not played';
  static String trainingGameOpenForPreviousDayPlayerHasNotPlayed = 'game open for a previous day but player has not played';
  static String trainingGameClosedPlayerHasPlayedWithSuccess = 'game closed player has played with success';
  static String trainingGameClosedPlayerHasPlayedWithFailure = 'game closed player has played with failure';
}

/// Manage success/failure outcome of a training session
class PlayerTrainingOutcome {
  static String success = 'success';
  static String failure = 'failure';
  static String pending = 'pending';
}

/// Manage Games rounds status
class PlayerGameRoundStatus {
  static String pending = 'pending';
  static String current = 'current';
  static String success = 'success';
  static String failure = 'failure';
}

enum GameStage {
  Start,
  HowToPlay,
  PositionYourPhone,
  GetInFrame,
  ShowForm,
  CountdownStarting,
  Countdown,
  Play,
  TimerExpires,
  CelebrationDance,
  Saving,
  NextSteps,
  Exit,
  SetupEnvironment,
  Tutorial,
  PushupTestWithML,
  GetReady,
  ProvideScore,
  ShowPersonalResult,
  ShowAllResults,
  Level,
  DoNothing,
  Rewards,
}

/// Manage the camera during the game experience
enum RecordingEnum { StartRecording, StopRecording, StartStreamWithoutRecording, StopStreamWithoutRecording, DoNothing }

/// PEMOM: Manage countdown timer and workout timer //changeForProduction//
// when debugging, lower the times so you can get through the game xp faster
// otherwise, leave this for prod as:
// countdownTimer = 10 (prod)
// workoutTimer = 60 (prod)
const int cCountdownTimer = 10;
const int cWorkoutTimer = 60;

///Tutorial list of stages
enum TutorialStage {
  intro,
  howToWin,
  ready,
  end,
  doNothing
}
