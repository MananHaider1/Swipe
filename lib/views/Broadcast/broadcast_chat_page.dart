// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:convert';
// import 'package:universal_html/html.dart' as html;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:media_info/media_info.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/broadcast_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/emoji_detect.dart';
import 'package:lamatdating/utils/mime_type.dart';
import 'package:lamatdating/utils/save.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/Broadcast/broadcast_details.dart';
import 'package:lamatdating/views/Groups/widget/group_chat_bubble.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/contact_screens/select_contact.dart';
import 'package:lamatdating/views/privacypolicy&TnC/pdf_viewer.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/photo_view.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/upload_media.dart';
import 'package:lamatdating/widgets/AllinOneCameraGalleryImageVideoPicker/all_in_one_camera.dart';
import 'package:lamatdating/widgets/AudioRecorder/record_audio.dart';
import 'package:lamatdating/widgets/CameraGalleryImagePicker/camera_image_gallery_picker.dart';
import 'package:lamatdating/widgets/CameraGalleryImagePicker/multi_media_picker.dart';
import 'package:lamatdating/widgets/DocumentPicker/document_picker.dart';
import 'package:lamatdating/widgets/DownloadManager/download_all_file_type.dart';
import 'package:lamatdating/widgets/InfiniteList/inf_coll_listview_widg.dart';
import 'package:lamatdating/widgets/SoundPlayer/sound_player_pro.dart';
import 'package:lamatdating/widgets/VideoEditor/video_editor.dart';
import 'package:lamatdating/widgets/VideoPicker/video_prev.dart';

class BroadcastChatPage extends ConsumerStatefulWidget {
  final String currentUserno;
  final String broadcastID;
  final DataModel model;
  final SharedPreferences prefs;
  const BroadcastChatPage({
    super.key,
    required this.currentUserno,
    required this.broadcastID,
    required this.model,
    required this.prefs,
  });

  @override
  BroadcastChatPageState createState() => BroadcastChatPageState();
}

class BroadcastChatPageState extends ConsumerState<BroadcastChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingThumbnail = false;

  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  final GlobalKey<State> _keyLoader =
      GlobalKey<State>(debugLabel: 'qqqeqessaqsseaadqeqe');
  final ScrollController realtime = ScrollController();
  late Query firestoreChatquery;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  @override
  void initState() {
    super.initState();
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .doc(widget.broadcastID)
        .collection(DbPaths.collectionbroadcastsChats)
        .orderBy(Dbkeys.broadcastmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading);
    setLastSeen(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var firestoreProvider =
          ref.watch(firestoreDataProviderMESSAGESforBROADCASTCHATPAGE);

      final observer = ref.watch(observerProvider);
      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1000), () {
        loadMessagesAndListen();

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
  }

  loadMessagesAndListen() async {
    firestoreChatquery.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforBROADCASTCHATPAGE);
          DocumentSnapshot newDoc = change.doc;
          if (chatprovider.datalistSnapshot.isEmpty) {
          } else if ((chatprovider.checkIfDocAlreadyExits(
                newDoc: newDoc,
              ) ==
              false)) {
            chatprovider.addDoc(newDoc);
            // unawaited(realtime.animateTo(0.0,
            //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforBROADCASTCHATPAGE);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.timestamp]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              ref.watch(firestoreDataProviderMESSAGESforBROADCASTCHATPAGE);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.timestamp]) ==
              true) {
            // chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop) {
    setStatusBarColor(widget.prefs);
    if (iswillpop == true) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false);
    if (IsInterstitialAdShow == true && !kIsWeb) {
      _interstitialAd!.dispose();
    }
    if (IsVideoAdShow == true && !kIsWeb) {
      _rewardedAd!.dispose();
    }
  }

  File? thumbnailFile;

  getFileData(File image) {
    final observer = ref.watch(observerProvider);
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setStateIfMounted(() {
        imageFile = image;
      });
    }
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(false)
        : uploadFile(false);
  }

  getpickedFileName(broadcastID, timestamp) {
    return "${widget.currentUserno}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = ref.watch(observerProvider);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingThumbnail = true;
    });
    // final storage =
    //     html.window.navigator.temporaryStorage?.requestQuota(1024 * 1024);
    String? path = await VideoThumbnail.thumbnailFile(
        video: url,
        // thumbnailPath:  !kIsWeb ? (await getTemporaryDirectory()).path : ,
        imageFormat: ImageFormat.PNG,
        // maxHeight: 150,
        // maxWidth:300,
        // timeMs: r.timeMs,
        quality: 30);

    thumbnailFile = File(path!);
    setStateIfMounted(() {
      isgeneratingThumbnail = false;
    });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getpickedFileName(
        widget.broadcastID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(imageFile!.path) == true) {
      fileToCompress = File(imageFile!.path);
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
      imageFile = File(info!.path!);
    } else if (isthumbnail == false && isImage(imageFile!.path) == true) {
      final targetPath =
          "${imageFile!.absolute.path.replaceAll(basename(imageFile!.absolute.path), "")}temp.jpg";

      File originalImageFile = File(imageFile!.path); // Convert XFile to File

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
    TaskSnapshot uploading = await reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(imageFile!.path) == true
            ? compressedImage!
            : imageFile!);

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
        Lamat.toast('Sending failed !');
        debugPrint('ERROR Sending File: $onError');
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

  Future uploadFileWithProgressIndicator(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getpickedFileName(
        widget.broadcastID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(imageFile!.path) == true) {
      fileToCompress = File(imageFile!.path);
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
      imageFile = File(info!.path!);
    } else if (isthumbnail == false && isImage(imageFile!.path) == true) {
      final targetPath =
          "${imageFile!.absolute.path.replaceAll(basename(imageFile!.absolute.path), "")}temp.jpg";

      File originalImageFile = File(imageFile!.path); // Convert XFile to File

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
        : isImage(imageFile!.path) == true
            ? compressedImage!
            : imageFile!);

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
                                    ? "Generating thumbnail..."
                                    : "Uploading...",
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                  prefs: widget.prefs,
                                  context: context,
                                  percent: 0.0,
                                  title: isthumbnail == true
                                      ? "Generating thumbnail..."
                                      : "Uploading...",
                                  subtitle: '');
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
        Lamat.toast('Sending failed !');
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

  void onSendMessage({
    required BuildContext context,
    required String content,
    required MessageType type,
    required List<dynamic> recipientList,
  }) async {
    textEditingController.clear();
    final observer = ref.watch(observerProvider);
    await FirebaseBroadcastServices().sendMessageToBroadcastRecipients(
        recipientList: recipientList,
        context: context,
        content: content,
        currentUserNo: widget.currentUserno,
        broadcastId: widget.broadcastID,
        type: type,
        cachedModel: widget.model);

    unawaited(realtime.animateTo(0.0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut));
    Lamat.toast('Sent to total recipients: ${recipientList.length}');
    setStatusBarColor(widget.prefs);
    if (type == MessageType.doc ||
        type == MessageType.audio ||
        (type == MessageType.image && !content.contains('giphy')) ||
        type == MessageType.location ||
        type == MessageType.contact) {
      if (IsVideoAdShow == true &&
          observer.isadmobshow == true &&
          IsInterstitialAdShow == false &&
          !kIsWeb) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          _showRewardedAd();
        });
      } else if (IsInterstitialAdShow == true &&
          observer.isadmobshow == true &&
          !kIsWeb) {
        _showInterstitialAd();
      }
    } else if (type == MessageType.video) {
      if (IsVideoAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          _showRewardedAd();
        });
      }
    }
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
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
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
    // String fileName = getpickedFileName(widget.broadcastID,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
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
                  // side: BorderSide(width: 5, color: Colors.green)),
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
                                    ? "Generating thumbnail..."
                                    : "Sending...",
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                prefs: widget.prefs,
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? "Generating thumbnail..."
                                    : "Sending...",
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
        Lamat.toast('Sending failed !');
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
  Widget buildInputAndroid(
      BuildContext context,
      bool isemojiShowing,
      Function toggleEmojiKeyboard,
      bool keyboardVisible,
      List<BroadcastModel> broadcastList) {
    final observer = ref.watch(observerProvider);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: !kIsWeb
                    ? Platform.isIOS == true
                        ? 20
                        : 0
                    : 0),
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
                              toggleEmojiKeyboard();
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
                              hintText: 'msg'.tr(),
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
                                          onPressed: observer
                                                      .ismediamessagingallowed ==
                                                  false
                                              ? () {
                                                  Lamat.showRationale(
                                                    "Sending Media is temporarily disabled by Admin!",
                                                  );
                                                }
                                              : () {
                                                  hidekeyboard(context);
                                                  shareMedia(
                                                      context, broadcastList);
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
                                                          "Sending Media is temporarily disabled by Admin!");
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
                                                                                recipientList: broadcastList.toList().firstWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                                                                              recipientList: broadcastList.toList().firstWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                                                                              recipientList: broadcastList.toList().firstWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                                                                              recipientList: broadcastList.toList().firstWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST]);
                                                                          // await file.delete();
                                                                        }
                                                                      }
                                                                    },
                                                                  )));
                                                      // hidekeyboard(context);

                                                      // Navigator.push(
                                                      //     context,
                                                      //     MaterialPageRoute(
                                                      //         builder: (context) =>
                                                      //             SingleImagePicker(
                                                      //               title:
                                                      //
                                                      //               callback:
                                                      //                   getFileData,
                                                      //             ))).then((url) {
                                                      //   if (url != null) {
                                                      //     onSendMessage(
                                                      //         context: this.context,
                                                      //         content: url,
                                                      //         type:
                                                      //             MessageType.image,
                                                      //         recipientList: broadcastList
                                                      //             .toList()
                                                      //             .firstWhere((element) =>
                                                      //                 element.docmap[
                                                      //                     Dbkeys
                                                      //                         .broadcastID] ==
                                                      //                 widget
                                                      //                     .broadcastID)
                                                      //             .docmap[Dbkeys.broadcastMEMBERSLIST]);
                                                      //   }
                                                      // });
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
                                                        "Sending Media is temporarily disabled by Admin!");
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
                                                          type:
                                                              MessageType.image,
                                                          recipientList: broadcastList
                                                              .toList()
                                                              .firstWhere((element) =>
                                                                  element.docmap[
                                                                      Dbkeys
                                                                          .broadcastID] ==
                                                                  widget
                                                                      .broadcastID)
                                                              .docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                                                title: "Record",
                                                callback: getFileData,
                                              ))).then((url) {
                                    if (url != null) {
                                      onSendMessage(
                                          context: context,
                                          content: url +
                                              '-BREAK-' +
                                              uploadTimestamp.toString(),
                                          type: MessageType.audio,
                                          recipientList: broadcastList
                                                  .toList()
                                                  .firstWhere((element) =>
                                                      element.docmap[
                                                          Dbkeys.broadcastID] ==
                                                      widget.broadcastID)
                                                  .docmap[
                                              Dbkeys.broadcastMEMBERSLIST]);
                                    } else {}
                                  });
                                }
                              : observer.istextmessagingallowed == false
                                  ? () {
                                      Lamat.showRationale(
                                          "Sending Text Messages is temporarily disabled by Admin.");
                                    }
                                  : () => onSendMessage(
                                      context: context,
                                      content: textEditingController.value.text
                                          .trim(),
                                      type: MessageType.text,
                                      recipientList: broadcastList
                                          .toList()
                                          .firstWhere((element) =>
                                              element
                                                  .docmap[Dbkeys.broadcastID] ==
                                              widget.broadcastID)
                                          .docmap[Dbkeys.broadcastMEMBERSLIST])
                          : () {
                              Lamat.showRationale(
                                  "Sending Media is temporarily disabled by Admin.");
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
                          // height: 256,
        // bgColor: const Color(0xFFF2F2F2),
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

                          // columns: 7,
                          // emojiSizeMax: 32 *
                          //     (f.defaultTargetPlatform == TargetPlatform.iOS
                          //         ? 1.30
                          //         : 1.0),
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
                          // noRecents: const Text(
                          //   'No Recents',
                          //   style:
                          //       TextStyle(fontSize: 20, color: Colors.black26),
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

  buildEachMessage(Map<String, dynamic> doc, BroadcastModel broadcastData) {
    if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationCreatedbroadcast) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          'Broadcast list is created: ${doc[Dbkeys.broadcastmsgLISToptional].length} Recipients',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationAddedUser) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          doc[Dbkeys.broadcastmsgLISToptional].length > 1
              ? 'You have added ${doc[Dbkeys.broadcastmsgLISToptional].length} recipients'
              : 'You have added ${doc[Dbkeys.broadcastmsgLISToptional][0]} ',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcastDetails) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: const Text(
          "You have updated the Broadcast Details",
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcasticon) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: const Text(
          "Broadcast Group Icon changed by You",
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationDeletedbroadcasticon) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: const Text(
          "Broadcast Group Icon deleted by You",
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Chip(
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blueGrey[50],
        label: Text(
          'You have removed ${doc[Dbkeys.broadcastmsgLISToptional][0]}',
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ));
    } else if (doc[Dbkeys.broadcastmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.location.index) {
      return buildMediaMessages(doc, broadcastData);
    }

    return Text(doc[Dbkeys.broadcastmsgCONTENT]);
  }

  contextMenu(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if (doc[Dbkeys.broadcastmsgSENDBY] == widget.currentUserno) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: const Icon(Icons.delete),
              title: Text(
                (doc[Dbkeys.messageType] == MessageType.image.index &&
                            !doc[Dbkeys.broadcastmsgCONTENT]
                                .contains('giphy')) ||
                        (doc[Dbkeys.messageType] == MessageType.doc.index) ||
                        (doc[Dbkeys.messageType] == MessageType.audio.index) ||
                        (doc[Dbkeys.messageType] == MessageType.video.index)
                    ? "Delete for Everyone"
                    : "Delete for Me",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                if (doc[Dbkeys.messageType] == MessageType.image.index &&
                    !doc[Dbkeys.broadcastmsgCONTENT].contains('giphy')) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(doc[Dbkeys.broadcastmsgCONTENT])
                        .delete();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                } else if (doc[Dbkeys.messageType] == MessageType.doc.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                } else if (doc[Dbkeys.messageType] == MessageType.audio.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                } else if (doc[Dbkeys.messageType] == MessageType.video.index) {
                  try {
                    await FirebaseStorage.instance
                        .refFromURL(
                            doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                        .delete();
                    await FirebaseStorage.instance
                        .refFromURL(
                            doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[1])
                        .delete();
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                }

                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionbroadcasts)
                    .doc(widget.broadcastID)
                    .collection(DbPaths.collectionbroadcastsChats)
                    .doc(
                        '${doc[Dbkeys.broadcastmsgTIME]}--${doc[Dbkeys.broadcastmsgSENDBY]}')
                    .delete();
                Lamat.toast("Deleted");
              })));
    }

    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  Widget buildMediaMessages(
      Map<String, dynamic> doc, BroadcastModel broadcastData) {
    final observer = ref.watch(observerProvider);
    final smartContactProviderWithLocalStoreData =
        ref.watch(smartContactProvider);
    bool isMe = widget.currentUserno == doc[Dbkeys.broadcastmsgSENDBY];
    bool saved = false;
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return Consumer(
        builder: (context, ref, child) => InkWell(
              onLongPress: () {
                contextMenu(context, doc);
                hidekeyboard(context);
              },
              child: GroupChatBubble(
                isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                    isContainURL == true,
                is24hrsFormat: observer.is24hrsTimeformat,
                prefs: widget.prefs,
                currentUserNo: widget.currentUserno,
                model: widget.model,
                savednameifavailable: smartContactProviderWithLocalStoreData
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key ==
                                doc[Dbkeys.broadcastmsgSENDBY]) >=
                        0
                    ? smartContactProviderWithLocalStoreData
                        .contactsBookContactList!.entries
                        .toList()[smartContactProviderWithLocalStoreData
                            .contactsBookContactList!.entries
                            .toList()
                            .indexWhere((element) =>
                                element.key == doc[Dbkeys.broadcastmsgSENDBY])]
                        .value
                    : null,
                postedbyname: smartContactProviderWithLocalStoreData
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .indexWhere((element) =>
                                element.phone ==
                                doc[Dbkeys.broadcastmsgSENDBY]) >=
                        0
                    ? smartContactProviderWithLocalStoreData
                            .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                smartContactProviderWithLocalStoreData
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .indexWhere((element) =>
                                        element.phone ==
                                        doc[Dbkeys.broadcastmsgSENDBY])]
                            .name ??
                        ''
                    : '',
                postedbyphone: doc[Dbkeys.broadcastmsgSENDBY],
                messagetype: doc[Dbkeys.broadcastmsgISDELETED] == true
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
                timestamp: doc[Dbkeys.broadcastmsgTIME],
                child: doc[Dbkeys.broadcastmsgISDELETED] == true
                    ? getTextMessage(isMe, doc, saved)
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content],
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(context, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content],
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content],
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(
                                                context, doc[Dbkeys.content],
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
              ),
            ));
  }

  Widget getVideoMessage(BuildContext context, String message,
      {bool saved = false}) {
    Map<dynamic, dynamic>? meta =
        jsonDecode((message.split('-BREAK-')[2]).toString());
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
      child: Container(
        color: Colors.blueGrey,
        width: 230.0,
        height: 230.0,
        child: Stack(
          children: [
            CachedNetworkImage(
              placeholder: (context, url) => Container(
                width: 230.0,
                height: 230.0,
                padding: const EdgeInsets.all(80.0),
                decoration: const BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.all(
                    Radius.circular(0.0),
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
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
                  width: 230.0,
                  height: 230.0,
                  fit: BoxFit.cover,
                ),
              ),
              imageUrl: message.split('-BREAK-')[1],
              width: 230.0,
              height: 230.0,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
              width: 230.0,
              height: 230.0,
            ),
            const Center(
              child: Icon(Icons.play_circle_fill_outlined,
                  color: Colors.white70, size: 65),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(BuildContext context, String message,
      {bool saved = false}) {
    return SizedBox(
      width: 210,
      height: 75,
      child: Column(
        children: [
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
    return selectablelinkify(
        doc[Dbkeys.broadcastmsgISDELETED] == true
            ? 'Message is deleted'
            : doc[Dbkeys.content],
        15.5,
        isMe ? TextAlign.right : TextAlign.left);
  }

  Widget getLocationMessage(String? message, {bool saved = false}) {
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: Image.asset(
        'assets/images/mapview.jpg',
        width: MediaQuery.of(this.context).size.width / 1.7,
        height: (MediaQuery.of(this.context).size.width / 1.7) * 0.6,
      ),
    );
  }

  Widget getAudiomessage(BuildContext context, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: () async {
                await MobileDownloadService().download(
                    prefs: widget.prefs,
                    keyloader: _keyLoader,
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

  Widget getDocmessage(BuildContext context, String message,
      {bool saved = false}) {
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        children: [
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
                        child: Text("Preview",
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
                        child: Text("Download",
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
                  child: Text("Download",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    return Container(
      child: saved
          ? Material(
              borderRadius: const BorderRadius.all(
                Radius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Save.getImageFromBase64(doc[Dbkeys.content]).image,
                      fit: BoxFit.cover),
                ),
                width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
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
                      tag: doc[Dbkeys.broadcastmsgTIME].toString(),
                      imageProvider:
                          CachedNetworkImageProvider(doc[Dbkeys.content]),
                    ),
                  )),
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                  padding: const EdgeInsets.all(80.0),
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
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
                    width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                    fit: BoxFit.cover,
                  ),
                ),
                imageUrl: doc[Dbkeys.content],
                width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                fit: BoxFit.cover,
              ),
            ),
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
    final broadcastsList = ref.watch(broadcastsListProvider);
    final firestoreDataProvider =
        ref.watch(firestoreDataProviderMESSAGESforBROADCASTCHATPAGE);
    return Consumer(
        builder: (context, ref, child) => Consumer(
            builder: (context, ref, _) => InfiniteCOLLECTIONListViewWidget(
                  prefs: widget.prefs,
                  scrollController: realtime,
                  isreverse: true,
                  firestoreDataProviderMESSAGESforBROADCASTCHATPAGE:
                      firestoreDataProvider,
                  datatype: Dbkeys.datatypeBROADCASTCMSGS,
                  refdata: firestoreChatquery,
                  list: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(0),
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: firestoreDataProvider.recievedDocs.length,
                      itemBuilder: (BuildContext context, int i) {
                        var dc = firestoreDataProvider.recievedDocs[i];

                        return broadcastsList.when(
                          data: (broadcastsList) {
                            final broadcast = broadcastsList.lastWhere(
                                (element) =>
                                    element.docmap[Dbkeys.groupID] ==
                                    widget.broadcastID);
                            return buildEachMessage(dc, broadcast);
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const Text('Error'),
                        );
                      }),
                )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingThumbnail
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

  File? imageFile;

  shareMedia(BuildContext context, List<BroadcastModel> broadcastList) {
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
                                    builder: (context) => HybridDocumentPicker(
                                          prefs: widget.prefs,
                                          title: "Pick Document",
                                          callback: getFileData,
                                        ))).then((url) async {
                              if (url != null) {
                                Lamat.toast('plswait'.tr());

                                onSendMessage(
                                    context: this.context,
                                    content: url +
                                        '-BREAK-' +
                                        basename(imageFile!.path).toString(),
                                    type: MessageType.doc,
                                    recipientList: broadcastList
                                        .toList()
                                        .firstWhere((element) =>
                                            element
                                                .docmap[Dbkeys.broadcastID] ==
                                            widget.broadcastID)
                                        .docmap[Dbkeys.broadcastMEMBERSLIST]);
                              } else {}
                            });
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
                          'doc'.tr(),
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
                              Lamat.toast("Invalid file");
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
                                                        timeStamp,
                                                        filenameoptional:
                                                            videofileName);
                                                if (thumnailUrl != null) {
                                                  onSendMessage(
                                                      context: context,
                                                      content:
                                                          '$videoUrl-BREAK-$thumnailUrl-BREAK-${videometadata!}-BREAK-$videofileName',
                                                      type: MessageType.video,
                                                      recipientList: broadcastList
                                                          .toList()
                                                          .firstWhere((element) =>
                                                              element.docmap[Dbkeys
                                                                  .broadcastID] ==
                                                              widget
                                                                  .broadcastID)
                                                          .docmap[Dbkeys.broadcastMEMBERSLIST]);
                                                  Lamat.toast("Sent");
                                                  file.delete();
                                                  thumnailFile.delete();
                                                }
                                              }
                                            },
                                            file: File(file.path))));
                              } else {
                                Lamat.toast(
                                    "File type not supported. Please choose a valid .mp4, .mov file. \n\nSelected file was $fileExtension ");
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
                          'video'.tr(),
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
                                    builder:
                                        (context) => CameraImageGalleryPicker(
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
                                                      recipientList: broadcastList
                                                          .toList()
                                                          .firstWhere((element) =>
                                                              element.docmap[Dbkeys
                                                                  .broadcastID] ==
                                                              widget
                                                                  .broadcastID)
                                                          .docmap[Dbkeys.broadcastMEMBERSLIST]);
                                                  file.delete();
                                                }
                                              },
                                            )));
                          },
                          elevation: .5,
                          fillColor: AppConstants.primaryColor,
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
                          'image'.tr(),
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
                                          title: "Record",
                                          callback: getFileData,
                                        ))).then((url) {
                              if (url != null) {
                                onSendMessage(
                                    context: context,
                                    content: url +
                                        '-BREAK-' +
                                        uploadTimestamp.toString(),
                                    type: MessageType.audio,
                                    recipientList: broadcastList
                                        .toList()
                                        .firstWhere((element) =>
                                            element
                                                .docmap[Dbkeys.broadcastID] ==
                                            widget.broadcastID)
                                        .docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                        const Text(
                          "Audio",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppConstants.lamatGrey),
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
                                  'detectingloc'.tr(),
                                );
                                await _determinePosition().then(
                                  (location) async {
                                    var locationstring =
                                        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
                                    onSendMessage(
                                        context: this.context,
                                        content: locationstring,
                                        type: MessageType.location,
                                        recipientList: broadcastList
                                                .toList()
                                                .firstWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.broadcastID] ==
                                                    widget.broadcastID)
                                                .docmap[
                                            Dbkeys.broadcastMEMBERSLIST]);
                                    setStateIfMounted(() {});
                                    Lamat.toast(
                                      'sentSuccessfully'.tr(),
                                    );
                                  },
                                );
                              } else {
                                Lamat.toast(
                                    'locationpermissionsaredenied'.tr());
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
                        const Text(
                          "Location",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppConstants.lamatGrey),
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
                                              recipientList: broadcastList
                                                      .toList()
                                                      .firstWhere((element) =>
                                                          element.docmap[Dbkeys
                                                              .broadcastID] ==
                                                          widget.broadcastID)
                                                      .docmap[
                                                  Dbkeys.broadcastMEMBERSLIST]);
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
                        const Text(
                          "Contact",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppConstants.lamatGrey),
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

  bool isemojiShowing = false;
  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setState(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      Navigator.of(this.context).pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

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
    final broadcastsList = ref.watch(broadcastsListProvider);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Consumer(
            builder: (context, broadcastList, _child) => WillPopScope(
                  onWillPop: isgeneratingThumbnail == true
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
                              setLastSeen(
                                false,
                              );

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
                            titleSpacing: 0,
                            leading: Container(
                              margin: const EdgeInsets.only(right: 0),
                              width: 10,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  size: 24,
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
                                        builder: (context) => BroadcastDetails(
                                            model: widget.model,
                                            prefs: widget.prefs,
                                            currentUserno: widget.currentUserno,
                                            broadcastID: widget.broadcastID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: broadcastsList.when(
                                        data: (broadcastList) {
                                          final broadcast = broadcastList
                                              .lastWhere((element) =>
                                                  element.docmap[
                                                      Dbkeys.broadcastID] ==
                                                  widget.broadcastID);
                                          return customCircleAvatarBroadcast(
                                            radius: 20,
                                            url: broadcast.docmap[
                                                Dbkeys.broadcastPHOTOURL],
                                          );
                                        },
                                        loading: () => const Center(
                                            child: CircularProgressIndicator()),
                                        error: (_, __) => const Text('Error'),
                                      )),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        broadcastsList.when(
                                          data: (broadcastList) {
                                            final broadcast = broadcastList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.broadcastID] ==
                                                    widget.broadcastID);
                                            return Text(
                                              broadcast
                                                  .docmap[Dbkeys.broadcastNAME],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: pickTextColorBasedOnBgColorAdvanced(
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
                                          loading: () => const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                          error: (_, __) => const Text('Error'),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.3,
                                          child: Text(
                                            "Tap here for Broadcast Info",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                            .isDarktheme(
                                                                widget.prefs)
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          body: Stack(children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                                image: DecorationImage(
                                    image: AssetImage(
                                        Teme.isDarktheme(widget.prefs)
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
                                        child: buildMessagesUsingProvider(
                                            context)),
                                    broadcastsList.when(
                                      data: (broadcastList) {
                                        final broadcast =
                                            broadcastList.lastWhere((element) =>
                                                element.docmap[
                                                    Dbkeys.broadcastID] ==
                                                widget.broadcastID);
                                        return broadcast
                                                    .docmap[Dbkeys
                                                        .broadcastMEMBERSLIST]
                                                    .length >
                                                0
                                            ? buildInputAndroid(
                                                context,
                                                isemojiShowing,
                                                refreshInput,
                                                _keyboardVisible,
                                                broadcastList)
                                            : Container(
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        14, 7, 14, 7),
                                                color: Colors.white,
                                                height: 70,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: const Text(
                                                  "No recipients available",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(height: 1.3),
                                                ),
                                              );
                                      },
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()),
                                      error: (_, __) => const Text('Error'),
                                    )
                                  ])
                            ]),
                          ])),
                      buildLoadingThumbnail(),
                    ],
                  ),
                ))));
  }

  Widget selectablelinkify(
      String? text, double? fontsize, TextAlign? textalign) {
    bool isContainURL = false;
    try {
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return isContainURL == false
        ? SelectableLinkify(
            style: TextStyle(
                fontSize: isAllEmoji(text!) ? fontsize! * 2 : fontsize,
                color: Colors.black87),
            text: text,
            onOpen: (link) async {
              custom_url_launcher(link.url);
            },
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
      setLastSeen(false);
    } else {
      setLastSeen(false);
    }
  }

  deletedBroadcastWidget() {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Text(
            'This Broadcast Has been deleted by Admin OR you have been removed from this group.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
