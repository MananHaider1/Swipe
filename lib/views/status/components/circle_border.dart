import 'dart:math';

import 'package:flutter/material.dart';

import 'package:lamatdating/constants.dart';

class CircularBorder extends StatelessWidget {
  final Color color;
  final double size;
  final double width;
  final Widget icon;
  final int totalitems;
  final int totalseen;
  const CircularBorder({
    super.key,
    this.color = Colors.blue,
    this.size = 70,
    this.width = 7.0,
    required this.icon,
    required this.totalitems,
    required this.totalseen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          icon,
          CustomPaint(
            size: const Size(90, 140),
            foregroundPainter: MyPainter(
                completeColor: color,
                width: 90,
                totalitems: totalitems,
                totalseen: totalseen),
          ),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  Color lineColor = Colors.transparent;
  Color completeColor;
  double width;
  int totalitems;
  int totalseen;
  MyPainter(
      {required this.completeColor,
      required this.width,
      required this.totalitems,
      required this.totalseen});
  @override
  void paint(Canvas canvas, Size size) {
    double a = totalitems == 0
        ? 0.010
        : totalitems == 1
            ? 0.023
            : totalitems == 2
                ? 0.123
                : totalitems == 3
                    ? 0.193
                    : totalitems == 4
                        ? 0.26
                        : totalitems == 5
                            ? 0.34
                            : totalitems == 6
                                ? 0.44
                                : totalitems == 7
                                    ? 0.53
                                    : totalitems == 8
                                        ? 0.60
                                        : totalitems == 9
                                            ? 0.26
                                            : totalitems == 10
                                                ? 2
                                                : totalitems == 11
                                                    ? 2
                                                    : totalitems == 12
                                                        ? 0.999
                                                        : totalitems == 13
                                                            ? 1.1
                                                            : totalitems == 14
                                                                ? 1.21
                                                                : totalitems ==
                                                                        15
                                                                    ? 1.38
                                                                    : 0.00;
    double b = totalitems == 0
        ? 0.50
        : totalitems == 1
            ? 0.50
            : totalitems == 2
                ? 0.50
                : totalitems == 3
                    ? 0.749
                    : totalitems == 4
                        ? 1.0
                        : totalitems == 5
                            ? 1.25
                            : totalitems == 6
                                ? 1.5
                                : totalitems == 7
                                    ? 1.752
                                    : totalitems == 8
                                        ? 1.0
                                        : totalitems == 9
                                            ? 2.25
                                            : totalitems == 10
                                                ? 2.5
                                                : totalitems == 11
                                                    ? 2.525
                                                    : totalitems == 12
                                                        ? 3.00
                                                        : totalitems == 13
                                                            ? 3.25
                                                            : totalitems == 14
                                                                ? 3.503
                                                                : totalitems ==
                                                                        15
                                                                    ? 3.767
                                                                    : 0.00;
    Paint seen = Paint()
      ..color = Colors.grey.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    Paint unseen = Paint()
      ..color = AppConstants.primaryColor.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    Offset center = const Offset(90 / 2, 140 / 2);
    double radius = min(90 / 2, 140 / 2);
    var percent = (90 * 0.0009) / a;

    double arcAngle = 1 * pi * percent;

    for (var i = 0; i < totalitems; i++) {
      var init = (-pi / 2) * (i / b);

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), init,
          arcAngle, false, i > totalseen - 1 ? unseen : seen);

      // canvas.drawLine(p1, p2, paint)
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
