import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'end_game_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class EndGameScreen extends StatefulWidget {
  EndGameScreen() {
    // Constructor
  }

  @override
  _EndGameScreenState createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Class Initialization
  /// ***********************************************************************
  /// ***********************************************************************

  // Initialize services required
  DatabaseServicesKOH databaseServices = DatabaseServicesKOH();
  DatabaseServices databaseServicesShared = DatabaseServices();
  GameServiceKOH gameService = GameServiceKOH();

  /// Declare variable where most of the logic is managed for this screen
  // majority of the logic is in this object
  late EndGameBloc endGameController;

  /// Manually set the competition to end
  String competitionIDtoEnd = '8Ik0hbNSZzkHcJaJ16WX';

  /// ***********************************************************************
  /// ***********************************************************************
  /// Init / Dispose
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Setup
  /// ***********************************************************************
  /// ***********************************************************************


  void setup() async {
    /// Instantiate controller for this Game Mode page
    endGameController = EndGameBloc();

    /// Setup page and fetch required data before loading the UI
    await endGameController.preloadScreenSetup();

    /// Load the UI on this screen
    await endGameController.loadUIOnScreen();
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  menuAction() {
    Navigator.push(context, PageTransition(type: PageTransitionType.leftToRightWithFade, child: Menu()));
  }

  endCompetitionButtonAction() async {
    // end the competition by changing the status
    await endGameController.endCompetition();

    // display success message when complete
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Snack bar message
  /// ***********************************************************************
  /// ***********************************************************************

  final snackBar = SnackBar(
    content: Text('Success! Competition has been ended'),
  );

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: endGameController.wrapperStream,
        initialData: {
          'ready': false,
        },
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final ready = snapshot.data!['ready'] as bool;
            if (ready == true) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: primarySolidBackgroundColor,
                appBar: AppBar(
                  title: PageTitle(title: 'DOJO'),
                  leading: IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      menuAction();
                    },
                  ),
                  backgroundColor: primarySolidBackgroundColor,
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.all(0),
                      child: Column(
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width),
                            height: (MediaQuery.of(context).size.height),
                            child: Stack(
                              children: <Widget>[
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/castle.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          headLine: 'End a competition:',
                                          bodyText:
                                          'Start Date: ${endGameController.getCompetitionToEndStartDate}'),
                                      HostCard(
                                          headLine: 'Competition ID',
                                          bodyText:
                                          '${endGameController.getCompetitionToEndID}'),
                                      SizedBox(height: 16),
                                      Container(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: HighEmphasisButtonWithAnimation(
                                            id: 1,
                                            title: 'END COMPETITION',
                                            onPressAction: endCompetitionButtonAction,
                                          ),
                                        ),
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
                  ),
                ),
              );

            } else {
              return Stack(
                  children: [
                  LoadingScreen(displayVisual: 'loading icon'),
                  BackgroundOpacity(opacity: 'medium'),
                  ],
              );
            }
          } else {
            return Stack(
              children: [
                LoadingScreen(displayVisual: 'loading icon'),
                BackgroundOpacity(opacity: 'medium'),
              ],
            );
          }
        });
    // top module
  }
}
