import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dojo_app/game_modes/training_emom/models/emom_hud_widget_visibility_config_model_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/pho_bowl_progress_screen.dart';
import 'package:dojo_app/services/sound_service.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'game_bloc.dart';
import 'package:dojo_app/game_modes/training_emom/screens/game/services/video_processing_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/services/database_service_pemom.dart';
import 'package:dojo_app/game_modes/training_emom/constants_pemom.dart' as constantsKOH;
import 'package:dojo_app/screens/video_player/video_full_screen.dart';
import 'package:dojo_app/screens/wrapper.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/services/helper_functions.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/close_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:dojo_app/services/pose_estimation_services/motion_data_service.dart';
import 'package:dojo_app/services/pose_estimation_services/pose_painter_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'package:dojo_app/globals.dart' as globals;
import 'dart:io';
import 'dart:async';
import 'dart:convert';

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
  GameScreen({this.gameMap = const {}, required this.gameRulesID, required this.userID}) {
    //
  }

  final Map gameMap;
  final String gameRulesID;
  final String userID;

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
  late String playerOneUserID = widget.userID;

  /// Initialize database object for calls to the DB
  DatabaseServicesPEMOM databaseServices = DatabaseServicesPEMOM();
  DatabaseServices databaseServicesShared = DatabaseServices();

  /// Initialize main game controller
  late GameBloc gameBloc;

  ///Initialize VideoService
  late VideoProcessingServicePEMOM videoProcessingServiceKOH;

  /// Initialize List to contain which widgets to display
  // this is controlled and populated by the GameBloc
  List<Widget> myList = [];

  /// Managing rep counting
  int lastRememberedRepCount = 0;

  /// Pho video that plays during the pho rewards stage
  // String phoVideo = 'https://firebasestorage.googleapis.com/v0/b/dojo-app-prod.appspot.com/o/assets_app%2Fvideos%2Fmisc%2Fpho_cooking-04.mp4?alt=media&token=74372be0-ef10-4632-93ae-8d0272222bf6';

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
  /// Styling config for EMOM hud
  /// ***********************************************************************
  /// ***********************************************************************

  ///Colors for results UI elements
  Color colorResult1 = Colors.black;
  Color colorResult2 = Colors.black;
  Color colorResult3 = Colors.black;

  ///Colors for Rounds UI elements
  Color colorRound1 = Colors.black;
  Color colorRound2 = Colors.black;
  Color colorRound3 = Colors.black;

  /// Round Text to display based on round status (pending, current, success, failure)
  late String roundText1;
  late String roundText2;
  late String roundText3;

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

  // this runs near-immediately upon loading this class
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
    gameBloc = GameBloc(playerOneUserID: playerOneUserID, gameMap: gameMap, gameRulesID: gameRulesID, cameraController: cameraController);

    /// Fetch required data before loading game screen
    /// then inform game screen to load widgets
    gameBloc.preSetupGameScreen();

    /// Load the UI and widgets on the screen
    // because the above items have completed
    gameBloc.loadUIOnScreen();
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
    // Play SFX on button tap
    SoundService.buttonClickOne();

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
    // Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
    Navigator.push(context, PageTransition(type: PageTransitionType.bottomToTop, child: PhoBowlProgressScreen(phoBowlsInventoryCount: gameBloc.getPhoBowlsInventoryCount, phoBowlsRequiredForUpcomingMainEventInvite: gameBloc.getPhoBowlsRequiredForNextMainEvent, phoBowlsEarned: gameBloc.getPhoBowlsEarned)));
  }

  quitGameIconOnPress() {
    // Quit icon is available in game xp in upper left hand corner at all times
    // dispose() is automatically called
    Navigator.pushAndRemoveUntil(context, PageTransition(type: PageTransitionType.bottomToTop, child: Wrapper()), (Route<dynamic> route) => false);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc Method
  /// ***********************************************************************
  /// ***********************************************************************

  /// A hack: position the button near the bottom only for the first button display
  // for the remainder, display the button further up so it does not cover the EMOM HUD
  double determineButtonPositionFromBottom(context, bool buttonPositionTargetBottom) {
    double buttonPositionFromBottom = 10.0; // default value
    if (buttonPositionTargetBottom) {
      buttonPositionFromBottom = 16.0;
    } else if (!buttonPositionTargetBottom) {
      buttonPositionFromBottom = MediaQuery.of(context).size.height * .36 - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom;
    }

    return buttonPositionFromBottom;
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
  Future<void> startImageStream() async {
    await cameraController.startImageStream(_processCameraImage);
  }

  Future<void> stopImageStream() async {
    await cameraController.stopImageStream();
    await poseDetector.close();
    motionData.dispose();
  }

  //ML method to control start and stop imageStream
  void manageMLCameraAction(cameraRecordAction) {
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
    Map<String, String> headers = {"Authorization": "249a4ff4-846d-426a-9280-26c36a5952ca"}; //key for NFTPort
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
    var multipartFile = new http.MultipartFile('file', stream, length, filename: imageFile.path);

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

    await url
        .doc(gameBloc.gameID)
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
    if (inputImage.inputImageData?.size != null && inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size, inputImage.inputImageData!.imageRotation);

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

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final camera = widget.camera;
    final imageRotation = InputImageRotationMethods.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.Rotation_0deg;

    final inputImageFormat = InputImageFormatMethods.fromRawValue(image.format.raw) ?? InputImageFormat.NV21;

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

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    _processImage(inputImage);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widgets for streams
  /// ***********************************************************************
  /// ***********************************************************************

//Displays buttons for game
  Widget buttonDisplay(BuildContext context) {
    return StreamBuilder<Map>(
        stream: gameBloc.buttonControllerStream,
        initialData: {'buttonVisibility': false, 'buttonText': 'Disabled', 'onPressButtonAction': 0, 'buttonPositionTargetBottom': false},
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final buttonControls = snapshot.data as Map;

            /// determine position of button from the bottom
            bool buttonPositionTargetBottom = false;
            if (buttonControls['buttonPositionTargetBottom'] != null) {
              buttonPositionTargetBottom = buttonControls['buttonPositionTargetBottom'];
            }
            double bottomPosition = determineButtonPositionFromBottom(context, buttonPositionTargetBottom);

            return Visibility(
              visible: buttonControls['buttonVisibility'],
              child: Positioned(
                bottom: bottomPosition,
                right: 10,
                left: 10,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MediumEmphasisButton(
                    title: buttonControls['buttonText'],
                    onPressAction: () {
                      onPressButtonAction(buttonControls['onPressButtonAction']);
                      manageMLCameraAction(buttonControls['cameraRecordAction']);
                    },
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  //Displays the camera for rep counting
  Widget cameraImageInputAndPaintStream(BuildContext context) {
    return StreamBuilder<Map>(
      stream: gameBloc.cameraUIControllerStream,
      initialData: {'cameraMode': 'hidden'},
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final cameraMode = snapshot.data!['cameraMode'] as String;
          if (cameraMode == 'hidden') {
            return Container();
          } else if (cameraMode == 'repCountMode') {
            return Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[CameraPreview(cameraController), if (customPaint != null) customPaint!],
              ),
            );
          } else if (cameraMode == 'halfScreenVideoPlayer') {
            return Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VideoFullScreen(videoMap: {'localVideoFile': 'none'}, videoURL: gameBloc.getRewardsBackgroundVideo, videoConfiguration: 4),
                ],
              ),
            );
          } else {
            return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  //All the widgets giving Sifu's instructions during game.
  Widget topOverlayWidgetStream(BuildContext context) {
    return StreamBuilder<List<Widget>>(
      stream: gameBloc.uiStream,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final list = snapshot.data as List<Widget>;
          return Column(
            children: list,
          );
        } else {
          return Container();
        }
      },
    );
  }

//All the bottom UI elements
  Widget bottomUiGameElements(BuildContext context) {
    return StreamBuilder<EmomHUDWidgetVisibilityModel>(
        stream: gameBloc.emomHUDControllerStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            EmomHUDWidgetVisibilityModel emomVisibility = snapshot.data as EmomHUDWidgetVisibilityModel;
            return Visibility(
              visible: emomVisibility.isEMOMHudVisible,
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: primarySolidCardColor,
                ),
                child: Column(
                  children: [

                    /// Round Status (ex. Round 1, Round 2, Round 3)
                    Visibility(
                      visible: emomVisibility.isRoundStatusVisible,
                      child: Row(
                        children: [
                          StreamBuilder<List>(
                              stream: gameBloc.roundStatusControllerStream,
                              initialData: ['pending', 'pending', 'pending'],
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  List roundStatus = snapshot.data as List;
                                  Color textColorVariable = onPrimaryWhite;

                                  //Results Colors
                                  colorResult1 = determineResultDisplayColor1(roundStatus)[0];
                                  colorResult2 = determineResultDisplayColor1(roundStatus)[1];
                                  colorResult3 = determineResultDisplayColor1(roundStatus)[2];

                                  //Rounds Colors
                                  colorRound1 = determineRoundsDisplayColor1(roundStatus)[0];
                                  colorRound2 = determineRoundsDisplayColor1(roundStatus)[1];
                                  colorRound3 = determineRoundsDisplayColor1(roundStatus)[2];

                                  // Determine round status text to display
                                  Widget roundText1 = determineRoundsDisplayText(roundStatus)[0];
                                  Widget roundText2 = determineRoundsDisplayText(roundStatus)[1];
                                  Widget roundText3 = determineRoundsDisplayText(roundStatus)[2];

                                  return Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              color: colorRound1,
                                              width: MediaQuery.of(context).size.width * (1 / 3) - 1,
                                              padding: const EdgeInsets.all(11),
                                              child: Center(child: Text('Round 1'))),
                                          Container(
                                            width: 1,
                                            color: primarySolidCardColor,
                                          ),
                                          Container(
                                              color: colorRound2,
                                              width: MediaQuery.of(context).size.width * (1 / 3),
                                              padding: const EdgeInsets.all(11),
                                              child: Center(child: Text('Round 2'))),
                                          Container(
                                            width: 1,
                                            color: primarySolidCardColor,
                                          ),
                                          Container(
                                              color: colorRound3,
                                              width: MediaQuery.of(context).size.width * (1 / 3) - 1,
                                              padding: const EdgeInsets.all(11),
                                              child: Center(child: Text('Round 3'))),
                                        ],
                                      ),

                                      /// Round Outcome (Pending, Current, Success, Failure
                                      Row(
                                        children: <Widget>[
                                          Container(
                                              color: colorResult1,
                                              width: MediaQuery.of(context).size.width * (1 / 3) - 1,
                                              padding: const EdgeInsets.all(10),
                                              child: Center(child: roundText1)),
                                          Container(
                                            width: 1,
                                            color: primarySolidCardColor,
                                          ),
                                          Container(
                                              color: colorResult2,
                                              width: MediaQuery.of(context).size.width * (1 / 3),
                                              padding: const EdgeInsets.all(10),
                                              child: Center(child: roundText2)),
                                          Container(
                                            width: 1,
                                            color: primarySolidCardColor,
                                          ),
                                          Container(
                                              color: colorResult3,
                                              width: MediaQuery.of(context).size.width * (1 / 3) - 1,
                                              padding: const EdgeInsets.all(10),
                                              child: Center(child: roundText3)),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                        ],
                      ),
                    ),

                    // spacer between round status and widgets below
                    SizedBox(height: 20),

                    /// workout timer + rep counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        /// Workout timer
                        Column(
                          children: [
                            Visibility(
                                visible: emomVisibility.isStaticWorkoutTimerVisible,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('Time', style: PrimaryCaption1()),
                                    Text('${gameBloc.getWorkoutTimerStatic}', style: GameStyleH1Bold()),
                                  ],
                                )),
                            Visibility(
                              // the timer widget and styling is found in
                              // training_emom/widgets/timer_card.dart
                              visible: emomVisibility.isDynamicWorkoutTimerVisible,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Time', style: PrimaryCaption1()),
                                  StreamBuilder<List<Widget>>(
                                      stream: gameBloc.emomTimerControllerStream,
                                      initialData: [],
                                      builder: (context, snapshot) {
                                        if (snapshot.data != null) {
                                          final listOfWidgets = snapshot.data as List<Widget>;
                                          return Column(
                                            children: listOfWidgets,
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// Rep Counter
                        Visibility(
                          visible: emomVisibility.isCurrentRepCounterVisible,
                          child: StreamBuilder<int>(
                              stream: gameBloc.currentRoundRepCountControllerStream,
                              initialData: 0,
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  int repCount = snapshot.data as int;
                                  return Container(
                                      width: 156,
                                      decoration: BoxDecoration(color: primaryColor, borderRadius: borderRadius1()),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        children: <Widget>[
                                          Text('Reps', style: PrimaryCaption1()),
                                          Text(
                                            '$repCount',
                                            style: TextStyle(fontSize: 48),
                                          ),
                                          Text('out of ${gameBloc.getMaxRepsPerRound}', style: PrimaryCaption1(color: onPrimaryWhite))
                                        ],
                                      ));
                                } else {
                                  return Container();
                                }
                              }),
                        ),
                      ],
                    ),

                    /// Backup 1 Meter message
                    Visibility(
                      visible: emomVisibility.isBackUpMessageVisible,
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          Text('PRO TIP', style: PrimaryBT1(color: captionColor)),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: SizedBox(
                                  height: 40,
                                  child: DefaultTextStyle(
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 36.0,
                                      fontFamily: 'PressStart2P',
                                    ),
                                    child: AnimatedTextKit(
                                      pause: Duration(milliseconds: 10),
                                      repeatForever: true,
                                      animatedTexts: [
                                        ScaleAnimatedText('BACKUP'),
                                        ScaleAnimatedText('1 METER'),
                                      ],
                                      onTap: () {
                                        print("Tap Event");
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text('FROM YOUR CAMERA', style: PrimaryBT1(color: captionColor)),
                        ],
                      ),
                    ),

                    /// Results
                    Visibility(
                      visible: emomVisibility.isYourResultsVisible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text(
                            'Results Grade', style: PrimaryBT1(color: captionColor),
                          ),
                          Text('${(gameBloc.getPushupScore).round()}%', style: GameStyleH4Bold()),
                          Text('completion', style: PrimaryBT1(color: captionColor)),
                        ],
                      ),
                    ),

                    /// Rewards
                    Visibility(
                      visible: emomVisibility.isYourRewardsVisible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text('Your Rewards', style: PrimaryBT1(color: captionColor)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${gameBloc.getRewards}', style: GameStyleH4Bold()),
                              SizedBox(width: 8),
                              Column(
                                children: [
                                  SizedBox(height: 16),
                                  Image.asset(
                                    'images/pho-bowl-01.png',
                                    height: 40,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text('Pho Bowls', style: PrimaryBT1()),
                        ],
                      ),
                    ),

                    /// Your New Goal
                    Visibility(
                      visible: emomVisibility.isYourNewGoalVisible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          Text('New Training Goal', style: PrimaryBT1(color: captionColor)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${gameBloc.getStartingPushupGoal}', style: GameStyleH4Bold(color: captionColor)),
                              SizedBox(width:16),
                              FaIcon(FontAwesomeIcons.arrowRight, size: 32),
                              SizedBox(width:16),
                              Text('${gameBloc.getNewPushupGoal}', style: GameStyleH4Bold(color: primaryColorExtraLight1)),
                          ],),
                          Text('pushups each minute', style: PrimaryBT1(color: captionColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  //Widget that passes rep counts to gameBloc
  Widget passRepDataStream() {
    return StreamBuilder<dynamic>(
        stream: motionData.repCountStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            var repCount = snapshot.data;
            if (repCount > lastRememberedRepCount) {
              gameBloc.successfulPushupTrigger();
              lastRememberedRepCount = repCount;
            }
            return Container();
          } else {
            return Container();
          }
        });
  }

  Widget videoTutorialScreen(BuildContext context) {
    return StreamBuilder<Map>(
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
            }
            if (videoPlayerMode == 'pushupTutorial') {
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
        });
  }

  //Determines the format of the results array.
  List determineResultDisplayColor1(List roundStatus) {
    List colorResults = [Colors.black, Colors.black, Colors.black];

    for (var i = 0; i <= 2; i++) {
      if (roundStatus[i] == 'pending') {
        colorResults[i] = inactiveSolidCardColor;
      } else if (roundStatus[i] == 'current') {
        colorResults[i] = primarySolidCardColor;
      } else if (roundStatus[i] == 'failure') {
        colorResults[i] = primaryDojoColor;
      } else if (roundStatus[i] == 'success') {
        colorResults[i] = greenSuccess;
      }
    }

    return colorResults;
  }

  //Determines the color of the Round text (ex. Round 1, Round 2)
  List determineRoundsDisplayColor1(List roundStatus) {
    List colorResultsRounds = [Color(0xff161B30), Color(0xff161B30), Color(0xff161B30)];

    for (var i = 0; i <= 2; i++) {
      if (roundStatus[i] == 'pending') {
        colorResultsRounds[i] = inactiveSolidCardColor;
      } else if (roundStatus[i] == 'current') {
        colorResultsRounds[i] = primarySolidCardColor;
      } else if (roundStatus[i] == 'failure') {
        colorResultsRounds[i] = inactiveSolidCardColor;
      } else if (roundStatus[i] == 'success') {
        colorResultsRounds[i] = inactiveSolidCardColor;
      }
    }

    return colorResultsRounds;
  }

  //Determines the color of the Round text (ex. Round 1, Round 2)
  List<Widget> determineRoundsDisplayText(List roundStatus) {
    // List roundText = ['TBD', 'TBD', 'TBD']; // default values
    List<Widget> roundTextWidgetList = [Container(), Container(), Container()];
    Widget roundDisplay;

    for (var i = 0; i <= 2; i++) {
      if (roundStatus[i] == 'pending') {
        // roundText[i] = '?';
        roundTextWidgetList[i] = FaIcon(FontAwesomeIcons.solidQuestionCircle, size: 16, color: onPrimaryWhite);
      } else if (roundStatus[i] == 'current') {
        //roundText[i] = 'GO!';
        roundTextWidgetList[i] = Text('GO!', style: PrimaryBT1());
      } else if (roundStatus[i] == 'failure') {
        //roundText[i] = 'FAILURE';
        roundTextWidgetList[i] = Text('FAILURE', style: PrimaryBT1());
      } else if (roundStatus[i] == 'success') {
        //roundText[i] = 'SUCCESS';
        roundTextWidgetList[i] = Text('SUCCESS', style: PrimaryBT1());
      }
    }

    return roundTextWidgetList;
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
          return SafeArea(
            child: Scaffold(
              body: Stack(
                children: [

                  /// Stack Item 1 (Background Color, Bottom half of UI such as EMOM HUD, Rewards, Level
                  Column(
                    children: <Widget>[
                      passRepDataStream(), // pass data from rep stream so our services can access this data

                      // Camera for Computer Vision, Paint stick figure lines
                      Container(
                          //color: Colors.red,
                          height: MediaQuery.of(context).size.height * .66 - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                          child: cameraImageInputAndPaintStream(context)),

                      // Bottom UI
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                              //height: MediaQuery.of(context).size.height * .40  - (MediaQuery.of(context).padding).top - (MediaQuery.of(context).padding).bottom,
                              decoration: BoxDecoration(
                                color: primarySolidCardColor,
                              ),
                              child: Column(
                                children: <Widget>[
                                  bottomUiGameElements(context),
                                  //SizedBox(height: 8),
                                  //buttonDisplay(context)
                                ],
                              )),
                        ),
                      )
                    ],
                  ),

                  /// Stack Item 2 (Full Screen Video)
                  videoTutorialScreen(context),

                  /// Stack Item 3 (Buttons)
                  // Positioned(bottom: determineButtonPositionFromBottom(context), right: 10, left: 10, child: buttonDisplay(context)),
                  buttonDisplay(context),

                  /// Stack Item 4 (Top half widgets: mostly SIFU host cards)
                  Column(
                    children: <Widget>[
                      SizedBox(height: 40), // padding between top and screen and initial widgets to display
                      topOverlayWidgetStream(context),
                    ],
                  ),

                  /// Stack Item 5
                  QuitGameIcon(quitGameIconOnPress: quitGameIconOnPress),
                ],
              ),
            ),
          );
        });
    // top module
  }
}
