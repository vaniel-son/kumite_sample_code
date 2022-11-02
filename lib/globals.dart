import 'package:camera/camera.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Stores auth object's user, which contains user UID
var dojoUser;

// Store this user's nickname for user throughout the application
var nickname = 'Player';

/// Cameras available
List<CameraDescription> cameras = [];

/// Global Analytics object to add tracking to the whole app
class Analytics {
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
}

/// Store Dojo app version information here
class appVersion{
  static String version = '0';
  static String buildNumber = '0';
}

