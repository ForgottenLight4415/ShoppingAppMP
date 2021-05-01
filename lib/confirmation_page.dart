import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mini_project_ii/home.dart';
import 'helpers.dart';

class ConfirmationPage extends StatefulWidget {
  final flag;

  ConfirmationPage(this.flag);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  Color colorProvider(int flag) {
    if (flag == 0) {
      return Colors.green.shade500;
    } else if (flag == 1) {
      return Colors.orange.shade500;
    } else {
      return Colors.red.shade500;
    }
  }

  IconData iconProvider(int flag) {
    if (flag == 0) {
      return Icons.check;
    } else if (flag == 1) {
      return Icons.warning;
    } else {
      return Icons.close;
    }
  }

  Text confirmationTextProvider(int flag) {
    if (flag == 0) {
      return Text(
        "Order placed",
        style: TextStyle(fontSize: displayWidth(context) * 0.1),
      );
    } else if (flag == 1) {
      return Text(
        "Some items went out of stock. Your money will be refunded in 2-3 business days.",
        style: TextStyle(fontSize: displayWidth(context) * 0.05),
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        "Items went out of stock. Your money will be refunded in 2-3 business days.",
        style: TextStyle(fontSize: displayWidth(context) * 0.05),
        textAlign: TextAlign.center,
      );
    }
  }

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
        MaterialPageRoute(builder: (context) => HomePage()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: displayWidth(context) * 0.5,
              width: displayWidth(context) * 0.5,
              decoration: BoxDecoration(
                  color: colorProvider(widget.flag),
                  borderRadius:
                      BorderRadius.circular(displayWidth(context) * 0.25)),
              child: Icon(
                iconProvider(widget.flag),
                color: Colors.white,
                size: displayWidth(context) * 0.35,
              ),
            ),
            SizedBox(
              height: displayHeight(context) * 0.05,
            ),
            confirmationTextProvider(widget.flag),
          ],
        ),
      ),
    );
  }
}
