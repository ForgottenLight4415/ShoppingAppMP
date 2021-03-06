import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';
import 'dart:convert';
import 'dart:async';
import 'confirmation_page.dart';

// Buy from product details page server communication function
Future<http.Response> _buyFromProductDesc(
    String productID, int quantity) async {
  return http.post(Uri.https(serverURL, 'ShoppingAppServer/buy_one.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'productID': productID,
        'userID': await getUID(),
        'quantity': quantity
      }));
}

// Customer details such as phone, email and address
Future<http.Response> _customerDetailsProvider() async {
  return http.post(
      Uri.https(serverURL, 'ShoppingAppServer/get_cust_details.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'userID': await getUID(),
      }));
}

Future<http.Response> buyOneFromCart(
    String productID, int quantity, String cartID) async {
  return http.post(
    Uri.https(serverURL, 'ShoppingAppServer/buy_cart.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, dynamic>{
        'productID': productID,
        'userID': await getUID(),
        'quantity': quantity,
        'cartID': cartID
      },
    ),
  );
}

Future<http.Response> checkoutCart() async {
  return http.post(
    Uri.https(serverURL, 'ShoppingAppServer/checkout_cart.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, String>{
        'userID': await getUID(),
      },
    ),
  );
}

class CheckoutDetail extends StatelessWidget {
  final totalPrice;
  final flag;
  final productID;
  final cartID;
  final quantity;
  final orderStatus = ['SUCCESS', 'SOME_ORDER_REFUSED', 'OUT_OF_STOCK'];

  CheckoutDetail(
      {this.totalPrice, this.flag, this.productID, this.quantity, this.cartID});

  _confirmationPageNavigator(String oStatus, BuildContext context) {
    int flag = orderStatus.indexOf(oStatus);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ConfirmationPage(flag)),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _customerDetailsProvider(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final customerData = jsonDecode((snapshot.data).body);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF545D68)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color(0xFF545D68),
                ),
              ),
              actions: <Widget>[],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Center(
                        child: Text(
                          'Delivery Address: ',
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6004C),
                          ),
                        ),
                      ),
                      SizedBox(height: displayWidth(context) * 0.03),
                      Center(
                        child: Text(
                          customerData[0]['address'],
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6004C),
                          ),
                        ),
                      ),
                      SizedBox(height: displayWidth(context) * 0.03),
                      Center(
                        child: Text(
                          customerData[0]['phone'],
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6004C),
                          ),
                        ),
                      ),
                      SizedBox(height: displayWidth(context) * 0.02),
                      Center(
                        child: Text(
                          customerData[0]['email'],
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.048,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE6004C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Center(
                        child: Text(
                          "You pay: ",
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          "\u{20B9}" + totalPrice.toString(),
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Center(
                        child: Text('No Contact Delivery - ',
                            style: TextStyle(
                              fontSize: displayWidth(context) * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            )),
                      ),
                      SizedBox(height: 8.0),
                      Center(
                        child: Text(
                          'Delivery Associate will place the order on your door step and step back to maintain a 2-meter distance. ',
                          style: TextStyle(
                            fontSize: displayWidth(context) * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width - 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Color(0xFFE6004C)),
                          child: InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return WillPopScope(
                                      onWillPop: () async => false,
                                      child: SimpleDialog(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                CircularProgressIndicator(),
                                                Text(
                                                  "Confirming your order",
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  });
                              if (flag == 1) {
                                http.Response response =
                                    await _buyFromProductDesc(
                                        productID, quantity);
                                if (response.statusCode == 200) {
                                  if (response.body == 'SUCCESS' || response.body == 'SOME_ORDER_REFUSED' || response.body == 'NOT_ENOUGH_STOCK') {
                                    _confirmationPageNavigator(
                                        response.body, context);
                                  } else {
                                    Navigator.pop(context);
                                    somethingWentWrongToast();
                                  }
                                } else {
                                  Navigator.pop(context);
                                  somethingWentWrongToast();
                                }
                              } else if (flag == 0) {
                                http.Response response = await buyOneFromCart(
                                    productID, quantity, cartID);
                                if (response.statusCode == 200) {
                                  if (response.body == 'SUCCESS' || response.body == 'SOME_ORDER_REFUSED' || response.body == 'NOT_ENOUGH_STOCK') {
                                    _confirmationPageNavigator(
                                        response.body, context);
                                  } else {
                                    Navigator.pop(context);
                                    somethingWentWrongToast();
                                  }
                                } else {
                                  Navigator.pop(context);
                                  somethingWentWrongToast();
                                }
                              } else if (flag == 2) {
                                http.Response response = await checkoutCart();
                                if (response.statusCode == 200) {
                                  if (response.body == 'SUCCESS' || response.body == 'SOME_ORDER_REFUSED' || response.body == 'NOT_ENOUGH_STOCK') {
                                    _confirmationPageNavigator(
                                        response.body, context);
                                  } else {
                                    Navigator.pop(context);
                                    somethingWentWrongToast();
                                  }
                                } else {
                                  Navigator.pop(context);
                                  somethingWentWrongToast();
                                }
                              } else {
                                Navigator.pop(context);
                                somethingWentWrongToast();
                              }
                            },
                            child: Center(
                              child: Text(
                                'Place Your Order',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0.0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF545D68)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: Text('Checkout',
                  style: TextStyle(fontSize: 20.0, color: Color(0xFF545D68))),
              actions: <Widget>[],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Loading"),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
