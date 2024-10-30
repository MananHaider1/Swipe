import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterwaveViewUtils {
  /// Displays a toast notification
  static void showToast(BuildContext context, String text) {
    try {
      Fluttertoast.showToast(
        msg: text,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(0xAA383737),
        textColor: Colors.white,
      );
    } catch(error) {
      Fluttertoast.showToast(
        msg: text,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color(0xAA383737),
        textColor: Colors.white,
      );
    }
  }
}
