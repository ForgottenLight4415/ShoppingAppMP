import 'package:flutter/material.dart';

String serverURL = '192.168.0.6:8080';

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
        'http://$serverURL/ShoppingApp/Assets/NoIMG/no-img.png');
  } else {
    return NetworkImage(imgURL);
  }
}