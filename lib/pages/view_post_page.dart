import 'package:feel_safe/widgets/post_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewPostPage extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>>? postData;
  final DocumentSnapshot<Map<String, dynamic>>? userData;
  const ViewPostPage({Key? key, required this.postData, required this.userData})
      : super(key: key);

  @override
  _ViewPostPageState createState() => _ViewPostPageState();
}

class _ViewPostPageState extends State<ViewPostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: PostWidget(
            userData: widget.userData,
            postData: widget.postData,
          ),
        ),
      ),
    );
  }
}
