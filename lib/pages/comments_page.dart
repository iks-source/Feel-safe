import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommentsPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> postData;
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const CommentsPage({Key? key, required this.postData, required this.userData})
      : super(key: key);

  @override
  _CommentsPageState createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map>>(
            stream:
                widget.postData.reference.collection('comments').snapshots(),
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          color: Colors.grey[200],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                snapshot.data!.docs[index]['postedBy'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(snapshot.data!.docs[index]['commentText'])
                            ],
                          ),
                        );
                      },
                    )
                  : SizedBox();
            }),
      ),
      bottomSheet: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.only(
            left: size.width * .02,
            right: size.width * .02,
            bottom: size.height * .02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                  width: size.width * .80,
                  child: TextField(
                    controller: _controller,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        hintText: "Write a comment...",
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.grey.shade300),
                  )),
            ),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    try {
                      widget.postData.reference.collection('comments').add({
                        'postedBy': widget.userData['fullName'],
                        'commentText': _controller.text,
                        'postedOn': DateTime.now()
                      });
                      setState(() {
                        _controller.text = "";
                      });
                    } catch (e) {
                      Fluttertoast.showToast(msg: "Error");
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
