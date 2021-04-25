import 'package:flutter/material.dart';

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
        'http://192.168.1.55:8080/ShoppingApp/Assets/NoIMG/no-img.png');
  } else {
    return NetworkImage(imgURL);
  }
}