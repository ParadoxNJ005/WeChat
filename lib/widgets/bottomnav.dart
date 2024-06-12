import 'package:flutter/material.dart';
import 'package:we_chat/screens/community_screen.dart';
import 'package:we_chat/screens/home_screen.dart';
import 'package:we_chat/screens/profile_screen.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  int selectedindex = 0;
  PageController pageController = PageController();

  void onTapped(int index) {
    setState(() {
      selectedindex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [HomeScreen(), CommunityScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
              ),
              label: 'Community'),
        ],
        currentIndex: selectedindex,
        selectedItemColor: Color.fromARGB(255, 60, 167, 239),
        unselectedItemColor: Colors.black87,
        onTap: onTapped,
        elevation: 10,
      ),
    );
  }
}
