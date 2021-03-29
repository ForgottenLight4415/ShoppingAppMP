import 'package:flutter/material.dart';

class RegisterNew extends StatefulWidget {
  @override
  _RegisterNewState createState() => _RegisterNewState();
}

class _RegisterNewState extends State<RegisterNew> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Form(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "First name",
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Last name",
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Phone",
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Address",
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Username",
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                  ),
                ),
                SizedBox(height: 15.0,),
                TextButton(onPressed: () {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Registering you...")));
                }, child: Text(
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
                          borderRadius: BorderRadius.circular(30.0))),),
                SizedBox(height: 10.0,),
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text("Cancel", style: TextStyle(fontSize: 20.0),))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
