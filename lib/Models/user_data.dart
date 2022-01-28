import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final DocumentSnapshot<Map<String, dynamic>> userData;
  const UserData({required this.userData});
}
