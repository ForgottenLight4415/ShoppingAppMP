import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_project_ii/checkout.dart';
import 'package:mini_project_ii/helpers.dart';
import 'cart.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

Future<http.Response> _getAllReviews(int flag,
    {String productID,
    double rating,
    String reviewDesc,
    String reviewID}) async {
  if (flag == 0) {
    // To get reviews from server
    return http.post(
      Uri.http(serverURL, 'ShoppingAppServer/star_rating.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'flag': flag,
          'userID': await getUID(),
          'productID': productID,
        },
      ),
    );
  } else if (flag == 1) {
    // To post new review
    return http.post(
      Uri.http(serverURL, 'ShoppingAppServer/star_rating.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'flag': flag,
          'userID': await getUID(),
          'productID': productID,
          'rating': rating,
          'reviewDesc': reviewDesc,
        },
      ),
    );
  } else {
    return http.post(
      Uri.http(serverURL, 'ShoppingAppServer/star_rating.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, dynamic>{
          'flag': flag,
          'reviewID': reviewID,
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class ProductDetail extends StatefulWidget {
  final pictureURL,
      productMSRP,
      productName,
      unitPrice,
      productDescription,
      productID,
      cartID,
      userID,
      stock,
      categoryName,
      purchasedBefore;

  ProductDetail(
      {this.pictureURL,
      this.productMSRP,
      this.unitPrice,
      this.productDescription,
      this.productName,
      this.addedToCart,
      this.productID,
      this.cartID,
      this.userID,
      this.categoryName,
      this.stock,
      this.purchasedBefore});

  @override
  _ProductDetailState createState() => _ProductDetailState();
  String addedToCart = "False";
}

class _ProductDetailState extends State<ProductDetail> {
  StreamController _streamController;
  Stream _stream;
  final _reviewDescController = TextEditingController();

  double productRating = 0;
  int quantity = 1;
  String reviewNo;

  dynamic _productRatingStreamUpdater(int flag,
      {String productID,
      double rating,
      String reviewDesc,
      String reviewID}) async {
    // Flag 0: Get all reviews of particular product (Requires: productID)
    // Flag 1: Submit a review (Requires: rating, reviewDesc, productID)
    // Else/Flag 2: Delete a review (Requires: reviewID)

    if (flag == 0) {
      http.Response response = await _getAllReviews(flag, productID: productID);
      if (response.statusCode == 200) {
        if (response.body != "Failed") {
          // Returns all reviews, if available, user's review is returned first
          // on index 0 in HashMap format
          if (response.body == "NO_REVIEWS") {
            _streamController.add(null);
          } else {
            _streamController.add(jsonDecode(response.body));
          }
        } else {
          somethingWentWrongToast();
        }
      } else {
        somethingWentWrongToast();
      }
    } else if (flag == 1) {
      http.Response response = await _getAllReviews(flag,
          productID: productID, rating: rating, reviewDesc: reviewDesc);
      if (response.statusCode == 200) {
        if (response.body != "Failed") {
          // ReviewID is returned on successful review submission (as String)
          // Success message toast is shown
          Fluttertoast.showToast(
              msg: "Review posted",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 12.0);
          return response.body;
        } else {
          somethingWentWrongToast();
        }
      } else {
        somethingWentWrongToast();
      }
    } else {
      http.Response response = await _getAllReviews(flag, reviewID: reviewID);
      if (response.statusCode == 200) {
        if (response.body != "Failed") {
          // Success message toast is shown, nothing returned
          Fluttertoast.showToast(
              msg: "Review removed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 12.0);
        } else {
          somethingWentWrongToast();
        }
      } else {
        somethingWentWrongToast();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _streamController = StreamController();
    _stream = _streamController.stream;
    _productRatingStreamUpdater(0, productID: widget.productID);
  }

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
        title: Text(widget.categoryName,
            style: TextStyle(fontSize: 20.0, color: Color(0xFF545D68))),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
        child: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            List<Widget> mainList = [
              SizedBox(height: 15.0),
              Center(
                child: Text(
                  widget.productName,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF17532),
                  ),
                ),
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
                        fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                  'M.R.P' + " " + '\u20B9' + widget.unitPrice,
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF17532),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: Text(
                  'Deal of the Day:' + " " + '\u20B9' + widget.productMSRP,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Visibility(
                visible: (int.parse(widget.stock) == 0),
                child: Center(
                  child: Text(
                    'Out of stock',
                    style: TextStyle(
                      fontSize: displayWidth(context) * 0.1,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: (int.parse(widget.stock) != 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                              setState(
                                    () {
                                  if (quantity > 1) {
                                    quantity--;
                                  }
                                },
                              );
                            },
                            child: Center(
                              child: Text(
                                "-",
                                style: TextStyle(
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
                              setState(
                                    () {
                                  if (quantity <= 4) {
                                    quantity++;
                                  }
                                },
                              );
                            },
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
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
                            http.Response response = await addToCart(
                                widget.userID, widget.productID, quantity);
                            if (response.body == "MAX") {
                              Fluttertoast.showToast(
                                  msg: "Maximum limit reached",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  fontSize: 12.0);
                            } else if (response.body != "Failed") {
                              setState(
                                    () {
                                  widget.addedToCart = "True";
                                },
                              );
                              Fluttertoast.showToast(
                                  msg: "Added $quantity items to cart",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  fontSize: 12.0);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Something went wrong.'),
                                ),
                              );
                            }
                          },
                          child: Center(
                            child: Text(
                              'Add to cart',
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
                    SizedBox(height: 21.0),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50.0,
                        height: 50.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: Color(0xFFF17532)),
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CheckoutDetail(
                                  productID: widget.productID,
                                  quantity: quantity,
                                  totalPrice: quantity *
                                      double.parse(widget.productMSRP),
                                  flag: 1,
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              'Buy Now',
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
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 50.0,
                  child: Text(
                      (widget.productDescription == null)
                          ? "No product description"
                          : widget.productDescription,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          fontSize: 18.0, color: Colors.grey.shade700)),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Reviews",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ];
            if (snapshot.data == null) {
              mainList.addAll([
                Visibility(
                  visible: widget.purchasedBefore == "True",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SmoothStarRating(
                        starCount: 5,
                        isReadOnly: false,
                        spacing: 3,
                        rating: productRating,
                        size: 30,
                        color: Colors.orange,
                        borderColor: Colors.orange,
                        allowHalfRating: false,
                        onRated: (value) {
                          setState(
                                () {
                              productRating = value;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 10.0),
                      Center(
                        child: Column(
                          children: [
                            TextField(
                              controller: _reviewDescController,
                              decoration: InputDecoration(
                                hintText: "Write a review...",
                                labelText: "Review",
                                labelStyle: TextStyle(
                                  fontSize: 30,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 500,
                              maxLines: 5,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String reviewID =
                                await _productRatingStreamUpdater(
                                  1,
                                  productID: widget.productID,
                                  rating: productRating,
                                  reviewDesc: _reviewDescController.text,
                                );
                                _productRatingStreamUpdater(0,
                                    productID: widget.productID);
                                reviewNo = reviewID;
                              },
                              child: Text(
                                "Submit",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: displayHeight(context) * 0.1,
                      ),
                      Text(
                        "No Reviews yet.",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                      SizedBox(
                        height: displayHeight(context) * 0.1,
                      ),
                    ],
                  ),
                ),
              ]);
              return ListView(
                children: [
                  Column(
                    children: mainList,
                  ),
                ],
              );
            } else {
              List<Widget> reviews = [];
              (snapshot.data).forEach(
                (d) {
                  if (d['Self'] == 'True') {
                    reviewNo = d['ReviewID'];
                  }
                  reviews.add(
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                      child: Column(
                        children: [
                          Visibility(
                            visible: (d['Self'] == "False" &&
                                reviews.length == 0 &&
                                widget.purchasedBefore == "True"),
                            child: Center(
                              child: Container(
                                child: Column(
                                  children: [
                                    SmoothStarRating(
                                      starCount: 5,
                                      isReadOnly: false,
                                      spacing: 3,
                                      rating: productRating,
                                      size: 30,
                                      color: Colors.orange,
                                      borderColor: Colors.orange,
                                      allowHalfRating: false,
                                      onRated: (value) {
                                        setState(
                                          () {
                                            productRating = value;
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10.0),
                                    TextField(
                                      controller: _reviewDescController,
                                      decoration: InputDecoration(
                                        hintText: "Write a review...",
                                        labelText: "Review",
                                        labelStyle: TextStyle(
                                          fontSize: 30,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLength: 500,
                                      maxLines: 5,
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        String reviewID =
                                            await _productRatingStreamUpdater(
                                          1,
                                          productID: widget.productID,
                                          rating: productRating,
                                          reviewDesc:
                                              _reviewDescController.text,
                                        );
                                        _productRatingStreamUpdater(0,
                                            productID: widget.productID);
                                        reviewNo = reviewID;
                                      },
                                      child: Text(
                                        "Submit",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: displayWidth(context) * 0.98,
                            child: Material(
                              color: Colors.white,
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(24.0),
                              shadowColor: Color(0x802196F3),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      d['FullName'],
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: SmoothStarRating(
                                      starCount: 5,
                                      isReadOnly: true,
                                      spacing: 3,
                                      rating: double.parse(d['Rating']),
                                      size: 20,
                                      color: Colors.orange,
                                      borderColor: Colors.orange,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      d['ReviewDesc'],
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Visibility(
                                        visible: d['Self'] == 'True',
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0.0, 0, 25.0, 8.0),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await _productRatingStreamUpdater(
                                                2,
                                                reviewID: reviewNo,
                                              );
                                              _productRatingStreamUpdater(0,
                                                  productID: widget.productID);
                                            },
                                            child: Text("Delete"),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              mainList.addAll(reviews);
              return ListView(
                children: mainList,
              );
            }
          },
        ),
      ),
    );
  }
}
