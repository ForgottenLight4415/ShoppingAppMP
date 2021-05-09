import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'helpers.dart';
import 'checkout.dart';

Future<http.Response> addToCart(
    String userID, String productID, int quantity) async {
  return http.post(
    Uri.https(serverURL, 'ShoppingAppServer/add_cart.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, dynamic>{
        'userID': userID,
        'productID': productID,
        'quantity': quantity
      },
    ),
  );
}

Future<http.Response> removeFromCart(String cartID) {
  return http.post(
    Uri.https(serverURL, 'ShoppingAppServer/remove_cart.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, String>{
        'CartID': cartID,
      },
    ),
  );
}

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  StreamController _streamController;
  Stream _stream;

  Future<http.Response> _getUserCart(String userID) {
    return http.post(
      Uri.https(serverURL, 'ShoppingAppServer/get_cart.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'uid': userID,
        },
      ),
    );
  }

  _cartPageStreamUpdater() async {
    String userID = await getUID();
    http.Response response = await _getUserCart(userID);
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  _cartPageBuilder(data) {
    List<Widget> cart = [];
    data.forEach(
      (d) {
        cart.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: displayHeight(context) * 0.20,
                  width: displayWidth(context),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: const Offset(2.5, 2.5),
                          blurRadius: 5.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(14.0)),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.all(10.0),
                        width: displayWidth(context) * 0.38,
                        height: displayHeight(context) * 0.16,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: setImage(d['PictureURL']),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        height: displayHeight(context) * 0.18,
                        width: displayWidth(context) * 0.48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              d['ProductName'],
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 20.0,
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              "\u{20B9} " + double.parse(d['MSRP']).toString(),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Color(0xFF595959),
                              ),
                            ),
                            Text(
                              "Quantity: " + d['Quantity'],
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Color(0xFF595959),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      http.Response response =
                                          await removeFromCart(d['CartID']);
                                      if (response.body == "Done") {
                                        _cartPageStreamUpdater();
                                      } else {
                                        somethingWentWrongToast();
                                      }
                                    },
                                    child: Text("Remove"),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.pressed))
                                            return Colors.orange;
                                          return Color(
                                              0xFFE6004C); // Use the component's default.
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (int.parse(d['UnitsInStock']) == 0) {
                                        Fluttertoast.showToast(
                                            msg: "Out of stock",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            fontSize: 12.0);
                                      } else {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CheckoutDetail(
                                              totalPrice:
                                                  int.parse(d['Quantity']) *
                                                      double.parse(d['MSRP']),
                                              cartID: d['CartID'],
                                              productID: d['ProductID'],
                                              quantity:
                                                  int.parse(d['Quantity']),
                                              flag: 0,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text("Buy"),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                        (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.pressed))
                                            return Colors.red;
                                          return Color(
                                              0xFFE6004C); // Use the component's default.
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
    return cart;
  }

  double _getCartValue(data) {
    double value = 0;
    data.forEach(
      (d) {
        int quantity = int.parse(d['Quantity']);
        int maxPrice = int.parse(d['MSRP']);
        value += (maxPrice * quantity);
      },
    );
    return value;
  }

  int _getCartSize(data) {
    int cartSize = 0;
    data.forEach(
      (d) {
        cartSize += int.parse(d['Quantity']);
      },
    );
    return cartSize;
  }

  @override
  void initState() {
    super.initState();
    _streamController = new StreamController();
    _stream = _streamController.stream;
    _cartPageStreamUpdater();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Cart"),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Nothing to show here!"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Start by adding a few items from store."),
                  )
                ],
              ),
            );
          } else {
            List<Widget> posts = _cartPageBuilder(snapshot.data);
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return posts[index];
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                    )
                  ]),
                  child: BottomAppBar(
                    color: Color(0xFFFFFFFF),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        width: displayWidth(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Total items: ' +
                                      _getCartSize(snapshot.data).toString(),
                                  style: TextStyle(
                                      fontSize: displayWidth(context) * 0.035,
                                      color: Color(0xFF595959)),
                                ),
                                Text(
                                  'Cart total: \u20B9' +
                                      _getCartValue(snapshot.data).toString(),
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                      fontSize: displayWidth(context) * 0.045,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF595959)),
                                ),
                              ],
                            ),
                            FloatingActionButton.extended(
                              onPressed: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutDetail(
                                      totalPrice: _getCartValue(snapshot.data),
                                      flag: 2,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Checkout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Color(0xFFE6004C),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
