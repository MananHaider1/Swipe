import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/utils/call_utilities.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/permissions.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';

class ProfileView extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
  final List<dynamic> mediaMesages;
  const ProfileView(
      this.user, this.currentUserNo, this.model, this.prefs, this.mediaMesages,
      {super.key, this.firestoreUserDoc});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        prefs: widget.prefs,
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: widget.user[Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.user[Dbkeys.phone],
        toFullname: widget.user[Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  BannerAd? myBanner;
  AdWidget? adWidget;
  StreamSubscription? chatStatusSubscriptionForPeer;
  @override
  void initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.read(observerProvider);
      listenToBlock();
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.user[Dbkeys.phone])
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data()!.containsKey(widget.currentUserNo)) {
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setState(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatStatusSubscriptionForPeer?.cancel();
    if (IsBannerAdShow == true && myBanner != null && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  buildBody(BuildContext context) {
    final observer = ref.watch(observerProvider);
    return Column(
      children: [
        Container(
          color: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.phoneNumber.tr(),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: 16),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(
                height: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.user[Dbkeys.phone],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                        fontSize: 15.3),
                  ),
                  Row(
                    children: [
                      if (widget.currentUserNo != widget.user[Dbkeys.phone])
                        observer.isCallFeatureTotallyHide == true ||
                                observer.isOngoingCall
                            ? const SizedBox()
                            : IconButton(
                                onPressed: observer.iscallsallowed == false
                                    ? () {
                                        Lamat.showRationale(
                                          LocaleKeys.callnotallowed.tr(),
                                        );
                                      }
                                    : hasPeerBlockedMe == true
                                        ? () {
                                            Lamat.toast(
                                              LocaleKeys.userhasblocked.tr(),
                                            );
                                          }
                                        : () async {
                                            await Permissions
                                                    .cameraAndMicrophonePermissionsGranted()
                                                .then((isgranted) {
                                              if (isgranted == true || kIsWeb) {
                                                call(context, false);
                                              } else {
                                                Lamat.showRationale(
                                                  LocaleKeys.pmc.tr(),
                                                );
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings(
                                                              permtype:
                                                                  'contact',
                                                              prefs:
                                                                  widget.prefs,
                                                            )));
                                              }
                                            }).catchError((onError) {
                                              Lamat.showRationale(
                                                LocaleKeys.pmc.tr(),
                                              );
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OpenSettings(
                                                            permtype: 'contact',
                                                            prefs: widget.prefs,
                                                          )));
                                            });
                                          },
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppConstants.primaryColor,
                                )),
                      if (widget.currentUserNo != widget.user[Dbkeys.phone])
                        observer.isCallFeatureTotallyHide == true ||
                                observer.isOngoingCall
                            ? const SizedBox()
                            : IconButton(
                                onPressed: observer.iscallsallowed == false
                                    ? () {
                                        Lamat.showRationale(
                                          LocaleKeys.callnotallowed.tr(),
                                        );
                                      }
                                    : hasPeerBlockedMe == true
                                        ? () {
                                            Lamat.toast(
                                              LocaleKeys.userhasblocked.tr(),
                                            );
                                          }
                                        : () async {
                                            await Permissions
                                                    .cameraAndMicrophonePermissionsGranted()
                                                .then((isgranted) {
                                              if (isgranted == true || kIsWeb) {
                                                call(context, true);
                                              } else {
                                                Lamat.showRationale(
                                                  LocaleKeys.pmc.tr(),
                                                );
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OpenSettings(
                                                              permtype:
                                                                  'contact',
                                                              prefs:
                                                                  widget.prefs,
                                                            )));
                                              }
                                            }).catchError((onError) {
                                              Lamat.showRationale(
                                                LocaleKeys.pmc.tr(),
                                              );
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          OpenSettings(
                                                            permtype: 'contact',
                                                            prefs: widget.prefs,
                                                          )));
                                            });
                                          },
                                icon: const Icon(
                                  Icons.videocam_rounded,
                                  size: 26,
                                  color: AppConstants.primaryColor,
                                )),
                      if (widget.currentUserNo != widget.user[Dbkeys.phone])
                        IconButton(
                            onPressed: () {
                              if (widget.firestoreUserDoc != null) {
                                widget.model!.addUser(widget.firestoreUserDoc!);
                              }

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          isSharingIntentForwarded: false,
                                          prefs: widget.prefs,
                                          model: widget.model!,
                                          currentUserNo: widget.currentUserNo,
                                          peerNo: widget.user[Dbkeys.phone],
                                          unread: 0)),
                                  (Route r) => r.isFirst);
                            },
                            icon: const Icon(
                              Icons.message,
                              color: AppConstants.primaryColor,
                            )),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 0,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 18, top: 8),
          color: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          // height: 30,
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(
                LocaleKeys.encryption.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 2,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
            ),
            dense: false,
            subtitle: Text(
              LocaleKeys.encryptionshort.tr(),
              style: const TextStyle(
                  color: AppConstants.lamatGrey, height: 1.3, fontSize: 15),
            ),
            trailing: const Padding(
              padding: EdgeInsets.only(top: 32),
              child: Icon(
                Icons.lock,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);

    var w = MediaQuery.of(context).size.width;
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(widget.user[Dbkeys.accountstatus] ==
                Dbkeys.sTATUSdeleted
            ? Scaffold(
                backgroundColor: Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor,
                appBar: AppBar(
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  elevation: 0,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(
                        height: 38,
                      ),
                      Text(LocaleKeys.userDeleted.tr()),
                    ],
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor,
                bottomSheet: IsBannerAdShow == true &&
                        observer.isadmobshow == true &&
                        adWidget != null &&
                        !kIsWeb
                    ? Container(
                        height: 60,
                        margin: EdgeInsets.only(
                            bottom: !kIsWeb
                                ? Platform.isIOS == true
                                    ? 25.0
                                    : 5
                                : 25,
                            top: 0),
                        child: Center(child: adWidget),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                // backgroundColor: AppConstants.lamatWhite,
                body: ListView(
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.user[Dbkeys.photoUrl] ?? '',
                          imageBuilder: (context, imageProvider) => Container(
                            width: w,
                            height: w / 1.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            width: w,
                            height: w / 1.2,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.person,
                                color: AppConstants.lamatGrey.withOpacity(0.5),
                                size: 95),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: w,
                            height: w / 1.2,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.person,
                                color: AppConstants.lamatGrey.withOpacity(0.5),
                                size: 95),
                          ),
                        ),
                        Container(
                          width: w,
                          height: w / 1.2,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.29),
                              Colors.black.withOpacity(0.48),
                            ],
                          )),
                        ),
                        Positioned(
                            bottom: 19,
                            left: 19,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: Text(
                                widget.user[Dbkeys.nickname],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                        Positioned(
                          top: 11,
                          left: 7,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_sharp,
                              size: 25,
                              color: AppConstants.lamatWhite,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      color: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.about.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            widget.user[Dbkeys.aboutMe] == null ||
                                    widget.user[Dbkeys.aboutMe] == ''
                                ? '${LocaleKeys.heyim.tr()} $Appname'
                                : widget.user[Dbkeys.aboutMe],
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor),
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Text(
                            getJoinTime(widget.user[Dbkeys.joinedOn], context),
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: AppConstants.lamatGrey,
                                fontSize: 13.3),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == true
                        ? widget.user.containsKey(Dbkeys.deviceSavedLeads)
                            ? widget.user[Dbkeys.deviceSavedLeads]
                                    .contains(widget.currentUserNo)
                                ? buildBody(context)
                                : const SizedBox(
                                    height: 40,
                                  )
                            : const SizedBox()
                        : buildBody(context),
                    SizedBox(
                      height: IsBannerAdShow == true &&
                              observer.isadmobshow == true &&
                              adWidget != null &&
                              !kIsWeb
                          ? 90
                          : 20,
                    ),
                  ],
                ),
              )));
  }
}
