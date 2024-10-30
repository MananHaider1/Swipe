import 'package:flutter/material.dart';

Widget myElevatedButton({Color? color, Widget? child, Function? onPressed}) {
  return ElevatedButton(
    onPressed: () {
      onPressed!();
    },
    style: ButtonStyle(
        elevation: WidgetStateProperty.all(0.5),
        backgroundColor: WidgetStateProperty.all(color),
        padding: WidgetStateProperty.all(const EdgeInsets.all(2)),
        shadowColor: WidgetStateProperty.all(color!.withOpacity(.5))
        // textStyle: MaterialStateProperty.all(TextStyle(color: Colors.black))
        ),
    child: child,
  );
}
