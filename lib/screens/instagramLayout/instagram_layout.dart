import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiyatrokulubu/screens/utils/global_variables.dart';

class LayoutScreen extends StatefulWidget {
  @override
  _InstagramLayoutScreen createState() => _InstagramLayoutScreen();
}

class _InstagramLayoutScreen extends State<LayoutScreen> {
  int _page = 0;
  late PageController pageController;
  int? userType;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    fetchUserType();
  }

  Future<void> fetchUserType() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userType = userDoc['userType'];
      });
    } catch (e) {
      print("Kullanıcı tipi alınırken hata oluştu: $e");
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: userType == 1
            ? homeScreensItems
            : homeScreensItems
                .where((item) => homeScreensItems.indexOf(item) != 2)
                .toList(),
        controller: pageController,
        onPageChanged: onPageChange,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        height: MediaQuery.of(context).size.height * 0.07,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _page == 0 ? Colors.black : Colors.black26,
            ),
            label: "",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _page == 1 ? Colors.black : Colors.black26,
            ),
            label: "",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          if (userType == 1)
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle_outline,
                color: _page == 2 ? Colors.black : Colors.black26,
              ),
              label: "",
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: userType == 1
                  ? (_page == 3 ? Colors.black : Colors.black26)
                  : (_page == 2 ? Colors.black : Colors.black26),
            ),
            label: "",
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
