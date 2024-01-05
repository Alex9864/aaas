import 'package:aaas/pages/messagesList/MessageListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../home/HomePage.dart';
import '../profile/ProfilePage.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int _pageSelectedIndex = 0;

  List<Widget> _userNavigationItems = <Widget>[
    HomePage(),
    MessageListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _userNavigationItems.elementAt(_pageSelectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.messenger_outline_rounded),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
        currentIndex: _pageSelectedIndex,
        onTap: (value) => _onItemSelected(value),
      ),
    );
  }

  void _onItemSelected(int index) {
    setState(() {
      _pageSelectedIndex = index;
    });
  }

}
