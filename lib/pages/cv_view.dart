import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class ViewCV extends StatelessWidget {
  final String cvURL;
  const ViewCV({Key? key, required this.cvURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('CV'),
      ),
      body: SingleChildScrollView(
        child: Container(
            height: size.height * .8, child: PDF().cachedFromUrl(cvURL)),
      ),
    );
  }
}
