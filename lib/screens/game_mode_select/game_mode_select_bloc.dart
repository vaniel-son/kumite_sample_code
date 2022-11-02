import 'dart:async';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/constants.dart' as constants;

class GameModeSelectBloc {
  /// ***********************************************************************
  /// LevelSelectorBloc Constructor
  /// ***********************************************************************

  GameModeSelectBloc({required this.userID}) {
    //
  }

  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************

  /// Setup variables to be passed in
  String userID;

  /// Contains all db calls from local and globally shared file
  DatabaseServicesKOH databaseService = DatabaseServicesKOH();
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Contains general services used by this game mode/rules type
  GameServiceKOH gameService = GameServiceKOH();

  /// Game Rules ID
  // currently, we only use one game rules ID so this is fixed
  String gameRulesIDPEMOM = constants.GameRulesConstants.pemomPushups;
  String gameRulesIDKOH = constants.GameRulesConstants.kohPushupMax60;

  /// Parameters that are used as getters
  int phoBowlsEarned = 0;
  late String nickname;
  late String backgroundVideo;
  String latestCompetitionStartDateFormatted = 'TBD';
  String sifuCopy = 'TBD';
  int playerLevel = 1;
  DateTime latestCompetitionStartDate = DateTime.now();
  DateTime latestCompetitionEndDate = DateTime.now();

  // Manage locking this screen
  bool lockScreenEnabled = false;
  String lockScreenType = 'none';


  void dispose() {
    wrapperController.close();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Streams // Getters
  /// ***********************************************************************
  /// ***********************************************************************

  /// Manage: fetch required data before loading screen UI widgets
  final wrapperController = StreamController<Map>();
  Stream<Map> get wrapperStream => wrapperController.stream;
  Sink<Map> get wrapperSink => wrapperController.sink;

  /// ***********************************************************************
  /// ***********************************************************************
  /// Getters
  /// ***********************************************************************
  /// ***********************************************************************

  String get getNickname {
    return nickname;
  }

  int get getPhoBowlsEarnedCount {
    return phoBowlsEarned;
  }

  String get getBackgroundVideo {
    return backgroundVideo;
  }

  String get getLatestCompetitionStartDateFormatted {
    return latestCompetitionStartDateFormatted;
  }

  DateTime get getLatestCompetitionStartDate {
    return latestCompetitionStartDate;
  }

  String get getSifuCopy {
    return sifuCopy;
  }

  int get getPlayerLevel {
    return playerLevel;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************

  preloadScreenSetup() async {
    /// Lock screen check
    // if locked, then pass this in the wrapper stream, so that it displays the lock screen
    Map<String, dynamic> lockScreenStatus = await GeneralService.lockScreenCheck();
    lockScreenType = lockScreenStatus['lockScreenType']; // none = nothing is locked

    // only display the full UI if this screen is NOT locked
    if (!thisScreenLocked(lockScreenType)) {
      /// get nickname
      nickname = await GeneralService.getNickname(userID);

      /// Get background videos
      // backgroundVideo = await GeneralService.getRandomBackgroundVideo(constants.GameRulesConstants.kohPushupMax60);
      backgroundVideo = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/assets_app%2Fvideos%2Fonboarding%2Fkoh_pushups%2Fmain-event-sizzle-01.mp4?alt=media&token=19155841-b8dd-4043-85e1-9d229ad487d2';

      /// Get pho bowls count
      // - if this record does not exist, then this will create one with default value of 0 pho bowls
      phoBowlsEarned = await GeneralService.getEarnedPhoBowlsFromFirebase(userID: userID);

      /// Get players level for EMOM pushup training
      // currently, level is the same as the number of pushups they can complete. ex 1 pushup per minute = level 1
      // if they have no data, then level will be 1
      Map<String, dynamic> playerRecord = await databaseServiceShared.fetchPlayerRecordsByGameRules(userID: userID, gameRulesID: gameRulesIDPEMOM);
      if (GeneralService.mapHasFieldValue(playerRecord, 'emomRepGoalsEachMinute')) {
        playerLevel = playerRecord['emomRepGoalsEachMinute'];
      } else {
        playerLevel = 1;
      }

      /// Get date of latest competition
      // and store # of pho bowls earned so far
      Map<String, dynamic> latestCompetition = await databaseServiceShared.latestCompetitionInformation(gameRulesIDKOH);
      if (latestCompetition.isNotEmpty) {
        latestCompetitionStartDate = latestCompetition['dateStart'].toDate();
        latestCompetitionEndDate = latestCompetition['dateEnd'].toDate();
        latestCompetitionStartDateFormatted = GeneralService.getFriendlyDateFormat(latestCompetitionStartDate);
      }

      /// Determine SIFU copy for main event
      // First, get the competition status based on the date
      String competitionStatus = GeneralService.competitionStatus(competitionStartDateTime: latestCompetitionStartDate.toUtc(), competitionEndDatetime: latestCompetitionEndDate.toUtc());
      if (latestCompetition.isEmpty) {
        sifuCopy = 'No competitions found. Come back when we\'re ready for you';
      } else if (competitionStatus == constants.competitionStatus.inThePast) {
        sifuCopy = 'Checkout the previous main event to find who was deemed the pushup master. \n\nWhen the next main event is announced, I\'ll let you know.  \n\nIn the meantime, keep training.';
      } else if (competitionStatus == constants.competitionStatus.announced) {
        sifuCopy = '$nickname, on $latestCompetitionStartDateFormatted, I need you to compete vs the world to test your pushup strength. \n\nThe top pushup master will win \$25 USD!';
      } else if ((competitionStatus == constants.competitionStatus.open)) {
        sifuCopy = '$nickname, today is the main event!! \n\nPlay now and test your pushup strength against the world to find out if you are the pushup master. \n\nThe top player wins \$25 USD!';
      } else {
        sifuCopy = 'Something went wrong. Come back when we\'re ready for you';
      }
    }
  }

  /// IF everything is ready, then add 'ready: true" to stream sink so the
  // UI will move away from loading to intended UI
  loadUIOnScreen() {
    Map<String, dynamic> templateWrapper = {
      'ready': true,
      'lockScreenType': lockScreenType,
    };
    wrapperSink.add(templateWrapper);
  }

  // determine which types would lock this screen
  bool thisScreenLocked(lockScreenType) {
    if (lockScreenType == constants.lockAppStatusType.updateAppVersion) {
      return true;
    }

    if (lockScreenType == constants.lockAppStatusType.maintenanceMode) {
      return true;
    }

    return false;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get background video
  Future<String?> getRandomBackgroundVideo() async {
    // Fetch the gameRules information
    Map gameRulesMap = await databaseServiceShared.gameRules(gameRulesID: constants.GameRulesConstants.kohPushupMax60);
    List defaultBackgroundVideos = gameRulesMap['backgroundVideos'];

    /// Default video to play
    // ex. display when no one has played yet)
    String? _backgroundVideo = GeneralService.getRandomItemFromThisListOfStrings(listOfStrings: defaultBackgroundVideos);

    return _backgroundVideo;
  }
}
