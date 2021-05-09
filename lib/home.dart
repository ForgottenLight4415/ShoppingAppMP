import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

// This variable is used to switch product categories from app drawer
int category = 0;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _uName;
  String _uEmail;
  String _uID;
  StreamController _streamController;
  Stream _stream;
  String _appBarTitle = "Home"; // Page title based on category

  // Gets Username, Email and UserID for drawer
  Future<List> _getSharedPrefs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _uName = pref.getString("Name");
    _uEmail = pref.getString("Email");
    _uID = pref.getString("UserID");
    return [_uName, _uEmail];
  }

  // Gets Category names for drawer
  Future<http.Response> _getCategories() async {
    return http
        .get(Uri.https(serverURL, 'ShoppingAppServer/get_categories.php'));
  }

  // Gets Product catalogue with its user specific meta data
  // in JSON format to build Catalogue page
  Future<http.Response> _getProductCatalogue(
      String userID, int categoryID) async {
    return http.post(Uri.https(serverURL, 'ShoppingAppServer/get_posts.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'userID': userID, 'categoryID': categoryID}));
  }

  // Builds the product catalogue on client
  List<Widget> _buildCatalogueUtility(data) {
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
            purchasedBefore: d['purchasedBefore'],
            userID: _uID,
          ),
        );
      },
    );
    return posts;
  }

  // Builds app drawer on home screen
  List<Widget> _buildDrawerUtility(data) {
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
                catalogueStreamUpdater();
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
    return drawerCategories;
  }

  // Calls the server to get product catalogue and updates the stream
  catalogueStreamUpdater() async {
    try {
      http.Response response = await _getProductCatalogue(_uID, category);
      if (response.body == "None") {
        _streamController.add(null);
      } else {
        _streamController.add(jsonDecode(response.body));
      }
    } on SocketException {
      Fluttertoast.showToast(
          msg: "Couldn't connect to server.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 12.0);
      sleep(Duration(seconds: 15));
      catalogueStreamUpdater();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _getSharedPrefs().then((value) => catalogueStreamUpdater());
  }

  // Main UI: AppBar, Drawer
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getSharedPrefs(),
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
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
                              catalogueStreamUpdater();
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
                        ), // Profile picture
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _uName.toUpperCase(),
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
                    decoration: BoxDecoration(color: Color(0xFFE6004C)),
                  ),
                  FutureBuilder(
                    future: _getCategories(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> drawerCategories = _buildDrawerUtility(
                            jsonDecode((snapshot.data).body));
                        return Column(
                          children: [
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
                                  catalogueStreamUpdater();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            ListView.builder(
                              padding: EdgeInsets.only(top: 0.0),
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemCount: drawerCategories.length,
                              itemBuilder: (context, index) {
                                return drawerCategories[index];
                              },
                            ),
                            ListTile(
                              title: Text('My orders'),
                              leading: Icon(Icons.list_alt),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OrderPage()));
                              },
                            ),
                            ListTile(
                              title: Text("About app"),
                              leading: Icon(Icons.help_outline_sharp),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AboutApp()),
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
                        );
                      } else {
                        return SizedBox(
                          height: 0.0,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: StreamBuilder<dynamic>(
              stream: _stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      catalogueStreamUpdater();
                    },
                    child: Center(
                      child: Text("Nothing here yet."),
                    ),
                  );
                } else {
                  List<Widget> _productCatalogueList =
                      _buildCatalogueUtility(snapshot.data);
                  return RefreshIndicator(
                    onRefresh: () async {
                      catalogueStreamUpdater();
                    },
                    child: GridView.builder(
                      itemCount: _productCatalogueList.length,
                      gridDelegate:
                          new SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.95),
                      itemBuilder: (context, index) {
                        return _productCatalogueList[index];
                      },
                    ),
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

// Individual product card from catalogue
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
  final String purchasedBefore;
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
      this.stock,
      this.purchasedBefore});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Future<http.Response> _getProductCategoryName() {
    return http.post(
      Uri.https(serverURL, 'ShoppingAppServer/get_cat_name.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'categoryID': widget.categoryID,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
        onTap: () async {
          http.Response categoryName = await _getProductCategoryName();
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
                stock: widget.stock,
                purchasedBefore: widget.purchasedBefore,
              ),
            ),
          );
        },
        child: Container(
          height: displayHeight(context) * 0.5,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.0),
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
                        fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(height: 6.0),
              Text('\u20B9' + widget.productMSRP,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 15.0)),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Text(widget.productName,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(color: Colors.blueGrey, fontSize: 16.0)),
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
                          color: Colors.blueGrey,
                          size: 15.0),
                      Text(
                          (widget.addedToCart == "True")
                              ? "Added"
                              : "Add to cart",
                          style: TextStyle(
                              color: Colors.blueGrey, fontSize: 16.0))
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
