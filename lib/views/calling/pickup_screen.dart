import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';
import 'package:lamatdating/providers/call_history_provider.dart';

import 'package:lamatdating/views/calling/audio_call.dart';
import 'package:lamatdating/views/calling/video_call.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/widgets/Common/cached_image.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/models/call.dart';
import 'package:lamatdating/models/call_methods.dart';
import 'package:lamatdating/utils/permissions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class PickupScreen extends ConsumerWidget {
  final Call call;
  final String? currentuseruid;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    super.key,
    required this.call,
    required this.currentuseruid,
    required this.prefs,
  });
  final ClientRoleType _role = ClientRoleType.clientRoleBroadcaster;
  @override
  Widget build(BuildContext context, ref) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    final firestoreDataProviderCALLHISTORY =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);

    return h > w && ((h / w) > 1.5)
        ? Scaffold(
            backgroundColor: Teme.isDarktheme(prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            body: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    color: Teme.isDarktheme(prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    height: h / 4,
                    width: w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          height: 7,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              call.isvideocall == true
                                  ? Icons.videocam
                                  : Icons.mic_rounded,
                              size: 40,
                              color: Teme.isDarktheme(prefs)
                                  ? AppConstants.primaryColor
                                  : pickTextColorBasedOnBgColorAdvanced(
                                          AppConstants.backgroundColor)
                                      .withOpacity(0.7),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Text(
                              call.isvideocall == true
                                  ? "Incoming Video Call ..."
                                  : "Incoming Audio Call ...",
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Teme.isDarktheme(prefs)
                                      ? AppConstants.primaryColor
                                      : pickTextColorBasedOnBgColorAdvanced(
                                              AppConstants.backgroundColor)
                                          .withOpacity(0.7),
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: h / 9,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 7),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Text(
                                  call.callerName!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor),
                                    fontSize: 27,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                call.callerId!,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                          Teme.isDarktheme(prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor)
                                      .withOpacity(0.34),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: h / 25),

                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  call.callerPic == null || call.callerPic == ''
                      ? Container(
                          height: w + (w / 140),
                          width: w,
                          color: Colors.white12,
                          child: Icon(
                            Icons.person,
                            size: 140,
                            color: Teme.isDarktheme(prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor,
                          ),
                        )
                      : Stack(
                          children: [
                            Container(
                                height: w + (w / 140),
                                width: w,
                                color: Colors.white12,
                                child: CachedNetworkImage(
                                  imageUrl: call.callerPic!,
                                  fit: BoxFit.cover,
                                  height: w + (w / 140),
                                  width: w,
                                  placeholder: (context, url) => Center(
                                      child: Container(
                                    height: w + (w / 140),
                                    width: w,
                                    color: Colors.white12,
                                    child: Icon(
                                      Icons.person,
                                      size: 140,
                                      color: Teme.isDarktheme(prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                    ),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: w + (w / 140),
                                    width: w,
                                    color: Colors.white12,
                                    child: Icon(
                                      Icons.person,
                                      size: 140,
                                      color: Teme.isDarktheme(prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                    ),
                                  ),
                                )),
                            Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.black.withOpacity(0.18),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: h / 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () async {
                            flutterLocalNotificationsPlugin.cancelAll();
                            await callMethods.endCall(call: call);
                            FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.callerId)
                                .collection(DbPaths.collectioncallhistory)
                                .doc(call.timeepoch.toString())
                                .set({
                              'STATUS': 'rejected',
                              'ENDED': DateTime.now(),
                            }, SetOptions(merge: true));
                            FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.receiverId)
                                .collection(DbPaths.collectioncallhistory)
                                .doc(call.timeepoch.toString())
                                .set({
                              'STATUS': 'rejected',
                              'ENDED': DateTime.now(),
                            }, SetOptions(merge: true));

                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.callerId)
                                .collection('recent')
                                .doc('callended')
                                .delete();
                            Future.delayed(const Duration(milliseconds: 200),
                                () async {
                              await FirebaseFirestore.instance
                                  .collection(DbPaths.collectionusers)
                                  .doc(call.callerId)
                                  .collection('recent')
                                  .doc('callended')
                                  .set({
                                'id': call.callerId,
                                'ENDED': DateTime.now().millisecondsSinceEpoch
                              });
                            });

                            firestoreDataProviderCALLHISTORY.fetchNextData(
                                'CALLHISTORY',
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .orderBy('TIME', descending: true)
                                    .limit(14),
                                true);
                            flutterLocalNotificationsPlugin.cancelAll();
                          },
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.redAccent,
                          padding: const EdgeInsets.all(15.0),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        ),
                        const SizedBox(width: 45),
                        RawMaterialButton(
                          onPressed: () async {
                            flutterLocalNotificationsPlugin.cancelAll();
                            await Permissions
                                    .cameraAndMicrophonePermissionsGranted()
                                .then((isgranted) async {
                              if (isgranted == true || kIsWeb) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        call.isvideocall == true
                                            ? VideoCall(
                                                prefs: prefs,
                                                currentuseruid: currentuseruid!,
                                                call: call,
                                                channelName: call.channelId!,
                                                role: _role,
                                              )
                                            : AudioCall(
                                                prefs: prefs,
                                                currentuseruid: currentuseruid,
                                                call: call,
                                                channelName: call.channelId,
                                                role: _role,
                                              ),
                                  ),
                                );
                              } else {
                                Lamat.showRationale(
                                  'pmc'.tr(),
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OpenSettings(
                                              permtype: 'contact',
                                              prefs: prefs,
                                            )));
                              }
                            }).catchError((onError) {
                              Lamat.showRationale(
                                'pmc'.tr(),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OpenSettings(
                                            permtype: 'contact',
                                            prefs: prefs,
                                          )));
                            });
                          },
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: AppConstants.lamatGreenColor400,
                          padding: const EdgeInsets.all(15.0),
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ))
        : Scaffold(
            backgroundColor: Teme.isDarktheme(prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            body: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: w > h ? 60 : 100),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    w > h
                        ? const SizedBox(
                            height: 0,
                          )
                        : Icon(
                            call.isvideocall == true
                                ? Icons.videocam_outlined
                                : Icons.mic,
                            size: 80,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor)
                                .withOpacity(0.3),
                          ),
                    w > h
                        ? const SizedBox(
                            height: 0,
                          )
                        : const SizedBox(
                            height: 20,
                          ),
                    Text(
                      call.isvideocall == true
                          ? "Incoming Video Call..."
                          : "Incoming Voice Call...",
                      style: TextStyle(
                        fontSize: 19,
                        color: Teme.isDarktheme(prefs)
                            ? AppConstants.primaryColor
                            : pickTextColorBasedOnBgColorAdvanced(
                                    AppConstants.backgroundColor)
                                .withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: w > h ? 16 : 50),
                    CachedImage(
                      call.callerPic,
                      isRound: true,
                      height: w > h ? 60 : 110,
                      width: w > h ? 60 : 110,
                      radius: w > h ? 70 : 138,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      call.callerName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(height: w > h ? 30 : 75),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RawMaterialButton(
                          onPressed: () async {
                            flutterLocalNotificationsPlugin.cancelAll();
                            await callMethods.endCall(call: call);
                            FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.callerId)
                                .collection(DbPaths.collectioncallhistory)
                                .doc(call.timeepoch.toString())
                                .set({
                              'STATUS': 'rejected',
                              'ENDED': DateTime.now(),
                            }, SetOptions(merge: true));
                            FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.receiverId)
                                .collection(DbPaths.collectioncallhistory)
                                .doc(call.timeepoch.toString())
                                .set({
                              'STATUS': 'rejected',
                              'ENDED': DateTime.now(),
                            }, SetOptions(merge: true));
                            //----------
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(call.callerId)
                                .collection('recent')
                                .doc('callended')
                                .delete();
                            Future.delayed(const Duration(milliseconds: 200),
                                () async {
                              await FirebaseFirestore.instance
                                  .collection(DbPaths.collectionusers)
                                  .doc(call.callerId)
                                  .collection('recent')
                                  .doc('callended')
                                  .set({
                                'id': call.callerId,
                                'ENDED': DateTime.now().millisecondsSinceEpoch
                              });
                            });

                            firestoreDataProviderCALLHISTORY.fetchNextData(
                                'CALLHISTORY',
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .orderBy('TIME', descending: true)
                                    .limit(14),
                                true);
                            flutterLocalNotificationsPlugin.cancelAll();
                          },
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: Colors.redAccent,
                          padding: const EdgeInsets.all(15.0),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        ),
                        const SizedBox(width: 45),
                        RawMaterialButton(
                          onPressed: () async {
                            flutterLocalNotificationsPlugin.cancelAll();
                            await Permissions
                                    .cameraAndMicrophonePermissionsGranted()
                                .then((isgranted) async {
                              if (isgranted == true || kIsWeb) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        call.isvideocall == true
                                            ? VideoCall(
                                                prefs: prefs,
                                                currentuseruid: currentuseruid!,
                                                call: call,
                                                channelName: call.channelId!,
                                                role: _role,
                                              )
                                            : AudioCall(
                                                prefs: prefs,
                                                currentuseruid: currentuseruid,
                                                call: call,
                                                channelName: call.channelId,
                                                role: _role,
                                              ),
                                  ),
                                );
                              } else {
                                Lamat.showRationale(
                                  'pmc'.tr(),
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OpenSettings(
                                              permtype: 'contact',
                                              prefs: prefs,
                                            )));
                              }
                            }).catchError((onError) {
                              Lamat.showRationale(
                                'pmc'.tr(),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OpenSettings(
                                            permtype: 'contact',
                                            prefs: prefs,
                                          )));
                            });
                          },
                          shape: const CircleBorder(),
                          elevation: 2.0,
                          fillColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.all(15.0),
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
