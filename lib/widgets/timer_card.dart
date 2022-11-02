import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import '../style/colors.dart';

class TimerCard extends StatefulWidget {
  const TimerCard({
    Key? key, required this.timer, this.size = 'average'
  }) : super(key: key);

  final int timer;
  final String size;

  @override
  State<TimerCard> createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget timerTextWidget = Text('${widget.timer}', style: GameStyleH1Bold());

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
              width: 300,
              // height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(6),
                ),
                color: primarySolidCardColor.withOpacity(0.7),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('WORKOUT TIMER', style: PrimaryCaption1(color: onPrimaryWhite)),
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