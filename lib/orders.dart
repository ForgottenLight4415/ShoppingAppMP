import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<http.Response> _getOrdersFromServer(String userID) {
    return http.post(Uri.http(serverURL, 'ShoppingAppServer/get_orders.php'),
    headers: <String,String> {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String,String> {'UserID': userID}));
  }

  _getOrders() async {
    String userID = await getUID();
    http.Response response = await _getOrdersFromServer(userID);
    if (response.body == "None") {
      _streamController.add(null);
    } else {
      _streamController.add(jsonDecode(response.body));
    }
  }

  _fontColorProvider(statusCode) {
    if (statusCode < 6) {
      return Color(0xFFFF6600);
    } else if (statusCode == 6 || statusCode == 7) {
      return Color(0xFF00CC00);
    } else if (statusCode == 8) {
      return Color(0xFF8C8C8C);
    } else if (statusCode == 9) {
      return Color(0xFFFF1A1A);
    }
  }

  _buildOrderCards(data) {
    List<Widget> orders = [];
    data.forEach((d) {
      orders.add(
        Padding(padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: displayHeight(context) * 0.23,
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
                    height: displayHeight(context) * 0.20,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: setImage(d['PictureURL']),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    height: displayHeight(context) * 0.20,
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
                        Text(d['StatusDesc'],
                        style: TextStyle(
                          fontSize: 15.0,
                          color: _fontColorProvider(int.parse(d['Status']))
                        ),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Visibility(
                                visible: (d['Status'] == '9')? false : true,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: Text((d['Status'] == '7') ? "Write a review" : "Cancel order"),
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
                            ),
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
    return orders;
  }

  @override
  void initState() {
    super.initState();
    _streamController = new StreamController();
    _stream = _streamController.stream;
    _getOrders();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
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
                children: <Widget>[
                  Text('No orders yet.', style:
                    TextStyle(
                      fontSize: displayWidth(context) * 0.05,
                      color: Colors.grey.shade700,
                    ),),
                  SizedBox(
                    height: displayHeight(context) * 0.03,
                  ),
                  ElevatedButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: Text('Search the store', style: TextStyle(
                    fontSize: displayWidth(context) * 0.05,
                  ),),
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
                    ),)
                ],
              ),
            );
          } else {
            List<Widget> posts = _buildOrderCards(snapshot.data);
            return RefreshIndicator(
              onRefresh: () async {
                _getOrders();
              },
              child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return posts[index];
                  }),
            );
          }
        },
      ),
    );
  }
}
