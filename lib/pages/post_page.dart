// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  ImagePicker _imagePicker = ImagePicker();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _controller = TextEditingController();
  TextEditingController _donationAmountController = TextEditingController();
  List<XFile>? _images;
  bool processing = false;
  List<String> items = <String>['NEWS Feed Post', 'Donation Post'];
  String? dropDownValue;

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
            child: Column(
              children: [
                Container(
                  child: DropdownButtonFormField<String>(
                      hint: Text('Select a post type.'),
                      onChanged: (value) {
                        setState(() {
                          dropDownValue = value;
                        });
                      },
                      value: dropDownValue,
                      items: items
                          .map((e) => DropdownMenuItem<String>(
                                child: Text(e),
                                value: e,
                              ))
                          .toList()),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Container(
                  child: TextField(
                    onChanged: (v) {
                      setState(() {});
                    },
                    controller: _controller,
                    maxLines: 12,
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      hintText: 'Write Something...',
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                dropDownValue != 'Donation Post'
                    ? Column(
                        children: [
                          _images == null
                              ? Text(
                                  "Add picture",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                )
                              : Column(
                                  children: _images!
                                      .map((e) => Text(
                                            e.name.length > 25
                                                ? e.name.substring(0, 25) +
                                                    "..."
                                                : e.name,
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ))
                                      .toList(),
                                ),
                          SizedBox(width: size.width * 0.05),
                          RaisedButton(
                            onPressed: () async {
                              try {
                                _images = await _imagePicker
                                    .pickMultiImage(imageQuality: 10)
                                    .whenComplete(() {
                                  setState(() {});
                                });
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: "Error. Try Again.");
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
                      )
                    : Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: Text('Donation Amount:'),
                          ),
                          TextField(
                              controller: _donationAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              )),
                        ],
                      ),
                SizedBox(
                  height: size.height * 0.07,
                ),
                RaisedButton(
                  disabledColor: Colors.pink[100],
                  onPressed: _images != null || _controller.text.isNotEmpty
                      ? processing
                          ? null
                          : () async {
                              List<String> urls = [];
                              setState(() {
                                processing = true;
                              });
                              try {
                                if (_images != null)
                                  for (XFile file in _images!) {
                                    await _firebaseStorage
                                        .ref(file.name)
                                        .putFile(File(file.path))
                                        .then((p0) async {
                                      urls.add(await p0.ref.getDownloadURL());
                                    });
                                  }
                                setState(() {});
                                await _firebaseFirestore
                                    .collection('posts')
                                    .add({
                                  'postType': dropDownValue ?? 'NEWS Feed Post',
                                  'donationAmount':
                                      _donationAmountController.text.isNotEmpty
                                          ? int.parse(
                                              _donationAmountController.text)
                                          : 0,
                                  'donated': 0,
                                  'posterUid': _auth.currentUser!.uid,
                                  'postCaption': _controller.text,
                                  'postImages': urls,
                                  'postedOn': DateTime.now(),
                                  'likedBy': []
                                });
                                Navigator.of(context).pop();
                              } catch (e) {
                                print(e.toString());
                                Fluttertoast.showToast(msg: "Unkown Error");
                              }
                            }
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.pink[100],
                  padding: EdgeInsets.only(
                      left: 70.0, right: 70.0, top: 10.0, bottom: 10.0),
                  textColor: Colors.black,
                  child: processing
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          "Post",
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
