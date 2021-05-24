import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              "SmartStore",
              style: TextStyle(fontSize: 30.0),
            ),
            const SizedBox(
              height: 5.0,
            ),
            const Text(
              "Developed by Vishal Pednekar and Tanvi Salian",
              style: TextStyle(fontSize: 15.0),
            ),
            const SizedBox(
              height: 50.0,
            ),
            const Text(
              "Version: 4.0.1 Release 2",
            )
          ],
        ),
      ),
    );
  }
}
