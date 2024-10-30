import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

double bytesTransferred(TaskSnapshot snapshot) {
  double res = snapshot.bytesTransferred / 1024.0;
  double res2 = snapshot.totalBytes / 1024.0;
  // print('${((res / res2) * 100).roundToDouble().toString()} %');
  return ((res / res2) * 100).roundToDouble();
}

openUploadDialog(
    {required BuildContext context,
    double? percent,
    required String title,
    required String subtitle,
    required SharedPreferences prefs}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      CircularPercentIndicator(
        radius: 25.0,
        lineWidth: 4.0,
        percent: percent ?? 0.0,
        center: Text(
          percent == null ? '0%' : "${(percent * 100).roundToDouble()}%",
          style: const TextStyle(fontSize: 11),
        ),
        progressColor: AppConstants.lamatGreenColor400,
      ),
      Container(
        width: 195,
        padding: const EdgeInsets.only(left: 3),
        child: ListTile(
          dense: false,
          title: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              height: 1.3,
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(prefs)
                  ? AppConstants.dialogColorDark
                  : AppConstants.backgroundColor),
            ),
          ),
          subtitle: Text(
            subtitle,
            textAlign: TextAlign.left,
            style: const TextStyle(height: 2.2, color: AppConstants.lamatGrey),
          ),
        ),
      ),
    ],
  );
}
