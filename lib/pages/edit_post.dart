// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPostPage extends StatefulWidget {
  final DocumentSnapshot<Map> post;
  const EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  TextEditingController _controller = TextEditingController();
  bool processing = false;
  @override
  void initState() {
    _controller.text = widget.post['postCaption'];
    super.initState();
  }

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
                  height: size.height * 0.07,
                ),
                RaisedButton(
                  disabledColor: Colors.pink[100],
                  onPressed: _controller.text.isNotEmpty
                      ? processing
                          ? null
                          : () async {
                              try {
                                if (_controller.text !=
                                    widget.post['postCaption']) {
                                  await widget.post.reference.update({
                                    'postCaption': _controller.text
                                  }).then((value) => Navigator.pop(context));
                                }
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: "Error. Try Again. ");
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
                      : Text("Save Changes", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
