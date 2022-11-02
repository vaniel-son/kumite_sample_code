import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:dojo_app/widgets/data_pill.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GameModeCard extends StatefulWidget {
  const GameModeCard({Key? key,
    required this.onPressAction,
    required this.subtitleIcon,
    required this.subtitle,
    required this.title,
    required this.description,
    this.icon2x = false,
    this.displayWinLossTieRecord = false,
    this.dataPillContent1 = '',
    this.dataPillContent2 = '',
  }) : super(key: key);

  final dynamic onPressAction;
  final IconData subtitleIcon;
  final String subtitle;
  final String title;
  final String description;
  final String dataPillContent1;
  final String dataPillContent2;
  final bool icon2x;
  final bool displayWinLossTieRecord;


  @override
  _GameModeCardState createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 8.0,
      borderOnForeground: false,
      child: Ink(
        height: 190,
        width: (MediaQuery.of(context).size.width)* .90,
        decoration: gameModeCardDecoration(),
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.red.withOpacity(0.5),
          onTap: widget.onPressAction,
          child: Container(
            padding: EdgeInsets.only(left: 24.0, right: 8.0, top: 24.0, bottom: 0.0),
            height: 175,
            width: (MediaQuery.of(context).size.width) * .90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    (widget.icon2x) ? FaIcon(widget.subtitleIcon, size: 20, color: secondaryTextColor,) : Container(),
                    FaIcon(widget.subtitleIcon, size: 20, color: secondaryTextColor,),
                    SizedBox(width: 8),
                    Text('${widget.subtitle}',
                        style:
                        Theme.of(context).textTheme.caption),
                  ],
                ),
                Row(
                  children: [
                    Text('${widget.title}', style: PrimaryStyleH5()),
                  ],
                ),
                SizedBox(height: 4),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text('${widget.description}', style: PrimaryBT1()),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Visibility(
                        visible: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DataPill(data: widget.dataPillContent1),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Visibility(
                        visible: (widget.dataPillContent2 != '') ? true : false, // hide this pill if there is no data
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DataPill(data: widget.dataPillContent2),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            /*decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                            //boxShadow1(),
                            BoxShadow(
                            color: Colors.grey.shade500,
                              offset: Offset(1,1),
                              blurRadius: 30,
                              spreadRadius: .5,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(-1,-1),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),],),*/
                            child: ElevatedButton(
                              onPressed: widget.onPressAction,
                              child: Icon(Icons.chevron_right, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8),
                                primary: secondaryColor, // <-- Button color
                                onPrimary: Colors.red, // <-- Splash color
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration gameModeCardDecoration() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0x9900528E),
          Color(0x9922283D),
        ],

      ));
}