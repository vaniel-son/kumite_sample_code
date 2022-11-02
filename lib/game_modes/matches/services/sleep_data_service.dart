

//import 'package:health/health.dart';


/*
class SleepDataService {

  final Map gameMap; // Match Date from gameBloc
  final String matchDay;
  late final String playerOneUserID = gameMap['userID'];
  late final String playerTwoUserID = helperMatches.getOpponentUserID(gameMap, playerOneUserID);
  late final GameModelKOH gameInfo;
  late final GameModel2Extras gameInfoExtras;

  SleepDataService({required this.gameMap,required this.matchDay,});

  final HealthFactory health = HealthFactory(); //Create Health Object

  ///Instantiate Match Service to add points totals to match
  GameServiceMatches matchService = GameServiceMatches();

  /// Instantiate database service
  DatabaseServicesMatches databaseServices = DatabaseServicesMatches();

  /// ***********************************************************************
  /// Main Method to fetch data from Apple HealthKit or Google Fit
  /// ***********************************************************************

  Future processSleepData() async {


    List<HealthDataPoint> _healthDataList = [];

    ///Finds the order that the match day is in terms of all the other days.
    // the match document contains matchSleepDays array with days of the week the match takes place
    // index will (return >= 0) as long as today's day of the week "e.g. Thursday" is found in this array
    final index = gameMap['matchSleepDays'].indexWhere((element) =>
    element == matchDay);

    if (index >= 0) {
      //UserID of current player for use in queries
      String userID = gameMap['userID'];


      ///Sleep Data to be updated.
      // TODO: convert vars to known type
      // TODO: convert to an object instead of a map
      var sleepDataForCurrentMatchDay = gameMap['sleepData'][userID][index];

      /// Get the start start and end dates that we will pull for the data
      // match document's "sleepData" map contains the start and end date
      var startDateDataPull = sleepDataForCurrentMatchDay['startDate'].toDate();
      var endDateDataPull = sleepDataForCurrentMatchDay['endDate'].toDate();
      var sleepValues = []; //array to hold the sleep values.

      // Define the types to get
      List<HealthDataType> types = [
        HealthDataType.SLEEP_ASLEEP,
        //HealthDataType.SLEEP_AWAKE,
        //HealthDataType.SLEEP_IN_BED
      ];

      await Permission.activityRecognition.request();

      // you MUST request access to the data types before reading them
      bool accessWasGranted = await health.requestAuthorization(types);


      if (accessWasGranted) {
        try {
          List<HealthDataPoint> healthData = await health
              .getHealthDataFromTypes(
              startDateDataPull, endDateDataPull, types);
          _healthDataList.addAll(healthData);

          if (_healthDataList.isNotEmpty) {
            //Remove Duplicates
            _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

            for (var i = 0; i <= (_healthDataList.length - 1); i++) {
              var sleepValue = _healthDataList[i].value;
              sleepValues.add(sleepValue);
            }

            /// Sleep value calculations
            //Calculates total sleep minutes
            var totalSleep = sleepValues.reduce((a, b) => a + b);
            //Round to nearest minute
            var totalSleepMinutesInt = totalSleep.round();
            //Convert to hours:minutes format
            var totalSleepHours = durationToString(totalSleepMinutesInt);
            print(totalSleepMinutesInt);

            ///New Data
            Map updatedSleepDataThisUser = {
              'actualValue': totalSleepMinutesInt,
              'displayValue': totalSleepHours,
              'sleepDayRange': sleepDataForCurrentMatchDay['sleepDayRange'],
              'startDate': sleepDataForCurrentMatchDay['startDate'],
              'endDate': sleepDataForCurrentMatchDay['endDate']
            };

            /// Create Game Object from map
            //gameInfo = matchService.createGameObject(gameMap);
            //gameInfoExtras = matchService.createGameExtrasObject(
                //gameMap, playerOneUserID, playerTwoUserID);

            /// Add the new sleep data to object
            // replace for this player (player1)
            //printBig("gameInfoObject with OG sleep",
                //"${gameInfo.sleepData[playerOneUserID][index]}");
            //gameInfo.sleepData[userID][index] = updatedSleepDataThisUser;
            //printBig("gameInfoObject with new sleep",
                //"${gameInfo.sleepData[playerOneUserID][index]}");


            ///Determine if player slept more than 6 hours and add to scores
            */
/*if (totalSleepMinutesInt > constants.sleepThresholdPoints) {
              //matchService.processPlayerSubScores(gameInfo: gameInfo, gameInfoExtras: gameInfoExtras, userID: playerOneUserID, subScoreType: constants.cSubScoreTypeSleep, points: constants.cScoreSleepPoint, saveMatch: true);

            }*//*


            /// Update match document on firebase
            //databaseServices.updateMatches(gameInfo, gameInfoExtras);
            //databaseServices.updateMatchActivityTrackerField(gameMap,constants.sleepActivityType);

          }
          else {
            print('Data is empty');
          }
        }
        catch (e) {
          print("Caught exception in getHealthDataFromTypes: $e");
        }
      }
      else {
        print('Authorization not granted');
      }
    }
    else {
      print('Today is not a match day');
    }
  }



  //Helper function to calculate hours from minutes and display reader friendly version.
  String durationToString(int minutes) {
    var d = Duration(minutes:minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

}*/
