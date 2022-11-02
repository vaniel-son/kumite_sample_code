import 'package:dojo_app/constants.dart';
import 'package:dojo_app/game_modes/matches/judge_matches/screens/view_replay/view_replay_wrapper.dart';
import 'package:dojo_app/style/style_misc.dart';
import 'package:dojo_app/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';

class JudgeCard extends StatefulWidget {
  const JudgeCard({
    Key? key,
    this.avatarImage = 'images/avatar-blank.png',
    this.avatarFirstLetter = 'X',
    required this.title,
    required this.gameID,
    required this.playerOneNickname,
    required this.playerOneScore,
    required this.playerOneVideo,
    required this.playerTwoNickname,
    required this.playerTwoScore,
    required this.playerTwoVideo,
    required this.playerOneUserID,
    required this.judgeRequestID,
    required this.dateUpdated,
  }) : super(key: key);

  final String title;
  final String gameID;
  final String avatarImage;
  final String avatarFirstLetter;
  final String playerOneNickname;
  final String playerOneScore;
  final String playerOneVideo;
  final String playerTwoNickname;
  final String playerTwoScore;
  final String playerTwoVideo;
  final playerOneUserID;
  final String judgeRequestID;
  final String dateUpdated;

  @override
  _JudgeCardState createState() => _JudgeCardState();
}

class _JudgeCardState extends State<JudgeCard> {
  void redirectUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReplayWrapper(
          playerOneVideo: widget.playerOneVideo,
          playerTwoVideo: widget.playerTwoVideo,
          playerOneUserID: widget.playerOneUserID,
          gameID: widget.gameID,
          redirect: 'JudgeListWrapper()',
          userPointOfView: UserPointOfView.Judge,
          judgeRequestID: widget.judgeRequestID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map tempMap = {};
    return Card(
      child: Ink(
        decoration: judgeCardBoxDecoration(),
        child: InkWell(
          splashColor: Colors.red.withAlpha(30),
          onTap: () {
            print('tap');
            redirectUser();
          },
          child: Container(
            height: 95,
            width: 232,
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 12.0, bottom: 0.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomCircleAvatar(avatarFirstLetter: widget.playerOneNickname[0].toUpperCase(), radius: 12.0, avatarImage: widget.avatarImage),
                      SizedBox(width: 4),
                      Text(widget.playerOneNickname, style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(width: 2),
                      Text('(${widget.playerOneScore})'),
                      SizedBox(width: 8),
                      Text('vs', style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      CustomCircleAvatar(avatarFirstLetter: widget.playerTwoNickname[0].toUpperCase(), radius: 12.0, avatarImage: widget.avatarImage),
                      SizedBox(width: 4),
                      Text(widget.playerTwoNickname, style: Theme.of(context).textTheme.bodyText1),
                      SizedBox(width: 2),
                      Text('(${widget.playerTwoScore})'),
                    ],
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

BoxDecoration judgeCardBoxDecoration() {
  return BoxDecoration(
      borderRadius: borderRadius1(),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color(0xFFB31217),
          Color(0xFFE52D27),
        ],

      ));
}