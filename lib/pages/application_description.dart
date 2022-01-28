import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/chat_screen_arguments.dart';
import 'package:feel_safe/pages/cv_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApplicationDescription extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> applicationData;
  final DocumentSnapshot<Map<String, dynamic>> userData;
  final QueryDocumentSnapshot<Map<String, dynamic>> applicantData;

  const ApplicationDescription(
      {Key? key,
      required this.applicationData,
      required this.applicantData,
      required this.userData})
      : super(key: key);

  @override
  _ApplicationDescriptionState createState() => _ApplicationDescriptionState();
}

class _ApplicationDescriptionState extends State<ApplicationDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Applicant',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(widget.applicantData['imageUrl']),
              ),
              title: Text(
                widget.applicantData['fullName'],
                style: TextStyle(fontSize: 15),
              ),
              trailing: IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  Navigator.of(context).pushNamed('/ChatPage',
                      arguments: ChatScreenArguments(
                          mainUserData: widget.userData,
                          peerUserData: widget.applicantData));
                },
              ),
            ),
            Divider(),
            Text(
              'Application',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(widget.applicationData['applicationText']),
            ),
            SizedBox(
              height: 10,
            ),
            widget.applicationData['cvURL'] != null
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ViewCV(cvURL: widget.applicationData['cvURL']);
                      }));
                    },
                    child: Text('View CV'))
                : SizedBox(),
            widget.applicationData['applicationStatus'] == 'pending'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            try {
                              widget.applicationData.reference
                                  .update({'applicationStatus': 'approved'});
                              Navigator.pop(context);
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg: 'Error. Please Try Again');
                            }
                          },
                          child: Text('Approve')),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            try {
                              widget.applicationData.reference
                                  .update({'applicationStatus': 'declined'});
                              Navigator.pop(context);
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg: 'Error. Please Try Again');
                            }
                          },
                          child: Text('Decline')),
                    ],
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
