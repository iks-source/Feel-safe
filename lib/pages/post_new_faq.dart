import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostNewFAQ extends StatefulWidget {
  const PostNewFAQ({Key? key}) : super(key: key);

  @override
  _PostNewFAQState createState() => _PostNewFAQState();
}

class _PostNewFAQState extends State<PostNewFAQ> {
  ZefyrController _controller = ZefyrController();
  TextEditingController _questionController = TextEditingController();
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Post New FAQ"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
              ),
              Divider(),
              Text(
                'Answer:',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              ZefyrToolbar.basic(
                controller: _controller,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: ZefyrEditor(
                  controller: _controller,
                  minHeight: size.height * .3,
                ),
                decoration: BoxDecoration(border: Border.all()),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                    onPressed: () {
                      try {
                        if (_controller.document.toPlainText().isNotEmpty &&
                            _questionController.text.isNotEmpty) {
                          _firebaseFirestore.collection('FAQs').add({
                            'questionText': _questionController.text,
                            'answerText': jsonEncode(_controller.document)
                          }).whenComplete(() => Navigator.of(context).pop());
                        }
                      } catch (e) {
                        print(e.toString());
                        Fluttertoast.showToast(msg: "Unkown Error. Try Again.");
                      }
                    },
                    child: Text("Post")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
