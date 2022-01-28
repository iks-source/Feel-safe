// ignore_for_file: prefer_const_constructors

import 'package:feel_safe/Models/main_screen_arguments.dart';
import 'package:feel_safe/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool circular = false;
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool invalidEmail = false;
  bool wrongPassword = false;
  bool userNotFound = false;
  bool userDisabled = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
          child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FeelSafe",
                  style: GoogleFonts.actor(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.0),
                Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: size.width * .15),
                        SizedBox(
                          width: size.width * .6,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Email is required.";
                              } else if (invalidEmail) {
                                return "Email Invalid";
                              } else if (userNotFound) {
                                return "No user found with this email";
                              } else if (userDisabled) {
                                return "This Account has been disabled";
                              }
                            },
                            controller: email,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        //     SizedBox(width: size.width * .01),
                        SizedBox(
                          child: TextFormField(
                            controller: password,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Password is required";
                              } else if (wrongPassword) {
                                return "Password Incorrect";
                              }
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: size.width * .6,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                // ignore: deprecated_member_use, missing_required_param
                RaisedButton(
                  disabledColor: Colors.pink[100],
                  onPressed: circular
                      ? null
                      : () async {
                          setState(() {
                            wrongPassword = false;
                            invalidEmail = false;
                            userDisabled = false;
                            userNotFound = false;
                          });
                          if (_key.currentState!.validate()) {
                            setState(() {
                              circular = true;
                            });
                            try {
                              UserCredential _user =
                                  await _auth.signInWithEmailAndPassword(
                                      email: email.text,
                                      password: password.text);
                              final _userData = await _firestore
                                  .collection('users')
                                  .doc(_user.user!.uid)
                                  .get();
                              if (_userData.data() != null) {
                                Navigator.of(context).pushReplacementNamed(
                                    "/MainScreen",
                                    arguments: MainScreenArguments(
                                        userData: _userData));
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          content:
                                              Text("This account is disabled."),
                                        ));
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                circular = false;
                              });
                              switch (e.code) {
                                case "invalid-email":
                                  setState(() {
                                    invalidEmail = true;
                                  });
                                  _key.currentState!.validate();
                                  break;
                                case "user-disabled":
                                  setState(() {
                                    userDisabled = true;
                                  });
                                  _key.currentState!.validate();
                                  break;
                                case "wrong-password":
                                  setState(() {
                                    wrongPassword = true;
                                  });
                                  _key.currentState!.validate();
                                  break;
                                case "user-not-found":
                                  setState(() {
                                    userNotFound = true;
                                  });
                                  _key.currentState!.validate();
                              }
                            } catch (e) {
                              setState(() {
                                circular = false;
                              });
                              Fluttertoast.showToast(
                                  msg: "Unknown Error.Please Try again.");
                            }
                          }
                        },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.pink[100],
                  padding: EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 12.0, bottom: 12.0),
                  textColor: Colors.black,
                  child: circular
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text("Login", style: TextStyle(fontSize: 22)),
                  elevation: 0.0,
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBDC2CB),
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SignUpPage()));
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void check_if_already_loggedIn() async {
  //   logindata = await SharedPreferences.getInstance();
  //   newuser = (logindata.getBool('login') ?? true);
  //   if (newuser == false) {
  //     Navigator.pushReplacement(
  //         context, MaterialPageRoute(builder: (context) => MyApp()));
  //   }
  // }
}
