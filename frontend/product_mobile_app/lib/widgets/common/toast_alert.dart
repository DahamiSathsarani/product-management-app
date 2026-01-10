import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AppToast {
  static void success(String message) {
    show(message, backgroundColor: Colors.green);
  }

  static void error(String message) {
    show(message, backgroundColor: Colors.red.shade700);
  }

  static void show(
    String message, {
      Color backgroundColor = Colors.black87,
      Color textColor = Colors.white,
    }) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: backgroundColor,
        textColor: textColor,
      );
    }
}