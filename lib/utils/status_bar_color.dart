import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';

setStatusBarColor(SharedPreferences prefs) {
  if (Teme.isDarktheme(prefs) == true) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkColor(AppConstants.backgroundColorDark)
            ? Brightness.light
            : Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkColor(AppConstants.backgroundColor)
            ? Brightness.light
            : Brightness.dark));
  }
}

setStatusBarColorHomePage() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
}

setStatusBarColorLoginPage(SharedPreferences prefs) {
  if (Teme.isDarktheme(prefs) == true) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppConstants.backgroundColorDark,
        statusBarIconBrightness: isDarkColor(AppConstants.backgroundColorDark)
            ? Brightness.light
            : Brightness.dark));
  } else {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkColor(AppConstants.primaryColor)
            ? Brightness.light
            : Brightness.dark));
  }
}
