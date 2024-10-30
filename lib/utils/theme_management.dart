// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';

class Teme {
  static const THEME_STATUS = "THEMESTATUS";

  static bool isDarktheme(SharedPreferences prefs) {
    return prefs.getBool(THEME_STATUS) ??
        (IsHIDELightDarkModeSwitchInApp == true
            ? false
            : WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
  }
}

class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ??
        (IsHIDELightDarkModeSwitchInApp == true
            ? false
            : WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
  }
}

class DarkThemeProvider extends StateNotifier<bool> {
  DarkThemePreference darkThemePreference = DarkThemePreference();

  DarkThemeProvider() : super(false);

  bool get darkTheme => state;

  set darkTheme(bool value) {
    state = value;
    darkThemePreference.setDarkTheme(value);
  }
}

final darkThemeProvider = StateNotifierProvider<DarkThemeProvider, bool>(
    (ref) => DarkThemeProvider());

MaterialColor getMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;

  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };

  return MaterialColor(color.value, shades);
}

final _primarySwatch = MaterialColor(AppConstants.primaryColor.value, _swatch);
final _swatch = {
  50: AppConstants.primaryColor.withOpacity(0.1),
  100: AppConstants.primaryColor.withOpacity(0.2),
  200: AppConstants.primaryColor.withOpacity(0.3),
  300: AppConstants.primaryColor.withOpacity(0.4),
  400: AppConstants.primaryColor.withOpacity(0.5),
  500: AppConstants.primaryColor.withOpacity(0.6),
  600: AppConstants.primaryColor.withOpacity(0.7),
  700: AppConstants.primaryColor.withOpacity(0.8),
  800: AppConstants.primaryColor.withOpacity(0.9),
  900: AppConstants.primaryColor.withOpacity(1),
};

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      splashColor: AppConstants.primaryColor.withOpacity(0.2),
      scaffoldBackgroundColor: isDarkTheme
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android:
              FadeThroughPageTransitionsBuilder(), // Change for Android
          TargetPlatform.iOS:
              FadeThroughPageTransitionsBuilder(), // Change for iOS
        },
      ),
      fontFamily: FONTFAMILY_NAME == '' ? null : FONTFAMILY_NAME,
      textTheme: TextTheme(
          displayLarge: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w800,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 28),
          displayMedium: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w800,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20),
          displaySmall: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w800,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16),
          headlineLarge: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 28),
          headlineMedium: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20),
          headlineSmall: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.bold,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16),
          bodyLarge: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.normal,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16),
          bodyMedium: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.normal,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 14),
          bodySmall: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.normal,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 12),
          titleLarge: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w900,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 28),
          titleMedium: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w800,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20),
          titleSmall: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w800,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16),
          labelLarge: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16),
          labelMedium: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 20),
          labelSmall: TextStyle(
              fontFamily: 'SFDisplay',
              fontWeight: FontWeight.w500,
              color: isDarkTheme ? Colors.white : Colors.black,
              fontSize: 16)),
      primaryColor: AppConstants.primaryColor,
      primaryColorLight: AppConstants.primaryColor,
      indicatorColor: AppConstants.primaryColor,
      primarySwatch: getMaterialColor(AppConstants.primaryColor),
      switchTheme: SwitchThemeData(
        thumbColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppConstants.primaryColor;
          }
          return null;
        }),
        trackColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppConstants.primaryColor;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppConstants.primaryColor;
          }
          return null;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return null;
          }
          if (states.contains(WidgetState.selected)) {
            return AppConstants.primaryColor;
          }
          return null;
        }),
      ),
      colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _primarySwatch,
          brightness: isDarkTheme ? Brightness.dark : Brightness.light,
          backgroundColor: isDarkTheme
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      canvasColor: isDarkTheme
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme
              ? const ColorScheme.dark()
              : const ColorScheme.light()),
      appBarTheme: const AppBarTheme(
        elevation: 0.0,
      ),
    );
  }
}
