// ignore_for_file: unused_local_variable, unused_field, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lamatdating/providers/get_current_location_provider.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/utils/variants_gen.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vph_web_date_picker/vph_web_date_picker.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class FirstTimeUserProfilePage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  const FirstTimeUserProfilePage({super.key, required this.prefs});

  @override
  ConsumerState<FirstTimeUserProfilePage> createState() =>
      _FirstTimeUserProfilePageState();
}

class _FirstTimeUserProfilePageState
    extends ConsumerState<FirstTimeUserProfilePage> {
  final _pageController = PageController();
  int _currentPage = 0;
  final _totalPages = 6;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final double _walletBalance = 0.0;

  String _gender = '';
  bool isLoading = true;

  final _birthdayController = TextEditingController();
  DateTime? _birthday;

  UserLocation? _userLocation;

  final UserLocation demoLocation = UserLocation(
    latitude: 48.8566,
    longitude: 2.3522,
    addressText: LocaleKeys.parisfrance.tr(),
  );

  final List<String> _interests = [];

  final List<String> _medias = [
    for (var i = 0; i < AppConfig.maxNumOfMedia; i++) ""
  ];

  String? _profilePicture;

  final List<Uint8List?> _mediasWeb = [
    for (var i = 0; i < AppConfig.maxNumOfMedia; i++) null
  ];

  // String? _profilePicture;
  Uint8List? _profilePictureBytes;

  String? _deviceToken;

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var mapDeviceInfo = {};
  String? deviceid;
  final storage = const FlutterSecureStorage();

  // Future<void> _pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile =
  //       await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _profilePicture = pickedFile.path;
  //     });
  //   }
  // }

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
      }
      if (Platform.isIOS == true) {
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
        deviceid = webBrowserInfo.appName! +
            webBrowserInfo.browserName.toString() +
            webBrowserInfo.appVersion!;
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

  @override
  void initState() {
    // print("PHONE: ${widget.prefs.getString(Dbkeys.phoneRaw)}");
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    // if (isDemo) {
    //   _userLocation = demoLocation;
    // }
    setdeviceinfo();
    _getDeviceToken();
    setStatusBarColor(widget.prefs);
    super.initState();
  }

  void _getDeviceToken() async {
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    setState(() {
      _deviceToken = deviceToken;
    });
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(currentUserNo.replaceFirst(RegExp(r'\+'), ''))
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(Dbkeys.topicUSERS)
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(Platform.isAndroid
              ? Dbkeys.topicUSERSandroid
              : Platform.isIOS
                  ? Dbkeys.topicUSERSios
                  : Dbkeys.topicUSERSweb)
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          for (var doc in query.docs) {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (!doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
                if (kIsWeb == false) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic(
                          "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                  });
                }
              }
            } else {
              if (kIsWeb == false) {
                await FirebaseMessaging.instance
                    .subscribeToTopic(
                        "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                    .catchError((err) {
                  debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                });
              }
            }
          }
        }
      });
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          for (var doc in query.docs) {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (!doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
                if (kIsWeb == false) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic(
                          "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                  });
                }
              }
            } else {
              if (kIsWeb == false) {
                await FirebaseMessaging.instance
                    .subscribeToTopic(
                        "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                    .catchError((err) {
                  debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                });
              }
            }
          }
        }
      });
    }
  }

  void _onSubmit() async {
    EasyLoading.show(status: "Registering...");
    final userId = ref.watch(currentUserStateProvider)!.uid;
    final phone = ref.watch(currentUserStateProvider)!.phoneNumber!;

    final UserAccountSettingsModel userAccountSettingsModel =
        UserAccountSettingsModel(
      location: _userLocation!,
      distanceInKm: AppConfig.initialDistanceInKM,
      maximumAge: AppConfig.maximumUserAge,
      minimumAge: AppConfig.minimumAgeRequired,
    );
    debugPrint("UserAccountSettingsModel ===>");

    // final metadata = SettableMetadata(
    //   contentType: 'image/jpeg',
    // );

    // Future<String?> uploadUserMediaFiles(
    //     Uint8List? path, String phoneNumber) async {
    //   final storageRef = FirebaseStorage.instance.ref();

    //   final imageRef = storageRef.child("user_media_files/$phoneNumber");
    //   final uploadTask = imageRef.putData(path!);

    //   String? imageUrl;
    //   await uploadTask.whenComplete(() async {
    //     imageUrl = await imageRef.getDownloadURL();
    //     // print("UPLOADED IMAGE: $imageUrl");
    //   });
    //   return imageUrl;
    // }

    // List<String> mediaURLs = [];
    // for (var media in _mediasWeb) {
    //   if (media == null) {
    //     debugPrint("Media is empty");
    //   } else {
    //     final mediaURL = await uploadUserMediaFiles(media, phone);
    //     if (mediaURL != null) {
    //       mediaURLs.add(mediaURL);
    //     }
    //   }
    // }

    // Future<String?> _uploadProfilePictureWeb(String phoneNumber) async {
    //   final storageRef = FirebaseStorage.instance.ref();

    //   final imageRef = storageRef.child("user_profile_pictures/$phoneNumber");
    //   final uploadTask = imageRef.putData(_profilePictureBytes!, metadata);

    //   String? imageUrl;
    //   await uploadTask.whenComplete(() async {
    //     imageUrl = await imageRef.getDownloadURL();
    //   });
    //   // print("UPLOADED IMAGE: $imageUrl");
    //   return imageUrl;
    // }

    // final profilePicUrl = await _uploadProfilePictureWeb(
    //     ref.watch(currentUserStateProvider)!.phoneNumber!);
    _medias.removeWhere((string) => string.isEmpty);

    final UserProfileModel userProfileModel = UserProfileModel(
      id: userId,
      userId: userId,
      fullName: _fullNameController.text.trim(),
      userName: _userNameController.text.trim(),
      nickname: _nickNameController.text.trim(),
      mediaFiles: _medias,
      interests: _interests,
      gender: _gender,
      birthDay: _birthday!,
      email: ref.watch(currentUserStateProvider)!.email,
      phoneNumber: ref.watch(currentUserStateProvider)!.phoneNumber!,
      userAccountSettingsModel: userAccountSettingsModel,
      isVerified: false,
      profilePicture: _profilePicture,
      deviceToken: _deviceToken,
      instaUrl: "",
      fbUrl: "",
      youtubeUrl: "",
      agoraToken: "",
      followersCount: 0,
      followingCount: 0,
      myPostLikes: 0,
      followers: [],
      following: [],
      favSongs: [],
      profileCategoryName: "New",
      boostBalance: 1,
      superLikesCount: 1,
      isBoosted: false,
      favTeels: [],
      about: "${LocaleKeys.heyim.tr()} $Appname",
      boostType: '',
      boostedOn: 0,
    );

    // await widget.prefs.setString(Dbkeys.photoUrl, _profilePicture ?? '');

    await ref
        .read(userProfileNotifier)
        .createUserProfile(userProfileModel, widget.prefs)
        .then((result) async {
      if (result == true) {
        debugPrint("STEP: USER PROFILE CREATED ==> Part 1");
        final box = Hive.box(HiveConstants.hiveBox);
        await box.put(HiveConstants.currentUserProf, userProfileModel.toJson());
        final phoneNo = ref.watch(currentUserStateProvider)!.phoneNumber!;
        debugPrint("STEP: FCM Token Getting");
        String? fcmTokenn = await FirebaseMessaging.instance.getToken();
        debugPrint("STEP: FCM Token ==> $fcmTokenn");

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .set({
          Dbkeys.countryCode: widget.prefs.getString(Dbkeys.countryCode),
          Dbkeys.aboutMe: "Hey there, I am on $Appname!",
          Dbkeys.id: userId,
          Dbkeys.phone: phoneNo,
          Dbkeys.phoneRaw: widget.prefs.getString(Dbkeys.phoneRaw),
          Dbkeys.authenticationType: AuthenticationType.passcode.index,
          // Dbkeys.photoUrl: _profilePicture,
          Dbkeys.searchKey:
              _nickNameController.text.trim().substring(0, 1).toUpperCase(),
          //---Additional fields added for Admin app compatible----
          Dbkeys.accountstatus: Dbkeys.sTATUSallowed,
          Dbkeys.actionmessage:
              widget.prefs.getString(Dbkeys.accountapprovalmessage),
          Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.notificationTokens: [fcmTokenn ?? phoneNo],
          Dbkeys.videoCallMade: 0,
          Dbkeys.videoCallRecieved: 0,
          Dbkeys.audioCallMade: 0,
          Dbkeys.groupsCreated: 0,
          Dbkeys.blockeduserslist: [],
          Dbkeys.audioCallRecieved: 0,
          Dbkeys.mssgSent: 0,
          Dbkeys.deviceDetails: mapDeviceInfo,
          Dbkeys.currentDeviceID: deviceid ?? phoneNo,
          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
              countrycode: widget.prefs.getString(Dbkeys.countryCode),
              phonenumber: widget.prefs.getString(Dbkeys.phoneRaw)),
        }, SetOptions(merge: true)).onError((e, stackTrace) {
          if (kDebugMode) showERRORSheet(context, "", message: e.toString());
        });
        debugPrint("STEP: USER PROFILE CREATED ==> Part 2");

        await FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docuserscount)
            .set(
                widget.prefs.getBool(Dbkeys.isaccountapprovalbyadminneeded) ==
                        false
                    ? {
                        Dbkeys.totalapprovedusers: FieldValue.increment(1),
                      }
                    : {
                        Dbkeys.totalpendingusers: FieldValue.increment(1),
                      },
                SetOptions(merge: true))
            .onError((e, stackTrace) {
          if (kDebugMode) showERRORSheet(context, "", message: e.toString());
        });
        debugPrint("STEP: docuserscount SET");

        await FirebaseFirestore.instance
            .collection(DbPaths.collectioncountrywiseData)
            .doc(
              widget.prefs.getString(Dbkeys.countryCode),
            )
            .set({
          Dbkeys.totalusers: FieldValue.increment(1),
        }, SetOptions(merge: true)).onError((e, stackTrace) {
          if (kDebugMode) showERRORSheet(context, "", message: e.toString());
        });
        debugPrint("STEP: collectioncountrywiseData SET");

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionnotifications)
            .doc(DbPaths.adminnotifications)
            .set({
          Dbkeys.nOTIFICATIONxxaction: 'PUSH',
          Dbkeys.nOTIFICATIONxxdesc: widget.prefs
                      .getBool(Dbkeys.isaccountapprovalbyadminneeded) ==
                  true
              ? '$phoneNo has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
              : '$phoneNo has Joined $Appname. You can view the user profile from All Users List.',
          Dbkeys.nOTIFICATIONxxtitle: 'User Joined',
          Dbkeys.nOTIFICATIONxximageurl: null,
          Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
          'list': FieldValue.arrayUnion([
            {
              Dbkeys.docid: DateTime.now().millisecondsSinceEpoch.toString(),
              Dbkeys.nOTIFICATIONxxdesc: widget.prefs
                          .getBool(Dbkeys.isaccountapprovalbyadminneeded) ==
                      true
                  ? '$phoneNo has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                  : '$phoneNo has Joined $Appname. You can view the user profile from All Users List.',
              Dbkeys.nOTIFICATIONxxtitle: 'User Joined',
              Dbkeys.nOTIFICATIONxximageurl: null,
              Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
              Dbkeys.nOTIFICATIONxxauthor: '${phoneNo}XXXuserapp',
            }
          ])
        }, SetOptions(merge: true)).onError((e, stackTrace) {
          if (kDebugMode) showERRORSheet(context, "", message: e.toString());
        });
        debugPrint("STEP: adminnotifications SET");

        await widget.prefs
            .setString(Dbkeys.nickname, _nickNameController.text.trim());
        await widget.prefs.setString(Dbkeys.phone, phoneNo);
        await widget.prefs.setString(
          Dbkeys.aboutMe,
          "${LocaleKeys.heyim.tr()} $Appname",
        );
        debugPrint("STEP: aboutMe SET");

        await subscribeToNotification(phoneNo, true);
        debugPrint("STEP: subscribeToNotification SET");

        setState(() {
          isLoading = false;
        });
        debugPrint("STEP: isLoading = False SET");

        if (isLoading == false) {
          if (result) {
            final currentUserProfile = ref.watch(userProfileFutureProvider);

            currentUserProfile.when(
                data: (data) async {
                  final box = Hive.box(HiveConstants.hiveBox);
                  box.put(HiveConstants.userSet, true);
                  // Save data to Hive
                  debugPrint("STEP: HiveConstants.currentUserProf SETTING");
                  await box.put(HiveConstants.currentUserProf, data!.toJson());
                  debugPrint("STEP: HiveConstants.currentUserProf SET");
                  await box.put(HiveConstants.lastUserProfileUpdatedKey,
                      DateTime.now().millisecondsSinceEpoch);
                  debugPrint(
                      "STEP: HiveConstants.lastUserProfileUpdatedKey SET");
                },
                error: (e, __) {
                  if (kDebugMode) {
                    showERRORSheet(context, "", message: e.toString());
                  }
                },
                loading: () => {});
            EasyLoading.dismiss();
            EasyLoading.showSuccess("Registered Successfully");
            ref.invalidate(userProfileFutureProvider);
            Restart.restartApp();
          }
        }
      }
    }).onError((e, stackTrace) {
      if (kDebugMode) showERRORSheet(context, "", message: e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final currentLocationProviderProvider =
        ref.watch(getCurrentLocationProviderProvider);
    (AppRes.currentLocationProviderProvider == null)
        ? {
            currentLocationProviderProvider.when(
              data: (data) {
                if (data != null) {
                  AppRes.currentLocationProviderProvider = data;
                  _userLocation = data;
                }
              },
              error: (e, __) {},
              loading: () {},
            )
          }
        : {_userLocation = AppRes.currentLocationProviderProvider};
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Form(
        key: _formKey,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: Column(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultNumericValue),
                child: CustomAppBar(
                  leading: CustomIconButton(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8),
                      onPressed: () async {
                        kIsWeb
                            ? {
                                await ref
                                    .read(authProvider)
                                    .signOut()
                                    .then((value) => Restart.restartApp()),
                                // await Restart.restartApp()
                              }
                            : showDialog(
                                context: context,
                                builder: (context) {
                                  return WillPopScope(
                                    onWillPop: () async {
                                      return false;
                                    },
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Dialog(
                                        insetPadding: EdgeInsets.symmetric(
                                            horizontal: width * .15),
                                        backgroundColor: Colors.transparent,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: width / 8,
                                              vertical: height / 8),
                                          child: AspectRatio(
                                            aspectRatio:
                                                kIsWeb ? 1 / 1 : 1 / 1.2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(22)),
                                              ),
                                              child: Column(
                                                children: [
                                                  const Spacer(),
                                                  AppRes.appLogo != null
                                                      ? Image.network(
                                                          AppRes.appLogo!,
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : Image.asset(
                                                          AppConstants.logo,
                                                          color: AppConstants
                                                              .primaryColor,
                                                          width: 90,
                                                          height: 90,
                                                          fit: BoxFit.contain,
                                                        ),
                                                  const Spacer(),
                                                  const Divider(),
                                                  const Spacer(),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                      LocaleKeys
                                                          .doYoReallyNwantToLogOut
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration.none,
                                                        color: Teme.isDarktheme(
                                                                widget.prefs)
                                                            ? AppConstants
                                                                .textColor
                                                            : AppConstants
                                                                .textColorLight,
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Spacer(),
                                                  Row(
                                                    children: [
                                                      InkWell(
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Container(
                                                          height: 55,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppConstants
                                                                .secondaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(20),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              LocaleKeys.cancel
                                                                  .tr(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        overlayColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                        onTap: () async {
                                                          Navigator.of(context)
                                                              .pop();

                                                          await ref
                                                              .read(
                                                                  authProvider)
                                                              .signOut();
                                                          EasyLoading
                                                              .showSuccess(
                                                                  LocaleKeys
                                                                      .loggingout
                                                                      .tr());
                                                          ref.invalidate(
                                                              currentUserStateProvider);
                                                        },
                                                        child: Container(
                                                          height: 55,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppConstants
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius.only(
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            20)),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              LocaleKeys.logout
                                                                  .tr(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                barrierDismissible: false);
                        // showDialog(
                        //     context: context,
                        //     builder: (context) {
                        //       return WillPopScope(
                        //           onWillPop: () async {
                        //             return false;
                        //           },
                        //           child: BackdropFilter(
                        //               filter: ImageFilter.blur(
                        //                   sigmaX: 10, sigmaY: 10),
                        //               child: Dialog(
                        //                   insetPadding: EdgeInsets.symmetric(
                        //                       horizontal: width * .15),
                        //                   backgroundColor: Colors.transparent,
                        //                   child: Padding(
                        //                       padding: EdgeInsets.symmetric(
                        //                           horizontal: width / 8,
                        //                           vertical: height / 8),
                        //                       child: AspectRatio(
                        //                           aspectRatio:
                        //                               kIsWeb ? 1 / 1 : 1 / 1.2,
                        //                           child: Container(
                        //                             decoration: BoxDecoration(
                        //                               color: Teme.isDarktheme(
                        //                                       widget.prefs)
                        //                                   ? AppConstants
                        //                                       .backgroundColorDark
                        //                                   : AppConstants
                        //                                       .backgroundColor,
                        //                               borderRadius:
                        //                                   const BorderRadius
                        //                                           .all(
                        //                                       Radius.circular(
                        //                                           22)),
                        //                             ),
                        //                             child: Column(
                        //                               children: [
                        //                                 TextButton(
                        //                                   child: Text(
                        //                                     LocaleKeys.cancel
                        //                                         .tr(),
                        //                                     style:
                        //                                         const TextStyle(
                        //                                             color: Colors
                        //                                                 .black),
                        //                                   ),
                        //                                   onPressed: () {
                        //                                     Navigator.of(
                        //                                             context)
                        //                                         .pop();
                        //                                   },
                        //                                 ),
                        //                                 TextButton(
                        //                                   child: Text(
                        //                                     LocaleKeys.yes.tr(),
                        //                                     style:
                        //                                         const TextStyle(
                        //                                             color: Colors
                        //                                                 .red),
                        //                                   ),
                        //                                   onPressed: () async {
                        //                                     Navigator.of(
                        //                                             context)
                        //                                         .pop();

                        //                                     await ref
                        //                                         .read(
                        //                                             authProvider)
                        //                                         .signOut();
                        //                                   },
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                           ))))));
                        //     });
                      },
                      color: AppConstants.primaryColor,
                      icon: closeIcon),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              SizedBox(
                width: width,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: _totalPages,
                    effect: ScrollingDotsEffect(
                      dotWidth: width / _totalPages * .8,
                      maxVisibleDots:
                          _totalPages.isOdd ? _totalPages : _totalPages + 1,
                      dotHeight: 4,
                      activeDotScale: 1,
                      activeDotColor: AppConstants.primaryColor,
                      dotColor: Colors.grey.withOpacity(.7),
                      spacing: width * .02, // Add spacing between dots
                      radius: AppConstants.defaultNumericValue,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                final imagePath = await pickMedia();
                                {
                                  if (imagePath != null) {
                                    setState(() {
                                      _profilePicture = imagePath;
                                    });
                                  }
                                }
                              },
                              child: Stack(children: <Widget>[
                                Container(
                                  height: width / 2,
                                  width: width / 2,
                                  decoration: _profilePicture != null
                                      ? BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                          image: DecorationImage(
                                            image: FileImage(
                                                File(_profilePicture!)),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                          image: const DecorationImage(
                                            image: AssetImage(profilePic),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  // child: _profilePicture != null
                                  //     ? CachedNetworkImage(
                                  //         imageUrl: _profilePicture!,
                                  //         placeholder: (context, url) =>
                                  //             const Center(
                                  //                 child:
                                  //                     CircularProgressIndicator
                                  //                         .adaptive()),
                                  //         errorWidget: (context, url, error) =>
                                  //             const Center(
                                  //                 child: Icon(
                                  //                     CupertinoIcons.photo)),
                                  //         fit: BoxFit.cover,
                                  //       )
                                  //     : const SizedBox(),
                                ),
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: (_profilePicture == null)
                                        ? WebsafeSvg.asset(editIcon,
                                            // color: Colors.black,
                                            colorFilter: const ColorFilter.mode(
                                              //  AppConstants.primaryColor,
                                              Colors.black,
                                              BlendMode.srcIn,
                                            ),
                                            width: AppConstants
                                                    .defaultNumericValue *
                                                4,
                                            fit: BoxFit.fitWidth)
                                        : const SizedBox())
                              ]),
                            ),
                          ),
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          UserDetailsTakingScreen(
                            prefs: widget.prefs,
                            nameController: _fullNameController,
                            userNameController: _userNameController,
                            nickNameController: _nickNameController,
                            walletBalanceNew: _walletBalance,
                            onGenderSelected: (gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            gender: _gender,
                            birthday: _birthday,
                            onBirthdaySelected: (birthday) {
                              setState(() {
                                _birthday = birthday;
                              });
                            },
                            birthdayController: _birthdayController,
                            selectedInterests: _interests,
                            onSelectInterest: (notSelected, interest) {
                              setState(() {
                                if (notSelected) {
                                  if (_interests.length >=
                                      AppConfig.maxNumOfInterests) {
                                    EasyLoading.showToast(
                                        "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                        toastPosition:
                                            EasyLoadingToastPosition.bottom);
                                  } else {
                                    _interests.add(interest);
                                  }
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                            onNext: () async {
                              bool usernameExist = true;

                              await checkUserNameExists(
                                      ref, _userNameController.text.trim())
                                  .then((value) {
                                usernameExist = value;
                              });
                              if (_formKey.currentState!.validate()) {
                                _profilePicture != null
                                    ? !usernameExist
                                        ? _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          )
                                        : EasyLoading.showError(
                                            LocaleKeys.usernamealreadyexists
                                                .tr(),
                                          )
                                    : EasyLoading.showError(
                                        LocaleKeys.setNewProfilePicture.tr(),
                                      );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          UserDetailsTakingScreenGender(
                            prefs: widget.prefs,
                            nameController: _fullNameController,
                            userNameController: _userNameController,
                            walletBalanceNew: _walletBalance,
                            onGenderSelected: (gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            gender: _gender,
                            birthday: _birthday,
                            onBirthdaySelected: (birthday) {
                              setState(() {
                                _birthday = birthday;
                              });
                            },
                            birthdayController: _birthdayController,
                            selectedInterests: _interests,
                            onSelectInterest: (notSelected, interest) {
                              setState(() {
                                if (notSelected) {
                                  if (_interests.length >=
                                      AppConfig.maxNumOfInterests) {
                                    EasyLoading.showToast(
                                        "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                        toastPosition:
                                            EasyLoadingToastPosition.bottom);
                                  } else {
                                    _interests.add(interest);
                                  }
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                            onNext: () {
                              if (_formKey.currentState!.validate()) {
                                if (_gender != "") {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  EasyLoading.showToast(
                                      LocaleKeys.pleaseselectyouryourgender
                                          .tr(),
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          UserDetailsTakingScreenDOB(
                            prefs: widget.prefs,
                            nameController: _fullNameController,
                            userNameController: _userNameController,
                            walletBalanceNew: _walletBalance,
                            onGenderSelected: (gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            gender: _gender,
                            birthday: _birthday,
                            onBirthdaySelected: (birthday) {
                              setState(() {
                                _birthday = birthday;
                              });
                            },
                            birthdayController: _birthdayController,
                            selectedInterests: _interests,
                            onSelectInterest: (notSelected, interest) {
                              setState(() {
                                if (notSelected) {
                                  if (_interests.length >=
                                      AppConfig.maxNumOfInterests) {
                                    EasyLoading.showToast(
                                        "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                        toastPosition:
                                            EasyLoadingToastPosition.bottom);
                                  } else {
                                    _interests.add(interest);
                                  }
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                            onNext: () {
                              if (_formKey.currentState!.validate()) {
                                if (_birthday != null) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  EasyLoading.showToast(
                                      LocaleKeys.pleaseSelectYourBirthday.tr(),
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          UserDetailsTakingScreenInterests(
                            prefs: widget.prefs,
                            nameController: _fullNameController,
                            userNameController: _userNameController,
                            walletBalanceNew: _walletBalance,
                            onGenderSelected: (gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            gender: _gender,
                            birthday: _birthday,
                            onBirthdaySelected: (birthday) {
                              setState(() {
                                _birthday = birthday;
                              });
                            },
                            birthdayController: _birthdayController,
                            selectedInterests: _interests,
                            onSelectInterest: (notSelected, interest) {
                              setState(() {
                                if (notSelected) {
                                  if (_interests.length >=
                                      AppConfig.maxNumOfInterests) {
                                    EasyLoading.showToast(
                                        "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                        toastPosition:
                                            EasyLoadingToastPosition.bottom);
                                  } else {
                                    _interests.add(interest);
                                  }
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                            onNext: () {
                              if (_formKey.currentState!.validate()) {
                                if (_interests.isNotEmpty) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  EasyLoading.showToast(
                                      LocaleKeys.pleaseselectatleastoneinterest
                                          .tr(),
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          Text(
                            LocaleKeys.myPhotos.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                              height: AppConstants.defaultNumericValue),
                          Wrap(
                              spacing: AppConstants.defaultNumericValue / 2.1,
                              runSpacing:
                                  AppConstants.defaultNumericValue / 2.1,
                              alignment: WrapAlignment.center,
                              children:
                                  // !kIsWeb
                                  //     ?
                                  _medias
                                      .map(
                                        (image) => GestureDetector(
                                          onTap: () async {
                                            void selecImage() async {
                                              final imagePath =
                                                  await pickMedia();
                                              if (imagePath != null) {
                                                setState(() {
                                                  _medias[_medias.indexOf(
                                                      image)] = imagePath;
                                                });
                                              }
                                            }

                                            if (image != "") {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        ListTile(
                                                          title: Text(LocaleKeys
                                                              .selectNewImage
                                                              .tr()),
                                                          leading: const Icon(
                                                              Icons.image),
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            selecImage();
                                                          },
                                                        ),
                                                        ListTile(
                                                          title: Text(LocaleKeys
                                                              .removeCurrentImage
                                                              .tr()),
                                                          leading: const Icon(
                                                              Icons.delete),
                                                          onTap: () {
                                                            setState(() {
                                                              _medias[_medias
                                                                  .indexOf(
                                                                      image)] = "";
                                                            });
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            } else {
                                              selecImage();
                                            }
                                          },
                                          child: SizedBox(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    AppConstants
                                                            .defaultNumericValue *
                                                        3) /
                                                3,
                                            height: (MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    AppConstants
                                                            .defaultNumericValue *
                                                        3) /
                                                3,
                                            child: image.isEmpty
                                                ? Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.black12),
                                                    child: const Center(
                                                        child: Icon(
                                                            CupertinoIcons
                                                                .photo)),
                                                  )
                                                : Uri.parse(image).isAbsolute
                                                    ?
                                                    // !kIsWeb ?
                                                    CachedNetworkImage(
                                                        imageUrl: image,
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child: CircularProgressIndicator
                                                                    .adaptive()),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Center(
                                                                child: Icon(
                                                                    CupertinoIcons
                                                                        .photo)),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(image),
                                                        fit: BoxFit.cover,
                                                      ),
                                          ),
                                        ),
                                      )
                                      .toList()),
                          const SizedBox(
                              height: AppConstants.defaultNumericValue / 2),
                          Text(
                            "${LocaleKeys.youcanaddupto.tr()} ${AppConfig.maxNumOfMedia} ${LocaleKeys.images.tr()}",
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(
                              height: AppConstants.defaultNumericValue * 2),
                          UserDetailsTakingScreenPhotos(
                            prefs: widget.prefs,
                            nameController: _fullNameController,
                            userNameController: _userNameController,
                            walletBalanceNew: _walletBalance,
                            onGenderSelected: (gender) {
                              setState(() {
                                _gender = gender;
                              });
                            },
                            gender: _gender,
                            birthday: _birthday,
                            onBirthdaySelected: (birthday) {
                              setState(() {
                                _birthday = birthday;
                              });
                            },
                            birthdayController: _birthdayController,
                            selectedInterests: _interests,
                            onSelectInterest: (notSelected, interest) {
                              setState(() {
                                if (notSelected) {
                                  if (_interests.length >=
                                      AppConfig.maxNumOfInterests) {
                                    EasyLoading.showToast(
                                        "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                        toastPosition:
                                            EasyLoadingToastPosition.bottom);
                                  } else {
                                    _interests.add(interest);
                                  }
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                            onNext: () {
                              if (_formKey.currentState!.validate()) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                // if (_userLocation != null) {
                                //   _onSubmit();
                                // }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    _UserLocationScreen(
                      prefs: widget.prefs,
                      onLocationChanged: (location) {
                        setState(() {
                          _userLocation = location;
                        });
                      },
                      location: _userLocation,
                      onNext: () {
                        if (_formKey.currentState!.validate()) {
                          if (_userLocation != null) {
                            _onSubmit();
                          } else {
                            EasyLoading.showInfo(LocaleKeys
                                .pleasesetyourlocationtocontinue
                                .tr());
                          }
                        }
                      },
                      onBack: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDetailsTakingScreen extends ConsumerWidget {
  final SharedPreferences prefs;
  final TextEditingController nameController;
  final TextEditingController userNameController;
  final TextEditingController nickNameController;
  final double walletBalance = 0.0;
  final Function(String gender) onGenderSelected;
  final String? gender;
  final Function(DateTime birthday) onBirthdaySelected;
  final TextEditingController birthdayController;
  final DateTime? birthday;
  final List<String> selectedInterests;
  final Function(bool, String) onSelectInterest;
  final VoidCallback onNext;
  const UserDetailsTakingScreen({
    super.key,
    required this.prefs,
    required this.nameController,
    required this.userNameController,
    required this.nickNameController,
    required this.onGenderSelected,
    this.gender,
    required this.onBirthdaySelected,
    required this.birthdayController,
    this.birthday,
    required this.selectedInterests,
    required this.onSelectInterest,
    required this.onNext,
    required double walletBalanceNew,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.myNicknameis.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        TextFormField(
          controller: nickNameController,
          autofocus: false,
          validator: (value) {
            if (value!.isEmpty) {
              return LocaleKeys.pleaseenteryournickname.tr();
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppConstants.primaryColor.withOpacity(.1),
            hintText: "Ash",
            border: OutlineInputBorder(
              // Set outline border
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        Text(
          "${LocaleKeys.you.tr()} ${AppConfig.canChangeNickName ? LocaleKeys.can.tr() : LocaleKeys.cannot.tr()} ${LocaleKeys.changeitlater.tr()}",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Text(
          LocaleKeys.mynameis.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        TextFormField(
          controller: nameController,
          autofocus: false,
          validator: (value) {
            if (value!.isEmpty) {
              return LocaleKeys.pleaseEnterYourName.tr();
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppConstants.primaryColor.withOpacity(.1),
            hintText: "Ashley Magagula",
            border: OutlineInputBorder(
              // Set outline border
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        Text(
          "${LocaleKeys.you.tr()} ${AppConfig.canChangeName ? LocaleKeys.can.tr() : LocaleKeys.cannot.tr()} ${LocaleKeys.changeitlater.tr()}",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Text(
          LocaleKeys.myusernameis.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        TextFormField(
          controller: userNameController,
          autofocus: false,
          validator: (value) {
            if (value!.isEmpty) {
              return LocaleKeys.pleaseenteryourusername.tr();
            }

            // Check if username starts with an underscore or dot
            if (RegExp(r'^[._]').hasMatch(value)) {
              return LocaleKeys.usernamecannotunderscore.tr();
            }

            // Check if username contains only allowed characters
            if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
              return LocaleKeys.usernamecontainunderscores.tr();
            }
            return null; // Username is valid
          },
          decoration: InputDecoration(
            hintText: LocaleKeys.username.tr().toLowerCase(),
            filled: true,
            fillColor: AppConstants.primaryColor.withOpacity(.1),
            border: OutlineInputBorder(
              // Set outline border
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue / 2),
        Text(
          "${LocaleKeys.you.tr()} ${AppConfig.canChangeUserName ? LocaleKeys.can.tr() : LocaleKeys.cannot.tr()} ${LocaleKeys.changeitlater.tr()}",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        CustomButton(
            onPressed: onNext, text: LocaleKeys.next.tr().toUpperCase()),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
      ],
    );
  }
}

class UserDetailsTakingScreenGender extends StatelessWidget {
  final SharedPreferences prefs;
  final TextEditingController nameController;
  final TextEditingController userNameController;
  final double walletBalance = 0.0;
  final Function(String gender) onGenderSelected;
  final String? gender;
  final Function(DateTime birthday) onBirthdaySelected;
  final TextEditingController birthdayController;
  final DateTime? birthday;
  final List<String> selectedInterests;
  final Function(bool, String) onSelectInterest;
  final VoidCallback onNext;
  const UserDetailsTakingScreenGender({
    super.key,
    required this.prefs,
    required this.nameController,
    required this.userNameController,
    required this.onGenderSelected,
    this.gender,
    required this.onBirthdaySelected,
    required this.birthdayController,
    this.birthday,
    required this.selectedInterests,
    required this.onSelectInterest,
    required this.onNext,
    required double walletBalanceNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        Text(
          LocaleKeys.iam.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                onGenderSelected(AppConfig.maleText);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultNumericValue / 1.8,
                  horizontal: AppConstants.defaultNumericValue,
                ),
                decoration: BoxDecoration(
                  color: gender == AppConfig.maleText
                      ? AppConstants.primaryColor.withOpacity(0.4)
                      : null,
                  border:
                      Border.all(color: AppConstants.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                ),
                child: Text(
                  AppConfig.maleText.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.defaultNumericValue),
            GestureDetector(
              onTap: () {
                onGenderSelected(AppConfig.femaleText);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultNumericValue / 1.8,
                  horizontal: AppConstants.defaultNumericValue,
                ),
                decoration: BoxDecoration(
                  color: gender == AppConfig.femaleText
                      ? AppConstants.primaryColor.withOpacity(0.4)
                      : null,
                  border:
                      Border.all(color: AppConstants.primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                ),
                child: Text(
                  AppConfig.femaleText.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (AppConfig.allowTransGender)
              const SizedBox(width: AppConstants.defaultNumericValue),
            if (AppConfig.allowTransGender)
              GestureDetector(
                onTap: () {
                  onGenderSelected(AppConfig.transText);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppConstants.defaultNumericValue / 1.8,
                    horizontal: AppConstants.defaultNumericValue,
                  ),
                  decoration: BoxDecoration(
                    color: gender == AppConfig.transText
                        ? AppConstants.primaryColor.withOpacity(0.4)
                        : null,
                    border:
                        Border.all(color: AppConstants.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultNumericValue * 2),
                  ),
                  child: Text(
                    AppConfig.transText.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Text(
          LocaleKeys.selectyourgendertogetnoticed.tr(),
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        CustomButton(
            onPressed: onNext, text: LocaleKeys.next.tr().toUpperCase()),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
      ],
    );
  }
}

class UserDetailsTakingScreenDOB extends StatelessWidget {
  final SharedPreferences prefs;
  final TextEditingController nameController;
  final TextEditingController userNameController;
  final double walletBalance = 0.0;
  final Function(String gender) onGenderSelected;
  final String? gender;
  final Function(DateTime birthday) onBirthdaySelected;
  final TextEditingController birthdayController;
  final DateTime? birthday;
  final List<String> selectedInterests;
  final Function(bool, String) onSelectInterest;
  final VoidCallback onNext;
  const UserDetailsTakingScreenDOB({
    super.key,
    required this.prefs,
    required this.nameController,
    required this.userNameController,
    required this.onGenderSelected,
    this.gender,
    required this.onBirthdaySelected,
    required this.birthdayController,
    this.birthday,
    required this.selectedInterests,
    required this.onSelectInterest,
    required this.onNext,
    required double walletBalanceNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        Text(
          LocaleKeys.mybirthdayis.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        TextFormField(
          controller: birthdayController,
          autofocus: true,
          readOnly: true,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 26),
          decoration: InputDecoration(
            hintText: "MM/DD/YYYY",
            filled: true,
            fillColor: AppConstants.primaryColor.withOpacity(.1),
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
                borderSide: BorderSide.none),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return LocaleKeys.pleaseSelectYourBirthday.tr();
            }
            return null;
          },
          onTap: () {
            const duration = Duration(days: 365 * AppConfig.minimumAgeRequired);
            (kIsWeb)
                ?
                // isDemo
                //     ? {
                //         onBirthdaySelected(DateTime.now().subtract(duration)),
                //         birthdayController.text = DateFormat("MM/dd/yyyy")
                //             .format(DateTime.now().subtract(duration))
                //       }
                //     :
                showWebDatePicker(
                    context: context,
                    initialDate: birthday ?? DateTime.now().subtract(duration),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now().subtract(duration),
                    //width: 300,
                    //withoutActionButtons: true,
                    weekendDaysColor: Colors.red,
                  ).then((value) {
                    if (value != null) {
                      onBirthdaySelected(value);
                      birthdayController.text =
                          DateFormat("MM/dd/yyyy").format(value);
                    }
                  })
                : showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().subtract(duration),
                        initialDate:
                            birthday ?? DateTime.now().subtract(duration))
                    .then((value) {
                    if (value != null) {
                      onBirthdaySelected(value);
                      birthdayController.text =
                          DateFormat("MM/dd/yyyy").format(value);
                    }
                  });
          },
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Text(
          "${LocaleKeys.youmustbe.tr()} ${AppConfig.minimumAgeRequired} ${LocaleKeys.yearsoldtousethisapp.tr()}",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        CustomButton(
            onPressed: onNext, text: LocaleKeys.next.tr().toUpperCase()),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
      ],
    );
  }
}

class UserDetailsTakingScreenInterests extends StatelessWidget {
  final SharedPreferences prefs;
  final TextEditingController nameController;
  final TextEditingController userNameController;
  final double walletBalance = 0.0;
  final Function(String gender) onGenderSelected;
  final String? gender;
  final Function(DateTime birthday) onBirthdaySelected;
  final TextEditingController birthdayController;
  final DateTime? birthday;
  final List<String> selectedInterests;
  final Function(bool, String) onSelectInterest;
  final VoidCallback onNext;
  const UserDetailsTakingScreenInterests({
    super.key,
    required this.prefs,
    required this.nameController,
    required this.userNameController,
    required this.onGenderSelected,
    this.gender,
    required this.onBirthdaySelected,
    required this.birthdayController,
    this.birthday,
    required this.selectedInterests,
    required this.onSelectInterest,
    required this.onNext,
    required double walletBalanceNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LocaleKeys.myInterests.tr(),
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Wrap(
          spacing: AppConstants.defaultNumericValue / 2,
          children: AppConfig.interests
              .map(
                (interest) => ChoiceChip(
                  label:
                      Text(interest[0].toUpperCase() + interest.substring(1)),
                  selected: selectedInterests.contains(interest),
                  shape: selectedInterests.contains(interest)
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue * 2),
                          side: const BorderSide(
                              color: AppConstants.primaryColor, width: 1),
                        )
                      : null,
                  selectedColor: AppConstants.primaryColor.withOpacity(0.3),
                  onSelected: (notSelected) {
                    onSelectInterest(notSelected, interest);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue),
        Text(
          "${LocaleKeys.pleaseselectyourintereststogetnoticed.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        CustomButton(
            onPressed: onNext, text: LocaleKeys.next.tr().toUpperCase()),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
      ],
    );
  }
}

class UserDetailsTakingScreenPhotos extends StatelessWidget {
  final SharedPreferences prefs;
  final TextEditingController nameController;
  final TextEditingController userNameController;
  final double walletBalance = 0.0;
  final Function(String gender) onGenderSelected;
  final String? gender;
  final Function(DateTime birthday) onBirthdaySelected;
  final TextEditingController birthdayController;
  final DateTime? birthday;
  final List<String> selectedInterests;
  final Function(bool, String) onSelectInterest;
  final VoidCallback onNext;
  const UserDetailsTakingScreenPhotos({
    super.key,
    required this.prefs,
    required this.nameController,
    required this.userNameController,
    required this.onGenderSelected,
    this.gender,
    required this.onBirthdaySelected,
    required this.birthdayController,
    this.birthday,
    required this.selectedInterests,
    required this.onSelectInterest,
    required this.onNext,
    required double walletBalanceNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
        CustomButton(
            onPressed: onNext, text: LocaleKeys.next.tr().toUpperCase()),
        const SizedBox(height: AppConstants.defaultNumericValue * 2),
      ],
    );
  }
}

class _UserLocationScreen extends ConsumerWidget {
  final Function(UserLocation location) onLocationChanged;
  final UserLocation? location;

  final VoidCallback onNext;
  final VoidCallback onBack;
  final SharedPreferences prefs;
  const _UserLocationScreen({
    required this.onLocationChanged,
    required this.prefs,
    this.location,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, ref) {
    final UserLocation demoLocation = UserLocation(
      latitude: 48.8566,
      longitude: 2.3522,
      addressText: LocaleKeys.parisfrance.tr(),
    );
    final currentLocationProviderProvider =
        ref.watch(getCurrentLocationProviderProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.mylocationis.tr(),
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          GestureDetector(
            onTap: () async {
              UserLocation? location;
              // isDemo
              //     ? location = demoLocation
              //     :

              currentLocationProviderProvider.when(
                data: (data) {
                  if (data != null) {
                    location = data;
                  }
                },
                error: (e, __) {},
                loading: () {},
              );

              if (location != null) {
                onLocationChanged(location!);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
              ),
              child: Row(
                children: [
                  WebsafeSvg.asset(
                    height: 36,
                    width: 36,
                    fit: BoxFit.fitHeight,
                    pinIcon,
                    colorFilter: const ColorFilter.mode(
                      AppConstants.primaryColor,
                      //  Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultNumericValue),
                  Expanded(
                    child: Text(
                      location?.addressText ??
                          "${LocaleKeys.set.tr()} ${LocaleKeys.currentLocation.tr()}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue / 2),
          Center(
            child: ElevatedButton(
              child: const Text("Pick From Map"),
              onPressed: () async {
                UserLocation? location;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MapLocationPicker(
                        apiKey: locationApiKey,
                        popOnNextButtonTaped: true,
                        currentLatLng: const LatLng(29.146727, 76.464895),
                        onNext: (GeocodingResult? result) {
                          if (result != null) {
                            location = UserLocation(
                                latitude: result.geometry.location.lat,
                                longitude: result.geometry.location.lng,
                                addressText: result.formattedAddress ?? "");
                          }
                          if (location != null) {
                            onLocationChanged(location!);
                          }
                        },
                        onSuggestionSelected: (PlacesDetailsResponse? result) {
                          if (result != null) {
                            location = UserLocation(
                                latitude: result.result.geometry!.location.lat,
                                longitude: result.result.geometry!.location.lng,
                                addressText:
                                    result.result.formattedAddress ?? "");
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          Text(
            LocaleKeys.youmustsetyourlocationtousethisapp.tr(),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue * 2),
          Row(
            children: [
              Expanded(
                  child: CustomButton(
                      onPressed: onBack,
                      text: LocaleKeys.back.tr().toUpperCase())),
              const SizedBox(width: AppConstants.defaultNumericValue),
              Expanded(
                  child: CustomButton(
                      onPressed: onNext,
                      text: LocaleKeys.finish.tr().toUpperCase())),
            ],
          ),
          const SizedBox(height: AppConstants.defaultNumericValue * 2),
        ],
      ),
    );
  }
}
