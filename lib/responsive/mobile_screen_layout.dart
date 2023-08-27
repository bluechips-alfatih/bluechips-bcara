import 'package:b_cara/resources/auth_methods.dart';
import 'package:flutter/material.dart';
import 'package:b_cara/utils/colors.dart';
import 'package:b_cara/utils/global_variable.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key}) : super(key: key);

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout>
    with WidgetsBindingObserver {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        AuthMethods().setUserState(true);
        debugPrint("adads");
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        AuthMethods().setUserState(false);
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.amber.shade700,
        buttonBackgroundColor: Colors.blue.shade700,
        backgroundColor: Colors.white70,
        items: <Widget>[
          Icon(Icons.home, color: (_page == 0) ? primaryColor : Colors.black),
          Icon(Icons.search, color: (_page == 1) ? primaryColor : Colors.black),
          Text("NU",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (_page == 2) ? primaryColor : Colors.black)),
          // Icon(Icons.star, color: (_page == 2) ? primaryColor : Colors.black),
          Icon(Icons.video_camera_front_rounded,
              color: (_page == 3) ? primaryColor : Colors.black),
          Icon(Icons.person, color: (_page == 4) ? primaryColor : Colors.black),
        ],
        onTap: navigationTapped,
        index: _page,
      ),
    );
  }
}
