import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/widgets/host_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToolTipScreen extends StatefulWidget {
  const ToolTipScreen({this.headline, this.bodyText,
    Key? key,
  }) : super(key: key);

  final String? headline;
  final String? bodyText;

  @override
  State<ToolTipScreen> createState() => _ToolTipScreenState();
}

class _ToolTipScreenState extends State<ToolTipScreen> {
  /// ***********************************************************************
  /// ***********************************************************************
  /// Widgets
  /// ***********************************************************************
  /// ***********************************************************************

  ///OTHER METHODS
  void backButtonAction(context) {
    Navigator.pop(context, []);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColorDark1,
          ],
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.all(0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: (MediaQuery.of(context).size.height) -
                        (MediaQuery.of(context).padding).top -
                        (MediaQuery.of(context).padding).bottom,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    print('tap');
                                    backButtonAction(context);
                                  },
                                )),
                            HostCard(
                              headLine: '${widget.headline}',
                              bodyText:
                                  '${widget.bodyText}',
                              // 'Almost every week, your pho bowls will be auth withdrawn to the Ethereum address you provided (Optimism chain).',
                              boxCard: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
