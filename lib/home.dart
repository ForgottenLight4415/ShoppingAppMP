import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'login.dart';
import 'cart.dart';
import 'about.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _uname;
  String _uid;
  StreamController _streamController;
  Stream _stream;
  String _appBarTitle = "Home";

  Future<List> getSharedPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _uname = pref.getString("Name");
    _uid = pref.getString("Email");
    return [_uname, _uid];
  }

  Future<http.Response> _getPostsFromServer() async {
    return http.get(
      Uri.http('192.168.1.55:8080', 'ShoppingApp/get_posts.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
  Widget _buildCard(String name,String price, String imgPath,context){
    return Padding(
        padding: EdgeInsets.only(top:5.0,bottom:5.0,left:5.0,right:5.0),
        child:InkWell(
            onTap:(){},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius:3.0,
                          blurRadius:5.0

                      )

                    ],
                    color: Colors.white

                ),
                child: Column(
                  children: [
                    Padding(
                      padding:EdgeInsets.all(5.0),
                    ),
                    Hero(
                        tag: 'dash',
                        child:Container(
                            height:90.0,
                            width:75.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: setImage(imgPath),
                                    fit:BoxFit.contain
                                )
                            )
                        )
                    ),
                    SizedBox(height:7.0),
                    Text(
                        price,
                        style:TextStyle(
                            color:Color(0xFFCC8053),
                            fontFamily: 'OpenSans',
                            fontSize: 15.0
                        )),
                    Text(name,
                        style: TextStyle(
                            color:Color(0xFFCC8053),
                            fontFamily: 'OpenSans',
                            fontSize: 16.0
                        )
                    ),
                    Padding(
                        padding:EdgeInsets.all(20.0),
                        child:Container(
                            color:Color(0xFFEBEBEB),
                            height:0.4
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(left:15.0,right:15.0,bottom:8.0),
                        child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly ,
                            children:[

                        Icon(Icons.shopping_basket,
                        color:Color(0xFFD17E50),
                        size:15.0
                    ),
                    Text('Add to cart',
                        style:TextStyle(
                            fontFamily:'Trajan Pro',
                            color: Color(0xFFD17E50),
                            fontSize: 16.0
                        ))


              ],
           ),

            ),
    ]))) );

  }
  List<Widget> _buildHome(data){
    List<Widget> posts=[];
    data.forEach((d){
      print(d);
      posts.add(
        _buildCard(d['name'],d['MSRP'],d['image'], context)

      );

    }

    );
    return posts;
  }

  _displayPosts() async {
    http.Response response = await _getPostsFromServer();
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  @override
  void initState() {
    super.initState();
    getSharedPrefs();

    _streamController = StreamController();
    _stream = _streamController.stream;
    _displayPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSharedPrefs(),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_appBarTitle),
                actions: <Widget>[
                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
                  IconButton(
                      icon: Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                            context,
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
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref?.setBool("isLoggedIn", false);
                        pref?.setString("Name", "");
                        pref?.setString("Email", "");
                        pref?.setString("UserID", "");
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginForm()),
                            (route) => false);
                      },
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.white,
              body: StreamBuilder<dynamic>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(
                      child: Text("Nothing here yet."),
                    );
                  }

                  else {
                    List<Widget> posts = _buildHome(snapshot.data);
                    return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return posts[index];
                        });
                  }

                }
              ),
            );
          } else {
            return Scaffold(
              body: Center(child: Text("Loading...Please wait...")),
            );
          }
        });
  }
}
