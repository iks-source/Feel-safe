import 'package:feel_safe/Models/chat_screen_arguments.dart';
import 'package:feel_safe/Models/profile_page_arguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserGroupPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? userData;
  AddUserGroupPage({Key? key, this.userData}) : super(key: key);

  @override
  _AddUserGroupPageState createState() => _AddUserGroupPageState();
}

class _AddUserGroupPageState extends State<AddUserGroupPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? usersList;
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    await _firestore.collection('users').get().then((value) {
      setState(() {
        usersList = value.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: usersList == null
            ? Center(child: CircularProgressIndicator())
            : ListView.separated(
                separatorBuilder: (context, index) =>
                    usersList!.elementAt(index).id == _auth.currentUser!.uid
                        ? SizedBox()
                        : Divider(),
                itemCount: usersList!.length,
                itemBuilder: (context, index) {
                  return usersList!.elementAt(index).id ==
                          _auth.currentUser!.uid
                      ? SizedBox()
                      : ListTile(
                          onTap: () {
                            Navigator.of(context).pushNamed("/ProfilePage",
                                arguments: ProfilePageArguments(
                                    userData: usersList!.elementAt(index)));
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                usersList![index].data()['imageUrl']),
                          ),
                          title: Text(
                            usersList![index].data()['fullName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(usersList![index].data()['role']),
                          trailing: Container(
                            width: size.width * .45,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                widget.userData!.data()!['role'] == 'admin'
                                    ? ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (contex) => AlertDialog(
                                              content: Text(
                                                  "Do you want to disable this user?"),
                                              actions: [
                                                OutlinedButton(
                                                    onPressed: () {
                                                      usersList!
                                                          .elementAt(index)
                                                          .reference
                                                          .delete();
                                                      fetchData();
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "Yes",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )),
                                                OutlinedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("No")),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Disable User",
                                          style: TextStyle(color: Colors.black),
                                        ))
                                    : SizedBox(),
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed("/ChatPage",
                                        arguments: ChatScreenArguments(
                                            peerUserData: usersList![index],
                                            mainUserData: widget.userData));
                                  },
                                  icon: Icon(Icons.chat),
                                )
                              ],
                            ),
                          ),
                        );
                }),
      ),
    );
  }
}
