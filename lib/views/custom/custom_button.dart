import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final IconData? icon;
  final Widget? child;
  final bool isWhite;
  final Color? borderColor;
  final Color? color;
  final SharedPreferences? prefs;

  const CustomButton(
      {super.key,
      required this.onPressed,
      this.text,
      this.icon,
      this.isWhite = false,
      this.borderColor,
      this.child,
      this.color,
      this.prefs});

  @override
  Widget build(BuildContext context) {
    bool isWhiter = (prefs != null)
        ? (Teme.isDarktheme(prefs!) == true)
            ? true
            : false
        : false;
    final buttonTextStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Colors.white,
        );
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 2),
      onTap: onPressed,
      // splashColor: AppConstants.primaryColor,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.4),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppConstants.defaultNumericValue * 2),
          gradient: !isWhiter ? AppConstants.defaultGradient : null,
          color: color ?? (isWhiter ? AppConstants.primaryColor : Colors.white),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: isWhiter
              ? null
              : [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: AppConstants.defaultNumericValue * 2,
                    spreadRadius: AppConstants.defaultNumericValue / 4,
                    offset: const Offset(0, AppConstants.defaultNumericValue),
                  ),
                ],
        ),
        child: child ??
            (text == null && icon == null
                ? Text(
                    LocaleKeys.next,
                    textAlign: TextAlign.center,
                    style: buttonTextStyle,
                  ).tr()
                : text != null && icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isWhiter ? Colors.black : Colors.white,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                          Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                        ],
                      )
                    : text != null
                        ? Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          )
                        : Icon(
                            icon!,
                            color: isWhiter ? Colors.black : Colors.white,
                          )),
      ),
    );
  }
}

class CustomButtonLogin extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final IconData? icon;
  final Widget? child;
  final bool isWhite;
  final Color? borderColor;
  final Color? color;
  final SharedPreferences? prefs;

  const CustomButtonLogin(
      {super.key,
      required this.onPressed,
      this.text,
      this.icon,
      this.isWhite = false,
      this.borderColor,
      this.child,
      this.color,
      this.prefs});

  @override
  Widget build(BuildContext context) {
    bool isWhiter = (prefs != null)
        ? (Teme.isDarktheme(prefs!) == true)
            ? true
            : false
        : false;
    final buttonTextStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: (prefs != null) ? Colors.black : Colors.black,
        );
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 2),
      onTap: onPressed,
      splashColor: AppConstants.primaryColor,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.4),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppConstants.defaultNumericValue * 2),
          // gradient: !isWhite ? AppConstants.defaultGradient : null,
          color: Colors.white,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: isWhiter
              ? null
              : [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: AppConstants.defaultNumericValue * 2,
                    spreadRadius: AppConstants.defaultNumericValue / 4,
                    offset: const Offset(0, AppConstants.defaultNumericValue),
                  ),
                ],
        ),
        child: child ??
            (text == null && icon == null
                ? Text(
                    LocaleKeys.next,
                    textAlign: TextAlign.center,
                    style: buttonTextStyle,
                  ).tr()
                : text != null && icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isWhiter ? Colors.black : Colors.white,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                          Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                        ],
                      )
                    : text != null
                        ? Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          )
                        : Icon(
                            icon!,
                            color: isWhiter ? Colors.black : Colors.white,
                          )),
      ),
    );
  }
}
