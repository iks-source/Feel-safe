import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreenArguments {
  final DocumentSnapshot<Map<String, dynamic>>? userData;
  MainScreenArguments({this.userData});
}
