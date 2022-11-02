import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:dojo_app/style/colors.dart';

class EMOMTimerCard extends StatefulWidget {
  const EMOMTimerCard({
    Key? key, required this.timer, this.size = 'average'
  }) : super(key: key);

  final int timer;
  final String size;

  @override
  State<EMOMTimerCard> createState() => _EMOMTimerCardState();
}

class _EMOMTimerCardState extends State<EMOMTimerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // set default timer font size
    Widget timerTextWidget = Text('${widget.timer}', style: GameStyleH1Bold());

    // set different font size under special circumstances
    void setTimerSize() {
      if (widget.size == 'small') {
        timerTextWidget = Text('${widget.timer}', style: GameStyleH5Bold());
      }
    }

    // set configurations for the timer card
    setTimerSize();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              // height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(6),
                ),
                color: primarySolidCardColor.withOpacity(0.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CaptionText(text: 'WORKOUT TIMER'),
                      timerTextWidget,
                      SizedBox(height:8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}