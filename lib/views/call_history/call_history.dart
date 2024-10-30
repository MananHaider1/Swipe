import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/call_history_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/call_utilities.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/permissions.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/Broadcast/add_contacts_to_broadcast.dart';
import 'package:lamatdating/views/Groups/add_contacts_to_group.dart';
import 'package:lamatdating/views/call_history/inf_listview.dart';
import 'package:lamatdating/views/contact_screens/smt_contact_page.dart';

class CallHistory extends ConsumerStatefulWidget {
  final String? userphone;
  final DataModel? model;
  final SharedPreferences prefs;
  const CallHistory(
      {super.key,
      required this.userphone,
      required this.model,
      required this.prefs});
  @override
  CallHistoryState createState() => CallHistoryState();
}

class CallHistoryState extends ConsumerState<CallHistory> {
  call(BuildContext context, bool isvideocall, LocalUserData peer) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';
    if (peer.name.toLowerCase().contains('deleted')) {
    } else {
      CallUtils.dial(
          prefs: widget.prefs,
          currentuseruid: widget.userphone,
          fromDp: myphotoUrl,
          toDp: peer.photoURL,
          fromUID: widget.userphone,
          fromFullname: mynickname,
          toUID: peer.id,
          toFullname: peer.name,
          context: context,
          isvideocall: isvideocall);
    }
  }

  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  BannerAd? myBanner;
  AdWidget? adWidget;
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
    Lamat.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);
    final callHistoryProvider =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);
    final contactsProvider = ref.watch(smartContactProvider);
    return Scaffold(
      key: _scaffold,
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
      floatingActionButton: callHistoryProvider.recievedDocs.isEmpty
          ? Padding(
              padding: EdgeInsets.only(
                  bottom: IsBannerAdShow == true && observer.isadmobshow == true
                      ? 60
                      : 0),
              child: FloatingActionButton(
                  heroTag: "dfsf4e8t4yaddweqewt834",
                  backgroundColor: AppConstants.secondaryColor,
                  child: const Icon(
                    Icons.add_call,
                    size: 30.0,
                    color: AppConstants.lamatWhite,
                  ),
                  onPressed: () {
                    !Responsive.isDesktop(context)
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SmartContactsPage(
                                    onTapCreateGroup: () {
                                      if (observer.isAllowCreatingGroups ==
                                          false) {
                                        Lamat.showRationale("Disabled");
                                      } else {
                                        !Responsive.isDesktop(context)
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddContactsToGroup(
                                                          currentUserNo:
                                                              widget.userphone,
                                                          model: widget.model,
                                                          biometricEnabled:
                                                              false,
                                                          prefs: widget.prefs,
                                                          isAddingWhileCreatingGroup:
                                                              true,
                                                        )))
                                            : ref
                                                .read(arrangementProvider
                                                    .notifier)
                                                .setArrangement(
                                                    AddContactsToGroup(
                                                  currentUserNo:
                                                      widget.userphone,
                                                  model: widget.model,
                                                  biometricEnabled: false,
                                                  prefs: widget.prefs,
                                                  isAddingWhileCreatingGroup:
                                                      true,
                                                ));
                                      }
                                    },
                                    onTapCreateBroadcast: () {
                                      if (observer.isAllowCreatingBroadcasts ==
                                          false) {
                                        Lamat.showRationale("Disabled");
                                      } else {
                                        !Responsive.isDesktop(context)
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AddContactsToBroadcast(
                                                          currentUserNo:
                                                              widget.userphone,
                                                          model: widget.model,
                                                          biometricEnabled:
                                                              false,
                                                          prefs: widget.prefs,
                                                          isAddingWhileCreatingBroadcast:
                                                              true,
                                                        )))
                                            : ref
                                                .read(arrangementProvider
                                                    .notifier)
                                                .setArrangement(
                                                    AddContactsToBroadcast(
                                                  currentUserNo:
                                                      widget.userphone,
                                                  model: widget.model,
                                                  biometricEnabled: false,
                                                  prefs: widget.prefs,
                                                  isAddingWhileCreatingBroadcast:
                                                      true,
                                                ));
                                      }
                                    },
                                    prefs: widget.prefs,
                                    biometricEnabled: false,
                                    currentUserNo: widget.userphone!,
                                    model: widget.model!)))
                        : ref
                            .read(arrangementProvider.notifier)
                            .setArrangement(SmartContactsPage(
                                onTapCreateGroup: () {
                                  if (observer.isAllowCreatingGroups == false) {
                                    Lamat.showRationale("Disabled");
                                  } else {
                                    !Responsive.isDesktop(context)
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddContactsToGroup(
                                                      currentUserNo:
                                                          widget.userphone,
                                                      model: widget.model,
                                                      biometricEnabled: false,
                                                      prefs: widget.prefs,
                                                      isAddingWhileCreatingGroup:
                                                          true,
                                                    )))
                                        : ref
                                            .read(arrangementProvider.notifier)
                                            .setArrangement(AddContactsToGroup(
                                              currentUserNo: widget.userphone,
                                              model: widget.model,
                                              biometricEnabled: false,
                                              prefs: widget.prefs,
                                              isAddingWhileCreatingGroup: true,
                                            ));
                                  }
                                },
                                onTapCreateBroadcast: () {
                                  if (observer.isAllowCreatingBroadcasts ==
                                      false) {
                                    Lamat.showRationale("Disabled");
                                  } else {
                                    !Responsive.isDesktop(context)
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddContactsToBroadcast(
                                                      currentUserNo:
                                                          widget.userphone,
                                                      model: widget.model,
                                                      biometricEnabled: false,
                                                      prefs: widget.prefs,
                                                      isAddingWhileCreatingBroadcast:
                                                          true,
                                                    )))
                                        : ref
                                            .read(arrangementProvider.notifier)
                                            .setArrangement(
                                                AddContactsToBroadcast(
                                              currentUserNo: widget.userphone,
                                              model: widget.model,
                                              biometricEnabled: false,
                                              prefs: widget.prefs,
                                              isAddingWhileCreatingBroadcast:
                                                  true,
                                            ));
                                  }
                                },
                                prefs: widget.prefs,
                                biometricEnabled: false,
                                currentUserNo: widget.userphone!,
                                model: widget.model!));
                  }),
            )
          : Padding(
              padding: EdgeInsets.only(
                  bottom: IsBannerAdShow == true && observer.isadmobshow == true
                      ? 60
                      : 0),
              child: FloatingActionButton(
                  heroTag: "dfsf4e8t4yt834",
                  backgroundColor: AppConstants.lamatWhite,
                  child: const Icon(
                    Icons.delete,
                    size: 30.0,
                    color: AppConstants.lamatREDbuttonColor,
                  ),
                  onPressed: () {
                    showDialog(
                      builder: (BuildContext context) {
                        return Builder(
                            builder: (BuildContext popable) => AlertDialog(
                                  backgroundColor:
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.dialogColorDark
                                          : AppConstants.backgroundColor,
                                  title: Text(
                                    "Clear Call log?",
                                    style: TextStyle(
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants.dialogColorDark
                                                  : AppConstants
                                                      .backgroundColor),
                                    ),
                                  ),
                                  content: Text(
                                    "Do you want to delete all call logs?",
                                    style: TextStyle(
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .dialogColorDark
                                                      : AppConstants
                                                          .backgroundColor)
                                              .withOpacity(0.6),
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'cancel'.tr(),
                                        style: const TextStyle(
                                            color: AppConstants.primaryColor,
                                            fontSize: 18),
                                      ),
                                      onPressed: () {
                                        Navigator.of(popable).pop();
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'delete'.tr(),
                                        style: const TextStyle(
                                            color: AppConstants
                                                .lamatREDbuttonColor,
                                            fontSize: 18),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(popable).pop();
                                        Lamat.toast('plswait'.tr());
                                        FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(widget.userphone)
                                            .collection(
                                                DbPaths.collectioncallhistory)
                                            .get()
                                            .then((snapshot) {
                                          for (DocumentSnapshot doc
                                              in snapshot.docs) {
                                            doc.reference.delete();
                                          }
                                        }).then((value) {
                                          callHistoryProvider.clearall();
                                        });
                                      },
                                    )
                                  ],
                                ));
                      },
                      context: context,
                    );
                  }),
            ),
      body: InfiniteListView(
        prefs: widget.prefs,
        firestoreDataProviderCALLHISTORY: callHistoryProvider,
        datatype: 'CALLHISTORY',
        refdata: FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.userphone)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('ENDED', descending: true)
            .limit(25),
        list: ListView.builder(
            padding: const EdgeInsets.only(bottom: 150),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: callHistoryProvider.recievedDocs.length,
            itemBuilder: (BuildContext context, int i) {
              var dc = callHistoryProvider.recievedDocs[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    // padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    // height: 40,
                    child: FutureBuilder<LocalUserData?>(
                        future:
                            contactsProvider.fetchUserDataFromnLocalOrServer(
                                widget.prefs, dc['PEER']),
                        builder: (BuildContext context,
                            AsyncSnapshot<LocalUserData?> snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            var user = snapshot.data;
                            return ListTile(
                              onLongPress: () {
                                List<Widget> tiles = List.from(<Widget>[]);

                                tiles.add(ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.delete),
                                    title: Text(
                                      'delete'.tr(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .dialogColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.of(context).pop();

                                      FirebaseFirestore.instance
                                          .collection(DbPaths.collectionusers)
                                          .doc(widget.userphone)
                                          .collection(
                                              DbPaths.collectioncallhistory)
                                          .doc(dc['TIME'].toString())
                                          .delete();
                                      Lamat.toast('deleted'.tr());
                                      callHistoryProvider.deleteSingle(dc);
                                    }));

                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                          backgroundColor:
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants.dialogColorDark
                                                  : AppConstants
                                                      .backgroundColor,
                                          children: tiles);
                                    });
                              },
                              isThreeLine: false,
                              leading: Stack(
                                children: [
                                  customCircleAvatar(
                                      url: user!.photoURL, radius: 22),
                                  dc['STARTED'] == null || dc['ENDED'] == null
                                      ? const SizedBox(
                                          height: 0,
                                          width: 0,
                                        )
                                      : Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                6, 2, 6, 2),
                                            decoration: const BoxDecoration(
                                                color:
                                                    AppConstants.primaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                            child: Text(
                                              dc['ENDED']
                                                          .toDate()
                                                          .difference(
                                                              dc['STARTED']
                                                                  .toDate())
                                                          .inMinutes <
                                                      1
                                                  ? '${dc['ENDED'].toDate().difference(dc['STARTED'].toDate()).inSeconds}s'
                                                  : '${dc['ENDED'].toDate().difference(dc['STARTED'].toDate()).inMinutes}m',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ))
                                ],
                              ),
                              title: Text(
                                user.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      dc['TYPE'] == 'INCOMING'
                                          ? (dc['STARTED'] == null
                                              ? Icons.call_missed
                                              : Icons.call_received)
                                          : (dc['STARTED'] == null
                                              ? Icons.call_made_rounded
                                              : Icons.call_made_rounded),
                                      size: 15,
                                      color: dc['TYPE'] == 'INCOMING'
                                          ? (dc['STARTED'] == null
                                              ? Colors.redAccent
                                              : AppConstants
                                                  .lamatGreenColorAccent)
                                          : (dc['STARTED'] == null
                                              ? Colors.redAccent
                                              : AppConstants
                                                  .lamatGreenColorAccent),
                                    ),
                                    const SizedBox(
                                      width: 7,
                                    ),
                                    IsShowNativeTimDate == true
                                        ? Text(
                                            '${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).MMMM.toString()} ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).date}, ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).Hm}',
                                            style: const TextStyle(
                                                color: AppConstants.lamatGrey),
                                          )
                                        : Text(
                                            '${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).MMMMd}, ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).Hm}',
                                            style: const TextStyle(
                                                color: AppConstants.lamatGrey),
                                          ),
                                    // Text(time)
                                  ],
                                ),
                              ),
                              trailing: observer.isOngoingCall
                                  ? const SizedBox()
                                  : IconButton(
                                      icon: Icon(
                                          dc['ISVIDEOCALL'] == true
                                              ? Icons.video_call
                                              : Icons.call,
                                          color: AppConstants.primaryColor,
                                          size: 24),
                                      onPressed:
                                          OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe ==
                                                  true
                                              ? () {}
                                              : observer.iscallsallowed == false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        "Calling feature has been temporarily disabled by Admin.",
                                                      );
                                                    }
                                                  : () async {
                                                      if (dc['ISVIDEOCALL'] ==
                                                          true) {
                                                        //---Make a video call
                                                        await Permissions
                                                                .cameraAndMicrophonePermissionsGranted()
                                                            .then((isgranted) {
                                                          if (isgranted ==
                                                                  true ||
                                                              kIsWeb) {
                                                            call(context, true,
                                                                user);
                                                          } else {
                                                            Lamat.showRationale(
                                                              'pmc'.tr(),
                                                            );
                                                            !Responsive
                                                                    .isDesktop(
                                                                        context)
                                                                ? Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                OpenSettings(
                                                                                  permtype: 'contact',
                                                                                  prefs: widget.prefs,
                                                                                )))
                                                                : ref
                                                                    .read(arrangementProviderExtend
                                                                        .notifier)
                                                                    .setArrangement(
                                                                        OpenSettings(
                                                                      permtype:
                                                                          'contact',
                                                                      prefs: widget
                                                                          .prefs,
                                                                    ));
                                                          }
                                                        }).catchError(
                                                                (onError) {
                                                          Lamat.showRationale(
                                                            'pmc'.tr(),
                                                          );
                                                          !Responsive.isDesktop(
                                                                  context)
                                                              ? Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              OpenSettings(
                                                                                permtype: 'contact',
                                                                                prefs: widget.prefs,
                                                                              )))
                                                              : ref
                                                                  .read(arrangementProviderExtend
                                                                      .notifier)
                                                                  .setArrangement(
                                                                      OpenSettings(
                                                                    permtype:
                                                                        'contact',
                                                                    prefs: widget
                                                                        .prefs,
                                                                  ));
                                                        });
                                                      } else if (dc[
                                                              'ISVIDEOCALL'] ==
                                                          false) {
                                                        //---Make a audio call
                                                        await Permissions
                                                                .cameraAndMicrophonePermissionsGranted()
                                                            .then((isgranted) {
                                                          if (isgranted ==
                                                                  true ||
                                                              kIsWeb) {
                                                            call(context, false,
                                                                user);
                                                          } else {
                                                            Lamat.showRationale(
                                                              'pmc'.tr(),
                                                            );
                                                            !Responsive
                                                                    .isDesktop(
                                                                        context)
                                                                ? Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                OpenSettings(
                                                                                  permtype: 'contact',
                                                                                  prefs: widget.prefs,
                                                                                )))
                                                                : ref
                                                                    .read(arrangementProviderExtend
                                                                        .notifier)
                                                                    .setArrangement(
                                                                        OpenSettings(
                                                                      permtype:
                                                                          'contact',
                                                                      prefs: widget
                                                                          .prefs,
                                                                    ));
                                                          }
                                                        }).catchError(
                                                                (onError) {
                                                          Lamat.showRationale(
                                                            'pmc'.tr(),
                                                          );
                                                          !Responsive.isDesktop(
                                                                  context)
                                                              ? Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              OpenSettings(
                                                                                permtype: 'contact',
                                                                                prefs: widget.prefs,
                                                                              )))
                                                              : ref
                                                                  .read(arrangementProviderExtend
                                                                      .notifier)
                                                                  .setArrangement(
                                                                      OpenSettings(
                                                                    permtype:
                                                                        'contact',
                                                                    prefs: widget
                                                                        .prefs,
                                                                  ));
                                                        });
                                                      }
                                                    }),
                            );
                          }
                          return ListTile(
                            onLongPress: () {
                              List<Widget> tiles = List.from(<Widget>[]);

                              tiles.add(ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.delete),
                                  title: Text(
                                    'delete'.tr(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    Lamat.toast('plswait'.tr());
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(widget.userphone)
                                        .collection(
                                            DbPaths.collectioncallhistory)
                                        .doc(dc['TIME'].toString())
                                        .delete();
                                    Lamat.toast('Deleted!');
                                    callHistoryProvider.deleteSingle(dc);
                                  }));

                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(children: tiles);
                                  });
                            },
                            isThreeLine: false,
                            leading: Stack(
                              children: [
                                customCircleAvatar(radius: 22),
                                dc['STARTED'] == null || dc['ENDED'] == null
                                    ? const SizedBox(
                                        height: 0,
                                        width: 0,
                                      )
                                    : Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              6, 2, 6, 2),
                                          decoration: const BoxDecoration(
                                              color: AppConstants
                                                  .lamatGreenColorAccent,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Text(
                                            dc['ENDED']
                                                        .toDate()
                                                        .difference(
                                                            dc['STARTED']
                                                                .toDate())
                                                        .inMinutes <
                                                    1
                                                ? '${dc['ENDED'].toDate().difference(dc['STARTED'].toDate()).inSeconds}s'
                                                : '${dc['ENDED'].toDate().difference(dc['STARTED'].toDate()).inMinutes}m',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10),
                                          ),
                                        ))
                              ],
                            ),
                            title: Text(
                              contactsProvider.contactsBookContactList!.entries
                                          .toList()
                                          .indexWhere((element) =>
                                              element.key == dc['PEER']) >=
                                      0
                                  ? contactsProvider
                                      .contactsBookContactList!.entries
                                      .toList()[contactsProvider
                                          .contactsBookContactList!.entries
                                          .toList()
                                          .indexWhere((element) =>
                                              element.key == dc['PEER'])]
                                      .value
                                  : dc['PEER'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                  height: 1.4,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    dc['TYPE'] == 'INCOMING'
                                        ? (dc['STARTED'] == null
                                            ? Icons.call_missed
                                            : Icons.call_received)
                                        : (dc['STARTED'] == null
                                            ? Icons.call_made_rounded
                                            : Icons.call_made_rounded),
                                    size: 15,
                                    color: dc['TYPE'] == 'INCOMING'
                                        ? (dc['STARTED'] == null
                                            ? Colors.redAccent
                                            : AppConstants
                                                .lamatGreenColorAccent)
                                        : (dc['STARTED'] == null
                                            ? Colors.redAccent
                                            : AppConstants
                                                .lamatGreenColorAccent),
                                  ),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  IsShowNativeTimDate == true
                                      ? Text(
                                          '${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).MMMM.toString()} ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).date}, ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).Hm}',
                                          style: const TextStyle(
                                              color: AppConstants.lamatGrey),
                                        )
                                      : Text(
                                          '${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).MMMMd}, ${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(dc["TIME"])).Hm}',
                                          style: const TextStyle(
                                              color: AppConstants.lamatGrey),
                                        ),
                                  // Text(time)
                                ],
                              ),
                            ),
                            trailing: observer.isOngoingCall
                                ? const SizedBox()
                                : IconButton(
                                    icon: Icon(
                                        dc['ISVIDEOCALL'] == true
                                            ? Icons.video_call
                                            : Icons.call,
                                        color: AppConstants.primaryColor,
                                        size: 24),
                                    onPressed: null),
                          );
                        }),
                  ),
                  const Divider(
                    height: 0,
                  ),
                ],
              );
            }),
      ),
    );
  }
}

Widget customCircleAvatar({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: const Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: const Icon(
        Icons.person,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage(url),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.person,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.person,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}

Widget customCircleAvatarGroup({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: const Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: const Icon(
        Icons.people,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage(url),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.people,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}

Widget customCircleAvatarBroadcast({String? url, double? radius}) {
  if (url == null || url == '') {
    return CircleAvatar(
      backgroundColor: const Color(0xffE6E6E6),
      radius: radius ?? 30,
      child: const Icon(
        Icons.campaign_sharp,
        color: Color(0xffCCCCCC),
      ),
    );
  } else {
    return CachedNetworkImage(
        imageUrl: url,
        imageBuilder: (context, imageProvider) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              backgroundImage: NetworkImage(url),
            ),
        placeholder: (context, url) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.campaign_sharp,
                color: Color(0xffCCCCCC),
              ),
            ),
        errorWidget: (context, url, error) => CircleAvatar(
              backgroundColor: const Color(0xffE6E6E6),
              radius: radius ?? 30,
              child: const Icon(
                Icons.campaign_sharp,
                color: Color(0xffCCCCCC),
              ),
            ));
  }
}

Widget customCircleAvatarStatus({String? url, String? profilePic}) {
  return Container(
      width: 90,
      height: 140,
      decoration: const BoxDecoration(
        borderRadius:
            BorderRadius.all(Radius.circular(AppConstants.defaultNumericValue)),
        color: Color(0xffE6E6E6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        child: url == null || url == ''
            ? CachedNetworkImage(
                imageUrl: profilePic ??
                    "https://static.vecteezy.com/system/resources/previews/004/509/264/original/profile-placeholder-default-female-avatar-vector.jpg",
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  // width: 60,
                  // height: 120,
                ),
                placeholder: (context, url) => const Icon(
                  Icons.person,
                  color: Color(0xffCCCCCC),
                  size: 60,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  color: Color(0xffCCCCCC),
                  size: 60,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  // width: 60,
                  // height: 120,
                ),
                placeholder: (context, url) => const Icon(
                  Icons.person,
                  color: Color(0xffCCCCCC),
                  size: 60,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.person,
                  color: Color(0xffCCCCCC),
                  size: 60,
                ),
              ),
      ));
}
