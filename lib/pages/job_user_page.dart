// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class JobUserPage extends StatefulWidget {
  const JobUserPage({ Key? key }) : super(key: key);

  @override
  _JobUserPageState createState() => _JobUserPageState();
}

class _JobUserPageState extends State<JobUserPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("FeelSafe"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                size.width * .06, size.height * .05, size.width * .06, 0),
                child: Column(
                  children: [
                    _cardReturn(),
                    SizedBox(height: size.height * 0.03,),
                    _cardReturn(),
                    SizedBox(height: size.height * 0.03,),
                  ],
                )
          ),
        ),
        ),
    );
  }
  Widget _cardReturn() {
    return GestureDetector(
                      onTap: (){
                      },
                      child: Card(
                        //elevation: 0.0,
                        color: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    child: Text("Image.."),
                                  ),
                                  SizedBox(
                                width: MediaQuery.of(context).size.width * .04,
                              ),
                              Text(
                                "Primary Teacher",
                                style:
                                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              )
                                ],
                              ),
                              Container(
                            alignment: Alignment.topRight,
                            child: RaisedButton(
                          onPressed: () {
                          },
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.pink[100],
                          child: Text("Apply", style: TextStyle(fontSize: 18)),
                        ),
                  ),
                            ],
                          ),
                        ),
      ),
    );
  }
}