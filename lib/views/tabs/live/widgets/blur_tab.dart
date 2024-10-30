import 'dart:ui';

import 'package:flutter/material.dart';

class BlurTab extends StatelessWidget {
  final Widget child;
  final double height;
  final double radius;

  const BlurTab(
      {super.key, required this.child, this.height = 50, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.33),
        // gradient: LinearGradient(
        //     begin: Alignment.centerLeft,
        //     end: Alignment.centerRight,
        //     colors: [
        //       colorPrimary.withOpacity(0.1),
        //       AppConstants.backgroundColor.withOpacity(0.1)
        //     ]),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}
