// ignore_for_file: deprecated_member_use

import 'package:lamatdating/constants.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GalleryDownloader {
  static void saveNetworkVideoInGallery(
      BuildContext context,
      String url,
      bool isFurtherOpenFile,
      String fileName,
      GlobalKey keyloader,
      SharedPreferences prefs) async {
    String path = "$url&ext=.mp4";
    Dialogs.showLoadingDialog(context, keyloader, prefs);
    GallerySaver.saveVideo(path).then((success) async {
      if (success == true) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();

        Lamat.toast(
          "$fileName Downloaded",
        );
      } else {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
        Lamat.toast(
          "Failed to download!",
        );
      }
    }).catchError((err) {
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Lamat.toast(err.toString());
    });
  }

  static void saveNetworkImage(
      BuildContext context,
      String url,
      bool isFurtherOpenFile,
      String fileName,
      GlobalKey keyloader,
      SharedPreferences prefs) async {
    // String path =
    //     'https://image.shutterstock.com/image-photo/montreal-canada-july-11-2019-600w-1450023539.jpg';

    String path = "$url&ext=.jpg";
    Dialogs.showLoadingDialog(context, keyloader, prefs);
    GallerySaver.saveImage(path, toDcim: true).then((success) async {
      if (success == true) {
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
        Lamat.toast(
          fileName == "" ? "Downloaded" : "$fileName Downloaded",
        );
      } else {
        Lamat.toast(
          "Failed to download!",
        );
        Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      }
    }).catchError((err) {
      Navigator.of(keyloader.currentContext!, rootNavigator: true).pop();
      Lamat.toast(err.toString());
    });
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key, SharedPreferences prefs) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Teme.isDarktheme(prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor,
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 18,
                              ),
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppConstants.secondaryColor),
                              ),
                              const SizedBox(
                                width: 23,
                              ),
                              Text(
                                "Downloading...",
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(prefs)
                                          ? AppConstants.dialogColorDark
                                          : AppConstants.backgroundColor),
                                ),
                              )
                            ]),
                      ),
                    )
                  ]));
        });
  }
}
