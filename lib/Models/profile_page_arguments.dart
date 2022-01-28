import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePageArguments {
  final DocumentSnapshot<Map<String, dynamic>>? userData;
  ProfilePageArguments({this.userData});
}
