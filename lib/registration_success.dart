import 'package:flutter/material.dart';
import 'helpers.dart';
import 'login.dart';
import 'dart:async';

class RegistrationSuccess extends StatefulWidget {
  @override
  _RegistrationSuccessState createState() => _RegistrationSuccessState();
}

class _RegistrationSuccessState extends State<RegistrationSuccess> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = new Duration(seconds: 3);
    return new Timer(duration, route);
  }

  route() async {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => LoginForm()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return successScreen(context);
  }

  successScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: displayWidth(context) * 0.5,
                width: displayWidth(context) * 0.5,
                decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius:
                        BorderRadius.circular(displayWidth(context) * 0.25)),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: displayWidth(context) * 0.35,
                ),
              ),
              SizedBox(
                height: displayHeight(context) * 0.05,
              ),
              Text(
                "Success!",
                style: TextStyle(fontSize: 40.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
