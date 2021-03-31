import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register.dart';
import 'home.dart';
import 'about.dart';
import 'screen_size.dart';

Future<CredentialManager> fetchCredentials() async {
  final response =
      await http.get(Uri.http('10.0.2.2', '/ShoppingApp/login.php'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final jsonResponse = jsonDecode(response.body);
    return CredentialManager.fromJson(jsonResponse[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load credentials');
  }
}

class CredentialManager {
  final String userCredentials;
  final String passCredentials;

  CredentialManager(
      {@required this.userCredentials, @required this.passCredentials});

  factory CredentialManager.fromJson(Map<String, dynamic> json) {
    return CredentialManager(
        userCredentials: json['u_name'], passCredentials: json['password']);
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _uname = TextEditingController();
  final _pass = TextEditingController();
  bool _validateUname = false;
  bool _validatePass = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 70.0, 10.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: displayHeight(context) * 0.23, // 150.0
                  width: displayHeight(context) * 0.23, // 150.0
                  decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.0,
                      ),
                      borderRadius: BorderRadius.circular(
                          displayWidth(context) * 0.25), //115
                      color: Colors.blueGrey),
                  child: Icon(
                    Icons.person,
                    size: displayWidth(context) * 0.30,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: displayHeight(context) * 0.06,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3.0, 0.0, 3.0, 3.0),
                        child: TextFormField(
                          controller: _uname,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: "Username",
                              hintText: "Enter your username",
                              errorText: _validateUname
                                  ? "Username cannot be empty"
                                  : null,
                              errorStyle: TextStyle(
                                color: Colors.white,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0))),
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(3.0, 1.5, 3.0, 20.0),
                        child: TextFormField(
                          controller: _pass,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_rounded),
                              labelText: "Password",
                              hintText: "Enter your password",
                              errorText: _validatePass
                                  ? "Password cannot be empty"
                                  : null,
                              errorStyle: TextStyle(
                                color: Colors.white,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                  //borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(50.0)),
                              enabledBorder: UnderlineInputBorder(
                                  //borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(50.0)),
                              border: UnderlineInputBorder(
                                  //borderSide: BorderSide(),
                                  borderRadius: BorderRadius.circular(50.0))),
                          obscureText: true,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {
                          _uname.text.isEmpty
                              ? _validateUname = true
                              : _validateUname = false;
                          _pass.text.isEmpty
                              ? _validatePass = true
                              : _validatePass = false;
                        });
                        if (!_validateUname && !_validatePass) {
                          final loginCredentials =
                              await fetchCredentials();
                          if (loginCredentials.userCredentials ==
                                  _uname.text.trim() &&
                              loginCredentials.passCredentials ==
                                  _pass.text.trim()) {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                                (r) => false);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text("Invalid username or password.")));
                          }
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 5.0,
                          minimumSize: Size(displayWidth(context) * 0.52,
                              displayHeight(context) * 0.074),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  displayWidth(context) * 0.25))),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Container(
                        height: displayHeight(context) * 0.1,
                        width: displayWidth(context) * 0.52,
                        child: FittedBox(
                          child: FloatingActionButton.extended(
                            heroTag: "CreateAccountBtn",
                            elevation: 5.0,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterNew()));
                            },
                            label: Text("Create Account"),
                            icon: Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: (displayHeight(context) -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight) *
                  0.15,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                      heroTag: "AboutBtn",
                      child: const Icon(Icons.help_outline_sharp),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutApp()));
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
