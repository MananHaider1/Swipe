import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:shared_preferences/shared_preferences.dart';

void notificationViwer(BuildContext context, String? desc, String? title,
    String? imageurl, String? timeString, SharedPreferences prefs) {
  var h = MediaQuery.of(context).size.height;
  var w = MediaQuery.of(context).size.width;
  showModalBottomSheet(
      backgroundColor: Teme.isDarktheme(prefs)
          ? AppConstants.dialogColorDark
          : AppConstants.backgroundColor,
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        return Container(
          margin: const EdgeInsets.only(top: 0),
          height: h > w ? h / 1.3 : w / 1.2,
          color: Colors.transparent,
          child: Container(
              decoration: BoxDecoration(
                  color: Teme.isDarktheme(prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0))),
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeString!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                            fontSize: 13.9,
                            color: AppConstants.lamatGrey,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppConstants.lamatGrey,
                          ),
                          alignment: Alignment.centerRight,
                        ),
                      ],
                    ),
                    // Divider(),
                    const SizedBox(height: 10),
                    imageurl == null
                        ? const SizedBox(
                            height: 0,
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Image.network(
                              imageurl,
                              height: (w * 0.62),
                              width: w,
                              fit: BoxFit.contain,
                            ),
                          ),
                    const SizedBox(height: 30),
                    SelectableText(
                      title ?? '',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 19,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(prefs)
                                  ? AppConstants.dialogColorDark
                                  : AppConstants.backgroundColor),
                          fontWeight: FontWeight.w800),
                    ),

                    const Divider(),
                    const SizedBox(height: 10),
                    SelectableLinkify(
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(prefs)
                                    ? AppConstants.dialogColorDark
                                    : AppConstants.backgroundColor)
                            .withOpacity(0.7),
                      ),
                      text: desc ?? "",
                      onOpen: (link) async {
                        custom_url_launcher(link.url);
                      },
                    ),
                  ],
                ),
              ))),
        );
      });
}
