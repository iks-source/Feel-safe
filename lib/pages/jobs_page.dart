// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/pages/apply_job_page.dart';
import 'package:feel_safe/pages/job_description_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class JobsPage extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const JobsPage({Key? key, required this.userData}) : super(key: key);

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(
                  size.width * .06, size.height * .05, size.width * .06, 0),
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _firestore.collection('jobs').snapshots(),
                      builder: (context, snapshot) {
                        return snapshot.hasData
                            ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  return _cardReturn(
                                      snapshot.data!.docs[index]);
                                })
                            : SizedBox();
                      }),
                  widget.userData['role'] == 'admin'
                      ? Container(
                          alignment: Alignment.topRight,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed("/PostJob");
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.pink[100],
                            padding: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                top: 10.0,
                                bottom: 10.0),
                            child: Text("Post new job",
                                style: TextStyle(fontSize: 18)),
                          ),
                        )
                      : SizedBox(),
                ],
              )),
        ),
      ),
    );
  }

  Widget _cardReturn(QueryDocumentSnapshot<Map<String, dynamic>> docData) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => JobDescription(
                  jobData: docData,
                  userData: widget.userData,
                ),
            fullscreenDialog: true));
      },
      child: Card(
        elevation: 0.0,
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(docData['imageUrl']),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .04,
                  ),
                  Text(
                    docData['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              widget.userData['role'] != 'admin' &&
                      !docData.data()['applicants'].contains(widget.userData.id)
                  ? OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ApplyJobPage(
                            userData: widget.userData,
                            jobReference: docData,
                          );
                        }));
                        // try {
                        //   final list = docData.data()['applicants'];
                        //   list.add(widget.userData.id);
                        //   await docData.reference.update({'applicants': list});
                        // } catch (e) {
                        //   Fluttertoast.showToast(msg: 'Error, Try Again');
                        // }
                      },
                      child: Text('Apply'))
                  : widget.userData['role'] == 'admin'
                      ? SizedBox()
                      : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: docData.reference
                              .collection('applications')
                              .doc(widget.userData.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return snapshot.hasData
                                ? snapshot.data!.data()!['applicationStatus'] ==
                                        'pending'
                                    ? Text(
                                        'Pending',
                                        style: TextStyle(color: Colors.blue),
                                      )
                                    : snapshot.data!
                                                .data()!['applicationStatus'] ==
                                            'approved'
                                        ? Text(
                                            'Approved',
                                            style:
                                                TextStyle(color: Colors.green),
                                          )
                                        : Text(
                                            'Declined',
                                            style: TextStyle(color: Colors.red),
                                          )
                                : SizedBox();
                          })
            ],
          ),
        ),
      ),
    );
  }
}
