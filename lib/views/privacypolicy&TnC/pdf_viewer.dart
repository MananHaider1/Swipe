import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFViewerCachedFromUrl extends StatelessWidget {
  const PDFViewerCachedFromUrl(
      {super.key,
      required this.url,
      required this.title,
      required this.prefs,
      required this.isregistered});
  final SharedPreferences prefs;
  final String? url;
  final String title;
  final bool isregistered;

  @override
  Widget build(BuildContext context) {
    return isregistered == false
        ? Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              title: Text(
                title,
                style: TextStyle(
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor),
                    fontSize: 18),
              ),
              backgroundColor: Teme.isDarktheme(prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
            ),
            body: const PDF().cachedFromUrl(
              url!,
              placeholder: (double progress) =>
                  Center(child: Text('$progress %')),
              errorWidget: (dynamic error) =>
                  Center(child: Text(error.toString())),
            ),
          )
        : PickupLayout(
            prefs: prefs,
            scaffold: Lamat.getNTPWrappedWidget(Scaffold(
              appBar: AppBar(
                elevation: 0.4,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: 30,
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor),
                  ),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor),
                      fontSize: 18),
                ),
                backgroundColor: Teme.isDarktheme(prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor,
              ),
              body: const PDF().cachedFromUrl(
                url!,
                placeholder: (double progress) =>
                    Center(child: Text('$progress %')),
                errorWidget: (dynamic error) =>
                    Center(child: Text(error.toString())),
              ),
            )));
  }
}
