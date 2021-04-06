import 'dart:convert';
import 'registration_success.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> registerUser(String fName, String lName, String phone,
    String email, String address, String uName, String passw) {
  return http.post(Uri.http('192.168.0.6:8080', 'ShoppingApp/register.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'first': fName,
        'last': lName,
        'phone': phone,
        'email': email,
        'addr': address,
        'uName': uName,
        'passwd': passw
      }));
}

class RegisterNew extends StatefulWidget {
  @override
  _RegisterNewState createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterNew> {
  final _fName = TextEditingController();
  final _lName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _addrs = TextEditingController();
  final _uName = TextEditingController();
  final _uPass = TextEditingController();
  final _cPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _validateFName = false;
  bool _validateLName = false;
  bool _validatePhone = false;
  bool _validateEmail = false;
  bool _validateAddrs = false;
  bool _validateUName = false;
  bool _validateUPass = false;
  bool _validateCPass = false;

  String uNameErrorText = "Invalid username";
  String emailErrorText = "Invalid email";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _fName,
                  decoration: InputDecoration(
                    labelText: "First name",
                    errorText:
                        _validateFName ? "This is a required field" : null,
                  ),
                ),
                TextFormField(
                  controller: _lName,
                  decoration: InputDecoration(
                    labelText: "Last name",
                    errorText:
                        _validateLName ? "This is a required field" : null,
                  ),
                ),
                TextFormField(
                  controller: _phone,
                  decoration: InputDecoration(
                    labelText: "Phone",
                    errorText: _validatePhone ? "Invalid phone number" : null,
                  ),
                ),
                TextFormField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    errorText: _validateEmail ? emailErrorText : null,
                  ),
                ),
                TextFormField(
                  controller: _addrs,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Address",
                    errorText:
                        _validateAddrs ? "This is a required field" : null,
                  ),
                ),
                TextFormField(
                  controller: _uName,
                  decoration: InputDecoration(
                    labelText: "Username",
                    errorText: _validateUName ? uNameErrorText : null,
                  ),
                ),
                TextFormField(
                  controller: _uPass,
                  decoration: InputDecoration(
                    labelText: "Password",
                    errorText:
                        _validateUPass ? "Password cannot be empty" : null,
                  ),
                  obscureText: true,
                ),
                TextFormField(
                  controller: _cPass,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    errorText: _validateCPass ? "Passwords do not match" : null,
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: 15.0,
                ),
                TextButton(
                  onPressed: () async {
                    setState(() {
                      _fName.text.isEmpty
                          ? _validateFName = true
                          : _validateFName = false;
                      _lName.text.isEmpty
                          ? _validateLName = true
                          : _validateLName = false;
                      _phone.text.isEmpty ||
                              !_phone.text.contains(new RegExp(r'[0-9]{10}'))
                          ? _validatePhone = true
                          : _validatePhone = false;
                      _email.text.isEmpty ||
                              !_email.text.contains(new RegExp(
                                  r'^[A-Za-z][A-z0-9_.]*[@][a-z0-9\-]+[.][a-z]{2,3}[.]?[a-z]{0,2}'))
                          ? _validateEmail = true
                          : _validateEmail = false;
                      _addrs.text.isEmpty
                          ? _validateAddrs = true
                          : _validateAddrs = false;
                      _uName.text.isEmpty
                          ? _validateUName = true
                          : _validateUName = false;
                      _uPass.text.isEmpty
                          ? _validateUPass = true
                          : _validateUPass = false;
                      _cPass.text.isEmpty || _cPass.text != _uPass.text
                          ? _validateCPass = true
                          : _validateCPass = false;
                    });
                    if (!_validateFName &&
                        !_validateLName &&
                        !_validatePhone &&
                        !_validateEmail &&
                        !_validateAddrs &&
                        !_validateUName &&
                        !_validateUPass &&
                        !_validateCPass) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Registering you...")));
                      final registerResponse = await registerUser(
                          _fName.text.trim(),
                          _lName.text.trim(),
                          _phone.text.trim(),
                          _email.text.trim(),
                          _addrs.text.trim(),
                          _uName.text.trim(),
                          _uPass.text);
                      print(registerResponse.body);
                      if (registerResponse.statusCode == 200) {
                        if (registerResponse.body == '1') {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RegistrationSuccess()),
                                  (route) => false);
                          SharedPreferences pref = await SharedPreferences.getInstance();
                          pref?.setBool('isLoggedIn', true);
                        } else if (registerResponse.body == '2') {
                          setState(() {
                            _validateEmail = true;
                            emailErrorText = "Email already exits";
                          });
                        } else if (registerResponse.body == '3') {
                          setState(() {
                            _validateUName = true;
                            uNameErrorText = "Username already taken";
                          });
                        }
                      }
                    }
                  },
                  child: Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 3.0,
                      minimumSize: Size(125, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                ),
                SizedBox(
                  height: 10.0,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 20.0),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
