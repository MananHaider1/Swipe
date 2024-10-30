// ignore_for_file: library_private_types_in_public_api, empty_catches, no_leading_underscores_for_local_identifiers

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

import 'package:lamatdating/generated/locale_keys.g.dart';
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
import 'package:lamatdating/views/Groups/group_details_edit.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/profile_settings/profile_view.dart';
import 'package:lamatdating/widgets/ImagePicker/image_picker.dart';

class ChannelDetails extends ConsumerStatefulWidget {
  final DataModel model;
  final SharedPreferences prefs;
  final String currentUserno;
  final String groupID;
  const ChannelDetails(
      {super.key,
      required this.model,
      required this.prefs,
      required this.currentUserno,
      required this.groupID});

  @override
  ChannelDetailsState createState() => ChannelDetailsState();
}

class ChannelDetailsState extends ConsumerState<ChannelDetails> {
  File? imageFile;

  getImage(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setStateIfMounted(() {
        imageFile = image;
      });
    }
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
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'GROUP_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
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

  userAction(value, String targetPhone, bool targetPhoneIsAdmin,
      List targetUserNotificationTokens) async {
    if (value == 'Remove as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.dialogColorDark
                : AppConstants.backgroundColor,
            title: Text(
              LocaleKeys.removeasadmin.tr(),
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
                    LocaleKeys.cancel.tr(),
                    style: const TextStyle(
                        color: AppConstants.primaryColor, fontSize: 18),
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
                  LocaleKeys.confirm.tr(),
                  style: const TextStyle(
                      color: AppConstants.lamatREDbuttonColor, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionchannels)
                      .doc(widget.groupID)
                      .update({
                    Dbkeys.groupADMINLIST:
                        FieldValue.arrayRemove([targetPhone]),
                  }).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionchannels)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(
                            '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                        .set({
                      Dbkeys.groupmsgCONTENT: '',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    Lamat.toast('${LocaleKeys.error.tr()} -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    } else if (value == 'Set as Admin') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.dialogColorDark
                : AppConstants.backgroundColor,
            title: Text(
              LocaleKeys.setasadmin.tr(),
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
                    LocaleKeys.cancel.tr(),
                    style: const TextStyle(
                        color: AppConstants.primaryColor, fontSize: 18),
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
                  LocaleKeys.confirm.tr(),
                  style: const TextStyle(
                      color: AppConstants.lamatREDbuttonColor, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionchannels)
                      .doc(widget.groupID)
                      .update({
                    Dbkeys.groupADMINLIST: FieldValue.arrayUnion([targetPhone]),
                  }).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionchannels)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(
                            '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                        .set({
                      Dbkeys.groupmsgCONTENT: '',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    Lamat.toast('${LocaleKeys.error.tr()} -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    } else if (value == 'Remove from Group') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.dialogColorDark
                : AppConstants.backgroundColor,
            title: Text(
              LocaleKeys.removefromgroup.tr(),
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
                    LocaleKeys.cancel.tr(),
                    style: const TextStyle(
                        color: AppConstants.primaryColor, fontSize: 18),
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
                  LocaleKeys.remove.tr(),
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  try {
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectiontemptokensforunsubscribe)
                        .doc(targetPhone)
                        .delete();
                  } catch (err) {}
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiontemptokensforunsubscribe)
                      .doc(targetPhone)
                      .set({
                    Dbkeys.groupIDfiltered: widget.groupID
                        .replaceAll(RegExp('-'), '')
                        .substring(
                            1,
                            widget.groupID
                                .replaceAll(RegExp('-'), '')
                                .toString()
                                .length),
                    Dbkeys.notificationTokens: targetUserNotificationTokens,
                    'type': 'unsubscribe'
                  });

                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionchannels)
                      .doc(widget.groupID)
                      .update(targetPhoneIsAdmin == true
                          ? {
                              Dbkeys.groupMEMBERSLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              Dbkeys.groupADMINLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              targetPhone: FieldValue.delete(),
                              '$targetPhone-joinedOn': FieldValue.delete(),
                              targetPhone: FieldValue.delete(),
                            }
                          : {
                              Dbkeys.groupMEMBERSLIST:
                                  FieldValue.arrayRemove([targetPhone]),
                              targetPhone: FieldValue.delete(),
                              '$targetPhone-joinedOn': FieldValue.delete(),
                              targetPhone: FieldValue.delete(),
                            })
                      .then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionchannels)
                        .doc(widget.groupID)
                        .collection(DbPaths.collectiongroupChats)
                        .doc(
                            '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                        .set({
                      Dbkeys.groupmsgCONTENT:
                          '$targetPhone ${LocaleKeys.removedbyadmin.tr()}',
                      Dbkeys.groupmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.groupmsgSENDBY: widget.currentUserno,
                      Dbkeys.groupmsgISDELETED: false,
                      Dbkeys.groupmsgTYPE:
                          Dbkeys.groupmsgTYPEnotificationRemovedUser,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    try {
                      await FirebaseFirestore.instance
                          .collection(
                              DbPaths.collectiontemptokensforunsubscribe)
                          .doc(targetPhone)
                          .delete();
                    } catch (err) {}
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    // Lamat.toast(
                    //     'Failed to remove ! \nError occured -$onError');
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

    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final groupList = ref.watch(channelsListProvider);
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
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
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
              groupDoc[Dbkeys.groupADMINLIST].contains(widget.currentUserno)
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                            this.context,
                            MaterialPageRoute(
                                builder: (context) => EditGroupDetails(
                                      prefs: widget.prefs,
                                      currentUserNo: widget.currentUserno,
                                      isadmin:
                                          groupDoc[Dbkeys.groupCREATEDBY] ==
                                              widget.currentUserno,
                                      groupType: groupDoc[Dbkeys.groupTYPE],
                                      groupDesc:
                                          groupDoc[Dbkeys.groupDESCRIPTION],
                                      groupName: groupDoc[Dbkeys.groupNAME],
                                      groupID: widget.groupID,
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
                  : const SizedBox()
            ],
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            title: InkWell(
              onTap: () {
                // Navigator.push(
                //     context,
                //     PageRouteBuilder(
                //         opaque: false,
                //         pageBuilder: (context, a1, a2) =>
                //             ProfileView(peer)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupDoc[Dbkeys.groupNAME],
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
                    widget.currentUserno == groupDoc[Dbkeys.groupCREATEDBY]
                        ? '${LocaleKeys.createdbyu.tr()} ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}'
                        : '${LocaleKeys.createdby.tr()} ${groupDoc[Dbkeys.groupCREATEDBY]}, ${formatDate(groupDoc[Dbkeys.groupCREATEDON].toDate())}',
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
                bottom: IsBannerAdShow == true && observer.isadmobshow == true
                    ? 60
                    : 0),
            child: Stack(
              children: [
                ListView(
                  children: [
                    Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: groupDoc[Dbkeys.groupPHOTOURL] ?? '',
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
                            child: Icon(Icons.people,
                                color: AppConstants.lamatGrey.withOpacity(0.5),
                                size: 75),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: w,
                            height: w / 1.2,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                            ),
                            child: Icon(Icons.people,
                                color: AppConstants.lamatGrey.withOpacity(0.5),
                                size: 75),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          width: w,
                          height: w / 1.2,
                          decoration: BoxDecoration(
                            color: groupDoc[Dbkeys.groupPHOTOURL] == null
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.4),
                            shape: BoxShape.rectangle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                groupDoc[Dbkeys.groupADMINLIST]
                                        .contains(widget.currentUserno)
                                    ? IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SingleImagePicker(
                                                        prefs: widget.prefs,
                                                        title: LocaleKeys
                                                            .pickimage
                                                            .tr(),
                                                        callback: getImage,
                                                      ))).then((url) async {
                                            if (url != null) {
                                              await FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionchannels)
                                                  .doc(widget.groupID)
                                                  .update({
                                                Dbkeys.groupPHOTOURL: url
                                              }).then((value) async {
                                                DateTime time = DateTime.now();
                                                await FirebaseFirestore.instance
                                                    .collection(DbPaths
                                                        .collectionchannels)
                                                    .doc(widget.groupID)
                                                    .collection(DbPaths
                                                        .collectiongroupChats)
                                                    .doc(
                                                        '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                                                    .set({
                                                  Dbkeys
                                                      .groupmsgCONTENT: groupDoc[
                                                              Dbkeys
                                                                  .groupCREATEDBY] ==
                                                          widget.currentUserno
                                                      ? '${LocaleKeys.grpiconchangedby.tr()} ${LocaleKeys.admin.tr()}'
                                                      : '${LocaleKeys.grpiconchangedby.tr()} ${widget.currentUserno}',
                                                  Dbkeys.groupmsgLISToptional:
                                                      [],
                                                  Dbkeys.groupmsgTIME: time
                                                      .millisecondsSinceEpoch,
                                                  Dbkeys.groupmsgSENDBY:
                                                      widget.currentUserno,
                                                  Dbkeys.groupmsgISDELETED:
                                                      false,
                                                  Dbkeys.groupmsgTYPE: Dbkeys
                                                      .groupmsgTYPEnotificationUpdatedGroupicon,
                                                });
                                              });
                                            } else {}
                                          });
                                        },
                                        icon: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: AppConstants.lamatWhite,
                                            size: 35),
                                      )
                                    : const SizedBox(),
                                groupDoc[Dbkeys.groupPHOTOURL] == null ||
                                        groupDoc[Dbkeys.groupCREATEDBY] !=
                                            widget.currentUserno
                                    ? const SizedBox()
                                    : groupDoc[Dbkeys.groupADMINLIST]
                                            .contains(widget.currentUserno)
                                        ? IconButton(
                                            onPressed: () async {
                                              Lamat.toast(
                                                LocaleKeys.plswait.tr(),
                                              );
                                              await FirebaseStorage.instance
                                                  .refFromURL(groupDoc[
                                                      Dbkeys.groupPHOTOURL])
                                                  .delete()
                                                  .then((d) async {
                                                await FirebaseFirestore.instance
                                                    .collection(DbPaths
                                                        .collectionchannels)
                                                    .doc(widget.groupID)
                                                    .update({
                                                  Dbkeys.groupPHOTOURL: null,
                                                });
                                                DateTime time = DateTime.now();
                                                await FirebaseFirestore.instance
                                                    .collection(DbPaths
                                                        .collectionchannels)
                                                    .doc(widget.groupID)
                                                    .collection(DbPaths
                                                        .collectiongroupChats)
                                                    .doc(
                                                        '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                                                    .set({
                                                  Dbkeys
                                                      .groupmsgCONTENT: groupDoc[
                                                              Dbkeys
                                                                  .groupCREATEDBY] ==
                                                          widget.currentUserno
                                                      ? '${LocaleKeys.grpicondeletedby.tr()} ${LocaleKeys.admin.tr()}'
                                                      : '${LocaleKeys.grpicondeletedby.tr()} ${widget.currentUserno}',
                                                  Dbkeys.groupmsgLISToptional:
                                                      [],
                                                  Dbkeys.groupmsgTIME: time
                                                      .millisecondsSinceEpoch,
                                                  Dbkeys.groupmsgSENDBY:
                                                      widget.currentUserno,
                                                  Dbkeys.groupmsgISDELETED:
                                                      false,
                                                  Dbkeys.groupmsgTYPE: Dbkeys
                                                      .groupmsgTYPEnotificationDeletedGroupicon,
                                                });
                                              }).catchError((error) async {
                                                if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                    error.toString().contains(Dbkeys
                                                        .firebaseStorageNoObjectFound2) ||
                                                    error.toString().contains(Dbkeys
                                                        .firebaseStorageNoObjectFound3) ||
                                                    error.toString().contains(Dbkeys
                                                        .firebaseStorageNoObjectFound4)) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(DbPaths
                                                          .collectionchannels)
                                                      .doc(widget.groupID)
                                                      .update({
                                                    Dbkeys.groupPHOTOURL: null,
                                                  });
                                                }
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: AppConstants.lamatWhite,
                                                size: 35),
                                          )
                                        : const SizedBox(),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.desc.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 16),
                              ),
                              groupDoc[Dbkeys.groupADMINLIST]
                                      .contains(widget.currentUserno)
                                  ? IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditGroupDetails(
                                                      prefs: widget.prefs,
                                                      currentUserNo:
                                                          widget.currentUserno,
                                                      isadmin: groupDoc[Dbkeys
                                                              .groupCREATEDBY] ==
                                                          widget.currentUserno,
                                                      groupType: groupDoc[
                                                          Dbkeys.groupTYPE],
                                                      groupDesc: groupDoc[Dbkeys
                                                          .groupDESCRIPTION],
                                                      groupName: groupDoc[
                                                          Dbkeys.groupNAME],
                                                      groupID: widget.groupID,
                                                    )));
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppConstants.lamatGrey,
                                      ))
                                  : const SizedBox()
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 7,
                          ),
                          groupList.when(
                            data: (groupLists) {
                              return Text(
                                groupDoc[Dbkeys.groupDESCRIPTION] == ''
                                    ? LocaleKeys.nodesc.tr()
                                    : groupLists
                                        .lastWhere((element) =>
                                            element.docmap[Dbkeys.groupID] ==
                                            widget.groupID)
                                        .docmap[Dbkeys.groupDESCRIPTION],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                  fontSize: 15.3,
                                ),
                              );
                            },
                            loading: () =>
                                const CircularProgressIndicator(), // return a loading widget if necessary
                            error: (_, __) => const Icon(
                                Icons.error), // handle error state if necessary
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.grouptype.tr(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                    fontSize: 16),
                              ),
                              groupDoc[Dbkeys.groupADMINLIST]
                                      .contains(widget.currentUserno)
                                  ? IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditGroupDetails(
                                                      prefs: widget.prefs,
                                                      currentUserNo:
                                                          widget.currentUserno,
                                                      isadmin: groupDoc[Dbkeys
                                                              .groupCREATEDBY] ==
                                                          widget.currentUserno,
                                                      groupType: groupDoc[
                                                          Dbkeys.groupTYPE],
                                                      groupDesc: groupDoc[Dbkeys
                                                          .groupDESCRIPTION],
                                                      groupName: groupDoc[
                                                          Dbkeys.groupNAME],
                                                      groupID: widget.groupID,
                                                    )));
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: AppConstants.lamatGrey,
                                      ))
                                  : const SizedBox()
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            groupDoc[Dbkeys.groupTYPE] ==
                                    Dbkeys.groupTYPEonlyadminmessageallowed
                                ? LocaleKeys.onlyadmin.tr()
                                : LocaleKeys.bothuseradmin.tr(),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                                fontSize: 15.3),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                // width: 150,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    groupList.when(
                                      data: (groupLists) {
                                        return Text(
                                          '${groupLists.firstWhere((element) => element.docmap[Dbkeys.groupID] == widget.groupID).docmap[Dbkeys.groupMEMBERSLIST].length} ${LocaleKeys.followers.tr()}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.primaryColor,
                                            fontSize: 16,
                                          ),
                                        );
                                      },
                                      loading: () =>
                                          const CircularProgressIndicator(), // return a loading widget if necessary
                                      error: (_, __) => const Icon(Icons
                                          .error), // handle error state if necessary
                                    ),
                                  ],
                                ),
                              ),
                              // (groupDoc[Dbkeys.groupMEMBERSLIST].length >=
                              //             observer.groupMemberslimit) ||
                              //         !(groupDoc[Dbkeys.groupADMINLIST]
                              //             .contains(widget.currentUserno))
                              //     ? const SizedBox()
                              //     : InkWell(
                              //         onTap: () {
                              //           availableContacts.fetchContacts(
                              //               context,
                              //               widget.model,
                              //               widget.currentUserno,
                              //               widget.prefs,
                              //               false);
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       AddContactsToGroup(
                              //                         currentUserNo:
                              //                             widget.currentUserno,
                              //                         model: widget.model,
                              //                         biometricEnabled: false,
                              //                         prefs: widget.prefs,
                              //                         groupID: widget.groupID,
                              //                         isAddingWhileCreatingGroup:
                              //                             false,
                              //                       )));
                              //         },
                              //         child: const SizedBox(
                              //           height: 50,
                              //           // width: 70,
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.end,
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.center,
                              //             children: [
                              //               SizedBox(
                              //                 width: 30,
                              //                 child: Icon(Icons.add,
                              //                     size: 19,
                              //                     color: AppConstants.primaryColor),
                              //               ),
                              //             ],
                              //           ),
                              //         ),
                              //       ),
                            ],
                          ),
                          // getAdminList(),
                          // getUsersList(),
                        ],
                      ),
                    ),
                    widget.currentUserno == groupDoc[Dbkeys.groupCREATEDBY]
                        ? InkWell(
                            onTap: () {
                              showDialog(
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.dialogColorDark
                                            : AppConstants.backgroundColor,
                                    title: Text(LocaleKeys.deletegroup.tr()),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          LocaleKeys.cancel.tr(),
                                          style: const TextStyle(
                                              color: AppConstants.primaryColor,
                                              fontSize: 18),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          LocaleKeys.delete.tr(),
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
                                              const Duration(milliseconds: 500),
                                              () async {
                                            await FirebaseFirestore.instance
                                                .collection(
                                                    DbPaths.collectionchannels)
                                                .doc(widget.groupID)
                                                .get()
                                                .then((doc) async {
                                              await doc.reference.delete();
                                            });

                                            await FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectiontemptokensforunsubscribe)
                                                .doc(widget.groupID)
                                                .delete();
                                            //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
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
                                margin:
                                    const EdgeInsets.fromLTRB(10, 30, 10, 30),
                                width: MediaQuery.of(context).size.width,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: AppConstants.lamatREDbuttonColor,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Text(
                                  LocaleKeys.deletegroup.tr(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
                                )),
                          )
                        : InkWell(
                            onTap: () {
                              showDialog(
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.dialogColorDark
                                            : AppConstants.backgroundColor,
                                    title: Text(
                                      LocaleKeys.leavegroup.tr(),
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
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          LocaleKeys.cancel.tr(),
                                          style: const TextStyle(
                                              color: AppConstants.primaryColor,
                                              fontSize: 18),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                        ),
                                        child: Text(
                                          LocaleKeys.leave.tr(),
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
                                              const Duration(milliseconds: 300),
                                              () async {
                                            DateTime time = DateTime.now();
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectiontemptokensforunsubscribe)
                                                  .doc(widget.currentUserno)
                                                  .delete();
                                            } catch (err) {}
                                            await FirebaseFirestore.instance
                                                .collection(DbPaths
                                                    .collectiontemptokensforunsubscribe)
                                                .doc(widget.currentUserno)
                                                .set({
                                              Dbkeys.groupIDfiltered: widget
                                                  .groupID
                                                  .replaceAll(RegExp('-'), '')
                                                  .substring(
                                                      1,
                                                      widget.groupID
                                                          .replaceAll(
                                                              RegExp('-'), '')
                                                          .toString()
                                                          .length),
                                              Dbkeys.notificationTokens: widget
                                                          .model.currentUser![
                                                      Dbkeys
                                                          .notificationTokens] ??
                                                  [],
                                              'type': 'unsubscribe'
                                            }).then((value) async {
                                              await FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionchannels)
                                                  .doc(widget.groupID)
                                                  .update(groupDoc[Dbkeys
                                                              .groupADMINLIST]
                                                          .contains(widget
                                                              .currentUserno)
                                                      ? {
                                                          Dbkeys.groupADMINLIST:
                                                              FieldValue
                                                                  .arrayRemove([
                                                            widget.currentUserno
                                                          ]),
                                                          Dbkeys.groupMEMBERSLIST:
                                                              FieldValue
                                                                  .arrayRemove([
                                                            widget.currentUserno
                                                          ]),
                                                          widget.currentUserno:
                                                              FieldValue
                                                                  .delete(),
                                                          '${widget.currentUserno}-joinedOn':
                                                              FieldValue
                                                                  .delete()
                                                        }
                                                      : {
                                                          Dbkeys.groupMEMBERSLIST:
                                                              FieldValue
                                                                  .arrayRemove([
                                                            widget.currentUserno
                                                          ]),
                                                          // widget.currentUserno:
                                                          //     FieldValue
                                                          //         .delete(),
                                                          // '${widget.currentUserno}-joinedOn':
                                                          //     FieldValue
                                                          //         .delete()
                                                        });

                                              await FirebaseFirestore.instance
                                                  .collection(DbPaths
                                                      .collectionchannels)
                                                  .doc(widget.groupID)
                                                  .collection(DbPaths
                                                      .collectiongroupChats)
                                                  .doc(
                                                      '${time.millisecondsSinceEpoch}--${widget.currentUserno}')
                                                  .set({
                                                Dbkeys.groupmsgCONTENT:
                                                    '${widget.currentUserno} ${LocaleKeys.leftthegroup.tr()}',
                                                Dbkeys.groupmsgLISToptional: [],
                                                Dbkeys.groupmsgTIME:
                                                    time.millisecondsSinceEpoch,
                                                Dbkeys.groupmsgSENDBY:
                                                    widget.currentUserno,
                                                Dbkeys.groupmsgISDELETED: false,
                                                Dbkeys.groupmsgTYPE: Dbkeys
                                                    .groupmsgTYPEnotificationUserLeft,
                                              });

                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection(DbPaths
                                                        .collectiontemptokensforunsubscribe)
                                                    .doc(widget.currentUserno)
                                                    .delete();
                                              } catch (err) {}
                                            }).catchError((err) {
                                              // Lamat.toast(
                                              //     getTranslated(context,
                                              //         'unabletoleavegrp'));
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
                                margin:
                                    const EdgeInsets.fromLTRB(10, 30, 10, 30),
                                width: MediaQuery.of(context).size.width,
                                height: 48.0,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Text(
                                  LocaleKeys.unfollow.tr(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )),
                          )
                  ],
                ),
                Positioned(
                  child: isloading
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
        )));
  }

  getAdminList() {
    final availableContacts = ref.watch(smartContactProvider);
    final groupList = ref.watch(channelsListProvider);

    return Consumer(builder: (context, ref, _child) {
      Map<dynamic, dynamic> groupDoc = groupList.when(
        data: (groupLists) {
          return groupLists
              .lastWhere(
                  (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
              .docmap;
        },
        loading: () => {}, // return a loading widget if necessary
        error: (_, __) => {}, // handle error state if necessary
      );

      return Consumer(
          builder: (context, ref, _child) => ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: groupDoc[Dbkeys.groupADMINLIST].length,
              itemBuilder: (context, int i) {
                List adminlist = groupDoc[Dbkeys.groupADMINLIST].toList();
                return FutureBuilder<LocalUserData?>(
                    future: availableContacts.fetchUserDataFromnLocalOrServer(
                        widget.prefs, adminlist[i]),
                    builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                      // if (snapshot.connectionState == ConnectionState.waiting) {
                      //   return Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Divider(
                      //         height: 3,
                      //       ),
                      //       Stack(
                      //         children: [
                      //           ListTile(
                      //             isThreeLine: false,
                      //             contentPadding:
                      //                 EdgeInsets.fromLTRB(0, 0, 0, 0),
                      //             leading: Padding(
                      //               padding: const EdgeInsets.only(left: 5),
                      //               child: Padding(
                      //                 padding: const EdgeInsets.all(0.0),
                      //                 child: CachedNetworkImage(
                      //                     imageUrl: '',
                      //                     imageBuilder:
                      //                         (context, imageProvider) =>
                      //                             Container(
                      //                               width: 40.0,
                      //                               height: 40.0,
                      //                               decoration: BoxDecoration(
                      //                                 shape: BoxShape.circle,
                      //                                 image: DecorationImage(
                      //                                     image: imageProvider,
                      //                                     fit: BoxFit.cover),
                      //                               ),
                      //                             ),
                      //                     placeholder: (context, url) =>
                      //                         Container(
                      //                           width: 40.0,
                      //                           height: 40.0,
                      //                           decoration: BoxDecoration(
                      //                             color: Colors.grey[300],
                      //                             shape: BoxShape.circle,
                      //                           ),
                      //                         ),
                      //                     errorWidget: (context, url, error) =>
                      //                         SizedBox(
                      //                           width: 40,
                      //                           height: 40,
                      //                           child: customCircleAvatar(
                      //                               radius: 40),
                      //                         )),
                      //               ),
                      //             ),
                      //             title: Text(
                      //               availableContacts.contactsBookContactList!
                      //                           .entries
                      //                           .toList()
                      //                           .indexWhere((element) =>
                      //                               element.key ==
                      //                               adminlist[i]) >
                      //                       0
                      //                   ? availableContacts
                      //                       .contactsBookContactList!.entries
                      //                       .elementAt(availableContacts
                      //                           .contactsBookContactList!
                      //                           .entries
                      //                           .toList()
                      //                           .indexWhere((element) =>
                      //                               element.key ==
                      //                               adminlist[i]))
                      //                       .value
                      //                       .toString()
                      //                   : adminlist[i],
                      //               maxLines: 1,
                      //               overflow: TextOverflow.ellipsis,
                      //               style: TextStyle(
                      //                   fontWeight: FontWeight.normal),
                      //             ),
                      //             subtitle: Text(
                      //               '',
                      //               maxLines: 1,
                      //               overflow: TextOverflow.ellipsis,
                      //               style: TextStyle(height: 1.4),
                      //             ),
                      //           ),
                      //           groupDoc[Dbkeys.groupADMINLIST]
                      //                   .contains(adminlist[i])
                      //               ? Positioned(
                      //                   right: 27,
                      //                   top: 10,
                      //                   child: Container(
                      //                     padding:
                      //                         EdgeInsets.fromLTRB(4, 2, 4, 2),
                      //                     height: 18.0,
                      //                     decoration: BoxDecoration(
                      //                       color: Colors.white,
                      //                       border: Border.all(
                      //                           color: adminlist[i] ==
                      //                                   groupList
                      //                                           .lastWhere((element) =>
                      //                                               element.docmap[
                      //                                                   Dbkeys
                      //                                                       .groupID] ==
                      //                                               widget.groupID)
                      //                                           .docmap[
                      //                                       Dbkeys
                      //                                           .groupCREATEDBY]
                      //                               ? Colors.purple[400]!
                      //                               : Colors.green[400] ??
                      //                                   Colors.grey,
                      //                           width: 1.0),
                      //                       borderRadius:
                      //                           BorderRadius.circular(5.0),
                      //                     ),
                      //                     child: Center(
                      //                       child: Text(
                      //                         getTranslated(context, 'admin'),
                      //                         style: TextStyle(
                      //                             fontSize: 11.0,
                      //                             color: adminlist[i] ==
                      //                                     groupList
                      //                                         .lastWhere((element) =>
                      //                                             element.docmap[
                      //                                                 Dbkeys
                      //                                                     .groupID] ==
                      //                                             widget
                      //                                                 .groupID)
                      //                                         .docmap[Dbkeys.groupCREATEDBY]
                      //                                 ? Colors.purple[400]
                      //                                 : Colors.green[400]),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 )
                      //               : SizedBox(),
                      //         ],
                      //       ),
                      //     ],
                      //   );
                      // } else
                      if (snapshot.hasData && snapshot.data != null) {
                        bool isCurrentUserSuperAdmin = widget.currentUserno ==
                            groupDoc[Dbkeys.groupCREATEDBY];
                        bool isCurrentUserAdmin =
                            groupDoc[Dbkeys.groupADMINLIST]
                                .contains(widget.currentUserno);

                        bool isListUserSuperAdmin =
                            groupDoc[Dbkeys.groupCREATEDBY] == adminlist[i];
                        //----
                        bool islisttUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                            .contains(adminlist[i]);
                        bool isListUserOnlyUser =
                            !groupDoc[Dbkeys.groupADMINLIST]
                                .contains(adminlist[i]);
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
                                    child: (isCurrentUserSuperAdmin ||
                                            ((isCurrentUserAdmin &&
                                                    isListUserOnlyUser) ==
                                                true))
                                        ? isListUserSuperAdmin
                                            ? null
                                            : PopupMenuButton<String>(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .dialogColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                itemBuilder:
                                                    (BuildContext context) =>
                                                        <PopupMenuEntry<
                                                            String>>[
                                                          PopupMenuItem<String>(
                                                            value:
                                                                'Remove from Group',
                                                            child: Text(
                                                              LocaleKeys
                                                                  .removefromgroup
                                                                  .tr(),
                                                              style: TextStyle(
                                                                  color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? AppConstants
                                                                          .dialogColorDark
                                                                      : AppConstants
                                                                          .backgroundColor)),
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: isListUserOnlyUser
                                                                ? 'Set as Admin'
                                                                : 'Remove as Admin',
                                                            child: Text(
                                                                isListUserOnlyUser
                                                                    ? LocaleKeys
                                                                        .setasadmin
                                                                        .tr()
                                                                    : LocaleKeys
                                                                        .removeasadmin
                                                                        .tr(),
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .dialogColorDark
                                                                        : AppConstants
                                                                            .backgroundColor))),
                                                          ),
                                                        ],
                                                onSelected:
                                                    (String value) async {
                                                  await availableContacts
                                                      .fetchFromFiretsoreAndReturnData(
                                                          widget.prefs,
                                                          snapshot.data!.id,
                                                          (doc) {
                                                    userAction(
                                                        value,
                                                        adminlist[i],
                                                        islisttUserAdmin,
                                                        doc[Dbkeys
                                                                .notificationTokens] ??
                                                            []);
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.more_vert_outlined,
                                                  size: 20,
                                                  color: AppConstants.lamatGrey,
                                                ))
                                        : null,
                                  ),
                                  isThreeLine: false,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: customCircleAvatar(
                                            url: snapshot.data!.photoURL,
                                            radius: 22)),
                                  ),
                                  title: Text(
                                    availableContacts.contactsBookContactList!
                                                .entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    adminlist[i]) >
                                            0
                                        ? availableContacts
                                            .contactsBookContactList!.entries
                                            .elementAt(availableContacts
                                                .contactsBookContactList!
                                                .entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    adminlist[i]))
                                            .value
                                            .toString()
                                        : snapshot.data!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor)),
                                  ),
                                  enabled: true,
                                  subtitle: Text(
                                    //-- or about me
                                    snapshot.data!.id,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        height: 1.4,
                                        color: AppConstants.lamatGrey),
                                  ),
                                  onTap: widget.currentUserno ==
                                          snapshot.data!.id
                                      ? () {}
                                      : () async {
                                          await availableContacts
                                              .fetchFromFiretsoreAndReturnData(
                                                  widget.prefs,
                                                  snapshot.data!.id, (doc) {
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
                                                          firestoreUserDoc: doc,
                                                        )));
                                          });
                                        },
                                ),
                                groupDoc[Dbkeys.groupADMINLIST]
                                        .contains(adminlist[i])
                                    ? Positioned(
                                        right: 27,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              4, 2, 4, 2),
                                          // width: 50.0,
                                          height: 18.0,
                                          decoration: BoxDecoration(
                                            color:
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                            border: Border.all(
                                                color: adminlist[i] ==
                                                        groupDoc[Dbkeys
                                                            .groupCREATEDBY]
                                                    ? Colors.purple[400]!
                                                    : AppConstants
                                                        .lamatGreenColor400,
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              LocaleKeys.admin.tr(),
                                              style: TextStyle(
                                                fontSize: 11.0,
                                                color: adminlist[i] ==
                                                        groupDoc[Dbkeys
                                                            .groupCREATEDBY]
                                                    ? Colors.purple[400]
                                                    : AppConstants
                                                        .lamatGreenColor400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
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
                                      child: customCircleAvatar(
                                          url: snapshot.data!.photoURL,
                                          radius: 22)),
                                ),
                                title: Text(
                                  availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key == adminlist[i]) >
                                          0
                                      ? availableContacts
                                          .contactsBookContactList!.entries
                                          .elementAt(availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key == adminlist[i]))
                                          .value
                                          .toString()
                                      : adminlist[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants
                                                      .backgroundColorDark
                                                  : AppConstants
                                                      .backgroundColor)),
                                ),
                                subtitle: const Text(
                                  '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(height: 1.4),
                                ),
                              ),
                              groupDoc[Dbkeys.groupADMINLIST]
                                      .contains(adminlist[i])
                                  ? Positioned(
                                      right: 27,
                                      top: 10,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            4, 2, 4, 2),
                                        // width: 50.0,
                                        height: 18.0,
                                        decoration: BoxDecoration(
                                          color: Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                          border: Border.all(
                                              color: adminlist[i] ==
                                                      groupDoc[
                                                          Dbkeys.groupCREATEDBY]
                                                  ? Colors.purple[400]!
                                                  : AppConstants
                                                      .lamatGreenColor400,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Center(
                                          child: Text(
                                            LocaleKeys.admin.tr(),
                                            style: TextStyle(
                                              fontSize: 11.0,
                                              color: adminlist[i] ==
                                                      groupDoc[
                                                          Dbkeys.groupCREATEDBY]
                                                  ? Colors.purple[400]
                                                  : AppConstants
                                                      .lamatGreenColor400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      );
                    });
              }));
    });
  }

  getUsersList() {
    final availableContacts = ref.watch(smartContactProvider);
    final groupList = ref.watch(channelsListProvider);

    return Consumer(builder: (context, ref, _child) {
      Map<dynamic, dynamic> groupDoc = groupList.when(
        data: (groupLists) {
          return groupLists
              .lastWhere(
                  (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
              .docmap;
        },
        loading: () => {}, // return a loading widget if necessary
        error: (_, __) => {}, // handle error state if necessary
      );

      return Consumer(builder: (context, ref, _child) {
        List onlyuserslist = groupDoc[Dbkeys.groupMEMBERSLIST];
        groupDoc[Dbkeys.groupMEMBERSLIST].toList().forEach((member) {
          if (groupDoc[Dbkeys.groupADMINLIST].contains(member) == true) {
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
                  future: availableContacts.fetchUserDataFromnLocalOrServer(
                      widget.prefs, viewerslist[i]),
                  builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return Column(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Divider(
                    //         height: 3,
                    //       ),
                    //       Stack(
                    //         children: [
                    //           ListTile(
                    //             isThreeLine: false,
                    //             contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //             leading: Padding(
                    //               padding: const EdgeInsets.only(left: 5),
                    //               child: Padding(
                    //                 padding: const EdgeInsets.all(0.0),
                    //                 child: CachedNetworkImage(
                    //                     imageUrl: '',
                    //                     imageBuilder:
                    //                         (context, imageProvider) =>
                    //                             Container(
                    //                               width: 40.0,
                    //                               height: 40.0,
                    //                               decoration: BoxDecoration(
                    //                                 shape: BoxShape.circle,
                    //                                 image: DecorationImage(
                    //                                     image: imageProvider,
                    //                                     fit: BoxFit.cover),
                    //                               ),
                    //                             ),
                    //                     placeholder: (context, url) =>
                    //                         Container(
                    //                           width: 40.0,
                    //                           height: 40.0,
                    //                           decoration: BoxDecoration(
                    //                             color: Colors.grey[300],
                    //                             shape: BoxShape.circle,
                    //                           ),
                    //                         ),
                    //                     errorWidget: (context, url, error) =>
                    //                         SizedBox(
                    //                           width: 40,
                    //                           height: 40,
                    //                           child: customCircleAvatar(
                    //                               radius: 40),
                    //                         )),
                    //               ),
                    //             ),
                    //             title: Text(
                    //               availableContacts
                    //                           .contactsBookContactList!.entries
                    //                           .toList()
                    //                           .indexWhere((element) =>
                    //                               element.key ==
                    //                               viewerslist[i]) >
                    //                       0
                    //                   ? availableContacts
                    //                       .contactsBookContactList!.entries
                    //                       .elementAt(availableContacts
                    //                           .contactsBookContactList!.entries
                    //                           .toList()
                    //                           .indexWhere((element) =>
                    //                               element.key ==
                    //                               viewerslist[i]))
                    //                       .value
                    //                       .toString()
                    //                   : viewerslist[i],
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //               style:
                    //                   TextStyle(fontWeight: FontWeight.normal),
                    //             ),
                    //             subtitle: Text(
                    //               '',
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //               style: TextStyle(height: 1.4),
                    //             ),
                    //           ),
                    //           groupDoc[Dbkeys.groupADMINLIST]
                    //                   .contains(viewerslist[i])
                    //               ? Positioned(
                    //                   right: 27,
                    //                   top: 10,
                    //                   child: Container(
                    //                     padding:
                    //                         EdgeInsets.fromLTRB(4, 2, 4, 2),
                    //                     // width: 50.0,
                    //                     height: 18.0,
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.white,
                    //                       border: Border.all(
                    //                           color: Colors.green[400] ??
                    //                               Colors.grey,
                    //                           width: 1.0),
                    //                       borderRadius:
                    //                           BorderRadius.circular(5.0),
                    //                     ),
                    //                     child: Center(
                    //                       child: Text(
                    //                         getTranslated(context, 'admin'),
                    //                         style: TextStyle(
                    //                             fontSize: 11.0,
                    //                             color: Colors.green[400]),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 )
                    //               : SizedBox(),
                    //         ],
                    //       ),
                    //     ],
                    //   );
                    // } else

                    if (snapshot.hasData && snapshot.data != null) {
                      bool isCurrentUserSuperAdmin = widget.currentUserno ==
                          groupDoc[Dbkeys.groupCREATEDBY];
                      bool isCurrentUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                          .contains(widget.currentUserno);

                      bool isListUserSuperAdmin =
                          groupDoc[Dbkeys.groupCREATEDBY] == viewerslist[i];
                      //----
                      bool islisttUserAdmin = groupDoc[Dbkeys.groupADMINLIST]
                          .contains(viewerslist[i]);
                      bool isListUserOnlyUser = !groupDoc[Dbkeys.groupADMINLIST]
                          .contains(viewerslist[i]);
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
                                  child: (isCurrentUserSuperAdmin ||
                                          ((isCurrentUserAdmin &&
                                                  isListUserOnlyUser) ==
                                              true))
                                      ? isListUserSuperAdmin
                                          ? null
                                          : PopupMenuButton<String>(
                                              color:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .dialogColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      <PopupMenuEntry<String>>[
                                                        PopupMenuItem<String>(
                                                          value:
                                                              'Remove from Group',
                                                          child: Text(
                                                            LocaleKeys
                                                                .removefromgroup
                                                                .tr(),
                                                            style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? AppConstants
                                                                        .dialogColorDark
                                                                    : AppConstants
                                                                        .backgroundColor)),
                                                          ),
                                                        ),
                                                        PopupMenuItem<String>(
                                                          value: isListUserOnlyUser ==
                                                                  true
                                                              ? 'Set as Admin'
                                                              : 'Remove as Admin',
                                                          child: Text(
                                                            isListUserOnlyUser == true
                                                                ? LocaleKeys
                                                                    .setasadmin
                                                                    .tr()
                                                                : LocaleKeys
                                                                    .removeasadmin
                                                                    .tr(),
                                                            style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? AppConstants
                                                                        .dialogColorDark
                                                                    : AppConstants
                                                                        .backgroundColor)),
                                                          ),
                                                        ),
                                                      ],
                                              onSelected: (String value) async {
                                                await availableContacts
                                                    .fetchFromFiretsoreAndReturnData(
                                                        widget.prefs,
                                                        snapshot.data!.id,
                                                        (doc) {
                                                  userAction(
                                                      value,
                                                      viewerslist[i],
                                                      islisttUserAdmin,
                                                      doc[Dbkeys
                                                              .notificationTokens] ??
                                                          []);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.more_vert_outlined,
                                                size: 20,
                                                color: AppConstants.lamatGrey,
                                              ))
                                      : null,
                                ),
                                isThreeLine: false,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: customCircleAvatar(
                                        url: snapshot.data!.photoURL,
                                        radius: 22),
                                  ),
                                ),
                                title: Text(
                                  availableContacts
                                              .contactsBookContactList!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]) >
                                          0
                                      ? availableContacts
                                          .contactsBookContactList!.entries
                                          .elementAt(availableContacts
                                              .contactsBookContactList!.entries
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
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants
                                                      .backgroundColorDark
                                                  : AppConstants
                                                      .backgroundColor)),
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
                                        await availableContacts
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
                                                      )));
                                        });
                                      },
                                enabled: true,
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
                                    child: customCircleAvatar(radius: 22)),
                              ),
                              title: Text(
                                availableContacts
                                            .contactsBookContactList!.entries
                                            .toList()
                                            .indexWhere((element) =>
                                                element.key == viewerslist[i]) >
                                        0
                                    ? availableContacts
                                        .contactsBookContactList!.entries
                                        .elementAt(availableContacts
                                            .contactsBookContactList!.entries
                                            .toList()
                                            .indexWhere((element) =>
                                                element.key == viewerslist[i]))
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
                                            : AppConstants.backgroundColor)),
                              ),
                              subtitle: const Text(
                                '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    height: 1.4, color: AppConstants.lamatGrey),
                              ),
                            ),
                            groupDoc[Dbkeys.groupADMINLIST]
                                    .contains(viewerslist[i])
                                ? Positioned(
                                    right: 27,
                                    top: 10,
                                    child: Container(
                                      padding:
                                          const EdgeInsets.fromLTRB(4, 2, 4, 2),
                                      // width: 50.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        border: Border.all(
                                            color:
                                                AppConstants.lamatGreenColor400,
                                            width: 1.0),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          LocaleKeys.admin.tr(),
                                          style: const TextStyle(
                                            fontSize: 11.0,
                                            color:
                                                AppConstants.lamatGreenColor400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
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
