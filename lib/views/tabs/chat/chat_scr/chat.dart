// ignore_for_file: use_build_context_synchronously, deprecated_member_use, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:restart_app/restart_app.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:lamatdating/main.dart';
import 'package:lamatdating/translate_notifs.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/localization/language.dart';
import 'package:lamatdating/localization/language_constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/currentchat_peer.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/seen_provider.dart';
import 'package:lamatdating/providers/seen_state.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/call_utilities.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/emoji_detect.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/permissions.dart';
import 'package:lamatdating/utils/save.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/contact_screens/contacts_to_fwrd.dart';
import 'package:lamatdating/views/contact_screens/select_contact.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/privacypolicy&TnC/pdf_viewer.dart';
import 'package:lamatdating/views/security_screens/security.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/audio_playback.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/delete_chat_media.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/message.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/photo_view.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/upload_media.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/widg/bubble.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:lamatdating/widgets/AllinOneCameraGalleryImageVideoPicker/all_in_one_camera.dart';
import 'package:lamatdating/widgets/AudioRecorder/record_audio.dart';
import 'package:lamatdating/widgets/CameraGalleryImagePicker/multi_media_picker.dart';
import 'package:lamatdating/widgets/CountryPicker/country_code.dart';
import 'package:lamatdating/widgets/DownloadManager/download_all_file_type.dart';
import 'package:lamatdating/widgets/DynamicBottomSheet/dynamic_modal_bottomsheet.dart';
import 'package:lamatdating/widgets/ImagePicker/image_picker.dart';
import 'package:lamatdating/widgets/InputTextBox/input_text_box.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:lamatdating/widgets/SoundPlayer/sound_player_pro.dart';
import 'package:lamatdating/widgets/VideoEditor/video_editor.dart';
import 'package:lamatdating/widgets/VideoPicker/video_prev.dart';
import 'package:lamatdating/widgets/camera_web/camera_web.dart';

hidekeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class ChatScreen extends ConsumerStatefulWidget {
  final String? peerNo, currentUserNo;
  final DataModel model;
  final int unread;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  const ChatScreen({
    super.key,
    // Key? key,
    required this.currentUserNo,
    required this.peerNo,
    required this.model,
    required this.prefs,
    required this.unread,
    required this.isSharingIntentForwarded,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  ConsumerState createState() => ChatScreenState();
}

class ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffold =
      GlobalKey<ScaffoldState>(debugLabel: "Scaffold");
  final GlobalKey buttonKey = GlobalKey(debugLabel: "buttonKey");
  final GlobalKey buttonKey2 = GlobalKey(debugLabel: "buttonKey2");
  final GlobalKey buttonKey3 = GlobalKey(debugLabel: "buttonKey3");
  bool isDeleteChatManually = false;
  bool isReplyKeyboard = false;
  bool isPeerMuted = false;
  Map<String, dynamic>? replyDoc;
  String? peerAvatar, peerNo, currentUserNo, privateKey, sharedSecret;
  late bool locked, hidden;
  Map<String, dynamic>? peer, currentUser;
  int? chatStatus, unread;
  final GlobalKey<State> _keyLoader34 =
      GlobalKey<State>(debugLabel: 'qqqeqeqsse xcb h vgcxhvhaadsqeqe');
  bool isCurrentUserMuted = false;
  String? chatId;
  bool isMessageLoading = true;
  bool typing = false;
  late File thumbnailFile;
  File? pickedFile;
  bool? isVideo;
  bool? isAudio;
  bool? isImage;
  // bool isLoading = true;
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  String? imageUrl;
  SeenState? seenState;
  List<Message> messages = List.from(<Message>[]);
  List<Map<String, dynamic>> _savedMessageDocs =
      List.from(<Map<String, dynamic>>[]);
  bool isDeletedDoc = false;
  int? uploadTimestamp;
  List<Map<String, dynamic>> listMapLang = [];
  StreamSubscription? seenSubscription,
      msgSubscription,
      deleteUptoSubscription,
      chatStatusSubscriptionForPeer;

  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController reportEditingController = TextEditingController();
  final ScrollController realtime = ScrollController();
  final ScrollController saved = ScrollController();
  late DataModel _cachedModel;

  Duration? duration;
  Duration? position;

  // AudioPlayer audioPlayer = AudioPlayer();

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  bool isPurchaseDialogOpen = false;

  WalletsModel? wallet;

  bool isFirstMessage = true;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  @override
  void initState() {
    super.initState();
    _cachedModel = widget.model;
    peerNo = widget.peerNo;
    currentUserNo = widget.currentUserNo;
    unread = widget.unread;
    // initAudioPlayer();
    // _load();
    Lamat.internetLookUp();

    updateLocalUserData(_cachedModel);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      var currentpeer = ref.watch(currentChatPeerProviderProvider);
      currentpeer.setpeer(newpeerid: widget.peerNo);
      seenState = SeenState(false);
      WidgetsBinding.instance.addObserver(this);
      chatId = '';
      unread = widget.unread;
      // isLoading = false;
      imageUrl = '';
      listenToBlock();
      loadSavedMessages();
      readLocal(this.context);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (IsVideoAdShow == true && observer.isadmobshow == true && !kIsWeb) {
          _createRewardedAd();
        }

        if (IsInterstitialAdShow == true &&
            observer.isadmobshow == true &&
            !kIsWeb) {
          _createInterstitialAd();
        }
      });
    });
    setStatusBarColor(widget.prefs);
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.peerNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data() != null && doc.data()!.containsKey(widget.currentUserNo)) {
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setStateIfMounted(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setStateIfMounted(() {});
        }
      } else {
        hasPeerBlockedMe = false;
        setStateIfMounted(() {});
      }
    });
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: getInterstitialAdUnitId()!,
        request: const AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
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
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  void _createRewardedAd() {
    RewardedAd.load(
        adUnitId: getRewardBasedVideoAdUnitId()!,
        request: const AdRequest(
          nonPersonalizedAds: true,
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            debugPrint('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= maxAdFailedLoadAttempts) {
              _createRewardedAd();
            }
          },
        ));
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debugPrint('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (a, b) {});
    _rewardedAd = null;
  }

  updateLocalUserData(model) {
    peer = model.userData[peerNo];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden = currentUser![Dbkeys.hidden] != null &&
          currentUser![Dbkeys.hidden].contains(peerNo);
      locked = currentUser![Dbkeys.locked] != null &&
          currentUser![Dbkeys.locked].contains(peerNo);
      chatStatus = peer![Dbkeys.chatStatus];
      peerAvatar = peer![Dbkeys.photoUrl];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    // audioPlayer.stop();
    msgSubscription?.cancel();

    chatStatusSubscriptionForPeer?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  void setLastSeen() async {
    if (chatStatus != ChatStatus.blocked.index) {
      if (chatId != null) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .update(
          {'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
        );
        setStatusBarColor(widget.prefs);
        if (typing == true) {
          FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(currentUserNo)
              .update(
            {Dbkeys.lastSeen: true},
          );
        }
      }
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
    } catch (e) {
      return '';
    }

    return '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setIsActive();
    } else {
      setLastSeen();
    }
  }

  void setIsActive() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .set({
      '$currentUserNo': true,
      '$currentUserNo-lastOnline': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = const FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  readLocal(
    BuildContext context,
  ) async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await const e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peer![Dbkeys.publicKey], true)))
          .toBase64();

      final key = encrypt.Key.fromBase64(sharedSecret!);
      cryptor = encrypt.Encrypter(encrypt.Salsa20(key));
    } catch (e) {
      sharedSecret = null;
    }
    try {
      seenState!.value = widget.prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState!.value = false;
    }
    chatId = Lamat.getChatId(currentUserNo!, peerNo!);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerNo;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .update(
          {Dbkeys.lastSeen: peerNo},
        );
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .update(
          {Dbkeys.lastSeen: true},
        );
        typing = false;
      }
    });
    setIsActive();
    seenSubscription = FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setStateIfMounted(() {
          isDeletedDoc = false;
          isPeerMuted = doc.data()!.containsKey("$peerNo-muted")
              ? doc.data()!["$peerNo-muted"]
              : false;

          isCurrentUserMuted = doc.data()!.containsKey("$currentUserNo-muted")
              ? doc.data()!["$currentUserNo-muted"]
              : false;
        });

        if (mounted && doc.data()!.containsKey(peerNo)) {
          seenState!.value = doc[peerNo!] ?? false;
          if (seenState!.value is int) {
            widget.prefs.setInt(getLastSeenKey(), seenState!.value);
          }
          if (doc.data()!.containsKey("${peerNo!}-lastOnline")) {
            int lastOnline = doc.data()!["${peerNo!}-lastOnline"];
            if (doc.data()![peerNo!] == true &&
                DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(lastOnline))
                        .inMinutes >
                    20) {
              doc.reference.update({peerNo!: lastOnline});
            }
          }
        }
      } else {
        setStateIfMounted(() {
          isDeletedDoc = true;
        });
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerNo-${Dbkeys.lastSeen}";
  }

  int? thumnailtimestamp;
  getFileData(File image, bool? isVideo, bool? isAudio, bool? isImage,
      {int? timestamp, int? totalFiles}) {
    final observer = ref.watch(observerProvider);

    setStateIfMounted(() {
      pickedFile = image;
      isVideo = isVideo;
      isAudio = isAudio;
      isImage = isImage;
    });

    return observer.isPercentProgressShowWhileUploading
        ? (totalFiles == null
            ? uploadFileWithProgressIndicator(
                false,
                timestamp: timestamp,
              )
            : totalFiles == 1
                ? uploadFileWithProgressIndicator(
                    false,
                    timestamp: timestamp,
                  )
                : uploadFile(false, timestamp: timestamp))
        : uploadFile(false, timestamp: timestamp);
  }

  getThumbnail(String url) async {
    final observer = ref.watch(observerProvider);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });

    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        // thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 30);

    thumbnailFile = File(path!);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  getWallpaper(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      _cachedModel.setWallpaper(peerNo, image);
    }
    return Future.value(false);
  }

  String? videometadata;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo mediaInfo = MediaInfo();

      await mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Lamat.toast(
          LocaleKeys.sendingFailed.tr(),
        );
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    return uploading.ref.getDownloadURL();
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    // File fileToCompress;
    // File? compressedImage;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    // if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
    //   fileToCompress = File(pickedFile!.path);
    //   await compress.VideoCompress.setLogLevel(0);

    //   final compress.MediaInfo? info =
    //       await compress.VideoCompress.compressVideo(
    //     fileToCompress.path,
    //     quality: IsVideoQualityCompress == true
    //         ? compress.VideoQuality.MediumQuality
    //         : compress.VideoQuality.HighestQuality,
    //     deleteOrigin: false,
    //     includeAudio: true,
    //   );
    //   pickedFile = File(info!.path!);
    // } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
    //   final targetPath =
    //       "${pickedFile!.absolute.path.replaceAll(basename(pickedFile!.absolute.path), "")}temp.jpg";

    //   File originalImageFile = File(pickedFile!.path); // Convert XFile to File

    //   XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
    //     originalImageFile.absolute.path,
    //     targetPath,
    //     quality: ImageQualityCompress,
    //     rotate: 0,
    //   );

    //   if (compressedXFile != null) {
    //     compressedImage = File(compressedXFile.path); // Convert XFile to File
    //   }
    // } else {}
    UploadTask? uploading;
    if (kIsWeb) {
      // Uri blobUri = Uri.parse(html.window.sessionStorage[pickedFile!.path]!);
      http.Response response = await http.get(Uri.parse(pickedFile!.path));
      uploading = reference.putData(
        response.bodyBytes,
      );
    } else {
      uploading =
          reference.putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    }
    // SettableMetadata(contentType: isVideo! ? 'video/mp4' : isImage! ? 'image/jpeg' : 'sound/webm')

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  key: _keyLoader34,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading!.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading!.snapshot;

                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo mediaInfo = MediaInfo();

      await mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Lamat.toast(LocaleKeys.sendingFailed.tr());
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future<bool> checkIfLocationEnabled() async {
    if (await Permission.location.request().isGranted) {
      return true;
    } else if (await Permission.locationAlways.request().isGranted) {
      return true;
    } else if (await Permission.locationWhenInUse.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<Position> _determinePosition() async {
    return await Geolocator.getCurrentPosition();
  }

  void _changeLanguage(Language language) async {
    // Locale locale = await setLocale(language.languageCode);
    // MyApp.setLocale(this.context, locale);

    Future.delayed(const Duration(milliseconds: 800), () {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .update({
        Dbkeys.notificationStringsMap:
            getTranslateNotificationStringsMap(this.context),
      });
    });

    setState(() {
      // seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  void createInteractionNotification(
      {required String title,
      required String body,
      required String receiverId,
      required UserProfileModel currentUser}) async {
    final currentTime = DateTime.now();
    final id = currentTime.millisecondsSinceEpoch.toString();
    final NotificationModel notificationModel = NotificationModel(
      id: id,
      phoneNumber: currentUser.phoneNumber,
      receiverId: receiverId,
      title: title,
      body: body,
      image: currentUser.profilePicture,
      createdAt: currentTime,
      isRead: false,
      isMatchingNotification: false,
      isInteractionNotification: true,
    );

    await addNotification(notificationModel);
  }

  void onSendMessage(
      BuildContext context, String content, MessageType type, int? timestamp,
      {bool isForward = false}) async {
    final observer = ref.watch(observerProvider);

    if (wallet!.balance < AppRes.msgCost) {
      debugPrint('NO BALANCE');
      debugPrint("Balance: ${wallet!.balance} < Cost: ${AppRes.msgCost}");
      onAddDymondsTap(context);
    } else {
      if (content.trim() != '') {
        String tempcontent = "";

        try {
          await minusBalanceProvider(ref, AppRes.msgCost);

          content = content.trim();
          tempcontent = content.trim();
          if (chatStatus == null || chatStatus == 4) {
            ChatController.request(currentUserNo, peerNo, chatId);
          }
          textEditingController.clear();
          final encrypted = content;

          if (encrypted.isNotEmpty) {
            Future messaging = FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('$timestamp')
                .set({
              Dbkeys.isMuted: isPeerMuted,
              Dbkeys.from: currentUserNo,
              Dbkeys.to: peerNo,
              Dbkeys.timestamp: timestamp,
              Dbkeys.content: encrypted,
              Dbkeys.messageType: type.index,
              Dbkeys.hasSenderDeleted: false,
              Dbkeys.hasRecipientDeleted: false,
              Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
              Dbkeys.isReply: isReplyKeyboard,
              Dbkeys.replyToMsgDoc: replyDoc,
              Dbkeys.isForward: isForward,
              Dbkeys.latestEncrypted: true,
            }, SetOptions(merge: true));

            _cachedModel.addMessage(peerNo, timestamp, messaging);
            var tempDoc = {
              Dbkeys.isMuted: isPeerMuted,
              Dbkeys.from: currentUserNo,
              Dbkeys.to: peerNo,
              Dbkeys.timestamp: timestamp,
              Dbkeys.content: content,
              Dbkeys.messageType: type.index,
              Dbkeys.hasSenderDeleted: false,
              Dbkeys.hasRecipientDeleted: false,
              Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
              Dbkeys.isReply: isReplyKeyboard,
              Dbkeys.replyToMsgDoc: replyDoc,
              Dbkeys.isForward: isForward,
              Dbkeys.latestEncrypted: true,
              Dbkeys.tempcontent: tempcontent,
            };
            setStatusBarColor(widget.prefs);
            setStateIfMounted(() {
              isReplyKeyboard = false;
              replyDoc = null;
              messages = List.from(messages)
                ..add(Message(
                  buildMessage(this.context, tempDoc),
                  onTap: (tempDoc[Dbkeys.from] == widget.currentUserNo &&
                              tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                          true
                      ? () {}
                      : type == MessageType.image
                          ? () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewWrapper(
                                      prefs: widget.prefs,
                                      keyloader: _keyLoader34,
                                      imageUrl: content,
                                      message: content,
                                      tag: timestamp.toString(),
                                      imageProvider:
                                          CachedNetworkImageProvider(content),
                                    ),
                                  ));
                            }
                          : null,
                  onDismiss: tempDoc[Dbkeys.content] == '' ||
                          tempDoc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = tempDoc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
                  onDoubleTap: () {
                    // save(tempDoc);
                  },
                  onLongPress: () {
                    if (tempDoc.containsKey(Dbkeys.hasRecipientDeleted) &&
                        tempDoc.containsKey(Dbkeys.hasSenderDeleted)) {
                      if ((tempDoc[Dbkeys.from] == widget.currentUserNo &&
                              tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                          false) {
                        //--Show Menu only if message is not deleted by current user already
                        contextMenuNew(this.context, tempDoc, true);
                      }
                    } else {
                      contextMenuOld(context, tempDoc);
                    }
                  },
                  from: currentUserNo,
                  timestamp: timestamp,
                ));
            });
            createInteractionNotification(
              title:
                  "${_cachedModel.currentUser![Dbkeys.nickname]} Sent you a message",
              body: content,
              receiverId: peerNo!,
              currentUser: UserProfileModel.fromMap(_cachedModel.currentUser!),
            );

            unawaited(realtime.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut));

            if (type == MessageType.doc ||
                type == MessageType.audio ||
                // (type == MessageType.image && !content.contains('giphy')) ||
                type == MessageType.location ||
                type == MessageType.contact &&
                    widget.isSharingIntentForwarded == false) {
              if (IsVideoAdShow == true &&
                  observer.isadmobshow == true &&
                  IsInterstitialAdShow == false &&
                  !kIsWeb) {
                Future.delayed(const Duration(milliseconds: 800), () {
                  _showRewardedAd();
                });
              } else if (IsInterstitialAdShow == true &&
                  observer.isadmobshow == true &&
                  !kIsWeb) {
                _showInterstitialAd();
              }
            } else if (type == MessageType.video) {
              if (IsVideoAdShow == true &&
                  observer.isadmobshow == true &&
                  !kIsWeb) {
                Future.delayed(const Duration(milliseconds: 800), () {
                  _showRewardedAd();
                });
              }
            }

            // _playPopSound();
          } else {
            Lamat.toast(LocaleKeys.nothingtoenc.tr());
          }
        } on Exception catch (e) {
          // debugPrint('Exception caught!');
          Lamat.toast("Exception: $e");
        }
      }
    }
  }

  delete(int? ts) {
    setStateIfMounted(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  updateDeleteBySenderField(int? ts, updateDoc, context) {
    setStateIfMounted(() {
      int i = messages.indexWhere((msg) => msg.timestamp == ts);
      var child = buildMessage(context, updateDoc);
      var timestamp = messages[i].timestamp;
      var from = messages[i].from;
      // var onTap = messages[i].onTap;
      var onDoubleTap = messages[i].onDoubleTap;
      var onDismiss = messages[i].onDismiss;
      onLongPress() {}
      if (i >= 0) {
        messages.removeWhere((msg) => msg.timestamp == ts);
        messages.insert(
            i,
            Message(child,
                timestamp: timestamp,
                from: from,
                onTap: () {},
                onDoubleTap: onDoubleTap,
                onDismiss: onDismiss,
                onLongPress: onLongPress));
      }
      messages = List.from(messages);
    });
  }

  //-- context menu with Delete for Me & Delete For Everyone feature
  contextMenuNew(contextForDialog, Map<String, dynamic> mssgDoc, bool isTemp,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    //####################----------------------- Delete Msgs for SENDER ---------------------------------------------------
    if ((mssgDoc[Dbkeys.from] == currentUserNo &&
            mssgDoc[Dbkeys.hasSenderDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.delete_outline),
              title: Text(
                LocaleKeys.dltforme.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () async {
                hidekeyboard(popable);
                Navigator.of(popable).pop();

                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Lamat.toast(LocaleKeys.reloadScr.tr());
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasRecipientDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as recipient has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                      } else {
                        // -------Delete message completely as recipient has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Lamat.toast(LocaleKeys.couldnotdelete.tr());
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasSenderDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });

                      Map<String, dynamic> tempDoc = realtimeDoc;
                      setStateIfMounted(() {
                        tempDoc[Dbkeys.hasSenderDeleted] = true;
                      });
                      updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp],
                          tempDoc, contextForDialog);
                    }
                  }
                });
              })));

      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.delete),
              title: Text(
                LocaleKeys.dltforeveryone.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () async {
                hidekeyboard(popable);
                Navigator.of(popable).pop();
                if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                        ? mssgDoc[Dbkeys.isbroadcast]
                        : false) ==
                    true) {
                  // -------Delete broadcast message completely for everyone
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${mssgDoc[Dbkeys.timestamp]}')
                      .delete();
                  delete(mssgDoc[Dbkeys.timestamp]);
                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs.removeWhere((msg) =>
                      msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });
                } else {
                  // -------Delete message completely for everyone

                  await deleteMsgMedia(mssgDoc, chatId!)
                      .then((isDeleted) async {
                    if (isDeleted == false || isDeleted == null) {
                      Lamat.toast(LocaleKeys.couldnotdelete.tr());
                    } else {
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${mssgDoc[Dbkeys.timestamp]}')
                          .delete();
                      delete(mssgDoc[Dbkeys.timestamp]);
                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });
                    }
                  });
                }
              })));
    }
    //####################-------------------- Delete Msgs for RECIPIENTS---------------------------------------------------
    if ((mssgDoc[Dbkeys.to] == currentUserNo &&
            mssgDoc[Dbkeys.hasRecipientDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.delete_outline),
              title: Text(
                LocaleKeys.dltforme.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () async {
                hidekeyboard(popable);
                Navigator.of(popable).pop();
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Lamat.toast(LocaleKeys.reloadScr.tr());
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasSenderDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as sender has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });
                      } else {
                        // -------Delete message completely as sender has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Lamat.toast(LocaleKeys.couldnotdelete.tr());
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasRecipientDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });
                      if (isTemp == true) {
                        Map<String, dynamic> tempDoc = realtimeDoc;
                        setStateIfMounted(() {
                          tempDoc[Dbkeys.hasRecipientDeleted] = true;
                        });
                        updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp],
                            tempDoc, contextForDialog);
                      }
                    }
                  }
                });
              })));
    }
    if (mssgDoc.containsKey(Dbkeys.broadcastID) &&
        mssgDoc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.block),
              title: Text(
                LocaleKeys.blockbroadcast.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () {
                hidekeyboard(popable);
                Navigator.of(popable).pop();

                Future.delayed(const Duration(milliseconds: 200), () {
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectionbroadcasts)
                      .doc(mssgDoc[Dbkeys.broadcastID])
                      .update({
                    Dbkeys.broadcastMEMBERSLIST:
                        FieldValue.arrayRemove([widget.currentUserNo]),
                    Dbkeys.broadcastBLACKLISTED:
                        FieldValue.arrayUnion([widget.currentUserNo]),
                  }).catchError((error) {
                    Lamat.toast(error.toString());
                  });
                });
              })));
    }

    //####################--------------------- ALL BELOW DIALOG TILES FOR COMMON SENDER & RECIPIENT-------------------------###########################------------------------------

    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        !mssgDoc.containsKey(Dbkeys.broadcastID)) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.content_copy),
              title: Text(
                LocaleKeys.copy.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: mssgDoc[Dbkeys.content]));

                Lamat.toast(
                  LocaleKeys.copied.tr(),
                );
                Navigator.of(popable).pop();
              })));
    }
    if (((mssgDoc[Dbkeys.from] == currentUserNo &&
                mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
            (mssgDoc[Dbkeys.to] == currentUserNo &&
                mssgDoc[Dbkeys.hasRecipientDeleted] == false)) ==
        true) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(FontAwesomeIcons.share, size: 22),
              title: Text(
                LocaleKeys.forward.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                Navigator.push(
                    contextForDialog,
                    MaterialPageRoute(
                        builder: (contextForDialog) => SelectContactsToForward(
                            contentPeerNo: peerNo!,
                            messageOwnerPhone: widget.peerNo!,
                            currentUserNo: widget.currentUserNo,
                            model: widget.model,
                            prefs: widget.prefs,
                            onSelect: (selectedlist) async {
                              if (selectedlist.isNotEmpty) {
                                setStateIfMounted(() {
                                  isgeneratingSomethingLoader = true;
                                  // tempSendIndex = 0;
                                });

                                String? privateKey =
                                    await storage.read(key: Dbkeys.privateKey);

                                await sendForwardMessageEach(
                                    0, selectedlist, privateKey!, mssgDoc);
                              }
                            })));
              })));
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: const Icon(FontAwesomeIcons.reply, size: 22),
              title: Text(
                LocaleKeys.reply.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                setStateIfMounted(() {
                  isReplyKeyboard = true;
                  replyDoc = mssgDoc;
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        GoogleTransalteAPIkey != '' &&
        GoogleTransalteAPIkey != 'PASTE_GOOGLE_TRANSLATE_API_KEY') {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.translate),
              title: Text(
                LocaleKeys.translate.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                try {
                  var v = await Lamat.translateString(
                      mssgDoc[Dbkeys.content], widget.prefs);
                  if (v != mssgDoc[Dbkeys.content]) {
                    await widget.prefs.setString(
                        '${mssgDoc[Dbkeys.timestamp]}-trns', v.toString());
                    listMapLang.add(
                        {'${mssgDoc[Dbkeys.timestamp]}-trns': v.toString()});
                    int i = messages.indexWhere((element) =>
                        element.timestamp == mssgDoc[Dbkeys.timestamp]);
                    var m = messages[i];

                    if (i >= 0) {
                      messages.removeWhere((element) =>
                          element.timestamp == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {});
                      Future.delayed(const Duration(milliseconds: 100), () {
                        messages.insert(
                            i,
                            Message(buildMessage(this.context, mssgDoc),
                                timestamp: m.timestamp,
                                from: m.from,
                                onTap: m.onTap,
                                onDoubleTap: m.onDoubleTap,
                                onDismiss: m.onDismiss,
                                onLongPress: m.onLongPress));
                        setStateIfMounted(() {});
                        hidekeyboard(this.context);
                      });
                    }
                  }
                } catch (e) {
                  Lamat.toast(e.toString());
                }
              })));
    }

    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        Language.languageList().length > 1 &&
        GoogleTransalteAPIkey != '' &&
        GoogleTransalteAPIkey != 'PASTE_GOOGLE_TRANSLATE_API_KEY') {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.language_rounded),
              title: Text(
                LocaleKeys.setlang.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                try {
                  showDialogPermBottomSheet(
                      isdark: Teme.isDarktheme(widget.prefs),
                      context: this.context,
                      widgetList: Language.languageList()
                          .map(
                            (e) => Builder(
                              builder: (BuildContext popable2) => InkWell(
                                onTap: () {
                                  Navigator.of(popable2).pop();
                                  _changeLanguage(e);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        IsShowLanguageNameInNativeLanguage ==
                                                true
                                            ? '${e.flag}     ${e.name}'
                                            : '${e.flag}     ${e.languageNameInEnglish}',
                                        style: TextStyle(
                                            color:
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants.lamatWhite
                                                    : AppConstants.lamatBlack,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      Language.languageList().length < 2
                                          ? const SizedBox()
                                          : Icon(
                                              Icons.done,
                                              color: e.languageCode ==
                                                      widget.prefs.getString(
                                                          LAGUAGE_CODE)
                                                  ? AppConstants.secondaryColor
                                                  : Colors.transparent,
                                            )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      title: "");
                } catch (e) {
                  Lamat.toast(e.toString());
                }
              })));
    }

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.dialogColorDark
                  : AppConstants.backgroundColor,
              children: tiles);
        });
  }

  sendForwardMessageEach(
      int index, List<dynamic> list, String privateKey, var mssgDoc) async {
    if (index >= list.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
        Navigator.of(this.context).pop();
      });
    } else {
      // setStateIfMounted(() {
      //   tempSendIndex = index;
      // });
      if (list[index].containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[index];
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectiongroups)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc('$timestamp--${widget.currentUserNo!}')
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserNo!,
            // Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgTYPE: mssgDoc[Dbkeys.messageType],
            Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
            Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
            Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
            Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
            Dbkeys.isReply: false,
            Dbkeys.replyToMsgDoc: null,
            Dbkeys.isForward: true
          }, SetOptions(merge: true)).then((value) {
            unawaited(realtime.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut));
            // _playPopSound();
            FirebaseFirestore.instance
                .collection(DbPaths.collectiongroups)
                .doc(groupDoc[Dbkeys.groupID])
                .update(
              {Dbkeys.groupLATESTMESSAGETIME: timestamp},
            );
          }).then((value) async {
            if (index >= list.length - 1) {
              Lamat.toast(
                LocaleKeys.sent.tr(),
              );
              setStateIfMounted(() {
                isgeneratingSomethingLoader = false;
              });
              Navigator.of(this.context).pop();
            } else {
              await sendForwardMessageEach(
                  index + 1, list, privateKey, mssgDoc);
            }
          });
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Lamat.toast('${LocaleKeys.failedsending.tr()} $e');
        }
      } else {
        try {
          String? sharedSecret = (await const e2ee.X25519()
                  .calculateSharedSecret(e2ee.Key.fromBase64(privateKey, false),
                      e2ee.Key.fromBase64(list[index][Dbkeys.publicKey], true)))
              .toBase64();
          final key = encrypt.Key.fromBase64(sharedSecret);
          cryptor = encrypt.Encrypter(encrypt.Salsa20(key));
          String content = mssgDoc[Dbkeys.content];
          // final encrypted = encryptWithCRC(content);
          final encrypted = content;
          //  encryptWithCRC(content);
          //  AESEncryptData.encryptAES(content, sharedSecret);

          if (encrypted.isNotEmpty) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            var chatId = Lamat.getChatId(
                widget.currentUserNo!, list[index][Dbkeys.phone]);
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[index][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(
                    currentUserNo,
                    list[index][Dbkeys.phone],
                    Lamat.getChatId(
                        widget.currentUserNo!, list[index][Dbkeys.phone]));
              }

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set({
                widget.currentUserNo!: true,
                list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[index][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserNo!: 4,
                }, SetOptions(merge: true));
                await widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.isMuted: isPeerMuted,
                  Dbkeys.latestEncrypted: true,
                  Dbkeys.from: widget.currentUserNo!,
                  Dbkeys.to: list[index][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true
                }, SetOptions(merge: true));
                await widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                if (index >= list.length - 1) {
                  Lamat.toast(
                    LocaleKeys.sent.tr(),
                  );
                  setStateIfMounted(() {
                    isgeneratingSomethingLoader = false;
                  });
                  Navigator.of(this.context).pop();
                } else {
                  await sendForwardMessageEach(
                      index + 1, list, privateKey, mssgDoc);
                }
              });
            }
          } else {
            setStateIfMounted(() {
              isgeneratingSomethingLoader = false;
            });
            Lamat.toast(
              LocaleKeys.nothingtosend.tr(),
            );
          }
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Lamat.toast('${LocaleKeys.failedtofrwdmsgerror.tr()}$e');
        }
      }
    }
  }

  contextMenuOld(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if ((doc[Dbkeys.from] != currentUserNo) && saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: const Icon(Icons.delete),
          title: Text(
            LocaleKeys.dltforme.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pickTextColorBasedOnBgColorAdvanced(
                  Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor),
            ),
          ),
          onTap: () async {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${doc[Dbkeys.timestamp]}')
                .update({Dbkeys.hasRecipientDeleted: true});
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });

            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.maybePop(context);
              Lamat.toast(
                LocaleKeys.deleted.tr(),
              );
            });
          }));
    }

    if (doc[Dbkeys.messageType] == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: const Icon(Icons.content_copy),
          title: Text(
            LocaleKeys.copy.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pickTextColorBasedOnBgColorAdvanced(
                  Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor),
            ),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: doc[Dbkeys.content]));
            Navigator.pop(context);
            Lamat.toast(
              LocaleKeys.copied.tr(),
            );
          }));
    }
    if (doc.containsKey(Dbkeys.broadcastID) &&
        doc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(ListTile(
          dense: true,
          leading: const Icon(Icons.block),
          title: Text(
            LocaleKeys.blockbroadcast.tr(),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor)),
          ),
          onTap: () {
            Lamat.toast(
              LocaleKeys.plswait.tr(),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(doc[Dbkeys.broadcastID])
                  .update({
                Dbkeys.broadcastMEMBERSLIST:
                    FieldValue.arrayRemove([widget.currentUserNo]),
                Dbkeys.broadcastBLACKLISTED:
                    FieldValue.arrayUnion([widget.currentUserNo]),
              }).then((value) {
                Lamat.toast(
                  LocaleKeys.blockedbroadcast.tr(),
                );
                hidekeyboard(context);
                Navigator.pop(context);
              }).catchError((error) {
                Lamat.toast(
                  LocaleKeys.blockbroadcast.tr(),
                );
                Navigator.pop(context);
                hidekeyboard(context);
              });
            });
          }));
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.dialogColorDark
                  : AppConstants.backgroundColor,
              children: tiles);
        });
  }

  save(Map<String, dynamic> doc) async {
    Lamat.toast(
      LocaleKeys.saved.tr(),
    );
    if (!_savedMessageDocs
        .any((doc) => doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp])) {
      String? content;
      if (doc[Dbkeys.messageType] == MessageType.image.index) {
        content = doc[Dbkeys.content].toString().startsWith('http')
            ? await Save.getBase64FromImage(
                imageUrl: doc[Dbkeys.content] as String?)
            : doc[Dbkeys
                .content]; // if not a url, it is a base64 from saved messages
      } else {
        // If text
        content = doc[Dbkeys.content];
      }
      doc[Dbkeys.content] = content;
      Save.saveMessage(peerNo, doc);
      _savedMessageDocs.add(doc);
      setStateIfMounted(() {
        _savedMessageDocs = List.from(_savedMessageDocs);
      });
    }
  }

  Widget selectablelinkify(String? text, int timestamp, double? fontsize) {
    bool isContainURL = false;
    try {
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return isContainURL == false
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                SelectableLinkify(
                  style: TextStyle(
                      fontSize: isAllEmoji(text!) ? fontsize! * 2 : fontsize,
                      color: Colors.black87),
                  text: text,
                  onOpen: (link) async {
                    custom_url_launcher(link.url);
                  },
                ),
                listMapLang.indexWhere((element) =>
                            element.containsKey('$timestamp-trns')) <
                        0
                    ?
                    //---prfs
                    widget.prefs.getString('$timestamp-trns') == null ||
                            widget.prefs.getString('$timestamp-trns') ==
                                text.trim().toLowerCase()
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(7),
                            child: Text(
                              widget.prefs.getString('$timestamp-trns') ?? "",
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppConstants.lamatGrey),
                            ),
                          )
//-pprefs
                    :
                    //---map
                    listMapLang[listMapLang.indexWhere((element) =>
                                        element.containsKey('$timestamp-trns'))]
                                    ['$timestamp-trns']
                                .toString()
                                .toLowerCase() ==
                            text.trim().toLowerCase()
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(7),
                            child: Text(
                              listMapLang[listMapLang.indexWhere((element) =>
                                      element.containsKey('$timestamp-trns'))]
                                  ['$timestamp-trns'],
                              style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppConstants.lamatGrey),
                            ),
                          )
              ])
        : LinkPreviewGenerator(
            removeElevation: true,
            graphicFit: BoxFit.contain,
            borderRadius: 5,
            showDomain: true,
            titleStyle: const TextStyle(
                fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
            showBody: true,
            bodyStyle: const TextStyle(fontSize: 11.6, color: Colors.black45),
            placeholderWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }
  // Widget selectablelinkify(String? text, double? fontsize) {
  //   return SelectableLinkify(
  //     style: TextStyle(fontSize: fontsize, color: Colors.black87),
  //     text: text ?? "",
  //     onOpen: (link) async {
  //       if (1 == 1) {
  //         await custom_url_launcher(link.url);
  //       } else {
  //         throw 'Could not launch $link';
  //       }
  //     },
  //   );
  // }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: isMe == true
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  const SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(
                      doc[Dbkeys.content], doc[Dbkeys.timestamp], 16),
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              mainAxisAlignment: isMe == true
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.share,
                                  size: 12,
                                  color:
                                      AppConstants.lamatGrey.withOpacity(0.5),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(LocaleKeys.forwarded.tr(),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: AppConstants.lamatGrey
                                            .withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ]),
                          const SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(
                              doc[Dbkeys.content], doc[Dbkeys.timestamp], 16),
                        ],
                      )
                    : selectablelinkify(
                        doc[Dbkeys.content], doc[Dbkeys.timestamp], 16)
                : selectablelinkify(
                    doc[Dbkeys.content], doc[Dbkeys.timestamp], 16)
        : selectablelinkify(doc[Dbkeys.content], doc[Dbkeys.timestamp], 16);
  }

  Widget getTempTextMessage(
    String message,
    Map<String, dynamic> doc,
  ) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  const SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(message, doc[Dbkeys.timestamp], 16)
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                              mainAxisAlignment: isMe == true
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FontAwesomeIcons.share,
                                  size: 12,
                                  color:
                                      AppConstants.lamatGrey.withOpacity(0.5),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(LocaleKeys.forwarded.tr(),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: AppConstants.lamatGrey
                                            .withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ]),
                          const SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(message, doc[Dbkeys.timestamp], 16)
                        ],
                      )
                    : selectablelinkify(message, doc[Dbkeys.timestamp], 16)
                : selectablelinkify(message, doc[Dbkeys.timestamp], 16)
        : selectablelinkify(message, doc[Dbkeys.timestamp], 16);
  }

  Widget getLocationMessage(Map<String, dynamic> doc, String? message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
        onTap: () {
          custom_url_launcher(message!);
        },
        child: doc.containsKey(Dbkeys.isForward) == true
            ? doc[Dbkeys.isForward] == true
                ? Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: AppConstants.lamatGrey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(LocaleKeys.forwarded.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        AppConstants.lamatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]),
                      const SizedBox(
                        height: 10,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        child: Image.asset(
                          'assets/images/mapview.jpg',
                        ),
                      )
                    ],
                  )
                : ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    child: Image.asset(
                      'assets/images/mapview.jpg',
                    ),
                  )
            : ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
                child: Image.asset(
                  'assets/images/mapview.jpg',
                ),
              ));
  }

  Widget getAudiomessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: AppConstants.lamatGrey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(LocaleKeys.forwarded.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        AppConstants.lamatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : const SizedBox(height: 0, width: 0)
              : const SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: () async {
                await MobileDownloadService().download(
                    prefs: widget.prefs,
                    keyloader: _keyLoader34,
                    url: message.split('-BREAK-')[0],
                    fileName: 'Recording_${message.split('-BREAK-')[1]}.mp3',
                    context: this.context,
                    ref: ref,
                    isOpenAfterDownload: true);
              },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: AppConstants.lamatGrey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(LocaleKeys.forwarded.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        AppConstants.lamatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : const SizedBox(height: 0, width: 0)
              : const SizedBox(height: 0, width: 0),
          ListTile(
            contentPadding: const EdgeInsets.all(4),
            isThreeLine: false,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.insert_drive_file,
                size: 25,
                color: Colors.white,
              ),
            ),
            title: Text(
              message.split('-BREAK-')[1],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
          ),
          const Divider(
            height: 3,
          ),
          message.split('-BREAK-')[1].endsWith('.pdf')
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (_) => PDFViewerCachedFromUrl(
                                prefs: widget.prefs,
                                title: message.split('-BREAK-')[1],
                                url: message.split('-BREAK-')[0],
                                isregistered: true,
                              ),
                            ),
                          );
                        },
                        child: Text(LocaleKeys.preview.tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () async {
                          await MobileDownloadService().download(
                              prefs: widget.prefs,
                              url: message.split('-BREAK-')[0],
                              fileName: message.split('-BREAK-')[1],
                              context: context,
                              ref: ref,
                              keyloader: _keyLoader34,
                              isOpenAfterDownload: true);
                        },
                        child: Text(LocaleKeys.download.tr(),
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[400]))),
                  ],
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    await MobileDownloadService().download(
                        prefs: widget.prefs,
                        url: message.split('-BREAK-')[0],
                        fileName: message.split('-BREAK-')[1],
                        context: context,
                        ref: ref,
                        keyloader: _keyLoader34,
                        isOpenAfterDownload: true);
                  },
                  child: Text(LocaleKeys.download.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return Column(
      crossAxisAlignment:
          isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        doc.containsKey(Dbkeys.isForward) == true
            ? doc[Dbkeys.isForward] == true
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                        mainAxisAlignment: isMe == true
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.share,
                            size: 12,
                            color: AppConstants.lamatGrey.withOpacity(0.5),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(LocaleKeys.forwarded.tr(),
                              maxLines: 1,
                              style: TextStyle(
                                  color:
                                      AppConstants.lamatGrey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 13))
                        ]))
                : const SizedBox(height: 0, width: 0)
            : const SizedBox(height: 0, width: 0),
        saved
            ? Material(
                borderRadius: const BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            Save.getImageFromBase64(doc[Dbkeys.content]).image,
                        fit: BoxFit.cover),
                  ),
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 102 : 200.0,
                ),
              )
            : CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  padding: const EdgeInsets.all(80.0),
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                  ),
                ),
                errorWidget: (context, str, error) => Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset(
                    'assets/images/img_not_available.jpeg',
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    fit: BoxFit.cover,
                  ),
                ),
                imageUrl: doc[Dbkeys.content],
                width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                fit: BoxFit.cover,
              ),
      ],
    );
  }

  Widget getTempImageMessage({String? url}) {
    return url == null
        ? CachedNetworkImage(
            imageUrl: pickedFile!.uri.toString(),
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            errorWidget: (context, url, error) =>
                const Center(child: Icon(CupertinoIcons.photo)),
            fit: BoxFit.cover,
            width: url!.contains('giphy') ? 120 : 200.0,
            height: url.contains('giphy') ? 120 : 200.0,
          )
        : getImageMessage({Dbkeys.content: url});
  }

  Widget getVideoMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
      onTap: () {
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => PreviewVideo(
                      prefs: widget.prefs,
                      isdownloadallowed: true,
                      filename: message.split('-BREAK-').length > 3
                          ? message.split('-BREAK-')[3]
                          : "Video-${DateTime.now().millisecondsSinceEpoch}.mp4",
                      id: null,
                      videourl: message.split('-BREAK-')[0],
                      aspectratio: meta!["width"] / meta["height"],
                    )));
      },
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: AppConstants.lamatGrey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(LocaleKeys.forwarded.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        AppConstants.lamatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : const SizedBox(height: 0, width: 0)
              : const SizedBox(height: 0, width: 0),
          Container(
            color: Colors.blueGrey,
            height: 197,
            width: 197,
            child: Stack(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    width: 197,
                    height: 197,
                    padding: const EdgeInsets.all(80.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                    ),
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
                    ),
                  ),
                  errorWidget: (context, str, error) => Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      'assets/images/img_not_available.jpeg',
                      width: 197,
                      height: 197,
                      fit: BoxFit.cover,
                    ),
                  ),
                  imageUrl: message.split('-BREAK-')[1],
                  width: 197,
                  height: 197,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  height: 197,
                  width: 197,
                ),
                const Center(
                  child: Icon(Icons.play_circle_fill_outlined,
                      color: Colors.white70, size: 65),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getContactMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 250,
      height: 130,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: AppConstants.lamatGrey.withOpacity(0.5),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(LocaleKeys.forwarded.tr(),
                                maxLines: 1,
                                style: TextStyle(
                                    color:
                                        AppConstants.lamatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : const SizedBox(height: 0, width: 0)
              : const SizedBox(height: 0, width: 0),
          ListTile(
            isThreeLine: false,
            leading: customCircleAvatar(url: null),
            title: Text(
              message.split('-BREAK-')[0],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[400]),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                message.split('-BREAK-')[1],
                style: const TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ),
          const Divider(
            height: 7,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () async {
                String peer = message.split('-BREAK-')[1];
                String? peerphone;
                bool issearching = true;
                bool issearchraw = false;
                bool isUser = false;
                String? formattedphone;

                setStateIfMounted(() {
                  peerphone = peer.replaceAll(RegExp(r'-'), '');
                  peerphone!.trim();
                });

                formattedphone = peerphone;

                if (!peerphone!.startsWith('+')) {
                  if ((peerphone!.length > 11)) {
                    for (var code in CountryCodes) {
                      if (peerphone!.startsWith(code) && issearching == true) {
                        setStateIfMounted(() {
                          formattedphone = peerphone!
                              .substring(code.length, peerphone!.length);
                          issearchraw = true;
                          issearching = false;
                        });
                      }
                    }
                  } else {
                    setStateIfMounted(() {
                      setStateIfMounted(() {
                        issearchraw = true;
                        formattedphone = peerphone;
                      });
                    });
                  }
                } else {
                  setStateIfMounted(() {
                    issearchraw = false;
                    formattedphone = peerphone;
                  });
                }

                Query<Map<String, dynamic>> query = issearchraw == true
                    ? FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phoneRaw,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1)
                    : FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phone,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1);

                await query.get().then((user) {
                  setStateIfMounted(() {
                    isUser = user.docs.isEmpty ? false : true;
                  });
                  if (isUser) {
                    Map<String, dynamic> peer = user.docs[0].data();
                    widget.model.addUser(user.docs[0]);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                isSharingIntentForwarded: false,
                                prefs: widget.prefs,
                                unread: 0,
                                currentUserNo: widget.currentUserNo,
                                model: widget.model,
                                peerNo: peer[Dbkeys.phone])));
                  } else {
                    Query<Map<String, dynamic>> queryretrywithoutzero =
                        issearchraw == true
                            ? FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1)
                            : FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1);
                    queryretrywithoutzero.get().then((user) {
                      setStateIfMounted(() {
                        // isLoading = false;
                        isUser = user.docs.isEmpty ? false : true;
                      });
                      if (isUser) {
                        Map<String, dynamic> peer = user.docs[0].data();
                        widget.model.addUser(user.docs[0]);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                    isSharingIntentForwarded: true,
                                    prefs: widget.prefs,
                                    unread: 0,
                                    currentUserNo: widget.currentUserNo,
                                    model: widget.model,
                                    peerNo: peer[Dbkeys.phone])));
                      }
                    });
                  }
                });

                // ignore: unnecessary_null_comparison
                if (isUser == null || isUser == false) {
                  EasyLoading.showError('User not joined $Appname');
                }
              },
              child: Text(LocaleKeys.msg.tr(),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.blue[400])))
        ],
      ),
    );
  }

  _onEmojiSelected(emojipic.Emoji emoji) {
    // String text = textEditingController.text;
    // TextSelection textSelection = textEditingController.selection;
    // String newText =
    //     text.replaceRange(textSelection.start, textSelection.end, emoji.emoji);
    // final emojiLength = emoji.emoji.length;
    // textEditingController.text = newText;
    // textEditingController.selection = textSelection.copyWith(
    //   baseOffset: textSelection.start + emojiLength,
    //   extentOffset: textSelection.start + emojiLength,
    // );
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  Widget buildMessage(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false, List<Message>? savedMsgs}) {
    final observer = ref.watch(observerProvider);
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    bool isContinuing;
    if (savedMsgs == null) {
      isContinuing =
          messages.isNotEmpty ? messages.last.from == doc[Dbkeys.from] : false;
    } else {
      isContinuing = savedMsgs.isNotEmpty
          ? savedMsgs.last.from == doc[Dbkeys.from]
          : false;
    }
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return SeenProvider(
        timestamp: doc[Dbkeys.timestamp].toString(),
        data: seenState,
        child: Bubble(
            isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                isContainURL == true,
            mssgDoc: doc,
            is24hrsFormat: observer.is24hrsTimeformat,
            isMssgDeleted: (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    doc.containsKey(Dbkeys.hasSenderDeleted))
                ? isMe
                    ? (doc[Dbkeys.from] == widget.currentUserNo
                        ? doc[Dbkeys.hasSenderDeleted]
                        : false)
                    : (doc[Dbkeys.from] != widget.currentUserNo
                        ? doc[Dbkeys.hasRecipientDeleted]
                        : false)
                : false,
            isBroadcastMssg: doc.containsKey(Dbkeys.isbroadcast) == true
                ? doc[Dbkeys.isbroadcast]
                : false,
            messagetype: doc[Dbkeys.messageType] == MessageType.text.index
                ? MessageType.text
                : doc[Dbkeys.messageType] == MessageType.contact.index
                    ? MessageType.contact
                    : doc[Dbkeys.messageType] == MessageType.location.index
                        ? MessageType.location
                        : doc[Dbkeys.messageType] == MessageType.image.index
                            ? MessageType.image
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? MessageType.video
                                : doc[Dbkeys.messageType] ==
                                        MessageType.doc.index
                                    ? MessageType.doc
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.audio.index
                                        ? MessageType.audio
                                        : MessageType.text,
            isMe: isMe,
            timestamp: doc[Dbkeys.timestamp],
            delivered:
                _cachedModel.getMessageStatus(peerNo, doc[Dbkeys.timestamp]),
            isContinuing: isContinuing,
            child: doc[Dbkeys.messageType] == MessageType.text.index
                ? getTextMessage(isMe, doc, saved)
                : doc[Dbkeys.messageType] == MessageType.location.index
                    ? getLocationMessage(doc, doc[Dbkeys.content], saved: false)
                    : doc[Dbkeys.messageType] == MessageType.doc.index
                        ? getDocmessage(context, doc, doc[Dbkeys.content],
                            saved: false)
                        : doc[Dbkeys.messageType] == MessageType.audio.index
                            ? getAudiomessage(context, doc, doc[Dbkeys.content],
                                isMe: isMe, saved: false)
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? getVideoMessage(
                                    context, doc, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.contact.index
                                    ? getContactMessage(
                                        context, doc, doc[Dbkeys.content],
                                        saved: false)
                                    : getImageMessage(
                                        doc,
                                        saved: saved,
                                      )));
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
      child: Container(
          // width: 280,
          height: 70,
          margin: const EdgeInsets.only(left: 0, right: 0),
          decoration: BoxDecoration(
              color: AppConstants.lamatWhite.withOpacity(0.55),
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: const EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: AppConstants.lamatGrey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.from] == currentUserNo
                            ? AppConstants.primaryColor
                            : Colors.purple,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Text(
                              doc[Dbkeys.from] == currentUserNo
                                  ? "You"
                                  : Lamat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.from] == currentUserNo
                                      ? AppConstants.primaryColor
                                      : Colors.purple),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign:  doc[Dbkeys.from] == currentUserNo? TextAlign.end: TextAlign.start,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: AppConstants.lamatBlack),
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Text(
                                        doc[Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            color: AppConstants.lamatBlack),
                                      ),
                                    )
                                  : Text(
                                      doc[Dbkeys.messageType] ==
                                              MessageType.image.index
                                          ? LocaleKeys.nim.tr()
                                          : doc[Dbkeys.messageType] ==
                                                  MessageType.video.index
                                              ? LocaleKeys.nvm.tr()
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? LocaleKeys.nam.tr()
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .contact.index
                                                      ? LocaleKeys.ncm.tr()
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .location
                                                                  .index
                                                          ? LocaleKeys.nlm.tr()
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .doc.index
                                                              ? LocaleKeys.ndm
                                                                  .tr()
                                                              : '',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: AppConstants.lamatBlack),
                                    ),
                        ],
                      ),
                    ))
                  ])),
              doc[Dbkeys.messageType] == MessageType.text.index ||
                      doc[Dbkeys.messageType] == MessageType.location.index
                  ? const SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : doc[Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 74.0,
                            height: 74.0,
                            padding: const EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  width: doc[Dbkeys.content].contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: doc[Dbkeys.content].contains('giphy')
                                      ? 60
                                      : 60.0,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppConstants.secondaryColor),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                imageUrl: doc[Dbkeys.messageType] ==
                                        MessageType.video.index
                                    ? ''
                                    : doc[Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : doc[Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: const EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 74,
                                        width: 74,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 74,
                                                height: 74,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                                child:
                                                    const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppConstants
                                                              .secondaryColor),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, str, error) =>
                                                      Material(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              imageUrl: doc[Dbkeys.content]
                                                  .split('-BREAK-')[1],
                                              width: 74,
                                              height: 74,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 74,
                                              width: 74,
                                            ),
                                            const Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 74.0,
                                  height: 74.0,
                                  padding: const EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: doc[Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? AppConstants
                                                      .lamatGreenColor400
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : doc[Dbkeys.messageType] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
            ],
          )),
    );
  }

  Widget buildReplyMessageForInput(
    BuildContext context,
  ) {
    return Flexible(
      child: Container(
          height: 80,
          margin: const EdgeInsets.only(left: 15, right: 70),
          decoration: const BoxDecoration(
              color: AppConstants.lamatWhite,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: const EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: AppConstants.lamatGrey.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: replyDoc![Dbkeys.from] == currentUserNo
                            ? AppConstants.primaryColor
                            : Colors.purple,
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Text(
                              replyDoc![Dbkeys.from] == currentUserNo
                                  ? LocaleKeys.you.tr()
                                  : Lamat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.from] == currentUserNo
                                      ? AppConstants.primaryColor
                                      : Colors.purple),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          replyDoc![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? Text(
                                  replyDoc![Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      color: AppConstants.lamatBlack),
                                )
                              : replyDoc![Dbkeys.messageType] ==
                                      MessageType.doc.index
                                  ? Container(
                                      width: MediaQuery.of(context).size.width -
                                          125,
                                      padding: const EdgeInsets.only(right: 55),
                                      child: Text(
                                        replyDoc![Dbkeys.content]
                                            .split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: const TextStyle(
                                            color: AppConstants.lamatBlack),
                                      ),
                                    )
                                  : Text(
                                      replyDoc![Dbkeys.messageType] ==
                                              MessageType.image.index
                                          ? LocaleKeys.nim.tr()
                                          : replyDoc![Dbkeys.messageType] ==
                                                  MessageType.video.index
                                              ? LocaleKeys.nvm.tr()
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? LocaleKeys.nam.tr()
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .contact.index
                                                      ? LocaleKeys.ncm.tr()
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .location
                                                                  .index
                                                          ? LocaleKeys.nlm.tr()
                                                          : replyDoc![Dbkeys
                                                                      .messageType] ==
                                                                  MessageType
                                                                      .doc.index
                                                              ? LocaleKeys.ndm
                                                                  .tr()
                                                              : '',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: AppConstants.lamatBlack),
                                    ),
                        ],
                      ),
                    ))
                  ])),
              replyDoc![Dbkeys.messageType] == MessageType.text.index
                  ? const SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : replyDoc![Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            padding: const EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  width: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  height: replyDoc![Dbkeys.content]
                                          .contains('giphy')
                                      ? 60
                                      : 60.0,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey[200],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppConstants.secondaryColor),
                                  ),
                                ),
                                errorWidget: (context, str, error) => Material(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.asset(
                                    'assets/images/img_not_available.jpeg',
                                    width: 60.0,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                imageUrl: replyDoc![Dbkeys.messageType] ==
                                        MessageType.video.index
                                    ? ''
                                    : replyDoc![Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : replyDoc![Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: const EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 84,
                                        width: 84,
                                        child: Stack(
                                          children: [
                                            CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 84,
                                                height: 84,
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey[200],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(0.0),
                                                  ),
                                                ),
                                                child:
                                                    const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppConstants
                                                              .secondaryColor),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, str, error) =>
                                                      Material(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(0.0),
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Image.asset(
                                                  'assets/images/img_not_available.jpeg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              imageUrl:
                                                  replyDoc![Dbkeys.content]
                                                      .split('-BREAK-')[1],
                                              width: 84,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 84,
                                              width: 84,
                                            ),
                                            const Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: const EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: replyDoc![
                                                      Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? AppConstants
                                                      .lamatGreenColor400
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 84,
                                          width: 84,
                                          child: Icon(
                                            replyDoc![Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : replyDoc![Dbkeys
                                                            .messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : replyDoc![Dbkeys
                                                                .messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : replyDoc![Dbkeys
                                                                    .messageType] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
              Positioned(
                right: 7,
                top: 7,
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      HapticFeedback.heavyImpact();
                      isReplyKeyboard = false;
                      hidekeyboard(context);
                    });
                  },
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.blueGrey,
                      size: 13,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              color: pickTextColorBasedOnBgColorAdvanced(
                      !Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor)
                  .withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor)),
              ),
            )
          : Container(),
    );
  }

  shareMedia(BuildContext context) {
    Offset? offset;
    Offset? buttonPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox buttonBox =
          buttonKey2.currentContext?.findRenderObject() as RenderBox;
      if (buttonBox.hasSize) {
        buttonPosition = buttonBox.localToGlobal(Offset.zero);
        offset = buttonPosition! + Offset(0, buttonBox.size.height);
      } else {
        offset = const Offset(0, 0);
      }
    });

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
          return Container(
            padding: const EdgeInsets.all(12),
            height: 250,
            child: Column(children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width / 3.27,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            key: buttonKey2,
                            disabledElevation: 0,
                            onPressed: () {
                              hidekeyboard(context);

                              Navigator.of(context).pop();
                              showModalBottomSheet(
                                context: context,
                                // barrierDismissible: true,
                                builder: (context) => AudioRecord(
                                  prefs: widget.prefs,
                                  title: LocaleKeys.record.tr(),
                                  callback: getFileData,
                                ),
                                backgroundColor: AppConstants.primaryColor,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.3,
                                ),
                                barrierColor: Colors
                                    .transparent, // Optional: semi-transparent background
                                useSafeArea: true,
                                routeSettings: RouteSettings(
                                  // Pass the offset to the popup content
                                  arguments: offset,
                                ),
                              ).then((url) {
                                if (url != null) {
                                  uploadTimestamp =
                                      DateTime.now().millisecondsSinceEpoch;
                                  onSendMessage(
                                      context,
                                      url +
                                          '-BREAK-' +
                                          uploadTimestamp.toString(),
                                      MessageType.audio,
                                      uploadTimestamp);
                                } else {}
                              });
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => AudioRecord(
                              //               prefs: widget.prefs,
                              //               title: "Record Audio",
                              //               callback: getFileData,
                              //             ))).then((url) {
                              //   if (url != null) {
                              //     onSendMessage(
                              //         context,
                              //         url +
                              //             '-BREAK-' +
                              //             uploadTimestamp.toString(),
                              //         MessageType.audio,
                              //         uploadTimestamp);
                              //   } else {}
                              // });
                            },
                            elevation: .5,
                            fillColor: Colors.yellow[900],
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.mic_rounded,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            LocaleKeys.audio.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(color: AppConstants.lamatGrey),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width / 3.27,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            disabledElevation: 0,
                            onPressed: () async {
                              hidekeyboard(context);
                              Navigator.of(context).pop();
                              if (!kIsWeb) {
                                File? selectedMedia =
                                    await pickVideoFromgallery(context)
                                        .catchError((err) {
                                  Lamat.toast("Invalid file");
                                  return null;
                                });

                                if (selectedMedia == null) {
                                  setStatusBarColor(widget.prefs);
                                } else {
                                  setStatusBarColor(widget.prefs);
                                  String fileExtension = p
                                      .extension(selectedMedia.path)
                                      .toLowerCase();

                                  if (fileExtension == ".mp4" ||
                                      fileExtension == ".mov") {
                                    final tempDir =
                                        await getTemporaryDirectory();
                                    File file = await File(
                                            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4')
                                        .create();
                                    file.writeAsBytesSync(
                                        selectedMedia.readAsBytesSync());

                                    await Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                            builder: (context) => VideoEditor(
                                                prefs: widget.prefs,
                                                onClose: () {
                                                  setStatusBarColor(
                                                      widget.prefs);
                                                },
                                                thumbnailQuality: 90,
                                                videoQuality: 100,
                                                maxDuration: 1900,
                                                onEditExported: (videoFile,
                                                    thumnailFile) async {
                                                  int timeStamp = DateTime.now()
                                                      .millisecondsSinceEpoch;
                                                  String videoFileext =
                                                      p.extension(file.path);
                                                  String videofileName =
                                                      'Video-$timeStamp$videoFileext';

                                                  String? videoUrl =
                                                      await uploadSelectedLocalFileWithProgressIndicator(
                                                          file,
                                                          true,
                                                          false,
                                                          timeStamp,
                                                          filenameoptional:
                                                              videofileName);
                                                  if (videoUrl != null) {
                                                    String? thumnailUrl =
                                                        await uploadSelectedLocalFileWithProgressIndicator(
                                                            thumnailFile,
                                                            false,
                                                            true,
                                                            timeStamp);
                                                    if (thumnailUrl != null) {
                                                      onSendMessage(
                                                          this.context,
                                                          '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName',
                                                          MessageType.video,
                                                          timeStamp);

                                                      await file.delete();
                                                      await thumnailFile
                                                          .delete();
                                                    }
                                                  }
                                                },
                                                file: File(file.path))));
                                  } else {
                                    Lamat.toast(
                                        "${LocaleKeys.filetypenotsupportedvideo.tr()} $fileExtension ");
                                  }
                                }
                              } else {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CameraWebHome(
                                              prefs: widget.prefs,
                                              onTakeFileWeb: (file, isVideo,
                                                  filname, videoData) async {
                                                setStatusBarColor(widget.prefs);

                                                int timeStamp = DateTime.now()
                                                    .millisecondsSinceEpoch;
                                                if (isVideo == true) {
                                                  // String videoFileext =
                                                  //     p.extension(file.path);
                                                  String videofileName =
                                                      'Video-$timeStamp$filname';
                                                  String? videoUrl =
                                                      await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                          file,
                                                          true,
                                                          false,
                                                          timeStamp,
                                                          filname);
                                                  if (videoUrl != null) {
                                                    // String? thumnailUrl =
                                                    //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                    //         filname!,
                                                    //         false,
                                                    //         true,
                                                    //         timeStamp);

                                                    onSendMessage(
                                                        this.context,
                                                        '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName',
                                                        MessageType.video,
                                                        timeStamp);
                                                    // await file.delete();
                                                    // await thumnail.delete();
                                                    Navigator.pop(context);
                                                  }
                                                } else {
                                                  // String imageFileext =
                                                  //     p.extension(file.path);
                                                  String imagefileName =
                                                      filname;
                                                  String? url =
                                                      await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                          file,
                                                          false,
                                                          false,
                                                          timeStamp,
                                                          imagefileName);
                                                  if (url != null) {
                                                    onSendMessage(
                                                        this.context,
                                                        url,
                                                        MessageType.image,
                                                        timeStamp);
                                                    // await file.delete();
                                                    Navigator.pop(context);
                                                  }
                                                }
                                              },
                                            )));
                              }
                            },
                            elevation: .5,
                            fillColor: Colors.pink[600],
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.video_collection_sharp,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            LocaleKeys.video.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppConstants.lamatGrey, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width / 3.27,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            disabledElevation: 0,
                            onPressed: () async {
                              hidekeyboard(context);
                              Navigator.of(context).pop();

                              if (kIsWeb) {
                                Uint8List? fileBytes;
                                String? fileName;
                                final result = await FilePicker.platform
                                    .pickFiles(
                                        allowMultiple: false,
                                        type: FileType.image);
                                if (result != null) {
                                  fileBytes = result.files.first.bytes!;
                                  fileName = result.files.first.name;
                                }

                                // await Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => PhotoEditor(
                                //               isPNG: false,
                                //               onImageEdit: (editedImage) {
                                //                 widget.onTakeFile(
                                //                     editedImage, false, null);
                                //               },
                                //               imageFilePreSelected:
                                //                   File(file!.path),
                                //             )));
                                if (fileBytes != null && fileBytes.isNotEmpty) {
                                  // final editedImage = await Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ImageEditor(
                                  //               images: fileBytes,
                                  //               appBar:
                                  //                   Teme.isDarktheme(widget.prefs)
                                  //                       ? AppConstants
                                  //                           .backgroundColorDark
                                  //                       : AppConstants
                                  //                           .backgroundColor,
                                  //               // bottomBarColor: Colors.blue,
                                  //             )));

                                  setStatusBarColor(widget.prefs);

                                  int timeStamp =
                                      DateTime.now().millisecondsSinceEpoch;
                                  // if (isVideo == true) {
                                  //   // String videoFileext =
                                  //   //     p.extension(file.path);
                                  //   String videofileName =
                                  //       'Video-$timeStamp$fileName';
                                  //   String? videoUrl =
                                  //       await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                  //           editedImage,
                                  //           true,
                                  //           false,
                                  //           timeStamp,
                                  //           fileName!);
                                  //   if (videoUrl != null) {
                                  //     // String? thumnailUrl =
                                  //     //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                  //     //         filname!,
                                  //     //         false,
                                  //     //         true,
                                  //     //         timeStamp);

                                  //     onSendMessage(
                                  //         this.context,
                                  //         '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName',
                                  //         MessageType.video,
                                  //         timeStamp);
                                  //     // await file.delete();
                                  //     // await thumnail.delete();
                                  //   }
                                  // } else

                                  // String imageFileext =
                                  //     p.extension(file.path);
                                  String imagefileName = fileName!;
                                  String? url =
                                      await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                          fileBytes,
                                          false,
                                          false,
                                          timeStamp,
                                          imagefileName);
                                  if (url != null) {
                                    onSendMessage(this.context, url,
                                        MessageType.image, timeStamp);
                                    // await file.delete();
                                  }
                                }
                              } else {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllinOneCameraGalleryImageVideoPicker(
                                              prefs: widget.prefs,
                                              onTakeFile: (file, isVideo,
                                                  thumnail) async {
                                                setStatusBarColor(widget.prefs);

                                                int timeStamp = DateTime.now()
                                                    .millisecondsSinceEpoch;
                                                if (isVideo == true) {
                                                  String videoFileext =
                                                      p.extension(file.path);
                                                  String videofileName =
                                                      'Video-$timeStamp$videoFileext';
                                                  String? videoUrl =
                                                      await uploadSelectedLocalFileWithProgressIndicator(
                                                          file,
                                                          true,
                                                          false,
                                                          timeStamp,
                                                          filenameoptional:
                                                              videofileName);
                                                  if (videoUrl != null) {
                                                    String? thumnailUrl =
                                                        await uploadSelectedLocalFileWithProgressIndicator(
                                                            thumnail!,
                                                            false,
                                                            true,
                                                            timeStamp);
                                                    if (thumnailUrl != null) {
                                                      onSendMessage(
                                                          this.context,
                                                          '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName',
                                                          MessageType.video,
                                                          timeStamp);
                                                      await file.delete();
                                                      await thumnail.delete();
                                                    }
                                                  }
                                                } else {
                                                  String imageFileext =
                                                      p.extension(file.path);
                                                  String imagefileName =
                                                      'IMG-$timeStamp$imageFileext';
                                                  String? url =
                                                      await uploadSelectedLocalFileWithProgressIndicator(
                                                          file,
                                                          false,
                                                          false,
                                                          timeStamp,
                                                          filenameoptional:
                                                              imagefileName);
                                                  if (url != null) {
                                                    onSendMessage(
                                                        this.context,
                                                        url,
                                                        MessageType.image,
                                                        timeStamp);
                                                    await file.delete();
                                                  }
                                                }
                                              },
                                              onTakeFileWeb: (file, isVideo,
                                                  filname) async {
                                                setStatusBarColor(widget.prefs);

                                                int timeStamp = DateTime.now()
                                                    .millisecondsSinceEpoch;
                                                if (isVideo == true) {
                                                  // String videoFileext =
                                                  //     p.extension(file.path);
                                                  String videofileName =
                                                      'Video-$timeStamp$filname';
                                                  String? videoUrl =
                                                      await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                          file,
                                                          true,
                                                          false,
                                                          timeStamp,
                                                          filname);
                                                  if (videoUrl != null) {
                                                    // String? thumnailUrl =
                                                    //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                    //         filname!,
                                                    //         false,
                                                    //         true,
                                                    //         timeStamp);

                                                    onSendMessage(
                                                        this.context,
                                                        '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName',
                                                        MessageType.video,
                                                        timeStamp);
                                                    // await file.delete();
                                                    // await thumnail.delete();
                                                  }
                                                } else {
                                                  // String imageFileext =
                                                  //     p.extension(file.path);
                                                  String imagefileName =
                                                      filname;
                                                  String? url =
                                                      await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                          file,
                                                          false,
                                                          false,
                                                          timeStamp,
                                                          imagefileName);
                                                  if (url != null) {
                                                    onSendMessage(
                                                        this.context,
                                                        url,
                                                        MessageType.image,
                                                        timeStamp);
                                                    // await file.delete();
                                                  }
                                                }
                                              },
                                            )));
                              }
                            },
                            elevation: .5,
                            fillColor: Colors.purple,
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.image_rounded,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            LocaleKeys.image.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppConstants.lamatGrey, fontSize: 14),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width / 3.27,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            disabledElevation: 0,
                            onPressed: () async {
                              hidekeyboard(context);
                              Navigator.of(context).pop();
                              await checkIfLocationEnabled()
                                  .then((value) async {
                                if (value == true) {
                                  Lamat.toast(
                                    LocaleKeys.detectingloc.tr(),
                                  );
                                  await _determinePosition().then(
                                    (location) async {
                                      var locationstring =
                                          'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                      onSendMessage(
                                          this.context,
                                          locationstring,
                                          MessageType.location,
                                          DateTime.now()
                                              .millisecondsSinceEpoch);
                                      setStateIfMounted(() {});
                                      Lamat.toast(
                                        LocaleKeys.sent.tr(),
                                      );
                                    },
                                  );
                                } else {
                                  Lamat.toast(
                                    LocaleKeys.lcdennied.tr(),
                                  );
                                  openAppSettings();
                                }
                              });
                            },
                            elevation: .5,
                            fillColor: Colors.cyan[700],
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.location_on,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            LocaleKeys.location.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(color: AppConstants.lamatGrey),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      // width: MediaQuery.of(context).size.width / 3.27,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            disabledElevation: 0,
                            onPressed: () async {
                              hidekeyboard(context);
                              Navigator.of(context).pop();
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ContactsSelect(
                                          currentUserNo: widget.currentUserNo,
                                          model: widget.model,
                                          biometricEnabled: false,
                                          prefs: widget.prefs,
                                          onSelect: (name, phone) {
                                            onSendMessage(
                                                context,
                                                '$name-BREAK-$phone',
                                                MessageType.contact,
                                                DateTime.now()
                                                    .millisecondsSinceEpoch);
                                          })));
                            },
                            elevation: .5,
                            fillColor: Colors.blue[800],
                            padding: const EdgeInsets.all(15.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.person,
                              size: 25.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            LocaleKeys.contact.tr(),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(color: AppConstants.lamatGrey),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }

  Future uploadSelectedLocalFileWithProgressIndicatorWeb(
    Uint8List selectedFile,
    bool isVideo,
    bool isthumbnail,
    int timeEpoch,
    String filenameoptional, {
    File? videoData,
  }) async {
    // String ext = filenameoptional.split(".").last;
    String fileName = filenameoptional;
    // (isthumbnail == true
    //     ? 'Thumbnail-$timeEpoch$ext'
    //     : isVideo
    //         ? 'Video-$timeEpoch$ext'
    //         : 'IMG-$timeEpoch$ext');
    // isthumbnail == false
    //     ? isVideo == true
    //         ? 'Video-$timeEpoch.mp4'
    //         : '$timeEpoch'
    //     : '${timeEpoch}Thumbnail.png'
    // );
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);

    UploadTask uploading = reference.putData(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  key: _keyLoader34,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isVideo == true) {
      videometadata = jsonEncode({
        "width": 1080,
        "height": 1920,
        "orientation": null,
        "duration": 1000000000,
        "filesize": null,
        "author": null,
        "date": null,
        "framerate": null,
        "location": null,
        "path": null,
        "title": '',
        "mimetype": "video/mp4",
      }).toString();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      // MediaInfo mediaInfo = MediaInfo();

      // await mediaInfo.getMediaInfo(selectedFile).then((mediaInfo) {
      //   setStateIfMounted(() {
      //     videometadata = jsonEncode({
      //       "width": mediaInfo['width'],
      //       "height": mediaInfo['height'],
      //       "orientation": null,
      //       "duration": mediaInfo['durationMs'],
      //       "filesize": null,
      //       "author": null,
      //       "date": null,
      //       "framerate": null,
      //       "location": null,
      //       "path": null,
      //       "title": '',
      //       "mimetype": mediaInfo['mimeType'],
      //     }).toString();
      //   });
      // }).catchError((onError) {
      //   Lamat.toast(LocaleKeys.sendingFailed.tr());
      //   debugPrint('ERROR SENDING FILE: $onError');
      // });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile, bool isVideo, bool isthumbnail, int timeEpoch,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = filenameoptional ??
        (isthumbnail == true
            ? 'Thumbnail-$timeEpoch$ext'
            : isVideo
                ? 'Video-$timeEpoch$ext'
                : 'IMG-$timeEpoch$ext');
    // isthumbnail == false
    //     ? isVideo == true
    //         ? 'Video-$timeEpoch.mp4'
    //         : '$timeEpoch'
    //     : '${timeEpoch}Thumbnail.png'
    // );
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  key: _keyLoader34,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.dialogColorDark
                      : AppConstants.backgroundColor,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? LocaleKeys.generatingthumbnail.tr()
                                    : LocaleKeys.sending.tr(),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == true) {
      MediaInfo mediaInfo = MediaInfo();

      await mediaInfo.getMediaInfo(selectedFile.path).then((mediaInfo) {
        setStateIfMounted(() {
          videometadata = jsonEncode({
            "width": mediaInfo['width'],
            "height": mediaInfo['height'],
            "orientation": null,
            "duration": mediaInfo['durationMs'],
            "filesize": null,
            "author": null,
            "date": null,
            "framerate": null,
            "location": null,
            "path": null,
            "title": '',
            "mimetype": mediaInfo['mimeType'],
          }).toString();
        });
      }).catchError((onError) {
        Lamat.toast(LocaleKeys.sendingFailed.tr());
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  FocusNode keyboardFocusNode = FocusNode();
  Widget buildInputAndroid(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    Offset? offset;
    Offset? buttonPosition;
    // Offset? buttonPosition2;
    Offset? buttonPosition3;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox buttonBox =
          buttonKey.currentContext?.findRenderObject() as RenderBox;
      if (buttonBox.hasSize) {
        buttonPosition = buttonBox.localToGlobal(Offset.zero);
        offset = buttonPosition! + Offset(0, buttonBox.size.height);
      } else {
        offset = const Offset(0, 0);
      }
      // RenderBox buttonBox2 =
      //     buttonKey2.currentContext?.findRenderObject() as RenderBox;
      // if (buttonBox2.hasSize) {
      //   buttonPosition2 = buttonBox2.localToGlobal(Offset.zero);
      //   offset = buttonPosition2! + Offset(0, buttonBox2.size.height);
      // } else {
      //   offset = const Offset(0, 0);
      // }
      RenderBox buttonBox3 =
          buttonKey3.currentContext?.findRenderObject() as RenderBox;
      if (buttonBox3.hasSize) {
        buttonPosition3 = buttonBox3.localToGlobal(Offset.zero);
        offset = buttonPosition3! + Offset(0, buttonBox3.size.height);
      } else {
        offset = const Offset(0, 0);
      }
    });
    // RenderBox buttonBox =
    //     buttonKey.currentContext!.findRenderObject() as RenderBox;
    // Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);

    // // Adjust offset for desired placement above the button
    // Offset offset = buttonPosition + Offset(0, buttonBox.size.height);
    final observer = ref.read(observerProvider);
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.dialogColorDark
            : AppConstants.backgroundColor,
        elevation: 10.0,
        title: Text(
          '${LocaleKeys.acceptInv.tr()} ${peer![Dbkeys.nickname]} ?',
          style: TextStyle(
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.dialogColorDark
                    : AppConstants.backgroundColor),
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                LocaleKeys.rjt.tr(),
                style: TextStyle(
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.dialogColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              child: Text(LocaleKeys.accept.tr(),
                  style: const TextStyle(color: AppConstants.primaryColor)),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          isReplyKeyboard == true
              ? buildReplyMessageForInput(
                  context,
                )
              : const SizedBox(),
          Container(
            margin: EdgeInsets.only(
                bottom: !kIsWeb
                    ? Platform.isIOS == true
                        ? 20
                        : 0
                    : 20),
            width: double.infinity,
            height: 60.0,
            decoration: const BoxDecoration(
              // border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              color: Colors.transparent,
            ),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                    ),
                    decoration: const BoxDecoration(
                        color: AppConstants.lamatWhite,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: isMessageLoading == true
                                ? null
                                : () {
                                    refreshThisInput();
                                  },
                            icon: const Icon(
                              Icons.emoji_emotions,
                              size: 23,
                              color: AppConstants.lamatGrey,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: isMessageLoading == true
                                ? null
                                : () {
                                    if (isemojiShowing == true) {
                                    } else {
                                      keyboardFocusNode.requestFocus();
                                      setStateIfMounted(() {});
                                    }
                                  },
                            // onChanged: (string) {
                            //   debugPrint(string);

                            //   if (string.substring(string.length - 1) == '/') {
                            //     Lamat.toast(string);
                            //   }
                            //   //  setStateIfMounted(() {});
                            // },
                            showCursor: true,
                            focusNode: keyboardFocusNode,
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            style: const TextStyle(
                                fontSize: 16.0, color: AppConstants.lamatBlack),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              hoverColor: Colors.transparent,
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide: const BorderSide(
                                      color: Colors.transparent)),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 4, 7, 4),
                              hintText: LocaleKeys.msg.tr(),
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                            width: textEditingController.text.isNotEmpty
                                ? 10
                                : IsShowGIFsenderButtonByGIPHY == false
                                    ? 80
                                    : 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                textEditingController.text.isNotEmpty
                                    ? const SizedBox()
                                    : SizedBox(
                                        width: 30,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.attachment_outlined,
                                            color: AppConstants.lamatGrey,
                                          ),
                                          padding: const EdgeInsets.all(0.0),
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        LocaleKeys
                                                            .mediamssgnotallowed
                                                            .tr(),
                                                      );
                                                    }
                                                  : chatStatus ==
                                                          ChatStatus
                                                              .blocked.index
                                                      ? () {
                                                          Lamat.toast(
                                                            LocaleKeys.unlck
                                                                .tr(),
                                                          );
                                                        }
                                                      : () {
                                                          hidekeyboard(context);
                                                          shareMedia(context);
                                                        },
                                          color: AppConstants.lamatWhite,
                                        ),
                                      ),
                                textEditingController.text.isNotEmpty
                                    ? const SizedBox()
                                    : SizedBox(
                                        width: 30,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.camera_alt_rounded,
                                            size: 20,
                                            color: AppConstants.lamatGrey,
                                          ),
                                          padding: const EdgeInsets.all(0.0),
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        LocaleKeys
                                                            .mediamssgnotallowed
                                                            .tr(),
                                                      );
                                                    }
                                                  : chatStatus ==
                                                          ChatStatus
                                                              .blocked.index
                                                      ? () {
                                                          Lamat.toast(
                                                            LocaleKeys.unlck
                                                                .tr(),
                                                          );
                                                        }
                                                      : () async {
                                                          hidekeyboard(context);
                                                          !kIsWeb
                                                              ? await Navigator
                                                                  .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                AllinOneCameraGalleryImageVideoPicker(
                                                                          prefs:
                                                                              widget.prefs,
                                                                          onTakeFile: (file,
                                                                              isVideo,
                                                                              thumnail) async {
                                                                            setStatusBarColor(widget.prefs);

                                                                            int timeStamp =
                                                                                DateTime.now().millisecondsSinceEpoch;
                                                                            if (isVideo ==
                                                                                true) {
                                                                              String videoFileext = p.extension(file.path);
                                                                              String videofileName = 'Video-$timeStamp$videoFileext';
                                                                              String? videoUrl = await uploadSelectedLocalFileWithProgressIndicator(file, true, false, timeStamp, filenameoptional: videofileName);
                                                                              if (videoUrl != null) {
                                                                                String? thumnailUrl = await uploadSelectedLocalFileWithProgressIndicator(thumnail!, false, true, timeStamp);
                                                                                if (thumnailUrl != null) {
                                                                                  onSendMessage(this.context, '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName', MessageType.video, timeStamp);
                                                                                  await file.delete();
                                                                                  await thumnail.delete();
                                                                                }
                                                                              }
                                                                            } else {
                                                                              String imageFileext = p.extension(file.path);
                                                                              String imagefileName = 'IMG-$timeStamp$imageFileext';
                                                                              String? url = await uploadSelectedLocalFileWithProgressIndicator(file, false, false, timeStamp, filenameoptional: imagefileName);
                                                                              if (url != null) {
                                                                                onSendMessage(this.context, url, MessageType.image, timeStamp);
                                                                                await file.delete();
                                                                              }
                                                                            }
                                                                          },
                                                                          onTakeFileWeb: (file,
                                                                              isVideo,
                                                                              filname) async {
                                                                            setStatusBarColor(widget.prefs);

                                                                            int timeStamp =
                                                                                DateTime.now().millisecondsSinceEpoch;
                                                                            if (isVideo ==
                                                                                true) {
                                                                              // String videoFileext =
                                                                              //     p.extension(file.path);
                                                                              String videofileName = 'Video-$timeStamp$filname';
                                                                              String? videoUrl = await uploadSelectedLocalFileWithProgressIndicatorWeb(file, true, false, timeStamp, filname);
                                                                              if (videoUrl != null) {
                                                                                // String? thumnailUrl =
                                                                                //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                                                //         filname!,
                                                                                //         false,
                                                                                //         true,
                                                                                //         timeStamp);

                                                                                onSendMessage(this.context, '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName', MessageType.video, timeStamp);
                                                                                // await file.delete();
                                                                                // await thumnail.delete();
                                                                              }
                                                                            } else {
                                                                              // String imageFileext =
                                                                              //     p.extension(file.path);
                                                                              String imagefileName = filname;
                                                                              String? url = await uploadSelectedLocalFileWithProgressIndicatorWeb(file, false, false, timeStamp, imagefileName);
                                                                              if (url != null) {
                                                                                onSendMessage(this.context, url, MessageType.image, timeStamp);
                                                                                // await file.delete();
                                                                              }
                                                                            }
                                                                          },
                                                                        ),
                                                                      ))
                                                              : await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => CameraWebHome(
                                                                            prefs:
                                                                                widget.prefs,
                                                                            onTakeFileWeb: (file,
                                                                                isVideo,
                                                                                filname,
                                                                                videoData) async {
                                                                              setStatusBarColor(widget.prefs);

                                                                              int timeStamp = DateTime.now().millisecondsSinceEpoch;
                                                                              if (isVideo == true) {
                                                                                // String videoFileext =
                                                                                //     p.extension(file.path);
                                                                                String videofileName = 'Video-$timeStamp$filname';
                                                                                String? videoUrl = await uploadSelectedLocalFileWithProgressIndicatorWeb(file, true, false, timeStamp, filname);
                                                                                if (videoUrl != null) {
                                                                                  // String? thumnailUrl =
                                                                                  //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                                                  //         filname!,
                                                                                  //         false,
                                                                                  //         true,
                                                                                  //         timeStamp);

                                                                                  onSendMessage(this.context, '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName', MessageType.video, timeStamp);
                                                                                  // await file.delete();
                                                                                  // await thumnail.delete();
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              } else {
                                                                                // String imageFileext =
                                                                                //     p.extension(file.path);
                                                                                String imagefileName = filname;
                                                                                String? url = await uploadSelectedLocalFileWithProgressIndicatorWeb(file, false, false, timeStamp, imagefileName);
                                                                                if (url != null) {
                                                                                  onSendMessage(this.context, url, MessageType.image, timeStamp);
                                                                                  // await file.delete();
                                                                                }
                                                                                Navigator.pop(context);
                                                                              }
                                                                            },
                                                                          )));
                                                        },
                                          color: AppConstants.lamatWhite,
                                        ),
                                      ),
                                textEditingController.text.isNotEmpty ||
                                        IsShowGIFsenderButtonByGIPHY == false
                                    ? const SizedBox(
                                        width: 0,
                                      )
                                    : Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5),
                                        height: 35,
                                        alignment: Alignment.topLeft,
                                        width: 40,
                                        child: IconButton(
                                            color: AppConstants.lamatWhite,
                                            padding: const EdgeInsets.all(0.0),
                                            icon: const Icon(
                                              Icons.gif_rounded,
                                              size: 40,
                                              color: AppConstants.lamatGrey,
                                            ),
                                            onPressed: isMessageLoading == true
                                                ? null
                                                : observer.ismediamessagingallowed ==
                                                        false
                                                    ? () {
                                                        Lamat.showRationale(
                                                          LocaleKeys
                                                              .mediamssgnotallowed
                                                              .tr(),
                                                        );
                                                      }
                                                    : () async {
                                                        GiphyGif? gif =
                                                            await GiphyGet
                                                                .getGif(
                                                          tabColor: AppConstants
                                                              .primaryColor,

                                                          context: context,
                                                          apiKey:
                                                              GiphyAPIKey, //YOUR API KEY HERE
                                                          lang: GiphyLanguage
                                                              .english,
                                                        );
                                                        if (gif != null &&
                                                            mounted) {
                                                          onSendMessage(
                                                              context,
                                                              gif
                                                                  .images!
                                                                  .original!
                                                                  .url,
                                                              MessageType.image,
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch);
                                                          hidekeyboard(context);
                                                          setStateIfMounted(
                                                              () {});
                                                        }
                                                      }),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),

                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 6, right: 10),
                  decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CustomButton(
                      key: buttonKey,
                      child: WebsafeSvg.asset(
                        height: 36,
                        width: 36,
                        fit: BoxFit.fitHeight,
                        giftIcon,
 colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),                      ),
                      onPressed: () {
                        hidekeyboard(context);

                        showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return GiftSheet(
                              onAddDymondsTap: onAddDymondsTap,
                              onGiftSend: (gift) {
                                EasyLoading.show(
                                    status: LocaleKeys.sendinggift.tr());

                                int value = gift!.coinPrice!;
                                uploadTimestamp =
                                    DateTime.now().millisecondsSinceEpoch;
                                sendGiftProvider(
                                    giftCost: value,
                                    recipientId: widget.peerNo!);
                                // print("${gift.coinPrice}");
                                onSendMessage(context, gift.image!,
                                    MessageType.image, uploadTimestamp);

                                // onCommentSend(
                                //     commentType: FirebaseConst.image, msg: gift.image ?? '');
                                Future.delayed(const Duration(seconds: 3), () {
                                  EasyLoading.dismiss();
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      // color: AppConstants.lamatWhite,
                    ),
                  ),
                ),

                // Button send message
                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 6, right: 10),
                  decoration: const BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      key: buttonKey3,
                      icon: textInSendButton == ""
                          ? Icon(
                              textEditingController.text.isEmpty
                                  ? Icons.mic
                                  : Icons.send,
                              color: AppConstants.lamatWhite.withOpacity(0.99),
                            )
                          : textEditingController.text.isEmpty
                              ? Icon(
                                  Icons.mic,
                                  color:
                                      AppConstants.lamatWhite.withOpacity(0.99),
                                )
                              : const Text(
                                  textInSendButton,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: isMessageLoading == true
                          ? null
                          : observer.ismediamessagingallowed == true
                              ? textEditingController.text.isEmpty
                                  ? () {
                                      hidekeyboard(context);

                                      showModalBottomSheet(
                                        context: context,
                                        // barrierDismissible: true,
                                        builder: (context) => AudioRecord(
                                          prefs: widget.prefs,
                                          title: LocaleKeys.record.tr(),
                                          callback: getFileData,
                                        ),
                                        backgroundColor:
                                            AppConstants.primaryColor,
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3,
                                        ),
                                        barrierColor: Colors
                                            .transparent, // Optional: semi-transparent background
                                        useSafeArea: true,
                                        routeSettings: RouteSettings(
                                          // Pass the offset to the popup content
                                          arguments: offset,
                                        ),
                                      ).then((url) {
                                        if (url != null) {
                                          uploadTimestamp = DateTime.now()
                                              .millisecondsSinceEpoch;
                                          onSendMessage(
                                              context,
                                              url +
                                                  '-BREAK-' +
                                                  uploadTimestamp.toString(),
                                              MessageType.audio,
                                              uploadTimestamp);
                                        } else {}
                                      });

                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => AudioRecord(
                                      //               prefs: widget.prefs,
                                      //               title: "Record Audio",
                                      //               callback: getFileData,
                                      //             ))).then((url) {
                                      //   if (url != null) {
                                      //     onSendMessage(
                                      //         context,
                                      //         url +
                                      //             '-BREAK-' +
                                      //             uploadTimestamp.toString(),
                                      //         MessageType.audio,
                                      //         uploadTimestamp);
                                      //   } else {}
                                      // });
                                    }
                                  : observer.istextmessagingallowed == false
                                      ? () {
                                          Lamat.showRationale(
                                            LocaleKeys.textmssgnotallowed.tr(),
                                          );
                                        }
                                      : chatStatus == ChatStatus.blocked.index
                                          ? null
                                          : () => onSendMessage(
                                              context,
                                              textEditingController.text,
                                              MessageType.text,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch)
                              : () {
                                  Lamat.showRationale(
                                    LocaleKeys.mediamssgnotallowed.tr(),
                                  );
                                },
                      color: AppConstants.lamatWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          isemojiShowing == true && keyboardVisible == false
              ? Offstage(
                  offstage: !isemojiShowing,
                  child: SizedBox(
                    height: 300,
                    child: emojipic.EmojiPicker(
                        onEmojiSelected:
                            (emojipic.Category? category, emojipic.Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: emojipic.Config(
                          checkPlatformCompatibility: true,
        emojiViewConfig: emojipic.EmojiViewConfig(
        // Issue: https://github.com/flutter/flutter/issues/28894
        emojiSizeMax: 28 *
        (defaultTargetPlatform == TargetPlatform.iOS
            ?  1.20
            :  1.0),
        ),
        swapCategoryAndBottomBar:  false,
        skinToneConfig: const emojipic.SkinToneConfig(),
        categoryViewConfig: const emojipic.CategoryViewConfig(),
        bottomActionBarConfig: const emojipic.BottomActionBarConfig(),
        searchViewConfig: const emojipic.SearchViewConfig(),
                          // columns: 7,
                          // emojiSizeMax: 32 *
                          //     (f.defaultTargetPlatform == TargetPlatform.iOS
                          //         ? 1.30
                          //         : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                          // verticalSpacing: 0,
                          // horizontalSpacing: 0,
                          // gridPadding: EdgeInsets.zero,
                          // initCategory: emojipic.Category.RECENT,
                          // bgColor: AppConstants.backgroundColor,
                          // indicatorColor: AppConstants.primaryColor,
                          // iconColor: Colors.grey,
                          // iconColorSelected: AppConstants.primaryColor,
                          // backspaceColor: AppConstants.primaryColor,
                          // skinToneDialogBgColor: Colors.white,
                          // skinToneIndicatorColor: Colors.grey,
                          // enableSkinTones: true,
                          // recentTabBehavior: RecentTabBehavior.RECENT,
                          // recentsLimit: 28,
                          // noRecents: Text(
                          //   LocaleKeys.noRecents.tr(),
                          //   style: const TextStyle(
                          //       fontSize: 20, color: Colors.black26),
                          //   textAlign: TextAlign.center,
                          // ), // Needs to be const Widget
                          // loadingIndicator: const SizedBox
                          //     .shrink(), // Needs to be const Widget
                          // tabIndicatorAnimDuration: kTabScrollDuration,
                          // categoryIcons: const CategoryIcons(),
                          // buttonMode: ButtonMode.MATERIAL,
                        )),
                  ),
                )
              : const SizedBox(),
        ]);
  }

  bool empty = true;

  void onAddDymondsTap(BuildContext context) {
    isPurchaseDialogOpen = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const DialogCoinsPlan();
      },
    ).then((value) {
      isPurchaseDialogOpen = false;
    });
  }

  loadMessagesAndListen() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .collection(chatId!)
        .orderBy(Dbkeys.timestamp)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        empty = false;

        for (final doci in docs.docs) {
          Map<String, dynamic> doc = Map.from(doci.data());
          int? ts = doc[Dbkeys.timestamp];

          try {
            doc[Dbkeys.content] = doc[Dbkeys.content];
            // AESEncryptData.decryptAES(
            //             doc[Dbkeys.content], sharedSecret)!
            //         .isNotEmpty
            //     ? AESEncryptData.decryptAES(doc[Dbkeys.content], sharedSecret)
            // :

            // decryptWithCRC(doc[Dbkeys.content]);

            messages.add(Message(buildMessage(this.context, doc),
                onDismiss:
                    doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null
                        ? () {}
                        : () {
                            setStateIfMounted(() {
                              isReplyKeyboard = true;
                              replyDoc = doc;
                            });
                            HapticFeedback.heavyImpact();
                            keyboardFocusNode.requestFocus();
                          },
                onTap: (doc[Dbkeys.from] == widget.currentUserNo &&
                            doc[Dbkeys.hasSenderDeleted] == true) ==
                        true
                    ? () {}
                    : doc[Dbkeys.messageType] == MessageType.image.index
                        ? () {
                            Navigator.push(
                                this.context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewWrapper(
                                    prefs: widget.prefs,
                                    keyloader: _keyLoader34,
                                    imageUrl: doc[Dbkeys.content],
                                    message: doc[Dbkeys.content],
                                    tag: ts.toString(),
                                    imageProvider: CachedNetworkImageProvider(
                                        doc[Dbkeys.content]),
                                  ),
                                ));
                          }
                        : null,
                onDoubleTap: doc.containsKey(Dbkeys.broadcastID)
                    ? () {}
                    : () {}, onLongPress: () {
              if (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                  doc.containsKey(Dbkeys.hasSenderDeleted)) {
                if ((doc[Dbkeys.from] == widget.currentUserNo &&
                        doc[Dbkeys.hasSenderDeleted] == true) ==
                    false) {
                  //--Show Menu only if message is not deleted by current user already
                  contextMenuNew(this.context, doc, false);
                }
              } else {
                contextMenuOld(this.context, doc);
              }
            }, from: doc[Dbkeys.from], timestamp: ts));

            if (doci.data()[Dbkeys.timestamp] ==
                docs.docs.last.data()[Dbkeys.timestamp]) {
              setStateIfMounted(() {
                isMessageLoading = false;
                isFirstMessage =
                    !messages.any((message) => message.from == currentUserNo);
                // debugPrint('All message loaded..........');
              });
            }
          } catch (e) {
            if (e.toString().contains('range')) {
              Lamat.toast(
                LocaleKeys.failedtoloadchat.tr(),
              );
              Navigator.of(this.context).pop();
            }
          }
        }
      } else {
        setStateIfMounted(() {
          isMessageLoading = false;
          isFirstMessage = true;
          // debugPrint('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          messages = List.from(messages);
        });
      }
      msgSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId!)
          .where(Dbkeys.from, isEqualTo: peerNo)
          .snapshots()
          .listen((query) {
        if (empty == true || query.docs.length != query.docChanges.length) {
          //----below action triggers when peer message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex &&
                doc.type == DocumentChangeType.added;

            //  &&
            //     query.docs[doc.oldIndex][Dbkeys.timestamp] !=
            //         query.docs[doc.newIndex][Dbkeys.timestamp];
          }).forEach((change) {
            Map<String, dynamic> doc = Map.from(change.doc.data()!);
            int? ts = doc[Dbkeys.timestamp];
            doc[Dbkeys.content] = doc[Dbkeys.content];
            // doc.containsKey(Dbkeys.latestEncrypted) ==
            //         true
            //     ? AESEncryptData.decryptAES(doc[Dbkeys.content], sharedSecret)
            //     :
            // decryptWithCRC(doc[Dbkeys.content]);

            messages.add(Message(
              buildMessage(this.context, doc),
              onDismiss:
                  doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onLongPress: () {
                if (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    doc.containsKey(Dbkeys.hasSenderDeleted)) {
                  if ((doc[Dbkeys.from] == widget.currentUserNo &&
                          doc[Dbkeys.hasSenderDeleted] == true) ==
                      false) {
                    //--Show Menu only if message is not deleted by current user already
                    contextMenuNew(this.context, doc, false);
                  }
                } else {
                  contextMenuOld(this.context, doc);
                }
              },
              onTap: (doc[Dbkeys.from] == widget.currentUserNo &&
                          doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  prefs: widget.prefs,
                                  keyloader: _keyLoader34,
                                  imageUrl: doc[Dbkeys.content],
                                  message: doc[Dbkeys.content],
                                  tag: ts.toString(),
                                  imageProvider: CachedNetworkImageProvider(
                                      doc[Dbkeys.content]),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: doc.containsKey(Dbkeys.broadcastID)
                  ? () {}
                  : () {
                      // save(_doc);
                    },
              from: doc[Dbkeys.from],
              timestamp: ts,
            ));
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            Map<String, dynamic> doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == doc[Dbkeys.timestamp]);
            if (i >= 0) messages.removeAt(i);
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            Map<String, dynamic> doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == doc[Dbkeys.timestamp]);
            if (i >= 0) {
              messages.removeAt(i);
              setStateIfMounted(() {});
              int? ts = doc[Dbkeys.timestamp];
              doc[Dbkeys.content] = doc[Dbkeys.content];
              // doc.containsKey(Dbkeys.latestEncrypted) ==
              //         true
              //     ? AESEncryptData.decryptAES(doc[Dbkeys.content], sharedSecret)
              //     :
              // decryptWithCRC(doc[Dbkeys.content]);
              messages.insert(
                  i,
                  Message(
                    buildMessage(this.context, doc),
                    onLongPress: () {
                      if (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                          doc.containsKey(Dbkeys.hasSenderDeleted)) {
                        if ((doc[Dbkeys.from] == widget.currentUserNo &&
                                doc[Dbkeys.hasSenderDeleted] == true) ==
                            false) {
                          //--Show Menu only if message is not deleted by current user already
                          contextMenuNew(this.context, doc, false);
                        }
                      } else {
                        contextMenuOld(this.context, doc);
                      }
                    },
                    onTap: (doc[Dbkeys.from] == widget.currentUserNo &&
                                doc[Dbkeys.hasSenderDeleted] == true) ==
                            true
                        ? () {}
                        : doc[Dbkeys.messageType] == MessageType.image.index
                            ? () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoViewWrapper(
                                        prefs: widget.prefs,
                                        keyloader: _keyLoader34,
                                        imageUrl: doc[Dbkeys.content],
                                        message: doc[Dbkeys.content],
                                        tag: ts.toString(),
                                        imageProvider:
                                            CachedNetworkImageProvider(
                                                doc[Dbkeys.content]),
                                      ),
                                    ));
                              }
                            : null,
                    onDoubleTap: doc.containsKey(Dbkeys.broadcastID)
                        ? () {}
                        : () {
                            // save(_doc);
                          },
                    from: doc[Dbkeys.from],
                    timestamp: ts,
                    onDismiss:
                        doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null
                            ? () {}
                            : () {
                                setStateIfMounted(() {
                                  isReplyKeyboard = true;
                                  replyDoc = doc;
                                });
                                HapticFeedback.heavyImpact();
                                keyboardFocusNode.requestFocus();
                              },
                  ));
            }
          });
          if (mounted) {
            setStateIfMounted(() {
              messages = List.from(messages);
              isFirstMessage =
                  !messages.any((message) => message.from == currentUserNo);
            });
          }
        }
      });

      //----sharing intent action:

      if (widget.isSharingIntentForwarded == true) {
        if (widget.sharedText != null) {
          onSendMessage(this.context, widget.sharedText!, MessageType.text,
              DateTime.now().millisecondsSinceEpoch);
        } else if (widget.sharedFiles != null) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = true;
          });
          uploadEach(0);
        }
      }
    });
  }

  int currentUploadingIndex = 0;
  uploadEach(
    int index,
  ) async {
    File file = File(widget.sharedFiles![index].path);
    String fileName = file.path.split('/').last.toLowerCase();

    if (index >= widget.sharedFiles!.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await getFileData(
              File(widget.sharedFiles![index].path), isVideo, isAudio, isImage,
              timestamp: messagetime, totalFiles: widget.sharedFiles!.length)
          .then((imageUrl) async {
        if (imageUrl != null) {
          MessageType type = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? MessageType.image
              : fileName.contains('.mp4') || fileName.contains('.mov')
                  ? MessageType.video
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? MessageType.audio
                      : MessageType.doc;
          String? thumbnailurl;
          if (type == MessageType.video) {
            thumbnailurl = await getThumbnail(imageUrl);

            setStateIfMounted(() {});
          }
          uploadTimestamp = DateTime.now().millisecondsSinceEpoch;

          String finalUrl = fileName.contains('.png') ||
                  fileName.contains('.gif') ||
                  fileName.contains('.jpg') ||
                  fileName.contains('.jpeg') ||
                  fileName.contains('giphy')
              ? imageUrl
              : fileName.contains('.mp4') || fileName.contains('.mov')
                  ? imageUrl +
                      '-BREAK-' +
                      thumbnailurl +
                      '-BREAK-' +
                      videometadata
                  : fileName.contains('.mp3') || fileName.contains('.aac')
                      ? imageUrl + '-BREAK-' + uploadTimestamp.toString()
                      : imageUrl +
                          '-BREAK-' +
                          basename(pickedFile!.path).toString();
          onSendMessage(this.context, finalUrl, type, messagetime);
        }
      }).then((value) {
        if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
        } else {
          uploadEach(currentUploadingIndex + 1);
        }
      });
    }
  }

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerNo).then((msgDocs) {
        // ignore: unnecessary_null_comparison
        if (msgDocs != null) {
          setStateIfMounted(() {
            _savedMessageDocs = msgDocs;
          });
        }
      });
    }
  }

//-- GROUP BY DATE ---
  List<Widget> getGroupedMessages() {
    List<Widget> groupedMessages = List.from(<Widget>[]);
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      // return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
      return "${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).year}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).month}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).day}";
    }).forEach((when, actualMessages) {
      // debugPrint("whennnnn $when");
      List<String> li = when.split('-');
      var w = getWhen(DateTime(
          int.tryParse(li[0])!, int.tryParse(li[1])!, int.tryParse(li[2])!));
      groupedMessages.add(Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blue[50],
        label: Text(
          w,
          style: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 14),
        ),
      )));
      for (var msg in actualMessages) {
        count++;
        if (unread != 0 && (messages.length - count) == unread! - 1) {
          groupedMessages.add(Center(
              child: Chip(
            backgroundColor: Colors.blueGrey[50],
            label: Text(
              '$unread ${LocaleKeys.unread.tr()}',
              style: const TextStyle(color: Colors.black54),
            ),
          )));
          unread = 0; // reset
        }
        groupedMessages.add(msg.child);
      }
    });
    return groupedMessages.reversed.toList();
  }

  Widget buildMessages(
    BuildContext context,
  ) {
    return Flexible(
        child: chatId == ''
            ? ListView(
                controller: realtime,
                children: <Widget>[
                  const Card(),
                  Padding(
                      padding: const EdgeInsets.only(top: 200.0),
                      child: isMessageLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConstants.secondaryColor)),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                  color: Teme.isDarktheme(widget.prefs)
                                      ? Colors.blueGrey
                                      : AppConstants.secondaryColor,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(
                                        AppConstants.defaultNumericValue),
                                  )),
                              child: Text(LocaleKeys.sayhi.tr(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18)))),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(10.0),
                controller: realtime,
                reverse: true,
                children: getGroupedMessages(),
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day) {
      when = LocaleKeys.today.tr();
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      when = LocaleKeys.yesterday.tr();
    } else {
      when = IsShowNativeTimDate == true
          ? '${DateFormat.MMMM().format(date)} ${DateFormat.d().format(date)}'
          : when = DateFormat.MMMd().format(date);
    }
    return when;
  }

  getPeerStatus(val) {
    final observer = ref.read(observerProvider);
    if (val is bool && val == true) {
      return LocaleKeys.online.tr();
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = observer.is24hrsTimeformat == false
              ? DateFormat.jm().format(date)
              : DateFormat('HH:mm').format(date),
          when = getWhen(date);
      return '${LocaleKeys.lastseen.tr()} $when, $at';
    } else if (val is String) {
      if (val == currentUserNo) return LocaleKeys.typing.tr();
      return LocaleKeys.online.tr();
    }
    return LocaleKeys.loading.tr();
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index;
  }

  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        prefs: widget.prefs,
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: peer![Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.peerNo,
        toFullname: peer![Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        // hidekeyboard(this.context);
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  showDialOptions(BuildContext context) {
    final observer = ref.read(observerProvider);
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
          return Container(
              padding: const EdgeInsets.all(12),
              height: 130,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: observer.iscallsallowed == false
                          ? () {
                              Navigator.of(this.context).pop();
                              Lamat.showRationale(
                                LocaleKeys.callnotallowed.tr(),
                              );
                            }
                          : hasPeerBlockedMe == true
                              ? () {
                                  Navigator.of(this.context).pop();
                                  Lamat.toast(
                                    LocaleKeys.userhasblocked.tr(),
                                  );
                                }
                              : () async {
                                  await Permissions
                                          .cameraAndMicrophonePermissionsGranted()
                                      .then((isgranted) async {
                                    if (isgranted == true || kIsWeb) {
                                      await minusBalanceProvider(
                                              ref, AppRes.msgCost)
                                          .then((value) {
                                        call(this.context, false);
                                      });
                                    } else {
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
                                    }
                                  }).onError((e, trace) {
                                    debugPrint(
                                        "Call Error: ${trace.toString()}");

                                    EasyLoading.showError(trace.toString(),
                                        duration: const Duration(hours: 1));
                                  });
                                },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 13),
                            const Icon(
                              Icons.local_phone,
                              size: 35,
                              color: AppConstants.primaryColor,
                            ),
                            const SizedBox(height: 13),
                            Text(
                              LocaleKeys.audiocall.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.dialogColorDark
                                          : AppConstants.backgroundColor)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: observer.iscallsallowed == false
                            ? () {
                                Navigator.of(this.context).pop();
                                Lamat.showRationale(
                                  LocaleKeys.callnotallowed.tr(),
                                );
                              }
                            : hasPeerBlockedMe == true
                                ? () {
                                    Navigator.of(this.context).pop();
                                    Lamat.toast(
                                      LocaleKeys.userhasblocked.tr(),
                                    );
                                  }
                                : () async {
                                    await Permissions
                                            .cameraAndMicrophonePermissionsGranted()
                                        .then((isgranted) async {
                                      if (isgranted == true || kIsWeb) {
                                        await minusBalanceProvider(
                                                ref, AppRes.msgCost)
                                            .then((value) {
                                          call(this.context, true);
                                        });
                                      } else {
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
                                      }
                                    }).onError((e, trace) {
                                      debugPrint(
                                          "Call Error: ${trace.toString()}");

                                      EasyLoading.showError(trace.toString(),
                                          duration: const Duration(hours: 1));
                                    });
                                  },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 13),
                              const Icon(
                                Icons.videocam,
                                size: 39,
                                color: AppConstants.primaryColor,
                              ),
                              const SizedBox(height: 13),
                              Text(
                                LocaleKeys.videocall.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.dialogColorDark
                                            : AppConstants.backgroundColor)),
                              ),
                            ],
                          ),
                        ))
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);
    var currentpeer = ref.watch(currentChatPeerProviderProvider);
    final availableContacts = ref.watch(smartContactProvider);
    var keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    final otherUserProfile =
        ref.watch(otherUserProfileFutureProvider(widget.peerNo!));

    UserProfileModel? otherUserProfileModel;

    otherUserProfile.when(
        data: (userProfile) {
          otherUserProfileModel = userProfile;
        },
        error: (_, __) => {},
        loading: () => {});
    final walletAsyncValue = ref.watch(walletsStreamProvider);

    return walletAsyncValue.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          ref.read(createNewWalletProvider);
          ref.refresh(walletsStreamProvider).value;
          return const Center(child: CircularProgressIndicator());
        } else {
          setState(() {
            wallet = WalletsModel.fromMap(
                snapshot.docs.first.data() as Map<String, dynamic>);
            AppRes.walletBalance = wallet!.balance;
          });

          return PickupLayout(
            prefs: widget.prefs,
            scaffold: Lamat.getNTPWrappedWidget(WillPopScope(
                onWillPop: isgeneratingSomethingLoader == true
                    ? () async {
                        return Future.value(false);
                      }
                    : isemojiShowing == true
                        ? () {
                            setState(() {
                              isemojiShowing = false;
                              keyboardFocusNode.unfocus();
                            });
                            return Future.value(false);
                          }
                        : () async {
                            setLastSeen();
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) async {
                              currentpeer.setpeer(newpeerid: '');
                              if (lastSeen == peerNo) {
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(currentUserNo)
                                    .update(
                                  {Dbkeys.lastSeen: true},
                                );
                              }
                            });

                            return Future.value(true);
                          },
                child: ScopedModel<DataModel>(
                    model: _cachedModel,
                    child: ScopedModelDescendant<DataModel>(
                        builder: (context, child, model) {
                      _cachedModel = model;
                      updateLocalUserData(model);
                      return peer != null
                          ? peer![Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted
                              ? Scaffold(
                                  backgroundColor:
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.chatBackground,
                                  appBar: AppBar(
                                      backgroundColor:
                                          Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                      elevation: 0,
                                      leading: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16, right: 20),
                                        child: CustomIconButton(
                                            padding: const EdgeInsets.all(
                                                AppConstants
                                                        .defaultNumericValue /
                                                    1.8),
                                            onPressed: () {
                                              (!Responsive.isDesktop(context))
                                                  ? {Navigator.pop(context)}
                                                  : ref.invalidate(
                                                      arrangementProviderExtend);
                                            },
                                            color: AppConstants.primaryColor,
                                            icon: leftArrowSvg),
                                      )),
                                  body: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        const SizedBox(
                                          height: 38,
                                        ),
                                        Text(
                                          LocaleKeys.userDeleted.tr(),
                                          style: TextStyle(
                                              color:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants.lamatWhite
                                                      : AppConstants
                                                          .lamatBlack),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    Scaffold(
                                        key: _scaffold,
                                        appBar: AppBar(
                                          elevation: 0,
                                          titleSpacing: -14,
                                          leading: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 14),
                                              child: InkWell(
                                                // onPressed: () => Navigator.pop(context),
                                                // color: AppConstants.primaryColor,
                                                child: WebsafeSvg.asset(
                                                    leftArrowSvg,
                                                   colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),  
                                                    width: 20,
                                                    height: 20,
                                                    fit: BoxFit.contain),
                                                onTap: () async {
                                                  if (isDeletedDoc == true) {
                                                    (!Responsive.isDesktop(
                                                            context))
                                                        ? await Restart
                                                            .restartApp()
                                                        : ref.invalidate(
                                                            arrangementProviderExtend);
                                                  } else {
                                                    (!Responsive.isDesktop(
                                                            context))
                                                        ? Navigator.pop(context)
                                                        : ref.invalidate(
                                                            arrangementProviderExtend);
                                                  }
                                                },
                                              )),
                                          backgroundColor: Teme.isDarktheme(
                                                  widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                          title: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: InkWell(
                                                onLongPress: () {
                                                  showModalBottomSheet(
                                                      backgroundColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        25.0)),
                                                      ),
                                                      builder: (context) =>
                                                          Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const SizedBox(
                                                                  height: AppConstants
                                                                      .defaultNumericValue,
                                                                ),
                                                                Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    // mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      const SizedBox(
                                                                        width: AppConstants
                                                                            .defaultNumericValue,
                                                                      ),
                                                                      InkWell(
                                                                          onTap:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              WebsafeSvg.asset(
                                                                            closeIcon,
                                                                             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,), 
                                                                            height:
                                                                                32,
                                                                            width:
                                                                                32,
                                                                          )),
                                                                      SizedBox(
                                                                        width: width *
                                                                            .3,
                                                                      ),
                                                                      Container(
                                                                          width: AppConstants.defaultNumericValue *
                                                                              3,
                                                                          height:
                                                                              4,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(16),
                                                                            color:
                                                                                AppConstants.hintColor,
                                                                          )),
                                                                    ]),
                                                                const SizedBox(
                                                                  width: AppConstants
                                                                      .defaultNumericValue,
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      LocaleKeys
                                                                          .options
                                                                          .tr(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleLarge!
                                                                          .copyWith(
                                                                              fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height:
                                                                        AppConstants.defaultNumericValue /
                                                                            2),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    // Handle tap action for unmuting or muting
                                                                    if (isCurrentUserMuted) {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(DbPaths
                                                                              .collectionmessages)
                                                                          .doc(Lamat.getChatId(
                                                                              currentUserNo!,
                                                                              peerNo!))
                                                                          .update({
                                                                        "$currentUserNo-muted":
                                                                            !isCurrentUserMuted,
                                                                      });
                                                                      setStateIfMounted(
                                                                          () {
                                                                        isCurrentUserMuted =
                                                                            !isCurrentUserMuted;
                                                                      });
                                                                    } else {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(DbPaths
                                                                              .collectionmessages)
                                                                          .doc(Lamat.getChatId(
                                                                              currentUserNo!,
                                                                              peerNo!))
                                                                          .update({
                                                                        "$currentUserNo-muted":
                                                                            !isCurrentUserMuted,
                                                                      });
                                                                      setStateIfMounted(
                                                                          () {
                                                                        isCurrentUserMuted =
                                                                            !isCurrentUserMuted;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      isCurrentUserMuted
                                                                          ? LocaleKeys
                                                                              .unmute
                                                                              .tr()
                                                                          : LocaleKeys
                                                                              .mute
                                                                              .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),

                                                                // Similar GestureDetector and ListTile structures for other options
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    deleteAllChats();
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      LocaleKeys
                                                                          .deleteallchats
                                                                          .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),

                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (hidden) {
                                                                      ChatController.unhideChat(
                                                                          currentUserNo,
                                                                          peerNo);
                                                                    } else {
                                                                      ChatController.hideChat(
                                                                          currentUserNo,
                                                                          peerNo);
                                                                    }
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      hidden
                                                                          ? LocaleKeys
                                                                              .unhidechat
                                                                              .tr()
                                                                          : LocaleKeys
                                                                              .hidechat
                                                                              .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (locked) {
                                                                      ChatController.unlockChat(
                                                                          currentUserNo,
                                                                          peerNo);
                                                                    } else {
                                                                      if (widget.prefs.getString(Dbkeys.isPINsetDone) !=
                                                                              currentUserNo ||
                                                                          widget.prefs.getString(Dbkeys.isPINsetDone) ==
                                                                              null) {
                                                                        unawaited(Navigator.push(
                                                                            this.context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => Security(
                                                                                      currentUserNo,
                                                                                      prefs: widget.prefs,
                                                                                      setPasscode: true,
                                                                                      onSuccess: (newContext) async {
                                                                                        ChatController.lockChat(currentUserNo, peerNo);
                                                                                        Navigator.pop(context);
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      title: LocaleKeys.authh.tr(),
                                                                                    ))));
                                                                      } else {
                                                                        ChatController.lockChat(
                                                                            currentUserNo,
                                                                            peerNo);
                                                                        Navigator.pop(
                                                                            context);
                                                                      }
                                                                    }
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      locked
                                                                          ? LocaleKeys
                                                                              .unlockchat
                                                                              .tr()
                                                                          : LocaleKeys
                                                                              .lockchat
                                                                              .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (isBlocked()) {
                                                                      ChatController.accept(
                                                                          currentUserNo,
                                                                          peerNo);
                                                                    } else {
                                                                      ChatController.block(
                                                                          currentUserNo,
                                                                          peerNo);
                                                                    }
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      isBlocked()
                                                                          ? LocaleKeys
                                                                              .unblockchat
                                                                              .tr()
                                                                          : LocaleKeys
                                                                              .blockchat
                                                                              .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                peer![Dbkeys.wallpaper] !=
                                                                        null
                                                                    ? GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          _cachedModel
                                                                              .removeWallpaper(peerNo!);
                                                                        },
                                                                        child:
                                                                            ListTile(
                                                                          title:
                                                                              Text(
                                                                            LocaleKeys.removewall.tr(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                            ),
                                                                          ),
                                                                          tileColor:
                                                                              Colors.transparent,
                                                                        ),
                                                                      )
                                                                    : GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => SingleImagePicker(
                                                                                        prefs: widget.prefs,
                                                                                        title: LocaleKeys.pickimage.tr(),
                                                                                        callback: getWallpaper,
                                                                                      )));
                                                                        },
                                                                        child:
                                                                            ListTile(
                                                                          title:
                                                                              Text(
                                                                            LocaleKeys.setwall.tr(),
                                                                            style:
                                                                                TextStyle(
                                                                              color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                            ),
                                                                          ),
                                                                          tileColor:
                                                                              Colors.transparent,
                                                                        ),
                                                                      ),
                                                                GestureDetector(
                                                                  onTap: () => {
                                                                    showModalBottomSheet(
                                                                        backgroundColor: Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants
                                                                                .dialogColorDark
                                                                            : AppConstants
                                                                                .backgroundColor,
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        shape:
                                                                            const RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                        ),
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          // return your layout
                                                                          var w = MediaQuery.of(context)
                                                                              .size
                                                                              .width;
                                                                          return Padding(
                                                                            padding:
                                                                                EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                            child: Container(
                                                                                padding: const EdgeInsets.all(16),
                                                                                height: MediaQuery.of(context).size.height / 2.6,
                                                                                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                                                                  const SizedBox(
                                                                                    height: 12,
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 3,
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 7),
                                                                                    child: Text(
                                                                                      LocaleKeys.reportshort.tr(),
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor), fontWeight: FontWeight.bold, fontSize: 16.5),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 10,
                                                                                  ),
                                                                                  Container(
                                                                                    margin: const EdgeInsets.only(top: 10),
                                                                                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                    // height: 63,
                                                                                    height: 63,
                                                                                    width: w / 1.24,
                                                                                    child: InpuTextBox(
                                                                                      isDark: Teme.isDarktheme(widget.prefs),
                                                                                      controller: reportEditingController,
                                                                                      leftrightmargin: 0,
                                                                                      showIconboundary: false,
                                                                                      boxcornerradius: 5.5,
                                                                                      boxheight: 50,
                                                                                      hinttext: LocaleKeys.reportdesc.tr(),
                                                                                      prefixIconbutton: Icon(
                                                                                        Icons.message,
                                                                                        color: Colors.grey.withOpacity(0.5),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: w / 10,
                                                                                  ),
                                                                                  myElevatedButton(
                                                                                      color: AppConstants.primaryColor,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                                        child: Text(
                                                                                          LocaleKeys.report.tr(),
                                                                                          style: const TextStyle(color: Colors.white, fontSize: 18),
                                                                                        ),
                                                                                      ),
                                                                                      onPressed: () async {
                                                                                        Navigator.of(context).pop();

                                                                                        DateTime time = DateTime.now();

                                                                                        Map<String, dynamic> mapdata = {
                                                                                          'title': 'report by User',
                                                                                          'desc': reportEditingController.text,
                                                                                          'phone': '${widget.currentUserNo}',
                                                                                          'type': 'Individual Chat',
                                                                                          'time': time.millisecondsSinceEpoch,
                                                                                          'id': Lamat.getChatId(currentUserNo!, peerNo!),
                                                                                        };

                                                                                        await FirebaseFirestore.instance.collection('reports').doc(time.millisecondsSinceEpoch.toString()).set(mapdata).then((value) async {
                                                                                          showModalBottomSheet(
                                                                                              backgroundColor: Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor,
                                                                                              isScrollControlled: true,
                                                                                              context: context,
                                                                                              shape: const RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                              ),
                                                                                              builder: (BuildContext context) {
                                                                                                return SizedBox(
                                                                                                  height: 220,
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(28.0),
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        const Icon(Icons.check, color: AppConstants.lamatGreenColor400, size: 40),
                                                                                                        const SizedBox(
                                                                                                          height: 30,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          LocaleKeys.reportsuccess.tr(),
                                                                                                          textAlign: TextAlign.center,
                                                                                                          style: TextStyle(
                                                                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor),
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              });

                                                                                          //----
                                                                                        }).catchError((err) {
                                                                                          showModalBottomSheet(
                                                                                              backgroundColor: Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor,
                                                                                              isScrollControlled: true,
                                                                                              context: this.context,
                                                                                              shape: const RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                              ),
                                                                                              builder: (BuildContext context) {
                                                                                                return SizedBox(
                                                                                                  height: 220,
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(28.0),
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        const Icon(Icons.check, color: AppConstants.lamatGreenColor400, size: 40),
                                                                                                        const SizedBox(
                                                                                                          height: 30,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          LocaleKeys.reportsuccess.tr(),
                                                                                                          textAlign: TextAlign.center,
                                                                                                          style: TextStyle(
                                                                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor),
                                                                                                          ),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                );
                                                                                              });
                                                                                        });
                                                                                      }),
                                                                                ])),
                                                                          );
                                                                        })
                                                                  },
                                                                  child:
                                                                      ListTile(
                                                                    title: Text(
                                                                      LocaleKeys
                                                                          .report
                                                                          .tr(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      ),
                                                                    ),
                                                                    tileColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: AppConstants
                                                                          .defaultNumericValue *
                                                                      2,
                                                                )
                                                              ]));
                                                },
                                                onTap: () async {
                                                  !Responsive.isDesktop(context)
                                                      ? await Navigator.push(
                                                          context,
                                                          CupertinoPageRoute(
                                                            builder: (context) =>
                                                                UserDetailsPage(
                                                              user:
                                                                  otherUserProfileModel!,
                                                            ),
                                                          ),
                                                        )
                                                      : ref
                                                          .read(
                                                              arrangementProvider
                                                                  .notifier)
                                                          .setArrangement(
                                                              UserDetailsPage(
                                                            user:
                                                                otherUserProfileModel!,
                                                          ));
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    IsShowUserFullNameAsSavedInYourContacts ==
                                                            true
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    0, 7, 0, 7),
                                                            child: FutureBuilder<
                                                                    LocalUserData?>(
                                                                future: availableContacts
                                                                    .fetchUserDataFromnLocalOrServer(
                                                                        widget
                                                                            .prefs,
                                                                        widget
                                                                            .peerNo!),
                                                                builder: (BuildContext
                                                                        context,
                                                                    AsyncSnapshot<
                                                                            LocalUserData?>
                                                                        snapshot) {
                                                                  if (snapshot
                                                                          .hasData &&
                                                                      snapshot.data !=
                                                                          null) {
                                                                    return Lamat.avatar(
                                                                        peer,
                                                                        radius:
                                                                            20,
                                                                        predefinedinitials: Lamat.getInitials(snapshot
                                                                            .data!
                                                                            .name));
                                                                  }
                                                                  return Lamat
                                                                      .avatar(
                                                                          peer,
                                                                          radius:
                                                                              20);
                                                                }),
                                                          )
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    0, 7, 0, 7),
                                                            child: Lamat.avatar(
                                                                peer,
                                                                radius: 20),
                                                          ),
                                                    const SizedBox(
                                                      width: 7,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      this.context)
                                                                  .size
                                                                  .width /
                                                              2.3,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IsShowUserFullNameAsSavedInYourContacts ==
                                                                      true
                                                                  ? FutureBuilder<
                                                                          LocalUserData?>(
                                                                      future: availableContacts.fetchUserDataFromnLocalOrServer(
                                                                          widget
                                                                              .prefs,
                                                                          widget
                                                                              .peerNo!),
                                                                      builder: (BuildContext
                                                                              context,
                                                                          AsyncSnapshot<LocalUserData?>
                                                                              snapshot) {
                                                                        if (snapshot.hasData &&
                                                                            snapshot.data !=
                                                                                null) {
                                                                          return Text(
                                                                            snapshot.data!.name,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            maxLines:
                                                                                1,
                                                                            style: TextStyle(
                                                                                color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                fontSize: 17.0,
                                                                                fontWeight: FontWeight.w500),
                                                                          );
                                                                        }
                                                                        return Text(
                                                                          Lamat.getNickname(
                                                                              peer!)!,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                              fontSize: 17.0,
                                                                              fontWeight: FontWeight.w500),
                                                                        );
                                                                      })
                                                                  : Text(
                                                                      Lamat.getNickname(
                                                                          peer!)!,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      style: TextStyle(
                                                                          color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                              ? AppConstants
                                                                                  .backgroundColorDark
                                                                              : AppConstants
                                                                                  .backgroundColor),
                                                                          fontSize:
                                                                              17.0,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                              otherUserProfileModel!
                                                                      .isVerified
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        EasyLoading.showToast(LocaleKeys
                                                                            .verifiedUser
                                                                            .tr());
                                                                      },
                                                                      child:
                                                                          const Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue * .5),
                                                                        child:
                                                                            Image(
                                                                          image:
                                                                              AssetImage(verifiedIcon),
                                                                          width:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              isCurrentUserMuted
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5.0),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .volume_off,
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                                ? AppConstants.backgroundColorDark
                                                                                : AppConstants.backgroundColor)
                                                                            .withOpacity(0.5),
                                                                        size:
                                                                            17,
                                                                      ),
                                                                    )
                                                                  : const SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        chatId != null
                                                            ? Text(
                                                                getPeerStatus(
                                                                    peer![Dbkeys
                                                                        .lastSeen]),
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants
                                                                                .backgroundColorDark
                                                                            : AppConstants
                                                                                .backgroundColor)
                                                                        .withOpacity(
                                                                            0.9),
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )
                                                            : Text(
                                                                LocaleKeys
                                                                    .loading
                                                                    .tr(),
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants
                                                                                .backgroundColorDark
                                                                            : AppConstants
                                                                                .backgroundColor)
                                                                        .withOpacity(
                                                                            0.9),
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          actions: [
                                            observer.isCallFeatureTotallyHide ==
                                                        true ||
                                                    observer.isOngoingCall
                                                ? const SizedBox()
                                                : Row(children: [
                                                    SizedBox(
                                                        width: 45,
                                                        child: IconButton(
                                                          icon: WebsafeSvg.asset(
                                                              height: 25,
                                                              width: 25,
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              ellipsisIcon,
                                                             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),  ),
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                                backgroundColor: Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? AppConstants
                                                                        .backgroundColorDark
                                                                    : AppConstants
                                                                        .backgroundColor,
                                                                isScrollControlled:
                                                                    true,
                                                                context:
                                                                    context,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              25.0)),
                                                                ),
                                                                builder: (context) =>
                                                                    Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                AppConstants.defaultNumericValue,
                                                                          ),
                                                                          Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              // mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                const SizedBox(
                                                                                  width: AppConstants.defaultNumericValue,
                                                                                ),
                                                                                InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: WebsafeSvg.asset(
                                                                                      closeIcon,
                                                                                      colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,), 
                                                                                      height: 32,
                                                                                      width: 32,
                                                                                      fit: BoxFit.fitHeight,
                                                                                    )),
                                                                                SizedBox(
                                                                                  width: width * .3,
                                                                                ),
                                                                                Container(
                                                                                    width: AppConstants.defaultNumericValue * 3,
                                                                                    height: 4,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(16),
                                                                                      color: AppConstants.hintColor,
                                                                                    )),
                                                                              ]),
                                                                          const SizedBox(
                                                                            width:
                                                                                AppConstants.defaultNumericValue,
                                                                          ),
                                                                          Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                LocaleKeys.options.tr(),
                                                                                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: AppConstants.defaultNumericValue / 2),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              // Handle tap action for unmuting or muting
                                                                              if (isCurrentUserMuted) {
                                                                                FirebaseFirestore.instance.collection(DbPaths.collectionmessages).doc(Lamat.getChatId(currentUserNo!, peerNo!)).update({
                                                                                  "$currentUserNo-muted": !isCurrentUserMuted,
                                                                                });
                                                                                setStateIfMounted(() {
                                                                                  isCurrentUserMuted = !isCurrentUserMuted;
                                                                                });
                                                                              } else {
                                                                                FirebaseFirestore.instance.collection(DbPaths.collectionmessages).doc(Lamat.getChatId(currentUserNo!, peerNo!)).update({
                                                                                  "$currentUserNo-muted": !isCurrentUserMuted,
                                                                                });
                                                                                setStateIfMounted(() {
                                                                                  isCurrentUserMuted = !isCurrentUserMuted;
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                isCurrentUserMuted ? LocaleKeys.unmute.tr() : LocaleKeys.mute.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),

                                                                          // Similar GestureDetector and ListTile structures for other options
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              deleteAllChats();
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                LocaleKeys.deleteallchats.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),

                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (hidden) {
                                                                                ChatController.unhideChat(currentUserNo, peerNo);
                                                                              } else {
                                                                                ChatController.hideChat(currentUserNo, peerNo);
                                                                              }
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                hidden ? LocaleKeys.unhidechat.tr() : LocaleKeys.hidechat.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (locked) {
                                                                                ChatController.unlockChat(currentUserNo, peerNo);
                                                                              } else {
                                                                                if (widget.prefs.getString(Dbkeys.isPINsetDone) != currentUserNo || widget.prefs.getString(Dbkeys.isPINsetDone) == null) {
                                                                                  unawaited(Navigator.push(
                                                                                      this.context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => Security(
                                                                                                currentUserNo,
                                                                                                prefs: widget.prefs,
                                                                                                setPasscode: true,
                                                                                                onSuccess: (newContext) async {
                                                                                                  ChatController.lockChat(currentUserNo, peerNo);
                                                                                                  Navigator.pop(context);
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                title: LocaleKeys.authh.tr(),
                                                                                              ))));
                                                                                } else {
                                                                                  ChatController.lockChat(currentUserNo, peerNo);
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              }
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                locked ? LocaleKeys.unlockchat.tr() : LocaleKeys.lockchat.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          GestureDetector(
                                                                            onTap:
                                                                                () {
                                                                              if (isBlocked()) {
                                                                                ChatController.accept(currentUserNo, peerNo);
                                                                              } else {
                                                                                ChatController.block(currentUserNo, peerNo);
                                                                              }
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                isBlocked() ? LocaleKeys.unblockchat.tr() : LocaleKeys.blockchat.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          peer![Dbkeys.wallpaper] != null
                                                                              ? GestureDetector(
                                                                                  onTap: () {
                                                                                    _cachedModel.removeWallpaper(peerNo!);
                                                                                  },
                                                                                  child: ListTile(
                                                                                    title: Text(
                                                                                      LocaleKeys.removewall.tr(),
                                                                                      style: TextStyle(
                                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                      ),
                                                                                    ),
                                                                                    tileColor: Colors.transparent,
                                                                                  ),
                                                                                )
                                                                              : GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => SingleImagePicker(
                                                                                                  prefs: widget.prefs,
                                                                                                  title: LocaleKeys.pickimage.tr(),
                                                                                                  callback: getWallpaper,
                                                                                                )));
                                                                                  },
                                                                                  child: ListTile(
                                                                                    title: Text(
                                                                                      LocaleKeys.setwall.tr(),
                                                                                      style: TextStyle(
                                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                      ),
                                                                                    ),
                                                                                    tileColor: Colors.transparent,
                                                                                  ),
                                                                                ),
                                                                          GestureDetector(
                                                                            onTap: () =>
                                                                                {
                                                                              showModalBottomSheet(
                                                                                  backgroundColor: Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor,
                                                                                  isScrollControlled: true,
                                                                                  context: context,
                                                                                  shape: const RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                  ),
                                                                                  builder: (BuildContext context) {
                                                                                    // return your layout
                                                                                    var w = MediaQuery.of(context).size.width;
                                                                                    return Padding(
                                                                                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                                      child: Container(
                                                                                          padding: const EdgeInsets.all(16),
                                                                                          height: MediaQuery.of(context).size.height / 2.6,
                                                                                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                                                                            const SizedBox(
                                                                                              height: 12,
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 3,
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(left: 7),
                                                                                              child: Text(
                                                                                                LocaleKeys.reportshort.tr(),
                                                                                                textAlign: TextAlign.left,
                                                                                                style: TextStyle(color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor), fontWeight: FontWeight.bold, fontSize: 16.5),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              height: 10,
                                                                                            ),
                                                                                            Container(
                                                                                              margin: const EdgeInsets.only(top: 10),
                                                                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                              // height: 63,
                                                                                              height: 63,
                                                                                              width: w / 1.24,
                                                                                              child: InpuTextBox(
                                                                                                isDark: Teme.isDarktheme(widget.prefs),
                                                                                                controller: reportEditingController,
                                                                                                leftrightmargin: 0,
                                                                                                showIconboundary: false,
                                                                                                boxcornerradius: 5.5,
                                                                                                boxheight: 50,
                                                                                                hinttext: LocaleKeys.reportdesc.tr(),
                                                                                                prefixIconbutton: Icon(
                                                                                                  Icons.message,
                                                                                                  color: Colors.grey.withOpacity(0.5),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: w / 10,
                                                                                            ),
                                                                                            myElevatedButton(
                                                                                                color: AppConstants.primaryColor,
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                                                  child: Text(
                                                                                                    LocaleKeys.report.tr(),
                                                                                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                                                                                  ),
                                                                                                ),
                                                                                                onPressed: () async {
                                                                                                  Navigator.of(context).pop();

                                                                                                  DateTime time = DateTime.now();

                                                                                                  Map<String, dynamic> mapdata = {
                                                                                                    'title': 'report by User',
                                                                                                    'desc': reportEditingController.text,
                                                                                                    'phone': '${widget.currentUserNo}',
                                                                                                    'type': 'Individual Chat',
                                                                                                    'time': time.millisecondsSinceEpoch,
                                                                                                    'id': Lamat.getChatId(currentUserNo!, peerNo!),
                                                                                                  };

                                                                                                  await FirebaseFirestore.instance.collection('reports').doc(time.millisecondsSinceEpoch.toString()).set(mapdata).then((value) async {
                                                                                                    showModalBottomSheet(
                                                                                                        backgroundColor: Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor,
                                                                                                        isScrollControlled: true,
                                                                                                        context: context,
                                                                                                        shape: const RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                                        ),
                                                                                                        builder: (BuildContext context) {
                                                                                                          return SizedBox(
                                                                                                            height: 220,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.all(28.0),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Icon(Icons.check, color: AppConstants.lamatGreenColor400, size: 40),
                                                                                                                  const SizedBox(
                                                                                                                    height: 30,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    LocaleKeys.reportsuccess.tr(),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: TextStyle(
                                                                                                                      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor),
                                                                                                                    ),
                                                                                                                  )
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          );
                                                                                                        });

                                                                                                    //----
                                                                                                  }).catchError((err) {
                                                                                                    showModalBottomSheet(
                                                                                                        backgroundColor: Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor,
                                                                                                        isScrollControlled: true,
                                                                                                        context: this.context,
                                                                                                        shape: const RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                                        ),
                                                                                                        builder: (BuildContext context) {
                                                                                                          return SizedBox(
                                                                                                            height: 220,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.all(28.0),
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  const Icon(Icons.check, color: AppConstants.lamatGreenColor400, size: 40),
                                                                                                                  const SizedBox(
                                                                                                                    height: 30,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    LocaleKeys.reportsuccess.tr(),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: TextStyle(
                                                                                                                      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.dialogColorDark : AppConstants.backgroundColor),
                                                                                                                    ),
                                                                                                                  )
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                          );
                                                                                                        });
                                                                                                  });
                                                                                                }),
                                                                                          ])),
                                                                                    );
                                                                                  })
                                                                            },
                                                                            child:
                                                                                ListTile(
                                                                              title: Text(
                                                                                LocaleKeys.report.tr(),
                                                                                style: TextStyle(
                                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                                ),
                                                                              ),
                                                                              tileColor: Colors.transparent,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                AppConstants.defaultNumericValue * 2,
                                                                          )
                                                                        ]));
                                                          },
                                                        )),
                                                    SizedBox(
                                                      width: 45,
                                                      child: IconButton(
                                                        icon: WebsafeSvg.asset(
                                                            height: 25,
                                                            width: 25,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                            videoIcon,
                                                             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,), ),
                                                        onPressed: (wallet ==
                                                                    null ||
                                                                wallet!.balance <
                                                                    AppRes
                                                                        .callCost)
                                                            ? () {
                                                                debugPrint(
                                                                    'NO BALANCE');
                                                                // EasyLoading.showError(LocaleKeys.insufficientBalance.tr());
                                                                onAddDymondsTap(
                                                                    context);
                                                                //   isPurchaseDialogOpen = true;
                                                                // showModalBottomSheet(
                                                                //   context: context,
                                                                //   backgroundColor: Colors.transparent,
                                                                //   builder: (context) {
                                                                //     return const DialogCoinsPlan();
                                                                //   },
                                                                // ).then((value) {
                                                                //   isPurchaseDialogOpen = false;
                                                                // });
                                                              }
                                                            : hasPeerBlockedMe ==
                                                                    true
                                                                ? () {
                                                                    Navigator.of(
                                                                            this.context)
                                                                        .pop();
                                                                    Lamat.toast(
                                                                      LocaleKeys
                                                                          .userhasblocked
                                                                          .tr(),
                                                                    );
                                                                  }
                                                                : () async {
                                                                    await Permissions
                                                                            .cameraAndMicrophonePermissionsGranted()
                                                                        .then(
                                                                            (isgranted) async {
                                                                      if (isgranted ==
                                                                              true ||
                                                                          kIsWeb) {
                                                                        await minusBalanceProvider(ref,
                                                                                AppRes.msgCost)
                                                                            .then((value) {
                                                                          call(
                                                                              this.context,
                                                                              true);
                                                                        });
                                                                      } else {
                                                                        Lamat
                                                                            .showRationale(
                                                                          LocaleKeys
                                                                              .pmc
                                                                              .tr(),
                                                                        );
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => OpenSettings(
                                                                                      permtype: 'contact',
                                                                                      prefs: widget.prefs,
                                                                                    )));
                                                                      }
                                                                    }).onError((e,
                                                                            trace) {
                                                                      debugPrint(
                                                                          "Call Error: ${trace.toString()}");

                                                                      EasyLoading.showError(
                                                                          trace
                                                                              .toString(),
                                                                          duration:
                                                                              const Duration(hours: 1));
                                                                    });
                                                                  },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 45,
                                                      child: IconButton(
                                                        icon: WebsafeSvg.asset(
                                                            height: 25,
                                                            width: 25,
                                                            fit: BoxFit
                                                                .fitHeight,
                                                            phoneCallIcon,
                                                             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,), ),
                                                        onPressed: (wallet ==
                                                                    null ||
                                                                wallet!.balance <
                                                                    AppRes
                                                                        .callCost)
                                                            ? () {
                                                                debugPrint(
                                                                    'NO BALANCE');
                                                                // EasyLoading.showError(LocaleKeys.insufficientBalance.tr());
                                                                onAddDymondsTap(
                                                                    context);
                                                                //   isPurchaseDialogOpen = true;
                                                                // showModalBottomSheet(
                                                                //   context: context,
                                                                //   backgroundColor: Colors.transparent,
                                                                //   builder: (context) {
                                                                //     return const DialogCoinsPlan();
                                                                //   },
                                                                // ).then((value) {
                                                                //   isPurchaseDialogOpen = false;
                                                                // });
                                                              }
                                                            : hasPeerBlockedMe ==
                                                                    true
                                                                ? () {
                                                                    Navigator.of(
                                                                            this.context)
                                                                        .pop();
                                                                    Lamat.toast(
                                                                      LocaleKeys
                                                                          .userhasblocked
                                                                          .tr(),
                                                                    );
                                                                  }
                                                                : () async {
                                                                    await Permissions
                                                                            .cameraAndMicrophonePermissionsGranted()
                                                                        .then(
                                                                            (isgranted) async {
                                                                      if (isgranted ==
                                                                              true ||
                                                                          kIsWeb) {
                                                                        // (!Responsive.isDesktop(context))
                                                                        //     ? Navigator.of(this.context).pop()
                                                                        //     : {};
                                                                        await minusBalanceProvider(ref,
                                                                                AppRes.msgCost)
                                                                            .then((value) {
                                                                          call(
                                                                              context,
                                                                              false);
                                                                        });
                                                                      } else {
                                                                        Lamat
                                                                            .showRationale(
                                                                          LocaleKeys
                                                                              .pmc
                                                                              .tr(),
                                                                        );
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => OpenSettings(
                                                                                      permtype: 'contact',
                                                                                      prefs: widget.prefs,
                                                                                    )));
                                                                      }
                                                                    }).onError((e,
                                                                            trace) {
                                                                      debugPrint(
                                                                          "Call Error: ${trace.toString()}");

                                                                      EasyLoading.showError(
                                                                          trace
                                                                              .toString(),
                                                                          duration:
                                                                              const Duration(hours: 1));
                                                                    });
                                                                  },
                                                      ),
                                                    )
                                                  ]),
                                          ],
                                        ),
                                        body: Stack(
                                          children: <Widget>[
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .chatBackground,
                                                image: DecorationImage(
                                                    image: peer![Dbkeys
                                                                .wallpaper] ==
                                                            null
                                                        ? AssetImage(
                                                            Teme.isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                                ? chatBgDark
                                                                : chatBgLight)
                                                        : Image.network(peer![
                                                                Dbkeys
                                                                    .wallpaper])
                                                            .image,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            PageView(
                                              children: <Widget>[
                                                isDeletedDoc == true &&
                                                        isDeleteChatManually ==
                                                            false
                                                    ? Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(15,
                                                                  60, 15, 15),
                                                          child: Text(
                                                              LocaleKeys
                                                                  .chatdeleted
                                                                  .tr(),
                                                              style: const TextStyle(
                                                                  color: AppConstants
                                                                      .lamatGrey)),
                                                        ),
                                                      )
                                                    : Column(
                                                        children: [
                                                          // List of messages

                                                          buildMessages(
                                                              context),
                                                          // Input content
                                                          isBlocked()
                                                              ? AlertDialog(
                                                                  backgroundColor: Teme.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? AppConstants
                                                                          .dialogColorDark
                                                                      : AppConstants
                                                                          .backgroundColor,
                                                                  elevation:
                                                                      10.0,
                                                                  title: Text(
                                                                    '${LocaleKeys.unblock.tr()} ${peer![Dbkeys.nickname]}?',
                                                                    style:
                                                                        TextStyle(
                                                                      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget
                                                                              .prefs)
                                                                          ? AppConstants
                                                                              .dialogColorDark
                                                                          : AppConstants
                                                                              .backgroundColor),
                                                                    ),
                                                                  ),
                                                                  actions: <Widget>[
                                                                    myElevatedButton(
                                                                        color: Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants
                                                                                .dialogColorDark
                                                                            : AppConstants
                                                                                .backgroundColor,
                                                                        child:
                                                                            Text(
                                                                          LocaleKeys
                                                                              .cancel
                                                                              .tr(),
                                                                          style:
                                                                              TextStyle(
                                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                                ? AppConstants.dialogColorDark
                                                                                : AppConstants.backgroundColor),
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                                    myElevatedButton(
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        child:
                                                                            Text(
                                                                          LocaleKeys
                                                                              .unblock
                                                                              .tr(),
                                                                          style:
                                                                              const TextStyle(color: AppConstants.lamatWhite),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          ChatController.accept(
                                                                              currentUserNo,
                                                                              peerNo);
                                                                          setStateIfMounted(
                                                                              () {
                                                                            chatStatus =
                                                                                ChatStatus.accepted.index;
                                                                          });
                                                                        })
                                                                  ],
                                                                )
                                                              : hasPeerBlockedMe ==
                                                                      true
                                                                  ? Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          14,
                                                                          7,
                                                                          14,
                                                                          7),
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                              0.3),
                                                                      height:
                                                                          50,
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.error_outline_rounded,
                                                                              color: Colors.red),
                                                                          const SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            LocaleKeys.userhasblocked.tr(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(height: 1.3),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : buildInputAndroid(
                                                                      context,
                                                                      isemojiShowing,
                                                                      refreshInput,
                                                                      keyboardVisible)
                                                        ],
                                                      ),
                                              ],
                                            ),
                                            // buildLoading()
                                          ],
                                        )),
                                    buildLoadingThumbnail(),
                                  ],
                                )
                          : Container();
                    })))),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('An error occurred')),
    );
  }

  deleteAllChats() async {
    if (messages.isNotEmpty) {
      Lamat.toast(
        LocaleKeys.deleting.tr(),
      );
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .get()
          .then((v) async {
        if (v.exists) {
          var c = v;
          isDeleteChatManually = true;
          setStateIfMounted(() {});
          await v.reference.delete().then((value) async {
            messages = [];
            setStateIfMounted(() {});
            Future.delayed(const Duration(milliseconds: 10000), () async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set(c.data()!);
            });
          });
        }
      });
    } else {}
  }
}
