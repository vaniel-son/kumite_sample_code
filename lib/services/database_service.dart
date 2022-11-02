import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/models/video_model.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dojo_app/services/background_upload_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dojo_app/globals.dart' as globals;

class DatabaseServices {
  /// ***********************************************************************
  /// ***********************************************************************
  /// User
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain nickname based on userID
  Future<String> fetchNickname({userID}) async {
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

  /// Obtain user info based on userID
  Future<Map> fetchUserInfo({userID}) async {
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('User_ID', isEqualTo: userID)
        .get();

    if (userQuery.docs.isEmpty) {
      return {};
    } else {
      var result = userQuery.docs.first.data();
      return result;
    }
  }

  ///Create User record in database.
  Future<void> addUser(uid, nickname) async {
    /// collection reference to query users table
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

    // Call the user's CollectionReference to add a new user
    return await userCollection
        .doc(uid)
        .set({
      'User_ID': uid, // John Doe
      'Nickname': nickname, // Stokes and Sons
      'Date_Created': DateTime.now(),
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Stream<QuerySnapshot> fetchAllUsers() {
    final Stream<QuerySnapshot> dataStream = FirebaseFirestore.instance
        .collection('users')
        .snapshots();

    var result;
    result = dataStream;
    return result;
  }

  deleteUserAccount({required String userID}) async {
    print('3');
    // Remove from users collection
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
    await userCollection.doc(userID).delete();

    // Remove from Auth table
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.currentUser!.delete();
  }

  updateNickname({required String userID, required nickname}) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(userID).update({'Nickname': nickname});
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Game Rules, Competition Info
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get SNAPSHOT: details for a single match
  Future<Map<String, dynamic>> gameRules({required String gameRulesID}) async {
    final gameRulesQuery = await FirebaseFirestore.instance
        .collection('gameRules')
        .where('id', isEqualTo: gameRulesID)
        .get();

    Map<String, dynamic> result;
    if (gameRulesQuery.docs.isNotEmpty) {
      result = gameRulesQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }
  
  /// Get latest competition 
  Future<Map<String, dynamic>> latestCompetitionInformation(String gameRulesID) async {
    final competitionQuery = await FirebaseFirestore.instance
        .collection('competitions')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .orderBy('dateStart', descending: true)
        .limit(1)
        .get();

    Map<String, dynamic> result;
    if (competitionQuery.docs.isNotEmpty) {
      result = competitionQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// Update a competition status
  Future<void> updateCompetitionStatus(String competitionID, String competitionStatus) async {
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('competitions')
        .doc(competitionID);

    updateGame.update({"competitionStatus": competitionStatus, "dateUpdated": DateTime.now()});
  }

  /// Get competition info
  Future<Map<String, dynamic>> fetchCompetitionInformation(String competitionID) async {
    final competitionQuery = await FirebaseFirestore.instance
        .collection('competitions')
        .where('id', isEqualTo: competitionID)
        //.orderBy('dateStart', descending: true)
        .limit(1)
        .get();

    Map<String, dynamic> result;
    if (competitionQuery.docs.isNotEmpty) {
      result = competitionQuery.docs.first.data();
    } else {
      result = {};
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Records
  /// ***********************************************************************
  /// ***********************************************************************

  /// Obtain scores for 60 second match
  Future<Map<String, dynamic>> fetchPlayerRecordsByGameRules({required String userID, required String gameRulesID}) async {
    Map<String, dynamic> result = {};

    final playerRecordsQuery = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('byGameRules')
        .where('gameRulesID', isEqualTo: gameRulesID)
        .get();

    if (playerRecordsQuery.docs.isNotEmpty) {
      result = playerRecordsQuery.docs.first.data();
    }

    return result;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Inventory
  /// ***********************************************************************
  /// ***********************************************************************

  /// Create new player record for resource inventory
  Future<Map<String, dynamic>> createPlayerInventoryRecord(String userID, String nickname) async {
    /// Temp migration (this code will go away once we are fully migrated)
    // players have their phoBowls stored in a legacy location of player records
    // fetch that data (if it exists) and set that as their pho bowl count
    // if the data doesn't exist, then they will start with 0 pho bowls
    int existingPhoBowlsOwned = await fetchPhoBowlsFromPlayerRecords(userID);

    await FirebaseFirestore.instance.collection('playerInventory').doc(userID).set({
      'phoBowls': existingPhoBowlsOwned,
      'userID': userID,
      'dateUpdated': FieldValue.serverTimestamp(),
      'nickname': nickname,
    });

    return {
      'phoBowls': existingPhoBowlsOwned,
      'userID': userID,
      'dateUpdated': FieldValue.serverTimestamp(),
      'nickname': nickname,
    };
  }

  /// Obtain player record inventory
  Future<Map<String, dynamic>> fetchPlayerInventoryResources(userID) async {
    final inventoryReference = await FirebaseFirestore.instance
        .collection('playerInventory')
        .doc(userID)
        .get();

    Map<String, dynamic> playerInventory = {};

    if (inventoryReference.exists) {
      playerInventory = inventoryReference.data()!; // store data as map and return this
    } else {
      // document does not exist so create it
      String nickname = await GeneralService.getNickname(userID);
      playerInventory = await createPlayerInventoryRecord(userID, nickname);
    }

    return playerInventory;
  }

  /// Temporary: Obtain player record pho bowls from playerRecords
  // so we can transfer them to the new way of saving them to playerInventory
  Future<int> fetchPhoBowlsFromPlayerRecords(userID) async {
    final inventoryReference = await FirebaseFirestore.instance
        .collection('playerRecords')
        .doc(userID)
        .collection('inventory')
        .doc('resources')
        .get();

    Map<String, dynamic> playerInventory = {};
    int phoBowls = 0;

    if (inventoryReference.exists) {
      playerInventory = inventoryReference.data()!; // store data as map and return this
      printBig('playerInventory', '$playerInventory');
      if (playerInventory['phoBowls'] != null) {
        phoBowls = playerInventory['phoBowls'];
      }
    }

    return phoBowls;
  }

  /// Increment or deduct pho bowls from player's inventory
  Future<void> updateResourcePhoBowl(String userID, int itemCount) async {
    DocumentReference updateGame = FirebaseFirestore.instance
        .collection('playerInventory')
        .doc(userID);

    updateGame.set({"phoBowls": FieldValue.increment(itemCount), "dateUpdated": FieldValue.serverTimestamp(),}, SetOptions(merge: true));
  }

  /// ****

  Future<QuerySnapshot<Object?>> getAllPhoBowlRecordsFromFirebase() async {
    final phoBowlStream = FirebaseFirestore.instance
        .collection('playerInventory')
        .where('phoBowls', isGreaterThan: 0)
        .orderBy('phoBowls', descending: true)
        .get();

    return phoBowlStream;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc
  /// ***********************************************************************
  /// ***********************************************************************

  void addDiscordMessage(Map<String, dynamic> discordMessageMap) async {
    /// save the level to the user's collection
    await FirebaseFirestore.instance
        .collection('discordMessages')
        .doc(discordMessageMap['id'])
        .set(discordMessageMap);
  }

  /// Determine the lock type of a screen that has been enabled
  // these should usually return as false
  static Future<Map<String, dynamic>> getLockScreenStatus() async {
    Map<String, dynamic> lockScreenStatus = {}; // value to return

    // check if we are using dev or prod, so we know which document to fetch
    String appName = await GeneralService.getPackageInformation('appName'); // get name of app from this code base
    String documentName;
    if (appName.contains('Dev') || appName.contains('dev')) {
      documentName = 'dojoAppDev';
    } else {
      documentName = 'dojoAppProd';
    }

    final lockScreenReference = await FirebaseFirestore.instance
        .collection('lockAppStatus')
        .doc(documentName)
        .get();

    // store data as map to return
    if (lockScreenReference.exists) {
      lockScreenStatus = lockScreenReference.data()!;
    }
    return lockScreenStatus;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Crypto Wallet database methods
  /// ***********************************************************************
  /// ***********************************************************************

  ///Update wallet address in user table.
  Future <void> updateEthereumAddress(String userID, String ethAddress) async {

    final docReference = FirebaseFirestore.instance.collection('users').doc(userID);

    await docReference.update({"ethAddress": ethAddress}).then(
            (value) => print("DocumentSnapshot successfully updated!"),
        onError: (e) => print("Error updating document $e"));

  }

  ///Retrieve existing wallet address from user table.
  Future <String> retrieveWalletAddress(String userID) async {

    Map<String, dynamic> resultMap = {};
    String result = '';

    final docRef = await FirebaseFirestore.instance.collection('users').doc(userID).get();

    if (docRef.data()!.containsKey('ethAddress')) {
      resultMap = docRef.data()!;
      result = resultMap['ethAddress'];
      return result;
    } else {
      return ''; // record does not exist so create it
    }
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// Videos: Get Data
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get videos
  Stream<QuerySnapshot> fetchVideosByID(String videoName) {
    return FirebaseFirestore.instance
        .collection('videos')
        .where('videoName', isEqualTo: videoName)
        .snapshots();
  }

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

  Future<void> uploadVideo(videoName, videoFile, gameMode, playerOneUserID) async {
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

    // Get the video url from firebase cloud storage
    // await getVideoURL(gameMode, playerOneUserID);
  }

  /// get video url from firebase storage
  Future<String> fetchVideoURL(gameMode, userID) async {
    String videoURL = 'not available yet';

    /// Reference video collection document
    final query = await FirebaseFirestore.instance.collection('videos')
        .where('finishedProcessing',isEqualTo: false)
        .where('gameMode',isEqualTo: gameMode)
        .where('players', arrayContains: userID)
        .where('uploadComplete',isEqualTo: true)
        .get();

    if (query.docs.isNotEmpty) {
      // there is only one document that should return so store this as a map
      var doc = query.docs.first.data();

      // Get the video url from firebase cloud storage
      videoURL = await FirebaseStorage.instance.ref('user_videos/${doc['videoName']}.mp4').getDownloadURL();
      printBig('DownloadURL', videoURL);

      /// Identify and store required data to save a game
      String videoName = doc['videoName'];

      /// Saves the videoURL to 'videos' collection and set 'finishedProcessing' to true
      /// Todo: Figure out why return videoURL doesn't wait for this if statement to process.
      await saveVideoURLtoVideoCollection(videoName, videoURL);
    }

    return videoURL;
  }

} // end database service class

class VideoDatabaseService {

  ///Records upload time.
  static saveVideoUploadStartTime(VideoModel video) async {
    await FirebaseFirestore.instance
        .collection('videos')
        .doc(video.videoName)
        .set({
      'uploadedAt': video.uploadedAt,
      'videoName': video.videoName,
    },SetOptions(merge: true));
  }

  /// After downloadURL is generated this method writes to that URL to the relevant document
/*  static saveDownloadURL(String? videoName, String downloadUrl) async {
    var complete1 = await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'videoUrl': downloadUrl,
      'finishedProcessing': true,
    }, SetOptions(merge: true));
  }*/

  /// Creates the initial record for the video in the video collection, pre-upload.
  static createNewVideoCollectionRecord(String videoName, String rawVideoPath, String gameID, String userID, String gameMode, String groupID) async {
    await FirebaseFirestore.instance.collection('videos').doc(videoName).set({
      'finishedProcessing': false,
      "datetimeUrlUploadCreation": DateTime.now(),
      'videoName': videoName,
      'rawVideoPath': rawVideoPath,
      'userID': userID,
      'gameID': gameID,
      'gameMode': gameMode,
      'groupID': groupID,
      "players": [userID],
    });
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Generate Device Tokens for Messaging after video upload
  /// ***********************************************************************
  /// ***********************************************************************

  /// Methods to create and save user tokens needed for messaging
  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<String> generateUserToken() async {
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    return token;

  }
}