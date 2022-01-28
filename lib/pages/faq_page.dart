import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zefyrka/zefyrka.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  _FaqPageState createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as UserData;
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore.collection('FAQs').snapshots(),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.active
              ? ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    ZefyrController _controller =
                        ZefyrController(NotusDocument.fromJson(
                      json.decode(
                        snapshot.data!.docs[index]['answerText'],
                      ),
                    ));

                    return ExpansionTileCard(
                      children: [
                        SizedBox(
                            height: 100,
                            child: ZefyrEditor(
                              showCursor: false,
                              focusNode: null,
                              padding: EdgeInsets.all(15),
                              onLaunchUrl: (value) {
                                launch(value);
                              },
                              controller: _controller,
                              readOnly: true,
                            ))
                      ],
                      title: Text(
                        snapshot.data!.docs[index]['questionText'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  })
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      floatingActionButton: args.userData.data()!['role'] == 'admin'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/PostNewFaq');
              },
              child: Icon(Icons.edit),
            )
          : null,
    );
  }
}
