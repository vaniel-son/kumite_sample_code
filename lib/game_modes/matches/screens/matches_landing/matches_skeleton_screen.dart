import 'package:dojo_app/game_modes/matches/screens/matches_landing/matches_screen.dart';
import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MatchesSkeletonScreen extends StatefulWidget {
  @override
  _MatchesSkeletonScreenState createState() => _MatchesSkeletonScreenState();
}

class _MatchesSkeletonScreenState extends State<MatchesSkeletonScreen> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    Menu(),
    MatchesScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void onPressAction(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: primarySolidCardColor,
        onTap: onPressAction,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        unselectedItemColor: primaryDojoColorLighter,
        selectedItemColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.layerGroup, size: 20),
            label: 'Matches',
          ),
        ],
      ),
    );
  }
}
