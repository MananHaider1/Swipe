// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, no_logic_in_create_state, deprecated_member_use

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as local;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
// import 'package:lamatdating/views/auth/login_page.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/contact_screens/smt_contact_page.dart';
import 'package:lamatdating/views/tabs/chat/updates/updates.dart';
import 'package:lamatdating/views/tabs/home/notification_page.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/Broadcast/add_contacts_to_broadcast.dart';
import 'package:lamatdating/views/Groups/add_contacts_to_group.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/translate_notifs.dart';
import 'package:lamatdating/views/notifications/notifs.dart';
import 'package:lamatdating/views/tabs/chat/recents/chat.dart';
import 'package:lamatdating/views/sharing_intent/contact_to_share.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/providers/call_history_provider.dart';
import 'package:lamatdating/providers/currentchat_peer.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/utils/variants_gen.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/settings/account_settings.dart';

class ChatHomePage extends ConsumerStatefulWidget {
  const ChatHomePage(
      {
        super.key,
        required this.currentUserNo,
      required this.prefs,
      required this.doc,
      this.isShowOnlyCircularSpin = false,
      })
      ;
  final String currentUserNo;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isShowOnlyCircularSpin;
  final SharedPreferences prefs;
  @override
  ConsumerState createState() => HomepageState(doc: doc);
}

class HomepageState extends ConsumerState<ChatHomePage>
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin {
  HomepageState({Key? key, doc}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  // User? user;
  TabController? controller;
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();
  late StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile>? _sharedFiles = [];
  String? _sharedText;
  @override
  bool get wantKeepAlive => true;

  bool isFetching = true;
  List phoneNumberVariants = [];
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setIsActive();
    } else {
      setLastSeen();
    }
  }

  void setIsActive() async {
    if (widget.currentUserNo != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.prefs.getString(Dbkeys.phone))
          .update(
        {
          "isOnline": true,
          Dbkeys.lastSeen: true,
          Dbkeys.lastOnline: DateTime.now().millisecondsSinceEpoch
        },
      );
    }
  }

  void setLastSeen() async {
    if (widget.currentUserNo != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.prefs.getString(Dbkeys.phone))
          .update(
        {
          "isOnline": false,
          Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch
        },
      );
    }
  }

  final TextEditingController _filter = TextEditingController();
  bool isAuthenticating = false;

  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? deviceid;
  var mapDeviceInfo = {};
  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;

  @override
  void initState() {
    if (kIsWeb == false) {
      listenToSharingintent();
    }
    listenToNotification();
    // if (kIsWeb == false) {
    setdeviceinfo();
    // }
    // registerNotification();

    controller = TabController(length: 3, vsync: this);
    controller!.index = 1;

    Lamat.internetLookUp();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      LocalAuthentication().canCheckBiometrics.then((res) {
        if (res) biometricEnabled = true;
      });
    }

    super.initState();
  }

  int selectedIndex = 1;

  @override
  void didChangeDependencies() async {
    getSignedInUserOrRedirect();
    if (widget.currentUserNo != '') {
      getModel();
    }
    controller!.addListener(() {
      final statusProvider = ref.watch(statusProviderProvider);
      final contactsProvider = ref.watch(smartContactProvider);
      setState(() {
        selectedIndex =
            controller!.index; // Update the list view state with the index
      });
      if (IsShowSearchTab == true) {
        if (controller!.index == 2) {
          statusProvider.searchContactStatus(
              widget.currentUserNo,
              FutureGroup(),
              contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer);
        }
      } else {
        if (controller!.index == 1) {
          statusProvider.searchContactStatus(
              widget.currentUserNo,
              FutureGroup(),
              contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer);
        }
      }
    });

    super.didChangeDependencies();
  }

  incrementSessionCount(String myphone) async {
    final statusProvider = ref.watch(statusProviderProvider);
    final contactsProvider = ref.watch(smartContactProvider);
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);
    if (kIsWeb == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docuserscount)
          .set(
              Platform.isAndroid
                  ? {
                      Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
                    }
                  : {
                      Dbkeys.totalvisitsIOS: FieldValue.increment(1),
                    },
              SetOptions(merge: true));
    }
    if (kIsWeb == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.prefs.getString(Dbkeys.phone))
          .set(
              Platform.isAndroid
                  ? {
                      Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                      Dbkeys.notificationStringsMap:
                          getTranslateNotificationStringsMap(context),
                      Dbkeys.totalvisitsANDROID: FieldValue.increment(1),
                    }
                  : {
                      Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
                      Dbkeys.notificationStringsMap:
                          getTranslateNotificationStringsMap(context),
                      Dbkeys.totalvisitsIOS: FieldValue.increment(1),
                    },
              SetOptions(merge: true));
    }
    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.prefs.getString(Dbkeys.phone))
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(10),
        true);
    // if (OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == false) {
    await contactsProvider.fetchContacts(
        context, _cachedModel, myphone, widget.prefs, false,
        currentuserphoneNumberVariants: phoneNumberVariants);
    // }

    //  await statusProvider.searchContactStatus(
    //       myphone, contactsProvider.joinedUserPhoneStringAsInServer);
    statusProvider.triggerDeleteMyExpiredStatus(myphone);
    statusProvider.triggerDeleteOtherUsersExpiredStatus(myphone);
    if (_sharedFiles!.isNotEmpty || _sharedText != null) {
      triggerSharing();
    }
  }

  triggerSharing() {
    final observer = ref.watch(observerProvider);
    if (_sharedText != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SelectContactToShare(
                  prefs: widget.prefs,
                  model: _cachedModel!,
                  currentUserNo: widget.currentUserNo,
                  sharedFiles: _sharedFiles!,
                  sharedText: _sharedText)));
    } else if (_sharedFiles != null) {
      if (_sharedFiles!.length > observer.maxNoOfFilesInMultiSharing) {
        Lamat.toast(
            "${LocaleKeys.maxnooffiles.tr()}: ${observer.maxNoOfFilesInMultiSharing}");
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SelectContactToShare(
                    prefs: widget.prefs,
                    model: _cachedModel!,
                    currentUserNo: widget.currentUserNo,
                    sharedFiles: _sharedFiles!,
                    sharedText: _sharedText)));
      }
    }
  }

  listenToSharingintent() {
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance.getMediaStream()
        .listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
      });
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() async {
      final _sharedFile = value.first;
        // extract the text from txt file
        final path = _sharedFile.path;
       _sharedText = await rootBundle.loadString(path);

      });
    }, onError: (err) {
      debugPrint("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
     setState(() async {
      final _sharedFile = value.first;
        // extract the text from txt file
        final path = _sharedFile.path;
       _sharedText = await rootBundle.loadString(path);

      });
    });
  }

  unsubscribeToNotification(String? userphone) async {
    if (userphone != null) {
      if (!kIsWeb) {
        await FirebaseMessaging.instance
            .unsubscribeFromTopic(userphone.replaceFirst(RegExp(r'\+'), ''));
      }
    }
    if (!kIsWeb) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(Dbkeys.topicUSERS)
          .catchError((err) {
        debugPrint(err.toString());
      });
    }
    if (!kIsWeb) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(Platform.isAndroid
              ? Dbkeys.topicUSERSandroid
              : Dbkeys.topicUSERSios)
          .catchError((err) {
        debugPrint(err.toString());
      });
    } else {
      // await FirebaseMessaging.instance
      //     .unsubscribeFromTopic(Dbkeys.topicUSERSweb)
      //     .catchError((err) {
      //   debugPrint(err.toString());
      // });
    }
  }

  void registerNotification() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  setdeviceinfo() async {
    if (!kIsWeb) {
      if (Platform.isAndroid == true) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceid = androidInfo.id + androidInfo.device;
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: androidInfo.model,
            Dbkeys.deviceInfoOS: 'android',
            Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: androidInfo.id,
            Dbkeys.deviceInfoOSID: androidInfo.id,
            Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
            Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      } else if (Platform.isIOS == true) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceid =
              "${iosInfo.systemName}${iosInfo.model}${iosInfo.systemVersion}";
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: iosInfo.model,
            Dbkeys.deviceInfoOS: 'ios',
            Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
            Dbkeys.deviceInfoOSID: iosInfo.name,
            Dbkeys.deviceInfoOSVERSION: iosInfo.name,
            Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      }
    } else {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      setState(() {
        deviceid = webBrowserInfo.appName! + widget.currentUserNo;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: webBrowserInfo.appName,
          Dbkeys.deviceInfoOS: 'web',
          Dbkeys.deviceInfoISPHYSICAL: webBrowserInfo.platform,
          Dbkeys.deviceInfoDEVICEID: deviceid,
          Dbkeys.deviceInfoOSID: webBrowserInfo.productSub,
          Dbkeys.deviceInfoOSVERSION: webBrowserInfo.productSub,
          Dbkeys.deviceInfoMANUFACTURER: webBrowserInfo.appName,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = ref.watch(userProviderProvider);

    userProvider.getUserDetails(widget.currentUserNo);
  }

  logout(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut();

    await widget.prefs.clear();

    FlutterSecureStorage storage = const FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;
    if (widget.currentUserNo != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .update({
        Dbkeys.notificationTokens: [],
      });
    }

    await widget.prefs.setBool(Dbkeys.isTokenGenerated, false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const MyApp(),
      ),
      (Route route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    for (var controller in controllers) {
      controller.close();
    }
    _filter.dispose();
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    if (widget.currentUserNo.isNotEmpty) {
      setLastSeen();
    }

    _intentDataStreamSubscription.cancel();
  }

  void cancelUnreadSubscriptions() {
    for (var subscription in unreadSubscriptions) {
      subscription.cancel();
    }
  }

  void listenToNotification() async {
    //FOR ANDROID & IOS  background notification is handled at the very top of main.dart ------

    //ANDROID & iOS  OnMessage callback
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // ignore: unnecessary_null_comparison
      flutterLocalNotificationsPlugin.cancelAll();

      if (message.data['title'] != 'Call Ended' &&
          message.data['title'] != 'Missed Call' &&
          message.data['title'] != 'You have message(s)' &&
          message.data['title'] != 'Incoming Video Call...' &&
          message.data['title'] != 'Incoming Audio Call...' &&
          message.data['title'] != 'Incoming Call ended' &&
          message.data['title'] != 'message in Group') {
        Lamat.toast(LocaleKeys.notifications.tr());
      } else {
        if (message.data['title'] == 'message in Group') {
          // var currentpeer =
          //     Provider.of<CurrentChatPeer>(this.context, listen: false);
          // if (currentpeer.groupChatId != message.data['groupid']) {
          //   flutterLocalNotificationsPlugin..cancelAll();

          //   showOverlayNotification((context) {
          //     return Card(
          //       margin: const EdgeInsets.symmetric(horizontal: 4),
          //       child: SafeArea(
          //         child: ListTile(
          //           title: Text(
          //             message.data['titleMultilang'],
          //             maxLines: 1,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //           subtitle: Text(
          //             message.data['bodyMultilang'],
          //             maxLines: 2,
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //           trailing: IconButton(
          //               icon: Icon(Icons.close),
          //               onPressed: () {
          //                 OverlaySupportEntry.of(context)!.dismiss();
          //               }),
          //         ),
          //       ),
          //     );
          //   }, duration: Duration(milliseconds: 2000));
          // }
        } else if (message.data['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else {
          if (message.data['title'] == 'Incoming Audio Call...' ||
              message.data['title'] == 'Incoming Video Call...') {
            final data = message.data;
            final title = data['title'];
            final body = data['body'];
            final titleMultilang = data['titleMultilang'];
            final bodyMultilang = data['bodyMultilang'];
            await showNotificationWithDefaultSound(
                title, body, titleMultilang, bodyMultilang);
          } else if (message.data['title'] == 'You have message(s)') {
            var currentpeer = ref.watch(currentChatPeerProviderProvider);

            if (currentpeer.peerid != message.data['peerid']) {
              // FlutterRingtonePlayer.playNotification();
              showOverlayNotification((context) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: SafeArea(
                    child: ListTile(
                      title: Text(
                        message.data['titleMultilang'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        message.data['bodyMultilang'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            OverlaySupportEntry.of(context)!.dismiss();
                          }),
                    ),
                  ),
                );
              }, duration: const Duration(milliseconds: 2000));
            }
          } else {
            showOverlayNotification((context) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: SafeArea(
                  child: ListTile(
                    leading: message.data.containsKey("image")
                        ? null
                        : message.data["image"] == null
                            ? const SizedBox()
                            : Image.network(
                                message.data['image'],
                                width: 50,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                    title: Text(
                      message.data['titleMultilang'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      message.data['bodyMultilang'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          OverlaySupportEntry.of(context)!.dismiss();
                        }),
                  ),
                ),
              );
            }, duration: const Duration(milliseconds: 2000));
          }
        }
      }
    });
    //ANDROID & iOS  onMessageOpenedApp callback
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      flutterLocalNotificationsPlugin.cancelAll();
      Map<String, dynamic> notificationData = message.data;
      AndroidNotification? android = message.notification?.android;
      if (android != null) {
        if (notificationData['title'] == 'Call Ended') {
          flutterLocalNotificationsPlugin.cancelAll();
        } else if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'message in Group') {
          flutterLocalNotificationsPlugin.cancelAll();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AllNotifications(
                        prefs: widget.prefs,
                      )));
        } else {
          flutterLocalNotificationsPlugin.cancelAll();
        }
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        flutterLocalNotificationsPlugin.cancelAll();
        Map<String, dynamic>? notificationData = message.data;
        if (notificationData['title'] != 'Call Ended' &&
            notificationData['title'] != 'You have message(s)' &&
            notificationData['title'] != 'Missed Call' &&
            notificationData['title'] != 'Incoming Video Call...' &&
            notificationData['title'] != 'Incoming Audio Call...' &&
            notificationData['title'] != 'Incoming Call ended' &&
            notificationData['title'] != 'message in Group') {
          flutterLocalNotificationsPlugin.cancelAll();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AllNotifications(
                        prefs: widget.prefs,
                      )));
        }
      }
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;
  UserProfileModel? currentUserProfile;

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserProfile!.phoneNumber);
    return _cachedModel;
  }

  getSignedInUserOrRedirect() async {
    currentUserProfile = ref.watch(userProfileFutureProvider).value;

    try {
      setState(() {
        isblockNewlogins = widget.doc.data()![Dbkeys.isblocknewlogins];
        isApprovalNeededbyAdminForNewUser =
            widget.doc[Dbkeys.isaccountapprovalbyadminneeded];
        accountApprovalMessage = widget.doc[Dbkeys.accountapprovalmessage];
      });
      if (widget.doc.data()![Dbkeys.isemulatorallowed] == false &&
          mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
        setState(() {
          isNotAllowEmulator = true;
        });
      } else {
        if (kIsWeb == false) {
          if (widget.doc[Platform.isAndroid
                  ? Dbkeys.isappunderconstructionandroid
                  : Platform.isIOS
                      ? Dbkeys.isappunderconstructionios
                      : Dbkeys.isappunderconstructionweb] ==
              true) {
            await unsubscribeToNotification(
                widget.prefs.getString(Dbkeys.phone));
            maintainanceMessage = widget.doc[Dbkeys.maintainancemessage];
            setState(() {});
          } else {
            final PackageInfo info = await PackageInfo.fromPlatform();
            widget.prefs.setString('app_version', info.version);

            int currentAppVersionInPhone = int.tryParse(info.version
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            int currentNewAppVersionInServer =
                int.tryParse(widget.doc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[0]
                            .toString()
                            .padLeft(3, '0') +
                        widget.doc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[1]
                            .toString()
                            .padLeft(3, '0') +
                        widget.doc[Platform.isAndroid
                                ? Dbkeys.latestappversionandroid
                                : Platform.isIOS
                                    ? Dbkeys.latestappversionios
                                    : Dbkeys.latestappversionweb]
                            .trim()
                            .split(".")[2]
                            .toString()
                            .padLeft(3, '0')) ??
                    0;
            if (currentAppVersionInPhone < currentNewAppVersionInServer) {
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  String title = LocaleKeys.updateAvailable.tr();
                  String message = LocaleKeys.updateavlmsg.tr();
                  String btnLabel = LocaleKeys.updatnow.tr();

                  return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        backgroundColor: Teme.isDarktheme(widget.prefs)
                            ? AppConstants.dialogColorDark
                            : AppConstants.backgroundColor,
                        title: Text(
                          title,
                          style: TextStyle(
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.dialogColorDark
                                    : AppConstants.backgroundColor),
                          ),
                        ),
                        content: Text(message),
                        actions: <Widget>[
                          TextButton(
                              child: Text(
                                btnLabel,
                                style: const TextStyle(
                                    color: AppConstants.primaryColor),
                              ),
                              onPressed: () => custom_url_launcher(
                                  widget.doc[Platform.isAndroid
                                      ? Dbkeys.newapplinkandroid
                                      : Platform.isIOS
                                          ? Dbkeys.newapplinkios
                                          : Dbkeys.newapplinkweb])),
                        ],
                      ));
                },
              );
            } else {
              final observer = ref.watch(observerProvider);

              observer.setObserver(
                getuserAppSettingsDoc: widget.doc,
                getisWebCompatible:
                    widget.doc.data()!.containsKey('is_web_compatible')
                        ? widget.doc.data()!['is_web_compatible']
                        : false,
                getandroidapplink: widget.doc[Dbkeys.newapplinkandroid],
                getiosapplink: widget.doc[Dbkeys.newapplinkios],
                getisadmobshow: widget.doc[Dbkeys.isadmobshow],
                getismediamessagingallowed:
                    widget.doc[Dbkeys.ismediamessageallowed],
                getistextmessagingallowed:
                    widget.doc[Dbkeys.istextmessageallowed],
                getiscallsallowed: widget.doc[Dbkeys.iscallsallowed],
                gettnc: widget.doc[Dbkeys.tnc],
                gettncType: widget.doc[Dbkeys.tncTYPE],
                getprivacypolicy: widget.doc[Dbkeys.privacypolicy],
                getprivacypolicyType: widget.doc[Dbkeys.privacypolicyTYPE],
                getis24hrsTimeformat: widget.doc[Dbkeys.is24hrsTimeformat],
                getmaxFileSizeAllowedInMB:
                    widget.doc[Dbkeys.maxFileSizeAllowedInMB],
                getisPercentProgressShowWhileUploading:
                    widget.doc[Dbkeys.isPercentProgressShowWhileUploading],
                getisCallFeatureTotallyHide:
                    widget.doc[Dbkeys.isCallFeatureTotallyHide],
                getgroupMemberslimit: widget.doc[Dbkeys.groupMemberslimit],
                getbroadcastMemberslimit:
                    widget.doc[Dbkeys.broadcastMemberslimit],
                getstatusDeleteAfterInHours:
                    widget.doc[Dbkeys.statusDeleteAfterInHours],
                getfeedbackEmail: widget.doc[Dbkeys.feedbackEmail],
                getisLogoutButtonShowInSettingsPage:
                    widget.doc[Dbkeys.isLogoutButtonShowInSettingsPage],
                getisAllowCreatingGroups:
                    widget.doc[Dbkeys.isAllowCreatingGroups],
                getisAllowCreatingBroadcasts:
                    widget.doc[Dbkeys.isAllowCreatingBroadcasts],
                getisAllowCreatingStatus:
                    widget.doc[Dbkeys.isAllowCreatingStatus],
                getmaxNoOfFilesInMultiSharing:
                    widget.doc[Dbkeys.maxNoOfFilesInMultiSharing],
                getmaxNoOfContactsSelectForForward:
                    widget.doc[Dbkeys.maxNoOfContactsSelectForForward],
                getappShareMessageStringAndroid:
                    widget.doc[Dbkeys.appShareMessageStringAndroid],
                getappShareMessageStringiOS:
                    widget.doc[Dbkeys.appShareMessageStringiOS],
                getisCustomAppShareLink:
                    widget.doc[Dbkeys.isCustomAppShareLink],
              );

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.prefs.getString(Dbkeys.phone))
                  .get()
                  .then((userDoc) async {
                if (deviceid != userDoc[Dbkeys.currentDeviceID] ||
                    !userDoc.data()!.containsKey(Dbkeys.currentDeviceID)) {
                  if (ConnectWithAdminApp == true) {
                    await unsubscribeToNotification(widget.currentUserNo);
                  }
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionusers)
                      .doc(widget.prefs.getString(Dbkeys.phone))
                      .set({
                    Dbkeys.currentDeviceID:
                        deviceid ?? widget.prefs.getString(Dbkeys.phone),
                  }, SetOptions(merge: true));
                  setState(() {
                    userFullname = userDoc[Dbkeys.nickname];
                    userPhotourl = userDoc[Dbkeys.photoUrl];
                    phoneNumberVariants = phoneNumberVariantsList(
                        countrycode: userDoc[Dbkeys.countryCode],
                        phonenumber: userDoc[Dbkeys.phoneRaw]);
                    isFetching = false;
                  });
                  getuid(context);
                  setIsActive();

                  incrementSessionCount(userDoc[Dbkeys.phone]);
                  // await logout(context);
                } else {
                  if (!userDoc.data()!.containsKey(Dbkeys.accountstatus)) {
                    await logout(context);
                  } else if (userDoc[Dbkeys.accountstatus] !=
                      Dbkeys.sTATUSallowed) {
                    if (userDoc[Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted) {
                      setState(() {
                        accountstatus = userDoc[Dbkeys.accountstatus];
                        accountactionmessage = userDoc[Dbkeys.actionmessage];
                      });
                    } else {
                      setState(() {
                        accountstatus = userDoc[Dbkeys.accountstatus];
                        accountactionmessage = userDoc[Dbkeys.actionmessage];
                      });
                    }
                  } else {
                    setState(() {
                      userFullname = userDoc[Dbkeys.nickname];
                      userPhotourl = userDoc[Dbkeys.photoUrl];
                      phoneNumberVariants = phoneNumberVariantsList(
                          countrycode: userDoc[Dbkeys.countryCode],
                          phonenumber: userDoc[Dbkeys.phoneRaw]);
                      isFetching = false;
                    });
                    getuid(context);
                    setIsActive();

                    incrementSessionCount(userDoc[Dbkeys.phone]);
                  }
                }
              });
            }
          }
        } else {
          if (widget.doc[Dbkeys.isappunderconstructionweb] == true) {
            await unsubscribeToNotification(widget.currentUserNo);
            maintainanceMessage = widget.doc[Dbkeys.maintainancemessage];
            setState(() {});
          } else {
            final PackageInfo info = await PackageInfo.fromPlatform();
            widget.prefs.setString('app_version', info.version);

            int currentAppVersionInPhone = int.tryParse(info.version
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    info.version
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            int currentNewAppVersionInServer = int.tryParse(widget
                        .doc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[0]
                        .toString()
                        .padLeft(3, '0') +
                    widget.doc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[1]
                        .toString()
                        .padLeft(3, '0') +
                    widget.doc[Dbkeys.latestappversionweb]
                        .trim()
                        .split(".")[2]
                        .toString()
                        .padLeft(3, '0')) ??
                0;
            if (currentAppVersionInPhone < currentNewAppVersionInServer) {
              showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  String title = LocaleKeys.updateAvailable.tr();
                  String message = LocaleKeys.updateavlmsg.tr();
                  String btnLabel = LocaleKeys.updatnow.tr();

                  return WillPopScope(
                      onWillPop: () async => false,
                      child: AlertDialog(
                        backgroundColor: Teme.isDarktheme(widget.prefs)
                            ? AppConstants.dialogColorDark
                            : AppConstants.backgroundColor,
                        title: Text(
                          title,
                          style: TextStyle(
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.dialogColorDark
                                    : AppConstants.backgroundColor),
                          ),
                        ),
                        content: Text(message),
                        actions: <Widget>[
                          TextButton(
                              child: Text(
                                btnLabel,
                                style: const TextStyle(
                                    color: AppConstants.primaryColor),
                              ),
                              onPressed: () => custom_url_launcher(
                                  widget.doc[Dbkeys.newapplinkweb])),
                        ],
                      ));
                },
              );
            } else {
              final observer = ref.watch(observerProvider);

              observer.setObserver(
                getuserAppSettingsDoc: widget.doc,
                getisWebCompatible:
                    widget.doc.data()!.containsKey('is_web_compatible')
                        ? widget.doc.data()!['is_web_compatible']
                        : false,
                getandroidapplink: widget.doc[Dbkeys.newapplinkandroid],
                getiosapplink: widget.doc[Dbkeys.newapplinkios],
                getisadmobshow: widget.doc[Dbkeys.isadmobshow],
                getismediamessagingallowed:
                    widget.doc[Dbkeys.ismediamessageallowed],
                getistextmessagingallowed:
                    widget.doc[Dbkeys.istextmessageallowed],
                getiscallsallowed: widget.doc[Dbkeys.iscallsallowed],
                gettnc: widget.doc[Dbkeys.tnc],
                gettncType: widget.doc[Dbkeys.tncTYPE],
                getprivacypolicy: widget.doc[Dbkeys.privacypolicy],
                getprivacypolicyType: widget.doc[Dbkeys.privacypolicyTYPE],
                getis24hrsTimeformat: widget.doc[Dbkeys.is24hrsTimeformat],
                getmaxFileSizeAllowedInMB:
                    widget.doc[Dbkeys.maxFileSizeAllowedInMB],
                getisPercentProgressShowWhileUploading:
                    widget.doc[Dbkeys.isPercentProgressShowWhileUploading],
                getisCallFeatureTotallyHide:
                    widget.doc[Dbkeys.isCallFeatureTotallyHide],
                getgroupMemberslimit: widget.doc[Dbkeys.groupMemberslimit],
                getbroadcastMemberslimit:
                    widget.doc[Dbkeys.broadcastMemberslimit],
                getstatusDeleteAfterInHours:
                    widget.doc[Dbkeys.statusDeleteAfterInHours],
                getfeedbackEmail: widget.doc[Dbkeys.feedbackEmail],
                getisLogoutButtonShowInSettingsPage:
                    widget.doc[Dbkeys.isLogoutButtonShowInSettingsPage],
                getisAllowCreatingGroups:
                    widget.doc[Dbkeys.isAllowCreatingGroups],
                getisAllowCreatingBroadcasts:
                    widget.doc[Dbkeys.isAllowCreatingBroadcasts],
                getisAllowCreatingStatus:
                    widget.doc[Dbkeys.isAllowCreatingStatus],
                getmaxNoOfFilesInMultiSharing:
                    widget.doc[Dbkeys.maxNoOfFilesInMultiSharing],
                getmaxNoOfContactsSelectForForward:
                    widget.doc[Dbkeys.maxNoOfContactsSelectForForward],
                getappShareMessageStringAndroid:
                    widget.doc[Dbkeys.appShareMessageStringAndroid],
                getappShareMessageStringiOS:
                    widget.doc[Dbkeys.appShareMessageStringiOS],
                getisCustomAppShareLink:
                    widget.doc[Dbkeys.isCustomAppShareLink],
              );

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.currentUserNo)
                  .get()
                  .then((userDoc) async {
                // if (deviceid != userDoc[Dbkeys.currentDeviceID] ||
                //     !userDoc.data()!.containsKey(Dbkeys.currentDeviceID)) {
                //   if (ConnectWithAdminApp == true) {
                //     await unsubscribeToNotification(widget.currentUserNo);
                //   }
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(widget.currentUserNo)
                    .set({
                  Dbkeys.currentDeviceID: deviceid ?? widget.currentUserNo,
                }, SetOptions(merge: true));
                setState(() {
                  phoneNumberVariants = phoneNumberVariantsList(
                      countrycode: currentUserProfile!.countryCode,
                      phonenumber: currentUserProfile!.phone_raw);
                });
                isFetching = false;
                getuid(context);
                setIsActive();

                incrementSessionCount(widget.currentUserNo);
                // getuid(context);
                // setIsActive();

                // incrementSessionCount(userDoc[Dbkeys.phone]);
                // await logout(context);
                // } else {
                // if (!userDoc.data()!.containsKey(Dbkeys.accountstatus)) {
                //   await logout(context);
                // } else if (userDoc[Dbkeys.accountstatus] !=
                //     Dbkeys.sTATUSallowed) {
                //   if (userDoc[Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted) {
                //     setState(() {
                //       accountstatus = userDoc[Dbkeys.accountstatus];
                //       accountactionmessage = userDoc[Dbkeys.actionmessage];
                //     });
                //   } else {
                //     setState(() {
                //       accountstatus = userDoc[Dbkeys.accountstatus];
                //       accountactionmessage = userDoc[Dbkeys.actionmessage];
                //     });
                //   }
                // } else {

                // }
              });
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) showERRORSheet(context, "", message: e.toString());
    }
  }

  final StreamController<String> _userQuery =
      StreamController<String>.broadcast();

  DateTime? currentBackPressTime = DateTime.now();
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      // Lamat.toast("Double tap to go back");

      return Future.value(false);
    } else {
      if (!isAuthenticating) setLastSeen();
      return Future.value(true);
    }
  }

  List<IconData> icons = [
    CupertinoIcons.person_3_fill,
    Icons.chat,
    Icons.phone
  ];

  List<String> items = [
    LocaleKeys.community.tr(),
    LocaleKeys.recents.tr(),
    LocaleKeys.calls.tr(),
  ];

  // String? currentUserNo;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final observer = ref.watch(observerProvider);
    // final availableContacts = ref.watch(smartContactProvider);
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    return isNotAllowEmulator == true
        ? errorScreen(LocaleKeys.emuNotAll.tr(), LocaleKeys.useRealDev.tr())
        : accountstatus != null
            ? errorScreen(accountstatus, accountactionmessage)
            : ConnectWithAdminApp == true && maintainanceMessage != null
                ? errorScreen('App Under maintainance', maintainanceMessage)
                : ConnectWithAdminApp == true && isFetching == true
                    ? Center(
                        child: NoItemFoundWidget(
                            text: LocaleKeys.noCardFound.tr()),
                      )
                    : PickupLayout(
                        prefs: widget.prefs,
                        scaffold: Lamat.getNTPWrappedWidget(
                          WillPopScope(
                              onWillPop: onWillPop,
                              child: Scaffold(
                                  backgroundColor:
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                  body: Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).padding.top +
                                                10,
                                      ),
                                      Container(
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        // height: 40,
                                        width: width,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppConstants
                                                  .defaultNumericValue,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Responsive.isMobile(context)
                                                    ? CustomPopupMenu(
                                                        menuBuilder:
                                                            () => ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants.defaultNumericValue /
                                                                              2),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                            color:
                                                                                AppConstants.backgroundColor),
                                                                    child:
                                                                        IntrinsicWidth(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.stretch,
                                                                        children: [
                                                                          MoreMenuTitle(
                                                                            icon:
                                                                                settingsIcon,
                                                                            title:
                                                                                LocaleKeys.settings.tr(),
                                                                            onTap:
                                                                                () async {
                                                                              _moreMenuController.hideMenu();
                                                                              Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                      builder: (context) => AccountSettingsLandingWidget(
                                                                                            currentUserNo: widget.currentUserNo,
                                                                                          )));
                                                                            },
                                                                          ),
                                                                          MoreMenuTitle(
                                                                            icon:
                                                                                bellIcon,
                                                                            title:
                                                                                LocaleKeys.notifications.tr(),
                                                                            onTap:
                                                                                () {
                                                                              _moreMenuController.hideMenu();
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(builder: (context) => const NotificationPage()),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                        pressType: PressType
                                                            .singleClick,
                                                        verticalMargin: 0,
                                                        controller:
                                                            _moreMenuController,
                                                        showArrow: true,
                                                        arrowColor: Colors
                                                            .white,
                                                        barrierColor:
                                                            AppConstants
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.1),
                                                        child: InkWell(
                                                          onTap: () {
                                                            _moreMenuController
                                                                .showMenu();
                                                          },
                                                          child: Icon(
                                                            CupertinoIcons
                                                                .ellipsis_circle,
                                                            color: Teme.isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                                ? AppConstants
                                                                    .backgroundColor
                                                                : AppConstants
                                                                    .backgroundColorDark,
                                                          ),
                                                        ))
                                                    : const SizedBox(),
                                                !kIsWeb
                                                    ? InkWell(
                                                        onTap: () {
                                                          showBottomSheet(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return SmartContactsPage(
                                                                    onTapCreateBroadcast:
                                                                        () {
                                                                      if (observer
                                                                              .isAllowCreatingBroadcasts ==
                                                                          false) {
                                                                        Lamat
                                                                            .showRationale(
                                                                          LocaleKeys
                                                                              .disabled
                                                                              .tr(),
                                                                        );
                                                                      } else {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => AddContactsToBroadcast(
                                                                                      currentUserNo: widget.currentUserNo,
                                                                                      model: _cachedModel,
                                                                                      biometricEnabled: false,
                                                                                      prefs: widget.prefs,
                                                                                      isAddingWhileCreatingBroadcast: true,
                                                                                    )));
                                                                      }
                                                                    },
                                                                    onTapCreateGroup:
                                                                        () {
                                                                      if (observer
                                                                              .isAllowCreatingGroups ==
                                                                          false) {
                                                                        Lamat
                                                                            .showRationale(
                                                                          LocaleKeys
                                                                              .disabled
                                                                              .tr(),
                                                                        );
                                                                      } else {
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => AddContactsToGroup(
                                                                                      currentUserNo: widget.currentUserNo,
                                                                                      model: _cachedModel,
                                                                                      biometricEnabled: false,
                                                                                      prefs: widget.prefs,
                                                                                      isAddingWhileCreatingGroup: true,
                                                                                    )));
                                                                      }
                                                                    },
                                                                    prefs: widget
                                                                        .prefs,
                                                                    biometricEnabled:
                                                                        biometricEnabled,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo,
                                                                    model:
                                                                        _cachedModel!);
                                                              });
                                                        },
                                                        child: Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                right: AppConstants
                                                                        .defaultNumericValue /
                                                                    2),
                                                            child: WebsafeSvg
                                                                .asset(
                                                              addIcon,
                                                              width: 30,
                                                              height: 30,
                                                              fit: BoxFit
                                                                  .contain,
                                                              colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                            )),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            )),
                                      ),
                                      const SizedBox(
                                        height:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      Container(
                                        height: 45,
                                        // width: width,
                                        decoration: BoxDecoration(
                                          // borderRadius: BorderRadius.circular(20),
                                          color: Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                        ),
                                        child: Center(
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: controller!.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (ctx, index) {
                                                  return Column(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedIndex =
                                                                index;
                                                          });
                                                          controller!.animateTo(
                                                            selectedIndex,
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                        child:
                                                            AnimatedContainer(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      300),
                                                          margin:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          width: 100,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: selectedIndex ==
                                                                    index
                                                                ? AppConstants
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        .1)
                                                                : Colors.black
                                                                    .withOpacity(
                                                                        .1),
                                                            borderRadius: selectedIndex ==
                                                                    index
                                                                ? BorderRadius
                                                                    .circular(
                                                                        12)
                                                                : BorderRadius.circular(
                                                                    AppConstants
                                                                            .defaultNumericValue /
                                                                        2),
                                                            border: selectedIndex ==
                                                                    index
                                                                ? Border.all(
                                                                    color: AppConstants
                                                                        .primaryColor,
                                                                    width: 1)
                                                                : null,
                                                          ),
                                                          child: Center(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                if (index == 0)
                                                                  Icon(
                                                                    icons[
                                                                        index],
                                                                    size: selectedIndex ==
                                                                            index
                                                                        ? 23
                                                                        : 20,
                                                                    color: selectedIndex ==
                                                                            index
                                                                        ? AppConstants
                                                                            .primaryColor
                                                                        : Colors
                                                                            .grey
                                                                            .shade400,
                                                                  ),
                                                                if (index != 0)
                                                                  Text(
                                                                    items[
                                                                        index],
                                                                    style: GoogleFonts
                                                                        .ubuntu(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: selectedIndex ==
                                                                              index
                                                                          ? Teme.isDarktheme(widget.prefs)
                                                                              ? Colors.white
                                                                              : AppConstants.primaryColor
                                                                          : Colors.grey.shade400,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            selectedIndex ==
                                                                index,
                                                        child: Container(
                                                          width: 5,
                                                          height: 5,
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Colors
                                                                      .deepPurpleAccent,
                                                                  shape: BoxShape
                                                                      .circle),
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                })),
                                      ),
                                      Expanded(
                                          // height: height,
                                          child: TabBarView(
                                              controller: controller,
                                              children: <Widget>[
                                            Updates(
                                                phoneNumberVariants:
                                                    phoneNumberVariants,
                                                model: _cachedModel,
                                                biometricEnabled:
                                                    biometricEnabled,
                                                prefs: widget.prefs,
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                isSecuritySetupDone: false),
                                            RecentChats(
                                                currentUserFullname:
                                                    currentUserProfile!
                                                        .countryCode,
                                                currentUserPhotourl:
                                                    currentUserProfile!
                                                        .profilePicture,
                                                phoneNumberVariants:
                                                    phoneNumberVariants,
                                                model: _cachedModel,
                                                biometricEnabled:
                                                    biometricEnabled,
                                                prefs: widget.prefs,
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                isSecuritySetupDone: false),
                                            CallHistory(
                                              model: _cachedModel,
                                              userphone: widget.currentUserNo,
                                              prefs: widget.prefs,
                                            ),
                                          ]))
                                    ],
                                  ))),
                        ));
  }
}

// Future<dynamic> myBackgroundMessageHandlerIos(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.data['title'] == 'Call Ended') {
//     final data = message.data;

//     final titleMultilang = data['titleMultilang'];
//     final bodyMultilang = data['bodyMultilang'];
//     flutterLocalNotificationsPlugin..cancelAll();
//     await showNotificationWithDefaultSound(
//         'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
//   } else {
//     if (message.data['title'] == 'You have message(s)') {
//     } else if (message.data['title'] == 'Incoming Audio Call...' ||
//         message.data['title'] == 'Incoming Video Call...') {
//       final data = message.data;
//       final title = data['title'];
//       final body = data['body'];
//       final titleMultilang = data['titleMultilang'];
//       final bodyMultilang = data['bodyMultilang'];
//       await showNotificationWithDefaultSound(
//           title, body, titleMultilang, bodyMultilang);
//     }
//   }

//   return Future<void>.value();
// }

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future showNotificationWithDefaultSound(String? title, String? message,
    String? titleMultilang, String? bodyMultilang) async {
  if (kIsWeb == false) {
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.cancelAll();
    }
  }

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  var androidPlatformChannelSpecifics =
      title == 'Missed Call' || title == 'Call Ended'
          ? const local.AndroidNotificationDetails('channel_id', 'channel_name',
              importance: local.Importance.max,
              priority: local.Priority.high,
              sound: RawResourceAndroidNotificationSound('whistle2'),
              playSound: true,
              ongoing: true,
              visibility: NotificationVisibility.public,
              timeoutAfter: 28000)
          : const local.AndroidNotificationDetails('channel_id', 'channel_name',
              sound: RawResourceAndroidNotificationSound('ringtone'),
              playSound: true,
              ongoing: true,
              importance: local.Importance.max,
              priority: local.Priority.high,
              visibility: NotificationVisibility.public,
              timeoutAfter: 28000);
  var iOSPlatformChannelSpecifics = local.DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    sound:
        title == 'Missed Call' || title == 'Call Ended' ? '' : 'ringtone.mp3',
    presentSound: true,
  );
  var platformChannelSpecifics = local.NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(
    0,
    '$titleMultilang',
    '$bodyMultilang',
    platformChannelSpecifics,
    payload: 'payload',
  )
      .catchError((err) {
    debugPrint('ERROR DISPLAYING NOTIFICATION: $err');
  });
}

Widget errorScreen(String? title, String? subtitle) {
  return Scaffold(
    backgroundColor: AppConstants.primaryColor,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_outlined,
              size: 60,
              color: Colors.yellowAccent,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              '$title',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  color: AppConstants.lamatWhite,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '$subtitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: AppConstants.lamatWhite.withOpacity(0.7),
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    ),
  );
}
