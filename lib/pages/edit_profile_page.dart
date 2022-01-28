// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:feel_safe/Models/main_screen_arguments.dart';
import 'package:feel_safe/Models/profile_page_arguments.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const EditProfilePage({Key? key, required this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String? _maritalStatus;
  String? gender;
  List<String> maritalStatusItems = ['Single', 'Married'];
  List<String> genderItems = ['Male', 'Female', 'Other'];
  TextEditingController _religionController = TextEditingController();
  TextEditingController _contactNameController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  XFile? _image;
  bool askForProfilePicture = false;
  bool _emailAlreadyInuse = false;
  bool _invalidEmail = false;
  bool _weakPassword = false;
  String? imageName;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  ImagePicker _imagePicker = ImagePicker();
  FirebaseStorage _storage = FirebaseStorage.instance;
  TaskSnapshot? _snapshot;
  bool processRunning = false;
  @override
  void initState() {
    _emailController.text = widget.userData['email'];
    _firstNameController.text = widget.userData['firstName'];
    _lastNameController.text = widget.userData['lastName'];
    gender = widget.userData['gender'];
    _maritalStatus = widget.userData['maritalStatus'];
    _religionController.text = widget.userData['religion'];
    _contactNameController.text = widget.userData['contactName'];
    _contactNumberController.text = widget.userData['contactNumber'];
    _addressController.text = widget.userData['address'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Register",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FeelSafe",
                  style: GoogleFonts.lato(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                    //fontFamily: GoogleFonts.marvel(color: Colors.black)
                    //fontFamily: "DancingScript"
                  ),
                ),
                SizedBox(height: 30.0),
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
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              } else if (_invalidEmail) {
                                return "Email is invalid";
                              } else if (_emailAlreadyInuse) {
                                return "Email is already in use";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value!.isNotEmpty) {
                                if (value.length < 7) {
                                  return "Password length must be greater than 6 characters.";
                                } else if (_weakPassword) {
                                  return "Password is weak. Please try a stronger password";
                                }
                              }
                            },
                            obscureText: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "First name",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _firstNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Last name",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _lastNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Address",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _addressController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Gender",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: DropdownButtonFormField<String>(
                            value: gender,
                            hint: Text('Gender'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                gender = value;
                              });
                            },
                            items: genderItems
                                .map((e) => DropdownMenuItem<String>(
                                      child: Text(e),
                                      value: e,
                                    ))
                                .toList(),
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Text(
                          "Religion",
                          style: TextStyle(fontSize: 22.0),
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _religionController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Column(
                          children: [
                            Text(
                              "Marital",
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              "status",
                              style: TextStyle(fontSize: 22.0),
                            ),
                          ],
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: DropdownButtonFormField<String>(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            hint: Text('Marital Status'),
                            value: _maritalStatus,
                            items: maritalStatusItems
                                .map((String e) => DropdownMenuItem<String>(
                                      child: Text(e),
                                      value: e,
                                    ))
                                .toList(),
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                            onChanged: (value) {
                              setState(() {
                                _maritalStatus = value;
                              });
                            },
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Column(
                          children: [
                            Text(
                              "Contact",
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              "name",
                              style: TextStyle(fontSize: 22.0),
                            ),
                          ],
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _contactNameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Column(
                          children: [
                            Text(
                              "Contact",
                              style: TextStyle(fontSize: 22.0),
                            ),
                            Text(
                              "number",
                              style: TextStyle(fontSize: 22.0),
                            ),
                          ],
                        ),
                        SizedBox(width: 70.0),
                        SizedBox(
                          child: TextFormField(
                            controller: _contactNumberController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Field is required.";
                              }
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                //hintText: 'Enter a search term'
                                fillColor: Colors.black),
                          ),
                          width: 170.0,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        Container(
                          width: size.width * .7,
                          child: Text(
                            imageName != null
                                ? (imageName!.length > 25
                                    ? imageName!.substring(0, 25) + "..."
                                    : imageName!)
                                : "Add profile picture",
                            style: TextStyle(fontSize: 22.0),
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              _image = await _imagePicker.pickImage(
                                  source: ImageSource.gallery, imageQuality: 1);
                              setState(() {
                                imageName = _image!.name;
                              });
                            },
                            icon: Icon(
                              Icons.upload_file_rounded,
                              //size: 22.0,
                            ),
                            iconSize: 36.0)
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                askForProfilePicture
                    ? Text(
                        'Upload a profile picture.',
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(),

                // // ignore: deprecated_member_use, missing_required_param
                // RaisedButton(
                //   onPressed: () async {
                //     //   if (_formkey.currentState.validate()) {}
                //     //   login();
                //   },
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(15.0),
                //   ),
                //   color: Colors.grey[400],
                //   padding: EdgeInsets.only(
                //       left: 100.0, right: 100.0, top: 12.0, bottom: 12.0),
                //   textColor: Colors.black,
                //   child: Text("Choose File", style: TextStyle(fontSize: 20)),
                // ),
                SizedBox(height: 40.0),
                // ignore: deprecated_member_use, missing_required_param
                RaisedButton(
                  disabledColor: Colors.pink[100],
                  onPressed: processRunning
                      ? null
                      : () async {
                          setState(() {
                            _weakPassword = false;
                            _invalidEmail = false;
                            _emailAlreadyInuse = false;
                            askForProfilePicture = false;
                          });
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              processRunning = true;
                            });
                            try {
                              if (_emailController.text !=
                                  widget.userData['email'])
                                await _auth.currentUser!
                                    .updateEmail(_emailController.text);
                              if (_passwordController.text.isNotEmpty) {
                                await _auth.currentUser!
                                    .updatePassword(_passwordController.text);
                              }
                              if (_passwordController.text.isNotEmpty) {}
                              if (_image != null) {
                                await _storage
                                    .ref(_image!.name)
                                    .child('')
                                    .putFile(File(_image!.path))
                                    .then((p0) {
                                  setState(() {
                                    _snapshot = p0;
                                  });
                                });

                                String url =
                                    await _snapshot!.ref.getDownloadURL();
                                await _firebaseFirestore
                                    .collection("users")
                                    .doc(_auth.currentUser!.uid)
                                    .update({
                                  "email": _emailController.text,
                                  "firstName": _firstNameController.text,
                                  "lastName": _lastNameController.text,
                                  "fullName": _firstNameController.text +
                                      " " +
                                      _lastNameController.text,
                                  "gender": gender,
                                  "maritalStatus": _maritalStatus,
                                  "address": _addressController.text,
                                  "contactName": _contactNameController.text,
                                  "religion": _religionController.text,
                                  "contactNumber":
                                      _contactNumberController.text,
                                  "imageUrl": url,
                                }).then((value) async {
                                  final _userData = await _firebaseFirestore
                                      .collection('users')
                                      .doc(_auth.currentUser!.uid)
                                      .get();
                                  Navigator.of(context).pushReplacementNamed(
                                      "/MainScreen",
                                      arguments: MainScreenArguments(
                                          userData: _userData));
                                });
                              } else {
                                await _firebaseFirestore
                                    .collection("users")
                                    .doc(_auth.currentUser!.uid)
                                    .update({
                                  "email": _emailController.text,
                                  "firstName": _firstNameController.text,
                                  "lastName": _lastNameController.text,
                                  "fullName": _firstNameController.text +
                                      " " +
                                      _lastNameController.text,
                                  "gender": gender,
                                  "maritalStatus": _maritalStatus,
                                  "address": _addressController.text,
                                  "contactName": _contactNameController.text,
                                  "religion": _religionController.text,
                                  "contactNumber":
                                      _contactNumberController.text,
                                }).then((value) async {
                                  final _userData = await _firebaseFirestore
                                      .collection('users')
                                      .doc(_auth.currentUser!.uid)
                                      .get();
                                  Navigator.of(context).pushReplacementNamed(
                                      "/MainScreen",
                                      arguments: MainScreenArguments(
                                          userData: _userData));
                                });
                              }
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                processRunning = false;
                              });

                              switch (e.code) {
                                case "email-already-in-use":
                                  setState(() {
                                    _emailAlreadyInuse = true;
                                  });
                                  _formKey.currentState!.validate();
                                  break;
                                case "invalid-email":
                                  setState(() {
                                    _invalidEmail = true;
                                  });
                                  _formKey.currentState!.validate();
                                  break;
                                case "weak-password":
                                  setState(() {
                                    _weakPassword = true;
                                  });
                                  _formKey.currentState!.validate();
                                  break;
                                case "requires-recent-login":
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: Text(
                                              "You need to logout and login to again to be able to make these changes"),
                                          actions: [
                                            OutlinedButton(
                                              onPressed: () async {
                                                try {
                                                  await FirebaseAuth.instance
                                                      .signOut()
                                                      .then((value) {
                                                    Navigator.of(context)
                                                        .pushReplacementNamed(
                                                            "/SignInPage");
                                                  });
                                                } catch (e) {
                                                  print(e.toString());
                                                  Fluttertoast.showToast(
                                                      msg: "Unkown Error");
                                                }
                                              },
                                              child: Text('LogOut'),
                                            ),
                                            OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Cancel'))
                                          ],
                                        );
                                      });
                                  break;
                              }
                            } catch (e) {
                              setState(() {
                                processRunning = false;
                              });
                              print(e.toString());
                              Fluttertoast.showToast(
                                  msg: "Unknown Error. Please Try again");
                            }
                          } else {
                            setState(() {
                              askForProfilePicture = true;
                            });
                          }
                        },
                  color: Colors.pink[100],
                  padding: EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 20.0, bottom: 20.0),
                  textColor: Colors.black,
                  child: processRunning
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text("Save Changes", style: TextStyle(fontSize: 22)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
