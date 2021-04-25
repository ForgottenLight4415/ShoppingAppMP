import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
  String _uEmail;
  String _uid;
  StreamController _streamController;
  Stream _stream;
  String _appBarTitle = "Home";

  Future<List> getSharedPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _uname = pref.getString("Name");
    _uEmail = pref.getString("Email");
    _uid = pref.getString("UserID");
    return [_uname, _uEmail];
  }

  Future<http.Response> _getPostsFromServer(String userID) async {
    return http.post(Uri.http(serverURL, 'ShoppingApp/get_posts.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'userID': userID}));
  }

  Future<http.Response> _addToCart(
      String userID, String productID, int quantity) async {
    return http.post(Uri.http(serverURL, 'ShoppingApp/add_cart.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userID': userID,
          'productID': productID,
          'quantity': quantity
        }));
  }

  Future<http.Response> removeFromCart(String cartID) {
    return http.post(Uri.http(serverURL, 'ShoppingApp/remove_cart.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'CartID': cartID,
        }));
  }

  Widget _buildCard(String name, String price, String imgPath, String productID,
      added, cartID, context) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        child: InkWell(
            onTap: () {},
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3.0,
                          blurRadius: 5.0)
                    ],
                    color: Colors.white),
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                  ),
                  Hero(
                      tag: name,
                      child: Container(
                          height: displayHeight(context) * 0.1,
                          width: displayWidth(context) * 0.5,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: setImage(imgPath),
                                  fit: BoxFit.contain)))),
                  SizedBox(height: 7.0),
                  Text('\u20B9' + price,
                      style: TextStyle(
                          color: Color(0xFFCC8053),
                          fontFamily: 'OpenSans',
                          fontSize: 15.0)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                            color: Color(0xFFCC8053),
                            fontFamily: 'OpenSans',
                            fontSize: 16.0)),
                  ),
                  Container(color: Color(0xFFEBEBEB), height: 0.4),
                  TextButton(
                    onPressed: () async {
                      if (added != "True") {
                        http.Response response =
                        await _addToCart(_uid, productID, 1);
                        print(response.body);
                        if (response.body == "Done") {
                          _getPosts();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Something went wrong.')));
                        }
                      } else {
                        http.Response response =
                        await removeFromCart(cartID);
                        print(cartID);
                        if (response.body == "Done") {
                          _getPosts();
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                              content: Text(
                                  "Something went wrong.")));
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon((added == "True") ? Icons.check : Icons.shopping_basket,
                            color: Color(0xFFD17E50), size: 15.0),
                        Text((added == "True") ? "Added" : "Add to cart",
                            style: TextStyle(
                                fontFamily: 'Open Sans',
                                color: Color(0xFFD17E50),
                                fontSize: 16.0))
                      ],
                    ),
                  ),
                ]))));
  }

  List<Widget> _buildHome(data) {
    List<Widget> posts = [];
    data.forEach((d) async {
      posts.add(_buildCard(
          d['name'], d['MSRP'], d['image'], d['pid'], d['added'], d['cartID'], context));
    });
    return posts;
  }

  _getPosts() async {
    print(_uid);
    http.Response response = await _getPostsFromServer(_uid);
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    getSharedPrefs().then((value) => _getPosts());
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
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                  builder: (context) => ShoppingCart()),
                            )
                            .then((value) => setState(() {
                                  _getPosts();
                                }));
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
                                  _uEmail,
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
                      return RefreshIndicator(
                        onRefresh: () async {
                          _getPosts();
                        },
                        child: Center(
                          child: Text("Nothing here yet."),
                        ),
                      );
                    } else {
                      List<Widget> posts = _buildHome(snapshot.data);
                      return RefreshIndicator(
                        onRefresh: () async {
                          _getPosts();
                        },
                        child: GridView.builder(
                            itemCount: posts.length,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemBuilder: (context, index) {
                              return posts[index];
                            }),
                      );
                    }
                  }),
            );
          } else {
            return Scaffold(
              body: Center(child: Text("Loading...Please wait...")),
            );
          }
        });
  }
}
