import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mini_project_ii/helpers.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ProductDetail extends StatefulWidget {
  final pictureURL,
      productMSRP,
      productName,
      unitPrice,
      productID,
      cartID,
      userID;

  ProductDetail(
      {this.pictureURL,
      this.productMSRP,
      this.unitPrice,
      this.productName,
      this.addedToCart,
      this.productID,
      this.cartID,
      this.userID});

  @override
  _ProductDetailState createState() => _ProductDetailState();
  String addedToCart = "False";
}

class _ProductDetailState extends State<ProductDetail> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
        title: Text('Category selected by user',
            style: TextStyle(
                fontFamily: 'Trajan Pro',
                fontSize: 20.0,
                color: Color(0xFF545D68))),
        actions: <Widget>[],
      ),
      body: ListView(children: [
        SizedBox(height: 15.0),
        Center(
          child: Text(widget.productName,
              style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF17532))),
        ),
        SizedBox(height: 15.0),
        Hero(
            tag: widget.pictureURL,
            child: Container(
              height: displayHeight(context) * 0.30,
              width: displayWidth(context),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: setImage(widget.pictureURL),
                  fit: BoxFit.contain
                )
              ),
            )),
        SizedBox(height: 20.0),
        Center(
          child: Text('M.R.P' + " " + '\u20B9' + widget.unitPrice,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 21.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF17532),
                decoration: TextDecoration.lineThrough,
              )),
        ),
        SizedBox(height: 20.0),
        Center(
          child: Text('Deal of the Day:' + " " + '\u20B9' + widget.productMSRP,
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 22.0,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              )),
        ),
        SizedBox(height: 20.0),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 50.0,
            child: Text('Easy to implement,portable & rechargeable',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16.0,
                    color: Color(0xFFB4B8B9))),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(228, 228, 228, 1),
                  borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (quantity > 0) {
                      quantity--;
                    }
                  });
                },
                child: Center(
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 49,
              width: 100,
              child: Center(
                child: Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                    color: Color.fromRGBO(243, 175, 45, 1),
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  child: Center(
                    child: Text(
                      "+",
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: 20.0),
        Center(
          child: Container(
              width: displayWidth(context) * 0.87,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Color(0xFFF17532),
              ),
              child: InkWell(
                  onTap: () async {
                    print("userID: " + widget.userID);
                    print("productID: " + widget.productID);
                    http.Response response = await addToCart(
                        widget.userID, widget.productID, quantity);
                    print(response.body);
                    if (response.body == "Done") {
                      setState(() {
                        widget.addedToCart = "True";
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Something went wrong.')));
                    }
                  },
                  child: Center(
                      child: Text(
                    'Add to cart',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )))),
        ),
        SizedBox(height: 21.0),
        Center(
          child: Container(
              width: MediaQuery.of(context).size.width - 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  color: Color(0xFFF17532)),
              child: InkWell(
                  onTap: () {},
                  child: Center(
                      child: Text(
                    'Buy Now',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )))),
        )
      ]),
    );
  }
}
