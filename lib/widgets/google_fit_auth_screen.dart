

/*

class GoogleFitAuthScreen extends StatelessWidget {

  const GoogleFitAuthScreen({Key? key, required this.matchDetailsMap, required this.matchDay }) : super(key: key);
  final Map matchDetailsMap;
  final String matchDay;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        title: const Text('Link to Google Fit'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
          SizedBox(height: 100),
          /*FaIcon(
            FontAwesomeIcons.solidHeart,
            size: 38,
            color: offWhiteColor,
          )*/
            Image.asset('images/GoogleFit_Icon_Color_RGB.png',height:100, width: 100,),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text('Connect Dojo to Google Fit',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18) ,
              ),
            ),
          SizedBox(height:15),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text('Google Fit is an open platform that lets you control your fitness data from multiple apps and devices.'
                ' When you connect Dojo to Google Fit, only hours slept'
                ' will be shared with us. In order to take advantage of this integration you must have the Google Fit App.'
                ' We use sleep data in our game'
                ' to promote healthy habits and recovery before strenuous exercise.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 16) ,

            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Connect to Google Fit'),
              style: ButtonStyle(textStyle:MaterialStateProperty.all(TextStyle(fontWeight: FontWeight.bold))),
              onPressed: () async {
              SleepDataService sleep = SleepDataService(gameMap: matchDetailsMap, matchDay: matchDay);
              await sleep.processSleepData();
              Navigator.pop(context);
            }
           )
         ],
        ),
      )
    );
  }
}*/
