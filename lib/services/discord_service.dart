import 'package:dojo_app/models/discord_message_model.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/constants.dart' as constants;

/// Game Service:
// handles any functions that are used by the game screen or view replay screen

class DiscordService {
  // Initialize DB object with methods to call DB
  DatabaseServices databaseServices = DatabaseServices();

  /// Constructor
  DiscordService() {
    // do something
  }

  // create object
  void createBasicDiscordMessageObject({required String message, required String originUserID, required messageType}){
    // create object
    DiscordMessage discordMessage = DiscordMessage(
      originUserID: originUserID,
      discordChannelID: constants.discordChannel,
      dateTimeSend: DateTime.now(),
      message: message,
      messageType: messageType,
    );

    // save to db
    saveDiscordMessage(discordMessage);

  }

  // convert object to map and call databaseService to save
  void saveDiscordMessage(DiscordMessage payload){
    // convert object into map
    Map<String, dynamic> discordMessageMap = {
      'originUserID': payload.originUserID,
      'id': payload.id,
      'dateCreated': DateTime.now(),
      'dateTimeSend': payload.dateTimeSend,
      'message': payload.message,
      'messageType': payload.messageType,
    };

    databaseServices.addDiscordMessage(discordMessageMap);
  }

  // build message
  void personalRecordAchieved({required int reps, required String userID, required String nickname}) {
    // create discord message
    String discordMessage = '$nickname achieved a new personal record of $reps pushups';
    String originUserID = userID;
    String messageType = 'simple';
    createBasicDiscordMessageObject(message: discordMessage, originUserID: originUserID, messageType: messageType);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// TBD
  /// ***********************************************************************
  /// ***********************************************************************


}
