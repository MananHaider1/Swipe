// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leading != null) leading!,
        if (title != null) Expanded(child: title!),
        if (trailing == null) SizedBox(width: width * .16),
        if (trailing != null) trailing!,
      ],
    );
  }
}
