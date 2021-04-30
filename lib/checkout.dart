import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helpers.dart';
import 'dart:convert';
import 'dart:async';

// Buy from product details page server communication function
Future<http.Response> buyFromProductDescription(
    String productID, int quantity) async {
  return http.post(Uri.http(serverURL, 'ShoppingAppServer/buy_one.php'),
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
Future<http.Response> customerDetailsProvider() async {
  return http.post(Uri.http(serverURL, 'ShoppingAppServer/get_cust_details.php'),
      headers: <String,String> {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String,String> {
        'userID': await getUID(),
      }));
}

Future<http.Response> buyOneFromCart(
    String productID, int quantity, String cartID) async {
  return http.post(
    Uri.http(serverURL, 'ShoppingAppServer/buy_cart.php'),
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
    Uri.http(serverURL, 'ShoppingAppServer/checkout_cart.php'),
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
  final totalPrice; final flag;final productID; final cartID; final quantity;
  CheckoutDetail({this.totalPrice,this.flag,this.productID,this.quantity,this.cartID});
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future:customerDetailsProvider(),
       builder:(context,snapshot) {
         if (snapshot.hasData) {
          final customerData = jsonDecode((snapshot.data).body);
          print(customerData);
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
                   style: TextStyle(
                       fontFamily: 'Trajan Pro',
                       fontSize: 20.0,
                       color: Color(0xFF545D68))),
               actions: <Widget>[
               ],
             ),


             body: Padding(
               padding: const EdgeInsets.all(8.0),
               child: ListView(
                   children: [
                     SizedBox(height: 15.0),
                     Center(
                       child: Text('Delivery Address: ',
                           style: TextStyle(
                               fontFamily: 'Trajan Pro',
                               fontSize: 20.0,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFFF17532)
                           )
                       ),
                     ),
                     SizedBox(height: 15.0),
                     Center(
                       child: Text(customerData[0]['address'],
                           style: TextStyle(
                               fontFamily: 'Trajan Pro',
                               fontSize: 20.0,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFFF17532)
                           )
                       ),
                     ),
                     SizedBox(height: 15.0),
                     Center(
                       child: Text(customerData[0]['phone'],
                           style: TextStyle(
                               fontFamily: 'Trajan Pro',
                               fontSize: 20.0,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFFF17532)
                           )
                       ),
                     ),
                     SizedBox(height: 15.0),
                     Center(
                       child: Text(customerData[0]['email'],
                           style: TextStyle(
                               fontFamily: 'Trajan Pro',
                               fontSize: 20.0,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFFF17532)
                           )
                       ),
                     ),
                     SizedBox(height: 20.0),
                     Center(
                       child: Text( "\u{20B9}"+totalPrice.toString()  ,
                           style: TextStyle(
                               fontFamily: 'Trajan Pro',
                               fontSize: 20.0,
                               fontWeight: FontWeight.bold,
                               color: Color(0xFFF17532)
                           )
                       ),
                     ),

                     SizedBox(height: 400.0),
                     Center(
                       child: Text('No Contact Delivery - ',
                           style: TextStyle(
                             fontFamily: 'Trajan Pro',
                             fontSize: 20.0,
                             fontWeight: FontWeight.bold,
                             color: Colors.green,
                           )
                       ),
                     ),
                     SizedBox(height: 10.0),
                     Center(
                       child: Text(
                           'Delivery Associate will place the order on your door step and step back to maintain a 2-meter distance. ',
                           style: TextStyle(
                             fontFamily: 'Trajan Pro',
                             fontSize: 20.0,
                             fontWeight: FontWeight.bold,
                             color: Colors.green,
                           )
                       ),
                     ), SizedBox(height: 15.0),
                     Center(
                         child: Container(
                             width: MediaQuery
                                 .of(context)
                                 .size
                                 .width - 50.0,
                             height: 50.0,
                             decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(25.0),
                                 color: Color(0xFFF17532)
                             ),
                              child: InkWell(
                              onTap: () async {
                                if(flag==1){
                                  http.Response response =
                                      await buyFromProductDescription(productID, quantity);
                                  print(response.body);
                                }
                                else if(flag==0){
                                  http.Response response =
                                      await buyOneFromCart(productID, quantity, cartID);
                                  print(response.body);
                                }
                                else if(flag==2){
                                  http.Response response =
                                      await checkoutCart();
                                  print(response.body);
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Something went wrong.')));
                                }
                                },

                             child: Center(
                                 child: Text('Place Your Order',
                                   style: TextStyle(
                                     fontFamily: 'Trajan Pro',
                                     fontSize: 14.0,
                                     fontWeight: FontWeight.bold,
                                     color: Colors.white,
                                   ),
                                 )
                             )

                         )

                     ),
                     )]
               ),
             ),

           );
         }
         else {
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
                   style: TextStyle(
                       fontFamily: 'Trajan Pro',
                       fontSize: 20.0,
                       color: Color(0xFF545D68))),
               actions: <Widget>[
               ],
             ),
             body: Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: <Widget>[
                   Text("Loading"

                   ),
                 ],
               ),
             ),
           );
         }
       });

  }
}