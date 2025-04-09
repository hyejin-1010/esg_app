import 'package:esg_app/screens/feed.dart';
import 'package:esg_app/screens/find.dart';
import 'package:esg_app/screens/map.dart';
import 'package:esg_app/screens/mission.dart';
import 'package:esg_app/screens/mypage.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Widget> _screens = <Widget>[
    FeedScreen(),
    MissionScreen(),
    MapScreen(),
    FindScreen(),
    MyPageScreen(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottom navigation 선언
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '미션'),
          BottomNavigationBarItem(icon: Icon(Icons.location_city), label: '맵'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: '발견'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '마이페이지'),
        ],
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // 지정 인덱스로 이동
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: TextStyle(color: Colors.black),
        onTap: _onItemTapped, // 선언했던 onItemTapped
      ),

      body: SafeArea(child: _screens.elementAt(_selectedIndex)),
    );
  }
}
