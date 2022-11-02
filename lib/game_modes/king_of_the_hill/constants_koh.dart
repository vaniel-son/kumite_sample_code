/// Manage the life cycle of a competition
// helps us determine the state of a competition
class CompetitionStatus{
  // primary competition status
  static String announced = 'announced'; // available, but has not started yet and is not accepting submissions
  static String open = 'open'; // accepting submissions, winner not announced
  static String pendingJudgment = 'pending judgement'; // submission window closed while judges are reviewing
  static String winnerAnnounced = 'winner announced';
  static String completed = 'completed';

  // other competition status, probably won't use
  static String acceptingSubmissions = 'accepting submissions'; // accepting video submissions
  static String archived = 'archived';
  static String closed = 'closed'; // not accepting submissions
}

/// Manage the life cycle of a game document
// helps us determine the state of the game, specific to the game mode type;
class GameStatus{
  static String open = 'open'; // a game doc has been create but they have not submitted a video yet
  static String videoSubmitted = 'video submitted'; // the user has submitted a video
  static String judgingCompleted = 'judging completed'; // judging completed and a score has been provided

  // other game status states, not planning to use yet
  static String competitionClosed = 'competition closed'; // winner has been announced
  static String closed = 'closed';
}

/// Manage the life cycle of judge documents
// helps us determine the state of the game in judgement
class JudgeStatus{
  static String open = 'open'; // a game doc has been create but they have not submitted a video yet
  static String judgingCompleted = 'judging completed'; // the user has submitted a video
  static String archived = 'archived'; // judging completed and a score has been provided
}

/// Types of game document updates so we can track specifically what was update.
// uses: discord bot
class GameUpdateTypes{
  static String videoSubmitted = 'videoSubmitted';
  static String judgingCompleted = 'judgingCompleted';
}

/// Used on games document, to identify when a specific field was updated
class EventDates{
  static String videoSubmitted = 'video submitted'; // the user has submitted a video
  static String judgingCompleted = 'judging completed'; // judging completed and a score has been provided
}

/// Manage the life cycle of a player and their relationship to a game
class PlayerCompetitionGameStatus{
  static String competitionDoesNotExist = 'competition does not exist'; // the competition does not exist for a specific day

  // todays date < competition date (competition not open yet)
  static String competitionNotOpenYetPlayerHasNotPaid = 'competition not open yet player has not paid';
  static String competitionNotOpenYetPlayerHasPaid = 'competition not open yet player has paid';

  // todays date = competition date (competition open)
  static String competitionOpenPlayerHasNotPaid = 'competition open player has not paid';
  static String competitionOpenPlayerHasPaidHasNotPlayed = 'competition open, player has paid, has not played';

  static String competitionOpenPlayerSubmittedVideo = 'competition open player has submitted a video';
  static String competitionOpenPlayerJudged = 'competition open player has been judged';

  // the competition is no longer accepting submissions,
  // this occurs when a competition is in the past
  // but we haven't judged it or put it into any of these other states.
  static String competitionPending = 'competition pending';

  // competition has a winner announced
  static String competitionWinnerAnnouncedPlayerHasNotPlayed = 'competition winner announced player has not played';
  static String competitionWinnerAnnouncedPlayerSubmittedVideo = 'competition winner announced player submitted video';
  static String competitionWinnerAnnouncedPlayerJudged = 'competition winner announced player judged'; // completed the competition successfully
  static String competitionWinnerAnnouncedPlayerIsRankOne = 'competition winner announced player is rank one';
  static String competitionWinnerAnnouncedPlayerIsTopTen = 'competition winner announced player is top ten';

  // unused
  static String competitionPendingPlayHasNotPlayed = 'competition pending player has not played';
  static String competitionPendingPlayerSubmittedVideo = 'competition pending player has submitted a video';
  static String competitionPendingPlayerJudged = 'competition pending player has been judged';
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

  DoNothing,
}

enum RecordingEnum { StartRecording, StopRecording, StartStreamWithoutRecording, StopStreamWithoutRecording, DoNothing }

/// Player Game Status, for a game of 2 players
// Determines an specific player's game status within a game
// the values are used to help determine UI, game logic
// where the states of individual matches are saved in match documents
const String cPlayerGameOutcomeWin = 'win';
const String cPlayerGameOutcomeLose = 'lose';
const String cPlayerGameOutcomeTie = 'tie';
const String cPlayerGameOutcomeWinByForfeit = 'win by forfeit';
const String cPlayerGameOutcomeLoseByForfeit = 'lose by forfeit';
const String cPlayerGameOutcomeOpen = 'open'; // the player has not played yet
const String cPlayerGameOutcomePending = 'pending'; // the player has played but waiting for opponent to play
const String cPlayerGameOutcomeConfirmed = 'confirmed'; // the player has had their game successfully judged

/// Judging Game Status
// saved to the JUDGING collection to determine judge request status
const String cJudgeMatchStatusOpen = 'open';
const String cJudgeMatchStatusClosed = 'closed';

/// KOH: Manage countdown timer and workout timer # //changeForProduction//
// when debugging, lower the times so you can get through the game xp faster
// otherwise, leave this for prod as:
// countdownTimer = 10 (prod)
// workoutTimer = 60 (prod)
const int cCountdownTimer = 10;
const int cWorkoutTimer = 60;

/// game document: dates map... their key names
const String cPlayersScoreUpdated = 'playerScoreUpdated';
const String cMatchClosed = 'matchClosed';
const String cFoodUpdated = 'foodUpdated';
const String cJudgingUpdated = 'judgingUpdated';

///Tutorial list of stages
enum TutorialStage {
  training,
  earnPho,
  mainEvent,
  intro,
  howToWin,
  ready,
  end,
  doNothing
}
