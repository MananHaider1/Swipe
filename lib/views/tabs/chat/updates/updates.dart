// ignore_for_file: no_logic_in_create_state, avoid_function_literals_in_foreach_calls, prefer_interpolation_to_compose_strings, void_checks

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/chat/updates/explore_channels.dart';
import 'package:lamatdating/views/tabs/chat/updates/widgets/channel_msg_tile.dart';
import 'package:path/path.dart' as path;
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/late_load.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/status/status_view.dart';
import 'package:lamatdating/views/status/components/TextStatus/text_status.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/bm_tile.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/pm_tile.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';

Color darkGrey = Colors.blueGrey[700]!;
Color lightGrey = Colors.blueGrey[400]!;

class Updates extends ConsumerStatefulWidget {
  const Updates(
      {required this.currentUserNo,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.model,
      required this.biometricEnabled,
      this.isShowAddStatusOnFirst = false,
      required this.phoneNumberVariants,
      super.key})
     ;
  final String currentUserNo;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  final DataModel? model;

  final bool biometricEnabled;
  final List phoneNumberVariants;
  final bool? isShowAddStatusOnFirst;
  @override
  ConsumerState createState() => UpdatesState(key: key);
}

class UpdatesState extends ConsumerState<Updates> {
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdesc = TextEditingController();

  List<String> targetUserNotificationTokens = [];

  bool iscreatinggroup = false;

  UpdatesState({Key? key}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  final TextEditingController _filter = TextEditingController();
  bool isAuthenticating = false;

  // List<StreamSubscription> unreadSubscriptions = [];

  List<StreamController> controllers = [];
  BannerAd? myBanner;
  AdWidget? adWidget;
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();
  final CustomPopupMenuController _moreMenuController2 =
      CustomPopupMenuController();

  FlutterSecureStorage storage = const FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);
  String? privateKey, sharedSecret;

  late Stream myStatusUpdates;
  late Stream otherStatusUpdates;

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
    setStatusBarColor(widget.prefs);
    super.initState();
    _moreMenuController.hideMenu();
    _moreMenuController2.hideMenu();
    myStatusUpdates = FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .doc(widget.currentUserNo)
        .snapshots();
    otherStatusUpdates = FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .snapshots();
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

  Future<String?> readPersonalMessage(
      peer, String inputMssg, bool isAESencryption) async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await const e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peer![Dbkeys.publicKey], true)))
          .toBase64();
      final key = encrypt.Key.fromBase64(sharedSecret!);
      cryptor = encrypt.Encrypter(encrypt.Salsa20(key));
      return inputMssg;
      // isAESencryption == true
      //     ? AESEncryptData.decryptAES(inputMssg, sharedSecret)
      //     :
      // decryptWithCRC(inputMssg);
    } catch (e) {
      sharedSecret = null;
      return "";
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Lamat.toast(
        LocaleKeys.waitingpeer.tr(),
      );
      return false;
    }
  }

  int _numInterstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId()!,
        request: const AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('$ad loaded');
            }
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('InterstitialAd failed to load: $error.');
            }
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxAdFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('Warning: attempt to show interstitial before loaded.');
      }
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('ad onAdShowedFullScreenContent.');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('$ad onAdDismissedFullScreenContent.');
        }
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        if (kDebugMode) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
        }
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  showMediaOptions(
      {required BuildContext context,
      required WidgetRef ref,
      required Function pickImageCallback,
      required Function pickVideoCallback,
      required List<dynamic> phoneVariants,
      required bool ishideTextStatusbutton}) {
    showModalBottomSheet(
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.dialogColorDark
            : AppConstants.backgroundColor,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer(
              builder: (context, ref, child) => Container(
                  padding: const EdgeInsets.all(12),
                  height: 100,
                  child: ishideTextStatusbutton == true
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  pickImageCallback();
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        size: 39,
                                        color: AppConstants.secondaryColor,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        LocaleKeys.image.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color:
                                                pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .dialogColorDark
                                                        : AppConstants
                                                            .backgroundColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    pickVideoCallback();
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.video_camera_back,
                                          size: 39,
                                          color: AppConstants.secondaryColor,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          LocaleKeys.video.tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15,
                                              color:
                                                  pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .dialogColorDark
                                                          : AppConstants
                                                              .backgroundColor)),
                                        ),
                                      ],
                                    ),
                                  ))
                            ])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  // createTextCallback();
                                  (!Responsive.isDesktop(context))
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => TextStatus(
                                                  currentuserNo:
                                                      widget.currentUserNo,
                                                  phoneNumberVariants: widget
                                                      .phoneNumberVariants)))
                                      : ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(TextStatus(
                                              currentuserNo:
                                                  widget.currentUserNo,
                                              phoneNumberVariants:
                                                  widget.phoneNumberVariants));
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.text_fields,
                                        size: 39,
                                        color: AppConstants.secondaryColor,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        LocaleKeys.text.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color:
                                                pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .dialogColorDark
                                                        : AppConstants
                                                            .backgroundColor)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  pickImageCallback();
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        size: 39,
                                        color: AppConstants.secondaryColor,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        LocaleKeys.image.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 15,
                                          color:
                                              pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .dialogColorDark
                                                      : AppConstants
                                                          .backgroundColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    pickVideoCallback();
                                  },
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.video_camera_back,
                                          size: 39,
                                          color: AppConstants.secondaryColor,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          LocaleKeys.video.tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            color:
                                                pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .dialogColorDark
                                                        : AppConstants
                                                            .backgroundColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                            ])));
        });
  }

  String decryptWithCRC(String input) {
    try {
      if (input.contains(Dbkeys.crcSeperator)) {
        int idx = input.lastIndexOf(Dbkeys.crcSeperator);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int? crc = int.tryParse(crcPart);
        if (crc != null) {
          msgPart =
              cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          if (CRC32.compute(msgPart) == crc) return msgPart;
        }
      }
    } on FormatException {
      return '';
    }

    return '';
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = ref.watch(userProviderProvider);
    userProvider.getUserDetails(widget.currentUserNo);
  }

  uploadFile(
      {required File file,
      required WidgetRef ref,
      String? caption,
      double? duration,
      required String type,
      required String filename}) async {
    final observer = ref.watch(observerProvider);
    final StatusProvider statusProvider = ref.watch(statusProviderProvider);
    statusProvider.setIsLoading(true);
    int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child('+00_STATUS_MEDIA/${widget.currentUserNo}/$filename');
    File? compressedImage;
    File? compressedVideo;
    File? fileToCompress;
    if (type == Dbkeys.statustypeIMAGE) {
      final targetPath =
          "${file.absolute.path.replaceAll(path.basename(file.absolute.path), "")}temp.jpg";

      File originalImageFile = File(file.path); // Convert XFile to File

      XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalImageFile.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );

      if (compressedXFile != null) {
        compressedImage = File(compressedXFile.path); // Convert XFile to File
      }
    } else if (type == Dbkeys.statustypeVIDEO) {
      fileToCompress = File(file.path);
      await compress.VideoCompress.setLogLevel(0);

      final compress.MediaInfo? info =
          await compress.VideoCompress.compressVideo(
        fileToCompress.path,
        quality: IsVideoQualityCompress == true
            ? compress.VideoQuality.MediumQuality
            : compress.VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      compressedVideo = File(info!.path!);
    }
    await reference
        .putFile(type == Dbkeys.statustypeIMAGE
            ? compressedImage!
            : type == Dbkeys.statustypeVIDEO
                ? compressedVideo!
                : file)
        .then((uploadTask) async {
      String url = await uploadTask.ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnstatus)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
          type == Dbkeys.statustypeVIDEO
              ? {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                  Dbkeys.statusItemDURATION: duration,
                }
              : {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                }
        ]),
        Dbkeys.statusPUBLISHERPHONE: widget.currentUserNo,
        Dbkeys.statusPUBLISHERPHONEVARIANTS: widget.phoneNumberVariants,
        Dbkeys.statusVIEWERLIST: [],
        Dbkeys.statusVIEWERLISTWITHTIME: [],
        Dbkeys.statusPUBLISHEDON: DateTime.now(),
        // uploadTimestamp,
        Dbkeys.statusEXPIRININGON: DateTime.now()
            .add(Duration(hours: observer.statusDeleteAfterInHours)),
        // .millisecondsSinceEpoch,
      }, SetOptions(merge: true)).then((value) {
        statusProvider.setIsLoading(false);
      });
    }).onError((error, stackTrace) {
      statusProvider.setIsLoading(false);
    });
  }

  // void cancelUnreadSubscriptions() {
  //   unreadSubscriptions.forEach((subscription) {
  //     subscription.cancel();
  //   });
  // }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  // String? currentUserNo;

  bool isLoading = false;

  _isHidden(phoneNo) {
    Map<String, dynamic> currentUser = _cachedModel!.currentUser!;
    return currentUser[Dbkeys.hidden] != null &&
        currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  final StreamController<String> _userQuery =
      StreamController<String>.broadcast();

  List<Map<String, dynamic>> _streamDocSnap = [];

  buildPersonalMessage(
    Map<String, dynamic> realTimePeerData,
  ) {
    String chatId =
        Lamat.getChatId(widget.currentUserNo, realTimePeerData[Dbkeys.phone]);
    return streamLoad(
        stream: FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .snapshots(),
        placeholder: 1 == 2
            ? const SizedBox()
            : getPersonalMessageTile(
                peerSeenStatus: false,
                unRead: 0,
                peer: realTimePeerData,
                context: context,
                cachedModel: _cachedModel!,
                currentUserNo: widget.currentUserNo,
                lastMessage: null,
                prefs: widget.prefs,
                readFunction: null,
                isPeerChatMuted: false,
                ref: ref),
        onfetchdone: (chatDoc) {
          return streamLoadCollections(
              stream: FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .collection(chatId)
                  .where(Dbkeys.timestamp,
                      isGreaterThan: chatDoc[widget.currentUserNo])
                  .snapshots(),
              placeholder: getPersonalMessageTile(
                  peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.phone]],
                  unRead: 0,
                  peer: realTimePeerData,
                  context: context,
                  cachedModel: _cachedModel!,
                  currentUserNo: widget.currentUserNo,
                  lastMessage: null,
                  prefs: widget.prefs,
                  readFunction: null,
                  ref: ref,
                  isPeerChatMuted:
                      chatDoc.containsKey("${widget.currentUserNo}-muted")
                          ? chatDoc["${widget.currentUserNo}-muted"]
                          : false),
              noDataWidget: streamLoadCollections(
                  stream: FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId)
                      .orderBy(Dbkeys.timestamp, descending: true)
                      .limit(1)
                      .snapshots(),
                  placeholder: getPersonalMessageTile(
                      peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.phone]],
                      unRead: 0,
                      peer: realTimePeerData,
                      context: context,
                      cachedModel: _cachedModel!,
                      currentUserNo: widget.currentUserNo,
                      lastMessage: null,
                      prefs: widget.prefs,
                      readFunction: null,
                      ref: ref,
                      isPeerChatMuted:
                          chatDoc.containsKey("${widget.currentUserNo}-muted")
                              ? chatDoc["${widget.currentUserNo}-muted"]
                              : false),
                  noDataWidget: getPersonalMessageTile(
                      peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.phone]],
                      unRead: 0,
                      peer: realTimePeerData,
                      context: context,
                      cachedModel: _cachedModel!,
                      currentUserNo: widget.currentUserNo,
                      lastMessage: null,
                      prefs: widget.prefs,
                      readFunction: null,
                      ref: ref,
                      isPeerChatMuted:
                          chatDoc.containsKey("${widget.currentUserNo}-muted")
                              ? chatDoc["${widget.currentUserNo}-muted"]
                              : false),
                  onfetchdone: (messages) {
                    return getPersonalMessageTile(
                        peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.phone]],
                        unRead: 0,
                        peer: realTimePeerData,
                        context: context,
                        cachedModel: _cachedModel!,
                        currentUserNo: widget.currentUserNo,
                        lastMessage: messages.last,
                        prefs: widget.prefs,
                        ref: ref,
                        readFunction: readPersonalMessage(
                            realTimePeerData,
                            messages.last[Dbkeys.content],
                            // messages.last
                            //     .data()
                            //     .containsKey(Dbkeys.latestEncrypted
                            //     )
                            false),
                        isPeerChatMuted:
                            chatDoc.containsKey("${widget.currentUserNo}-muted")
                                ? chatDoc["${widget.currentUserNo}-muted"]
                                : false);
                  }),
              onfetchdone: (messages) {
                return getPersonalMessageTile(
                    peerSeenStatus: chatDoc[realTimePeerData[Dbkeys.phone]],
                    unRead: messages.length,
                    peer: realTimePeerData,
                    context: context,
                    ref: ref,
                    cachedModel: _cachedModel!,
                    currentUserNo: widget.currentUserNo,
                    lastMessage: messages.last,
                    prefs: widget.prefs,
                    readFunction: readPersonalMessage(
                        realTimePeerData, messages.last[Dbkeys.content], false
                        // messages.last
                        //     .data()
                        //     .containsKey(Dbkeys.latestEncrypted)
                        ),
                    isPeerChatMuted:
                        chatDoc.containsKey("${widget.currentUserNo}-muted")
                            ? chatDoc["${widget.currentUserNo}-muted"]
                            : false);
              });
        });
  }

  _chats(Map<String?, Map<String, dynamic>?> userData,
      Map<String, dynamic>? currentUser) {
    final channelList = ref.watch(channelsListProvider);

    return Consumer(
        builder: (context, ref, child) =>
            Consumer(builder: (context, ref, child) {
              Map<String?, int?> lastSpokenAt = _cachedModel!.lastSpokenAt;
              // List<Map<String, dynamic>> filtered =
              //     List.from(<Map<String, dynamic>>[]);

              channelList.when(
                data: (groupLists) {
                  _streamDocSnap =
                      groupLists.map((element) => element.docmap).toList();
                  return _streamDocSnap;
                },
                loading: () => _streamDocSnap,
                error: (_, __) => {},
              );

              _streamDocSnap.sort((a, b) {
                int aTimestamp = a.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? a[Dbkeys.groupLATESTMESSAGETIME]
                    : a.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? a[Dbkeys.broadcastLATESTMESSAGETIME]
                        : lastSpokenAt[a[Dbkeys.phone]] ?? 0;
                int bTimestamp = b.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? b[Dbkeys.groupLATESTMESSAGETIME]
                    : b.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? b[Dbkeys.broadcastLATESTMESSAGETIME]
                        : lastSpokenAt[b[Dbkeys.phone]] ?? 0;
                return bTimestamp - aTimestamp;
              });

              if (!showHidden) {
                _streamDocSnap.removeWhere((user) =>
                    !user.containsKey(Dbkeys.groupISTYPINGUSERID) &&
                    !user.containsKey(Dbkeys.broadcastBLACKLISTED) &&
                    _isHidden(user[Dbkeys.phone]));
              }

              return ListView(shrinkWrap: true, children: [
                _streamDocSnap.isNotEmpty
                    ? StreamBuilder(
                        stream: _userQuery.stream.asBroadcastStream(),
                        builder: (context, snapshot) {
                          // if (_filter.text.isNotEmpty || snapshot.hasData) {
                          //   filtered = _streamDocSnap.where((user) {
                          //     return user[Dbkeys.nickname]
                          //         .toLowerCase()
                          //         .trim()
                          //         .contains(RegExp(r'' +
                          //             _filter.text.toLowerCase().trim() +
                          //             ''));
                          //   }).toList();
                          //   if (filtered.isNotEmpty) {
                          //     return const Text('');
                          //   } else {
                          //     return ListView(
                          //         physics: const BouncingScrollPhysics(),
                          //         shrinkWrap: true,
                          //         children: [
                          //           Padding(
                          //               padding: EdgeInsets.only(
                          //                   top: MediaQuery.of(context)
                          //                           .size
                          //                           .height /
                          //                       3.5),
                          //               child: Center(
                          //                 child: Text(
                          //                     LocaleKeys.nosearchresult.tr(),
                          //                     textAlign: TextAlign.center,
                          //                     style: const TextStyle(
                          //                       fontSize: 18,
                          //                       color: AppConstants.lamatGrey,
                          //                     )),
                          //               ))
                          //         ]);
                          //   }
                          // }
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            itemBuilder: (context, index) {
                              if (_streamDocSnap[index]
                                  .containsKey(Dbkeys.groupISTYPINGUSERID)) {
                                ///----- Build Group Chat Tile ----
                                return streamLoadCollections(
                                  stream: FirebaseFirestore.instance
                                      .collection(DbPaths.collectionchannels)
                                      .doc(
                                          _streamDocSnap[index][Dbkeys.groupID])
                                      .collection(DbPaths.collectiongroupChats)
                                      .where(Dbkeys.groupmsgTIME,
                                          isGreaterThan: _streamDocSnap[index]
                                              [widget.currentUserNo])
                                      .snapshots(),
                                  placeholder: 1 == 2
                                      ? const SizedBox()
                                      : channelMessageTile(
                                          context: context,
                                          streamDocSnap: _streamDocSnap,
                                          index: index,
                                          currentUserNo: widget.currentUserNo,
                                          prefs: widget.prefs,
                                          ref: ref,
                                          cachedModel: _cachedModel!,
                                          unRead: 0,
                                          isGroupChatMuted: _streamDocSnap[
                                                      index]
                                                  .containsKey(
                                                      Dbkeys.groupMUTEDMEMBERS)
                                              ? _streamDocSnap[index]
                                                      [Dbkeys.groupMUTEDMEMBERS]
                                                  .contains(
                                                      widget.currentUserNo)
                                              : false),
                                  noDataWidget: channelMessageTile(
                                      context: context,
                                      ref: ref,
                                      streamDocSnap: _streamDocSnap,
                                      index: index,
                                      currentUserNo: widget.currentUserNo,
                                      prefs: widget.prefs,
                                      cachedModel: _cachedModel!,
                                      unRead: 0,
                                      isGroupChatMuted: _streamDocSnap[index]
                                              .containsKey(
                                                  Dbkeys.groupMUTEDMEMBERS)
                                          ? _streamDocSnap[index]
                                                  [Dbkeys.groupMUTEDMEMBERS]
                                              .contains(widget.currentUserNo)
                                          : false),
                                  onfetchdone: (docs) {
                                    return channelMessageTile(
                                        context: context,
                                        ref: ref,
                                        streamDocSnap: _streamDocSnap,
                                        index: index,
                                        currentUserNo: widget.currentUserNo,
                                        prefs: widget.prefs,
                                        cachedModel: _cachedModel!,
                                        unRead: docs
                                            .where((mssg) =>
                                                mssg[Dbkeys.groupmsgSENDBY] !=
                                                widget.currentUserNo)
                                            .toList()
                                            .length,
                                        isGroupChatMuted: _streamDocSnap[index]
                                                .containsKey(
                                                    Dbkeys.groupMUTEDMEMBERS)
                                            ? _streamDocSnap[index]
                                                    [Dbkeys.groupMUTEDMEMBERS]
                                                .contains(widget.currentUserNo)
                                            : false);
                                  },
                                );
                              } else if (_streamDocSnap[index]
                                  .containsKey(Dbkeys.broadcastBLACKLISTED)) {
                                ///----- Build Broadcast Chat Tile ----
                                return broadcastMessageTile(
                                  context: context,
                                  ref: ref,
                                  streamDocSnap: _streamDocSnap,
                                  index: index,
                                  currentUserNo: widget.currentUserNo,
                                  prefs: widget.prefs,
                                  cachedModel: _cachedModel!,
                                );
                              } else {
                                return buildPersonalMessage(
                                    _streamDocSnap.elementAt(index));
                              }
                            },
                            itemCount: _streamDocSnap.length,
                          );
                        })
                    : const SizedBox()
              ]);
            }));
  }

  Widget buildGroupitem() {
    return const Text(
      Dbkeys.groupNAME,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.currentUserNo);
    return _cachedModel;
  }

  bool? searchingcontactsstatus;

  List<QueryDocumentSnapshot<dynamic>>? contactsStatus;
  List<bool> isFollowing = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final statusProvider = ref.watch(statusProviderProvider);
    bool searchingcontactsstatuscheck = statusProvider.searchingcontactsstatus;
    var contactsStatuscheck = statusProvider.contactsStatus;
    setState(() {
      contactsStatus = contactsStatuscheck;
      searchingcontactsstatus = searchingcontactsstatuscheck;
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
    final contactsProvider = ref.watch(smartContactProvider);
    final statusProvider = ref.watch(statusProviderProvider);
    final currentUserProfile = ref.watch(userProfileFutureProvider).value;
    final allChannels = ref.watch(allChannelsListProvider);
    final List<Widget> usersToFollow = allChannels.when(
      data: (data) {
        if (data.isNotEmpty) {
          for (var i = 0; i < data.length; i++) {
            isFollowing.add(false);
          }
          return data
              .where((group) => !group.docmap[Dbkeys.groupMEMBERSLIST]
                  .contains(widget.currentUserNo))
              .toList()
              .map((group) {
            return Container(
              height: 300,
              width: 150,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
                border: Border.all(color: AppConstants.hintColor, width: 1),
              ),
              // Add your container widget properties here
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(group.docmap[Dbkeys.groupPHOTOURL]),
                      ),
                      // Verified Badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.greenAccent,
                            size: 20,
                          ),
                        ),
                      ),
                      // Follow Button
                    ],
                  ),
                  const Spacer(),
                  Text(group.docmap[Dbkeys.groupNAME],
                      maxLines: 1, // Set the maximum number of lines
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  // Container(
                  //   padding: const EdgeInsets.all(8.0),
                  //   decoration: BoxDecoration(
                  //     color: AppConstants.primaryColor.withOpacity(0.5),
                  //     borderRadius: BorderRadius.circular(
                  //         AppConstants.defaultNumericValue * 2),
                  //   ),
                  //   child: Text(
                  //       "${group.docmap[Dbkeys.groupMEMBERSLIST]!.length.toString()} ${LocaleKeys.subscribers.tr()}",
                  //       style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 15)),
                  // ),
                  // const Spacer(),
                  CustomButton(
                    text: isFollowing[data.indexOf(group)]
                        ? LocaleKeys.following.tr()
                        : LocaleKeys.follow.tr(),
                    onPressed: () async {
                      isFollowing[data.indexOf(group)] =
                          !isFollowing[data.indexOf(group)];
                      await FirebaseGroupServices().addUserToGroup(
                          group.docmap[Dbkeys.groupID], widget.currentUserNo);
                      setState(() {});
                    },
                  ),
                  const Spacer(),
                ],
              ),
            );
          }).toList();
        } else {
          return [];
        }
      },
      error: (Object error, StackTrace stackTrace) {
        // Handle error case
        return [];
      },
      loading: () {
        // Handle loading case
        return [];
      },
    );

    return Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child: ScopedModelDescendant<DataModel>(builder: (context, child, model) {
        _cachedModel = model;
        return Scaffold(
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
          backgroundColor: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          body: RefreshIndicator(
              onRefresh: () {
                isAuthenticating = !isAuthenticating;
                setState(() {
                  showHidden = !showHidden;
                });
                return Future.value(true);
              },
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        // width: MediaQuery.of(context).size.width,
                        child: Row(
                      children: [
                        StreamBuilder(
                            stream: myStatusUpdates,
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Card(
                                    color: Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                    elevation: 0.0,
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                AppConstants
                                                    .defaultNumericValue,
                                                8,
                                                8,
                                                8),
                                            child: InkWell(
                                              onTap: () {},
                                              child: SizedBox(
                                                width: 90,
                                                height: 140,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    customCircleAvatarStatus(
                                                        profilePic:
                                                            currentUserProfile!
                                                                .profilePicture),
                                                    Positioned(
                                                        bottom: 0,
                                                        child: Container(
                                                          height: 70,
                                                          width: 90,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Teme.isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                                ? AppConstants
                                                                    .backgroundColorDark
                                                                : AppConstants
                                                                    .backgroundColor,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      AppConstants
                                                                              .defaultNumericValue *
                                                                          .9),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      AppConstants
                                                                              .defaultNumericValue *
                                                                          .9),
                                                            ),
                                                          ),
                                                        )),
                                                    CircleAvatar(
                                                      backgroundColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                      child: const Icon(
                                                        Icons
                                                            .add_circle_rounded,
                                                        color: AppConstants
                                                            .primaryColor,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: 15,
                                                        child: Center(
                                                            child: Text(
                                                          LocaleKeys.createStory
                                                              .tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )))
                                                  ],
                                                ),
                                              ),
                                            )),

                                        // Container(
                                        //     width: 90,
                                        //     height: 140,
                                        //     decoration: BoxDecoration(
                                        //         color: AppConstants.primaryColor
                                        //             .withOpacity(.1),
                                        //         borderRadius: const BorderRadius.all(
                                        //             Radius.circular(AppConstants
                                        //                 .defaultNumericValue))),
                                        //     child: const Center(
                                        //       child: CircularProgressIndicator(
                                        //           strokeWidth: 2,
                                        //           value: 0.5,
                                        //           color: AppConstants.primaryColor),
                                        //     )),
                                        // const SizedBox(
                                        //   width: 10,
                                        // ),
                                      ],
                                    ));
                              } else if (snapshot.hasData &&
                                  snapshot.data.exists) {
                                int seen = !snapshot.data
                                        .data()
                                        .containsKey(widget.currentUserNo)
                                    ? 0
                                    : 0;
                                if (snapshot.data
                                    .data()
                                    .containsKey(widget.currentUserNo)) {
                                  snapshot.data[Dbkeys.statusITEMSLIST]
                                      .forEach((status) {
                                    if (snapshot.data[widget.currentUserNo]
                                        .contains(
                                            status[Dbkeys.statusItemID])) {
                                      seen = seen + 1;
                                    }
                                  });
                                }

                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      AppConstants.defaultNumericValue,
                                      8,
                                      8,
                                      8),
                                  child: Container(
                                    width: 90,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.defaultNumericValue),
                                    ),
                                    child: Stack(
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StatusView(
                                                          model: widget.model!,
                                                          prefs: widget.prefs,
                                                          currentUserNo: widget
                                                              .currentUserNo,
                                                          statusDoc:
                                                              snapshot.data,
                                                          postedbyFullname:
                                                              currentUserProfile!
                                                                  .nickname,
                                                          postedbyPhotourl:
                                                              currentUserProfile
                                                                  .profilePicture,
                                                        )));
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10, bottom: 10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue *
                                                          1.2),
                                                  border: Border.all(
                                                    width: 3,
                                                    color: snapshot.data
                                                                .data()
                                                                .containsKey(widget
                                                                    .currentUserNo) ==
                                                            true
                                                        ? snapshot
                                                                    .data[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length >
                                                                0
                                                            ? Colors.grey
                                                                .withOpacity(
                                                                    0.8)
                                                            : AppConstants
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.8)
                                                        : AppConstants
                                                            .primaryColor
                                                            .withOpacity(0.8),
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: snapshot.data[Dbkeys.statusITEMSLIST]
                                                                [snapshot.data[Dbkeys.statusITEMSLIST].length - 1]
                                                            [Dbkeys
                                                                .statusItemTYPE] ==
                                                        Dbkeys.statustypeTEXT
                                                    ? Container(
                                                        width: 90.0,
                                                        height: 140.0,
                                                        decoration: BoxDecoration(
                                                            color: Color(int.parse(
                                                                snapshot.data[Dbkeys.statusITEMSLIST]
                                                                    [
                                                                    snapshot.data[Dbkeys.statusITEMSLIST].length -
                                                                        1][Dbkeys
                                                                    .statusItemBGCOLOR],
                                                                radix: 16)),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    AppConstants.defaultNumericValue)),
                                                        child: const Icon(
                                                            Icons.text_fields,
                                                            color:
                                                                Colors.white54),
                                                      )
                                                    : snapshot.data[Dbkeys.statusITEMSLIST]
                                                                    [snapshot.data[Dbkeys.statusITEMSLIST].length - 1]
                                                                [Dbkeys.statusItemTYPE] ==
                                                            Dbkeys.statustypeVIDEO
                                                        ? Container(
                                                            width: 90.0,
                                                            height: 140.0,
                                                            decoration:
                                                                BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        snapshot
                                                                            .data[Dbkeys.statusITEMSLIST][snapshot
                                                                                .data[Dbkeys.statusITEMSLIST].length -
                                                                            1]['thumbNail'],
                                                                      ),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    color: AppConstants
                                                                        .primaryColor
                                                                        .withOpacity(
                                                                            .2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue)),
                                                            child: Icon(
                                                                Icons
                                                                    .play_circle_fill_rounded,
                                                                color: AppConstants
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        .5)),
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: snapshot
                                                                        .data[
                                                                    Dbkeys
                                                                        .statusITEMSLIST]
                                                                [snapshot
                                                                        .data[Dbkeys
                                                                            .statusITEMSLIST]
                                                                        .length -
                                                                    1][Dbkeys
                                                                .statusItemURL],
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 90.0,
                                                              height: 140.0,
                                                              decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue)),
                                                            ),
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    Container(
                                                              width: 90.0,
                                                              height: 140.0,
                                                              decoration: BoxDecoration(
                                                                  color: AppConstants
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue)),
                                                            ),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Container(
                                                              width: 90.0,
                                                              height: 140.0,
                                                              decoration: BoxDecoration(
                                                                  color: AppConstants
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue)),
                                                            ),
                                                          ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0.0,
                                          right: 0.0,
                                          child:
                                              observer.isAllowCreatingStatus ==
                                                      false
                                                  ? const SizedBox()
                                                  : CustomPopupMenu(
                                                      menuBuilder: () =>
                                                          ClipRRect(
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                                  color: Colors
                                                                      .white),
                                                          child: IntrinsicWidth(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: [
                                                                MoreMenuTitle(
                                                                  title:
                                                                      LocaleKeys
                                                                          .camera
                                                                          .tr(),
                                                                  icon:
                                                                      cameraIcon,
                                                                  onTap:
                                                                      () async {
                                                                    _moreMenuController
                                                                        .hideMenu();
                                                                    !Responsive.isDesktop(
                                                                            context)
                                                                        ? Navigator
                                                                            .push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => CameraScreenStory(
                                                                                      prefs: widget.prefs,
                                                                                    )),
                                                                          )
                                                                        : ref
                                                                            .read(arrangementProvider.notifier)
                                                                            .setArrangement(CameraScreenStory(
                                                                              prefs: widget.prefs,
                                                                            ));
                                                                  },
                                                                ),
                                                                MoreMenuTitle(
                                                                  title:
                                                                      LocaleKeys
                                                                          .text
                                                                          .tr(),
                                                                  icon:
                                                                      textIcon,
                                                                  onTap: () {
                                                                    _moreMenuController
                                                                        .hideMenu();

                                                                    (!Responsive.isDesktop(
                                                                            context))
                                                                        ? Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => TextStatus(currentuserNo: widget.currentUserNo, phoneNumberVariants: widget.phoneNumberVariants)))
                                                                        : ref.read(arrangementProvider.notifier).setArrangement(TextStatus(currentuserNo: widget.currentUserNo, phoneNumberVariants: widget.phoneNumberVariants));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      pressType:
                                                          PressType.singleClick,
                                                      verticalMargin: 0,
                                                      controller:
                                                          _moreMenuController,
                                                      showArrow: true,
                                                      arrowColor: Colors.white,
                                                      barrierColor: AppConstants
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                      child: GestureDetector(
                                                        child:
                                                            const CircleAvatar(
                                                          radius: 15,
                                                          backgroundColor:
                                                              Colors.white,
                                                          child: Icon(
                                                            Icons
                                                                .add_circle_rounded,
                                                            color: AppConstants
                                                                .primaryColor,
                                                            size: 29,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (!snapshot.hasData ||
                                  !snapshot.data.exists) {
                                return Card(
                                  color: Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  elevation: 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        AppConstants.defaultNumericValue,
                                        8,
                                        0,
                                        8),
                                    child: observer.isAllowCreatingStatus ==
                                            false
                                        ? const SizedBox()
                                        : CustomPopupMenu(
                                            menuBuilder: () => ClipRRect(
                                              borderRadius: BorderRadius
                                                  .circular(AppConstants
                                                          .defaultNumericValue /
                                                      2),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    color: Colors.white),
                                                child: IntrinsicWidth(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      MoreMenuTitle(
                                                        title: LocaleKeys.camera
                                                            .tr(),
                                                        icon: cameraIcon,
                                                        onTap: () async {
                                                          _moreMenuController
                                                              .hideMenu();
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CameraScreenStory(
                                                                          prefs:
                                                                              widget.prefs,
                                                                        )),
                                                          );
                                                        },
                                                      ),
                                                      MoreMenuTitle(
                                                        title: LocaleKeys.text
                                                            .tr(),
                                                        icon: textIcon,
                                                        onTap: () {
                                                          _moreMenuController
                                                              .hideMenu();
                                                          (!Responsive
                                                                  .isDesktop(
                                                                      context))
                                                              ? Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => TextStatus(
                                                                          currentuserNo: widget
                                                                              .currentUserNo,
                                                                          phoneNumberVariants: widget
                                                                              .phoneNumberVariants)))
                                                              : ref
                                                                  .read(arrangementProvider
                                                                      .notifier)
                                                                  .setArrangement(TextStatus(
                                                                      currentuserNo:
                                                                          widget
                                                                              .currentUserNo,
                                                                      phoneNumberVariants:
                                                                          widget
                                                                              .phoneNumberVariants));
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            pressType: PressType.singleClick,
                                            verticalMargin: 0,
                                            controller: _moreMenuController,
                                            showArrow: true,
                                            arrowColor: Colors.white,
                                            barrierColor: AppConstants
                                                .primaryColor
                                                .withOpacity(0.1),
                                            child: GestureDetector(
                                              child: SizedBox(
                                                width: 90,
                                                height: 140,
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    customCircleAvatarStatus(
                                                        profilePic:
                                                            currentUserProfile!
                                                                .profilePicture),
                                                    Positioned(
                                                        bottom: 0,
                                                        child: Container(
                                                          height: 70,
                                                          width: 90,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Teme.isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                                ? AppConstants
                                                                    .backgroundColorDark
                                                                : AppConstants
                                                                    .backgroundColor,
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      AppConstants
                                                                              .defaultNumericValue *
                                                                          .9),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      AppConstants
                                                                              .defaultNumericValue *
                                                                          .9),
                                                            ),
                                                          ),
                                                        )),
                                                    CircleAvatar(
                                                      backgroundColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                      child: const Icon(
                                                        Icons
                                                            .add_circle_rounded,
                                                        color: AppConstants
                                                            .primaryColor,
                                                        size: 40,
                                                      ),
                                                    ),
                                                    Positioned(
                                                        bottom: 15,
                                                        child: Center(
                                                            child: Text(
                                                          LocaleKeys.createStory
                                                              .tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )))
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }
                              return Card(
                                  color: Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  elevation: 0.0,
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              AppConstants.defaultNumericValue,
                                              8,
                                              8,
                                              8),
                                          child: InkWell(
                                            onTap: () {},
                                            child: SizedBox(
                                              width: 90,
                                              height: 140,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: <Widget>[
                                                  customCircleAvatarStatus(
                                                      profilePic:
                                                          currentUserProfile!
                                                              .profilePicture),
                                                  Positioned(
                                                      bottom: 0,
                                                      child: Container(
                                                        height: 70,
                                                        width: 90,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .backgroundColorDark
                                                              : AppConstants
                                                                  .backgroundColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    AppConstants
                                                                            .defaultNumericValue *
                                                                        .9),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    AppConstants
                                                                            .defaultNumericValue *
                                                                        .9),
                                                          ),
                                                        ),
                                                      )),
                                                  CircleAvatar(
                                                    backgroundColor: Teme
                                                            .isDarktheme(
                                                                widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor,
                                                    child: const Icon(
                                                      Icons.add_circle_rounded,
                                                      color: AppConstants
                                                          .primaryColor,
                                                      size: 40,
                                                    ),
                                                  ),
                                                  Positioned(
                                                      bottom: 15,
                                                      child: Center(
                                                          child: Text(
                                                        LocaleKeys.createStory
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.center,
                                                      )))
                                                ],
                                              ),
                                            ),
                                          )),
                                      // const SizedBox(
                                      //   width: 10,
                                      // ),
                                      // Container(
                                      //     width: 90,
                                      //     height: 140,
                                      //     decoration: BoxDecoration(
                                      //         color: AppConstants.primaryColor
                                      //             .withOpacity(.1),
                                      //         borderRadius: const BorderRadius.all(
                                      //             Radius.circular(AppConstants
                                      //                 .defaultNumericValue))),
                                      //     child: const Center(
                                      //       child: CircularProgressIndicator(
                                      //           strokeWidth: 2,
                                      //           value: 0.5,
                                      //           color: AppConstants.primaryColor),
                                      //     )),
                                      // const SizedBox(
                                      //   width: 10,
                                      // ),
                                      // Container(
                                      //     width: 90,
                                      //     height: 140,
                                      //     decoration: BoxDecoration(
                                      //         color: AppConstants.primaryColor
                                      //             .withOpacity(.1),
                                      //         borderRadius: const BorderRadius.all(
                                      //             Radius.circular(AppConstants
                                      //                 .defaultNumericValue))),
                                      //     child: const Center(
                                      //       child: CircularProgressIndicator(
                                      //           strokeWidth: 1.5,
                                      //           value: 0.5,
                                      //           color: AppConstants.primaryColor),
                                      //     )),
                                      // const SizedBox(
                                      //   width: 10,
                                      // ),
                                    ],
                                  ));
                            }),
                        const SizedBox(
                          width: AppConstants.defaultNumericValue / 2,
                        ),
                        // searchingcontactsstatus == true
                        //     ? Container()
                        //     : contactsStatus!.isEmpty
                        //         ? Container()
                        //         :
                        Expanded(
                            child: Container(
                                height: 140,
                                color: Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      statusProvider.contactsStatus.length,
                                  itemBuilder: (context, idx) {
                                    int seen = !statusProvider
                                            .contactsStatus[idx]
                                            .data()!
                                            .containsKey(widget.currentUserNo)
                                        ? 0
                                        : 0;
                                    if (statusProvider.contactsStatus[idx]
                                        .data()
                                        .containsKey(widget.currentUserNo)) {
                                      statusProvider.contactsStatus[idx]
                                              [Dbkeys.statusITEMSLIST]
                                          .forEach((status) {
                                        if (statusProvider.contactsStatus[idx]
                                            .data()[widget.currentUserNo]
                                            .contains(
                                                status[Dbkeys.statusItemID])) {
                                          seen = seen + 1;
                                        }
                                      });
                                    }
                                    return FutureBuilder<LocalUserData?>(
                                        future: contactsProvider
                                            .fetchUserDataFromnLocalOrServer(
                                                widget.prefs,
                                                statusProvider
                                                        .contactsStatus[idx]
                                                        .data()[
                                                    Dbkeys
                                                        .statusPUBLISHERPHONE]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<LocalUserData?>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            return InkWell(
                                                onTap: () {
                                                  // print(statusProvider
                                                  //     .contactsStatus[idx]
                                                  //     .toString());
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  StatusView(
                                                                    model: widget
                                                                        .model!,
                                                                    prefs: widget
                                                                        .prefs,
                                                                    callback:
                                                                        (statuspublisherphone) {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(DbPaths
                                                                              .collectionnstatus)
                                                                          .where(
                                                                              Dbkeys.statusPUBLISHERPHONE,
                                                                              isEqualTo: statuspublisherphone)
                                                                          .get()
                                                                          .then((doc) {
                                                                        if (doc
                                                                            .docs
                                                                            .isNotEmpty) {
                                                                          int i = statusProvider.contactsStatus.indexWhere((element) =>
                                                                              element.data()[Dbkeys.statusPUBLISHERPHONE] ==
                                                                              statuspublisherphone);

                                                                          if (i >=
                                                                              0) {
                                                                            statusProvider.replaceStatus(i,
                                                                                doc.docs.first);
                                                                          }

                                                                          // setState(() {});
                                                                        }
                                                                      });
                                                                      if (IsInterstitialAdShow ==
                                                                              true &&
                                                                          observer.isadmobshow ==
                                                                              true &&
                                                                          !kIsWeb) {
                                                                        Future.delayed(
                                                                            const Duration(milliseconds: 500),
                                                                            () {
                                                                          _showInterstitialAd();
                                                                        });
                                                                      }
                                                                    },
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo,
                                                                    statusDoc:
                                                                        statusProvider
                                                                            .contactsStatus[idx],
                                                                    postedbyFullname:
                                                                        snapshot
                                                                            .data!
                                                                            .name,
                                                                    postedbyPhotourl:
                                                                        snapshot
                                                                            .data!
                                                                            .photoURL,
                                                                  )));
                                                },
                                                child: SizedBox(
                                                    height: 140,
                                                    width: 90,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          // totalitems: statusProvider
                                                          //     .contactsStatus[
                                                          //         idx][
                                                          //         Dbkeys
                                                          //             .statusITEMSLIST]
                                                          //     .length,
                                                          // totalseen: seen,
                                                          width: 90,
                                                          height: 140,
                                                          decoration: BoxDecoration(
                                                              color: Colors.transparent,
                                                              borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 1.2),
                                                              border: Border.all(
                                                                  color: statusProvider.contactsStatus[idx].data().containsKey(widget.currentUserNo)
                                                                      ? statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length > 0
                                                                          ? Colors.grey.withOpacity(0.8)
                                                                          : AppConstants.primaryColor.withOpacity(.8)
                                                                      : AppConstants.primaryColor.withOpacity(.8),
                                                                  width: 3)),

                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child:
                                                                statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            [
                                                                            statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                                1][Dbkeys
                                                                            .statusItemTYPE] ==
                                                                        Dbkeys
                                                                            .statustypeTEXT
                                                                    ? Container(
                                                                        width:
                                                                            90.0,
                                                                        height:
                                                                            140.0,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(int.parse(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR], radix: 16)),
                                                                            borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                        child: const Icon(
                                                                            Icons
                                                                                .text_fields,
                                                                            color:
                                                                                Colors.white54),
                                                                      )
                                                                    : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] ==
                                                                            Dbkeys.statustypeVIDEO
                                                                        ? Container(
                                                                            width:
                                                                                90.0,
                                                                            height:
                                                                                140.0,
                                                                            decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                  image: CachedNetworkImageProvider(
                                                                                    statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1]['thumbNail'],
                                                                                  ),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                                color: AppConstants.primaryColor.withOpacity(.2),
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                            child:
                                                                                const Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                                color: Colors.grey[300],
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                                color: Colors.grey[300],
                                                                              ),
                                                                            ),
                                                                          ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            bottom: 15,
                                                            child: SizedBox(
                                                                width: 90,
                                                                child: Center(
                                                                  child: Text(
                                                                    snapshot
                                                                        .data!
                                                                        .name,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ))),
                                                        Positioned(
                                                            top: 10,
                                                            left: 10,
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        width:
                                                                            2)),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 15,
                                                                  backgroundImage:
                                                                      CachedNetworkImageProvider(
                                                                    snapshot
                                                                        .data!
                                                                        .photoURL,
                                                                  ),
                                                                  // child:
                                                                  //     CachedNetworkImage(
                                                                  //   imageUrl: snapshot
                                                                  //       .data!
                                                                  //       .photoURL,
                                                                  //   fit: BoxFit
                                                                  //       .cover,
                                                                  // ),
                                                                )))
                                                      ],
                                                    )));
                                          }
                                          return InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              StatusView(
                                                                model: widget
                                                                    .model!,
                                                                prefs: widget
                                                                    .prefs,
                                                                callback:
                                                                    (statuspublisherphone) {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          DbPaths
                                                                              .collectionnstatus)
                                                                      .where(
                                                                          Dbkeys
                                                                              .statusPUBLISHERPHONE,
                                                                          isEqualTo:
                                                                              statuspublisherphone)
                                                                      .get()
                                                                      .then(
                                                                          (doc) {
                                                                    if (doc.docs
                                                                        .isNotEmpty) {
                                                                      int i = statusProvider
                                                                          .contactsStatus
                                                                          .indexWhere((element) =>
                                                                              element[Dbkeys.statusPUBLISHERPHONE] ==
                                                                              statuspublisherphone);
                                                                      statusProvider.replaceStatus(
                                                                          i,
                                                                          doc.docs
                                                                              .first);
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  });
                                                                  if (IsInterstitialAdShow ==
                                                                          true &&
                                                                      observer.isadmobshow ==
                                                                          true &&
                                                                      !kIsWeb) {
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        () {
                                                                      _showInterstitialAd();
                                                                    });
                                                                  }
                                                                },
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo,
                                                                statusDoc:
                                                                    statusProvider
                                                                            .contactsStatus[
                                                                        idx],
                                                                postedbyFullname: statusProvider
                                                                    .joinedUserPhoneStringAsInServer
                                                                    .elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider
                                                                        .contactsStatus[
                                                                            idx]
                                                                            [
                                                                            Dbkeys
                                                                                .statusPUBLISHERPHONEVARIANTS]
                                                                        .contains(element
                                                                            .phone
                                                                            .toString())))
                                                                    .name
                                                                    .toString(),
                                                                postedbyPhotourl:
                                                                    null,
                                                              )));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      AppConstants
                                                          .defaultNumericValue,
                                                      0,
                                                      0,
                                                      0),
                                              child: Container(
                                                width: 90,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                          .defaultNumericValue),
                                                ),
                                                child: Stack(
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        StatusView(
                                                                          model:
                                                                              widget.model!,
                                                                          prefs:
                                                                              widget.prefs,
                                                                          callback:
                                                                              (statuspublisherphone) {
                                                                            FirebaseFirestore.instance.collection(DbPaths.collectionnstatus).where(Dbkeys.statusPUBLISHERPHONE, isEqualTo: statuspublisherphone).get().then((doc) {
                                                                              if (doc.docs.isNotEmpty) {
                                                                                int i = statusProvider.contactsStatus.indexWhere((element) => element.data()[Dbkeys.statusPUBLISHERPHONE] == statuspublisherphone);

                                                                                if (i >= 0) {
                                                                                  statusProvider.replaceStatus(i, doc.docs.first);
                                                                                }

                                                                                // setState(() {});
                                                                              }
                                                                            });
                                                                            if (IsInterstitialAdShow == true &&
                                                                                observer.isadmobshow == true &&
                                                                                !kIsWeb) {
                                                                              Future.delayed(const Duration(milliseconds: 500), () {
                                                                                _showInterstitialAd();
                                                                              });
                                                                            }
                                                                          },
                                                                          currentUserNo:
                                                                              widget.currentUserNo,
                                                                          statusDoc:
                                                                              statusProvider.contactsStatus[idx],
                                                                          postedbyFullname: snapshot
                                                                              .data!
                                                                              .name,
                                                                          postedbyPhotourl: snapshot
                                                                              .data!
                                                                              .photoURL,
                                                                        )));
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10,
                                                                bottom: 10),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      AppConstants
                                                                              .defaultNumericValue *
                                                                          1.2),
                                                              border: Border.all(
                                                                  width: 3,
                                                                  color: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length ==
                                                                          seen
                                                                      ? Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.8)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              0.8))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child:
                                                                statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            [
                                                                            statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                                1][Dbkeys
                                                                            .statusItemTYPE] ==
                                                                        Dbkeys
                                                                            .statustypeTEXT
                                                                    ? Container(
                                                                        width:
                                                                            90.0,
                                                                        height:
                                                                            140.0,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: Color(int.parse(
                                                                              statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR],
                                                                              radix: 16)),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child: const Icon(
                                                                            Icons
                                                                                .text_fields,
                                                                            color:
                                                                                Colors.white54),
                                                                      )
                                                                    : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] ==
                                                                            Dbkeys.statustypeVIDEO
                                                                        ? Container(
                                                                            width:
                                                                                90.0,
                                                                            height:
                                                                                140.0,
                                                                            decoration: BoxDecoration(
                                                                                image: DecorationImage(
                                                                                  image: CachedNetworkImageProvider(
                                                                                    statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1]['thumbNail'],
                                                                                  ),
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                                color: AppConstants.primaryColor.withOpacity(.2),
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                            child:
                                                                                const Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[300],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Container(
                                                                              width: 90.0,
                                                                              height: 140.0,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[300],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                          ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 10.0,
                                                      child: Center(
                                                        child: Text(
                                                          statusProvider
                                                              .joinedUserPhoneStringAsInServer
                                                              .elementAt(statusProvider
                                                                  .joinedUserPhoneStringAsInServer
                                                                  .toList()
                                                                  .indexWhere((element) => statusProvider
                                                                      .contactsStatus[
                                                                          idx][
                                                                          Dbkeys
                                                                              .statusPUBLISHERPHONEVARIANTS]
                                                                      .contains(
                                                                          element
                                                                              .phone)))
                                                              .name
                                                              .toString(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                ))),
                      ],
                    )),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultNumericValue),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(LocaleKeys.channels.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold)),
                            CustomPopupMenu(
                                pressType: PressType.singleClick,
                                verticalMargin: 0,
                                controller: _moreMenuController2,
                                showArrow: true,
                                arrowColor: Colors.white,
                                barrierColor:
                                    AppConstants.primaryColor.withOpacity(0.1),
                                menuBuilder: () => ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.defaultNumericValue / 2),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: IntrinsicWidth(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              MoreMenuTitle(
                                                icon: mailIcon,
                                                title: LocaleKeys.startChannel
                                                    .tr(),
                                                onTap: () async {
                                                  _moreMenuController2
                                                      .hideMenu();
                                                  // Navigator.pop(context);
                                                  groupdesc.clear();
                                                  groupname.clear();

                                                  showModalBottomSheet(
                                                      backgroundColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .dialogColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius.circular(
                                                                    AppConstants
                                                                        .defaultNumericValue)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        // return your layout
                                                        var w = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width;
                                                        return StatefulBuilder(
                                                            builder: (BuildContext
                                                                    context,
                                                                StateSetter
                                                                    setState) {
                                                          String imageUrlChnl =
                                                              "";

                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16),
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    .8,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  physics:
                                                                      const BouncingScrollPhysics(),
                                                                  child: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              12,
                                                                        ),
                                                                        Center(
                                                                          child:
                                                                              Text(
                                                                            LocaleKeys.startChannel.tr(),
                                                                            textAlign:
                                                                                TextAlign.left,
                                                                            style: TextStyle(
                                                                                color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor),
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 16.5),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Center(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              await pickMediaAsData().then((value) async {
                                                                                final storageRef = FirebaseStorage.instance.ref();
                                                                                if (value != null) {
                                                                                  final imageRef = storageRef.child("group_profile_pictures/${groupname.text.replaceAll(" ", "-")}+${DateTime.now().millisecondsSinceEpoch}/${value.fileName}");

                                                                                  final uploadTask = imageRef.putData(value.pickedFile!, SettableMetadata(contentType: value.fileName!.contains(".jpg") || value.fileName!.contains(".jpeg") ? 'image/jpeg' : 'image/png'));
                                                                                  await uploadTask.whenComplete(() async {
                                                                                    imageUrlChnl = await imageRef.getDownloadURL();
                                                                                    setState(
                                                                                      () {},
                                                                                    );
                                                                                  });
                                                                                }
                                                                              });
                                                                            },
                                                                            child: CircleAvatar(
                                                                                radius: 50,
                                                                                backgroundColor: imageUrlChnl == "" ? AppConstants.primaryColor.withOpacity(.4) : null,
                                                                                backgroundImage: imageUrlChnl != "" ? NetworkImage(imageUrlChnl) : null,
                                                                                child: imageUrlChnl == ""
                                                                                    ? const Icon(
                                                                                        Icons.add,
                                                                                        color: Colors.white,
                                                                                      )
                                                                                    : const SizedBox()),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          // height: 63,
                                                                          height:
                                                                              83,
                                                                          width:
                                                                              w / 1.24,
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                groupname,
                                                                            autofocus:
                                                                                false,
                                                                            validator:
                                                                                (val) {
                                                                              if (val!.isEmpty) {
                                                                                return LocaleKeys.channelName.tr();
                                                                              }
                                                                              return null;
                                                                            },
                                                                            textCapitalization:
                                                                                TextCapitalization.words,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              filled: true,
                                                                              fillColor: AppConstants.primaryColor.withOpacity(.1),
                                                                              hintText: LocaleKeys.channelName.tr(),
                                                                              border: OutlineInputBorder(
                                                                                // Set outline border
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                                borderSide: BorderSide.none,
                                                                              ),
                                                                              prefixIcon: Icon(
                                                                                Icons.edit,
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              top: 10),
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          // height: 63,
                                                                          height:
                                                                              83,
                                                                          width:
                                                                              w / 1.24,
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                groupdesc,
                                                                            autofocus:
                                                                                false,
                                                                            validator:
                                                                                (val) {
                                                                              if (val!.isEmpty) {
                                                                                return LocaleKeys.pleaseEnterDescription.tr();
                                                                              }
                                                                              return null;
                                                                            },
                                                                            textCapitalization:
                                                                                TextCapitalization.words,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              filled: true,
                                                                              fillColor: AppConstants.primaryColor.withOpacity(.1),
                                                                              hintText: LocaleKeys.channeldesc.tr(),
                                                                              border: OutlineInputBorder(
                                                                                // Set outline border
                                                                                borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                                borderSide: BorderSide.none,
                                                                              ),
                                                                              prefixIcon: Icon(
                                                                                Icons.message,
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              6,
                                                                        ),
                                                                        CustomButton(
                                                                            color:
                                                                                AppConstants.primaryColor,
                                                                            text: LocaleKeys.create.tr(),
                                                                            onPressed: () async {
                                                                              if (imageUrlChnl != "" && groupdesc.text.trim() != "" && groupname.text.trim() != "") {
                                                                                List<String> listusers = [];
                                                                                List<String> listmembers = [];

                                                                                listmembers.add(widget.currentUserNo);
                                                                                if (widget.model!.currentUser![Dbkeys.notificationTokens].last != null) {
                                                                                  targetUserNotificationTokens.add(widget.model!.currentUser![Dbkeys.notificationTokens].last);
                                                                                }

                                                                                DateTime time = DateTime.now();
                                                                                DateTime time2 = DateTime.now().add(const Duration(seconds: 1));
                                                                                String groupID = '${widget.currentUserNo.toString()}--${time.millisecondsSinceEpoch.toString()}';
                                                                                Map<String, dynamic> groupdata = {
                                                                                  Dbkeys.groupDESCRIPTION: groupdesc.text.trim(),
                                                                                  Dbkeys.groupCREATEDON: time,
                                                                                  Dbkeys.groupCREATEDBY: widget.currentUserNo,
                                                                                  Dbkeys.groupNAME: groupname.text.trim(),
                                                                                  Dbkeys.groupIDfiltered: groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length),
                                                                                  Dbkeys.groupISTYPINGUSERID: '',
                                                                                  Dbkeys.groupADMINLIST: [
                                                                                    widget.currentUserNo
                                                                                  ],
                                                                                  Dbkeys.groupID: groupID,
                                                                                  Dbkeys.groupISVERIFIED: true,
                                                                                  Dbkeys.groupPHOTOURL: imageUrlChnl,
                                                                                  Dbkeys.groupMEMBERSLIST: listmembers,
                                                                                  Dbkeys.groupLATESTMESSAGETIME: time.millisecondsSinceEpoch,
                                                                                  Dbkeys.groupTYPE: Dbkeys.groupTYPEonlyadminmessageallowed,
                                                                                };

                                                                                for (var element in listmembers) {
                                                                                  groupdata.putIfAbsent(element.toString(), () => time.millisecondsSinceEpoch);

                                                                                  groupdata.putIfAbsent('$element-joinedOn', () => time.millisecondsSinceEpoch);
                                                                                }
                                                                                setState(() {
                                                                                  iscreatinggroup = true;
                                                                                });
                                                                                final collection = await FirebaseFirestore.instance.collection(DbPaths.collectionchannels).get();
                                                                                if (collection.docs != [] || collection.size != 0) {
                                                                                  await FirebaseFirestore.instance.collection(DbPaths.collectionchannels).doc('${widget.currentUserNo}--${time.millisecondsSinceEpoch}').set(groupdata).then((value) async {
                                                                                    await FirebaseFirestore.instance.collection(DbPaths.collectionchannels).doc('${widget.currentUserNo}--${time.millisecondsSinceEpoch}').collection(DbPaths.collectiongroupChats).doc('${time.millisecondsSinceEpoch}--${widget.currentUserNo}').set({
                                                                                      Dbkeys.groupmsgCONTENT: '',
                                                                                      Dbkeys.groupmsgLISToptional: listusers,
                                                                                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                                                                                      Dbkeys.groupmsgSENDBY: widget.currentUserNo,
                                                                                      Dbkeys.groupmsgISDELETED: false,
                                                                                      Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationCreatedGroup,
                                                                                    }).then((value) async {
                                                                                      await FirebaseFirestore.instance.collection(DbPaths.collectionchannels).doc('${widget.currentUserNo}--${time.millisecondsSinceEpoch}').collection(DbPaths.collectiongroupChats).doc('${time2.millisecondsSinceEpoch}--${widget.currentUserNo}').set({
                                                                                        Dbkeys.groupmsgCONTENT: '',
                                                                                        Dbkeys.groupmsgLISToptional: listmembers,
                                                                                        Dbkeys.groupmsgTIME: time2.millisecondsSinceEpoch,
                                                                                        Dbkeys.groupmsgSENDBY: widget.currentUserNo,
                                                                                        Dbkeys.groupmsgISDELETED: false,
                                                                                        Dbkeys.groupmsgTYPE: Dbkeys.groupmsgTYPEnotificationAddedUser,
                                                                                      }).then((val) async {
                                                                                        await FirebaseFirestore.instance.collection(DbPaths.collectiontemptokensforunsubscribe).doc(groupID).set({
                                                                                          Dbkeys.groupIDfiltered: groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length),
                                                                                          Dbkeys.notificationTokens: targetUserNotificationTokens,
                                                                                          'type': 'subscribe'
                                                                                        });
                                                                                      }).then((value) async {
                                                                                        EasyLoading.showSuccess(LocaleKeys.success.tr());
                                                                                        Navigator.of(context).pop();
                                                                                      }).catchError((err) {
                                                                                        setState(() {
                                                                                          iscreatinggroup = false;
                                                                                        });

                                                                                        Lamat.toast('${LocaleKeys.error.tr()} $err');
                                                                                        debugPrint('Error Creating group: $err');
                                                                                      });
                                                                                    });
                                                                                  });
                                                                                } else {
                                                                                  EasyLoading.showError("No Group found");
                                                                                  Navigator.of(context).pop();
                                                                                }
                                                                              } else {
                                                                                EasyLoading.showError("Please Fill All Fields!!");
                                                                              }
                                                                            }),
                                                                      ]),
                                                                )),
                                                          );
                                                        });
                                                      });

                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //         builder: (context) =>
                                                  //             AddContactsToChannel(
                                                  //               currentUserNo: widget
                                                  //                   .currentUserNo,
                                                  //               model: _cachedModel,
                                                  //               biometricEnabled:
                                                  //                   false,
                                                  //               prefs: widget.prefs,
                                                  //               isAddingWhileCreatingGroup:
                                                  //                   true,
                                                  //             )));
                                                },
                                              ),
                                              MoreMenuTitle(
                                                icon: searchIcon,
                                                title: LocaleKeys.findChannels
                                                    .tr(),
                                                onTap: () {
                                                  _moreMenuController2
                                                      .hideMenu();
                                                  !Responsive.isDesktop(context)
                                                      ? showDialog(
                                                          context: context,
                                                          barrierColor: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .backgroundColorDark
                                                              : AppConstants
                                                                  .backgroundColor,
                                                          builder: (BuildContext
                                                              context) {
                                                            return Column(
                                                              children: [
                                                                const SizedBox(
                                                                    height: AppConstants
                                                                        .defaultNumericValue),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                  child:
                                                                      CustomAppBar(
                                                                    leading: CustomIconButton(
                                                                        icon: leftArrowSvg,
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8)),
                                                                    title:
                                                                        Center(
                                                                      child:
                                                                          CustomHeadLine(
                                                                        text: LocaleKeys
                                                                            .channels
                                                                            .tr(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                ExploreChannel(
                                                                  
                                                                    prefs: widget
                                                                        .prefs, currentUserProf: currentUserProfile!,),
                                                              ],
                                                            );
                                                          })
                                                      : ref
                                                          .read(
                                                              arrangementProvider
                                                                  .notifier)
                                                          .setArrangement(
                                                              Column(
                                                            children: [
                                                              const SizedBox(
                                                                  height: AppConstants
                                                                      .defaultNumericValue),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        AppConstants
                                                                            .defaultNumericValue),
                                                                child:
                                                                    CustomAppBar(
                                                                  leading:
                                                                      CustomIconButton(
                                                                          icon:
                                                                              leftArrowSvg,
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              AppConstants.defaultNumericValue / 1.8)),
                                                                  title: Center(
                                                                    child:
                                                                        CustomHeadLine(
                                                                      text: LocaleKeys
                                                                          .channels
                                                                          .tr(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              ExploreChannel(
                                                                  prefs: widget
                                                                      .prefs, currentUserProf: currentUserProfile!,),
                                                            ],
                                                          ));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                child: InkWell(
                                  onTap: () {
                                    _moreMenuController2.showMenu();
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: AppConstants.primaryColor
                                        .withOpacity(0.1),
                                    radius: 20,
                                    child: const Icon(
                                      CupertinoIcons.add,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                )),
                            // CustomButton(onPressed: onPressed)
                          ]),
                    ),

                    _chats(model.userData, model.currentUser),
                    const SizedBox(
                        height: AppConstants.defaultNumericValue / 2),

                    // Divider(
                    //   height: 2, thickness: 2, color: Colors.grey.shade500),
                    InkWell(
                        onTap: () {
                          !Responsive.isDesktop(context)
                              ? showDialog(
                                  context: context,
                                  barrierColor: Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  builder: (BuildContext context) {
                                    return Column(
                                      children: [
                                        const SizedBox(
                                            height: AppConstants
                                                .defaultNumericValue),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: AppConstants
                                                  .defaultNumericValue),
                                          child: CustomAppBar(
                                            leading: CustomIconButton(
                                                icon: leftArrowSvg,
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                padding: const EdgeInsets.all(
                                                    AppConstants
                                                            .defaultNumericValue /
                                                        1.8)),
                                            title: Center(
                                              child: CustomHeadLine(
                                                text: LocaleKeys.channels.tr(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        ExploreChannel(prefs: widget.prefs, currentUserProf: currentUserProfile!,),
                                      ],
                                    );
                                  })
                              : ref
                                  .read(arrangementProvider.notifier)
                                  .setArrangement(Column(
                                    children: [
                                      const SizedBox(
                                          height:
                                              AppConstants.defaultNumericValue),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants
                                                .defaultNumericValue),
                                        child: CustomAppBar(
                                          leading: CustomIconButton(
                                              icon: leftArrowSvg,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              padding: const EdgeInsets.all(
                                                  AppConstants
                                                          .defaultNumericValue /
                                                      1.8)),
                                          title: Center(
                                            child: CustomHeadLine(
                                              text: LocaleKeys.channels.tr(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ExploreChannel(prefs: widget.prefs, currentUserProf: currentUserProfile!,),
                                    ],
                                  ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(LocaleKeys.findChannels.tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                              Text(LocaleKeys.viewAll.tr(),
                                  style: const TextStyle(
                                      color: AppConstants.primaryColor)),
                            ],
                          ),
                        )),
                    if (usersToFollow.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              // padding: const EdgeInsets.only(bottom: 50),
                              margin: const EdgeInsets.only(top: 30),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  enlargeCenterPage: false,
                                  scrollPhysics: const BouncingScrollPhysics(),
                                  height: 200,
                                  enableInfiniteScroll: true,
                                  viewportFraction: 0.45,
                                ),
                                items: usersToFollow,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(
                        height: AppConstants.defaultNumericValue * 6),
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width * .8,
                    //     child: CustomButton(
                    //         onPressed: () {
                    //           showDialog(
                    //               context: context,
                    //               builder: (BuildContext context) {
                    //                 return AddContactsToChannel(
                    //                   currentUserNo: widget.currentUserNo,
                    //                   model: _cachedModel,
                    //                   biometricEnabled: false,
                    //                   prefs: widget.prefs,
                    //                   isAddingWhileCreatingGroup: true,
                    //                 );
                    //               });
                    //         },
                    //         text: LocaleKeys.startChannel.tr())),
                  ],
                ),
              )),
        );
      }),
    ));
  }

  deleteOptions(BuildContext context, DocumentSnapshot myStatusDoc) {
    showModalBottomSheet(
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.dialogColorDark
            : AppConstants.backgroundColor,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer(
              builder: (context, ref, child) => Container(
                  padding: const EdgeInsets.all(12),
                  height: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          LocaleKeys.myactstatus.tr(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.dialogColorDark
                                    : AppConstants.backgroundColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 96,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                myStatusDoc[Dbkeys.statusITEMSLIST].length,
                            itemBuilder: (context, int i) {
                              return Container(
                                height: 40,
                                margin: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    myStatusDoc[Dbkeys.statusITEMSLIST][i]
                                                [Dbkeys.statusItemTYPE] ==
                                            Dbkeys.statustypeTEXT
                                        ? Container(
                                            width: 70.0,
                                            height: 70.0,
                                            decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  myStatusDoc[Dbkeys
                                                          .statusITEMSLIST][i][
                                                      Dbkeys.statusItemBGCOLOR],
                                                  radix: 16)),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.text_fields,
                                                color: Colors.white54),
                                          )
                                        : myStatusDoc[Dbkeys.statusITEMSLIST][i]
                                                    [Dbkeys.statusItemTYPE] ==
                                                Dbkeys.statustypeVIDEO
                                            ? Container(
                                                width: 70.0,
                                                height: 70.0,
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                    Icons.play_circle_fill,
                                                    size: 29,
                                                    color: Colors.white54),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: myStatusDoc[
                                                        Dbkeys.statusITEMSLIST]
                                                    [i][Dbkeys.statusItemURL],
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  width: 70.0,
                                                  height: 70.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                    Positioned(
                                      top: 45.0,
                                      left: 45.0,
                                      child: InkWell(
                                        onTap: () async {
                                          Navigator.of(context).pop();
                                          showDialog(
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor:
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .dialogColorDark
                                                        : AppConstants
                                                            .backgroundColor,
                                                title: Text(
                                                  LocaleKeys.dltstatus.tr(),
                                                  style: TextStyle(
                                                      color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .dialogColorDark
                                                          : AppConstants
                                                              .backgroundColor)),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      LocaleKeys.cancel.tr(),
                                                      style: const TextStyle(
                                                          color: AppConstants
                                                              .primaryColor,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      LocaleKeys.delete.tr(),
                                                      style: const TextStyle(
                                                          color: AppConstants
                                                              .lamatREDbuttonColor,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();

                                                      ref
                                                          .watch(
                                                              statusProviderProvider)
                                                          .setIsLoading(true);

                                                      if (myStatusDoc[Dbkeys
                                                                  .statusITEMSLIST][i]
                                                              [Dbkeys
                                                                  .statusItemTYPE] ==
                                                          Dbkeys
                                                              .statustypeTEXT) {
                                                        if (myStatusDoc[Dbkeys
                                                                    .statusITEMSLIST]
                                                                .length <
                                                            2) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionnstatus)
                                                              .doc(widget
                                                                  .currentUserNo)
                                                              .delete();
                                                        } else {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionnstatus)
                                                              .doc(widget
                                                                  .currentUserNo)
                                                              .update({
                                                            Dbkeys.statusITEMSLIST:
                                                                FieldValue
                                                                    .arrayRemove([
                                                              myStatusDoc[Dbkeys
                                                                  .statusITEMSLIST][i]
                                                            ])
                                                          });
                                                        }

                                                        ref
                                                            .watch(
                                                                statusProviderProvider)
                                                            .setIsLoading(
                                                                false);
                                                      } else {
                                                        FirebaseStorage.instance
                                                            .refFromURL(myStatusDoc[
                                                                Dbkeys
                                                                    .statusITEMSLIST][i][Dbkeys
                                                                .statusItemURL])
                                                            .delete()
                                                            .then(
                                                                (value) async {
                                                          if (myStatusDoc[Dbkeys
                                                                      .statusITEMSLIST]
                                                                  .length <
                                                              2) {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionnstatus)
                                                                .doc(widget
                                                                    .currentUserNo)
                                                                .delete();
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionnstatus)
                                                                .doc(widget
                                                                    .currentUserNo)
                                                                .update({
                                                              Dbkeys.statusITEMSLIST:
                                                                  FieldValue
                                                                      .arrayRemove([
                                                                myStatusDoc[Dbkeys
                                                                    .statusITEMSLIST][i]
                                                              ])
                                                            });
                                                          }
                                                        }).then((value) {
                                                          ref
                                                              .watch(
                                                                  statusProviderProvider)
                                                              .setIsLoading(
                                                                  false);
                                                        }).catchError(
                                                                (onError) async {
                                                          ref
                                                              .watch(
                                                                  statusProviderProvider)
                                                              .setIsLoading(
                                                                  false);
                                                          debugPrint(
                                                              'ERROR DELETING STATUS: $onError');

                                                          if (onError.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound2) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound3) ||
                                                              onError
                                                                  .toString()
                                                                  .contains(Dbkeys
                                                                      .firebaseStorageNoObjectFound4)) {
                                                            if (myStatusDoc[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length <
                                                                2) {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionnstatus)
                                                                  .doc(widget
                                                                      .currentUserNo)
                                                                  .delete();
                                                            } else {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionnstatus)
                                                                  .doc(widget
                                                                      .currentUserNo)
                                                                  .update({
                                                                Dbkeys.statusITEMSLIST:
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  myStatusDoc[Dbkeys
                                                                      .statusITEMSLIST][i]
                                                                ])
                                                              });
                                                            }
                                                          }
                                                        });
                                                      }
                                                    },
                                                  )
                                                ],
                                              );
                                            },
                                            context: context,
                                          );
                                        },
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: const BoxDecoration(
                                            color: AppConstants
                                                .lamatREDbuttonColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    ],
                  )));
        });
  }
}

class PopMenu extends ConsumerWidget {
  final Widget builder;
  final Widget child;
  const PopMenu({super.key, required this.builder, required this.child});

  @override
  Widget build(BuildContext context, ref) {
    final CustomPopupMenuController moreMenuController =
        CustomPopupMenuController();
    return CustomPopupMenu(
        menuBuilder: () => builder,
        pressType: PressType.singleClick,
        verticalMargin: 0,
        controller: moreMenuController,
        showArrow: true,
        arrowColor: Colors.white,
        barrierColor: AppConstants.primaryColor.withOpacity(0.1),
        child: child);
  }
}
