import 'package:dojo_app/game_modes/king_of_the_hill/models/player_records_model_KOH.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/data_pill.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChart extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LineChart({Key? key, required this.playerRecords, required this.title}) : super(key: key);
  final PlayerRecordsModelKOH playerRecords;
  final String title;

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<_ScoresData> scoresData = [];
  int personalRecord = 0;

  @override
  void initState() {
    super.initState();
    buildScoreData(widget.playerRecords.scoresOverTime);
    personalRecord = widget.playerRecords.personalRecord;
  }

  /// Store date and scores in object
  void buildScoreData(playerData) {
    for (var i = 0; i < playerData.length; i++) {
      if (playerData[i]['score'] != null) {
        DateTime date = playerData[i]['dateTime'].toDate();
        int reps = playerData[i]['score'];
        scoresData.add(_ScoresData('${date.month}/${date.day}', reps));
      }

    }
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        width: (MediaQuery.of(context).size.width) * .90,
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
        decoration: BoxDecoration(
          color: primaryTransparentCardColor,
          borderRadius: borderRadius1(),
        ),
        child: Column(
          children: [
            //Initialize the chart widget
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: '${widget.title}', textStyle: Theme.of(context).textTheme.caption, alignment: ChartAlignment.near, borderWidth: 6),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<_ScoresData, String>>[
                LineSeries<_ScoresData, String>(
                  dataSource: scoresData,
                  xValueMapper: (_ScoresData scores, _) => scores.date,
                  yValueMapper: (_ScoresData scores, _) => scores.reps,
                  name: 'Pushups',
                  // Enable data label
                  dataLabelSettings: DataLabelSettings(isVisible: false),
                  isVisibleInLegend: false,
                )
              ],
            ),
            DataPill(data: '  Personal Record: $personalRecord  '),
          ],
        ),
      );
  }
}

class _ScoresData {
  _ScoresData(this.date, this.reps);

  final String date;
  final int reps;
}
