// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostPage extends StatefulWidget {
  const JobPostPage({Key? key}) : super(key: key);

  @override
  _JobPostPageState createState() => _JobPostPageState();
}

class _JobPostPageState extends State<JobPostPage> {
  ImagePicker _imagePicker = ImagePicker();
  TextEditingController _jobTitleController = TextEditingController();
  TextEditingController _jobDetailsController = TextEditingController();
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  XFile? image;
  bool imageNotSelected = false;
  bool processing = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("FeelSafe"),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Form(
              key: _key,
              child: Column(
                children: [
                  Container(
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Title is required.";
                        }
                      },
                      controller: _jobTitleController,
                      decoration: new InputDecoration(
                        border: new OutlineInputBorder(),
                        hintText: 'Add job Title...',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Description is required.";
                        }
                      },
                      controller: _jobDetailsController,
                      maxLines: 12,
                      decoration: new InputDecoration(
                        border: new OutlineInputBorder(),
                        hintText: 'Add job details...',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        image == null
                            ? "Add company picture"
                            : image!.name.length > 20
                                ? image!.name.substring(0, 18) + "..."
                                : image!.name,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: size.width * 0.05),
                      RaisedButton(
                        onPressed: processing
                            ? null
                            : () async {
                                try {
                                  await _imagePicker
                                      .pickImage(source: ImageSource.gallery)
                                      .then((value) {
                                    if (value != null) {
                                      setState(() {
                                        image = value;
                                      });
                                    }
                                  });
                                } catch (e) {
                                  Fluttertoast.showToast(
                                      msg: "Unknown Error. Try Again.");
                                }
                              },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0.0,
                        color: Colors.pink[100],
                        padding: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        textColor: Colors.black,
                        child: Text("Choose file",
                            style: TextStyle(
                              fontSize: 18,
                            )),
                      ),
                    ],
                  ),
                  imageNotSelected
                      ? Text(
                          "Choose one image.",
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  RaisedButton(
                    onPressed: processing
                        ? null
                        : () async {
                            setState(() {
                              imageNotSelected = image == null;
                            });
                            if (_key.currentState!.validate() &&
                                !imageNotSelected) {
                              setState(() {
                                processing = true;
                              });
                              try {
                                await _storage
                                    .ref(image!.name)
                                    .putFile(File(image!.path))
                                    .then((p0) async {
                                  _firestore.collection('jobs').add({
                                    'title': _jobTitleController.text,
                                    'description': _jobDetailsController.text,
                                    'imageUrl': await p0.ref.getDownloadURL(),
                                    'applicants': []
                                  });
                                }).whenComplete(() {
                                  Navigator.pop(context);
                                });
                              } catch (e) {
                                setState(() {
                                  processing = false;
                                });
                                print(e.toString());
                                Fluttertoast.showToast(
                                    msg: "Unknown Error. Try Again");
                              }
                            }
                          },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.pink[100],
                    padding: EdgeInsets.only(
                        left: 70.0, right: 70.0, top: 10.0, bottom: 10.0),
                    textColor: Colors.black,
                    child: Text("Post", style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
