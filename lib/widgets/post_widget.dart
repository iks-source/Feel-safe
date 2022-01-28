import 'package:feel_safe/pages/comments_page.dart';
import 'package:feel_safe/pages/edit_post.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PostWidget extends StatefulWidget {
  QueryDocumentSnapshot<Map<String, dynamic>>? postData;
  DocumentSnapshot<Map<String, dynamic>>? userData;
  PostWidget({Key? key, this.postData, required this.userData})
      : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool liked = false;
  bool dataFetched = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('users')
            .doc(widget.postData!['posterUid'])
            .snapshots(),
        builder: (context, snapshot) {
          if (!dataFetched) {
            List list = widget.postData!.data()['likedBy'];
            liked = list.contains(_auth.currentUser!.uid);
            dataFetched = true;
          }
          return !snapshot.hasData
              ? SizedBox()
              : SafeArea(
                  child: Card(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.height * .01),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data!['imageUrl']),
                              ),
                              SizedBox(
                                width: size.width * .03,
                              ),
                              Text(
                                snapshot.data!['fullName'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              widget.postData!['posterUid'] ==
                                          _auth.currentUser!.uid ||
                                      widget.userData!['role'] == 'admin'
                                  ? Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          widget.postData!['posterUid'] ==
                                                  _auth.currentUser!.uid
                                              ? IconButton(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditPostPage(
                                                                  post: widget
                                                                      .postData!,
                                                                )));
                                                  },
                                                  icon: Icon(Icons.edit))
                                              : SizedBox(),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: IconButton(
                                              icon: Icon(Icons.cancel_outlined),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        content: Text(
                                                            "Do you want to delete this post?"),
                                                        actions: [
                                                          OutlinedButton(
                                                              onPressed: () {
                                                                try {
                                                                  widget
                                                                      .postData!
                                                                      .reference
                                                                      .delete();
                                                                  Navigator.pop(
                                                                      context);
                                                                } catch (e) {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Error. Try Again");
                                                                }
                                                              },
                                                              child: Text(
                                                                'Yes',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
                                                              )),
                                                          OutlinedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child:
                                                                  Text('No')),
                                                        ],
                                                      );
                                                    });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.postData!.data()['postCaption'],
                            )),
                        widget.postData!['postType'] == 'Donation Post'
                            ? Column(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      child: LinearPercentIndicator(
                                        alignment: MainAxisAlignment.center,
                                        width: size.width * .8,
                                        lineHeight: 10,
                                        leading: Text("0"),
                                        trailing: Text('RM' +
                                            widget.postData!['donationAmount']
                                                .toString()),
                                        progressColor:
                                            Theme.of(context).primaryColor,
                                        percent: widget.postData!['donated'] /
                                            widget.postData!['donationAmount'],
                                      )),
                                  Text('RM' +
                                      widget.postData!['donated'].toString()),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              TextEditingController
                                                  _controller =
                                                  TextEditingController();
                                              return AlertDialog(
                                                content: TextField(
                                                  controller: _controller,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration: InputDecoration(
                                                      hintText:
                                                          'Enter amount...'),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        if (_controller
                                                            .text.isNotEmpty) {
                                                          if (int.parse(_controller
                                                                      .text) +
                                                                  widget.postData![
                                                                      'donated'] >
                                                              widget.postData![
                                                                  'donationAmount']) {
                                                            widget.postData!
                                                                .reference
                                                                .update({
                                                              'donationAmount': widget
                                                                          .postData![
                                                                      'donated'] +
                                                                  int.parse(
                                                                      _controller
                                                                          .text),
                                                              'donated': widget
                                                                          .postData![
                                                                      'donated'] +
                                                                  int.parse(
                                                                      _controller
                                                                          .text)
                                                            });
                                                          } else {
                                                            widget.postData!
                                                                .reference
                                                                .update({
                                                              'donated': widget
                                                                          .postData![
                                                                      'donated'] +
                                                                  int.parse(
                                                                      _controller
                                                                          .text)
                                                            });
                                                          }

                                                          Navigator.pop(
                                                              context);
                                                        } else {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      child: Text('Donate'))
                                                ],
                                              );
                                            });
                                      },
                                      child: Text('Donate'))
                                ],
                              )
                            : SizedBox(),
                        widget.postData!.data()['postImages'].length == 0
                            ? SizedBox()
                            : Container(
                                width: size.width - 20,
                                height: size.height * .3,
                                color: Colors.grey[100],
                                child: PageView.builder(
                                    itemCount: widget.postData!
                                        .data()['postImages']
                                        .length,
                                    itemBuilder: (context, i) {
                                      return Stack(
                                        children: [
                                          Center(
                                            child: Image(
                                              image: NetworkImage(widget
                                                  .postData!
                                                  .data()['postImages'][i]),
                                            ),
                                          ),
                                          widget.postData!
                                                      .data()['postImages']
                                                      .length >
                                                  1
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Icon(Icons
                                                      .arrow_forward_ios_rounded),
                                                )
                                              : SizedBox()
                                        ],
                                      );
                                    }),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  try {
                                    List list =
                                        widget.postData!.data()['likedBy'];
                                    if (liked) {
                                      list.remove(_auth.currentUser!.uid);
                                      _firestore
                                          .collection('posts')
                                          .doc(widget.postData!.id)
                                          .update({'likedBy': list});
                                    } else {
                                      list.add(_auth.currentUser!.uid);
                                      _firestore
                                          .collection('posts')
                                          .doc(widget.postData!.id)
                                          .update({'likedBy': list});
                                    }
                                  } catch (e) {
                                    print(e.toString());
                                    Fluttertoast.showToast(
                                        msg: "Error. Try Again.");
                                  }
                                },
                                icon: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: liked ? Colors.red : Colors.black,
                                )),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CommentsPage(
                                          postData: widget.postData!,
                                          userData: widget.userData!,
                                        ),
                                    fullscreenDialog: true));
                              },
                              icon: Icon(Icons.chat),
                            ),
                            IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          content: Text(
                                              "Do you Want to share this post?"),
                                          actions: [
                                            OutlinedButton(
                                                onPressed: () async {
                                                  try {
                                                    Map<String, dynamic> data =
                                                        widget.postData!.data();
                                                    data.update(
                                                        'posterUid',
                                                        (value) => widget
                                                            .userData!.id);
                                                    data.update(
                                                      'postedOn',
                                                      (value) => DateTime.now(),
                                                    );

                                                    Navigator.pop(context);
                                                    await _firestore
                                                        .collection('posts')
                                                        .add(data);
                                                  } catch (e) {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Unknown Error. Try Again.");
                                                  }
                                                },
                                                child: Text('Yes')),
                                            OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('No'))
                                          ],
                                        ));
                              },
                              icon: Icon(Icons.share),
                            ),
                          ],
                        ),
                        widget.postData!.data()['likedBy'].length == 0
                            ? SizedBox()
                            : Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.favorite),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  widget.postData!.data()['likedBy'].length == 1
                                      ? Text('Liked by ' +
                                          widget.postData!
                                              .data()['likedBy']
                                              .length
                                              .toString() +
                                          ' person.')
                                      : Text('Liked by ' +
                                          widget.postData!
                                              .data()['likedBy']
                                              .length
                                              .toString() +
                                          ' people.')
                                ],
                              ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                );
        });
  }
}
