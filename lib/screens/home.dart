import 'package:esg_app/screens/feed.dart';
import 'package:esg_app/screens/find.dart';
import 'package:esg_app/screens/map.dart';
import 'package:esg_app/screens/mission.dart';
import 'package:esg_app/screens/mypage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        selectedLabelStyle: TextStyle(fontSize: 12.0),
        unselectedLabelStyle: TextStyle(fontSize: 12.0, color: Colors.black),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/footer/ic_home.png', width: 20.0),
            activeIcon: Image.asset(
              'assets/icon/footer/ic_home_active.png',
              width: 20.0,
            ),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/footer/ic_mission.png', width: 20.0),
            activeIcon: Image.asset(
              'assets/icon/footer/ic_mission_active.png',
              width: 20.0,
            ),
            label: '미션',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/footer/ic_map.png', width: 20.0),
            activeIcon: Image.asset(
              'assets/icon/footer/ic_map_active.png',
              width: 20.0,
            ),
            label: '맵',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icon/footer/ic_discovery.png',
              width: 20.0,
            ),
            activeIcon: Image.asset(
              'assets/icon/footer/ic_discovery_active.png',
              width: 20.0,
            ),
            label: '발견',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/footer/ic_my.png', width: 20.0),
            activeIcon: Image.asset(
              'assets/icon/footer/ic_my.png',
              width: 20.0,
            ),
            label: '마이페이지',
          ),
        ],
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // 지정 인덱스로 이동
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped, // 선언했던 onItemTapped
      ),

      body: SafeArea(child: _screens.elementAt(_selectedIndex)),
    );
  }
}
