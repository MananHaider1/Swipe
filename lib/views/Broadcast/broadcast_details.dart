// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/Broadcast/add_contacts_to_broadcast.dart';
import 'package:lamatdating/views/Broadcast/edit_broadcast_details.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/profile_settings/profile_view.dart';
import 'package:lamatdating/widgets/ImagePicker/image_picker.dart';

class BroadcastDetails extends ConsumerStatefulWidget {
  final DataModel? model;
  final SharedPreferences prefs;
  final String currentUserno;
  final String broadcastID;
  const BroadcastDetails(
      {super.key,
      this.model,
      required this.prefs,
      required this.currentUserno,
      required this.broadcastID});

  @override
  BroadcastDetailsState createState() => BroadcastDetailsState();
}

class BroadcastDetailsState extends ConsumerState<BroadcastDetails> {
  File? imageFile;

  getImage(File image) {
    setStateIfMounted(() {
      imageFile = image;
    });
    return uploadFile(false);
  }

  bool isloading = false;
  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (!kIsWeb) {
        if (IsBannerAdShow == true && observer.isadmobshow == true) {
          myBanner!.load();
          adWidget = AdWidget(ad: myBanner!);
          setState(() {});
        }
      }
    });
  }

  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'BROADCAST_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);
    File? compressedImage;

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

    TaskSnapshot uploading = await reference.putFile(compressedImage!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }

    return uploading.ref.getDownloadURL();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  userAction(
    value,
    String targetPhone,
  ) async {
    if (value == 'Remove from List') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.dialogColorDark
                : AppConstants.backgroundColor,
            title: Text(
              "Remove from List",
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
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
                        color: AppConstants.secondaryColor, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  'remove'.tr(),
                  style: const TextStyle(
                      color: AppConstants.lamatREDbuttonColor, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionbroadcasts)
                      .doc(widget.broadcastID)
                      .update({
                    Dbkeys.broadcastMEMBERSLIST:
                        FieldValue.arrayRemove([targetPhone]),
                  }).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionbroadcasts)
                        .doc(widget.broadcastID)
                        .collection(DbPaths.collectionbroadcastsChats)
                        .doc(
                            '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                        .set({
                      Dbkeys.broadcastmsgCONTENT:
                          'You have removed $targetPhone',
                      Dbkeys.broadcastmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.broadcastmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.broadcastmsgSENDBY: widget.currentUserno,
                      Dbkeys.broadcastmsgISDELETED: false,
                      Dbkeys.broadcastmsgTYPE:
                          Dbkeys.broadcastmsgTYPEnotificationRemovedUser,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      if (!kIsWeb && myBanner != null) {
        myBanner!.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = ref.watch(observerProvider);
    final broadcastsList = ref.watch(broadcastsListProvider);
    final smartContactProviderWithLocalStoreData =
        ref.watch(smartContactProvider);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold:
            Lamat.getNTPWrappedWidget(Consumer(builder: (context, ref, child) {
          Map<dynamic, dynamic> broadcastDoc = {};

          broadcastsList.when(
            data: (broadcastList) {
              int index = broadcastList.indexWhere((element) =>
                  element.docmap[Dbkeys.broadcastID] == widget.broadcastID);
              if (index >= 0) {
                broadcastDoc = broadcastList[index].docmap;
              }
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error'),
          );

          return Consumer(
              builder: (context, ref, child) => Scaffold(
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
                                    : 25.0,
                                top: 0),
                            child: Center(child: adWidget),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    appBar: AppBar(
                      elevation: 0.4,
                      titleSpacing: -5,
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
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      actions: <Widget>[
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditBroadcastDetails(
                                            prefs: widget.prefs,
                                            currentUserNo: widget.currentUserno,
                                            isadmin: true,
                                            broadcastDesc: broadcastDoc[
                                                Dbkeys.broadcastDESCRIPTION],
                                            broadcastName: broadcastDoc[
                                                Dbkeys.broadcastNAME],
                                            broadcastID: widget.broadcastID,
                                          )));
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 21,
                              color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor),
                            ))
                      ],
                      backgroundColor: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor,
                      title: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              broadcastDoc[Dbkeys.broadcastNAME],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Created by you, ${formatDate(broadcastDoc[Dbkeys.broadcastCREATEDON].toDate())}',
                              style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                          Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor)
                                      .withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: EdgeInsets.only(
                          bottom: IsBannerAdShow == true &&
                                  observer.isadmobshow == true
                              ? 60
                              : 0),
                      child: Stack(
                        children: [
                          ListView(
                            children: [
                              Stack(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: broadcastDoc[
                                            Dbkeys.broadcastPHOTOURL] ??
                                        '',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Icon(Icons.campaign,
                                          color: AppConstants.lamatGrey
                                              .withOpacity(0.5),
                                          size: 75),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: w,
                                      height: w / 1.2,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: Icon(Icons.campaign,
                                          color: AppConstants.lamatGrey
                                              .withOpacity(0.5),
                                          size: 75),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    width: w,
                                    height: w / 1.2,
                                    decoration: BoxDecoration(
                                      color: broadcastDoc[
                                                  Dbkeys.broadcastPHOTOURL] ==
                                              null
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.black.withOpacity(0.4),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SingleImagePicker(
                                                            prefs: widget.prefs,
                                                            title:
                                                                'pleaseSelectImage'
                                                                    .tr(),
                                                            callback: getImage,
                                                          ))).then((url) async {
                                                if (url != null) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(DbPaths
                                                          .collectionbroadcasts)
                                                      .doc(widget.broadcastID)
                                                      .update({
                                                    Dbkeys.broadcastPHOTOURL:
                                                        url
                                                  }).then((value) async {
                                                    DateTime time =
                                                        DateTime.now();
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(DbPaths
                                                            .collectionbroadcasts)
                                                        .doc(widget.broadcastID)
                                                        .collection(DbPaths
                                                            .collectionbroadcastsChats)
                                                        .doc(
                                                            '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                                                        .set({
                                                      Dbkeys.broadcastmsgCONTENT:
                                                          'broadcastGroupIconChnagedByYou'
                                                              .tr(),
                                                      Dbkeys.broadcastmsgLISToptional:
                                                          [],
                                                      Dbkeys.broadcastmsgTIME: time
                                                          .millisecondsSinceEpoch,
                                                      Dbkeys.broadcastmsgSENDBY:
                                                          widget.currentUserno,
                                                      Dbkeys.broadcastmsgISDELETED:
                                                          false,
                                                      Dbkeys.broadcastmsgTYPE:
                                                          Dbkeys
                                                              .broadcastmsgTYPEnotificationUpdatedbroadcasticon,
                                                    });
                                                  });
                                                } else {}
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.camera_alt_rounded,
                                                color: AppConstants.lamatWhite,
                                                size: 35),
                                          ),
                                          broadcastDoc[Dbkeys
                                                      .broadcastPHOTOURL] ==
                                                  null
                                              ? const SizedBox()
                                              : IconButton(
                                                  onPressed: () async {
                                                    Lamat.toast(
                                                      'plswait'.tr(),
                                                    );
                                                    await FirebaseStorage
                                                        .instance
                                                        .refFromURL(
                                                            broadcastDoc[Dbkeys
                                                                .broadcastPHOTOURL])
                                                        .delete()
                                                        .then((d) async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .update({
                                                        Dbkeys.broadcastPHOTOURL:
                                                            null,
                                                      });
                                                      DateTime time =
                                                          DateTime.now();
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .collection(DbPaths
                                                              .collectionbroadcastsChats)
                                                          .doc(
                                                              '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                                                          .set({
                                                        Dbkeys.broadcastmsgCONTENT:
                                                            "Broadcast Group Icon deleted by You",
                                                        Dbkeys.broadcastmsgLISToptional:
                                                            [],
                                                        Dbkeys.broadcastmsgTIME:
                                                            time.millisecondsSinceEpoch,
                                                        Dbkeys.broadcastmsgSENDBY:
                                                            widget
                                                                .currentUserno,
                                                        Dbkeys.broadcastmsgISDELETED:
                                                            false,
                                                        Dbkeys.broadcastmsgTYPE:
                                                            Dbkeys
                                                                .broadcastmsgTYPEnotificationDeletedbroadcasticon,
                                                      });
                                                    }).catchError(
                                                            (error) async {
                                                      if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound2) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound3) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound4)) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionbroadcasts)
                                                            .doc(widget
                                                                .broadcastID)
                                                            .update({
                                                          Dbkeys.broadcastPHOTOURL:
                                                              null,
                                                        });
                                                      }
                                                    });
                                                  },
                                                  icon: const Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color: AppConstants
                                                          .lamatWhite,
                                                      size: 35),
                                                ),
                                        ],
                                      ),
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Description",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppConstants.primaryColor,
                                              fontSize: 16),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  this.context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditBroadcastDetails(
                                                            prefs: widget.prefs,
                                                            currentUserNo: widget
                                                                .currentUserno,
                                                            isadmin: true,
                                                            broadcastDesc:
                                                                broadcastDoc[Dbkeys
                                                                    .broadcastDESCRIPTION],
                                                            broadcastName:
                                                                broadcastDoc[Dbkeys
                                                                    .broadcastNAME],
                                                            broadcastID: widget
                                                                .broadcastID,
                                                          )));
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AppConstants.lamatGrey,
                                            ))
                                      ],
                                    ),
                                    const Divider(),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    broadcastsList.when(
                                      data: (broadcastList) {
                                        final broadcast =
                                            broadcastList.lastWhere((element) =>
                                                element.docmap[
                                                    Dbkeys.broadcastID] ==
                                                widget.broadcastID);
                                        return Text(
                                          broadcastDoc[Dbkeys
                                                      .broadcastDESCRIPTION] ==
                                                  ''
                                              ? "No Description"
                                              : broadcast.docmap[
                                                  Dbkeys.broadcastDESCRIPTION],
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color:
                                                pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor),
                                            fontSize: 15.3,
                                          ),
                                        );
                                      },
                                      loading: () =>
                                          const CircularProgressIndicator(),
                                      error: (_, __) => const Text('Error'),
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
                              Container(
                                color: Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              broadcastsList.when(
                                                data: (broadcastsList) {
                                                  final broadcast = broadcastsList
                                                      .lastWhere((element) =>
                                                          element.docmap[Dbkeys
                                                              .broadcastID] ==
                                                          widget.broadcastID);
                                                  return Text(
                                                    '${broadcast.docmap[Dbkeys.broadcastMEMBERSLIST].length} recipients',
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppConstants
                                                          .secondaryColor,
                                                      fontSize: 16,
                                                    ),
                                                  );
                                                },
                                                loading: () =>
                                                    const CircularProgressIndicator(),
                                                error: (_, __) =>
                                                    const Text('Error'),
                                              )
                                            ],
                                          ),
                                        ),
                                        (broadcastDoc[Dbkeys
                                                        .broadcastMEMBERSLIST]
                                                    .length >=
                                                observer.broadcastMemberslimit)
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  smartContactProviderWithLocalStoreData
                                                      .fetchContacts(
                                                          context,
                                                          widget.model,
                                                          widget.currentUserno,
                                                          widget.prefs,
                                                          true);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AddContactsToBroadcast(
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserno,
                                                                model: widget
                                                                    .model,
                                                                biometricEnabled:
                                                                    false,
                                                                prefs: widget
                                                                    .prefs,
                                                                broadcastID: widget
                                                                    .broadcastID,
                                                                isAddingWhileCreatingBroadcast:
                                                                    false,
                                                              )));
                                                },
                                                child: const SizedBox(
                                                  height: 50,
                                                  // width: 70,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Icon(Icons.add,
                                                            size: 19,
                                                            color: AppConstants
                                                                .secondaryColor),
                                                      ),
                                                      // Text(
                                                      //   'ADD ',
                                                      //   style: TextStyle(
                                                      //       fontWeight:
                                                      //           FontWeight.bold,
                                                      //       color:
                                                      //           lamatLightGreen),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                    // Divider(),
                                    getUsersList(),
                                  ],
                                ),
                              ),
                              widget.currentUserno ==
                                      broadcastDoc[Dbkeys.broadcastCREATEDBY]
                                  ? InkWell(
                                      onTap: () {
                                        showDialog(
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .dialogColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                              title: Text(
                                                "Delete Broadcast",
                                                style: TextStyle(
                                                  color: pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .dialogColorDark
                                                          : AppConstants
                                                              .backgroundColor),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    'cancel'.tr(),
                                                    style: const TextStyle(
                                                        color: AppConstants
                                                            .primaryColor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                  ),
                                                  child: Text(
                                                    'delete'.tr(),
                                                    style: const TextStyle(
                                                        color: AppConstants
                                                            .lamatREDbuttonColor,
                                                        fontSize: 18),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();
                                                    Navigator.of(context).pop();

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .get()
                                                          .then((doc) async {
                                                        await doc.reference
                                                            .delete();
                                                        //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                                                      });
                                                    });
                                                  },
                                                )
                                              ],
                                            );
                                          },
                                          context: context,
                                        );
                                      },
                                      child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.fromLTRB(
                                              10, 30, 10, 30),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 48.0,
                                          decoration: BoxDecoration(
                                            color: AppConstants
                                                .lamatREDbuttonColor,
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: const Text(
                                            "Delete Broadcast",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16),
                                          )),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                          Positioned(
                            child: isloading
                                ? Container(
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                            !Teme.isDarktheme(widget.prefs)
                                                ? AppConstants
                                                    .backgroundColorDark
                                                : AppConstants.backgroundColor)
                                        .withOpacity(0.6),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppConstants.secondaryColor)),
                                    ))
                                : Container(),
                          )
                        ],
                      ),
                    ),
                  ));
        })));
  }

  getUsersList() {
    // final observer = ref.watch(observerProvider);
    final broadcastsList = ref.watch(broadcastsListProvider);
    final smartContactProviderWithLocalStoreData =
        ref.watch(smartContactProvider);
    return Consumer(builder: (context, ref, child) {
      Map<dynamic, dynamic>? broadcastDoc;

      broadcastsList.when(
        data: (broadcastList) {
          int index = broadcastList.indexWhere((element) =>
              element.docmap[Dbkeys.broadcastID] == widget.broadcastID);
          if (index >= 0) {
            broadcastDoc = broadcastList[index].docmap;
          }
        },
        loading: () => const CircularProgressIndicator(),
        error: (_, __) => const Text('Error'),
      );

      return Consumer(builder: (context, ref, child) {
        List onlyuserslist = broadcastDoc![Dbkeys.broadcastMEMBERSLIST];
        broadcastDoc![Dbkeys.broadcastMEMBERSLIST].toList().forEach((member) {
          if (broadcastDoc![Dbkeys.broadcastADMINLIST].contains(member)) {
            onlyuserslist.remove(member);
          }
        });
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: onlyuserslist.length,
            itemBuilder: (context, int i) {
              List viewerslist = onlyuserslist;
              return FutureBuilder<LocalUserData?>(
                  future: smartContactProviderWithLocalStoreData
                      .fetchUserDataFromnLocalOrServer(
                          widget.prefs, viewerslist[i]),
                  builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Divider(
                            height: 3,
                          ),
                          Stack(
                            children: [
                              ListTile(
                                trailing: SizedBox(
                                  width: 30,
                                  child: PopupMenuButton<String>(
                                      color: Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.dialogColorDark
                                          : AppConstants.backgroundColor,
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'Remove from List',
                                              child: Text(
                                                "Remove from List",
                                                style: TextStyle(
                                                    color: pickTextColorBasedOnBgColorAdvanced(
                                                        Teme.isDarktheme(
                                                                widget.prefs)
                                                            ? AppConstants
                                                                .dialogColorDark
                                                            : AppConstants
                                                                .backgroundColor)),
                                              ),
                                            ),
                                          ],
                                      onSelected: (String value) {
                                        userAction(
                                          value,
                                          viewerslist[i],
                                        );
                                      },
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        size: 20,
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                      )),
                                ),
                                isThreeLine: false,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: snapshot.data!.photoURL == ''
                                        ? Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.person),
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: snapshot.data!.photoURL,
                                            imageBuilder: (context, imageProvider) =>
                                                Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                            placeholder: (context, url) =>
                                                Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    SizedBox(
                                                      width: 40,
                                                      height: 40,
                                                      child: customCircleAvatar(
                                                          radius: 40),
                                                    )),
                                  ),
                                ),
                                title: Text(
                                  smartContactProviderWithLocalStoreData
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]) >
                                          0
                                      ? smartContactProviderWithLocalStoreData
                                          .contactsBookContactList!.entries
                                          .elementAt(
                                              smartContactProviderWithLocalStoreData
                                                  .contactsBookContactList!
                                                  .entries
                                                  .toList()
                                                  .indexWhere((element) =>
                                                      element.key ==
                                                      viewerslist[i]))
                                          .value
                                          .toString()
                                      : snapshot.data!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor),
                                  ),
                                ),
                                subtitle: Text(
                                  //-- or about me
                                  snapshot.data!.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      height: 1.4,
                                      color: AppConstants.lamatGrey),
                                ),
                                onTap: widget.currentUserno == snapshot.data!.id
                                    ? () {}
                                    : () async {
                                        await smartContactProviderWithLocalStoreData
                                            .fetchFromFiretsoreAndReturnData(
                                                widget.prefs, snapshot.data!.id,
                                                (doc) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileView(
                                                          doc.data()!,
                                                          widget.currentUserno,
                                                          widget.model,
                                                          widget.prefs,
                                                          const [],
                                                          firestoreUserDoc:
                                                              null)));
                                        });
                                      },
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(
                          height: 3,
                        ),
                        Stack(
                          children: [
                            ListTile(
                              isThreeLine: false,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: CachedNetworkImage(
                                      imageUrl: '',
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                      placeholder: (context, url) => Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      errorWidget: (context, url, error) =>
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child:
                                                customCircleAvatar(radius: 40),
                                          )),
                                ),
                              ),
                              title: Text(
                                smartContactProviderWithLocalStoreData
                                            .contactsBookContactList!.entries
                                            .toList()
                                            .indexWhere((element) =>
                                                element.key == viewerslist[i]) >
                                        0
                                    ? smartContactProviderWithLocalStoreData
                                        .contactsBookContactList!.entries
                                        .elementAt(
                                            smartContactProviderWithLocalStoreData
                                                .contactsBookContactList!
                                                .entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    viewerslist[i]))
                                        .value
                                        .toString()
                                    : viewerslist[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                              ),
                              subtitle: const Text(
                                '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            });
      });
    });
  }
}

formatDate(DateTime timeToFormat) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(timeToFormat);
  return formatted;
}
