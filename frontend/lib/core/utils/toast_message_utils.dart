import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class ToastMessageUtils {
  static void showMessage(BuildContext context, String? message, {bool useFlutterToast = false}) {
    // if(useFlutterToast) {
      // Fluttertoast.showToast(
      //   msg: message ?? '',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      // );
    // } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? '')));
    // }
  }
}