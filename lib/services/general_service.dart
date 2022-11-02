import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dojo_app/models/dojo_user.dart';
import 'package:dojo_app/services/auth_service.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dojo_app/constants.dart' as constants;
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:http/http.dart';

class GeneralService {
  // Initialize DB object with methods to call DB
  DatabaseServices databaseServiceShared = DatabaseServices();

  /// Constructor
  GeneralService() {
    //
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Misc
  /// ***********************************************************************
  /// ***********************************************************************

  /// Takes a snapshot, creates a list, so that it's easy to manipulate the data
  static List convertQuerySnapshotToListOfMaps(QuerySnapshot snapshot){
    List snapshotList = [];

    snapshot.docs.forEach((value)
    {
      var dataAsMap = value.data() as Map<String, dynamic>;
      snapshotList.add(dataAsMap);
    });

    return snapshotList;
  }

  /// determine if a map is empty, and if a field exists
  static bool mapHasFieldValue(Map<String, dynamic> targetMap, String targetField) {
    bool mapHasFieldValue = false;
    if (targetMap.isNotEmpty) {
      if (targetMap[targetField] != null) {
        mapHasFieldValue = true;
      }
    }

    return mapHasFieldValue;
  }

  // print big to console to help debug
  static void printBig(String title, String stringValue) {
    print('1***************************************************************');
    print('2*                                                             *');
    print('****        $title: $stringValue');
    print('3                                                              *');
    print('4***************************************************************');
  }

  static String createUUID() {
    /// Generate a unique id
    var uuid = Uuid(); // create unique uuid for levelID
    String levelID = uuid.v1();
    return levelID;
  }

  static String capitalizeFirstLetter(String stringToModify){
    String modifiedString = toBeginningOfSentenceCase(stringToModify)!;
    return modifiedString;
  }

  static displaySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Lock Screen Management
  /// ***********************************************************************
  /// ***********************************************************************

  static Future<Map<String, dynamic>> lockScreenCheck() async {
    /// Get lock screen statuses from Firebase collection 'lockAppStatus'
    Map<String, dynamic> lockScreenStatusData = await DatabaseServices.getLockScreenStatus();

    /// Value to be returned
    Map<String, dynamic> lockScreenStatus = {'lockScreenType': 'none'}; // default value

    /// update app lock?
    // what is this version of the app that this code has
    String buildNumber = await GeneralService.getPackageInformation('buildNumber');

    // compare versions to decide if we should lock
    if (lockScreenStatusData['appVersion'] != null && lockScreenStatusData['appVersionCheckEnabled']) {
      if (int.parse(buildNumber) == int.parse(lockScreenStatusData['appVersion'])) {
        // do nothing
      } else if (int.parse(buildNumber) < int.parse(lockScreenStatusData['appVersion'])) {
        // user has the old version so lock the app
        lockScreenStatus['lockScreenType'] = constants.lockAppStatusType.updateAppVersion;
      } else if (int.parse(buildNumber) > int.parse(lockScreenStatusData['appVersion'])) {
        // do nothing
      } else {
        // do nothing
      }
    }

    // show create account suspended?
    if (lockScreenStatusData['accountCreationSuspended']) {
      lockScreenStatus['lockScreenType'] = constants.lockAppStatusType.accountCreationSuspended;
    }

    // show maintenance lock screen?
    if (lockScreenStatusData['maintenanceEnabled']) {
      lockScreenStatus['lockScreenType'] = constants.lockAppStatusType.maintenanceMode;
    }

    return lockScreenStatus;
  }

  static Future<String> getPackageInformation(String type) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // store for global use
    globals.appVersion.version = packageInfo.version;
    globals.appVersion.buildNumber = packageInfo.buildNumber;

    if (type == 'appName') {
      return packageInfo.appName;
    } else if (type == 'packageName') {
      return packageInfo.packageName;
    } else if (type == 'version') {
      return packageInfo.version;
    } else if (type == 'buildNumber') {
      return packageInfo.buildNumber;
    } else {
      return '';
    }
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Users
  /// ***********************************************************************
  /// ***********************************************************************

  static void setGlobalUser(user) {
    globals.dojoUser = user;
  }

  static setGlobalNickname(nickname) async {
    globals.nickname = nickname;
  }

  static Future<String> getNickname(userID) async {
    DatabaseServices databaseServiceShared = DatabaseServices();
    String nickname;

    if (globals.nickname == 'Default' || globals.nickname == 'Player') {
      // globals contains one of the default nicknames, meaning, we do not have one we can use
      // fetch it
      nickname = await databaseServiceShared.fetchNicknameWhenDefault(userID:userID);
      nickname = toBeginningOfSentenceCase(nickname)!; // capitalize the first letter
      setGlobalNickname(nickname);
    } else {
      // some name must be present in this global variable, and we can use it
      nickname = toBeginningOfSentenceCase(globals.nickname)!; // capitalize the first letter
      nickname = globals.nickname;
    }

    return nickname;
  }

  static signOut() async {
    final AuthService _auth = AuthService();
    await _auth.signOut();
    globals.nickname == 'Player'; // reset globals variable
    globals.dojoUser = DojoUser(uid: '0');
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Time
  /// ***********************************************************************
  /// ***********************************************************************

  /// get date/time of midnight that previously occurred
  static DateTime previousMidnight() {

    var now = DateTime.now();
    var lastMidnight = DateTime(now.year, now.month, now.day);
    return lastMidnight;
  }

  /// get date/time of midnight that is taking place next
  static DateTime nextMidnight() {
    var now = DateTime.now();
    var tomorrowMidnight = DateTime(now.year, now.month, now.day +1);
    return tomorrowMidnight;
  }

  /// Takes current day (ex. 6/28/2022 7:00pm EST) and provies the next day (ex. 6/29/2022 00:00:00am EST)
  static DateTime getNextDay(DateTime _dateTime) {
    DateTime nextDay = DateTime.now().add(const Duration(days:1));
    return nextDay;
  }

  /// convert time to user friendly format
  static String getFriendlyDateFormat(DateTime dateToConvert) {
    DateFormat formatter = DateFormat('MMMd');
    return formatter.format(dateToConvert);
  }

  /// Compare a games date with todays date to determine if a game is for today
  static bool gameIsForToday(DateTime gameDate) {
    bool gameIsForToday = false;
    // if diff = 0, then competition date is today
    // if diff < 0, then comp date is in the past
    // if diff > 0, then competition is in the future
    if (gameDate.difference(previousMidnight()).inDays == 0) {
      gameIsForToday = true;
    }

    return gameIsForToday;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Randomizer
  /// ***********************************************************************
  /// ***********************************************************************

  /// Generate a random number
  static int getRandomNumber(int maxNumber) {
    Random random = Random();
    return random.nextInt(maxNumber);;
  }

  /// Pass in a list of Strings and this will randomly return one of those items
  static String? getRandomItemFromThisListOfStrings({required List listOfStrings}) {
    // default value
    String? randomItem = null;

    if (listOfStrings.length > 0) {
      // get a random number
      int randomNumber = getRandomNumber(listOfStrings.length);

      // set the randomItem
      randomItem = listOfStrings[randomNumber];
    }

    return randomItem;
  }

  /// Get background video
  static Future<String?> getRandomBackgroundVideo(String gameRulesID) async {
    DatabaseServices databaseService = DatabaseServices();

    // Fetch the gameRules information
    // TODO cache the list of background videos so it doesn't keep grabbing this static list of videos from firebase
    Map gameRulesMap = await databaseService.gameRules(gameRulesID: gameRulesID);
    List defaultBackgroundVideos = gameRulesMap['backgroundVideos'];

    /// Default video to play
    // ex. display when no one has played yet)
    String? _backgroundVideo = GeneralService.getRandomItemFromThisListOfStrings(listOfStrings: defaultBackgroundVideos);

    return _backgroundVideo;
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Player Inventory
  /// ***********************************************************************
  /// ***********************************************************************

  /// New version: stores data in playerInventory collection
  static Future<int> getEarnedPhoBowlsFromFirebase({required userID}) async {
    int phoBowlsEarned = 0;
    DatabaseServices databaseService = DatabaseServices();

    /// get inventory count on DOJO
    Map<String, dynamic> resourcesEarned = await databaseService.fetchPlayerInventoryResources(userID);
    if (GeneralService.mapHasFieldValue(resourcesEarned, 'phoBowls')) {
      phoBowlsEarned = resourcesEarned['phoBowls'];
    }

    return phoBowlsEarned;
  }

  /// Get pho bowls from firebase and ethereum wallet provided by user
  static Future<int> getEarnedPhoBowlsFromAllLocations({required userID}) async {
    int totalPhoBowlsEarned = 0;
    int phoBowlsFromFirebase = 0;
    double phoBowlsFromEthereumWallet = 0.0;
    DatabaseServices databaseService = DatabaseServices();

    /// get inventory count on DOJO
    Map<String, dynamic> resourcesEarned = await databaseService.fetchPlayerInventoryResources(userID);
    if (GeneralService.mapHasFieldValue(resourcesEarned, 'phoBowls')) {
      phoBowlsFromFirebase = resourcesEarned['phoBowls'];
    }

    /// get inventory count from an ethereum address
    String userEthereumWalletAddress = await databaseService.retrieveWalletAddress(userID);
    if (userEthereumWalletAddress != '') {
      phoBowlsFromEthereumWallet = await getPhoBowlsFromEthereumAccount(userEthereumWalletAddress);
    }

    // add both values together
    totalPhoBowlsEarned = phoBowlsFromEthereumWallet.round() + phoBowlsFromFirebase;

    return totalPhoBowlsEarned;
  }

  static Future<double> getPhoBowlsFromEthereumAccount(String walletAddress) async {
    double balance = 0.0;

    late Client httpClient;
    late web3.Web3Client ethClient;
    final String blockchainUrl =
        'https://ropsten.infura.io/v3/1e5bf73e36f04822a0fc51df918631fb';  //changeForProduction//
    httpClient = Client(); // initialize
    ethClient = web3.Web3Client(blockchainUrl, httpClient);

    /// Set contract address and ABI file --> to get the contract
    String contractAddress = "0xbe5a7FC4abdBB335A508FdC4b81Cd1Fea46ac90A"; // pho, ropsten //changeForProduction//
    String abiFile = await rootBundle.loadString("assets/abi/pho_token_abi.json");
    // name of contract is Pho_bowl_token.sol, I think.
    final contract = web3.DeployedContract(web3.ContractAbi.fromJson(abiFile, "pho_bowl_token"), //changeForProduction//
        web3.EthereumAddress.fromHex(contractAddress));

    //obtain private key
    web3.Credentials key = web3.EthPrivateKey.fromHex(
        "a7b328817429020fb8fb98ed2a5ea4a264a6cf2d2af7d2561df5c5c6ff927751"); //changeForProduction//

    // extract function from json file
    web3.ContractFunction function = contract.function("balanceOf");

    /// Get balance
    try {
      // test wallet: 0x35a0d7b88DF113c60D8eA8962A8Bbc5f9bB0676d
      var addressToCheck = web3.EthereumAddress.fromHex(walletAddress);
      List balanceList = await ethClient.call(contract: contract, function: function, params: [addressToCheck]);
      var decimals = BigInt.from(1000000000000000000); // 18 decimals
      balance = balanceList[0] / decimals;
    } catch (e) {
      printBig('error fetching balance', '$e');
      balance = 0.0;
    }

    return balance;
  }

  /// Determines the competition status of 'announced', 'open', 'in the past', based on competition dates and current datetime
  // please pass in UTC times
  static String competitionStatus({required DateTime competitionStartDateTime, required DateTime competitionEndDatetime}) {
    String competitionStatus = constants.competitionStatus.inThePast; // default value

    // if diff = 0, then competition date is today
    // if diff < 0, then comp date is in the past
    // if diff > 0, then competition is in the future

    // competition is in the past
    if (competitionEndDatetime.difference(DateTime.now().toUtc()).inMinutes < 0) {
      competitionStatus = constants.competitionStatus.inThePast;
    }

    // competition is not open yet
    if (competitionStartDateTime.difference(DateTime.now().toUtc()).inMinutes > 0) {
      competitionStatus = constants.competitionStatus.announced;
    }

    // competition is open right now
    if (competitionStartDateTime.difference(DateTime.now().toUtc()).inMinutes < 0 && competitionEndDatetime.difference(DateTime.now().toUtc()).inMinutes > 0) {
      competitionStatus = constants.competitionStatus.open;
    }

    return competitionStatus;
  }
}
