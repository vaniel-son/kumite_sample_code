import 'package:dojo_app/screens/video_player/video_split_screen_player.dart';
import 'package:flutter/material.dart';

class MatchesWatchGameScreen extends StatefulWidget {
  const MatchesWatchGameScreen({Key? key, required this.thisPlayerVideo, required this.opponentPlayerVideo}) : super(key: key);

  final String thisPlayerVideo;
  final String opponentPlayerVideo;

  @override
  _MatchesWatchGameScreenState createState() => _MatchesWatchGameScreenState();
}

class _MatchesWatchGameScreenState extends State<MatchesWatchGameScreen> {
  @override
  Widget build(BuildContext context) {
    return VideoSplitScreen(thisPlayerVideo: widget.thisPlayerVideo, opponentPlayerVideo: widget.opponentPlayerVideo);
  }
}
