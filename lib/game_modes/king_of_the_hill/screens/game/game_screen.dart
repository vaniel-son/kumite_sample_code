import 'dart:convert';
import 'package:dojo_app/game_modes/king_of_the_hill/screens/game/service/video_processing_service_koh.dart';
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/loading_screen_static.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/style/colors.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/close_icon_button.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/widgets/recording_icon.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'game_bloc.dart';
import 'package:wakelock/wakelock.dart';
import 'package:dojo_app/services/pose_estimation_services/motion_data_service.dart';
import 'package:dojo_app/services/pose_estimation_services/pose_painter_service.dart';
import 'package:http/http.dart' as http;
import 'package:dojo_app/game_modes/king_of_the_hill/constants_koh.dart' as constantsKOH;

/// ***************************************************************
///
/// Game Page and Game Bloc work together
/// This job of this page includes...
/// - setting up game bloc which contains most of the logic
/// - setup and manage video player
/// - setup and manage camera recorder
/// - display UI
///
/// To Follow the logic of game_screen and gameBloc
/// - follow gameBloc
/// - then follow game_screen code
///
/// ***************************************************************

class GameScreen extends StatefulWidget {
  /// Game Screen Constructor
  GameScreen(
      {required this.gameMap, required this.gameRulesID, required this.userID, required this.competitionID}) {
    //
  }
  final Map gameMap;
  final String gameRulesID;
  final String userID;
  final String competitionID;

  // Front facing camera
  // TODO: move setting globals.camera from main.dart to here or to gameScreenWrapper
  final camera = globals.cameras[1];

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  /// _GameScreenState constructor
  _GameScreenState() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  /// Get passed in parameters
  late Map gameMap = widget.gameMap;
  late String gameRulesID = widget.gameRulesID;
  late String competitionID = widget.competitionID;
  late String playerOneUserID = widget.userID;
  late String gameMode = 'king of the hill';

  /// Initialize database object for calls to the DB
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();

  /// Initialize main game controller
  late GameBloc gameBloc;

  ///Initialize VideoService
  late VideoProcessingServiceKOH videoProcessingServiceKOH;

  /// Initialize List to contain which widgets to display
  // this is controlled and populated by the GameBloc
  List<Widget> myList = [];

  /// ***********************************************************************
  /// ***********************************************************************
  /// Initialization: video stuff
  /// ***********************************************************************
  /// ***********************************************************************

  /// Initialize Video Player
  late VideoPlayerController videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  String selfieVideoToPlay = '';
  // String pushupTutorialVideo = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-9812e.appspot.com/o/assets_app%2Fvideos%2Ftutorials%2FTutorial-Traditional-Pushup-Van-1.mp4?alt=media&token=dae654ce-fc01-4fdf-aeab-89ce7bc4d4db';  // temporary pushup tutorial video

  /// Initialize Camera
  late CameraController cameraController;
  late Future<void> _initializeControllerFuture;

  /// ML parameters
  bool isBusy = false;
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector();
  MotionData motionData = new MotionData();
  CustomPaint? customPaint;

  /// Web3 parameters
  String ipfsVideoUrl = '';

  /// ***********************************************************************
  /// ***********************************************************************
  /// Init and dispose methods
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();

    /// Prevent the screen from turning off
    Wakelock.enable();

   /// Begin setting up game screen and game bloc
   setup();
  }

  /// When view is closed, dispose of gameBloc
  // to prevent performance issues
  @override
  void dispose() {
    printBig('Game Screen Dispose Called', 'true');
    gameBloc.dispose();

    /// Wait 1 second before closing the cameraController or VideoPlayer
    // otherwise, the app returns an error because it tries to close this when it's in use
    Timer(Duration(seconds: 1), () {
      cameraController.dispose();
    });

    /// Screen will turn off when not in use for x seconds
    Wakelock.disable();

    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup method
  /// ***********************************************************************
  /// ***********************************************************************

  void setup() async {
    /// Initialize Camera (for recording)
    cameraController = CameraController(
      widget.camera, // Get a specific camera from the list of available cameras.
      ResolutionPreset.low, // Define the resolution to use.
    );

    /// Initialize specific instance of a camera
    _initializeControllerFuture = cameraController.initialize();

    /// Instantiate bloc object (aka controller with all the logic)
    // this also starts a chain of methods in GameBloc to start informing this screen
    gameBloc = GameBloc(
      playerOneUserID: playerOneUserID,
      gameMap: gameMap,
      gameRulesID: gameRulesID,
      competitionID: competitionID,
      cameraController: cameraController
    );


    /// Fetch required data before loading game screen
    /// then inform game screen to load widgets
    gameBloc.preSetupGameScreen();

        /// Load the UI and widgets on the screen
    gameBloc.loadUIOnScreen();

    //videoProcessingServiceKOH = VideoProcessingServiceKOH(gameBloc: gameBloc, cameraController: cameraController);

  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Methods
  /// ***********************************************************************
  /// ***********************************************************************

  /// ***********************************************************************
  /// ***********************************************************************
  /// Google Analytic Tracking Methods
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _sendAnalyticsEventCompleteGame() async {
    await globals.Analytics.analytics.logEvent(
      name: 'complete_game',
      parameters: <String, dynamic>{
        'Game Completed': true,
      },
    );
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  void onPressButtonAction(constantsKOH.GameStage gameStage) {
    /// hide button and set default button label
   Map buttonConfig = {
      'buttonVisibility': false,
      'buttonText': 'Disabled',
      'onPressButtonAction': 0,
    };
    gameBloc.buttonControllerSink.add(buttonConfig);

    /// either exit the game, or
    // move to the next gameStage
    if (gameStage == constantsKOH.GameStage.Exit) {
      exitButtonAction();
    } else {
      gameBloc.loadGameStageSink.add(gameStage);
    }
  }

  void exitButtonAction() {
    // Exit button displays at the end of the game experience
    // dispose() is automatically called

    /// GA tracking
    _sendAnalyticsEventCompleteGame();

    // Redirect
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
  }

  quitGameIconOnPress() {
    // Quit icon is available in game xp in upper left hand corner at all times
    // dispose() is automatically called
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// ML image stream methods
  /// ***********************************************************************
  /// ***********************************************************************


  /// ** StopRecordingButtonAction does the following **
  /// - stops the camera from recording
  /// - stores the localSelfieVideo that is used to be auto replay at the end of the game xp
  /// - creates a new video collection
  /// - when a new video collection is created, this triggers a cloud function to create a 'uploadURL' from firebase cloud storage
  // that is then saved to the videos collection by the cloud function
  /// - then a collection stream is created
  /// -- to wait for this uploadUrl to become available
  /// - when uploadUrl is available, then it starts the upload video process
  /// - then waits for the upload to complete
  /// - after complete, it gets the videoURL from firebase storage, which is what will be used to replay the video remotely
  /// - then shares videoURL with game bloc/controller so it can be saved to the games document
  /// - at this point, the bloc/controller stops displaying "saving" and moves to the next game stage


  ///Start and stop image streams for MLkit usage.
  Future <void> startImageStream() async {
    await cameraController.startImageStream(_processCameraImage);
  }

  Future <void> stopImageStream() async {
    await cameraController.stopImageStream();
    await poseDetector.close();
    motionData.dispose();
  }

  //ML method to control start and stop imageStream
  void manageMLCameraAction (cameraRecordAction) {
    if (cameraRecordAction == constantsKOH.RecordingEnum.StartStreamWithoutRecording) {
      startImageStream();
    }

    if (cameraRecordAction == constantsKOH.RecordingEnum.StopStreamWithoutRecording) {
      stopImageStream();
    }
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// IPFS methods
  /// ***********************************************************************
  /// ***********************************************************************
  ///TODO: Move to it's own service for NFT minting.
  Future<void> uploadVideoIpfs(File imageFile) async {

    Map<String, String> headers = { "Authorization": "249a4ff4-846d-426a-9280-26c36a5952ca"}; //key for NFTPort
    //String videoUrl = '';

    // open a bytestream
    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("https://api.nftport.xyz/v0/files");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: imageFile.path);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    await response.stream.bytesToString().then((value) {
      Map ipfsJSON = jsonDecode(value);
      ipfsVideoUrl = ipfsJSON['ipfs_url'];
      print(ipfsVideoUrl);
    });
    //return videoUrl;

    CollectionReference url = FirebaseFirestore.instance.collection('games');

    await  url.doc(gameBloc.gameID)
          .update({'ipfsUrl': ipfsVideoUrl})
          .then((value) => print("URL Updated"))
          .catchError((error) => print("Failed to update user: $error"));
  }


  /// ***********************************************************************
  /// ***********************************************************************
  /// ML functions
  /// ***********************************************************************
  /// ***********************************************************************

  Future<void> _processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final poses = await poseDetector.processImage(inputImage);
    print('Found ${poses.length} poses');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);

      motionData.pushUpRepCounter(poses);

      print('PROCESS IMAGE RUNNING');

      customPaint = CustomPaint(painter: painter);
    } else {
      customPaint = null;
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());

    final camera = widget.camera;
    final imageRotation =
        InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    //widget.onImage(inputImage);
    _processImage(inputImage);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: gameBloc.gameScreenWrapperStream,
      initialData: {
        'ready': false,
      },
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: primarySolidCardColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: (MediaQuery.of(context).size.height) - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[

                            /// ***************************************************************
                            ///  Video Player (options: network file, local file)
                            /// ***************************************************************

                            StreamBuilder<Map>(
                                stream: gameBloc.videoPlayerControllerStream,
                                initialData: {'videoPlayerMode': 'hidden'},
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    final videoPlayerMode = snapshot.data!['videoPlayerMode'] as String;

                                    /// Display their own video after they are done playing
                                    // this uses the localSelieVideoToPlay parameter, and selfieVideoToPlay = ''
                                    if (videoPlayerMode == 'self') {
                                      Map videoMap = {'localVideoFile': gameBloc.playbackVideo};
                                      return VideoFullScreen(videoMap: videoMap, videoURL: selfieVideoToPlay, videoConfiguration: 1);
                                    } if (videoPlayerMode == 'pushupTutorial') {
                                      Map videoMap = {'localVideoFile': 'none'};
                                      return VideoFullScreen(videoMap: videoMap, videoURL: gameBloc.getTutorialVideoURL, videoConfiguration: 6);
                                    } else {
                                      // videoPlayerMode = hidden so do not show the widget
                                      return Container();
                                    }
                                  } else {
                                    // snapshot.data has no data so display nothing
                                    return Container();
                                  }
                                }),

                            /// ***************************************************************
                            ///  Full Background: Camera (options: on, recording, ML rep counting)
                            /// ***************************************************************

                            StreamBuilder<Map>(
                                stream: gameBloc.cameraUIControllerStream,
                                initialData: {'cameraMode': 'full'},
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    final cameraMode = snapshot.data!['cameraMode'] as String;
                                    if (cameraMode == 'full') {
                                      return SizedBox.expand(
                                        child: FutureBuilder<void>(
                                          future: _initializeControllerFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.done && cameraController.value.isInitialized) {
                                              var camera = cameraController.value;
                                              // fetch screen size
                                              final size = MediaQuery.of(context).size;

                                              // calculate scale depending on screen and camera ratios
                                              // this is actually size.aspectRatio / (1 / camera.aspectRatio)
                                              // because camera preview size is received as landscape
                                              // but we're calculating for portrait orientation
                                              var scale = size.aspectRatio * camera.aspectRatio;

                                              // to prevent scaling down, invert the value
                                              if (scale < 1) scale = 1 / scale;
                                              // If the Future is complete, display the preview.
                                              return  Transform.scale(
                                                scale: scale,
                                                child: Center(child: CameraPreview(cameraController)),
                                              );
                                            } else {
                                              // Otherwise, display a loading indicator.
                                              return LoadingScreenStatic(displayVisual: 'loading icon');
                                            }
                                          },
                                        ),
                                      );

                                      /// ***************************************************************
                                      ///  Full Background: Rep counting
                                      /// ***************************************************************

                                    } else if(cameraMode == 'repCountMode') {
                                      return Container(
                                        color: Colors.black,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: <Widget>[
                                            CameraPreview(cameraController),
                                            if (customPaint != null) customPaint!
                                          ],
                                        ),
                                      );
                                    }
                                    else if (cameraMode == 'hidden') {
                                      return Container();
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                },
                            ),

                            /// ***************************************************************
                            ///  Full Background: misc UI
                            /// ***************************************************************

                            StreamBuilder<bool>(
                              stream: gameBloc.fullBackground2UIStream,
                              initialData: false,
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  final isRecordingIconVisible = snapshot.data as bool;
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Visibility(visible: isRecordingIconVisible, child: RecordingIcon()),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),

                            /// ***************************************************************
                            ///  UI: Top
                            /// ***************************************************************

                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Material(
                                  color: primarySolidBackgroundColor.withOpacity(0.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: [QuitGameIcon(quitGameIconOnPress: quitGameIconOnPress)],
                                      ),
                                      StreamBuilder<List<Widget>>(
                                        stream: gameBloc.uiStream,
                                        initialData: [],
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            final list = snapshot.data as List<Widget>;
                                            return Column(
                                              children: list,
                                            );
                                          } else {
                                            return Column(
                                              children: myList,
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 24),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Stack(
                                        children: [

                                          /// ***************************************************************
                                          ///  UI: Bottom
                                          /// ***************************************************************

                                          StreamBuilder<Map>(
                                              stream: gameBloc.buttonControllerStream,
                                              initialData: {'buttonVisibility': false, 'buttonText': 'Disabled', 'onPressButtonAction': 0},
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null) {
                                                  final buttonControls = snapshot.data as Map;
                                                  return Visibility(
                                                    visible: buttonControls['buttonVisibility'],
                                                    child: MediumEmphasisButton(
                                                      title: buttonControls['buttonText'],
                                                      onPressAction: () {
                                                        onPressButtonAction(buttonControls['onPressButtonAction']);
                                                        manageMLCameraAction(buttonControls['cameraRecordAction']);
                                                        gameBloc.manageCameraAction(buttonControls['cameraRecordAction']);
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              }),

                                          /// ***************************************************************
                                          ///  UI: Bottom 2
                                          /// ***************************************************************

                                          StreamBuilder<dynamic>(
                                              stream: motionData.repCountStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null && snapshot.data < 3) {
                                                  var repCount = snapshot.data;
                                                  String repCountString = repCount.toString();
                                                  var remainingReps = 3-repCount;
                                                  return Container(
                                                    width: (MediaQuery.of(context).size.width) * 0.80,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: primarySolidCardColor,
                                                      borderRadius: borderRadius1(),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text('$repCountString reps give me $remainingReps more!', style: PrimaryBT1()),
                                                    ),
                                                  );
                                                } else {
                                                  return Container(width: (MediaQuery.of(context).size.width) * 0.80,
                                                    height: 50,);
                                                }
                                              }
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 32),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
    // top module
  }
}
