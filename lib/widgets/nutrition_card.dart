import 'dart:collection';
import 'package:dojo_app/game_modes/matches/screens/food_image_capture/capture_food_image.dart';
import 'package:collection/collection.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'circle_avatar.dart';
import 'package:intl/intl.dart';
import 'package:dojo_app/constants.dart' as constants;

class NutritionCard extends StatelessWidget {
  const NutritionCard({Key? key, required this.matchDetailsMap}) : super(key: key);
  final Map matchDetailsMap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width) * .90,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
      padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
      decoration: BoxDecoration(
        color: primaryTransparentCardColor,
        borderRadius: borderRadius1(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.utensilSpoon,
                  size: 16,
                  color: offWhiteColor,
                ),
                SizedBox(width: 8),
                Text('Nutrition', style: Theme.of(context).textTheme.headline6),
              ],
            ),
          ),
          SizedBox(height: 8),
          Divider(height: 1.0, thickness: 1.0, indent: 0.0),
          displayFoodPictures(matchDetailsMap, context),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: displayEmojiBoxMatchStart(matchDetailsMap, context),
          ),
        ],
      ),
    );
  }
}

/// ***********************************************************************
/// ***********************************************************************
/// Functions for Widgets
/// ***********************************************************************
/// ***********************************************************************

Map<dynamic, List<Map<String, dynamic>>> foodListMapConvert(Map matchDetailsMap) {
  var firebaseFoodList = List<Map<String, dynamic>>.from(matchDetailsMap['playerFoodPics']);
  List<Map<String, dynamic>> dataSet2 = [];
  for (var i = 0; i < firebaseFoodList.length; i++) {
    String dateTime = DateTime.parse(firebaseFoodList[i]['dateTime'].toDate().toString()).toString();
    String downloadURL = firebaseFoodList[i]['downloadURL'];
    String foodDescription = firebaseFoodList[i]['foodDescription'];
    String nickname = firebaseFoodList[i]['nickname'];
    String userID = firebaseFoodList[i]['userID'];

    var foodListRaw = [
      {
        "dateTime": dateTime,
        "downloadURL": downloadURL,
        "foodDescription": foodDescription,
        "nickname": nickname,
        "userID": userID
      }
    ];

    //Add this to the dataset to be used for the feed.
    dataSet2.add(foodListRaw[0]);
  }
  var groupByDate = groupBy(dataSet2, (Map obj) => obj['dateTime'].substring(0, 10));
  return groupByDate;
}


/// ***********************************************************************
/// ***********************************************************************
/// Dynamic Widget Methods
/// ***********************************************************************
/// ***********************************************************************

/// Display the message and corresponding emoji
Widget emojiMessage(String emoji, String message, BuildContext context) {
  return Container(
    padding: EdgeInsets.all(10),
    color: Colors.red,
    child: Row(children: <Widget>[
      Container(
        constraints: BoxConstraints(maxWidth: (MediaQuery.of(context).size.width) * .75),
        padding: EdgeInsets.all(10),
        color: Colors.red,
        child: Row(children: <Widget>[
          Text(emoji, style: TextStyle(fontSize: 30)),
          SizedBox(
            width: 8,
          ),
          Flexible(child: Text(message))
        ]),
      ),
    ]),
  );
}


Widget displayEmojiBoxMatchStart(Map matchDetailsMap, BuildContext context) {
  if (matchDetailsMap['playerFoodPics'].length == 0) {
    return Column(
      children: <Widget>[
        emojiContainer('😭', matchDetailsMap['opponentPlayer']['playerNickname'], context),
        emojiContainer('😭', matchDetailsMap['thisPlayer']['playerNickname'], context)
      ],
    );
  } else if (matchDetailsMap['playerFoodPics'].length == 1) {
    return Container();
  } else if (matchDetailsMap['playerFoodPics'].length == 2) {
    return Container();
  } else {
    return Container();
  }
}

Widget displayEmojiBoxInFeed(Map matchDetailsMap, BuildContext context,var sortedDataFeed, int index) {
  if (sortedDataFeed[sortedDataFeed.keys.elementAt(index)].length == 2) {
    return Container();
  } else if (sortedDataFeed[sortedDataFeed.keys.elementAt(index)].length == 1) {
    if (sortedDataFeed[sortedDataFeed.keys.elementAt(index)][0]['userID'] == matchDetailsMap['userID']) {
      return emojiContainer('😭', matchDetailsMap['opponentPlayer']['playerNickname'], context);
    } else {
      return emojiContainer('😭', matchDetailsMap['thisPlayer']['playerNickname'], context);
    }
  } else {
    return Container();
  }
}

/// Add food image button
Widget addFoodImageButton(Map matchDetailsMap, BuildContext context) {
  return Column(children: <Widget>[
    // Divider(height: 1.0, thickness: 1.0, indent: 0.0),
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
          Flexible(
            child: Text(
              'Share healthy food you’re eating today.',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          IconButton(
              onPressed: () {
                takeFoodPicButtonAction(matchDetailsMap, context);
              },
              icon: Icon(Icons.add_circle, color: Colors.red, size: 40))
        ],
      ),
    ),
    SizedBox(height: 8),
  ]);
}

/// Determine whether to display the add food image button
Widget determineDisplayingFoodImageButton(Map matchDetailsMap, BuildContext context) {
  if (matchDetailsMap['gameStatus'] == constants.cGameStatusOpen) {
    if (matchDetailsMap['playerFoodPics'].length == 2) {
      return Container();
    } else if (matchDetailsMap['playerFoodPics'].length == 0) {
      return addFoodImageButton(matchDetailsMap, context);
    } else if (matchDetailsMap['playerFoodPics'][0]['userID'] == matchDetailsMap['userID']) {
      return Container();
    } else {
      return addFoodImageButton(matchDetailsMap, context);
    }
  } else {
    return Container();
  }
}



Widget displayFoodPictures(Map matchDetailsMap, BuildContext context) {
  var initialDataFeed = foodListMapConvert(matchDetailsMap);
  var sortedDataFeed = LinkedHashMap.fromEntries(initialDataFeed.entries.toList().reversed);

  return Container(
    height: (matchDetailsMap['playerFoodPics'].length.toDouble() * 300) + (sortedDataFeed.length * 50)+
        (((sortedDataFeed.length*2)-matchDetailsMap['playerFoodPics'].length)*300),
    width: MediaQuery.of(context).size.width,
    child: ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: sortedDataFeed.length,
      itemBuilder: (context, index1) => Column(children: <Widget>[
        Container(
            height: 50,
            child: Center(child: Text(DateFormat('EEEE').format(DateTime.parse(sortedDataFeed.keys.elementAt(index1)))))),
        ListView.builder(
          shrinkWrap: true,
            itemCount: sortedDataFeed[sortedDataFeed.keys.elementAt(index1)]!.length,
            itemBuilder: (context, index2) =>
                Stack(children: <Widget>[
                  Container(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(sortedDataFeed[sortedDataFeed.keys.elementAt(index1)]?[index2]['downloadURL'],
                        fit: BoxFit.fitWidth),
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      color: primaryTransparentCardColor,
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            CustomCircleAvatar(
                              avatarImage: 'images/avatar-blank.png',
                              radius: 16,
                              avatarFirstLetter: sortedDataFeed[sortedDataFeed.keys.elementAt(index1)]?[index2]['nickname'][0],
                            ),
                            SizedBox(width: 8),
                            Flexible(child: Text('${(sortedDataFeed[sortedDataFeed.keys.elementAt(index1)]?[index2]['nickname']).toUpperCase()}')),
                          ],
                        ),
                      ),
                    ),
                  ),
                 ]
                ),
        ),
        displayEmojiBoxInFeed(matchDetailsMap,context,sortedDataFeed,index1)
      ]),
    ),
  );
}

///Emoji container
Widget emojiContainer(String emoji, String nickname, BuildContext context) {
  return DottedBorder(
    color: Color(0xffADB0FF),
    strokeWidth: 1,
    dashPattern: [2, 5],
    child: Container(
      height: 300,
      //margin: EdgeInsets.all(20),
      color: primaryTransparentCardColor,
      child: Stack(children: <Widget>[
        Center(child: Text(emoji, style: TextStyle(fontSize: 48))),
        Positioned(
          bottom: 0,
          child: Container(
            color: primaryTransparentCardColor,
            height: 60,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 16, left: 8),
            child: Row(
              children: [
                CustomCircleAvatar(
                  avatarImage: 'images/avatar-blank.png',
                  radius: 16,
                  avatarFirstLetter: nickname[0].toUpperCase(),
                ),
                SizedBox(width: 8),
                Text('${nickname.toUpperCase()} has not posted yet'),
              ],
            ),
          ),
        ),
      ]),
    ),
  );
}

takeFoodPicButtonAction(Map matchDetailsMap, BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CaptureFoodImage(
                matchDetailsMap: matchDetailsMap,
              )));
}
