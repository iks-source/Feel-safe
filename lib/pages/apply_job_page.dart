import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyJobPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? jobReference;
  final DocumentSnapshot? userData;
  const ApplyJobPage(
      {Key? key, required this.jobReference, required this.userData})
      : super(key: key);

  @override
  _ApplyJobPageState createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  TextEditingController _controller = TextEditingController();
  FilePicker _filePicker = FilePicker.platform;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PlatformFile? _file;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool processing = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text("Apply For Job"),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field is required.';
                      }
                    },
                    onChanged: (v) {
                      setState(() {});
                    },
                    controller: _controller,
                    maxLines: 12,
                    decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      hintText: 'Write a message for application...',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              _file == null
                  ? Text(
                      "Add CV..",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  : Container(
                      child: Text(
                        _file!.name.length > 25
                            ? _file!.name.substring(0, 25) + "..."
                            : _file!.name,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
              SizedBox(width: size.width * 0.05),
              RaisedButton(
                onPressed: () async {
                  try {
                    FilePickerResult? result = await _filePicker.pickFiles(
                      allowMultiple: false,
                    );
                    if (result != null) {
                      setState(() {
                        _file = result.files.first;
                      });
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: "Error. Try Again.");
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
              SizedBox(
                height: size.height * 0.06,
              ),
              RaisedButton(
                disabledColor: Colors.pink[100],
                onPressed: processing
                    ? null
                    : () async {
                        try {
                          if (_formKey.currentState!.validate()) {
                            String? url;
                            if (_file != null) {
                              var ref = await _firebaseStorage
                                  .ref(_file!.name)
                                  .child('cvs')
                                  .putFile(File(_file!.path!));
                              url = await ref.ref.getDownloadURL();
                              setState(() {});
                            }
                            await widget.jobReference!.reference
                                .collection('applications')
                                .doc(widget.userData!.id)
                                .set({
                              'applicantId': widget.userData!.id,
                              'applicationText': _controller.text,
                              'cvURL': url,
                              'applicationStatus': 'pending'
                            });
                            List list = await widget.jobReference!
                                .data()!['applicants'];
                            list.add(widget.userData!.id);
                            await widget.jobReference!.reference
                                .update({'applicants': list});
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(
                              msg: 'Unkown Error. Try Again.');
                        }
                      },
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
                    : Text("Post", style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ));
  }
}
