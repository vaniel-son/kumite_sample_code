import 'package:dojo_app/globals.dart' as globals;
import 'package:dojo_app/game_modes/matches/globals_matches.dart' as globalsMatches;
import 'package:dojo_app/game_modes/matches/services/database_service_matches.dart';
import 'package:dojo_app/game_modes/matches/services/game_service_matches.dart';
import 'package:page_transition/page_transition.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dojo_app/game_modes/matches/services/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_wrapper.dart';

class ConfirmAndSaveFoodImage extends StatefulWidget {
  final String localImagePath;
  final Map matchDetailsMap;

  ConfirmAndSaveFoodImage({Key? key, required this.localImagePath, required this.matchDetailsMap})
      : super(key: key);

  @override
  _ConfirmAndSaveFoodImageState createState() => _ConfirmAndSaveFoodImageState();
}

class _ConfirmAndSaveFoodImageState extends State<ConfirmAndSaveFoodImage> {
  /// Instantiate DB service objects so we can perform actions from a consolidated file
  DatabaseServicesMatches databaseServices = DatabaseServicesMatches();

  /// Instantiate match service
  GameServiceMatches matchService = GameServiceMatches();

  /// Setup required parameters
  late Map gameMap = widget.matchDetailsMap;
  String playerOneUserID = globals.dojoUser.uid;
  late String playerTwoUserID = getOpponentUserID(gameMap, playerOneUserID);
  late String groupID = globalsMatches.matchGroupID;
  late String playerOneNickname = gameMap['playerNicknames'][playerOneUserID];
  late String localImagePath = widget.localImagePath;

  //Button press variable. Used to ensure user doesn't press the button twice.
  var _firstPress = true;

  Future<void> buttonPressAction() async {
    /// Upload picture to firebase storage
    String directoryAndFileName = await matchService.uploadPicture(localImagePath, gameMap);

    /// Retrieve saved image's URL from firebase storage
    String firebaseImageURL = await databaseServices.fetchFoodPicture(directoryAndFileName);

    /// Save firebase storage URL to match collection, for both players
    matchService.updateMatchWithFoodImageURL(
        firebaseImageURL: firebaseImageURL,
        matchID: gameMap['id'],
        matchGroupID: groupID,
        playerOneUserID: playerOneUserID,
        playerOneNickname: playerOneNickname,
        playerTwoUserID: playerTwoUserID,
        dates: gameMap['dates'],
    );

    ///Update matches activity tracker to note that a pic was taken for the day.
    databaseServices.updateMatchActivityTrackerField(gameMap);

    /// Reward the player a point
    //matchService.addNutritionOrSleepPoints(gameMap: gameMap, userID: playerOneUserID, subScoreType: constants.cSubScoreTypeNutrition);



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(children: <Widget> [
        Image.file(File(widget.localImagePath)),
        Positioned(
          bottom: 20,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  HighEmphasisButton(title: 'Accept Picture',
                      onPressAction: ()async {
                        if (_firstPress) {

                          _firstPress = false;

                          await buttonPressAction();
                          Navigator.pushAndRemoveUntil(
                              context, PageTransition(type: PageTransitionType
                              .rightToLeftWithFade, child: MatchesWrapper()), (
                              Route<dynamic> route) => false);
                        }
                      }
                  ),
                  SizedBox(height: 20,),
                  MediumEmphasisButton(title: 'Retake', onPressAction:(){Navigator.pop(context);})
                ]
            ),
          ),
        ),
      ]),
    );
  }
}
