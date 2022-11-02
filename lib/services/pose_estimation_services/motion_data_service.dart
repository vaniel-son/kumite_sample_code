import 'dart:async';
import 'dart:math';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:vector_math/vector_math.dart';


class MotionData {

  //MotionData(this.poses,);
  //final List<Pose> poses;
  //List shoulderPositions = [];

  int repCount = 0;  //Used to hold rep counts.
  List repCountArray = [0,0,0]; //Used to determine if a rep was done.


  ///Right Shoulder vertical position
  final StreamController _yPositionRightShoulderController = StreamController();
  Stream get yPositionRightShoulderStream => _yPositionRightShoulderController.stream;
  Sink get yPositionRightShoulderSink => _yPositionRightShoulderController.sink;

  ///Right Arm Angle
  final StreamController _rightArmAngleController = StreamController();
  Stream get rightArmAngleStream => _rightArmAngleController.stream;
  Sink get rightArmAngleSink => _rightArmAngleController.sink;

  ///Left Shoulder vertical position
  final StreamController _yPositionLeftShoulderController = StreamController();
  Stream get yPositionLeftShoulderStream => _yPositionLeftShoulderController.stream;
  Sink get yPositionLeftShoulderSink => _yPositionLeftShoulderController.sink;

  ///Left Arm Angle
  final StreamController _leftArmAngleController = StreamController();
  Stream get leftArmAngleStream => _leftArmAngleController.stream;
  Sink get leftArmAngleSink => _leftArmAngleController.sink;

  ///Right Wrist vertical position
  final StreamController _rightWristController = StreamController();
  Stream get rightWristStream => _rightWristController.stream;
  Sink get rightWristSink => _rightWristController.sink;

  ///Z coordinate of midpoint of vector between left and right foot.  Used to approximate if you actually in push-up position.
  final StreamController _zPositionMidPointLeftAndRightFootController = StreamController();
  Stream get zPositionMidPointLeftAndRightFootStream => _zPositionMidPointLeftAndRightFootController.stream;
  Sink get zPositionMidPointLeftAndRightFootSink => _zPositionMidPointLeftAndRightFootController.sink;

  ///Rep Counting Stream
  final StreamController _repCountController = StreamController();
  Stream get repCountStream => _repCountController.stream;
  Sink get repCountSink => _repCountController.sink;


  void dispose() {
    _yPositionRightShoulderController.close();
    _yPositionLeftShoulderController.close();
    _rightArmAngleController.close();
    _leftArmAngleController.close();
    _rightWristController.close();
    _zPositionMidPointLeftAndRightFootController.close();
    _repCountController.close();
  }

  void rightShoulderPositionStream(poses) {

    poses.forEach((pose) {

      PoseLandmark shoulderPositionData =   pose.landmarks[PoseLandmarkType.rightShoulder]!;
      var shoulderPositionY = shoulderPositionData.y;

      //shoulderPositions.add(shoulderPositionY);
      //var lastPositionalDataPoint = shoulderPositions.last; Don't need this as I can use the data directly.

      yPositionRightShoulderSink.add(shoulderPositionY);

    });
  }

  void leftShoulderPositionStream(poses) {

    poses.forEach((pose) {

      PoseLandmark shoulderPositionData =   pose.landmarks[PoseLandmarkType.leftShoulder]!;
      var shoulderPositionY = shoulderPositionData.y;

      //shoulderPositions.add(shoulderPositionY);
      //var lastPositionalDataPoint = shoulderPositions.last; Don't need this as I can use the data directly.

      yPositionLeftShoulderSink.add(shoulderPositionY);

    });
  }

  void rightWristPositionStream(poses) {

    poses.forEach((pose) {

      PoseLandmark wristPositionData =   pose.landmarks[PoseLandmarkType.rightWrist]!;
      var wristPositionY = wristPositionData.y;

      //shoulderPositions.add(shoulderPositionY);
      //var lastPositionalDataPoint = shoulderPositions.last; Don't need this as I can use the data directly.

      rightWristSink.add(wristPositionY);

    });

  }

  void rightArmAngleDataStream(poses) {

    poses.forEach((pose) {
      PoseLandmark firstPoint = pose.landmarks[PoseLandmarkType.rightShoulder]!;
      PoseLandmark midPoint = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark lastPoint = pose.landmarks[PoseLandmarkType.rightWrist]!;


      var result = angleCalculator(firstPoint, midPoint, lastPoint);
      rightArmAngleSink.add(result);

    });
  }

  void leftArmAngleDataStream(poses) {


    poses.forEach((pose) {
      PoseLandmark firstPoint = pose.landmarks[PoseLandmarkType.leftShoulder]!;
      PoseLandmark midPoint = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark lastPoint = pose.landmarks[PoseLandmarkType.leftWrist]!;


      var result = angleCalculator(firstPoint, midPoint, lastPoint);
      leftArmAngleSink.add(result);

    });
  }

  void zCoordinateMidPointBtwTwoFeetStream(poses) {
    poses.forEach((pose) {

      ///Z coordinate for right ankle
      PoseLandmark rightAnklePositionData =  pose.landmarks[PoseLandmarkType.rightAnkle]!;
      var zRightAnklePosition = rightAnklePositionData.z;

      ///Z coordinate for left ankle
      PoseLandmark leftAnklePositionData =   pose.landmarks[PoseLandmarkType.leftAnkle]!;
      var zLeftAnklePosition = leftAnklePositionData.z;

      ///Midpoint coordinates for vector between left and right ankle
      double zMidpoint = (zLeftAnklePosition + zRightAnklePosition)/2;

      print('THIS IS THE MIDPOINT: $zMidpoint');

      zPositionMidPointLeftAndRightFootSink.add(zMidpoint);

    });

  }

  void pushUpRepCounter(poses) {

    poses.forEach((pose) {

      PoseLandmark leftFirstPoint = pose.landmarks[PoseLandmarkType.leftShoulder]!;
      PoseLandmark leftMidPoint = pose.landmarks[PoseLandmarkType.leftElbow]!;
      PoseLandmark leftLastPoint = pose.landmarks[PoseLandmarkType.leftWrist]!;

      PoseLandmark rightFirstPoint = pose.landmarks[PoseLandmarkType.rightShoulder]!;
      PoseLandmark rightMidPoint = pose.landmarks[PoseLandmarkType.rightElbow]!;
      PoseLandmark rightLastPoint = pose.landmarks[PoseLandmarkType.rightWrist]!;


      var resultLeftArm = angleCalculator(leftFirstPoint, leftMidPoint, leftLastPoint);
      var resultRightArm = angleCalculator(rightFirstPoint, rightMidPoint, rightLastPoint);

      var sumRepArray =   repCountArray.reduce((a, b) => a + b);

      if(resultRightArm > 165 && resultLeftArm > 165) {

        if(sumRepArray == 0) {

          repCountArray[0] = 1;

        } else if (sumRepArray == 2){

          repCountArray = [0,0,0];
          repCount = repCount +1;
          repCountSink.add(repCount);
        }
      } else if(resultRightArm < 100 && resultLeftArm < 100) {

        if(sumRepArray==1) {
          repCountArray[1] = 1;
        }

      } else {
        print('No conditions were met');
      }

    });

  }

  double angleCalculator(PoseLandmark firstPoint, PoseLandmark midPoint,
      PoseLandmark lastPoint) {

    double result = degrees(
        atan2(lastPoint.y - midPoint.y,
            lastPoint.x - midPoint.x)
            - atan2(firstPoint.y - midPoint.y,
            firstPoint.x - midPoint.x));

    result = result.abs(); // Angle should never be negative

    if (result > 180) {
      result =
      (360.0 - result); // Always get the acute representation of the angle
    }

    return result;

  }



}