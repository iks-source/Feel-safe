import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/profile_page_arguments.dart';
import 'package:feel_safe/pages/edit_profile_page.dart';
import 'package:feel_safe/pages/view_post_page.dart';
import 'package:feel_safe/widgets/about_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfilePage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? userData;

  const ProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool fetched = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _list;
  DocumentSnapshot<Map<String, dynamic>>? userData;
  getPosts() async {
    await _firestore
        .collection('posts')
        .where('posterUid', isEqualTo: userData!.id)
        .get()
        .then((value) {
      setState(() {
        _list = value.docs
            .where((element) => element.data()['postImages'].length != 0)
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ProfilePageArguments;
    if (!fetched) {
      fetched = true;
      userData = args.userData;
      getPosts();
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("FeelSafe"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      endDrawer: args.userData!.id != _auth.currentUser!.uid
          ? null
          : SafeArea(
              child: Drawer(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    ListTile(
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signOut().then((value) {
                            Navigator.of(context)
                                .pushReplacementNamed("/SignInPage");
                          });
                        } catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(msg: "Unkown Error");
                        }
                      },
                      leading: Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        'LogOut',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                size.width * .06, size.height * .05, size.width * .06, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          NetworkImage(args.userData!.data()!['imageUrl']),
                    ),
                    SizedBox(
                      width: size.width * .04,
                    ),
                    Text(
                      args.userData!.data()!['fullName'],
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * .02,
                ),
                Row(
                  children: [
                    AboutWidget(
                      text: args.userData!.data()!['maritalStatus'],
                      icon: Icons.favorite,
                    ),
                    AboutWidget(
                      text: args.userData!.data()!['religion'],
                      icon: Icons.star,
                    ),
                    AboutWidget(
                      text: args.userData!.data()!['address'],
                      icon: Icons.location_pin,
                    ),
                  ],
                ),
                args.userData!.id == _auth.currentUser!.uid
                    ? Container(
                        width: size.width * .5,
                        child: OutlinedButton(
                            style:
                                OutlinedButton.styleFrom(primary: Colors.black),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                      userData: args.userData!)));
                            },
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(
                                  width: size.width * .05,
                                ),
                                Text('Edit Profile')
                              ],
                            )),
                      )
                    : SizedBox(),
                Divider(
                  thickness: 1,
                ),
                _list == null
                    ? SizedBox()
                    : SizedBox(
                        child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _list!.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) {
                                        return ViewPostPage(
                                            postData: _list!.elementAt(i),
                                            userData: userData);
                                      }));
                                },
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  child: Image(
                                    image: NetworkImage(
                                        _list!.elementAt(i)['postImages'][0]),
                                  ),
                                ),
                              );
                            }),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
