// ignore_for_file: prefer_const_constructors

import 'package:feel_safe/widgets/post_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  DocumentSnapshot<Map<String, dynamic>>? userData;
  HomePage({Key? key, this.userData}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('posts')
              .orderBy('postedOn', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            return snapshot.data == null || snapshot.data!.docs.length == 0
                ? Center(
                    child: Text(
                      'No Posts Found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    dragStartBehavior: DragStartBehavior.start,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return PostWidget(
                        key: UniqueKey(),
                        postData: snapshot.data!.docs[index],
                        userData: widget.userData,
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context).pushNamed("/PostPage");
        },
      ),
    );
  }
}
