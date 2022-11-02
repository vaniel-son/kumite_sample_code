import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;

void setGlobalNickname(nickname) async {
  globals.nickname = nickname;
}

Future<void> setGlobalWrapperMap(String type, Map dataMap) async {
  if (type == 'gameScreen') {
    globalsMatches.gameScreenWrapperMap = dataMap;
  } else if (type == 'levels') {
    globalsMatches.levelsWrapperMap = dataMap;
  } else if (type == 'matches') {
    globalsMatches.matchesWrapperMap = dataMap;
  } else if (type == 'gameModes') {
    globalsMatches.gameModesWrapperMap = dataMap;
  } else if (type == 'viewReplay') {
    globalsMatches.viewReplayWrapperMap = dataMap;
  } else if (type == 'judgeList') {
    globalsMatches.judgeListWrapperMap = dataMap;
  }

}

/// Determine the opponents video
// it processes a map of 0,1 or 2 items
// and returns the video that does not belong to the userID passed in
String getOpponentVideo(Map playerVideos, String userID) {
  String videoURL = '';

  // fetch video that does not belong to this user
  playerVideos.entries.forEach((e) {
    if (e.key != userID) {
      videoURL = e.value;
    }
  });

  return videoURL;
}

/// Determine the opponent's user ID from matches document
// it processes an array of 2 players
// and returns the userID that is not belonging to the userID passed in
String getOpponentUserID(matchesMap, userID) {

  String opponentUserID;
  if (matchesMap['players'][0] == userID) {
    opponentUserID = matchesMap['players'][1];
  } else {
    opponentUserID = matchesMap['players'][0];
  }

  return opponentUserID;
}