// ignore_for_file: no_leading_underscores_for_local_identifiers, void_checks

import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:path/path.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/status/status_view.dart';
import 'package:lamatdating/views/status/components/ImagePicker/image_picker.dart';
import 'package:lamatdating/views/status/components/TextStatus/text_status.dart';
import 'package:lamatdating/views/status/components/VideoPicker/vid_picker.dart';
import 'package:lamatdating/views/status/components/circle_border.dart';
import 'package:lamatdating/views/status/components/show_viewers.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';

class Status extends ConsumerStatefulWidget {
  const Status({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.phoneNumberVariants,
    required this.currentUserFullname,
    required this.currentUserPhotourl,
    this.isShowAddStatusOnFirst = false,
  });
  final String? currentUserNo;
  final String? currentUserFullname;
  final String? currentUserPhotourl;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final List phoneNumberVariants;
  final bool? isShowAddStatusOnFirst;

  @override
  StatusState createState() => StatusState();
}

class StatusState extends ConsumerState<Status>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  loading() {
    return const Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
      ))
    ]);
  }

  late Stream myStatusUpdates;
  BannerAd? myBanner;
  AdWidget? adWidget;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  @override
  initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    myStatusUpdates = FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .doc(widget.currentUserNo)
        .snapshots();
    // forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final observer = ref.watch(observerProvider);
      if (widget.isShowAddStatusOnFirst == true &&
          observer.isAllowCreatingStatus == true) {
        Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => StatusImageEditor(
                      prefs: widget.prefs,
                      callback: (v, d) async {
                        Navigator.of(context).pop();
                        await uploadFile(
                            ref: ref,
                            filename: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            type: Dbkeys.statustypeIMAGE,
                            file: d,
                            caption: v);
                      },
                      title: "Create Status",
                    )));
      }
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
      // Interstital Ads
      if (IsInterstitialAdShow == true &&
          observer.isadmobshow == true &&
          !kIsWeb) {
        Future.delayed(const Duration(milliseconds: 3000), () {
          _createInterstitialAd();
        });
      }
    });
  }

  // forward() {
  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     final observer = Provider.of<Observer>(this.context, listen: false);
  //     if (widget.isShowAddStatusOnFirst == true &&
  //         observer.isAllowCreatingStatus == true) {
  //       Navigator.push(
  //           this.context,
  //           MaterialPageRoute(
  //               builder: (context) => StatusImageEditor(
  //                     callback: (v, d) async {
  //                       Navigator.of(context).pop();
  //                       await uploadFile(
  //                           filename: DateTime.now()
  //                               .millisecondsSinceEpoch
  //                               .toString(),
  //                           type: Dbkeys.statustypeIMAGE,
  //                           file: d,
  //                           caption: v);
  //                     },
  //                     title: "Create Status",
  //                   )));
  //     }
  //   });
  // }

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
          "${file.absolute.path.replaceAll(basename(file.absolute.path), "")}temp.jpg";

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

  @override
  void dispose() {
    super.dispose();
    if (IsInterstitialAdShow == true) {
      _interstitialAd!.dispose();
    }
    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final observer = ref.watch(observerProvider);
    final contactsProvider = ref.watch(smartContactProvider);
    final statusProvider = ref.watch(statusProviderProvider);

    return Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
        model: widget.model!,
        child:
            ScopedModelDescendant<DataModel>(builder: (context, child, model) {
          return Scaffold(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            floatingActionButton: Padding(
              padding: EdgeInsets.only(
                  bottom: IsBannerAdShow == true &&
                          observer.isadmobshow == true &&
                          !kIsWeb
                      ? 60
                      : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 43,
                    margin: const EdgeInsets.only(bottom: 18),
                    child: FloatingActionButton(
                        heroTag: "d636546yt834",
                        backgroundColor: const Color(0xffebecee),
                        onPressed: observer.isAllowCreatingStatus == false
                            ? () {
                                Lamat.showRationale(
                                  "This feature is temporarily disabled by Admin",
                                );
                              }
                            : () {
                                (!Responsive.isDesktop(context))
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TextStatus(
                                                currentuserNo:
                                                    widget.currentUserNo!,
                                                phoneNumberVariants: widget
                                                    .phoneNumberVariants)))
                                    : ref
                                        .read(arrangementProvider.notifier)
                                        .setArrangement(TextStatus(
                                            currentuserNo:
                                                widget.currentUserNo!,
                                            phoneNumberVariants:
                                                widget.phoneNumberVariants));
                              },
                        child: Icon(Icons.edit,
                            size: 23.0, color: Colors.blueGrey[700])),
                  ),
                  FloatingActionButton(
                    heroTag: "frewrwr",
                    backgroundColor: AppConstants.secondaryColor,
                    onPressed: observer.isAllowCreatingStatus == false
                        ? () {
                            Lamat.showRationale(
                              "This feature is temporarily disabled by Admin",
                            );
                          }
                        : () async {
                            showMediaOptions(
                                ishideTextStatusbutton: true,
                                phoneVariants: widget.phoneNumberVariants,
                                context: context,
                                ref: ref,
                                pickVideoCallback: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StatusVideoEditor(
                                                prefs: widget.prefs,
                                                callback: (v, d, t) async {
                                                  Navigator.of(context).pop();
                                                  await uploadFile(
                                                      filename: DateTime.now()
                                                          .millisecondsSinceEpoch
                                                          .toString(),
                                                      type: Dbkeys
                                                          .statustypeVIDEO,
                                                      file: d,
                                                      caption: v,
                                                      ref: ref,
                                                      duration: t);
                                                },
                                                title: "Create Status",
                                              )));
                                },
                                pickImageCallback: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StatusImageEditor(
                                                prefs: widget.prefs,
                                                callback: (v, d) async {
                                                  Navigator.of(context).pop();
                                                  await uploadFile(
                                                      filename: DateTime.now()
                                                          .millisecondsSinceEpoch
                                                          .toString(),
                                                      type: Dbkeys
                                                          .statustypeIMAGE,
                                                      file: d,
                                                      ref: ref,
                                                      caption: v);
                                                },
                                                title: "Create Status",
                                              )));
                                });
                          },
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppConstants.lamatWhite,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
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
            body: RefreshIndicator(
              onRefresh: () {
                statusProvider.searchContactStatus(
                    widget.currentUserNo!,
                    FutureGroup(),
                    contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer);
                return Future.value(true);
              },
              child: Padding(
                padding: EdgeInsets.only(
                    bottom:
                        IsBannerAdShow == true && observer.isadmobshow == true
                            ? 60
                            : 0),
                child: Stack(
                  children: [
                    Container(
                      color: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : const Color(0xfff2f2f2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 8, 8, 8),
                                        child: InkWell(
                                          onTap: () {},
                                          child: ListTile(
                                            leading: Stack(
                                              children: <Widget>[
                                                customCircleAvatar(radius: 35),
                                                Positioned(
                                                  bottom: 1.0,
                                                  right: 1.0,
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppConstants
                                                          .secondaryColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: const Text(
                                              "My Status",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: const Text(
                                              "Loading ...",
                                            ),
                                          ),
                                        )),
                                  );
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

                                  return Card(
                                    color: Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                    elevation: 0.0,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(3, 8, 8, 8),
                                      child: ListTile(
                                        leading: Stack(
                                          children: <Widget>[
                                            InkWell(
                                              onTap: () {
                                                !(Responsive.isDesktop(context))
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    StatusView(
                                                                      model: widget
                                                                          .model!,
                                                                      prefs: widget
                                                                          .prefs,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo!,
                                                                      statusDoc:
                                                                          snapshot
                                                                              .data,
                                                                      postedbyFullname:
                                                                          widget.currentUserFullname ??
                                                                              '',
                                                                      postedbyPhotourl:
                                                                          widget
                                                                              .currentUserPhotourl,
                                                                    )))
                                                    : ref
                                                        .read(
                                                            arrangementProvider
                                                                .notifier)
                                                        .setArrangement(
                                                            StatusView(
                                                          model: widget.model!,
                                                          prefs: widget.prefs,
                                                          currentUserNo: widget
                                                              .currentUserNo!,
                                                          statusDoc:
                                                              snapshot.data,
                                                          postedbyFullname:
                                                              widget.currentUserFullname ??
                                                                  '',
                                                          postedbyPhotourl: widget
                                                              .currentUserPhotourl,
                                                        ));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0),
                                                child: CircularBorder(
                                                  totalitems: snapshot
                                                      .data[Dbkeys
                                                          .statusITEMSLIST]
                                                      .length,
                                                  totalseen: seen,
                                                  width: 2.5,
                                                  size: 65,
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
                                                          ? AppConstants
                                                              .lamatGreenColor500
                                                              .withOpacity(0.8)
                                                          : Colors.grey
                                                              .withOpacity(0.8)
                                                      : Colors.grey
                                                          .withOpacity(0.8),
                                                  icon: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            3.0),
                                                    child: snapshot.data[Dbkeys.statusITEMSLIST]
                                                                    [snapshot.data[Dbkeys.statusITEMSLIST].length - 1]
                                                                [Dbkeys
                                                                    .statusItemTYPE] ==
                                                            Dbkeys
                                                                .statustypeTEXT
                                                        ? Container(
                                                            width: 50.0,
                                                            height: 50.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(int.parse(
                                                                  snapshot.data[
                                                                          Dbkeys
                                                                              .statusITEMSLIST]
                                                                      [
                                                                      snapshot.data[Dbkeys.statusITEMSLIST].length -
                                                                          1][Dbkeys
                                                                      .statusItemBGCOLOR],
                                                                  radix: 16)),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                            child: const Icon(
                                                                Icons
                                                                    .text_fields,
                                                                color: Colors
                                                                    .white54),
                                                          )
                                                        : snapshot.data[Dbkeys.statusITEMSLIST]
                                                                        [snapshot.data[Dbkeys.statusITEMSLIST].length - 1]
                                                                    [Dbkeys.statusItemTYPE] ==
                                                                Dbkeys.statustypeVIDEO
                                                            ? Container(
                                                                width: 50.0,
                                                                height: 50.0,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .black87,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: const Icon(
                                                                    Icons
                                                                        .play_circle_fill_rounded,
                                                                    color: Colors
                                                                        .white54),
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
                                                                imageBuilder:
                                                                    (context,
                                                                            imageProvider) =>
                                                                        Container(
                                                                  width: 50.0,
                                                                  height: 50.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover),
                                                                  ),
                                                                ),
                                                                placeholder:
                                                                    (context,
                                                                            url) =>
                                                                        Container(
                                                                  width: 50.0,
                                                                  height: 50.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Container(
                                                                  width: 50.0,
                                                                  height: 50.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .grey[
                                                                        300],
                                                                    shape: BoxShape
                                                                        .circle,
                                                                  ),
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 1.0,
                                              right: 1.0,
                                              child: InkWell(
                                                onTap:
                                                    observer.isAllowCreatingStatus ==
                                                            false
                                                        ? () {
                                                            Lamat.showRationale(
                                                              "This feature is temporarily disabled by Admin",
                                                            );
                                                          }
                                                        : () async {
                                                            showMediaOptions(
                                                                ishideTextStatusbutton:
                                                                    false,
                                                                phoneVariants:
                                                                    widget
                                                                        .phoneNumberVariants,
                                                                context:
                                                                    context,
                                                                ref: ref,
                                                                pickVideoCallback:
                                                                    () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => StatusVideoEditor(
                                                                                prefs: widget.prefs,
                                                                                callback: (v, d, t) async {
                                                                                  Navigator.of(context).pop();
                                                                                  await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeVIDEO, file: d, caption: v, ref: ref, duration: t);
                                                                                },
                                                                                title: "Create Status",
                                                                              )));
                                                                },
                                                                pickImageCallback:
                                                                    () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => StatusImageEditor(
                                                                                prefs: widget.prefs,
                                                                                callback: (v, d) async {
                                                                                  Navigator.of(context).pop();
                                                                                  await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeIMAGE, file: d, ref: ref, caption: v);
                                                                                },
                                                                                title: "Create Status",
                                                                              )));
                                                                });
                                                          },
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppConstants
                                                        .secondaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        StatusView(
                                                          model: widget.model!,
                                                          prefs: widget.prefs,
                                                          currentUserNo: widget
                                                              .currentUserNo!,
                                                          statusDoc:
                                                              snapshot.data,
                                                          postedbyFullname:
                                                              widget.currentUserFullname ??
                                                                  '',
                                                          postedbyPhotourl: widget
                                                              .currentUserPhotourl,
                                                        )));
                                          },
                                          child: Text(
                                            "My Status",
                                            style: TextStyle(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants.lamatWhite
                                                    : AppConstants.lamatBlack,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        subtitle: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StatusView(
                                                            model:
                                                                widget.model!,
                                                            prefs: widget.prefs,
                                                            currentUserNo: widget
                                                                .currentUserNo!,
                                                            statusDoc:
                                                                snapshot.data,
                                                            postedbyFullname:
                                                                widget.currentUserFullname ??
                                                                    '',
                                                            postedbyPhotourl: widget
                                                                .currentUserPhotourl,
                                                          )));
                                            },
                                            child: const Text(
                                              "Tap to view",
                                              style: TextStyle(
                                                  color:
                                                      AppConstants.primaryColor,
                                                  fontSize: 14),
                                            )),
                                        trailing: Container(
                                          alignment: Alignment.centerRight,
                                          width: 90,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: snapshot
                                                            .data[Dbkeys
                                                                .statusVIEWERLISTWITHTIME]
                                                            .length >
                                                        0
                                                    ? () {
                                                        showViewers(
                                                            context,
                                                            snapshot.data,
                                                            contactsProvider
                                                                .contactsBookContactList,
                                                            widget
                                                                .currentUserNo!,
                                                            widget.prefs,
                                                            widget.model!);
                                                      }
                                                    : () {},
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.visibility,
                                                      color: AppConstants
                                                          .lamatGrey,
                                                    ),
                                                    const SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      ' ${snapshot.data[Dbkeys.statusVIEWERLIST].length}',
                                                      style: TextStyle(
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .lamatWhite
                                                              : AppConstants
                                                                  .lamatBlack,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  deleteOptions(
                                                      context, snapshot.data);
                                                },
                                                child: const SizedBox(
                                                    width: 25,
                                                    child: Icon(Icons.edit,
                                                        color: AppConstants
                                                            .lamatGrey)),
                                              )
                                            ],
                                          ),
                                        ),
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
                                            0, 8, 8, 8),
                                        child: InkWell(
                                          onTap:
                                              observer.isAllowCreatingStatus ==
                                                      false
                                                  ? () {
                                                      Lamat.showRationale(
                                                        "This feature is temporarily disabled by Admin",
                                                      );
                                                    }
                                                  : () {
                                                      showMediaOptions(
                                                          ishideTextStatusbutton:
                                                              false,
                                                          phoneVariants: widget
                                                              .phoneNumberVariants,
                                                          context: context,
                                                          ref: ref,
                                                          pickVideoCallback:
                                                              () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StatusVideoEditor(
                                                                              prefs: widget.prefs,
                                                                              callback: (v, d, t) async {
                                                                                Navigator.of(context).pop();
                                                                                await uploadFile(duration: t, filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeVIDEO, file: d, ref: ref, caption: v);
                                                                              },
                                                                              title: "Create Status",
                                                                            )));
                                                          },
                                                          pickImageCallback:
                                                              () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            StatusImageEditor(
                                                                              prefs: widget.prefs,
                                                                              callback: (v, d) async {
                                                                                Navigator.of(context).pop();
                                                                                await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeIMAGE, file: d, ref: ref, caption: v);
                                                                              },
                                                                              title: "Create Status",
                                                                            )));
                                                          });
                                                    },
                                          child: ListTile(
                                            leading: Stack(
                                              children: <Widget>[
                                                customCircleAvatar(radius: 35),
                                                Positioned(
                                                  bottom: 1.0,
                                                  right: 1.0,
                                                  child: Container(
                                                    height: 20,
                                                    width: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: AppConstants
                                                          .secondaryColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            title: const Text(
                                              "My Status",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: const Text(
                                              "Tap to add status update",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        )),
                                  );
                                }
                                return Card(
                                  color: Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  elevation: 0.0,
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 8, 8, 8),
                                      child: InkWell(
                                        onTap: () {},
                                        child: ListTile(
                                          leading: Stack(
                                            children: <Widget>[
                                              customCircleAvatar(radius: 35),
                                              Positioned(
                                                bottom: 1.0,
                                                right: 1.0,
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppConstants
                                                        .secondaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          title: const Text(
                                            "My Status",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: const Text(
                                            "Loading ...",
                                          ),
                                        ),
                                      )),
                                );
                              }),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Recent updates",
                                  style: TextStyle(
                                      color: AppConstants.lamatGrey,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 13,
                                ),
                                statusProvider.searchingcontactsstatus == true
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(right: 17),
                                        height: 15,
                                        width: 15,
                                        color: Colors.transparent,
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 0),
                                            child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        AppConstants
                                                            .secondaryColor)),
                                          ),
                                        ))
                                    : const SizedBox()
                              ],
                            ),
                          ),
                          statusProvider.searchingcontactsstatus == true
                              ? Expanded(
                                  child: Container(
                                    color: Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                  ),
                                )
                              : statusProvider.contactsStatus.isEmpty
                                  ? Expanded(
                                      child: Container(
                                      color: Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                      child: Center(
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 40,
                                                left: 25,
                                                right: 25,
                                                bottom: 70),
                                            child: Text(
                                              "No Status in your Saved Contacts",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: AppConstants.lamatGrey
                                                      .withOpacity(0.8),
                                                  fontWeight: FontWeight.w400),
                                            )),
                                      ),
                                    ))
                                  : Expanded(
                                      child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 8, 8),
                                          color: Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(10),
                                            itemCount: statusProvider
                                                .contactsStatus.length,
                                            itemBuilder: (context, idx) {
                                              int seen = !statusProvider
                                                      .contactsStatus[idx]
                                                      .data()!
                                                      .containsKey(
                                                          widget.currentUserNo)
                                                  ? 0
                                                  : 0;
                                              if (statusProvider
                                                  .contactsStatus[idx]
                                                  .data()
                                                  .containsKey(
                                                      widget.currentUserNo)) {
                                                statusProvider
                                                    .contactsStatus[idx]
                                                        [Dbkeys.statusITEMSLIST]
                                                    .forEach((status) {
                                                  if (statusProvider
                                                      .contactsStatus[idx]
                                                      .data()[
                                                          widget.currentUserNo]
                                                      .contains(status[Dbkeys
                                                          .statusItemID])) {
                                                    seen = seen + 1;
                                                  }
                                                });
                                              }
                                              return FutureBuilder<
                                                      LocalUserData?>(
                                                  future: contactsProvider
                                                      .fetchUserDataFromnLocalOrServer(
                                                          widget.prefs,
                                                          statusProvider
                                                                  .contactsStatus[
                                                                      idx]
                                                                  .data()[
                                                              Dbkeys
                                                                  .statusPUBLISHERPHONE]),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              LocalUserData?>
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
                                                                              if (IsInterstitialAdShow == true && observer.isadmobshow == true && !kIsWeb) {
                                                                                Future.delayed(const Duration(milliseconds: 500), () {
                                                                                  _showInterstitialAd();
                                                                                });
                                                                              }
                                                                            },
                                                                            currentUserNo:
                                                                                widget.currentUserNo!,
                                                                            statusDoc:
                                                                                statusProvider.contactsStatus[idx],
                                                                            postedbyFullname:
                                                                                snapshot.data!.name,
                                                                            postedbyPhotourl:
                                                                                snapshot.data!.photoURL,
                                                                          )));
                                                        },
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  5, 6, 10, 6),
                                                          leading: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child:
                                                                CircularBorder(
                                                              totalitems: statusProvider
                                                                  .contactsStatus[
                                                                      idx][
                                                                      Dbkeys
                                                                          .statusITEMSLIST]
                                                                  .length,
                                                              totalseen: seen,
                                                              width: 2.5,
                                                              size: 65,
                                                              color: statusProvider
                                                                      .contactsStatus[
                                                                          idx]
                                                                      .data()
                                                                      .containsKey(
                                                                          widget
                                                                              .currentUserNo)
                                                                  ? statusProvider
                                                                              .contactsStatus[idx][Dbkeys
                                                                                  .statusITEMSLIST]
                                                                              .length >
                                                                          0
                                                                      ? AppConstants
                                                                          .lamatGreenColor500
                                                                          .withOpacity(
                                                                              0.8)
                                                                      : Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.8)
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.8),
                                                              icon: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        3.0),
                                                                child: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeTEXT
                                                                    ? Container(
                                                                        width:
                                                                            50.0,
                                                                        height:
                                                                            50.0,
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
                                                                    : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] == Dbkeys.statustypeVIDEO
                                                                        ? Container(
                                                                            width:
                                                                                50.0,
                                                                            height:
                                                                                50.0,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors.black87,
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                            child:
                                                                                const Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                          )
                                                                        : CachedNetworkImage(
                                                                            imageUrl:
                                                                                statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                            imageBuilder: (context, imageProvider) =>
                                                                                Container(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                            placeholder: (context, url) =>
                                                                                Container(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[300],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                            errorWidget: (context, url, error) =>
                                                                                Container(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.grey[300],
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                            ),
                                                                          ),
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            snapshot.data!.name,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          subtitle: Text(
                                                            getStatusTime(
                                                                statusProvider
                                                                        .contactsStatus[idx]
                                                                    [
                                                                    Dbkeys.statusITEMSLIST][statusProvider
                                                                        .contactsStatus[
                                                                            idx]
                                                                            [
                                                                            Dbkeys.statusITEMSLIST]
                                                                        .length -
                                                                    1][Dbkeys.statusItemID],
                                                                this.context,
                                                                ref),
                                                            style:
                                                                const TextStyle(
                                                                    height:
                                                                        1.4),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return InkWell(
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
                                                                                int i = statusProvider.contactsStatus.indexWhere((element) => element[Dbkeys.statusPUBLISHERPHONE] == statuspublisherphone);
                                                                                statusProvider.replaceStatus(i, doc.docs.first);
                                                                                setState(() {});
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
                                                                              widget.currentUserNo!,
                                                                          statusDoc:
                                                                              statusProvider.contactsStatus[idx],
                                                                          postedbyFullname: statusProvider
                                                                              .joinedUserPhoneStringAsInServer
                                                                              .elementAt(statusProvider.joinedUserPhoneStringAsInServer.toList().indexWhere((element) => statusProvider.contactsStatus[idx][Dbkeys.statusPUBLISHERPHONEVARIANTS].contains(element.phone.toString())))
                                                                              .name
                                                                              .toString(),
                                                                          postedbyPhotourl:
                                                                              null,
                                                                        )));
                                                      },
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                5, 6, 10, 6),
                                                        leading: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 5),
                                                          child: CircularBorder(
                                                            totalitems: statusProvider
                                                                .contactsStatus[
                                                                    idx][Dbkeys
                                                                        .statusITEMSLIST]
                                                                .length,
                                                            totalseen: seen,
                                                            width: 2.5,
                                                            size: 65,
                                                            color: statusProvider
                                                                    .contactsStatus[
                                                                        idx]
                                                                    .data()
                                                                    .containsKey(
                                                                        widget
                                                                            .currentUserNo)
                                                                ? statusProvider
                                                                            .contactsStatus[idx][Dbkeys
                                                                                .statusITEMSLIST]
                                                                            .length >
                                                                        0
                                                                    ? AppConstants
                                                                        .lamatGreenColor500
                                                                        .withOpacity(
                                                                            0.8)
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.8)
                                                                : Colors.grey
                                                                    .withOpacity(
                                                                        0.8),
                                                            icon: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(3.0),
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
                                                                              50.0,
                                                                          height:
                                                                              50.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(int.parse(statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemBGCOLOR], radix: 16)),
                                                                            shape:
                                                                                BoxShape.circle,
                                                                          ),
                                                                          child: const Icon(
                                                                              Icons.text_fields,
                                                                              color: Colors.white54),
                                                                        )
                                                                      : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemTYPE] ==
                                                                              Dbkeys.statustypeVIDEO
                                                                          ? Container(
                                                                              width: 50.0,
                                                                              height: 50.0,
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.black87,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white54),
                                                                            )
                                                                          : CachedNetworkImage(
                                                                              imageUrl: statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1][Dbkeys.statusItemURL],
                                                                              imageBuilder: (context, imageProvider) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                ),
                                                                              ),
                                                                              placeholder: (context, url) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey[300],
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                              ),
                                                                              errorWidget: (context, url, error) => Container(
                                                                                width: 50.0,
                                                                                height: 50.0,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.grey[300],
                                                                                  shape: BoxShape.circle,
                                                                                ),
                                                                              ),
                                                                            ),
                                                            ),
                                                          ),
                                                        ),
                                                        title: Text(
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
                                                        subtitle: Text(
                                                          getStatusTime(
                                                              statusProvider.contactsStatus[
                                                                          idx][
                                                                      Dbkeys
                                                                          .statusITEMSLIST]
                                                                  [
                                                                  statusProvider
                                                                          .contactsStatus[
                                                                              idx]
                                                                              [
                                                                              Dbkeys
                                                                                  .statusITEMSLIST]
                                                                          .length -
                                                                      1][Dbkeys
                                                                  .statusItemID],
                                                              this.context,
                                                              ref),
                                                          style:
                                                              const TextStyle(
                                                                  height: 1.4),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                          )),
                                    ),
                        ],
                      ),
                    ),
                    Positioned(
                      child: statusProvider.isLoading
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
                              ))
                          : Container(),
                    )
                  ],
                ),
              ),
            ),
          );
        })));
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
              builder: (context, ref, _child) => Container(
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
                                        "Image",
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
                                          "Video",
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
                                                      widget.currentUserNo!,
                                                  phoneNumberVariants:
                                                      phoneVariants)))
                                      : ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(TextStatus(
                                              currentuserNo:
                                                  widget.currentUserNo!,
                                              phoneNumberVariants:
                                                  phoneVariants));
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
                                        "Text",
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
                                        "Image",
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
                                          "Video",
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
              builder: (context, ref, _child) => Container(
                  padding: const EdgeInsets.all(12),
                  height: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "My Active Status",
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
                                                  "Delete Status ?",
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
                                                    child: const Text(
                                                      "Cancel ",
                                                      style: TextStyle(
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
                                                    child: const Text(
                                                      "Delete",
                                                      style: TextStyle(
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
