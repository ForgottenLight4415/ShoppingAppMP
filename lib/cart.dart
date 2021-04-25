import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  StreamController _streamController;
  Stream _stream;

  Future<String> getUID() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("UserID");
  }

  Future<http.Response> getCartFromServer(String userID) {
    return http.post(Uri.http(serverURL, 'ShoppingApp/get_cart.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'uid': userID,
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

  _getCart() async {
    String userID = await getUID();
    http.Response response = await getCartFromServer(userID);
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  NetworkImage _setImage(imgURL) {
    if (imgURL == null) {
      return NetworkImage(
          'http://$serverURL/ShoppingApp/Assets/NoIMG/no-img.png');
    } else {
      return NetworkImage(imgURL);
    }
  }

  _buildCart(data) {
    List<Widget> cart = [];
    data.forEach((d) {
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
                    borderRadius: BorderRadius.circular(10.0)),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10.0),
                      width: displayWidth(context) * 0.38,
                      height: displayHeight(context) * 0.16,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: _setImage(d['PictureURL']),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      height: displayHeight(context) * 0.16,
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
                              fontSize: 18.0,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "\u{20B9} " + d['MSRP'],
                            style: TextStyle(fontSize: 18.0),
                          ),
                          Text(
                            "Quantity: " + d['Quantity'],
                            style: TextStyle(fontSize: 18.0),
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
                                      _getCart();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Something went wrong.")));
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
                                        return Colors
                                            .red; // Use the component's default.
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Buy"),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.pressed))
                                          return Colors.orange;
                                        return Colors
                                            .red; // Use the component's default.
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
    });
    return cart;
  }

  @override
  void initState() {
    super.initState();
    _streamController = new StreamController();
    _stream = _streamController.stream;
    _getCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Colors.red,
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
            ));
          } else {
            List<Widget> posts = _buildCart(snapshot.data);
            return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return posts[index];
                });
          }
        },
      ),
    );
  }
}
