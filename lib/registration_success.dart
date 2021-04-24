import 'package:flutter/material.dart';
import 'helpers.dart';
import 'login.dart';
import 'dart:async';

class RegistrationSuccess extends StatefulWidget {

  final String _username;
  final String _password;

  RegistrationSuccess(this._username, this._password);

  @override
  _RegistrationSuccessState createState() => _RegistrationSuccessState(_username, _password);
}

class _RegistrationSuccessState extends State<RegistrationSuccess> {

  final String _username;
  final String _password;

  _RegistrationSuccessState(this._username, this._password);

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
    login(_username, _password, context);
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
              SizedBox(height: displayHeight(context) * 0.05,),
              Text("Success!", style: TextStyle(fontSize: 40.0),),
            ],
          ),
        ),
      ),
    );
  }
}
