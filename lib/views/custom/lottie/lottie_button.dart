import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';
import 'package:lottie/lottie.dart';

class LottieButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String lottieAsset;
  final Widget child;

  const LottieButton({
    super.key,
    required this.onPressed,
    required this.lottieAsset,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, elevation: 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            lottieAsset,
            fit: BoxFit.scaleDown,
            width: 100,
            height: 30,
            animate: kDebugMode ? false : true,
          ),
          child,
        ],
      ),
    );
  }
}

class LottieButtonRound extends StatelessWidget {
  final VoidCallback onPressed;
  final String lottieAsset;

  const LottieButtonRound({
    super.key,
    required this.onPressed,
    required this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, elevation: 0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Lottie.asset(
              lottieAsset,
              fit: BoxFit.cover,
              width: 35,
              height: 35,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomLottieButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String lottieAsset;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? backgroundColor;

  const CustomLottieButton({
    super.key,
    required this.onPressed,
    required this.lottieAsset,
    this.padding,
    this.margin,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        splashColor: color?.withOpacity(0.3) ?? Colors.black38,
        onTap: onPressed,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
            color: backgroundColor ?? color ?? Colors.black.withOpacity(0.07),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Lottie.asset(
              lottieAsset,
              fit: BoxFit.contain,
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }
}
