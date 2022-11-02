
//import 'package:health/health.dart';



/*

class SleepCard extends StatelessWidget {
  const SleepCard({Key? key, required this.matchDetailsMap,}) : super(key: key);

  final Map matchDetailsMap;


  @override
  Widget build(BuildContext context) {
      return Container(
        width: (MediaQuery
            .of(context)
            .size
            .width) * .90,
        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
        padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
        decoration: BoxDecoration(
          color: primaryTransparentCardColor,
          borderRadius: borderRadius1(),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  FaIcon(
                    FontAwesomeIcons.heart,
                    size: 16,
                    color: offWhiteColor,
                  ),
                  SizedBox(width: 8),
                  Text('Sleep (hours:minutes)', style: Theme
                      .of(context)
                      .textTheme
                      .headline6),
                  Expanded(child: SizedBox())
                ],
              ),
            ),
            SizedBox(height: 8),
            Divider(height: 1.0, thickness: 1.0, indent: 0.0),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                //Sleep Days
                Column(
                  children: [
                    FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text('Days',
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption)),
                    Container(
                      height: matchDetailsMap['matchSleepDays'].length.toDouble() *
                          25,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * .20,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: matchDetailsMap['matchSleepDays'].length,
                        itemBuilder: (context, index) =>
                            Column(
                              children: <Widget>[
                                SizedBox(height: 2),
                                FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                        matchDetailsMap['sleepData'][matchDetailsMap['userID']][index]['sleepDayRange']
                                            .toUpperCase(),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline4)),

                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                // First Player Scores
                Column(
                  children: [
                    FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                            matchDetailsMap['thisPlayer']['playerNickname']
                                .toUpperCase(),
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption)),
                    Container(
                      height: matchDetailsMap['matchSleepDays'].length.toDouble() *
                          25,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * .20,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: matchDetailsMap['matchSleepDays'].length,
                        itemBuilder: (context, index) =>
                            Column(
                              children: <Widget>[
                                FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                        matchDetailsMap['sleepData'][matchDetailsMap['userID']][index]['displayValue']
                                            .toUpperCase(),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline4)),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                //Opponent Scores
                Column(
                  children: [
                    FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                            matchDetailsMap['opponentPlayer']['playerNickname']
                                .toUpperCase(),
                            style: Theme
                                .of(context)
                                .textTheme
                                .caption)),
                    Container(
                      height: matchDetailsMap['matchSleepDays'].length.toDouble() *
                          25,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * .20,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: matchDetailsMap['matchSleepDays'].length,
                        itemBuilder: (context, index) =>
                            Column(
                              children: <Widget>[
                                FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                        matchDetailsMap['sleepData'][matchDetailsMap['opponentPlayer']['userID']][index]['displayValue']
                                            .toUpperCase(),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline4)),
                              ],
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 16,
                )
              ]),
            )
          ],
        ),
      );
    }
  }



///Add sleep data button. This calls the sleep service class.

Widget addSleepData(Map matchDetailsMap,String matchDay, BuildContext context) {
  return Column(children: <Widget>[
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
    SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
          ),
          SizedBox(
            width: 16,
          ),
          FaIcon(
            FontAwesomeIcons.solidHeart,
            size: 16,
            color: offWhiteColor,
          ),
          SizedBox(width:16),
          Text(
            'Share your sleep hours.',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Expanded(child:SizedBox()),
          IconButton(
              onPressed: () {
                SleepDataService sleep = SleepDataService(gameMap: matchDetailsMap, matchDay: matchDay);
                sleep.processSleepData();
              },
              icon: Icon(Icons.add_circle, color: Colors.red, size: 40))
        ],
      ),
    ),
    SizedBox(height: 8),
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
  ]);
}

Widget connectToGoogleFit(Map matchDetailsMap,String matchDay, BuildContext context) {
  return Column(children: <Widget>[
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
    SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
          ),
          SizedBox(
            width: 16,
          ),
          FaIcon(
            FontAwesomeIcons.solidHeart,
            size: 16,
            color: offWhiteColor,
          ),
          SizedBox(width:16),
          Text(
            'Connect to Google Fit.',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Expanded(child:SizedBox()),
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GoogleFitAuthScreen(matchDetailsMap: matchDetailsMap,matchDay: matchDay,)));
              },
              icon: Icon(Icons.add_circle, color: Colors.red, size: 40))
        ],
      ),
    ),
    SizedBox(height: 8),
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
  ]);
}

Widget disconnectFromGoogleFit(BuildContext context) {
  return Column(children: <Widget>[
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
    SizedBox(height: 10),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('images/avatar-host-Sensei.png'),
          ),
          SizedBox(
            width: 16,
          ),
          FaIcon(
            FontAwesomeIcons.solidHeart,
            size: 16,
            color: offWhiteColor,
          ),
          SizedBox(width:16),
          Text(
            'Disconnect from Google Fit',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          Expanded(child:SizedBox()),
          IconButton(
              onPressed: () async {
                List<HealthDataType> types = [
                  HealthDataType.SLEEP_ASLEEP,
                  //HealthDataType.SLEEP_AWAKE,
                  //HealthDataType.SLEEP_IN_BED
                ];
                bool? hasPermission = await HealthFactory.hasPermissions(types);

                print(hasPermission);

              },
              icon: Icon(Icons.add_circle, color: Colors.red, size: 40))
        ],
      ),
    ),
    SizedBox(height: 8),
    Divider(height: 1.0, thickness: 1.0, indent: 0.0),
  ]);
}
*/
