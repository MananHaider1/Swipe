import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomHeadLine extends ConsumerWidget {
  final String text;

  // final SharedPreferences? prefs;

  const CustomHeadLine({
    super.key,
    required this.text,
    // this.prefs,
  });

  @override
  Widget build(BuildContext context, ref) {
    final prefss = ref.watch(sharedPreferences);
    SharedPreferences? prefs;
    prefss.when(
        data: (data) {
          prefs = data;
        },
        error: (Object error, StackTrace stackTrace) {},
        loading: () {});
    final textStyle = Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: (prefs != null)
            ? Teme.isDarktheme(prefs!)
                ? Colors.white
                : Colors.black
            : Colors.black,
        fontWeight: FontWeight.bold);

    return Text(
      text,
      style: textStyle,
    );
  }
}
