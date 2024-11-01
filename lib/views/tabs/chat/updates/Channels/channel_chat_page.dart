// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/tabs/chat/updates/Channels/channel_details.dart';
import 'package:lamatdating/widgets/InputTextBox/input_text_box.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/translate_notifs.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/localization/language.dart';
import 'package:lamatdating/localization/language_constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/currentchat_peer.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/emoji_detect.dart';
import 'package:lamatdating/utils/mime_type.dart';
import 'package:lamatdating/utils/save.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/Groups/widget/group_chat_bubble.dart';

import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/contact_screens/select_contact.dart';
import 'package:lamatdating/views/contact_screens/contacts_to_fwrd.dart';
import 'package:lamatdating/views/privacypolicy&TnC/pdf_viewer.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/photo_view.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/upload_media.dart';
import 'package:lamatdating/widgets/AllinOneCameraGalleryImageVideoPicker/all_in_one_camera.dart';
import 'package:lamatdating/widgets/AudioRecorder/record_audio.dart';
import 'package:lamatdating/widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:lamatdating/widgets/CameraGalleryImagePicker/multi_media_picker.dart';
import 'package:lamatdating/widgets/DownloadManager/download_all_file_type.dart';
import 'package:lamatdating/widgets/DynamicBottomSheet/dynamic_modal_bottomsheet.dart';
import 'package:lamatdating/widgets/InfiniteList/inf_coll_listview_widg.dart';
import 'package:lamatdating/widgets/MultiDocumentPicker/doc_picker.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:lamatdating/widgets/SoundPlayer/sound_player_pro.dart';
import 'package:lamatdating/widgets/VideoEditor/video_editor.dart';
import 'package:lamatdating/widgets/VideoPicker/video_prev.dart';

class ChannelChatPage extends ConsumerStatefulWidget {
  final String currentUserno;
  final String groupID;
  final int joinedTime;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile>? sharedFiles;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  final bool isCurrentUserMuted;
  const ChannelChatPage({
    super.key,
    required this.currentUserno,
    required this.groupID,
    required this.joinedTime,
    required this.model,
    required this.prefs,
    required this.isSharingIntentForwarded,
    required this.isCurrentUserMuted,
    this.sharedFiles,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  ChannelChatPageState createState() => ChannelChatPageState();
}

class ChannelChatPageState extends ConsumerState<ChannelChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  late String messageReplyOwnerName;
  late Stream<QuerySnapshot> groupChatMessages;
  final TextEditingController reportEditingController = TextEditingController();
  late Query firestoreChatquery;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader =
      GlobalKey<State>(debugLabel: 'qqqeqeqsssaadqeqe');
  final ScrollController realtime = ScrollController();
  Map<String, dynamic>? replyDoc;
  bool isReplyKeyboard = false;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  bool isCurrentUserMuted = false;
  List<Map<String, dynamic>> listMapLang = [];
  @override
  void initState() {
    super.initState();
    isCurrentUserMuted = widget.isCurrentUserMuted;
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectionchannels)
        .doc(widget.groupID)
        .collection(DbPaths.collectiongroupChats)
        .where(Dbkeys.groupmsgTIME, isGreaterThanOrEqualTo: widget.joinedTime)
        .orderBy(Dbkeys.groupmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.read(observerProvider);
      var currentpeer = ref.watch(currentChatPeerProviderProvider);
      var firestoreProvider =
          ref.watch(firestoreDataProviderMESSAGESforGROUPCHAT);

      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1700), () {
        loadMessagesAndListen();

        currentpeer.setpeer(
            newgroupChatId: widget.groupID
                .replaceAll(RegExp('-'), '')
                .substring(
                    1,
                    widget.groupID
                        .replaceAll(RegExp('-'), '')
                        .toString()
                        .length));

        Future.delayed(const Duration(milliseconds: 3000), () {
          if (IsVideoAdShow == true &&
              observer.isadmobshow == true &&
              !kIsWeb) {
            _createRewardedAd();
          }

          if (IsInterstitialAdShow == true &&
              observer.isadmobshow == true &&
              !kIsWeb) {
            _createInterstitialAd();
          }
        });
      });
    });
    setStatusBarColor(widget.prefs);
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

  void _changeLanguage(Language language) async {
    // Locale _locale = await setLocale(language.languageCode);
    // MyApp.setLocale(this.context, _locale);

    Future.delayed(const Duration(milliseconds: 800), () {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
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

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? subscription;
  loadMessagesAndListen() async {
    subscription = firestoreChatquery.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforGROUPCHAT);
          DocumentSnapshot newDoc = change.doc;
          // if (chatprovider.datalistSnapshot.length == 0) {
          // } else if ((chatprovider.checkIfDocAlreadyExits(
          //       newDoc: newDoc,
          //     ) ==
          //     false)) {

          // if (newDoc[Dbkeys.groupmsgSENDBY] != widget.currentUserno) {
          chatprovider.addDoc(newDoc);
          // unawaited(realtime.animateTo(0.0,
          //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          // }
          // }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforGROUPCHAT);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.timestamp]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforGROUPCHAT);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.groupmsgTIME]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      }
    });

    setStateIfMounted(() {});

//       //----sharing intent action:
    if (widget.isSharingIntentForwarded == true) {
      if (widget.sharedText != null) {
        onSendMessage(
            context: this.context,
            content: widget.sharedText!,
            type: MessageType.text,
            timestamp: DateTime.now().millisecondsSinceEpoch);
      } else if (widget.sharedFiles != null) {
        setStateIfMounted(() {
          isgeneratingSomethingLoader = true;
        });
        uploadEach(0);
      }
    }
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
      await getFileData(File(widget.sharedFiles![index].path),
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
            debugPrint('THUMNBNAIL URL::::: ${thumbnailurl!}');
            setStateIfMounted(() {});
          }

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
          onSendMessage(
              context: this.context,
              content: finalUrl,
              type: type,
              timestamp: messagetime);
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

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop, isemojikeyboardopen) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionchannels)
        .doc(widget.groupID)
        .update(
      {
        widget.currentUserno: DateTime.now().millisecondsSinceEpoch,
      },
    );
    setStatusBarColor(widget.prefs);
    if (iswillpop == true && isemojikeyboardopen == false) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false, isemojiShowing);
    subscription!.cancel();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true) {
      _rewardedAd!.dispose();
    }
  }

  File? pickedFile;
  File? thumbnailFile;

  getFileData(File image, {int? timestamp, int? totalFiles}) {
    final observer = ref.read(observerProvider);

    setStateIfMounted(() {
      pickedFile = image;
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

  getFileName(groupid, timestamp) {
    return "${widget.currentUserno}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = ref.read(observerProvider);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });
    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        // thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        quality: 20);
    thumbnailFile = File(path!);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        widget.groupID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile! : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();
      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
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
          LocaleKeys.failedsending.tr(),
        );
        debugPrint('ERROR SENDING MEDIA: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
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
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    String fileName = getFileName(
        widget.currentUserno,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
      fileToCompress = File(pickedFile!.path);
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
      pickedFile = File(info!.path!);
    } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
      final targetPath =
          "${pickedFile!.absolute.path.replaceAll(basename(pickedFile!.absolute.path), "")}temp.jpg";

      File originalImageFile = File(pickedFile!.path); // Convert XFile to File

      XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalImageFile.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );

      if (compressedXFile != null) {
        compressedImage = File(compressedXFile.path); // Convert XFile to File
      }
    } else {}

    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(pickedFile!.path) == true
            ? compressedImage!
            : pickedFile!);

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
                  key: _keyLoader,
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

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
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
          LocaleKeys.failedsending.tr(),
        );
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
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
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future uploadSelectedLocalFileWithProgressIndicatorWeb(
      Uint8List selectedFile,
      bool isVideo,
      bool isthumbnail,
      int timeEpoch,
      String filenameoptional) async {
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
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

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
                  key: _keyLoader,
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
          .doc(widget.currentUserno)
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
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
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
    // String fileName = getFileName(widget.currentUserno,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

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
                  key: _keyLoader,
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
      MediaInfo _mediaInfo = MediaInfo();

      await _mediaInfo.getMediaInfo(selectedFile.path).then((mediaInfo) {
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
          LocaleKeys.failedsending.tr(),
        );
        debugPrint('ERROR SENDING FILE: $onError');
      });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
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
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  void onSendMessage(
      {required BuildContext context,
      required String content,
      required MessageType type,
      int? timestamp,
      bool? isForward = false}) async {
    final groupList = ref.read(channelsListProvider);
    final observer = ref.watch(observerProvider);

    Map<dynamic, dynamic> groupDoc = groupList.when(
      data: (groupLists) {
        int index = groupLists.indexWhere(
            (element) => element.docmap[Dbkeys.groupID] == widget.groupID);
        return index < 0
            ? {}
            : groupLists
                .lastWhere((element) =>
                    element.docmap[Dbkeys.groupID] == widget.groupID)
                .docmap;
      },
      loading: () => {}, // return an empty map or a loading state if necessary
      error: (_, __) => {}, // handle error state if necessary
    );
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      content = content.trim();
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc('$timestamp--${widget.currentUserno}')
          .set({
        Dbkeys.groupmsgCONTENT: content,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: timestamp,
        Dbkeys.groupmsgSENDBY: widget.currentUserno,
        // Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: type.index,
        Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
        Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
        Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
        Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
        Dbkeys.isReply: isReplyKeyboard,
        Dbkeys.replyToMsgDoc: replyDoc,
        Dbkeys.isForward: isForward
      }, SetOptions(merge: true));

      unawaited(realtime.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut));
      // _playPopSound();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .doc(widget.groupID)
          .update(
        {Dbkeys.groupLATESTMESSAGETIME: timestamp},
      );
      setStateIfMounted(() {
        isReplyKeyboard = false;
        replyDoc = null;
      });
      setStatusBarColor(widget.prefs);
      unawaited(realtime.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut));
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
        if (IsVideoAdShow == true && observer.isadmobshow == true && !kIsWeb) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showRewardedAd();
          });
        }
      }
    }
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

  _onEmojiSelected(emojipic.Emoji emoji) {
    textEditingController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    setStateIfMounted(() {});
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  final TextEditingController textEditingController = TextEditingController();
  FocusNode keyboardFocusNode = FocusNode();
  Widget buildInputAndroid(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = ref.watch(observerProvider);

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
                            onPressed: () {
                              refreshThisInput();
                            },
                            icon: const Icon(Icons.emoji_emotions,
                                color: AppConstants.lamatGrey, size: 23),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: () {
                              if (isemojiShowing == true) {
                              } else {
                                keyboardFocusNode.requestFocus();
                                setStateIfMounted(() {});
                              }
                            },
                            onChanged: (f) {
                              if (textEditingController.text.isNotEmpty &&
                                  textEditingController.text.length == 1) {
                                setStateIfMounted(() {});
                              }
                              setStateIfMounted(() {});
                            },
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
                                          onPressed:
                                              observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        LocaleKeys
                                                            .mediamssgnotallowed
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
                                          onPressed:
                                              observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        LocaleKeys
                                                            .mediamssgnotallowed
                                                            .tr(),
                                                      );
                                                    }
                                                  : () async {
                                                      hidekeyboard(context);
                                                      await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AllinOneCameraGalleryImageVideoPicker(
                                                                    prefs: widget
                                                                        .prefs,
                                                                    onTakeFile: (file,
                                                                        isVideo,
                                                                        thumnail) async {
                                                                      setStatusBarColor(
                                                                          widget
                                                                              .prefs);

                                                                      int timeStamp =
                                                                          DateTime.now()
                                                                              .millisecondsSinceEpoch;
                                                                      if (isVideo ==
                                                                          true) {
                                                                        int timeStamp =
                                                                            DateTime.now().millisecondsSinceEpoch;
                                                                        String
                                                                            videoFileext =
                                                                            p.extension(file.path);
                                                                        String
                                                                            videofileName =
                                                                            'Video-$timeStamp$videoFileext';
                                                                        String? videoUrl = await uploadSelectedLocalFileWithProgressIndicator(
                                                                            file,
                                                                            true,
                                                                            false,
                                                                            timeStamp,
                                                                            filenameoptional:
                                                                                videofileName);
                                                                        if (videoUrl !=
                                                                            null) {
                                                                          String? thumnailUrl = await uploadSelectedLocalFileWithProgressIndicator(
                                                                              thumnail!,
                                                                              false,
                                                                              true,
                                                                              timeStamp);
                                                                          if (thumnailUrl !=
                                                                              null) {
                                                                            onSendMessage(
                                                                                context: this.context,
                                                                                content: '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName',
                                                                                type: MessageType.video,
                                                                                timestamp: timeStamp);
                                                                            file.delete();
                                                                            thumnail.delete();
                                                                          }
                                                                        }
                                                                      } else {
                                                                        String
                                                                            imageFileext =
                                                                            p.extension(file.path);
                                                                        String
                                                                            imagefileName =
                                                                            'IMG-$timeStamp$imageFileext';
                                                                        String? url = await uploadSelectedLocalFileWithProgressIndicator(
                                                                            file,
                                                                            false,
                                                                            false,
                                                                            timeStamp,
                                                                            filenameoptional:
                                                                                imagefileName);
                                                                        if (url !=
                                                                            null) {
                                                                          onSendMessage(
                                                                              context: this.context,
                                                                              content: url,
                                                                              type: MessageType.image,
                                                                              timestamp: timeStamp);
                                                                          file.delete();
                                                                        }
                                                                      }
                                                                    },
                                                                    onTakeFileWeb: (file,
                                                                        isVideo,
                                                                        filname) async {
                                                                      setStatusBarColor(
                                                                          widget
                                                                              .prefs);

                                                                      int timeStamp =
                                                                          DateTime.now()
                                                                              .millisecondsSinceEpoch;
                                                                      if (isVideo ==
                                                                          true) {
                                                                        // String videoFileext =
                                                                        //     p.extension(file.path);
                                                                        String
                                                                            videofileName =
                                                                            'Video-$timeStamp$filname';
                                                                        String? videoUrl = await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                                            file,
                                                                            true,
                                                                            false,
                                                                            timeStamp,
                                                                            filname);
                                                                        if (videoUrl !=
                                                                            null) {
                                                                          // String? thumnailUrl =
                                                                          //     await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                                          //         filname!,
                                                                          //         false,
                                                                          //         true,
                                                                          //         timeStamp);

                                                                          onSendMessage(
                                                                              context: this.context,
                                                                              content: '$videoUrl-BREAK-${'https://www.intermedia-solutions.net/wp-content/uploads/2021/06/video-thumbnail-01.jpg'}-BREAK-${videometadata!}-BREAK-$videofileName',
                                                                              type: MessageType.video,
                                                                              timestamp: timeStamp);
                                                                          // await file.delete();
                                                                          // await thumnail.delete();
                                                                        }
                                                                      } else {
                                                                        // String imageFileext =
                                                                        //     p.extension(file.path);
                                                                        String
                                                                            imagefileName =
                                                                            filname;
                                                                        String? url = await uploadSelectedLocalFileWithProgressIndicatorWeb(
                                                                            file,
                                                                            false,
                                                                            false,
                                                                            timeStamp,
                                                                            imagefileName);
                                                                        if (url !=
                                                                            null) {
                                                                          onSendMessage(
                                                                              context: this.context,
                                                                              content: url,
                                                                              type: MessageType.image,
                                                                              timestamp: timeStamp);
                                                                          // await file.delete();
                                                                        }
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
                                            onPressed: observer
                                                        .ismediamessagingallowed ==
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
                                                        await GiphyGet.getGif(
                                                      tabColor: AppConstants
                                                          .primaryColor,
                                                      context: context,
                                                      apiKey:
                                                          GiphyAPIKey, //YOUR API KEY HERE
                                                      lang:
                                                          GiphyLanguage.english,
                                                    );
                                                    if (gif != null &&
                                                        mounted) {
                                                      onSendMessage(
                                                        context: context,
                                                        content: gif.images!
                                                            .original!.url,
                                                        type: MessageType.image,
                                                      );
                                                      hidekeyboard(context);
                                                      setStateIfMounted(() {});
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
                      color: AppConstants.secondaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
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
                                      fontWeight: FontWeight.w600,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: observer.ismediamessagingallowed == true
                          ? textEditingController.text.isNotEmpty == false
                              ? () {
                                  hidekeyboard(context);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AudioRecord(
                                                prefs: widget.prefs,
                                                title: "Record Audio",
                                                callback: getFileData,
                                              ))).then((url) {
                                    if (url != null) {
                                      onSendMessage(
                                        context: context,
                                        content: url +
                                            '-BREAK-' +
                                            uploadTimestamp.toString(),
                                        type: MessageType.audio,
                                      );
                                    } else {}
                                  });
                                }
                              : observer.istextmessagingallowed == false
                                  ? () {
                                      Lamat.showRationale(
                                        LocaleKeys.mediamssgnotallowed.tr(),
                                      );
                                    }
                                  : () => onSendMessage(
                                        context: context,
                                        content: textEditingController
                                            .value.text
                                            .trim(),
                                        type: MessageType.text,
                                      )
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
        skinToneConfig: const emojipic.SkinToneConfig(),
        categoryViewConfig: const emojipic.CategoryViewConfig(),
        bottomActionBarConfig: const emojipic.BottomActionBarConfig(),
        searchViewConfig: const emojipic.SearchViewConfig(),
                        )),
                  ),
                )
              : const SizedBox(),
        ]);
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
                        color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                widget.currentUserno
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
                              replyDoc![Dbkeys.groupmsgSENDBY] ==
                                      widget.currentUserno
                                  ? LocaleKeys.you.tr()
                                  : messageReplyOwnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                          widget.currentUserno
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
                                              ? Colors.yellow[00]
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

  buildEachMessage(Map<String, dynamic> doc, GroupModel groupData) {
    if (doc[Dbkeys.groupmsgTYPE] == Dbkeys.groupmsgTYPEnotificationAddedUser) {
      return const Center(child: SizedBox());
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationCreatedGroup) {
      return const Center(child: SizedBox());
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? LocaleKeys.uhvupdatedgrpdetails.tr()
              : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasupdatedgrpdetails.tr()}'
                      .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                  ? LocaleKeys.grpdetailsupdatebyadmin.tr()
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasupdatedgrpdetails.tr()}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${LocaleKeys.hasbeensetasadminbyu.tr()}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hvsetuasadsmin.tr()}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.set.tr()} ${doc[Dbkeys.groupmsgLISToptional][0]} ${LocaleKeys.asadmin.tr()}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? '${LocaleKeys.youhaveremoved.tr()} ${doc[Dbkeys.groupmsgLISToptional][0]} ${LocaleKeys.fromadmin.tr()}'
              : doc[Dbkeys.groupmsgLISToptional][0] == widget.currentUserno
                  ? '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.theyremoveduasadmin.tr()}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasremoved.tr()} ${doc[Dbkeys.groupmsgLISToptional][0]} ${LocaleKeys.fromadmin.tr()}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? LocaleKeys.youupdatedgrpicon.tr()
              : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasupdatedgrpicon.tr()}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationDeletedGroupicon) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
              ? LocaleKeys.youremovedgrpicon.tr()
              : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasremovedgrpicon.tr()}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains('by ${widget.currentUserno}')
              ? '${LocaleKeys.youhaveremoved.tr()} ${doc[Dbkeys.groupmsgLISToptional][0]}'
              : doc[Dbkeys.groupmsgSENDBY] ==
                      groupData.docmap[Dbkeys.groupCREATEDBY]
                  ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${LocaleKeys.removedbyadmin.tr()}'
                  : '${doc[Dbkeys.groupmsgSENDBY]} ${LocaleKeys.hasremoved.tr()} ${doc[Dbkeys.groupmsgLISToptional][0]}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserLeft) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.groupmsgCONTENT].contains(widget.currentUserno)
              ? LocaleKeys.youleftthegroup.tr()
              : '${doc[Dbkeys.groupmsgCONTENT]}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.location.index) {
      return doc[Dbkeys.content] == null || doc[Dbkeys.content] == ''
          ? buildMediaMessages(doc, groupData)
          : Dismissible(
              direction: DismissDirection.startToEnd,
              key: Key(doc[Dbkeys.groupmsgTIME].toString()),
              confirmDismiss: (direction) {
                onDismiss(doc);
                return Future.value(false);
              },
              child: buildMediaMessages(doc, groupData));
    }

    return Text(doc[Dbkeys.groupmsgCONTENT]);
  }

  onDismiss(Map<String, dynamic> doc) {
    if ((doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null) == false) {
      final contactsProvider = ref.watch(smartContactProvider);

      setStateIfMounted(() {
        isReplyKeyboard = true;
        replyDoc = doc;
        messageReplyOwnerName = contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                    .indexWhere((element) =>
                        element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                0
            ? contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer[contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .indexWhere((element) =>
                            element.phone == doc[Dbkeys.groupmsgSENDBY])]
                    .name ??
                doc[Dbkeys.groupmsgSENDBY].toString()
            : doc[Dbkeys.groupmsgSENDBY].toString();
      });
      HapticFeedback.heavyImpact();
      keyboardFocusNode.requestFocus();
    }
  }

  FlutterSecureStorage storage = const FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  contextMenu(BuildContext context, Map<String, dynamic> mssgDoc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    final contactsProvider = ref.watch(smartContactProvider);

    if (mssgDoc[Dbkeys.groupmsgSENDBY] == widget.currentUserno) {
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
                Navigator.of(popable).pop();
                if (mssgDoc[Dbkeys.messageType] == MessageType.image.index &&
                    !mssgDoc[Dbkeys.groupmsgCONTENT].contains('giphy')) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(mssgDoc[Dbkeys.groupmsgCONTENT])
                        .delete();
                  } catch (e) {
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  }
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.doc.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  }
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.audio.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  }
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.video.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                    await FirebaseStorage.instance
                        .refFromURL(
                            mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[1])
                        .delete();
                  } catch (e) {
                    if (kDebugMode) {
                      print(e.toString());
                    }
                  }
                }
                if (deleteMessaqgeForEveryoneDeleteFromServer == true) {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionchannels)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .delete();
                } else {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionchannels)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .update({
                    Dbkeys.groupmsgISDELETED: true,
                    Dbkeys.groupmsgCONTENT: '',
                  });
                }
              })));
    }
    if (mssgDoc[Dbkeys.groupmsgISDELETED] == false) {
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
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectContactsToForward(
                            contentPeerNo: mssgDoc[Dbkeys.from],
                            messageOwnerPhone: widget.currentUserno,
                            currentUserNo: widget.currentUserno,
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
                  messageReplyOwnerName = contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                              .indexWhere((element) =>
                                  element.phone ==
                                  mssgDoc[Dbkeys.groupmsgSENDBY]) >=
                          0
                      ? contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                  contactsProvider
                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                      .indexWhere((element) =>
                                          element.phone ==
                                          mssgDoc[Dbkeys.groupmsgSENDBY])]
                              .name ??
                          mssgDoc[Dbkeys.groupmsgSENDBY].toString()
                      : mssgDoc[Dbkeys.groupmsgSENDBY].toString();
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    if (mssgDoc[Dbkeys.groupmsgTYPE] == MessageType.text.index &&
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

                var v = await Lamat.translateString(
                    mssgDoc[Dbkeys.groupmsgCONTENT], widget.prefs);
                if (v != mssgDoc[Dbkeys.groupmsgCONTENT]) {
                  await widget.prefs.setString(
                      '${mssgDoc[Dbkeys.groupmsgTIME]}-trns', v.toString());
                  listMapLang.add(
                      {'${mssgDoc[Dbkeys.groupmsgTIME]}-trns': v.toString()});
                  setStateIfMounted(() {});
                }
              })));
    }

    if (mssgDoc[Dbkeys.groupmsgTYPE] == MessageType.text.index &&
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
        context: this.context,
        builder: (context) {
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
      });
      Navigator.of(this.context).pop();
    } else {
      if (list[index].containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[index];
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectionchannels)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc('$timestamp--${widget.currentUserno}')
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserno,
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
                .collection(DbPaths.collectionchannels)
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
          Lamat.toast(
            LocaleKeys.failedsending.tr(),
          );
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
          final encrypted = content;
          // encryptWithCRC(content);
          //  AESEncryptData.encryptAES(content, sharedSecret);
          int timestamp2 = DateTime.now().millisecondsSinceEpoch;
          if (content.trim() != '') {
            Map<String, dynamic>? targetPeer =
                widget.model.userData[list[index][Dbkeys.phone]];
            if (targetPeer == null) {
              await ChatController.request(
                  widget.currentUserno,
                  list[index][Dbkeys.phone],
                  Lamat.getChatId(
                      widget.currentUserno, list[index][Dbkeys.phone]));
            }
            var chatId = Lamat.getChatId(
                widget.currentUserno, list[index][Dbkeys.phone]);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .set({
              widget.currentUserno: true,
              list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
            }, SetOptions(merge: true)).then((value) async {
              Future messaging = FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(list[index][Dbkeys.phone])
                  .collection(Dbkeys.chatsWith)
                  .doc(Dbkeys.chatsWith)
                  .set({
                widget.currentUserno: 4,
              }, SetOptions(merge: true));
              widget.model
                  .addMessage(list[index][Dbkeys.phone], timestamp2, messaging);
            }).then((value) async {
              Future messaging = FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .collection(chatId)
                  .doc('$timestamp2')
                  .set({
                Dbkeys.from: widget.currentUserno,
                Dbkeys.to: list[index][Dbkeys.phone],
                Dbkeys.timestamp: timestamp2,
                Dbkeys.content: encrypted,
                Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                Dbkeys.hasSenderDeleted: false,
                Dbkeys.hasRecipientDeleted: false,
                Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                Dbkeys.isReply: false,
                Dbkeys.replyToMsgDoc: null,
                Dbkeys.isForward: true,
                Dbkeys.latestEncrypted: true,
                Dbkeys.isMuted: false,
              }, SetOptions(merge: true));
              widget.model
                  .addMessage(list[index][Dbkeys.phone], timestamp2, messaging);
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
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Lamat.toast('${LocaleKeys.failedtofrwdmsgerror.tr()}$e');
        }
      }
    }
  }

  Widget buildMediaMessages(Map<String, dynamic> doc, GroupModel groupData) {
    bool isMe = widget.currentUserno == doc[Dbkeys.groupmsgSENDBY];
    bool saved = false;
    final contactsProvider = ref.watch(smartContactProvider);

    final observer = ref.watch(observerProvider);

    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return Consumer(
        builder: (context, ref, _child) => InkWell(
              onLongPress: doc[Dbkeys.groupmsgISDELETED] == false
                  ? () {
                      contextMenu(
                        context,
                        doc,
                      );
                      hidekeyboard(context);
                    }
                  : null,
              child: GroupChatBubble(
                isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                    isContainURL == true,
                is24hrsFormat: observer.is24hrsTimeformat,
                prefs: widget.prefs,
                currentUserNo: widget.currentUserno,
                model: widget.model,
                savednameifavailable: contactsProvider
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider.contactsBookContactList!.entries
                        .toList()[contactsProvider
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key == doc[Dbkeys.groupmsgSENDBY])]
                        .value
                    : null,
                postedbyname: contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .indexWhere((element) =>
                                element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                contactsProvider
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .indexWhere((element) =>
                                        element.phone ==
                                        doc[Dbkeys.groupmsgSENDBY])]
                            .name ??
                        doc[Dbkeys.groupmsgSENDBY]
                    : '',
                postedbyphone: doc[Dbkeys.groupmsgSENDBY],
                messagetype: doc[Dbkeys.groupmsgISDELETED] == true
                    ? MessageType.text
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? MessageType.text
                        : doc[Dbkeys.messageType] == MessageType.contact.index
                            ? MessageType.contact
                            : doc[Dbkeys.messageType] ==
                                    MessageType.location.index
                                ? MessageType.location
                                : doc[Dbkeys.messageType] ==
                                        MessageType.image.index
                                    ? MessageType.image
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? MessageType.video
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.doc.index
                                            ? MessageType.doc
                                            : doc[Dbkeys.messageType] ==
                                                    MessageType.audio.index
                                                ? MessageType.audio
                                                : MessageType.text,
                isMe: isMe,
                delivered: true,
                isContinuing: true,
                timestamp: doc[Dbkeys.groupmsgTIME],
                child: doc[Dbkeys.groupmsgISDELETED] == true
                    ? Text(
                        LocaleKeys.msgdeleted.tr(),
                        style: TextStyle(
                            color: AppConstants.lamatBlack.withOpacity(0.6),
                            fontSize: 15,
                            fontStyle: FontStyle.italic),
                      )
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content], doc,
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(
                                    context, doc[Dbkeys.content], doc,
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content], doc,
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content], doc,
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(context,
                                                doc[Dbkeys.content], doc,
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
              ),
            ));
  }

  Widget getVideoMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return InkWell(
      onTap: () {
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => PreviewVideo(
                      prefs: widget.prefs,
                      isdownloadallowed: true,
                      filename: message.split('-BREAK-')[1],
                      id: null,
                      videourl: message.split('-BREAK-')[0],
                      aspectratio: meta!["width"] / meta["height"],
                    )));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            width: 245,
            height: 245,
            child: Stack(
              children: [
                CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    width: 245,
                    height: 245,
                    padding: const EdgeInsets.all(80.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(0.0),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blueGrey[400]!),
                      ),
                    ),
                  ),
                  errorWidget: (context, str, error) => Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(0.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      'assets/images/img_not_available.jpeg',
                      width: 245,
                      height: 245,
                      fit: BoxFit.cover,
                    ),
                  ),
                  imageUrl: message.split('-BREAK-')[1],
                  width: 245,
                  height: 245,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                  width: 245,
                  height: 245,
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
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 210,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            leading: customCircleAvatar(url: null, radius: 20),
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
        ],
      ),
    );
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  const SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content],
                      doc[Dbkeys.groupmsgTIME], 15.5, TextAlign.left),
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
                          selectablelinkify(doc[Dbkeys.content],
                              doc[Dbkeys.groupmsgTIME], 15.5, TextAlign.left)
                        ],
                      )
                    : selectablelinkify(doc[Dbkeys.content],
                        doc[Dbkeys.groupmsgTIME], 15.5, TextAlign.left)
                : selectablelinkify(doc[Dbkeys.content],
                    doc[Dbkeys.groupmsgTIME], 15.5, TextAlign.left)
        : selectablelinkify(doc[Dbkeys.content], doc[Dbkeys.groupmsgTIME], 15.5,
            TextAlign.left);
  }

  Widget getLocationMessage(String? message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: doc.containsKey(Dbkeys.isForward) == true
          ? doc[Dbkeys.isForward] == true
              ? Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                    Image.asset(
                      'assets/images/mapview.jpg',
                      width: MediaQuery.of(this.context).size.width / 1.7,
                      height:
                          (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                    ),
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                  width: MediaQuery.of(this.context).size.width / 1.7,
                  height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
                )
          : Image.asset(
              'assets/images/mapview.jpg',
              width: MediaQuery.of(this.context).size.width / 1.7,
              height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    ref: ref,
                    keyloader: _keyLoader,
                    url: message.split('-BREAK-')[0],
                    fileName: 'Recording_${message.split('-BREAK-')[1]}.mp3',
                    context: this.context,
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
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 220,
      height: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Text("PREVIEW",
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
                              keyloader: _keyLoader,
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
                        keyloader: _keyLoader,
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
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                ),
              )
            : InkWell(
                onTap: () => Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewWrapper(
                        prefs: widget.prefs,
                        keyloader: _keyLoader,
                        imageUrl: doc[Dbkeys.content],
                        message: doc[Dbkeys.content],
                        tag: doc[Dbkeys.groupmsgTIME].toString(),
                        imageProvider:
                            CachedNetworkImageProvider(doc[Dbkeys.content]),
                      ),
                    )),
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    child: Center(
                      child: SizedBox(
                        height: 60.0,
                        width: 60.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueGrey[400]!),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, str, error) => Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.asset(
                      'assets/images/img_not_available.jpeg',
                      width:
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                      height:
                          doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  imageUrl: doc[Dbkeys.content],
                  width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                  fit: BoxFit.cover,
                ),
              ),
      ],
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    final contactsProvider = ref.watch(smartContactProvider);

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
                        color:
                            doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
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
                              doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                                  ? "You"
                                  : contactsProvider
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .indexWhere((element) =>
                                                  element.phone ==
                                                  doc[Dbkeys.groupmsgSENDBY]) >=
                                          0
                                      ? contactsProvider
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                  contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .indexWhere((element) =>
                                                          element.phone ==
                                                          doc[Dbkeys
                                                              .groupmsgSENDBY])]
                                              .name ??
                                          doc[Dbkeys.groupmsgSENDBY].toString()
                                      : doc[Dbkeys.groupmsgSENDBY].toString(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.groupmsgSENDBY] ==
                                          widget.currentUserno
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
                                  maxLines: 1,
                                  style: const TextStyle(
                                      color: AppConstants.lamatBlack),
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 75),
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

  Widget buildMessagesUsingProvider(BuildContext context) {
    final groupList = ref.watch(channelsListProvider);

    final firestoreDataProvider =
        ref.watch(firestoreDataProviderMESSAGESforGROUPCHAT);
    return InfiniteCOLLECTIONListViewWidget(
      prefs: widget.prefs,
      scrollController: realtime,
      isreverse: true,
      firestoreDataProviderMESSAGESforGROUPCHAT: firestoreDataProvider,
      datatype: Dbkeys.datatypeGROUPCHATMSGS,
      refdata: firestoreChatquery,
      list: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.all(7),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: firestoreDataProvider.recievedDocs.length,
          itemBuilder: (BuildContext context, int i) {
            var dc = firestoreDataProvider.recievedDocs[i];

            return groupList.when(
              data: (groupLists) {
                return buildEachMessage(
                    dc,
                    groupLists.lastWhere((element) =>
                        element.docmap[Dbkeys.groupID] == widget.groupID));
              },
              loading: () => const Center(
                  child:
                      CircularProgressIndicator()), // handle loading state if necessary
              error: (_, __) => const Center(
                  child:
                      CircularProgressIndicator()), // handle error state if necessary
            );
          }),
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
                        AppConstants.secondaryColor)),
              ),
            )
          : Container(),
    );
  }

  shareMedia(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiDocumentPicker(
                                          prefs: widget.prefs,
                                          title: LocaleKeys.pickdoc.tr(),
                                          callback: getFileData,
                                          writeMessage:
                                              (String? url, int time) async {
                                            if (url != null) {
                                              String finalUrl =
                                                  '$url-BREAK-${basename(pickedFile!.path)}';
                                              onSendMessage(
                                                  context: this.context,
                                                  content: finalUrl,
                                                  type: MessageType.doc,
                                                  timestamp: time);
                                            }
                                          },
                                        )));
                          },
                          elevation: .5,
                          fillColor: Colors.indigo,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.file_copy,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(
                          LocaleKeys.doc.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: AppConstants.lamatGrey, fontSize: 14),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            File? selectedMedia =
                                await pickVideoFromgallery(context)
                                    .catchError((err) {
                              Lamat.toast(LocaleKeys.invalidfile.tr());
                              return null;
                            });

                            if (selectedMedia == null) {
                              setStatusBarColor(widget.prefs);
                            } else {
                              setStatusBarColor(widget.prefs);
                              String fileExtension =
                                  p.extension(selectedMedia.path).toLowerCase();

                              if (fileExtension == ".mp4" ||
                                  fileExtension == ".mov") {
                                final tempDir = await getTemporaryDirectory();
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
                                              setStatusBarColor(widget.prefs);
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
                                                    context: this.context,
                                                    content:
                                                        '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName',
                                                    type: MessageType.video,
                                                  );
                                                  file.delete();
                                                  thumnailFile.delete();
                                                }
                                              }
                                            },
                                            file: File(file.path))));
                              } else {
                                Lamat.toast(
                                    "${LocaleKeys.filetypenotsupportedvideo.tr()} $fileExtension");
                              }
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
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
                                    builder: (context) =>
                                        CameraImageGalleryPicker(
                                          onTakeFile: (file) async {
                                            setStatusBarColor(widget.prefs);

                                            int timeStamp = DateTime.now()
                                                .millisecondsSinceEpoch;

                                            String? url =
                                                await uploadSelectedLocalFileWithProgressIndicator(
                                                    file,
                                                    false,
                                                    false,
                                                    timeStamp);
                                            if (url != null) {
                                              onSendMessage(
                                                  context: this.context,
                                                  content: url,
                                                  type: MessageType.image,
                                                  timestamp: timeStamp);
                                              file.delete();
                                            }
                                          },
                                        )));
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
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () {
                            hidekeyboard(context);

                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AudioRecord(
                                          prefs: widget.prefs,
                                          title: LocaleKeys.record.tr(),
                                          callback: getFileData,
                                        ))).then((url) {
                              if (url != null) {
                                onSendMessage(
                                  context: this.context,
                                  content: url +
                                      '-BREAK-' +
                                      uploadTimestamp.toString(),
                                  type: MessageType.audio,
                                );
                              } else {}
                            });
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
                          style: const TextStyle(color: AppConstants.lamatGrey),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RawMaterialButton(
                          disabledElevation: 0,
                          onPressed: () async {
                            hidekeyboard(context);
                            Navigator.of(context).pop();
                            await checkIfLocationEnabled().then((value) async {
                              if (value == true) {
                                Lamat.toast(
                                  LocaleKeys.detectingloc.tr(),
                                );
                                await _determinePosition().then(
                                  (location) async {
                                    var locationstring =
                                        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                    onSendMessage(
                                      context: this.context,
                                      content: locationstring,
                                      type: MessageType.location,
                                    );
                                    setStateIfMounted(() {});
                                    Lamat.toast(
                                      LocaleKeys.sent.tr(),
                                    );
                                  },
                                );
                              } else {
                                Lamat.toast(LocaleKeys.lcdennied.tr());
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
                          style: const TextStyle(color: AppConstants.lamatGrey),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.27,
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
                                        currentUserNo: widget.currentUserno,
                                        model: widget.model,
                                        biometricEnabled: false,
                                        prefs: widget.prefs,
                                        onSelect: (name, phone) {
                                          onSendMessage(
                                            context: context,
                                            content: '$name-BREAK-$phone',
                                            type: MessageType.contact,
                                          );
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
                          style: const TextStyle(color: AppConstants.lamatGrey),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ]),
          );
        });
  }

  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setStateIfMounted(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      setLastSeen(true, isemojiShowing);
      return Future.value(true);
    }
    return Future.value(false);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    final groupList = ref.watch(channelsListProvider);

    var currentpeer = ref.watch(currentChatPeerProviderProvider);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(WillPopScope(
          onWillPop: isgeneratingSomethingLoader == true
              ? () async {
                  return Future.value(false);
                }
              : isemojiShowing == true
                  ? () {
                      setStateIfMounted(() {
                        isemojiShowing = false;
                        keyboardFocusNode.unfocus();
                      });
                      return Future.value(false);
                    }
                  : () async {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        currentpeer.setpeer(newgroupChatId: '');
                      });
                      setLastSeen(false, false);

                      return Future.value(true);
                    },
          child: Stack(
            children: [
              Scaffold(
                  key: _scaffold,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.chatBackground,
                  appBar: AppBar(
                    elevation: 0.4,
                    titleSpacing: -10,
                    leading: Container(
                      margin: const EdgeInsets.only(right: 0),
                      width: 10,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        onPressed: onWillPop,
                      ),
                    ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    title: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChannelDetails(
                                    model: widget.model,
                                    prefs: widget.prefs,
                                    currentUserno: widget.currentUserno,
                                    groupID: widget.groupID)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          groupList.when(
                            data: (groupLists) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                child: customCircleAvatarGroup(
                                    radius: 20,
                                    url: groupLists
                                        .lastWhere((element) =>
                                            element.docmap[Dbkeys.groupID] ==
                                            widget.groupID)
                                        .docmap[Dbkeys.groupPHOTOURL]),
                              );
                            },
                            loading: () =>
                                const CircularProgressIndicator(), // return a loading widget if necessary
                            error: (_, __) => const Icon(
                                Icons.error), // handle error state if necessary
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  groupList.when(
                                    data: (groupLists) {
                                      return Text(
                                        groupLists
                                            .lastWhere((element) =>
                                                element
                                                    .docmap[Dbkeys.groupID] ==
                                                widget.groupID)
                                            .docmap[Dbkeys.groupNAME],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color:
                                                pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor),
                                            fontSize: 17.0,
                                            fontWeight: FontWeight.w500),
                                      );
                                    },
                                    loading: () =>
                                        const CircularProgressIndicator(), // return a loading widget if necessary
                                    error: (_, __) => const Icon(Icons
                                        .error), // handle error state if necessary
                                  ),
                                  isCurrentUserMuted
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Icon(
                                            Icons.volume_off,
                                            color: pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor)
                                                .withOpacity(0.5),
                                            size: 17,
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.7,
                                child: Text(
                                  LocaleKeys.tapherefrgrpinfo.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor)
                                              .withOpacity(0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 15, left: 15),
                        width: 25,
                        child: PopupMenuButton(
                            icon: Padding(
                              padding: const EdgeInsets.only(right: 0),
                              child: Icon(
                                Icons.more_vert_outlined,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                              ),
                            ),
                            color: Teme.isDarktheme(widget.prefs)
                                ? AppConstants.dialogColorDark
                                : AppConstants.backgroundColor,
                            onSelected: (dynamic val) {
                              switch (val) {
                                case 'mute':
                                  setStateIfMounted(() {
                                    isCurrentUserMuted = !isCurrentUserMuted;
                                  });

                                  FirebaseMessaging.instance
                                      .unsubscribeFromTopic(
                                          "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                      .then((value) {
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionchannels)
                                        .doc(widget.groupID)
                                        .update({
                                      Dbkeys.groupMUTEDMEMBERS:
                                          FieldValue.arrayUnion(
                                              [widget.currentUserno]),
                                    });
                                  }).catchError((err) {
                                    setStateIfMounted(() {
                                      isCurrentUserMuted = !isCurrentUserMuted;
                                    });
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionchannels)
                                        .doc(widget.groupID)
                                        .update({
                                      Dbkeys.groupMUTEDMEMBERS:
                                          FieldValue.arrayRemove(
                                              [widget.currentUserno]),
                                    });
                                  });

                                  break;
                                case 'unmute':
                                  setStateIfMounted(() {
                                    isCurrentUserMuted = !isCurrentUserMuted;
                                  });

                                  FirebaseMessaging.instance
                                      .subscribeToTopic(
                                          "GROUP${widget.groupID.replaceAll(RegExp('-'), '').substring(1, widget.groupID.replaceAll(RegExp('-'), '').toString().length)}")
                                      .then((value) {
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionchannels)
                                        .doc(widget.groupID)
                                        .update({
                                      Dbkeys.groupMUTEDMEMBERS:
                                          FieldValue.arrayRemove(
                                              [widget.currentUserno]),
                                    });
                                  }).catchError((err) {
                                    setStateIfMounted(() {
                                      isCurrentUserMuted = !isCurrentUserMuted;
                                    });
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionchannels)
                                        .doc(widget.groupID)
                                        .update({
                                      Dbkeys.groupMUTEDMEMBERS:
                                          FieldValue.arrayUnion(
                                              [widget.currentUserno]),
                                    });
                                  });

                                  break;
                                case 'report':
                                  showModalBottomSheet(
                                      backgroundColor:
                                          Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.dialogColorDark
                                              : AppConstants.backgroundColor,
                                      isScrollControlled: true,
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0)),
                                      ),
                                      builder: (BuildContext context) {
                                        // return your layout
                                        var w =
                                            MediaQuery.of(context).size.width;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Container(
                                              padding: const EdgeInsets.all(16),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.6,
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    const SizedBox(
                                                      height: 12,
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 7),
                                                      child: Text(
                                                        LocaleKeys.reportshort
                                                            .tr(),
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                    .isDarktheme(
                                                                        widget
                                                                            .prefs)
                                                                ? AppConstants
                                                                    .dialogColorDark
                                                                : AppConstants
                                                                    .backgroundColor),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.5),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 0, 0),
                                                      // height: 63,
                                                      height: 63,
                                                      width: w / 1.24,
                                                      child: InpuTextBox(
                                                        isDark:
                                                            Teme.isDarktheme(
                                                                widget.prefs),
                                                        controller:
                                                            reportEditingController,
                                                        leftrightmargin: 0,
                                                        showIconboundary: false,
                                                        boxcornerradius: 5.5,
                                                        boxheight: 50,
                                                        hinttext: LocaleKeys
                                                            .reportdesc
                                                            .tr(),
                                                        prefixIconbutton: Icon(
                                                          Icons.message,
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: w / 10,
                                                    ),
                                                    myElevatedButton(
                                                        color: AppConstants
                                                            .primaryColor,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(10,
                                                                  15, 10, 15),
                                                          child: Text(
                                                            LocaleKeys.report
                                                                .tr(),
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pop();

                                                          DateTime time =
                                                              DateTime.now();

                                                          Map<String, dynamic>
                                                              mapdata = {
                                                            'title':
                                                                'report by User',
                                                            'desc':
                                                                reportEditingController
                                                                    .text,
                                                            'phone': widget
                                                                .currentUserno,
                                                            'type':
                                                                'Group Chat',
                                                            'time': time
                                                                .millisecondsSinceEpoch,
                                                            'id':
                                                                widget.groupID,
                                                          };

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'reports')
                                                              .doc(time
                                                                  .millisecondsSinceEpoch
                                                                  .toString())
                                                              .set(mapdata)
                                                              .then(
                                                                  (value) async {
                                                            showModalBottomSheet(
                                                                backgroundColor: Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
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
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              25.0)),
                                                                ),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return SizedBox(
                                                                    height: 220,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          28.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.check,
                                                                              color: AppConstants.lamatGreenColor400,
                                                                              size: 40),
                                                                          const SizedBox(
                                                                            height:
                                                                                30,
                                                                          ),
                                                                          Text(
                                                                            LocaleKeys.reportsuccess.tr(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
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
                                                                backgroundColor: Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? AppConstants
                                                                        .dialogColorDark
                                                                    : AppConstants
                                                                        .backgroundColor,
                                                                isScrollControlled:
                                                                    true,
                                                                context: this
                                                                    .context,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              25.0)),
                                                                ),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return SizedBox(
                                                                    height: 220,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          28.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.check,
                                                                              color: AppConstants.lamatGreenColor400,
                                                                              size: 40),
                                                                          const SizedBox(
                                                                            height:
                                                                                30,
                                                                          ),
                                                                          Text(
                                                                            LocaleKeys.reportsuccess.tr(),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
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
                                      });
                                  break;
                              }
                            },
                            itemBuilder: ((context) => <PopupMenuItem<String>>[
                                  PopupMenuItem<String>(
                                    value:
                                        isCurrentUserMuted ? 'unmute' : 'mute',
                                    child: Text(
                                      isCurrentUserMuted
                                          ? LocaleKeys.unmute.tr()
                                          : LocaleKeys.mute.tr(),
                                      style: TextStyle(
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .dialogColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'report',
                                    child: Text(
                                      LocaleKeys.report.tr(),
                                      style: TextStyle(
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .dialogColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                      ),
                                    ),
                                  ),
                                  // ignore: unnecessary_null_comparison
                                ].toList())),
                      ),
                    ],
                  ),
                  body: Stack(children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Teme.isDarktheme(widget.prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.chatBackground,
                        image: DecorationImage(
                            image: AssetImage(Teme.isDarktheme(widget.prefs)
                                ? chatBgDark
                                : chatBgLight),
                            fit: BoxFit.cover),
                      ),
                    ),
                    PageView(children: <Widget>[
                      Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                                child: buildMessagesUsingProvider(context)),
                            groupList.when(
                              data: (groupLists) {
                                return groupLists
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupTYPE] ==
                                            Dbkeys
                                                .groupTYPEallusersmessageallowed ||
                                        groupLists
                                            .lastWhere((element) =>
                                                element
                                                    .docmap[Dbkeys.groupID] ==
                                                widget.groupID)
                                            .docmap[Dbkeys.groupADMINLIST]
                                            .contains(widget.currentUserno)
                                    ? buildInputAndroid(
                                        context,
                                        isemojiShowing,
                                        refreshInput,
                                        _keyboardVisible,
                                      )
                                    : const SizedBox();
                              },
                              loading: () =>
                                  const CircularProgressIndicator(), // return a loading widget if necessary
                              error: (_, __) => const Icon(Icons
                                  .error), // handle error state if necessary
                            ),
                          ])
                    ]),
                  ])),
              buildLoadingThumbnail()
            ],
          ),
        )));
  }

  Widget selectablelinkify(
      String? text, int timestamp, double? fontsize, TextAlign? textalign) {
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
              listMapLang.indexWhere(
                          (element) => element.containsKey('$timestamp-trns')) <
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
            ],
          )
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
              textAlign: textalign,
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text,
              textAlign: textalign,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setLastSeen(false, false);
    } else {
      setLastSeen(false, false);
    }
  }
}

deletedGroupWidget(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          LocaleKeys.deletedgroup.tr(),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
