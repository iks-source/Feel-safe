// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/main_screen_arguments.dart';
import 'package:feel_safe/Models/profile_page_arguments.dart';
import 'package:feel_safe/Models/user_data.dart';
import 'package:feel_safe/pages/add_user_group_page.dart';
import 'package:feel_safe/pages/chats_list_page.dart';
import 'package:feel_safe/pages/home_page.dart';
import 'package:feel_safe/pages/jobs_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTabIndex = 1;
  DocumentSnapshot<Map<String, dynamic>>? userData;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  var args;
  @override
  void initState() {
    super.initState();
  }

  getUserData() async {
    await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        userData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as MainScreenArguments;
      userData = args.userData;
    } else {
      if (userData == null) getUserData();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        title: const Text(
          "Feel Safe",
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
              onPressed: () {
                if (userData != null)
                  Navigator.pushNamed(context, "/FaqPage",
                      arguments: UserData(userData: userData!));
              },
              icon: const Icon(Icons.help)),
          IconButton(
              onPressed: () {
                if (userData != null)
                  Navigator.pushNamed(context, "/ProfilePage",
                      arguments: ProfilePageArguments(userData: userData));
              },
              icon: const Icon(Icons.person)),
        ],
      ),
      bottomNavigationBar: userData == null
          ? SizedBox()
          : BottomNavigationBar(
              onTap: (int index) {
                setState(() {
                  currentTabIndex = index;
                });
              },
              currentIndex: currentTabIndex,
              selectedIconTheme: IconThemeData(color: Colors.blue),
              unselectedIconTheme: IconThemeData(color: Colors.grey),
              items: _getBottomNavigationBarItems(),
            ),
      body: userData == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : currentTabIndex == 0
              ? AddUserGroupPage(
                  userData: userData,
                )
              : currentTabIndex == 1
                  ? HomePage(
                      userData: userData,
                    )
                  : currentTabIndex == 2
                      ? ChatsListPage(
                          userData: userData!,
                        )
                      : JobsPage(
                          userData: userData!,
                        ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(icon: Icon(Icons.people), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "")
    ];
  }
}
