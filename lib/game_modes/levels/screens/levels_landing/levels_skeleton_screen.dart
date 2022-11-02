import 'package:dojo_app/screens/menu/menu_screen.dart';
import 'package:dojo_app/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'levels_selection.dart';

class LevelsSkeletonScreen extends StatefulWidget {
  @override
  _LevelsSkeletonScreenState createState() => _LevelsSkeletonScreenState();
}

class _LevelsSkeletonScreenState extends State<LevelsSkeletonScreen> {
  int _currentIndex = 1;
  final List<Widget> _children = [
    Menu(),
    LevelSelection(),
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
            label: 'Levels',
          ),
        ],
      ),
    );
  }
}
