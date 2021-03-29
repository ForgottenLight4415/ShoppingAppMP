import 'package:flutter/material.dart';
import 'main.dart';
import 'cart.dart';
import 'about.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _uname = "Vishal Pednekar";
  final String _uid = "ACC0001";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Dashboard"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: () {}),
            IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ShoppingCart()));
                })
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: Colors.white),
                      child: Icon(Icons.person),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _uname.toUpperCase(),
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                        Text(
                          "UID: " + _uid,
                          style: TextStyle(fontSize: 15.0, color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(color: Colors.red),
              ),
              ListTile(
                title: Text("About app"),
                leading: Icon(Icons.help_outline_sharp),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutApp()),
                          );
                },
              ),
              ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.logout),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: Text("Homepage"),
    );
  }
}
