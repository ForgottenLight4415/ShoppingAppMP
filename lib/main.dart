import 'package:flutter/material.dart';
import 'login.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  var status = pref.getBool('isLoggedIn') ?? false;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Shopping App",
    home: status == true ? HomePage() : LoginForm(),
    theme: ThemeData(
      primaryColor: Color(0xFFE6004C),
      accentColor: Colors.orange,
      splashColor: Colors.orange,
      fontFamily: 'Open Sans',
    ),
  ));
}
