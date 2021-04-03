import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Shopping App",
                style: TextStyle(fontSize: 30.0),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Developed by Vishal Pednekar",
                style: TextStyle(fontSize: 15.0),
              ),
              SizedBox(height: 50.0,),
              Text("Version: 1.4 Beta",)
            ]),
      ),
    );
  }
}
