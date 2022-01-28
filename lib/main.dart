import 'package:feel_safe/pages/chat_page.dart';
import 'package:feel_safe/pages/faq_page.dart';

import 'package:feel_safe/pages/job_post_page.dart';
import 'package:feel_safe/pages/post_new_faq.dart';
import 'package:feel_safe/pages/post_page.dart';
import 'package:feel_safe/pages/profile_page.dart';
import 'package:feel_safe/pages/user_signin_page.dart';
import 'package:feel_safe/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  FirebaseAuth _auth = FirebaseAuth.instance;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          actionsIconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      routes: {
        "/ProfilePage": (context) => ProfilePage(),
        "/ChatPage": (context) => ChatPage(),
        "/MainScreen": (context) => MainScreen(),
        "/SignInPage": (context) => SignInPage(),
        "/PostPage": (context) => PostPage(),
        "/PostJob": (context) => JobPostPage(),
        "/FaqPage": (context) => FaqPage(),
        "/PostNewFaq": (context) => PostNewFAQ(),
      },
      home: _auth.currentUser == null ? SignInPage() : MainScreen(),
    );
  }
}
