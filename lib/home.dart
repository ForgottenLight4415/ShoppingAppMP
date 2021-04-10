import 'package:flutter/material.dart';
import 'login.dart';
import 'cart.dart';
import 'about.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _uname;
  String _uid;

  Future<List> getSharedPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _uname = pref.getString("Name");
    _uid = pref.getString("Email");
    return [_uname, _uid];
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSharedPrefs(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Dashboard"),
              actions: <Widget>[
                IconButton(icon: Icon(Icons.search), onPressed: () {}),
                IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => ShoppingCart()));
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
                          height: 75.0,
                          width: 75.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.white),
                          child: Icon(Icons.person),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _uname.toUpperCase(),
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white),
                              ),
                              Text(
                                _uid,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.white),
                              ),
                            ],
                          ),
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
                    onTap: () async {
                      SharedPreferences pref = await SharedPreferences
                          .getInstance();
                      pref?.setBool("isLoggedIn", false);
                      pref?.setString("Name", "");
                      pref?.setString("Email", "");
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginForm()),
                              (route) => false);
                    },
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: Text("Homepage"),
          );
        } else {
          return Scaffold(
            body: Text("Loading..."),
          );
        }
      }
    );
  }
}
