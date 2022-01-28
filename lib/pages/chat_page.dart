import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feel_safe/Models/chat_screen_arguments.dart';
import 'package:feel_safe/pages/send_photos.dart';
import 'package:feel_safe/widgets/message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController _messageController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  ImagePicker _imagePicker = ImagePicker();
  DocumentSnapshot<Map>? peerUserData;
  DocumentSnapshot<Map>? mainUserData;
  DocumentSnapshot<Map>? chatRoomData;

  List<XFile>? _imagesList;
  bool fetchedData = false;
  bool? isNewMessage;
  bool sending = false;

  checkIfNewMessage() {
    if (chatRoomData != null) {
      isNewMessage = false;
    } else {
      _firestore
          .collection('chatRooms')
          .where('chatUsers', arrayContains: mainUserData!.id)
          .get()
          .then((value) {
        final chatDocs = value.docs.where((element) =>
            element.data()['chatUsers'].contains(peerUserData!.id));
        if (chatDocs.length != 0) {
          isNewMessage = false;
          chatRoomData = chatDocs.first;
        } else {
          isNewMessage = true;
        }
      }).whenComplete(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatScreenArguments _args =
        ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
    if (peerUserData == null && mainUserData == null && chatRoomData == null) {
      peerUserData = _args.peerUserData;
      mainUserData = _args.mainUserData;
      chatRoomData = _args.chatRoomData;
    }
    if (!fetchedData) {
      fetchedData = true;
      checkIfNewMessage();
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(peerUserData!.data()!['fullName']),
      ),
      body: isNewMessage == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Container(
                  margin: EdgeInsets.only(
                      bottom: size.height * .12,
                      left: size.width * .04,
                      right: size.width * .04),
                  //  margin: EdgeInsets.symmetric(horizontal: size.width * .05),
                  child: isNewMessage == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isNewMessage!
                          ? Center(
                              child:
                                  Text('Send a message to start conversation.'),
                            )
                          : chatRoomData == null
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                  stream: chatRoomData!.reference
                                      .collection('messages')
                                      .orderBy('sendingTime', descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    return snapshot.data == null
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : ListView.builder(
                                            reverse: true,
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              return MessageWidget(
                                                isReceivedMessage:
                                                    snapshot.data!.docs[index]
                                                            ['sentBy'] !=
                                                        _auth.currentUser!.uid,
                                                hasImages: snapshot.data!
                                                    .docs[index]['hasImages'],
                                                messageText: snapshot.data!
                                                    .docs[index]['messageText'],
                                                imagesUrls: snapshot.data!
                                                    .docs[index]['imagesUrls'],
                                              );
                                            });
                                  })),
            ),
      bottomSheet: Container(
        height: size.height * .11,
        color: Colors.grey[100],
        padding: EdgeInsets.only(
            left: size.width * .02,
            right: size.width * .02,
            bottom: size.height * .015),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: isNewMessage == null && chatRoomData == null
                  ? null
                  : () {
                      _imagePicker
                          .pickMultiImage(imageQuality: 10)
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            _imagesList = value;
                            if (!isNewMessage!) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SendPhotos(
                                            isNewMessage: false,
                                            imagesList: value,
                                            chatRoomId: chatRoomData!.id,
                                            mainUserUid: mainUserData!.id,
                                            peerUserUid: peerUserData!.id,
                                          ),
                                      fullscreenDialog: true));
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SendPhotos(
                                            isNewMessage: true,
                                            imagesList: value,
                                            mainUserUid: mainUserData!.id,
                                            peerUserUid: peerUserData!.id,
                                          ),
                                      fullscreenDialog: true));
                            }
                          });
                        }
                      });
                    },
              icon: Icon(
                Icons.image_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                  width: size.width * .70,
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
              onPressed: sending || isNewMessage == null && chatRoomData == null
                  ? null
                  : () {
                      setState(() {
                        sending = true;
                      });
                      if (_messageController.text.isNotEmpty) {
                        if (isNewMessage!) {
                          sendNewMessage(
                              messageText: _messageController.text,
                              hasImages: _imagesList != null,
                              imagesUrls: _imagesList);
                        } else {
                          sendMessage();
                        }
                      }
                    },
            )
          ],
        ),
      ),
    );
  }

  sendMessage() async {
    try {
      await _firestore.collection('chatRooms').doc(chatRoomData!.id).update({
        'readBy': [mainUserData!.id],
        'lastMessageText': _messageController.text,
      });
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomData!.id)
          .collection('messages')
          .add({
        'sentBy': mainUserData!.id,
        'sendingTime': DateTime.now(),
        'hasImages': false,
        'imagesUrls': null,
        'messageText': _messageController.text,
      }).whenComplete(() {
        setState(() {
          sending = false;
          _messageController.text = '';
        });
      });
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: "Unknown Error.Try again");
    }
  }

  sendNewMessage(
      {String? messageText, bool? hasImages, List? imagesUrls}) async {
    try {
      await _firestore.collection('chatRooms').add({
        'chatUsers': [mainUserData!.id, peerUserData!.id],
        'readBy': [mainUserData!.id],
        'lastMessageText': messageText,
      }).then((value) {
        value.collection('messages').add({
          'sentBy': mainUserData!.id,
          'sendingTime': DateTime.now(),
          'hasImages': false,
          'imagesUrls': null,
          'messageText': messageText,
        });

        setState(() {
          sending = false;
          _messageController.text = '';
        });
        checkIfNewMessage();
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Unknown Error.Try again");
    }
  }
}
