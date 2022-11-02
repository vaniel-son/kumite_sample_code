import 'package:dojo_app/game_modes/king_of_the_hill/models/competition_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/game_model_king_of_hill.dart';
import 'package:dojo_app/models/host_messages_model.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/main_event_landing/models/main_event_landing_screen_widget_visibility_config_model_koh.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/models/leaderboards_all_model_koh.dart';

/// Stores the player's status from the latest and previous competition
/// - they might not have played at all
/// - see more status types in constantsKOH
class MainEventLandingContentModel {
  MainEventLandingContentModel({
    required this.playerGameCompetitionStatus,
    required this.competitionID,
    required this.competitionInfo,
    required this.gameInfo,
    required this.leaderboardAndPlayerRank,
    required this.backgroundVideo,
    required this.hostCardMessages,
    required this.widgetVisibilityConfig,
  });

  String playerGameCompetitionStatus;
  String competitionID;
  CompetitionModelKOH competitionInfo;
  GameModelKOH gameInfo;
  LeaderboardAndPlayerRankModelKOH leaderboardAndPlayerRank;
  String? backgroundVideo;
  HostCardMessagesModel hostCardMessages;
  MainEventLandingWidgetVisibilityModel widgetVisibilityConfig;

  Map<String, dynamic> toMap(){
    return {
      'playerGameCompetitionStatus': playerGameCompetitionStatus,
      'competitionID': competitionID,
      'competitionInfo': competitionInfo,
      'gameInfo': gameInfo,
      'leaderboardAndPlayerRank': leaderboardAndPlayerRank,
      'backgroundVideo': backgroundVideo,
      'widgetVisibilityConfig': widgetVisibilityConfig,
    };
  }

}