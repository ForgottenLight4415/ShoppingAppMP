import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_project_ii/details.dart';
import 'dart:async';
import 'helpers.dart';
import 'package:http/http.dart' as http;

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  StreamController _streamController;
  Stream _stream;

  Future<http.Response> _getUserOrders(String userID) {
    return http.post(
      Uri.https(serverURL, 'ShoppingAppServer/get_orders.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{'UserID': userID},
      ),
    );
  }

  Future<http.Response> _cancelOrder(String orderID) {
    return http.post(
      Uri.https(serverURL, 'ShoppingAppServer/cancel.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, String>{
          'orderID': orderID,
        },
      ),
    );
  }

  Future<void> _cancelAlert(
      String productName, String quantity, String orderID) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel order'),
          content: Text(
              "Do you really want to cancel your order for \"$productName\" (Quantity: $quantity)"),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No')),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  http.Response response = await _cancelOrder(orderID);
                  if (response.statusCode == 200) {
                    if (response.body == "CANCELLED") {
                      Fluttertoast.showToast(
                          msg: "Order cancelled",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          fontSize: 12.0);
                      _orderPageStreamUpdater();
                    } else {
                      somethingWentWrongToast();
                    }
                  } else {
                    somethingWentWrongToast();
                  }
                },
                child: const Text('Yes'))
          ],
        );
      },
    );
  }

  void _orderPageStreamUpdater() async {
    String userID = await getUID();
    http.Response response = await _getUserOrders(userID);
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  Color _dstFontColorProvider(int statusCode) {
    if (statusCode < 6) {
      return Color(0xFFFF6600);
    } else if (statusCode == 6 || statusCode == 7) {
      return Color(0xFF00CC00);
    } else if (statusCode == 8) {
      return Color(0xFF8C8C8C);
    } else {
      return Color(0xFFFF1A1A);
    }
  }

  List<Widget> _buildOrderCards(List data) {
    final Size size = displaySize(context);
    final double height = size.height;
    final double width = size.width;

    List<Widget> orders = [];
    data.forEach(
      (d) {
        orders.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  height: height * 0.25,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        const BoxShadow(
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
                        margin: const EdgeInsets.all(8.0),
                        width: width * 0.35,
                        height: height * 0.20,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: setImage(d['PictureURL']),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          height: height * 0.24,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                d['ProductName'],
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 3.0,
                              ),
                              Text(
                                "\u{20B9} " + d['MSRP'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              Text(
                                "Quantity: " + d['Quantity'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                d['StatusDesc'],
                                style: TextStyle(
                                    fontSize: 14,
                                    color: _dstFontColorProvider(
                                        int.parse(d['Status']))),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible:
                                        (d['Status'] == '9') ? false : true,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        int delStatus = int.parse(d['Status']);
                                        if (delStatus == 7) {
                                          String _uid = await getUID();
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductDetail(
                                                        pictureURL:
                                                            d['PictureURL'],
                                                        productMSRP: d['MSRP'],
                                                        productName:
                                                            d['ProductName'],
                                                        unitPrice:
                                                            d['unitPrice'],
                                                        productDescription: d[
                                                            'productDescription'],
                                                        productID:
                                                            d['ProductID'],
                                                        cartID: d['cartID'],
                                                        userID: _uid,
                                                        stock: d['stock'],
                                                        purchasedBefore: d[
                                                            'purchasedBefore'],
                                                        categoryName:
                                                            d['categoryName'],
                                                      )));
                                        } else if (delStatus == 8 ||
                                            delStatus < 7) {
                                          _cancelAlert(d['ProductName'],
                                              d['Quantity'], d['OrderNo']);
                                        }
                                      },
                                      child: Text((d['Status'] == '7')
                                          ? "Write a review"
                                          : "Cancel order"),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.pressed))
                                              return Colors.red.shade700;
                                            return Color(
                                                0xFFE6004C); // Use the component's default.
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
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
    return orders;
  }

  @override
  void initState() {
    super.initState();
    _streamController = new StreamController();
    _stream = _streamController.stream;
    _orderPageStreamUpdater();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = displaySize(context);
    final double width = size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Orders'),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                  'We are experiencing some problems right now. Please try again later.'),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              continue waiting;
            waiting:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10.0,),
                    const Text("Loading")
                  ],
                ),
              );
            case ConnectionState.active:
              continue data_ready;
            data_ready:
            case ConnectionState.done:
              if (snapshot.data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'No orders yet.',
                        style: TextStyle(
                          fontSize: width * 0.05,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Search the store',
                          style: TextStyle(
                            fontSize: width * 0.05,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed))
                                return Colors.red.shade700;
                              return Color(
                                  0xFFE6004C); // Use the component's default.
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                List<Widget> posts = _buildOrderCards(snapshot.data);
                return RefreshIndicator(
                  onRefresh: () async {
                    _orderPageStreamUpdater();
                  },
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return posts[index];
                    },
                  ),
                );
              }
          }
          return null;
        },
      ),
    );
  }
}
