// ignore_for_file: no_leading_underscores_for_local_identifiers, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_translate/extensions/string_extension.dart';
import 'package:ntp/ntp.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/localization/language_constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';

class Lamat {
  static String? getNickname(Map<String, dynamic> user) =>
      user[Dbkeys.aliasName] ?? user[Dbkeys.nickname];

  static void toast(String message) {
    showToast(message, position: ToastPosition.bottom);
  }

  static void internetLookUp() async {
    // try {
    //   // ignore: body_might_complete_normally_catch_error
    //   await InternetAddress.lookup('google.com').catchError((e) {
    //     Lamat.toast(
    //         'No internet connection. Please check your Internet Connection.');
    //   });
    // } catch (err) {
    //   Lamat.toast(
    //       'No internet connection. Please check your Internet Connection.');
    // }
  }

  static void invite(BuildContext context, WidgetRef ref) {
    final observer = ref.watch(observerProvider);
    String multilingualtext = !kIsWeb
        ? Platform.isIOS
            ? "Let's chat on $Appname, Join me at - ${observer.iosapplink}"
            : "Let's chat on $Appname, Join me at -  ${observer.androidapplink}"
        : "Let's chat on $Appname, Join me at - ${observer.androidapplink}";
    Share.share(observer.isCustomAppShareLink == true
        ? (!kIsWeb
            ? Platform.isAndroid
                ? observer.appShareMessageStringAndroid == ''
                    ? multilingualtext
                    : observer.appShareMessageStringAndroid
                : Platform.isIOS
                    ? observer.appShareMessageStringiOS == ''
                        ? multilingualtext
                        : observer.appShareMessageStringiOS
                    : multilingualtext
            : multilingualtext)
        : multilingualtext);
  }

  static Widget avatar(Map<String, dynamic>? user,
      {File? image, double radius = 22.5, String? predefinedinitials}) {
    if (image == null) {
      if (user![Dbkeys.aliasAvatar] == null) {
        return (user[Dbkeys.photoUrl] ?? '').isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    CachedNetworkImageProvider(user[Dbkeys.photoUrl]),
                radius: radius)
            : CircleAvatar(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                radius: radius,
                child: Text(predefinedinitials ??
                    getInitials(Lamat.getNickname(user)!)),
              );
      }
      return CircleAvatar(
        backgroundImage: Image.network(user[Dbkeys.aliasAvatar]).image,
        radius: radius,
      );
    }
    return CircleAvatar(
        backgroundImage: Image.network(image.path).image, radius: radius);
  }

  static Future<int> getNTPOffset() {
    return NTP.getNtpOffset();
  }

  static Future<int>? getTime() async {
    var res = await http
        .get(Uri.parse('https://worldtimeapi.org/api/timezone/Etc/UTC'));
    // if (res.statusCode == 200){
    final data = jsonDecode(res.body); // Parse JSON response
    final dateTimeString = data['datetime'];

    debugPrint(
        "DateTime Now $dateTimeString !!!!!!!!!!!!!!!!!"); // Access the 'datetime' property

    // Parse the ISO 8601 formatted datetime string
    final dateTime = DateTime.now().toUtc();

    // Convert DateTime object to milliseconds since epoch
    final millisecondsSinceEpoch = dateTime.millisecondsSinceEpoch;
    if (kDebugMode) {
      print(millisecondsSinceEpoch);
      print(jsonDecode(res.body).toString());
    }
    final difference =
        millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;

    return difference;

// } else
// {
// return null;
// }
  }

  static Widget getNTPWrappedWidget(Widget child) {
    return FutureBuilder(
        future: getTime(),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data! > const Duration(minutes: 2).inMilliseconds ||
                snapshot.data! < -const Duration(minutes: 2).inMilliseconds) {
              return const Material(
                  color: AppConstants.lamatBlack,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            "Your clock time is out of sync with the server time. Please set it right to continue.",
                            // getTranslated(context, 'clocktime'),
                            style: TextStyle(
                                color: AppConstants.lamatWhite, fontSize: 18),
                          ))));
            }
          }
          return child;
        });
  }

  static void showRationale(rationale) async {
    Lamat.toast(rationale);
    // await Future.delayed(Duration(seconds: 2));
    // Lamat.toast(
    //     'If you change your mind, you can grant the permission through App Settings > Permissions');
  }

  static Future<bool> checkAndRequestPermission(Permission permission) {
    Completer<bool> completer = Completer<bool>();
    permission.request().then((status) {
      if (status != PermissionStatus.granted) {
        permission.request().then((_status) {
          bool granted = _status == PermissionStatus.granted;
          completer.complete(granted);
        });
      } else {
        completer.complete(true);
      }
    });
    return completer.future;
  }

  static String getInitials(String name) {
    try {
      List<String> names =
          name.trim().replaceAll(RegExp(r'[\W]'), '').toUpperCase().split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2) {
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      } else if (names.elementAt(0).length >= 2) {
        return names.elementAt(0).substring(0, 2);
      } else {
        return names.elementAt(0)[0];
      }
    } catch (e) {
      return '?';
    }
  }

  static String getChatId(String currentUserNo, String peerNo) {
    if ((int.tryParse(currentUserNo) ?? 0) >= (int.tryParse(peerNo) ?? 0)) {
      return '$currentUserNo-$peerNo';
    }
    return '$peerNo-$currentUserNo';
  }

  static AuthenticationType getAuthenticationType(
      bool biometricEnabled, DataModel? model) {
    if (biometricEnabled && model?.currentUser != null) {
      return AuthenticationType
          .values[model!.currentUser![Dbkeys.authenticationType]];
    }
    return AuthenticationType.passcode;
  }

  static ChatStatus getChatStatus(int index) => ChatStatus.values[index];

  static String normalizePhone(String phone) =>
      phone.replaceAll(RegExp(r"\s+\b|\b\s"), "");

  static String getHashedAnswer(String answer) {
    answer = answer.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]"), "");
    var bytes = utf8.encode(answer); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getHashedString(String str) {
    var bytes = utf8.encode(str); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static List<List<String>> divideIntoChuncks(List<String> array, int size) {
    List<List<String>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }

  static List<List<List<String>>> divideIntoChuncksGroup(
      List<List<String>> array, int size) {
    List<List<List<String>>> chunks = [];
    int i = 0;
    while (i < array.length) {
      int j = i + size;
      chunks.add(array.sublist(i, j > array.length ? array.length : j));
      i = j;
    }
    return chunks;
  }

  static Future<String> translateString(
      String str, SharedPreferences prefs) async {
    String value = await str.translate(
        sourceLanguage: '',
        targetLanguage:
            prefs.getString(LAGUAGE_CODE) ?? DEFAULT_LANGUAGE_FILE_CODE);
    return value;
  }
}
