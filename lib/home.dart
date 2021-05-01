import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_project_ii/details.dart';
import 'package:mini_project_ii/orders.dart';
import 'login.dart';
import 'cart.dart';
import 'about.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';

int category = 0;

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

  Future<http.Response> getCategories() async {
    return http
        .get(Uri.http(serverURL, 'ShoppingAppServer/get_categories.php'));
  }

  Future<http.Response> _getPostsFromServer(
      String userID, int categoryID) async {
    return http.post(Uri.http(serverURL, 'ShoppingAppServer/get_posts.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'userID': userID, 'categoryID': categoryID}));
  }

  List<Widget> _buildHome(data) {
    List<Widget> posts = [];
    data.forEach(
      (d) async {
        posts.add(
          new ProductCard(
            productID: d['pid'],
            productName: d['name'],
            productMSRP: d['MSRP'],
            unitPrice: d['unitPrice'],
            productDescription: d['productDescription'],
            pictureURL: d['image'],
            cartID: d['cartID'],
            addedToCart: d['added'],
            categoryID: d['categoryID'],
            stock: d['stock'],
            userID: _uid,
          ),
        );
      },
    );
    return posts;
  }

  List<Widget> _buildDrawer(data) {
    List<Widget> drawerCategories = [];
    data.forEach(
      (d) {
        drawerCategories.add(
          ListTile(
            title: Text(d['CategoryName']),
            leading: Icon(Icons.arrow_forward_rounded),
            onTap: () {
              if (category == int.parse(d['CategoryID'])) {
                Navigator.pop(context);
              } else {
                setState(
                  () {
                    category = int.parse(d['CategoryID']);
                    _appBarTitle = d['CategoryName'];
                  },
                );
                getPosts();
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
    return drawerCategories;
  }

  getPosts() async {
    http.Response response = await _getPostsFromServer(_uid, category);
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
    getSharedPrefs().then((value) => getPosts());
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
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                              builder: (context) => ShoppingCart()),
                        )
                        .then(
                          (value) => setState(
                            () {
                              getPosts();
                            },
                          ),
                        );
                  },
                )
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
                    title: Text('Home'),
                    leading: Icon(Icons.home),
                    onTap: () {
                      if (category == 0) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          category = 0;
                          _appBarTitle = 'Home';
                        });
                        getPosts();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  FutureBuilder(
                      future: getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<Widget> drawerCategories =
                              _buildDrawer(jsonDecode((snapshot.data).body));
                          return Column(
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.only(top: 0.0),
                                shrinkWrap: true,
                                itemCount: drawerCategories.length,
                                itemBuilder: (context, index) {
                                  return drawerCategories[index];
                                },
                              ),
                            ],
                          );
                        } else {
                          return SizedBox(
                            height: 0.0,
                          );
                        }
                      }),
                  ListTile(
                    title: Text('My orders'),
                    leading: Icon(Icons.list_alt),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => OrderPage()));
                    },
                  ),
                  ListTile(
                    title: Text("About app"),
                    leading: Icon(Icons.help_outline_sharp),
                    onTap: () {
                      Navigator.pop(context);
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
                          MaterialPageRoute(builder: (context) => LoginForm()),
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
                      getPosts();
                    },
                    child: Center(
                      child: Text("Nothing here yet."),
                    ),
                  );
                } else {
                  List<Widget> posts = _buildHome(snapshot.data);
                  return RefreshIndicator(
                    onRefresh: () async {
                      getPosts();
                    },
                    child: GridView.builder(
                        itemCount: posts.length,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 0.95),
                        itemBuilder: (context, index) {
                          return posts[index];
                        }),
                  );
                }
              },
            ),
          );
        } else {
          return Scaffold(
            body: Center(child: Text("Loading...Please wait...")),
          );
        }
      },
    );
  }
}

// ignore: must_be_immutable
class ProductCard extends StatefulWidget {
  final String productName;
  final String productMSRP;
  final String unitPrice;
  final String productDescription;
  final String pictureURL;
  final String productID;
  final String userID;
  final String categoryID;
  final String stock;
  String cartID;
  String addedToCart = "False";

  ProductCard(
      {this.productID,
      this.productName,
      this.productMSRP,
      this.unitPrice,
      this.productDescription,
      this.pictureURL,
      this.cartID,
      this.userID,
      this.addedToCart,
      this.categoryID,
      this.stock});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  
  Future<http.Response> getCategoryName() {
    return http.post(Uri.http(serverURL, 'ShoppingAppServer/get_cat_name.php'),
    headers: <String,String> {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String,String> {
      'categoryID': widget.categoryID,
    }));
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () async {
          http.Response categoryName = await getCategoryName();
          print(categoryName.body);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetail(
                productMSRP: widget.productMSRP,
                productName: widget.productName,
                pictureURL: widget.pictureURL,
                unitPrice: widget.unitPrice,
                productDescription: widget.productDescription,
                userID: widget.userID,
                productID: widget.productID,
                categoryName: categoryName.body,
                stock: widget.stock
              ),
            ),
          );
        },
        child: Container(
          height: displayHeight(context) * 0.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3.0,
                    blurRadius: 5.0)
              ],
              color: Colors.white),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
              ),
              Hero(
                  tag: widget.productID,
                  child: Container(
                      height: displayHeight(context) * 0.1,
                      width: displayWidth(context) * 0.5,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: setImage(widget.pictureURL),
                              fit: BoxFit.contain)))),
              SizedBox(height: 6.0),
              Text('\u20B9' + widget.productMSRP,
                  style: TextStyle(color: Color(0xFFCC8053), fontSize: 15.0)),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(widget.productName,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: Color(0xFFCC8053), fontSize: 16.0)),
              ),
              Container(color: Color(0xFFEBEBEB), height: 0.4),
              TextButton(
                onPressed: () async {
                  if (int.parse(widget.stock) == 0) {
                    Fluttertoast.showToast(
                        msg: "Out of stock",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        fontSize: 12.0);
                  } else {
                    if (widget.addedToCart != "True") {
                      http.Response response =
                      await addToCart(widget.userID, widget.productID, 1);
                      if (response.body == "MAX") {
                        Fluttertoast.showToast(
                            msg: "Maximum limit reached",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            fontSize: 12.0);
                      } else if (response.body != "Failed") {
                        setState(
                              () {
                            widget.cartID = response.body;
                            widget.addedToCart = "True";
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Something went wrong.')));
                      }
                    } else {
                      http.Response response =
                      await removeFromCart(widget.cartID);
                      if (response.body == "Done") {
                        setState(
                              () {
                            widget.addedToCart = "False";
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Something went wrong.")));
                      }
                    }
                  }
                },
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                          (widget.addedToCart == "True")
                              ? Icons.check
                              : Icons.shopping_basket,
                          color: Color(0xFFD17E50),
                          size: 15.0),
                      Text(
                          (widget.addedToCart == "True")
                              ? "Added"
                              : "Add to cart",
                          style: TextStyle(
                              color: Color(0xFFD17E50), fontSize: 16.0))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}