import 'package:flutter/material.dart';
import 'package:mini_project_ii/register.dart';
import 'home.dart';
import 'about.dart';
import 'register.dart';

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
        padding: const EdgeInsets.fromLTRB(10.0, 100.0, 10.0, 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 150.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.redAccent,
                          width: 5.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(115.0),
                      color: Colors.blueGrey),
                  child: Icon(
                    Icons.person,
                    size: 100.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
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
                        padding: const EdgeInsets.all(3.0),
                        child: TextFormField(
                          controller: _pass,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_rounded),
                              labelText: "Password",
                              hintText: "Enter your password",
                              errorText:
                              _validatePass ? "Password cannot be empty" : null,
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
                    SizedBox(
                      height: 25.0,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _uname.text.isEmpty
                              ? _validateUname = true
                              : _validateUname = false;
                          _pass.text.isEmpty
                              ? _validatePass = true
                              : _validatePass = false;
                        });
                        if (!_validateUname && !_validatePass) {
                          //ScaffoldMessenger.of(context)
                          //  .showSnackBar(SnackBar(content: Text("Validating")));
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                                  (r) => false);
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
                          elevation: 10.0,
                          minimumSize: Size(180, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 50.0,
                      width: 180.0,
                      child: FittedBox(
                        child: FloatingActionButton.extended(
                          heroTag: "CreateAccountBtn",
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterNew()));
                          },
                          label: Text("Create Account"),
                          icon: Icon(Icons.add),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 125.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                    heroTag: "AboutBtn",
                    child: const Icon(Icons.help_outline_sharp),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AboutApp()));
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }
}