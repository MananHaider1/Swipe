// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, depend_on_referenced_packages, deprecated_member_use

import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/download_info_provider.dart';

import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';

abstract class DownloadService {
  Future<void> download(
      {required String url,
      required WidgetRef ref,
      required String fileName,
      required BuildContext context,
      required SharedPreferences prefs,
      required bool isOpenAfterDownload,
      GlobalKey? keyloader});
}

class WebDownloadService implements DownloadService {
  @override
  Future<void> download(
      {required String url,
      required WidgetRef ref,
      required String fileName,
      required BuildContext context,
      required SharedPreferences prefs,
      required bool isOpenAfterDownload,
      GlobalKey? keyloader}) async {
    html.window.open(url, "_blank");
  }
}

class MobileDownloadService implements DownloadService {
  @override
  Future<void> download(
      {required String url,
      required WidgetRef ref,
      required String fileName,
      required BuildContext context,
      required SharedPreferences prefs,
      required bool isOpenAfterDownload,
      GlobalKey? keyloader}) async {
    bool hasPermission = await _requestWritePermission();
    if (!hasPermission) return;

    Dio dio = Dio();
    var dir = !kIsWeb
        ? Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory()
        : await getExternalStorageDirectory();

    // You should put the name you want for the file here.
    // Take in account the extension.
    File outputFile = File(Platform.isAndroid
        ? "/sdcard/download/$fileName"
        : "${dir!.path}/$fileName");
    bool fileExists = await outputFile.exists();
    if (fileExists == true) {
      Lamat.toast(
        "Downloaded ",
      );
    } else {
      final downloadinfo = ref.watch(downloadInfoProviderProvider);
      if (keyloader != null) {
        showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return WillPopScope(
                  onWillPop: () async => false,
                  child: SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      key: keyloader,
                      backgroundColor: Teme.isDarktheme(prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor,
                      children: <Widget>[
                        Consumer(
                            builder: (context, ref, _child) => Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CircularPercentIndicator(
                                        radius: 25.0,
                                        lineWidth: 4.0,
                                        percent:
                                            downloadinfo.downloadedpercentage /
                                                100,
                                        center: Text(
                                            "${downloadinfo.downloadedpercentage.floor()}%"),
                                        progressColor:
                                            AppConstants.lamatGreenColor400,
                                      ),
                                      Container(
                                        width: 180,
                                        padding: const EdgeInsets.only(left: 7),
                                        child: ListTile(
                                          dense: false,
                                          title: const Text(
                                            "Loading ...",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                height: 1.3,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            '${((((downloadinfo.totalsize / 1024) / 1000) * 100).roundToDouble()) / 100}  MB',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(height: 2.2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                      ]));
            });
      }

      await dio.download(
        url,
        !kIsWeb
            ? Platform.isAndroid
                ? "/sdcard/download/$fileName"
                : "${dir!.path}/$fileName"
            : "",
        onReceiveProgress: (rcv, total) {
          downloadinfo.calculatedownloaded(rcv / total * 100, total);
        },
        deleteOnError: true,
      ).then((_) async {
        Navigator.of(keyloader!.currentContext!, rootNavigator: true).pop(); //
        downloadinfo.calculatedownloaded(0.00, 0);
        if (isOpenAfterDownload == true) {
          Lamat.toast(
            "Downloaded ",
          );
          if (getDocumentType(fileName) != "") {
            Future.delayed(const Duration(milliseconds: 700), () {
              OpenFile.open(
                  !kIsWeb
                      ? Platform.isAndroid
                          ? "/sdcard/download/$fileName"
                          : "${dir!.path}/$fileName"
                      : "",
                  type: getDocumentType(fileName));
            });
          }
        } else {
          Lamat.toast(
            "Downloaded ",
          );
        }
      }).onError((err, er) {
        downloadinfo.calculatedownloaded(0.00, 0);
        if (kDebugMode) {
          print('ERROR OCCURED WHILE DOWNLOADING MEDIA: $err');
        }
        Navigator.of(keyloader!.currentContext!, rootNavigator: true).pop(); //
        Lamat.toast(
          "Error Occured while Downloading",
        );
      });
    }
  }

  Future<bool> _requestWritePermission() async {
    await Permission.storage.request();
    return await Permission.storage.request().isGranted;
  }
}

String getDocumentType(fileName) {
  String fileExtension = p.extension(fileName).toLowerCase();
  if (fileExtension == ".3gp") {
    return "video/3gpp";
  } else if (fileExtension == ".torrent") {
    return "application/x-bittorrent";
  } else if (fileExtension == ".kml") {
    return "application/vnd.google-earth.kml+xml";
  } else if (fileExtension == ".gpx") {
    return "application/gpx+xml";
  } else if (fileExtension == ".csv") {
    return "application/vnd.ms-excel";
  } else if (fileExtension == ".apk") {
    return "application/vnd.android.package-archive";
  } else if (fileExtension == ".asf") {
    return "video/x-ms-asf";
  } else if (fileExtension == ".avi") {
    return "video/x-msvideo";
  } else if (fileExtension == ".bin") {
    return "application/octet-stream";
  } else if (fileExtension == ".bmp") {
    return "image/bmp";
  } else if (fileExtension == ".c") {
    return "text/plain";
  } else if (fileExtension == ".class") {
    return "application/octet-stream";
  } else if (fileExtension == ".conf") {
    return "text/plain";
  } else if (fileExtension == ".cpp") {
    return "text/plain";
  } else if (fileExtension == ".doc") {
    return "application/msword";
  } else if (fileExtension == ".docx") {
    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
  } else if (fileExtension == ".xls") {
    return "application/vnd.ms-excel";
  } else if (fileExtension == ".xslx") {
    return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
  } else if (fileExtension == ".exe") {
    return "application/octet-stream";
  } else if (fileExtension == ".gif") {
    return "image/gif";
  } else if (fileExtension == ".gtar") {
    return "application/x-gtar";
  } else if (fileExtension == ".gz") {
    return "application/x-gzip";
  } else if (fileExtension == ".h") {
    return "text/plain";
  } else if (fileExtension == ".htm") {
    return "text/html";
  } else if (fileExtension == ".html") {
    return "text/html";
  } else if (fileExtension == ".jar") {
    return "application/java-archive";
  } else if (fileExtension == ".java") {
    return "text/plain";
  } else if (fileExtension == ".jpg") {
    return "image/jpeg";
  } else if (fileExtension == ".jpeg") {
    return "image/jpeg";
  } else if (fileExtension == ".js") {
    return "application/x-javascript";
  } else if (fileExtension == ".log") {
    return "text/plain";
  } else if (fileExtension == ".m3u") {
    return "audio/x-mpegurl";
  } else if (fileExtension == ".m4a") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4b") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4p") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4u") {
    return "video/vnd.mpegurl";
  } else if (fileExtension == ".m4v") {
    return "video/x-m4v";
  } else if (fileExtension == ".mov") {
    return "video/quicktime";
  } else if (fileExtension == ".mp2") {
    return "audio/x-mpeg";
  } else if (fileExtension == ".mp3") {
    return "audio/x-mpeg";
  } else if (fileExtension == ".mp4") {
    return "video/mp4";
  } else if (fileExtension == ".mpc") {
    return "application/vnd.mpohun.certificate";
  } else if (fileExtension == ".mpe") {
    return "video/mpeg";
  } else if (fileExtension == ".mpeg") {
    return "video/mpeg";
  } else if (fileExtension == ".mpg") {
    return "video/mpeg";
  } else if (fileExtension == ".mpg4") {
    return "video/mp4";
  } else if (fileExtension == ".mpga") {
    return "audio/mpeg";
  } else if (fileExtension == ".msg") {
    return "application/vnd.ms-outlook";
  } else if (fileExtension == ".ogg") {
    return "audio/ogg";
  } else if (fileExtension == ".pdf") {
    return "application/pdf";
  } else if (fileExtension == ".png") {
    return "image/png";
  } else if (fileExtension == ".pps") {
    return "application/vnd.ms-powerpoint";
  } else if (fileExtension == ".ppt") {
    return "application/vnd.ms-powerpoint";
  } else if (fileExtension == ".pptx") {
    return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
  } else if (fileExtension == ".prop") {
    return "text/plain";
  } else if (fileExtension == ".rc") {
    return "text/plain";
  } else if (fileExtension == ".rmvb") {
    return "audio/x-pn-realaudio";
  } else if (fileExtension == ".rtf") {
    return "application/rtf";
  } else if (fileExtension == ".sh") {
    return "text/plain";
  } else if (fileExtension == ".tar") {
    return "application/x-tar";
  } else if (fileExtension == ".tgz") {
    return "application/x-compressed";
  } else if (fileExtension == ".txt") {
    return "text/plain";
  } else if (fileExtension == ".wav") {
    return "audio/x-wav";
  } else if (fileExtension == ".wma") {
    return "audio/x-ms-wma";
  } else if (fileExtension == ".wmv") {
    return "audio/x-ms-wmv";
  } else if (fileExtension == ".wps") {
    return "application/vnd.ms-works";
  } else if (fileExtension == ".xml") {
    return "text/plain";
  } else if (fileExtension == ".z") {
    return "application/x-compress";
  } else if (fileExtension == ".zip") {
    return "application/x-zip-compressed";
  } else if (fileExtension == "") {
    return "*/*";
  } else {
    return "";
  }
}
