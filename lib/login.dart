import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register.dart';
import 'home.dart';
import 'about.dart';
import 'helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> getCredentialsFromServer(String uName, String uPass) {
  return http.post(Uri.http('192.168.0.6:8080', 'ShoppingApp/login.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'username': uName, 'password': uPass}));
}

void login(username, password, context) async {
  try {
    final loginCredentials =
        await getCredentialsFromServer(
        username.trim(),
        password);
    var serverResponse =
    loginCredentials.body
        .split(';');
    if (loginCredentials
        .statusCode ==
        200) {
      if (serverResponse[0] ==
          "true") {
        SharedPreferences pref =
            await SharedPreferences
            .getInstance();
        pref?.setBool(
            "isLoggedIn", true);
        pref?.setString("Name",
            serverResponse[1]);
        pref?.setString("Email",
            serverResponse[2]);
        pref?.setString("UserID",
            serverResponse[3]);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder:
                    (context) =>
                    HomePage()),
                (r) => false);
      } else {
        ScaffoldMessenger.of(
            context)
            .showSnackBar(SnackBar(
            content: Text(
                "Invalid username or password.")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
          content: Text(
              "Something went wrong.")));
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
        content: Text(
            "Failed to connect to server.")));
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

  final AssetImage loginBGI = AssetImage("images/login_bg.jpg");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: loginBGI,
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            color: Colors.black.withOpacity(0.15),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Sign in to your account",
                      style: TextStyle(
                          fontFamily: "Open Sans",
                          fontSize: 48.0,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: displayHeight(context) * 0.05,
                    ),
                    Container(
                      height: displayHeight(context) * 0.30,
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  3.0, 0.0, 3.0, 8.0),
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
                                      borderRadius:
                                          BorderRadius.circular(50.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    border: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(50.0))),
                              ),
                            ),
                          ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  3.0, 1.5, 3.0, 20.0),
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
                                      borderRadius:
                                          BorderRadius.circular(50.0),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        //borderSide: BorderSide(),
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    enabledBorder: UnderlineInputBorder(
                                        //borderSide: BorderSide(),
                                        borderRadius:
                                            BorderRadius.circular(50.0)),
                                    border: UnderlineInputBorder(
                                        //borderSide: BorderSide(),
                                        borderRadius:
                                            BorderRadius.circular(50.0))),
                                obscureText: true,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Container(
                                  height: displayHeight(context) * 0.06,
                                  width: displayWidth(context) * 0.3,
                                  child: FittedBox(
                                    child: FloatingActionButton.extended(
                                      backgroundColor: Colors.white,
                                      heroTag: "LoginBtn",
                                      elevation: 5.0,
                                      onPressed: () async {
                                        setState(() {
                                          _uname.text.isEmpty
                                              ? _validateUname = true
                                              : _validateUname = false;
                                          _pass.text.isEmpty
                                              ? _validatePass = true
                                              : _validatePass = false;
                                        });
                                        if (!_validateUname &&
                                            !_validatePass) {
                                          login(_uname.text, _pass.text, context);
                                        }
                                      },
                                      label: Text(
                                        "Login",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 1.0),
                                child: Container(
                                  height: displayHeight(context) * 0.06,
                                  width: displayWidth(context) * 0.55,
                                  child: FittedBox(
                                    child: FloatingActionButton.extended(
                                      backgroundColor: Colors.white,
                                      heroTag: "CreateAccountBtn",
                                      elevation: 5.0,
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RegisterNew()));
                                      },
                                      label: Text(
                                        "Create Account",
                                        style: TextStyle(
                                            color:
                                                Colors.blueGrey.shade700),
                                      ),
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.blueGrey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          heroTag: "AboutBtn",
          child: Icon(Icons.info_outlined,
              color: Colors.blueGrey.shade700),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutApp()));
          }),
    );
  }
}
