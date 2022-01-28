import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreenArguments {
  final DocumentSnapshot<Map>? peerUserData;
  final DocumentSnapshot<Map>? mainUserData;
  final DocumentSnapshot<Map>? chatRoomData;
  ChatScreenArguments(
      {this.peerUserData, this.mainUserData, this.chatRoomData});
}
