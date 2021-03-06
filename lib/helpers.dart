import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

String serverURL = 'shoppingappserver.000webhostapp.com';

void somethingWentWrongToast() {
  Fluttertoast.showToast(
      msg: "Something went wrong",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 12.0);
}

Size displaySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double displayHeight(BuildContext context) {
  return displaySize(context).height;
}

double displayWidth(BuildContext context) {
  return displaySize(context).width;
}

NetworkImage setImage(imgURL) {
  if (imgURL == null) {
    return NetworkImage(
        'http://$serverURL/ShoppingAppServer/Assets/NoIMG/no-img.png');
  } else {
    return NetworkImage(imgURL);
  }
}

Future<String> getUID() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString("UserID");
}
