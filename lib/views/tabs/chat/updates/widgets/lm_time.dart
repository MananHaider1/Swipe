import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';

final DateFormat formatter = DateFormat('dd/MM/yy');

getLastMessageTime(
    BuildContext context, String currentUserNo, val, WidgetRef ref) {
  final observer = ref.read(observerProvider);
  if (val is bool && val == true) {
    return LocaleKeys.msgdeleted.tr();
  } else if (val is int) {
    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    String at = observer.is24hrsTimeformat == false
            ? DateFormat.jm().format(date)
            : DateFormat('HH:mm').format(date),
        when = date.day == now.subtract(const Duration(days: 1)).day
            ? LocaleKeys.yesterday.tr()
            : getWhen(date, context);

    return date.day == now.day ? at : when;
  } else if (val is String) {
    if (val == currentUserNo) return LocaleKeys.typing.tr();
    return LocaleKeys.online.tr();
  }
  return "";
}
