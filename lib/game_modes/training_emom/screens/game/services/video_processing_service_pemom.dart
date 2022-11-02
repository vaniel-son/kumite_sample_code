import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/constants.dart' as constants;

class VideoProcessingServicePEMOM {

  //Class Variables
  final videoName = createUUID();
  final gameMode = constants.GameRulesConstants.trainingPushupEmomTitle;
  final CameraController cameraController;
  final String gameID;
  final String playerOneUserID;
  final Sink<String> videoURLSink;

  //Stream to check for uploadVideoURL
  late Stream<QuerySnapshot> _uploadVideoURLStream;
  Stream<QuerySnapshot> get uploadVideoURLStream => _uploadVideoURLStream;

  // Initialize DB object with methods to call DB
  DatabaseServices databaseServicesShared = DatabaseServices();

  /// Constructor
  VideoProcessingServicePEMOM({
    required this.videoURLSink,
    required this.gameID,
    required this.playerOneUserID,
    required this.cameraController
  });

  /// ***********************************************************************
  /// ***********************************************************************
  /// Functions to:
  /// - Stop video recording and generate video file for upload
  /// - Create video file for local playback
  /// - Create new record for video in firebase collection
  /// ***********************************************************************
  /// ***********************************************************************


  Future <XFile> generateVideoUploadFile() async {
    final XFile videoFile = await cameraController.stopVideoRecording();
    return videoFile;
  }


  Future <File> generateVideoPlaybackFile(XFile videoFile) async {

    /// Record Video using camera package, convert to File format to save to Firebase
    final File localSelfieVideoToPlay = File(videoFile.path);

    return localSelfieVideoToPlay;
  }

  Future <void> saveVideoRecord(XFile videoFile) async {

    /// Save video file metadata to cloud firestore before upload (Van asks: Why?)
    // this triggers a cloud function
    // that will save an 'uploadUrl' to videos collection
    await VideoDatabaseService.createNewVideoCollectionRecord(videoName, videoFile.path, gameID, playerOneUserID, gameMode, 'n/a');
  }

  /// ***********************************************************************
  /// ***********************************************************************
  ///  Video upload function.
  ///  - Waits for upload URL
  ///  - Initiates background upload
  ///  - Generates downloadURL (videoURL)
  ///  - Writes downloadURL (videoURL) to videos collection and game collection
  /// ***********************************************************************
  /// ***********************************************************************


  Future <void> videoUpload(XFile videoFile) async {

    bool didFileUpload = false;

    _uploadVideoURLStream = databaseServicesShared.fetchVideosByID(videoName);
    var subscription;
    subscription = _uploadVideoURLStream.listen((event) async {

      if (event.docs.isNotEmpty) {

        Map videosMap = event.docs.first.data() as Map<dynamic, dynamic>;

        // If the videos collection has an uploadURL
        // then move forward with the saving process
        if (videosMap['uploadUrl'] != null) {
          // Start uploading the video with background flutter upload package.
          // when the video is done uploading

          if(didFileUpload == false) {
            await databaseServicesShared.uploadVideo(videoName, videoFile, gameMode, playerOneUserID);
            didFileUpload = true;
          }
          printBig('Video Upload Method', 'This is after uploadVideo runs');


          if(videosMap['uploadComplete'] == true){
            await databaseServicesShared.fetchVideoURL(gameMode, playerOneUserID);
          }
          // Get the video url from firebase cloud storage
          //await databaseServicesShared.getVideoURL(gameMode, playerOneUserID);

          // Saves the videoURL to 'videos' collection and set 'finishedProcessing' to true
          //await databaseServicesShared.saveVideoURLtoVideoCollection(videoName, videoURL);

          // Share videoURL with the game bloc / controller
          // so it can update the game document with this video URL
          // note: the game bloc will wait 300 seconds before skipping this and moving forward
          // note: essentially, we will now 100% wait until the video is uploaded before letting the user proceed

          if (videosMap['videoUrl'] != null) {
            // Share upload URL with bloc so it can save it to the game object
            //gameBloc.setVideoURL = videosMap['videoUrl'];
            videoURLSink.add(videosMap['videoUrl']);

            printBig('Video Upload Method', 'This is when videosMap[videoURL] is not null');


            // Inform the gameBloc to move forward from displaying the message "saving..."
            //gameBloc.updateVideoURLAvailable = true;

            // Stop listening to this stream so that it exits this loop
            subscription.cancel();
          }
        }
      }
    });
  }


}
