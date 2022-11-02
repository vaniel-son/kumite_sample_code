import 'package:dojo_app/game_modes/training_emom/models/training_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/models/host_messages_model.dart';
import 'package:dojo_app/game_modes/training_emom/models/game_model_pemom.dart';

/// Stores the player's status from the latest and previous competition
/// - they might not have played at all
/// - see more status types in constantsKOH
class TrainingLandingContentModel {
  TrainingLandingContentModel({
    required this.playerGameTrainingStatus,
    required this.gameInfo,
    required this.hostCardMessages,
    required this.widgetVisibilityConfig,
    required this.playerRoundOutcomes,
    required this.playerLevel,
  });

  String playerGameTrainingStatus;
  GameModelPEMOM gameInfo;
  HostCardMessagesModel hostCardMessages;
  TrainingScreenWidgetVisibilityModel widgetVisibilityConfig; // create one custom to this screen
  List playerRoundOutcomes;
  int playerLevel;

  Map<String, dynamic> toMap(){
    return {
      'playerGameCompetitionStatus': playerGameTrainingStatus,
      'gameInfo': gameInfo,
      'hostCardMessages': hostCardMessages,
      'widgetVisibilityConfig': widgetVisibilityConfig,
      'playerRoundOutcomes': playerRoundOutcomes,
    };
  }

}