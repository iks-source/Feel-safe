import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/chat_screen_arguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsListPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const ChatsListPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ChatsListPageState createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map>>(
          stream: _firestore
              .collection('chatRooms')
              .where('chatUsers', arrayContains: _auth.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? snapshot.data!.docs.length != 0
                    ? ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          List users =
                              snapshot.data!.docs[index].data()['chatUsers'];
                          String peerUserUid =
                              users[0] == _auth.currentUser!.uid
                                  ? users[1]
                                  : users[0];

                          return StreamBuilder<
                                  DocumentSnapshot<Map<String, dynamic>>>(
                              stream: _firestore
                                  .collection('users')
                                  .doc(peerUserUid)
                                  .snapshots(),
                              builder: (context, usersnapshot) {
                                return usersnapshot.hasData &&
                                        usersnapshot.data!.data() != null
                                    ? ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          backgroundImage: NetworkImage(
                                              usersnapshot.data!['imageUrl']),
                                        ),
                                        subtitle: Text(
                                          snapshot.data!.docs[index].data()[
                                                      'lastMessageText'] ==
                                                  ''
                                              ? "Image"
                                              : snapshot.data!.docs[index]
                                                  .data()['lastMessageText'],
                                          style: TextStyle(
                                              fontWeight: snapshot
                                                      .data!.docs[index]
                                                      .data()['readBy']
                                                      .contains(_auth
                                                          .currentUser!.uid)
                                                  ? FontWeight.normal
                                                  : FontWeight.bold),
                                        ),
                                        trailing: snapshot.data!.docs[index]
                                                .data()['readBy']
                                                .contains(
                                                    _auth.currentUser!.uid)
                                            ? null
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15.0),
                                                child: CircleAvatar(
                                                  radius: 5,
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                        title: Text(
                                            usersnapshot.data!['fullName']),
                                        onTap: () {
                                          List list = snapshot.data!.docs[index]
                                              .data()['readBy'];
                                          if (!list.contains(
                                              _auth.currentUser!.uid)) {
                                            list.add(_auth.currentUser!.uid);
                                            snapshot.data!.docs[index].reference
                                                .update({'readBy': list});
                                          }
                                          Navigator.of(context).pushNamed(
                                              "/ChatPage",
                                              arguments: ChatScreenArguments(
                                                  mainUserData: widget.userData,
                                                  chatRoomData: snapshot
                                                      .data!.docs[index],
                                                  peerUserData:
                                                      usersnapshot.data));
                                        },
                                        contentPadding: EdgeInsets.only(
                                            left: size.width * .04,
                                            bottom: size.height * .005),
                                      )
                                    : SizedBox();
                              });
                        },
                      )
                    : Center(
                        child: Text('No Chats Found'),
                      )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
    );
  }
}
