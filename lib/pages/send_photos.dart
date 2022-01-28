import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SendPhotos extends StatefulWidget {
  final List<XFile> imagesList;
  final bool isNewMessage;
  final String? chatRoomId;
  final String? peerUserUid;
  final String? mainUserUid;

  const SendPhotos(
      {Key? key,
      required this.imagesList,
      required this.isNewMessage,
      this.chatRoomId,
      this.mainUserUid,
      this.peerUserUid})
      : super(key: key);

  @override
  _SendPhotosState createState() => _SendPhotosState();
}

class _SendPhotosState extends State<SendPhotos> {
  TextEditingController _messageController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool processing = false;
  FirebaseStorage _storage = FirebaseStorage.instance;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: PageView.builder(
              itemCount: widget.imagesList.length,
              itemBuilder: (context, index) {
                return Image.file(File(widget.imagesList[index].path));
              }),
        ),
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
                    controller: _messageController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                        hintText: "Write a message...",
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
              onPressed: processing
                  ? null
                  : () async {
                      setState(() {
                        processing = true;
                      });
                      try {
                        print(widget.isNewMessage);
                        List<String> imagesUrls = [];
                        for (XFile file in widget.imagesList) {
                          await _storage
                              .ref(file.name)
                              .putFile(File(file.path))
                              .then((p0) async => imagesUrls
                                  .add(await p0.ref.getDownloadURL()));
                        }
                        if (widget.isNewMessage) {
                          sendNewMessage(imagesUrls);
                        } else {
                          sendMessage(imagesUrls);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                            msg: "Unknown Error. Try Again.");
                      }
                    },
            )
          ],
        ),
      ),
    );
  }

  sendMessage(List imagesUrls) async {
    try {
      await _firestore.collection('chatRooms').doc(widget.chatRoomId).update({
        'readBy': [widget.mainUserUid],
        'lastMessageText': _messageController.text,
      });
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'sentBy': widget.mainUserUid,
        'sendingTime': DateTime.now(),
        'hasImages': true,
        'imagesUrls': imagesUrls,
        'messageText': _messageController.text,
      }).whenComplete(() {
        Navigator.pop(context);
      });
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Unknown Error.Try again");
    }
  }

  sendNewMessage(List imagesUrls) async {
    try {
      await _firestore.collection('chatRooms').add({
        'chatUsers': [widget.mainUserUid, widget.peerUserUid],
        'readBy': [widget.mainUserUid],
        'lastMessageText': _messageController.text,
      }).then((value) {
        value.collection('messages').add({
          'sentBy': widget.mainUserUid,
          'sendingTime': DateTime.now(),
          'hasImages': true,
          'imagesUrls': imagesUrls,
          'messageText': _messageController.text,
        }).whenComplete(() {
          Navigator.pop(context);
        });
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Unknown Error.Try again");
    }
  }
}
