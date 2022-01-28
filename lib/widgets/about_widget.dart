import 'package:flutter/material.dart';

class AboutWidget extends StatelessWidget {
  final String? text;
  final IconData? icon;
  const AboutWidget({Key? key, required this.text, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(size.width * .01),
      padding: EdgeInsets.fromLTRB(size.width * .025, size.width * .005,
          size.width * .025, size.width * .005),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(
            width: size.width * .005,
          ),
          Text(
            text!,
          ),
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.grey.shade400, borderRadius: BorderRadius.circular(20)),
    );
  }
}
