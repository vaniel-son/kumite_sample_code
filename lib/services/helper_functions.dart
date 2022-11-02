import 'package:dojo_app/globals.dart' as globals;
import 'package:uuid/uuid.dart';

void setGlobalUser(user) {
  globals.dojoUser = user;
}

void setGlobalNickname(nickname) async {
  globals.nickname = nickname;
}

// print big to console to help debug
void printBig(String title, String stringValue) {
  print('1***************************************************************');
  print('2*                                                             *');
  print('****        $title: $stringValue');
  print('3                                                              *');
  print('4***************************************************************');
}

String createUUID() {
  /// Generate a unique id
  var uuid = Uuid(); // create unique uuid for levelID
  String levelID = uuid.v1();
  return levelID;
}

// get date/time of midnight that previously occurred
DateTime previousMidnight() {
  var now = DateTime.now();
  var lastMidnight = DateTime(now.year, now.month, now.day);
  return lastMidnight;
}

// get date/time of midnight that is taking place next
DateTime nextMidnight() {
  var now = DateTime.now();
  var tomorrowMidnight = DateTime(now.year, now.month, now.day +1);
  return tomorrowMidnight;
}