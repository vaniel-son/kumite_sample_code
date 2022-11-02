import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/game_modes/levels/models/game_model2.dart';
import 'package:dojo_app/game_modes/levels/models/game_model2_extras.dart';
import 'package:dojo_app/models/video_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dojo_app/services/background_upload_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart' as helperMatches;
import 'package:dojo_app/globals.dart' as globals;

class DatabaseServicesLevels {
  /// ***********************************************************************
  /// ***********************************************************************
  /// User
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain nickname based on userID
  Future<String> fetchNicknameWhenDefault({userID}) async {
    // We use two generic nicknames when the user does not have one
    // 1. globals.nickname starts with the nickname 'player', so anytime we encounter that, we know globals has never been updated
    // 2. after an account is initially created, we set nickname = Default
    // which during sign up uses to infer that the user has no nickname yet and should route the user to the nickname add screen
    if (globals.nickname != 'Default' || globals.nickname != 'Player') {
      final nicknameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('User_ID', isEqualTo: userID)
          .get();

      if (nicknameQuery.docs.isEmpty) {
        return 'Default';
      } else {
        var result = nicknameQuery.docs.first.data();
        return result['Nickname'];
      }
    }

    return globals.nickname;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get all levels for a specific levelGroup
  Stream<QuerySnapshot> fetchLevelsByLevelGroup(String levelGroupID, String userID) {
    return FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID) // userID as collection name
        .orderBy('level', descending: false)
        .snapshots();
  }

  /// Obtain opponent details of a specific level
  // used by gameMode levels only
  Future<QuerySnapshot<Map<String, dynamic>>> fetchSingleGameDetails({gameMode, id, groupID, userID}) async {
    final gameQuery = await FirebaseFirestore.instance
        .collection('$gameMode')
        .doc(groupID)
        .collection(userID)
        .where('id', isEqualTo: id)
        .get();

    return gameQuery;
  }

  /// After the user wins a level, get the next levelID to update so that it's unlocked
  Future<String> fetchNextLevelID({required String levelGroupID, required String userID, required int level}) async {
    final nextLevelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('level', isGreaterThanOrEqualTo: level)
        .orderBy('level')
        .limit(2)
        .get();

    /// Determine if 2 documents come back
    // the 2nd document is the next active level
    // if the length is 1, then there is no next level available yet
    dynamic result2 = nextLevelQuery.docs.length;

    // set result to be the last document from the collection
    dynamic result = nextLevelQuery.docs.last.data();
    String newLevelID = result['id'];
    return newLevelID;
  }

  /// Obtain video background for level page
  Future<String> fetchLevelSelectBackgroundVideo({levelGroupID, userID}) async {
    String videoURL = '';

    final levelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .get();

    /// return the video of any active level
    // or if they beat all the levels (no docs returned above, then return a celebration video
    if (levelQuery.docs.isEmpty) {
      Map levelDetailMap = await fetchLevelDetails(levelGroupID: levelGroupID);
      var defaultVideo = levelDetailMap['allLevelsCompletedVideo'];
      return defaultVideo;
    } else {
      var result = levelQuery.docs.first.data();

      // find video that isn't their own
      Map playerVideos = result['playerVideos'];
      videoURL = helperMatches.getOpponentVideo(playerVideos, userID);

      return videoURL;
    }
  }

  /// Obtain video background for level page
  Future<String> fetchGameModeBackgroundVideo({levelGroupID, userID}) async {
    String videoURL = '';

    final levelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .get();

    /// return the video of any active level
    // or if they beat all the levels (no docs returned above, then return a celebration video
    if (levelQuery.docs.isEmpty) {
      Map levelDetailMap = await fetchLevelDetails(levelGroupID: levelGroupID);
      var defaultVideo = levelDetailMap['allLevelsCompletedVideo'];
      return defaultVideo;
    } else {
      var result = levelQuery.docs.first.data();

      // find video that isn't their own
      Map playerVideos = result['playerVideos'];
      videoURL = helperMatches.getOpponentVideo(playerVideos, userID);

      return videoURL;
    }
  }

  /// Obtain level details
  Future<Map> fetchLevelDetails({levelGroupID}) async {
    final levelDetailsQuery = await FirebaseFirestore.instance
        .collection('levels')
        .where('groupID', isEqualTo: levelGroupID)
        .get();

    var result = levelDetailsQuery.docs.first.data();
    return result;
  }

  /// query database and see if they have any levels associated with their account
  Future<bool> hasLevelsForThisLevelGroupCheck({levelGroupID, userID}) async {
    final userCollection = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .limit(1)
        .get();

    // returns true if they do not have levels associated their their account yet
    // returns false if they have levels for this levelGroup
    return (userCollection.docs.isEmpty);
  }

  /// query database and see if they completed all levels for a specific levelGroup
  Future<bool> hasUserCompletedAllLevels({levelGroupID, userID}) async {
    final userCollection = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    // returns true if all levels are completed
    // returns false if they have at least one level that is active
    return (userCollection.docs.isEmpty);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Levels: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get data from levelTemplates and save to a user's levels collection
  copyLevelsToUserAccount({levelGroupID, userID, nickname}) async {
    final retrieveLevelTemplates = await FirebaseFirestore.instance
        .collection('levelTemplates')
        .doc(levelGroupID)
        .collection('levelTemplates.templates')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) async {

        /// Generate a unique id for the level
        String levelID = createUUID();

        /// Iterate through each document field and create a map
        // first convert document into a map
        Map<String, dynamic> levelTemplateData = doc.data() as Map<String, dynamic>;

        /// dynamically populate the levelData map with results from Firebase
        Map<String, dynamic> levelData = {};
        for (String key in levelTemplateData.keys){
          levelData[key] = levelTemplateData[key];
        }

        /// Add additional data that is not part of the level template document
        levelData["dateCreated"] = DateTime.now();
        levelData["id"] = levelID;
        levelData["players"].add(userID);
        levelData["playerNicknames"][userID] = nickname;

        /// Obtain opponentID
        String playerTwoUserID = helperMatches.getOpponentUserID(levelData, userID);

        /// Add player sub scores
        // Create map for playerSubScores
        Map<String, int> playerOneSubScores = {
          "reps": 0,
          "form": 0,
          "sleep": 0,
          "nutrition": 0,
        };

        Map<String, int> playerTwoSubScores = {
          "reps": levelData['levelGoal'],
          "form": 0,
          "sleep": 0,
          "nutrition": 0,
        };

        levelData["playerSubScores"] = {
          userID: playerOneSubScores,
          playerTwoUserID: playerTwoSubScores,
        };

        /// save the level to the user's collection
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(levelGroupID)
            .collection(userID)
            .doc(levelID)
            .set(levelData);
      });
    });
  } // end addLevelsToUserAccount

  /// update levels > level document... if they won
  void updateActiveLevelForAWinner({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    String gameStatus = gameInfo.gameStatus;
    Map playerScores = gameInfo.playerScores; // final score
    Map playerVideos = gameInfo.playerVideos; // final video
    Map playerGameOutcomes = gameInfo.playerGameOutcomes;

    DocumentReference updateExistingLevel = FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .doc(levelID);

    /// IF user won, then update active level
    updateExistingLevel.update({
      "playerScores": playerScores,
      "playerVideos": playerVideos,
      "playerGameOutcomes": playerGameOutcomes,
      "gameStatus": gameStatus,
      "dateUpdated": DateTime.now(),
      "status": 'completed',
    }); // end
  }

  void updateLevelWithGameData({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from gameInfo
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    int score = gameInfo.playerScores[userID];
    String gameID = gameInfo.id;

    /// obtain active level collection and locate the specific document
    final userLevelQuery = await FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .where('id', isEqualTo: levelID)
        .get();

    // there should only be one result so set result to this document
    var result = userLevelQuery.docs.first.data();

    /// Declare empty maps
    Map scoresMap = {}; // stores all scores recorded for this level
    //Map videosMap = {}; // stores all videos recorded for this level

    /// handle case where userLevelQuery doesn't have this field created yet
    // (ex. map won't exist when a user plays a levelGroup's level for the first time)
    if (result.containsKey('gameScores')) {
      // field exists so obtain their existing values so we can append to it
      scoresMap = result['gameScores'] as Map;
    }

    /*if (result.containsKey('gameVideos')) {
      // field exists so obtain their existing values so we can append to it
      videosMap = result['gameVideos'] as Map;
    }*/

    /// Update map with additional values
    scoresMap[gameID] = score;
    //videosMap[gameID] = currentPlayerVideoURL;

    /// Update level document with these values
    // create document reference
    DocumentReference levelReference = FirebaseFirestore.instance
        .collection('levels')
        .doc(levelGroupID)
        .collection(userID)
        .doc(levelID);

    // update document
    await levelReference.update({
      "gameScores": scoresMap,
      //"gameVideos": videosMap,
      'dateUpdated': DateTime.now(),
    }); // end
  }

  /// locate the next level document that requires updating
  // the following returns the next levelID
  // if there no next level, it will return the same exact ID you pass it
  void updateNextLevelForAWinner({required GameModel2 gameInfo, required GameModel2Extras gameInfoExtras}) async {
    // Extract required data from GameInfo
    String levelGroupID = gameInfo.groupID;
    String levelID = gameInfo.id;
    String userID = gameInfoExtras.playerOneUserID;
    int level = gameInfo.level;

    dynamic nextLevelID;
    nextLevelID = await fetchNextLevelID(
        levelGroupID: levelGroupID,
        userID: userID,
        level: level);

    /// Only update if a next level exists
    // if the levelID passed in matches the levelID returned from nextLevelID, then no next level exists
    if (levelID != nextLevelID) {
      /// Set this next level's status as active
      DocumentReference updateExistingGame2 = FirebaseFirestore.instance
          .collection('levels')
          .doc(levelGroupID)
          .collection(userID)
          .doc(nextLevelID);

      /// IF user won, then update next level
      await updateExistingGame2.update({
        "dateUpdated": DateTime.now(),
        "status": 'active',
      }); // end
    } else {
      printBig('do not update, existing levelID', '$nextLevelID');
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Matches: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// Matches - Judging: Save Data
  /// ***********************************************************************

  /// ***********************************************************************
  /// Matches - Video, Food: Save Data
  /// ***********************************************************************

  /// Update match or level collection with player videos
  Future<void> updateMatchWithVideoURLFlat(gameMode, groupID, id, userID, videoOwnerUserID, videoURL) async {
    /// Fetch data
    final gameQuery = await FirebaseFirestore.instance
        .collection('matchesAll2')
        .where('id', isEqualTo: id)
        .get();

    if (gameQuery.docs.isNotEmpty) {
      var result = gameQuery.docs.first.data();
      Map playerVideoMap = result['playerVideos'];

      /// Update Map with this user's video
      playerVideoMap[videoOwnerUserID] = videoURL;

      /// Update userID's document
      DocumentReference updateMatch = FirebaseFirestore.instance
          .collection('matchesAll2')
          .doc(id);

      updateMatch.update({
        "playerVideos": playerVideoMap,
      }); // end
    }
  }

  Future<void> saveFoodImageURLtoMatch({required Map picMap, required String groupID, required String userID, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(groupID)
        .collection(userID)
        .doc(matchID)
        .update({
          'playerFoodPics':FieldValue.arrayUnion([picMap]),
          'dateUpdated': DateTime.now(),
          'dates': dates,
    });
  }

  Future<void> saveFoodImageURLtoMatchFlat({required Map picMap, required String matchID, required Map dates}) async {
    await FirebaseFirestore.instance
        .collection('matchesAll')
        .doc(matchID)
        .update({
      'playerFoodPics':FieldValue.arrayUnion([picMap]),
      'dateUpdated': DateTime.now(),
      'dates': dates,});
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Judging: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Other
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Save Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// After downloadURL is generated this method writes to that URL to the relevant document
  Future<void> saveVideoURLtoVideoCollection(String? videoName, String downloadUrl) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }

  Future<void> uploadVideo(videoName, videoFile) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).get().then((DocumentSnapshot ds) {
      if (ds.exists) {
        print('Document exists in the database');
        final data = ds.data();
        final uploadUrL = (data as dynamic)['uploadUrl'];
        print(uploadUrL);
        var video = VideoModel(uploadUrl: uploadUrL);
        uploadFileBackground(videoName, videoFile.path, video.uploadUrl);
      } else {
        print('Document does not exist');
      }
    });
  }

  Future<void> fetchVideoURLandUpdateMatches(gameMode, userID,) async {
    /// Fetch video collection documents for this user, or their opponent, who have their video background uploaded
    /// but not saved to both players' match or level document
    final query = await FirebaseFirestore.instance.collection('videos')
        .where('finishedProcessing',isEqualTo: false)
        .where('gameMode',isEqualTo: gameMode)
        .where('players', arrayContains: userID)
        .where('uploadComplete',isEqualTo: true).get();

    if (query.docs.isNotEmpty) {
      var doc = query.docs.first.data();

      String videoURL = await FirebaseStorage.instance.ref('user_videos/${doc['videoName']}.mp4').getDownloadURL();
      String gameMode = doc['gameMode'];
      String groupID = doc['groupID'];
      String gameID = doc['gameID'];
      String userID = doc['userID'];
      String videoName = doc['videoName'];

      /// For this user: Saves videoURL to matches collection
      //await updateLevelOrMatchWithVideoURL(gameMode, groupID, gameID, userID, userID, videoURL);
      await updateMatchWithVideoURLFlat(gameMode, groupID, gameID, userID, userID, videoURL);

      /// Saves the videoURL to videos collection and set finishedProcessing to true
      await saveVideoURLtoVideoCollection(videoName, videoURL);
    }
  }
} // end database service class