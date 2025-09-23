import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'), // "首页" 改为英文 "Home"
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'), // "个人主页" 改为英文 "Profile"
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
