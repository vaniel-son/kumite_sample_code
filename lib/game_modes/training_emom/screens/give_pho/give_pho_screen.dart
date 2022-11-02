import 'package:dojo_app/game_modes/king_of_the_hill/services/database_service_koh.dart';
import 'package:dojo_app/game_modes/training_emom/screens/training_landing/training_landing_screen.dart';
import 'package:dojo_app/services/database_service.dart';
import 'package:dojo_app/game_modes/king_of_the_hill/services/game_service_koh.dart';
import 'package:dojo_app/services/general_service.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/background_opacity.dart';
import 'package:dojo_app/widgets/background_top_img.dart';
import 'package:dojo_app/widgets/button.dart';
import 'package:dojo_app/widgets/loading_screen.dart';
import 'package:dojo_app/widgets/page_title.dart';
import 'package:page_transition/page_transition.dart';
import 'give_pho_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class GivePhoScreen extends StatefulWidget {
  GivePhoScreen({required this.userID, required this.recipientUserID, required this.recipientNickname, this.snackBarMessage = ''}) {
    // Constructor
  }

  String userID;
  String recipientUserID;
  String recipientNickname;
  var context;
  String snackBarMessage;

  @override
  _GivePhoScreenState createState() => _GivePhoScreenState();
}

class _GivePhoScreenState extends State<GivePhoScreen> {
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
  late GivePhoBloc givePhoController;

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
    givePhoController = GivePhoBloc(
        userID: widget.userID,
        recipientUserID: widget.recipientUserID,
        recipientNickname: widget.recipientNickname,
        context: context);

    /// Setup page and fetch required data before loading the UI
    await givePhoController.preloadScreenSetup();

    /// Load the UI on this screen
    await givePhoController.loadUIOnScreen();

    /// Display snack bar if a message was provided
    if (widget.snackBarMessage != '') {
      GeneralService.displaySnackBar(context, widget.snackBarMessage);
    }

  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Button Actions
  /// ***********************************************************************
  /// ***********************************************************************

  backAction() {
    //Navigator.pop(context);

    Navigator.pushReplacement(
        context,
        PageTransition(
            type: PageTransitionType.bottomToTop,
            child: TrainingLandingScreen()));
  }

  /// ***********************************************************************
  /// ***********************************************************************
  /// Widget Tree
  /// ***********************************************************************
  /// ***********************************************************************

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map>(
        stream: givePhoController.wrapperStream,
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
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(title: 'SEND PHO BOWLS'),
                  ],
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      backAction();
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
                                Opacity(opacity: 0.25, child: BackgroundTopImage(imageURL: 'images/dojo-village-day-02.jpg')),
                                Container(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 16,
                                      ),
                                      HostCard(
                                          avatar: 'avatar-host-Sensei.png',
                                          headLineVisibility: true,
                                          headLine: 'Help ${GeneralService.capitalizeFirstLetter(widget.recipientNickname)}!',
                                          bodyText:
                                          'Send your pho bowls to ${GeneralService.capitalizeFirstLetter(widget.recipientNickname)}... \n\n...so they can access the main event!',
                                      avatarName: 'SIFU'),
                                      SizedBox(height: 16),

                                      MediumEmphasisButton(
                                        id: 1,
                                        title: 'SEND 1 PHO BOWL',
                                        onPressAction: givePhoController.giveFivePhoBowls,
                                      ),
                                      spaceVertical2(context: context),
                                      MediumEmphasisButton(
                                        id: 2,
                                        title: 'SEND ALL PHO BOWLS',
                                        onPressAction: givePhoController.giveAllPhoBowls,
                                      ),
                                      SizedBox(height:8),
                                      Text('You have ${givePhoController.phoBowlsEarned} pho bowls', style: PrimaryCaption1()),
                                      Text('Sent from your DOJO wallet balance.', style: PrimaryCaption1()),
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
