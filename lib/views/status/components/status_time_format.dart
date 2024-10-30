import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

getStatusTime(val, BuildContext context, WidgetRef ref) {
  final observer = ref.watch(observerProvider);
  if (val is int) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    String at = observer.is24hrsTimeformat == true
            ? DateFormat('HH:mm').format(date)
            : DateFormat.jm().format(date),
        when = getWhen(date, context);
    return '$when, $at';
  }
  return '';
}

getWhen(date, BuildContext context) {
  DateTime now = DateTime.now();
  String when;
  if (date.day == now.day) {
    when = LocaleKeys.today.tr();
  } else if (date.day == now.subtract(const Duration(days: 1)).day) {
    when = LocaleKeys.yesterday.tr();
  } else {
    when = IsShowNativeTimDate == true
        ? '${DateFormat.MMMM().format(date)} ${DateFormat.d().format(date)}'
        : DateFormat.MMMd().format(date);
  }
  return when;
}

getJoinTime(val, BuildContext context) {
  if (val is int) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    String when = IsShowNativeTimDate == true
        ? '${DateFormat.MMMM().format(date)} ${DateFormat.d().format(date)}, ${DateFormat.y().format(date)}'
        : DateFormat.yMMMd().format(date);
    return when;
  }
  return '';
}
