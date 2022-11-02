import 'package:dojo_app/style/text_styles_v3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompetitionExpirationTimer extends StatefulWidget {
  const CompetitionExpirationTimer({Key? key, required this.expirationDateTime}) : super(key: key);

  // this time should be passed into this class as UTC
  // so that we can perform all logic and comparisons in UTC
  final DateTime expirationDateTime;

  @override
  _CompetitionExpirationTimerState createState() => _CompetitionExpirationTimerState();
}

class _CompetitionExpirationTimerState extends State<CompetitionExpirationTimer> {
  late int year = widget.expirationDateTime.year;
  late int month = widget.expirationDateTime.month;
  late int day = widget.expirationDateTime.day;
  late int hour = widget.expirationDateTime.hour;
  late int minute = widget.expirationDateTime.minute;
  late int second = widget.expirationDateTime.second;
  late int estimateTs = DateTime.utc(year, month, day, hour, minute, second).millisecondsSinceEpoch; // set needed date

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 1), (i) => i),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          DateFormat format_hh = DateFormat("HH");
          DateFormat format_mm = DateFormat("mm");
          DateFormat format_ss = DateFormat("ss");

          int now = DateTime.now().toUtc().millisecondsSinceEpoch;
          Duration remaining = Duration(milliseconds: estimateTs - now);

          var dateString = '${remaining.inDays}d ${format_hh.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds, isUtc: true))}h ${format_mm.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds, isUtc: true))}m ${format_ss.format(DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds, isUtc: true))}s';
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(dateString, style: PrimaryStyleH6()),
              ],
            ),
          );
        });
  }
}
