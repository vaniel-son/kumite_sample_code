import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;
import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/models/host_messages_model.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/models/main_event_landing_screen_widget_visibility_config_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboards_all_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/models/main_event_landing_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/constants.dart' as constants;

/// Manages / Determines the state of the player
/// based on the competition status and their game document status
// returns a status found in constantsKOH: PlayerCompetitionGameStatus class

class MainEventContentServiceService {
  // Init some stuff

  /// Constructor
  MainEventContentServiceService() {
    //
  }

  /// This service returns a list of competitions, relative to this player
  /// which is used by the main event landing page to display content
  // Gets player's status from latest competition, and previous competition
  // that is specific to a game
  // - if no competitions exists, this will create one
  // - if the latest competition is not for today, this will create one
  // - returns an object: PlayerGameCompetitionLatestAndPrevious
  static Future<List<MainEventLandingContentModel>> start({required String nickname, required QuerySnapshot competitionSnapshot, required String userID, required String gameRulesID}) async {
    /// *********************************************************
    /// INIT
    /// *********************************************************

    /// Contains all db calls from local and globally shared file
    DatabaseServicesKOH databaseService = DatabaseServicesKOH();
    DatabaseServices databaseServiceShared = DatabaseServices();

    /// Contains general services used by this game mode/rules type
    GameServiceKOH gameService = GameServiceKOH();

    /// Value to be returned
    // this will contain a list of playerGameCompetition objects
    List<MainEventLandingContentModel> playerCompetitions = [];

    /// *********************************************************
    /// Get initial competition data to process
    /// *********************************************************

    /// Store all competitions as a list of maps
    // index 0 is latest, index 1 is the 2nd most recent competition (if it exists)
    List competitionList;

    /// Store all competitions as a list of competition objects
    competitionList = gameService.convertQuerySnapshotToListOfObjects(competitionSnapshot, 'competition');

    /// *********************************************************
    /// Add objects to a list that will be returned by this service
    /// *********************************************************
    // this object contains everything the home page requires to display data
    // - competition info, game info, player's competition/game status, competition leaderboard, and player's rank

    /// Only the latest 2 competitions will be added to the competition list
    // because on the main event landing page, we only display today's and the previous competition (should add to show more)
    int maxCompetitionIndex = 2; // 2 total
    if (competitionList.length == 1) {
      maxCompetitionIndex = 1;
    }

    for (int i = 0; i <= maxCompetitionIndex - 1; i++) {

      /// *********************************************************
      ///  Prepare a single competition and game data
      /// *********************************************************

      /// Get most recent competitionID
      String competitionID = competitionList[i].id;

      /// Get game doc
      // note: if gameMap does not exist, this returns an empty map
      Map gameMap = await databaseService.fetchGameByCompetitionID(userID: userID, competitionID: competitionID);

      /// If a game doc does not exist, then create one
      // if it does exist, then this returns gameMap but converted into an object
      GameModelKOH gameInfo = await gameService.createGameWhenNotExisting(nickname: nickname, userID: userID, gameMap: gameMap, competitionID: competitionID, gameRulesID: gameRulesID);

      /// *********************************************************
      /// Determine if today... a competition status changes
      /// *********************************************************
      // can change from 'announced' --> 'open' --> 'pending judgement' --> 'winner announced' --> 'completed'
      // we need to force a status change from announced to open to pending judgement. so this is done here
      // the other status transitions (-->winner announced, -->competed) are managed by another process (End competition screen)
      competitionList[i].competitionStatus = changeCompetitionStatus(competitionList[i].dateStart, competitionList[i].competitionStatus, competitionList[i].id, competitionList[i].dateEnd);

      /// *********************************************************
      /// Determine player's status in regards to competition and game status
      /// *********************************************************

      // note: you can find the list of PlayerCompetitionGameStatus in constantsKOH
      // this is used to determine the state of a player in relationship to the competition and the game doc
      // ex status: competition is not open yet, but the player has paid to play
      // this status determines which content to display on the main event landing page
      String playerGameCompetitionStatus = getPlayerStatusForACompetition(
        competitionStatus: competitionList[i].competitionStatus,
        gameStatus: (gameInfo.gameStatus != '0') ? gameInfo.gameStatus : null,
        gameInfo: gameInfo,
      );

      /// *********************************************************
      /// Get leaderboard and this player's rank for each competition
      /// *********************************************************

      // contains a list of maps, where each map is leaderboard record for this competition
      LeaderboardAndPlayerRankModelKOH leaderboardAndPlayerRank = await gameService.getLeaderboardAndPlayerRank(
          gameRulesID: competitionList[i].gameRulesID,
          competitionID: competitionList[i].id,
          userID: userID,
          gameStatus: gameInfo.gameStatus);

      /// *********************************************************
      /// Determine background video that will play on home page
      /// *********************************************************

      // competition status options: open, winner announced
      String competitionStatus = competitionList[i].competitionStatus;

      /// get background video
      String? backgroundVideo = await getBackgroundVideo(
          gameInfo: gameInfo,
          competitionStatus: competitionStatus,
          leaderboardAndPlayerRank: leaderboardAndPlayerRank,
          gameRulesID: gameRulesID);

      /// *********************************************************
      /// Get copy for host cards
      /// *********************************************************

      // get up to two messages back to display on the home screen
      HostCardMessagesModel hostCardMessages = getHostMessages(
          playerGameCompetitionStatus: playerGameCompetitionStatus,
          leaderboardAndPlayerRank: leaderboardAndPlayerRank,
          gameInfo: gameInfo);

      /// *********************************************************
      /// Get configuration for which widget to display and hide
      /// *********************************************************

      // To determine the widgets on the home page
      // look at the player's competition and game status to inform which ones should display
      MainEventLandingWidgetVisibilityModel homeScreenWidgetVisibilityConfig = getHomeScreenWidgetVisibilityConfiguration(
        playerGameCompetitionStatus: playerGameCompetitionStatus
      );

      /// *********************************************************
      /// Create object with a player's competition and game data
      /// *********************************************************
      MainEventLandingContentModel playerGameCompetition = MainEventLandingContentModel(
        playerGameCompetitionStatus: playerGameCompetitionStatus,
        competitionID: competitionID,
        competitionInfo: competitionList[i],
        gameInfo: gameInfo,
        leaderboardAndPlayerRank: leaderboardAndPlayerRank,
        backgroundVideo: backgroundVideo,
        hostCardMessages: hostCardMessages,
        widgetVisibilityConfig: homeScreenWidgetVisibilityConfig,
      );

      /// Add this object to a list
      playerCompetitions.add(playerGameCompetition);
    }

    /// Return a list of competitions and their status for a player
    return playerCompetitions;
  }

  /// Determine if a competition status changes today
  // can change from 'announced' --> 'open' --> 'pending judgement' --> 'winner announced' --> 'completed'
  // we need to force a status change from announced to open to pending judgement
  // the other status changes are handle by other processes. ex.  'winner announced' and 'completed' are handled by end game process
  static String changeCompetitionStatus(competitionDateStart, competitionStatus, competitionID, competitionDateEnd) {
    DatabaseServices databaseServiceShared = DatabaseServices();

    // Get the competition status based on the current date time compared to the competition start/end date times
    String competitionStatusBasedOnNow = GeneralService.competitionStatus(competitionStartDateTime: competitionDateStart.toUtc(), competitionEndDatetime: competitionDateEnd.toUtc());

    if (competitionStatusBasedOnNow == constants.competitionStatus.inThePast) {
      if (competitionStatus == constantsKOH.CompetitionStatus.announced || competitionStatus == constantsKOH.CompetitionStatus.open) {
        // set new status
        competitionStatus = constantsKOH.CompetitionStatus.pendingJudgment;

        // update competition document with 'pending judgement' status
        databaseServiceShared.updateCompetitionStatus(competitionID, competitionStatus);
      }
    }

    if (competitionStatusBasedOnNow == constants.competitionStatus.open) {
      if (competitionStatus == constantsKOH.CompetitionStatus.announced) {
        // set new status
        competitionStatus = constantsKOH.CompetitionStatus.open;

        // update competition document with 'open' status
        databaseServiceShared.updateCompetitionStatus(competitionID, competitionStatus);
      }
    }

    return competitionStatus;
  }

  /// Determines the player's status in regards to a competition, and it's related game
  // everyday, there is a competition (with competitionID)
  // everytime a player starts a game, a new game is created that contains this competitionID
  // each competition and game have a status. So when combined, they create a very specific state for a player
  static String getPlayerStatusForACompetition({required String? competitionStatus, required String? gameStatus, required GameModelKOH gameInfo}){
    String playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionDoesNotExist;

    /// Competition document does not exist
    if (competitionStatus == null) {
      playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionDoesNotExist; // the competition does not exist for a specific day
    }

    /// Competition has been created for a future date, but is not accepting video submissions yet
    if (competitionStatus == constantsKOH.CompetitionStatus.announced) {
      if (gameInfo.paymentReceived == true) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasPaid;
      }

      if (gameInfo.paymentReceived == false || gameInfo.gameStatus == '0'){
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasNotPaid;
      }
    }

    /// Open competitions (accepting submissions)
    if (competitionStatus == constantsKOH.CompetitionStatus.open) {
      if (gameStatus == constantsKOH.GameStatus.open && gameInfo.paymentReceived == false){
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasNotPaid;
      }

      // gameStatus: open (started to play but did not submit video)
      if (gameStatus == constantsKOH.GameStatus.open && gameInfo.paymentReceived == true) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasPaidHasNotPlayed;
      }

      // gameStatus: videoSubmitted (player has played played)
      if (gameStatus == constantsKOH.GameStatus.videoSubmitted) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerSubmittedVideo;
      }

      // gameStatus: judgingCompleted (a score has been assigned)
      if (gameStatus == constantsKOH.GameStatus.judgingCompleted) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerJudged;
      }
    }

    if (competitionStatus == constantsKOH.CompetitionStatus.pendingJudgment) {
      playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionPending;
    }

    /// Winner Announced (accepting submissions)
    if (competitionStatus == constantsKOH.CompetitionStatus.winnerAnnounced) {
      // gameDoc does not exist (never started playing)
      if (gameStatus == null) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerHasNotPlayed;
      }

      // gameStatus: open (started to play but didn't submit video)
      if (gameStatus == constantsKOH.GameStatus.open) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerHasNotPlayed;
      }

      // winner announced, gameStatus: videoSubmitted (played)
      if (gameStatus == constantsKOH.GameStatus.videoSubmitted) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerSubmittedVideo;
      }

      // winner announced, gameStatus: judgingCompleted (a score has been assigned)
      if (gameStatus == constantsKOH.GameStatus.judgingCompleted) {
        playerStatus = constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerJudged;
      }
    }

    return playerStatus;
  }

  /// Determines which video should play on the home screen background
  static Future<String?> getBackgroundVideo({required GameModelKOH gameInfo, required String competitionStatus, required LeaderboardAndPlayerRankModelKOH leaderboardAndPlayerRank, required String gameRulesID}) async {
    String? backgroundVideo = 'none';

    /// Closed Competitions: winner announced
    // a winner has been announced so display the winner's video as the background
    if (competitionStatus == constantsKOH.CompetitionStatus.winnerAnnounced) {
      if (leaderboardAndPlayerRank.leaderboardRecords.length > 0) {
        backgroundVideo = leaderboardAndPlayerRank.leaderboardRecords[0]['playerVideo'];
      }
    }

    /// Open competition
    // this competition is accepting video submission
    if (competitionStatus == constantsKOH.CompetitionStatus.open) {

      // this player has played so display this video
      if ((gameInfo.gameStatus == constantsKOH.GameStatus.videoSubmitted || gameInfo.gameStatus == constantsKOH.GameStatus.judgingCompleted) && gameInfo.playerVideos.isNotEmpty) {
        backgroundVideo = gameInfo.playerVideos[gameInfo.userID];
      }

      // This user has not played, but at least one other player is on the leaderboard:
      // - display the top player
      // - how it determines this: gameMap has no video, or gameMap does not exist, but leaderboard has records
      if ((gameInfo.gameStatus != constantsKOH.GameStatus.videoSubmitted || gameInfo.gameStatus != constantsKOH.GameStatus.judgingCompleted) && gameInfo.playerVideos.isEmpty && leaderboardAndPlayerRank.leaderboardRecords.length > 0) {
        backgroundVideo = leaderboardAndPlayerRank.leaderboardRecords[0]['playerVideo'];
        // backgroundVideo = gameService.getRandomItemFromThisListOfStrings(backgroundVideos: leaderboardAndPlayerRank.leaderboardRecords);
      }
    }

    /// Set default background if one hasn't been set yet
    if (backgroundVideo == 'none' || competitionStatus == constantsKOH.CompetitionStatus.announced) {
      backgroundVideo = await GeneralService.getRandomBackgroundVideo(gameRulesID);
    }

    return backgroundVideo;
  }

  static HostCardMessagesModel getHostMessages({required String playerGameCompetitionStatus, required LeaderboardAndPlayerRankModelKOH leaderboardAndPlayerRank, required GameModelKOH gameInfo}) {

    // set default messages
    String hostMessage1 = 'Welcome to Dojo';
    String hostMessage2 = 'Can you become a master?';

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionDoesNotExist) {
      hostMessage1 = 'Competition does not exist';
      hostMessage2 = 'Something is awry so I alerted the maintenance staff';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasNotPaid) {
      hostMessage1 = 'The competition opens soon. \n\nGet your main event invite before other players take them all.'; // nothing to say
      hostMessage2 = '...'; // nothing to say
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasPaid) {
      hostMessage1 = 'Your invite was accepted! \n\nCome back on event day... \n\nI want you to show me how your training has paid off.';
      hostMessage2 = '...'; // nothing to say
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasPaidHasNotPlayed) {
      hostMessage1 = 'Your invite was accepted! \n\nThe grand main event is open to play, today only! \n\nPlay now to test your strength';
      hostMessage2 = '...'; // nothing to say
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasNotPaid) {
      hostMessage1 = 'Main event is open to play, today only! \n\nBut you need an invite to access the main event.';
      hostMessage2 = '...'; // nothing to say
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerSubmittedVideo) {
      hostMessage1 = 'Judges are reviewing your video submission for quality.';
      hostMessage2 = 'The pushup master will be announced after the competition ends.';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerJudged) {
      hostMessage1 = 'Good news! \n\nJudges finished reviewing your video submission.';
      hostMessage2 = 'After the competition ends, I\'ll let you know who is the new pushup master.';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionPending) {
      hostMessage1 = 'Judges are reviewing the video submissions.';
      hostMessage2 = 'The pushup master will be announced soon.';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerHasNotPlayed) {
      hostMessage1 = 'A winner has been announced.';
      hostMessage2 = 'But you did not play.';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerSubmittedVideo) {
      hostMessage1 = 'Thank you for submitting your video submission.';
      hostMessage2 = 'The competition ended but your video was mistakenly left out of the judging. I alerted the judges to look into it.';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerJudged) {
      hostMessage1 = 'Congratulations, you placed #${leaderboardAndPlayerRank.rank} with ${gameInfo.playerScores[gameInfo.userID]} reps!';
      hostMessage2 = '...';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerIsRankOne) {
      hostMessage1 = 'YOU ARE THE PUSHUP MASTER. You placed #${leaderboardAndPlayerRank.rank} with ${gameInfo.playerScores[gameInfo.userID]} reps!';
      hostMessage1 = '...';
    }

    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerIsTopTen) {
      hostMessage1 = 'Congratulations, you placed top 10! #${leaderboardAndPlayerRank.rank} with ${gameInfo.playerScores[gameInfo.userID]} reps!';
      hostMessage2 = '...';

    }

    HostCardMessagesModel hostCardMessages = HostCardMessagesModel(
      message1: hostMessage1,
      message2: hostMessage2,
    );

    return hostCardMessages;
  }

  static MainEventLandingWidgetVisibilityModel getHomeScreenWidgetVisibilityConfiguration({required String playerGameCompetitionStatus}) {

    // set default visibility
    bool isVisibleHostCardOne = true;
    bool isVisibleHostCardTwo = false;
    bool isVisibleCompetitionTimerStartsSoon = false;
    bool isVisibleCompetitionTimerEndsSoon = false;
    bool isVisiblePlayButton = false;
    bool isVisibleRequestAccessButton = false;
    bool isVisiblePushupsOverTimeChart = false;
    bool isVisibleLeaderboard = false;
    bool isVisibleInvitationPaid = false;

    // #1
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionDoesNotExist) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = false;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    // #2a
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasNotPaid) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = true;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = true;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    // #2a
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionNotOpenYetPlayerHasPaid) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = true;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = true;
    }

    // #2a
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasNotPaid) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = true;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = true;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    // #2b
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerHasPaidHasNotPlayed) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = true;
      isVisiblePlayButton = true;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = true;
    }

    // #3
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerSubmittedVideo) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = true;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = true;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    // #4
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionOpenPlayerJudged) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = true;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = true;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    // #5
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerHasNotPlayed) {
      isVisibleHostCardOne = false;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = true;
      isVisibleInvitationPaid = false;
    }

    // #6
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerSubmittedVideo) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = true;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = true;
      isVisibleInvitationPaid = false;
    }

    // #7
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerJudged) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = true;
      isVisibleInvitationPaid = false;
    }

    // #8
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerIsRankOne) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = true;
      isVisibleInvitationPaid = false;
    }

    // #9
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionWinnerAnnouncedPlayerIsTopTen) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = false;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = true;
      isVisibleLeaderboard = true;
      isVisibleInvitationPaid = false;
    }

    // #10 competition pending / no longer accepting submissions
    if (playerGameCompetitionStatus == constantsKOH.PlayerCompetitionGameStatus.competitionPending) {
      isVisibleHostCardOne = true;
      isVisibleHostCardTwo = true;
      isVisibleCompetitionTimerStartsSoon = false;
      isVisibleCompetitionTimerEndsSoon = false;
      isVisiblePlayButton = false;
      isVisibleRequestAccessButton = false;
      isVisiblePushupsOverTimeChart = false;
      isVisibleLeaderboard = false;
      isVisibleInvitationPaid = false;
    }

    MainEventLandingWidgetVisibilityModel homeScreenWidgetVisibility = MainEventLandingWidgetVisibilityModel(
      isVisibleHostCardOne: isVisibleHostCardOne,
      isVisibleHostCardTwo: isVisibleHostCardTwo,
      isVisibleCompetitionTimerStartsSoon: isVisibleCompetitionTimerStartsSoon,
      isVisibleCompetitionTimerEndsSoon: isVisibleCompetitionTimerEndsSoon,
      isVisiblePlayButton: isVisiblePlayButton,
      isVisibleRequestAccessButton: isVisibleRequestAccessButton,
      isVisiblePushupsOverTimeChart: isVisiblePushupsOverTimeChart,
      isVisibleLeaderboard: isVisibleLeaderboard,
      isVisibleInvitationPaid: isVisibleInvitationPaid,
    );

    return homeScreenWidgetVisibility;
  }

}
