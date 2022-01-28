// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/chat_screen_arguments.dart';
import 'package:feel_safe/pages/application_description.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JobDescription extends StatefulWidget {
  final DocumentSnapshot<Map> jobData;
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const JobDescription(
      {Key? key, required this.jobData, required this.userData})
      : super(key: key);

  @override
  _JobDescriptionState createState() => _JobDescriptionState();
}

class _JobDescriptionState extends State<JobDescription> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("FeelSafe"),
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
                    backgroundImage: NetworkImage(widget.jobData['imageUrl']),
                  ),
                  SizedBox(
                    width: size.width * .04,
                  ),
                  Text(
                    widget.jobData['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.topLeft,
                child: Text(
                    "Job Description :\n\n" + widget.jobData['description']),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              widget.userData['role'] == 'user'
                  ? SizedBox()
                  : Text(
                      "Applicants List :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              widget.userData['role'] == 'user' &&
                      !widget.jobData
                          .data()!['applicants']
                          .contains(widget.userData.id)
                  ? Container(
                      alignment: Alignment.topRight,
                      child: RaisedButton(
                        onPressed: () async {
                          try {
                            final list = widget.jobData.data()!['applicants'];
                            list.add(widget.userData.id);
                            await widget.jobData.reference
                                .update({'applicants': list});
                            Navigator.pop(context);
                          } catch (e) {
                            Fluttertoast.showToast(msg: 'Error, Try Again');
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.pink[100],
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                        textColor: Colors.black,
                        child:
                            Text("Apply now", style: TextStyle(fontSize: 18)),
                      ),
                    )
                  : widget.userData['role'] == 'admin'
                      ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _firestore.collection('users').snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      return widget.jobData['applicants']
                                              .contains(
                                                  snapshot.data!.docs[index].id)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ListTile(
                                                onTap: () async {
                                                  DocumentSnapshot<
                                                          Map<String, dynamic>>
                                                      applicationData =
                                                      await widget
                                                          .jobData.reference
                                                          .collection(
                                                              'applications')
                                                          .doc(snapshot.data!
                                                              .docs[index].id)
                                                          .get();
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return ApplicationDescription(
                                                      userData: widget.userData,
                                                      applicationData:
                                                          applicationData,
                                                      applicantData: snapshot
                                                          .data!.docs[index],
                                                    );
                                                  }));
                                                },
                                                leading: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      snapshot.data!.docs[index]
                                                          ['imageUrl']),
                                                ),
                                                title: Text(snapshot.data!
                                                    .docs[index]['fullName']),
                                                trailing: IconButton(
                                                  icon: Icon(Icons.chat),
                                                  onPressed: () {
                                                    Navigator.of(context).pushNamed(
                                                        '/ChatPage',
                                                        arguments: ChatScreenArguments(
                                                            mainUserData:
                                                                widget.userData,
                                                            peerUserData:
                                                                snapshot.data!
                                                                        .docs[
                                                                    index]));
                                                  },
                                                ),
                                              ),
                                            )
                                          : SizedBox();
                                    })
                                : SizedBox();
                          })
                      : SizedBox()
            ],
          ),
        ),
      )),
    );
  }
}
