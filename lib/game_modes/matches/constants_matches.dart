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

/// Match Status
// a 2 player match can be in many states, for example, both players have not played
// based on the match status, game logic and UI is constructed
// use constants here because spelling and description matters for the game logic
// note: if this is one of the players in the game, then player 1 is that player
// note: this player = playerOne, opponent player = playerTwo
const String cGameOpenBothPlayersHaveNotPlayed = 'cGameOpenBothPlayersHaveNotPlayed';
const String cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed = 'cGameOpenPlayerOneHasPlayedPlayerTwoHasNotPlayed';
const String cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed = 'cGameOpenPlayerOneHasNotPlayedPlayerTwoHasPlayed';
const String cGameOpenUnhandledCase = 'cGameOpenUnhandledCase';
const String cGameClosedBothPlayersLoseByForfeit = 'cGameClosedBothPlayersLoseByForfeit';
const String cGameClosedPlayerOneWinsPlayerTwoLoses = 'cGameClosedPlayerOneWinsPlayerTwoLoses';
const String cGameClosedPlayerOneLosesPlayerTwoWins = 'cGameClosedPlayerOneLosesPlayerTwoWins';
const String cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit = 'cGameClosedPlayerOneWinsByForfeitPlayerTwoLosesByForfeit';
const String cGameClosedPlayerOneLosesByForfeitPlayerTwoWinsLosesByForfeit = 'cGameClosedPlayerOneLosesByForfeitPlayerWinsLosesByForfeit';
const String cGameClosedPlayerOneTiesPlayerTwoTies = 'cGameClosedPlayerOneTiesPlayerTwoTies';
const String cGameClosedUnhandledCase = 'cGameClosedUnhandledCase';

/// Secondary Game Status
// matches can be in several states simultaneously
// judging status is saved to MATCH collection, in field JUDGE
const String cGameStatusSecondaryJudgeOpen = 'open';
const String cGameStatusSecondaryJudgePending = 'pending';
const String cGameStatusSecondaryJudgeClosed = 'closed';

/// Challenge Button status
// controls whether to display the challenge button on the match screen
const String cChallengeButtonStatusHidden = 'hidden';
const String cChallengeButtonStatusEnabled = 'enabled';

/// Judging Match Status
// saved to the JUDGING collection to determine judge request status
const String cJudgeMatchStatusOpen = 'open';
const String cJudgeMatchStatusClosed = 'closed';

/// View Replay: determine point of view of current user
// when viewing the replay, the experience changes based on who is watching
enum UserPointOfViewMatches {
  Player,
  Judge,
  Spectator,
  //KingOfHillJudge,
}

/// Player Sub Scores: labels for the types of player sub scores
const String cSubScoreTypeNutrition = 'nutrition';
const String cSubScoreTypeSleep = 'sleep';
const String cSubScoreTypeReps = 'reps';
const String cSubScoreTypeForm = 'form';

/// Manage countdown timer and workout timer
// when debugging, lower the times so you can get through the game xp faster
// otherwise, leave this for prod as:
// countdownTimer = 10 (prod)
// workoutTimer = 60 (prod)
const int cCountdownTimer = 5;
const int cWorkoutTimer = 60;

/// Match duration, should only be in multiples of 24.
const int cMatchDurationHours = 1;

/// Match Activity Tracker types (found in match document)
const String nutritionActivityType = 'nutritionImagePosted';
const String sleepActivityType = 'sleepDataPosted';

/// Match document: dates map... their key names
const String cPlayersScoreUpdated = 'playerScoreUpdated';
const String cMatchClosed = 'matchClosed';
const String cFoodUpdated = 'foodUpdated';
const String cJudgingUpdated = 'judgingUpdated';