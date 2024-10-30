// ignore_for_file: unused_local_variable, library_private_types_in_public_api, must_be_immutable, avoid_print, use_build_context_synchronously, await_only_futures, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/comment/comment_screen.dart' as com;
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/storyCamera/upload_screen.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/teelsCamera/upload_teel.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_compress/video_compress.dart' as compress;
import 'package:video_player/video_player.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/date_formater.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/feed_model.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/models/stories_model.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/feed_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/variants_gen.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/ads/banner_ads.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';
import 'package:lamatdating/views/report/report_page.dart';
import 'package:lamatdating/views/status/status_view.dart';
import 'package:lamatdating/views/status/components/TextStatus/text_status.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:lamatdating/views/tabs/feeds/edit_feed_page.dart';
import 'package:lamatdating/views/tabs/feeds/feed_post_page.dart'
    if (dart.library.html) 'package:lamatdating/views/tabs/feeds/feed_post_page_web.dart';
import 'package:lamatdating/views/tabs/home/notification_page.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:lamatdating/views/tabs/profile/profile_nested_page.dart';
import 'package:lamatdating/views/teelsCamera/camera_teels.dart';

class FeedsPage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final String currentUserNo;
  final UserProfileModel? user;
  const FeedsPage(
      {super.key,
      required this.prefs,
      required this.currentUserNo,
      required this.user});

  @override
  ConsumerState<FeedsPage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<FeedsPage> {
  // late Stream myStatusUpdates;
  // UserProfileModel? currentUserProf;

  Observer? observer;
  StatusProvider? statusProvider;
  SmartContactProviderWithLocalStoreData? contactsProvider;

  @override
  void initState() {
    setStatusBarColor(widget.prefs);
    

    super.initState();

    // myStatusUpdates = FirebaseFirestore.instance
    //     .collection(DbPaths.collectionnstatus)
    //     .doc(widget.currentUserNo)
    //     .snapshots();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // final box = Hive.box(HiveConstants.hiveBox);
      // currentUserProf = UserProfileModel.fromJson(
      //     await box.get(HiveConstants.currentUserProf));
       observer = ref.watch(observerProvider);
      statusProvider = ref.watch(statusProviderProvider);
      contactsProvider = ref.watch(smartContactProvider);
      if (kIsWeb) {
        statusProvider!.searchContactStatus(
          widget.currentUserNo,
          FutureGroup(),
          contactsProvider!.alreadyJoinedSavedUsersPhoneNameAsInServer,
        );
      }
     
      
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const SizedBox(),
        toolbarHeight: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.defaultNumericValue),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return SubscriptionBuilder(
                  builder: (context, isPremiumUser) {
                    return FilterInteraction(
                      contactsProvider: contactsProvider,
                      isPremiumUser: isPremiumUser,
                      user: widget.user,
                      onNavigateBack: () async {
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      currentUserNo: widget.currentUserNo,
                      prefs: widget.prefs,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationButton extends ConsumerWidget {
  final SharedPreferences prefs;
  const NotificationButton({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context, ref) {
    final matchingNotifications = ref.watch(notificationsStreamProvider);

    int count = 0;

    matchingNotifications.whenData((value) {
      for (var element in value) {
        if (element.isRead == false) {
          count++;
        }
      }
    });

    return Stack(
      children: [
        CustomIconButton(
          icon: bellIcon,
          margin: count > 0
              ? const EdgeInsets.only(
                  right: AppConstants.defaultNumericValue / 3)
              : null,
          onPressed: () {
            (!Responsive.isDesktop(context))
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  )
                : ref
                    .read(arrangementProvider.notifier)
                    .setArrangement(const NotificationPage());
          },
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
        ),
        if (count > 0)
          Positioned(
            bottom: 0,
            right: 0,
            child: Badge(
              backgroundColor: AppConstants.primaryColor,
              // padding: const EdgeInsets.only(bottom: 5),
              // smallSize: 18,
              // largeSize: 18,
              label: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    // fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FilterInteraction extends ConsumerStatefulWidget {
  final SmartContactProviderWithLocalStoreData? contactsProvider;
  final bool isPremiumUser;
  final UserProfileModel? user;
  final VoidCallback? onNavigateBack;
  final SharedPreferences prefs;
  final String currentUserNo;
  const FilterInteraction({
    super.key,
    required this.isPremiumUser,
    required this.prefs,
    required this.currentUserNo,
    required this.contactsProvider,
    required this.user,
    this.onNavigateBack,
  });

  @override
  ConsumerState<FilterInteraction> createState() => _FilterInteractionState();
}

class _FilterInteractionState extends ConsumerState<FilterInteraction> {
  late Stream myStatusUpdates;

  AdWidget? adWidget;
  BannerAd? myBanner;
  int _numInterstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;
  List phoneNumberVariants = [];
  bool isFetching = true;
  String? userFullname;
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();

  Uint8List? pickedFile;

  bool isPhoto = true;

  Box<dynamic>? box;

  List<FeedModel> cachedFeedsList = [];
  List<UserProfileModel> cachedUSersList = [];

  @override
  void initState() {
    setStatusBarColor(widget.prefs);
    box = Hive.box(HiveConstants.hiveBox);

    setUserFields();
    if (widget.currentUserNo != '') {
      getModel();
    }
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    _moreMenuController.hideMenu();
    super.initState();
    myStatusUpdates = FirebaseFirestore.instance
        .collection(DbPaths.collectionnstatus)
        .doc(widget.currentUserNo)
        .snapshots();
    Lamat.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final cachedFeeds = await box!.get(HiveConstants.cachedFeeds);
      if (cachedFeeds != null && cachedFeeds.isNotEmpty) {
        for (int i = 0; i < cachedFeeds.length; i++) {
          final feed = FeedModel.fromJson(cachedFeeds[i]);
          cachedFeedsList.add(feed);
        }
      }
      final cachedUsers = await box!.get(HiveConstants.allOtherUsersKey);
      if (cachedUsers != null && cachedUsers.isNotEmpty) {
        for (int i = 0; i < cachedUsers.length; i++) {
          final user = UserProfileModel.fromJson(cachedUsers[i]);
          cachedUSersList.add(user);
        }
      }

      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  void setUserFields() async {
    if (widget.currentUserNo != '') {
      final userProfileRef =
          await box!.get(HiveConstants.currentUserProf).then((data) {
        final user = UserProfileModel.fromJson(data);
        userFullname = user.nickname;
        phoneNumberVariants = phoneNumberVariantsList(
            countrycode: user.countryCode, phonenumber: user.phone_raw);
        isFetching = false;
      });
    }
  }

  DataModel? _cachedModel;

  int currentIndex = 0;

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.prefs.getString(Dbkeys.phone));
    return _cachedModel;
  }

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
        Dbkeys.statusPUBLISHERPHONEVARIANTS: phoneNumberVariants,
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
                                                  phoneNumberVariants:
                                                      phoneNumberVariants)))
                                      : ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(TextStatus(
                                              currentuserNo:
                                                  widget.currentUserNo,
                                              phoneNumberVariants:
                                                  phoneNumberVariants));
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final feedList = ref.watch(getFeedsProvider(ref));
    final observer = ref.watch(observerProvider);
    final statusProvider = ref.watch(statusProviderProvider);
    final prefs = ref.watch(sharedPreferences).value;
    final registrationUser = ref.watch(userProfileFutureProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  const SizedBox(width: 5),
                    Image.asset(
                      AppConstants.symbolColor,
                      // color: AppConstants.primaryColor,
                      
                      height: 50,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      child: AppRes.appLogo != null
                          ? CachedNetworkImage(
                              imageUrl: AppRes.appLogo!,
                              placeholder: (context, url) => Image.asset(
                              AppConstants.logo,
                              // color: AppConstants.primaryColor,
                              
                              height: 50,
                              fit: BoxFit.fitHeight,
                            ),
                              errorWidget: (context, url, error) =>
                                  Image.asset(
                              AppConstants.logo,
                              // color: AppConstants.primaryColor,
                              
                              height: 50,
                              fit: BoxFit.fitHeight,
                            ),
                              fit: BoxFit.fitHeight,
                              
                              height: 50)
                          // Image.network(
                          //     AppRes.appLogo!,
                          //     // color: Colors.white,
                          //     width: 150,
                          //     height: 50,
                          //     fit: BoxFit.contain,
                          //   )
                          : Image.asset(
                              AppConstants.logo,
                              // color: AppConstants.primaryColor,
                              
                              height: 50,
                              fit: BoxFit.fitHeight,
                            ),
                    ),
                    const Spacer(),
                    NotificationButton(prefs: prefs!),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                  top: AppConstants.defaultNumericValue,
                  bottom: 0,
                  left: 16,
                  right: 16),
              child: CreateNewPostSection(),
            ),
            Container(
                // width: width,
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: AppConstants.defaultNumericValue),
                // color: Teme.isDarktheme(widget.prefs)
                //     ? AppConstants.backgroundColorDark
                //     : AppConstants.backgroundColor,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        child: GestureDetector(
                            onTap: () async {
                              if (kIsWeb) {
                                final imagePath =
                                    await pickMediaWeb(isVideo: true)
                                        .then((value) {
                                  final observer = ref.watch(observerProvider);
                                  setState(() {
                                    isPhoto = false;
                                  });
                                  if (value != null) {
                                    if (value.lengthInBytes / (1024 * 1024) <
                                        observer.maxFileSizeAllowedInMB) {
                                      // setState(() {
                                      //   // isEdited = true;
                                      //   uploadScreen = UploadScreen(
                                      //       videoWeb: imagePath,
                                      //       thumbNailWeb: null,
                                      //       soundId: _selectedMusic?.soundId,
                                      //       sound: _selectedMusic?.sound,
                                      //       isPhoto: isPhoto);
                                      // });
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.only(
                                                            bottom:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                    child: UploadScreenTeels(
                                                        postVideoWeb: value,
                                                        thumbNail: null,
                                                        soundId: null,
                                                        sound: null,
                                                        isPhoto: isPhoto))),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          ),
                                        ),
                                        backgroundColor:
                                            AppConstants.backgroundColor,
                                        isScrollControlled: true,
                                      );
                                    } else {
                                      EasyLoading.showError(
                                          "${LocaleKeys.filesizeexceeded.tr()}: ${observer.maxFileSizeAllowedInMB}MB");
                                    }
                                  }
                                });
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CameraScreenTeels()));
                              }
                            },
                            child: Container(
                                // width: width * .22,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue),
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: Row(
                                      children: [
                                        WebsafeSvg.asset(
                                          height: 36,
                                          width: 36,
                                          fit: BoxFit.fitHeight,
                                          reelsActiveIcon,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.red,
                                            //  AppConstants.primaryColor,
                                            // AppConstants.secondaryColor,
                                            // Colors.white,
                                            // Colors.grey,
                                            //  Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        Text(
                                          LocaleKeys.teel.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                fontSize: 12,
                                              ),
                                        )
                                      ],
                                    )))),
                      ),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue * .5,
                      ),
                      SizedBox(
                        width: 80,
                        child: GestureDetector(
                            onTap: () {
                              ref.watch(userProfileFutureProvider).when(
                                  data: (data) {
                                    if (data != null) {
                                      if (data.followersCount! >=
                                          SettingRes.minFansForLive!) {
                                        !Responsive.isDesktop(context)
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (c) =>
                                                      const LiveStreamScreen(),
                                                ),
                                              )
                                            : ref
                                                .read(arrangementProvider
                                                    .notifier)
                                                .setArrangement(
                                                  const LiveStreamScreen(),
                                                );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                AppRes.minimumCoinRequired),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  error:
                                      (Object error, StackTrace stackTrace) {},
                                  loading: () {});
                            },
                            child: Container(
                                // width: width * .22,
                                height: 30,
                                decoration: BoxDecoration(
                                  color:
                                      AppConstants.primaryColor.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue),
                                  border: Border.all(
                                    color: AppConstants.primaryColor,
                                    width: 1.0,
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: Row(
                                      children: [
                                        WebsafeSvg.asset(
                                          height: 36,
                                          width: 36,
                                          fit: BoxFit.fitHeight,
                                          livestreamIcon,
                                          colorFilter: const ColorFilter.mode(
                                            // Colors.blueGrey,
                                            AppConstants.primaryColor,
                                            // AppConstants.secondaryColor,
                                            // Colors.white,
                                            // Colors.grey,
                                            //  Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        Text(
                                          LocaleKeys.live.tr(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                fontSize: 12,
                                              ),
                                        )
                                      ],
                                    )))),
                      ),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue * .5,
                      ),
                      // GestureDetector(
                      //     onTap: () {},
                      //     child: Container(
                      //         width: width * .22,
                      //         height: 30,
                      //         decoration: BoxDecoration(
                      //           color: AppConstants.secondaryColor
                      //               .withOpacity(.1),
                      //           borderRadius: BorderRadius.circular(
                      //               AppConstants.defaultNumericValue),
                      //           border: Border.all(
                      //             color: AppConstants.secondaryColor,
                      //             width: 1.0,
                      //           ),
                      //         ),
                      //         child: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //                 horizontal: 5, vertical: 5),
                      //             child: Row(
                      //               children: [
                      //                 WebsafeSvg.asset(
                      //                   addvideoIcon,
                      //                   color: AppConstants.secondaryColor,
                      //                 ),
                      //                 Text(
                      //                   "Video",
                      //                   style: Theme.of(context)
                      //                       .textTheme
                      //                       .titleSmall,
                      //                 )
                      //               ],
                      //             )))),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue * .5,
                      ),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue * .5,
                      ),
                    ],
                  ),
                )),
            Container(
              color: !Teme.isDarktheme(prefs)
                  ? Colors.grey.withOpacity(.2)
                  : Colors.black,
              height: 7,
              width: width,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                StreamBuilder(
                    stream: myStatusUpdates,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          color: Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor,
                          elevation: 0.0,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  AppConstants.defaultNumericValue, 8, 8, 8),
                              child: InkWell(
                                onTap: () {},
                                child: SizedBox(
                                  width: 90,
                                  height: 140,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      (widget.user != null)
                                          ? customCircleAvatarStatus(
                                              profilePic:
                                                  widget.user!.profilePicture)
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                color:
                                                    AppConstants.primaryColor,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                      Positioned(
                                          bottom: 0,
                                          child: Container(
                                            height: 70,
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: Teme.isDarktheme(prefs)
                                                  ? AppConstants
                                                      .backgroundColorDark
                                                  : AppConstants
                                                      .backgroundColor,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                    AppConstants
                                                            .defaultNumericValue *
                                                        .9),
                                                bottomRight: Radius.circular(
                                                    AppConstants
                                                            .defaultNumericValue *
                                                        .9),
                                              ),
                                            ),
                                          )),
                                      CircleAvatar(
                                        backgroundColor: Teme.isDarktheme(prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        child: const Icon(
                                          Icons.add_circle_rounded,
                                          color: AppConstants.primaryColor,
                                          size: 40,
                                        ),
                                      ),
                                      Positioned(
                                          bottom: 15,
                                          child: Center(
                                              child: Text(
                                            LocaleKeys.createStory.tr(),
                                            textAlign: TextAlign.center,
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
                        );
                      } else if (snapshot.hasData && snapshot.data.exists) {
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
                                .contains(status[Dbkeys.statusItemID])) {
                              seen = seen + 1;
                            }
                          });
                        }

                        return Card(
                          color: Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor,
                          elevation: 0.0,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppConstants.defaultNumericValue, 0, 0, 0),
                            child: Stack(
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    !(Responsive.isDesktop(context))
                                        ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StatusView(
                                                      model: _cachedModel!,
                                                      prefs: widget.prefs,
                                                      currentUserNo:
                                                          widget.currentUserNo,
                                                      statusDoc: snapshot.data,
                                                      postedbyFullname:
                                                          userFullname ?? '',
                                                      postedbyPhotourl: widget
                                                          .user!.profilePicture,
                                                    )))
                                        : ref
                                            .read(arrangementProvider.notifier)
                                            .setArrangement(StatusView(
                                              model: _cachedModel!,
                                              prefs: widget.prefs,
                                              currentUserNo:
                                                  widget.currentUserNo,
                                              statusDoc: snapshot.data,
                                              postedbyFullname:
                                                  userFullname ?? '',
                                              postedbyPhotourl:
                                                  widget.user!.profilePicture,
                                            ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5, bottom: 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue *
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
                                                        seen
                                                    ? AppConstants.primaryColor
                                                        .withOpacity(0.7)
                                                    : Colors.grey
                                                        .withOpacity(0.7)
                                                : Colors.grey.withOpacity(0.7),
                                          )),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: snapshot.data[Dbkeys.statusITEMSLIST]
                                                        [snapshot.data[Dbkeys.statusITEMSLIST].length - 1]
                                                    [Dbkeys.statusItemTYPE] ==
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
                                                    color: Colors.white54),
                                              )
                                            : snapshot.data[Dbkeys.statusITEMSLIST]
                                                            [snapshot
                                                                    .data[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length -
                                                                1]
                                                        [Dbkeys.statusItemTYPE] ==
                                                    Dbkeys.statustypeVIDEO
                                                ? Container(
                                                    width: 90.0,
                                                    height: 140.0,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image:
                                                              CachedNetworkImageProvider(
                                                            snapshot.data[Dbkeys
                                                                .statusITEMSLIST][snapshot
                                                                    .data[Dbkeys
                                                                        .statusITEMSLIST]
                                                                    .length -
                                                                1]['thumbNail'],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        color: AppConstants
                                                            .primaryColor
                                                            .withOpacity(.2),
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue)),
                                                    child: Icon(
                                                        Icons
                                                            .play_circle_fill_rounded,
                                                        color: AppConstants
                                                            .primaryColor
                                                            .withOpacity(.5)),
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: snapshot.data[Dbkeys
                                                        .statusITEMSLIST][snapshot
                                                            .data[Dbkeys
                                                                .statusITEMSLIST]
                                                            .length -
                                                        1][Dbkeys.statusItemURL],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      width: 90.0,
                                                      height: 140.0,
                                                      decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue)),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            Container(
                                                      width: 90.0,
                                                      height: 140.0,
                                                      decoration: BoxDecoration(
                                                          color: AppConstants
                                                              .primaryColor
                                                              .withOpacity(.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue)),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      width: 90.0,
                                                      height: 140.0,
                                                      decoration: BoxDecoration(
                                                          color: AppConstants
                                                              .primaryColor
                                                              .withOpacity(.1),
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
                                        observer.isAllowCreatingStatus == false
                                            ? const SizedBox()
                                            : CustomPopupMenu(
                                                menuBuilder: () => ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue /
                                                          2),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.white),
                                                    child: IntrinsicWidth(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          MoreMenuTitle(
                                                            title: LocaleKeys
                                                                .image
                                                                .tr(),
                                                            icon: cameraIcon,
                                                            onTap: () async {
                                                              _moreMenuController
                                                                  .hideMenu();
                                                              // !kIsWeb
                                                              //       ?
                                                              !Responsive
                                                                      .isDesktop(
                                                                          context)
                                                                  ? Navigator
                                                                      .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              CameraScreenStory(
                                                                                prefs: prefs,
                                                                              )),
                                                                    )
                                                                  : ref
                                                                      .read(arrangementProvider
                                                                          .notifier)
                                                                      .setArrangement(
                                                                          CameraScreenStory(
                                                                        prefs:
                                                                            prefs,
                                                                      ));
                                                              // await pickMediaAsBytes()
                                                              //     .then(
                                                              //         (value) async {
                                                              //   setState(
                                                              //       () {
                                                              //     pickedFile =
                                                              //         value;
                                                              //   });
                                                              // });
                                                              if (pickedFile !=
                                                                  null) {
                                                                final editedImage =
                                                                    await showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          ImageEditor(
                                                                    image:
                                                                        pickedFile,
                                                                  ),
                                                                  shape:
                                                                      const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                    ),
                                                                  ),
                                                                  backgroundColor:
                                                                      AppConstants
                                                                          .backgroundColor,
                                                                  isScrollControlled:
                                                                      true,
                                                                );
                                                                showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  builder: (context) => SingleChildScrollView(
                                                                      child: Container(
                                                                          padding: EdgeInsets.only(
                                                                              bottom: MediaQuery.of(context)
                                                                                  .viewInsets
                                                                                  .bottom),
                                                                          child: UploadScreenStory(
                                                                              photoWeb: editedImage,
                                                                              thumbNailWeb: editedImage,
                                                                              soundId: null,
                                                                              sound: null,
                                                                              isPhoto: isPhoto))),
                                                                  shape:
                                                                      const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15),
                                                                    ),
                                                                  ),
                                                                  backgroundColor:
                                                                      AppConstants
                                                                          .backgroundColor,
                                                                  isScrollControlled:
                                                                      true,
                                                                );
                                                                // Navigator
                                                                //     .push(
                                                                //   context,
                                                                //   MaterialPageRoute(
                                                                //     builder: (context) => PreviewScreen(
                                                                //         postVideo:
                                                                //             pickedFile,
                                                                //         thumbNail:
                                                                //             pickedFile,
                                                                //         sound:
                                                                //             "",
                                                                //         isPhoto:
                                                                //             isPhoto),
                                                                //   ),
                                                                // );
                                                              }
                                                              // :
                                                              //  Navigator
                                                              //     .push(
                                                              //   context,
                                                              //   MaterialPageRoute(
                                                              //       builder:
                                                              //           (context) =>
                                                              //               const w.CameraScreenStory()),
                                                              // );
                                                            },
                                                          ),
                                                          // MoreMenuTitle(
                                                          //   title:
                                                          //       LocaleKeys
                                                          //           .video
                                                          //           .tr(),
                                                          //   icon:
                                                          //       videoIcon,
                                                          //   onTap:
                                                          //       () async {
                                                          //     _moreMenuController
                                                          //         .hideMenu();
                                                          //     // !kIsWeb
                                                          //     //       ?
                                                          //     // Navigator.push(
                                                          //     //   context,
                                                          //     //   MaterialPageRoute(
                                                          //     //       builder:
                                                          //     //           (context) =>
                                                          //     //               CameraScreenStory(
                                                          //     //                 prefs: prefs!,
                                                          //     //               )),
                                                          //     // );
                                                          //     await pickMediaAsBytes(
                                                          //             isVideo:
                                                          //                 true)
                                                          //         .then(
                                                          //             (value) async {
                                                          //       final Uint8List
                                                          //           bytes =
                                                          //           await pickedFile!;
                                                          //       setState(
                                                          //           () {
                                                          //         pickedFile =
                                                          //             value;
                                                          //         isPhoto =
                                                          //             false;
                                                          //       });
                                                          //     });
                                                          //     if (pickedFile !=
                                                          //         null) {
                                                          //       // final editedImage =
                                                          //       //     await showModalBottomSheet(
                                                          //       //   context:
                                                          //       //       context,
                                                          //       //   builder:
                                                          //       //       (context) =>
                                                          //       //           ImageEditor(
                                                          //       //     image:
                                                          //       //         pickedFile,
                                                          //       //     appBar: Teme.isDarktheme(widget.prefs)
                                                          //       //         ? AppConstants.backgroundColorDark
                                                          //       //         : AppConstants.backgroundColor,
                                                          //       //     // bottomBarColor: Colors.blue,
                                                          //       //   ),
                                                          //       //   shape:
                                                          //       //       const RoundedRectangleBorder(
                                                          //       //     borderRadius:
                                                          //       //         BorderRadius.only(
                                                          //       //       topLeft:
                                                          //       //           Radius.circular(15),
                                                          //       //       topRight:
                                                          //       //           Radius.circular(15),
                                                          //       //     ),
                                                          //       //   ),
                                                          //       //   backgroundColor:
                                                          //       //       AppConstants.backgroundColor,
                                                          //       //   isScrollControlled:
                                                          //       //       true,
                                                          //       // );
                                                          //       showModalBottomSheet(
                                                          //         context:
                                                          //             context,
                                                          //         builder:
                                                          //             (context) =>
                                                          //                 SingleChildScrollView(child: Container(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: UploadScreen(photoWeb: pickedFile, thumbNailWeb: null, soundId: null, sound: null, isPhoto: isPhoto))),
                                                          //         shape:
                                                          //             const RoundedRectangleBorder(
                                                          //           borderRadius:
                                                          //               BorderRadius.only(
                                                          //             topLeft:
                                                          //                 Radius.circular(15),
                                                          //             topRight:
                                                          //                 Radius.circular(15),
                                                          //           ),
                                                          //         ),
                                                          //         backgroundColor:
                                                          //             AppConstants.backgroundColor,
                                                          //         isScrollControlled:
                                                          //             true,
                                                          //       );
                                                          //       // Navigator
                                                          //       //     .push(
                                                          //       //   context,
                                                          //       //   MaterialPageRoute(
                                                          //       //     builder: (context) => PreviewScreen(
                                                          //       //         postVideo:
                                                          //       //             pickedFile,
                                                          //       //         thumbNail:
                                                          //       //             pickedFile,
                                                          //       //         sound:
                                                          //       //             "",
                                                          //       //         isPhoto:
                                                          //       //             isPhoto),
                                                          //       //   ),
                                                          //       // );
                                                          //     }
                                                          //     // :
                                                          //     //  Navigator
                                                          //     //     .push(
                                                          //     //   context,
                                                          //     //   MaterialPageRoute(
                                                          //     //       builder:
                                                          //     //           (context) =>
                                                          //     //               const w.CameraScreenStory()),
                                                          //     // );
                                                          //   },
                                                          // ),

                                                          MoreMenuTitle(
                                                            title: LocaleKeys
                                                                .text
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
                                                                              phoneNumberVariants:
                                                                                  phoneNumberVariants)))
                                                                  : ref.read(arrangementProvider.notifier).setArrangement(TextStatus(
                                                                      currentuserNo:
                                                                          widget
                                                                              .currentUserNo,
                                                                      phoneNumberVariants:
                                                                          phoneNumberVariants));
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
                                                controller: _moreMenuController,
                                                showArrow: true,
                                                arrowColor: Colors.white,
                                                barrierColor: AppConstants
                                                    .primaryColor
                                                    .withOpacity(0.1),
                                                child: GestureDetector(
                                                  child: const CircleAvatar(
                                                    radius: 15,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: Icon(
                                                      Icons.add_circle_rounded,
                                                      color: AppConstants
                                                          .primaryColor,
                                                      size: 29,
                                                    ),
                                                  ),
                                                ),
                                              )

                                    //  InkWell(
                                    //   onTap: observer
                                    //               .isAllowCreatingStatus ==
                                    //           false
                                    //       ? () {
                                    //           Lamat.showRationale(
                                    //             "This feature is temporarily disabled by Admin",
                                    //           );
                                    //         }
                                    //       : () async {
                                    //         vv
                                    //           showMediaOptions(
                                    //               ishideTextStatusbutton:
                                    //                   false,
                                    //               phoneVariants:
                                    //                   phoneNumberVariants,
                                    //               context: context,
                                    //               ref: ref,
                                    //               pickVideoCallback: () {
                                    //                 Navigator.push(
                                    //                     context,
                                    //                     MaterialPageRoute(
                                    //                         builder:
                                    //                             (context) =>
                                    //                                 StatusVideoEditor(
                                    //                                   prefs:
                                    //                                       widget.prefs,
                                    //                                   callback: (v,
                                    //                                       d,
                                    //                                       t) async {
                                    //                                     Navigator.of(context).pop();
                                    //                                     await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeVIDEO, file: d, caption: v, ref: ref, duration: t);
                                    //                                   },
                                    //                                   title:
                                    //                                       "Create Status",
                                    //                                 )));
                                    //               },
                                    //               pickImageCallback: () {
                                    //                 Navigator.push(
                                    //                     context,
                                    //                     MaterialPageRoute(
                                    //                         builder:
                                    //                             (context) =>
                                    //                                 StatusImageEditor(
                                    //                                   prefs:
                                    //                                       widget.prefs,
                                    //                                   callback:
                                    //                                       (v, d) async {
                                    //                                     Navigator.of(context).pop();
                                    //                                     await uploadFile(filename: DateTime.now().millisecondsSinceEpoch.toString(), type: Dbkeys.statustypeIMAGE, file: d, ref: ref, caption: v);
                                    //                                   },
                                    //                                   title:
                                    //                                       "Create Status",
                                    //                                 )));
                                    //               });
                                    //         },
                                    //   child: const CircleAvatar(
                                    //     backgroundColor: Colors.white,
                                    //     child: Icon(
                                    //       Icons.add_circle_rounded,
                                    //       color:
                                    //           AppConstants.primaryColor,
                                    //       size: 40,
                                    //     ),
                                    //   ),
                                    // ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || !snapshot.data.exists) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              AppConstants.defaultNumericValue, 8, 0, 8),
                          child: observer.isAllowCreatingStatus == false
                              ? const SizedBox()
                              : CustomPopupMenu(
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
                                              title: LocaleKeys.camera.tr(),
                                              icon: cameraIcon,
                                              onTap: () {
                                                _moreMenuController.hideMenu();

                                                !Responsive.isDesktop(context)
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                CameraScreenStory(
                                                                  prefs: prefs,
                                                                )),
                                                      )
                                                    : ref
                                                        .read(
                                                            arrangementProvider
                                                                .notifier)
                                                        .setArrangement(
                                                            CameraScreenStory(
                                                          prefs: prefs,
                                                        ));
                                              },
                                            ),
                                            MoreMenuTitle(
                                              title: LocaleKeys.text.tr(),
                                              icon: textIcon,
                                              onTap: () {
                                                _moreMenuController.hideMenu();
                                                (!Responsive.isDesktop(context))
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => TextStatus(
                                                                currentuserNo:
                                                                    widget
                                                                        .currentUserNo,
                                                                phoneNumberVariants:
                                                                    phoneNumberVariants)))
                                                    : ref
                                                        .read(
                                                            arrangementProvider
                                                                .notifier)
                                                        .setArrangement(TextStatus(
                                                            currentuserNo: widget
                                                                .currentUserNo,
                                                            phoneNumberVariants:
                                                                phoneNumberVariants));
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
                                  barrierColor: AppConstants.primaryColor
                                      .withOpacity(0.1),
                                  child: GestureDetector(
                                    child: SizedBox(
                                      width: 90,
                                      height: 140,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: <Widget>[
                                          (widget.user != null)
                                              ? customCircleAvatarStatus(
                                                  profilePic: widget
                                                      .user!.profilePicture)
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: AppConstants
                                                        .primaryColor,
                                                    strokeWidth: 2,
                                                  ),
                                                ),
                                          Positioned(
                                              bottom: 0,
                                              child: Container(
                                                height: 70,
                                                width: 90,
                                                decoration: BoxDecoration(
                                                  color: Teme.isDarktheme(prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                        AppConstants
                                                                .defaultNumericValue *
                                                            .9),
                                                    bottomRight: Radius
                                                        .circular(AppConstants
                                                                .defaultNumericValue *
                                                            .9),
                                                  ),
                                                ),
                                              )),
                                          CircleAvatar(
                                            backgroundColor:
                                                Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                            child: const Icon(
                                              Icons.add_circle_rounded,
                                              color: AppConstants.primaryColor,
                                              size: 40,
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 15,
                                              child: Center(
                                                  child: Text(
                                                LocaleKeys.createStory.tr(),
                                                textAlign: TextAlign.center,
                                              )))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                      }
                      return const SizedBox();
                    }),
                const SizedBox(
                  width: AppConstants.defaultNumericValue / 2,
                ),
                Expanded(
                    child: Container(
                        height: 140,
                        color: Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: statusProvider.contactsStatus.length,
                          itemBuilder: (context, idx) {
                            int seen = !statusProvider.contactsStatus[idx]
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
                                    .contains(status[Dbkeys.statusItemID])) {
                                  seen = seen + 1;
                                }
                              });
                            }
                            return FutureBuilder<LocalUserData?>(
                                future: widget.contactsProvider!
                                    .fetchUserDataFromnLocalOrServer(
                                        widget.prefs,
                                        statusProvider.contactsStatus[idx]
                                                .data()[
                                            Dbkeys.statusPUBLISHERPHONE]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<LocalUserData?> snapshot) {
                                  if (snapshot.hasData) {
                                    return InkWell(
                                        onTap: () {
                                          // print(statusProvider
                                          //     .contactsStatus[idx]
                                          //     .toString());
                                          !(Responsive.isDesktop(context))
                                              ? Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          StatusView(
                                                            model:
                                                                _cachedModel!,
                                                            prefs: widget.prefs,
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
                                                                  .then((doc) {
                                                                if (doc.docs
                                                                    .isNotEmpty) {
                                                                  int i = statusProvider
                                                                      .contactsStatus
                                                                      .indexWhere((element) =>
                                                                          element
                                                                              .data()[Dbkeys.statusPUBLISHERPHONE] ==
                                                                          statuspublisherphone);

                                                                  if (i >= 0) {
                                                                    statusProvider.replaceStatus(
                                                                        i,
                                                                        doc.docs
                                                                            .first);
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
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                                    () {
                                                                  _showInterstitialAd();
                                                                });
                                                              }
                                                            },
                                                            currentUserNo: widget
                                                                .currentUserNo,
                                                            statusDoc:
                                                                statusProvider
                                                                        .contactsStatus[
                                                                    idx],
                                                            postedbyFullname:
                                                                snapshot
                                                                    .data!.name,
                                                            postedbyPhotourl:
                                                                snapshot.data!
                                                                    .photoURL,
                                                          )))
                                              : ref
                                                  .read(arrangementProvider
                                                      .notifier)
                                                  .setArrangement(StatusView(
                                                    model: _cachedModel!,
                                                    prefs: widget.prefs,
                                                    callback:
                                                        (statuspublisherphone) {
                                                      FirebaseFirestore.instance
                                                          .collection(DbPaths
                                                              .collectionnstatus)
                                                          .where(
                                                              Dbkeys
                                                                  .statusPUBLISHERPHONE,
                                                              isEqualTo:
                                                                  statuspublisherphone)
                                                          .get()
                                                          .then((doc) {
                                                        if (doc
                                                            .docs.isNotEmpty) {
                                                          int i = statusProvider
                                                              .contactsStatus
                                                              .indexWhere((element) =>
                                                                  element.data()[
                                                                      Dbkeys
                                                                          .statusPUBLISHERPHONE] ==
                                                                  statuspublisherphone);

                                                          if (i >= 0) {
                                                            statusProvider
                                                                .replaceStatus(
                                                                    i,
                                                                    doc.docs
                                                                        .first);
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
                                                            const Duration(
                                                                milliseconds:
                                                                    500), () {
                                                          _showInterstitialAd();
                                                        });
                                                      }
                                                    },
                                                    currentUserNo:
                                                        widget.currentUserNo,
                                                    statusDoc: statusProvider
                                                        .contactsStatus[idx],
                                                    postedbyFullname:
                                                        snapshot.data!.name,
                                                    postedbyPhotourl:
                                                        snapshot.data!.photoURL,
                                                  ));
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppConstants
                                                                      .defaultNumericValue *
                                                                  1.2),
                                                      border: Border.all(
                                                          color: statusProvider.contactsStatus[idx]
                                                                  .data()
                                                                  .containsKey(widget
                                                                      .currentUserNo)
                                                              ? statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length >
                                                                      0
                                                                  ? Colors.grey
                                                                      .withOpacity(
                                                                          0.8)
                                                                  : AppConstants
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          .8)
                                                              : AppConstants
                                                                  .primaryColor
                                                                  .withOpacity(.8),
                                                          width: 3)),

                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child:
                                                        statusProvider.contactsStatus[idx]
                                                                        [Dbkeys.statusITEMSLIST]
                                                                    [
                                                                    statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                        1][Dbkeys
                                                                    .statusItemTYPE] ==
                                                                Dbkeys
                                                                    .statustypeTEXT
                                                            ? Container(
                                                                width: 90.0,
                                                                height: 140.0,
                                                                decoration: BoxDecoration(
                                                                    color: Color(int.parse(
                                                                        statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            [
                                                                            statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                                1][Dbkeys
                                                                            .statusItemBGCOLOR],
                                                                        radix:
                                                                            16)),
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                child: const Icon(
                                                                    Icons
                                                                        .text_fields,
                                                                    color: Colors
                                                                        .white54),
                                                              )
                                                            : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            [statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1]
                                                                        [Dbkeys.statusItemTYPE] ==
                                                                    Dbkeys.statustypeVIDEO
                                                                ? Container(
                                                                    width: 90.0,
                                                                    height:
                                                                        140.0,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                          image:
                                                                              CachedNetworkImageProvider(
                                                                            statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                                1]['thumbNail'],
                                                                          ),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        color: AppConstants.primaryColor.withOpacity(.2),
                                                                        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .play_circle_fill_rounded,
                                                                        color: Colors
                                                                            .white54),
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl: statusProvider
                                                                            .contactsStatus[idx]
                                                                        [
                                                                        Dbkeys.statusITEMSLIST][statusProvider
                                                                            .contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            .length -
                                                                        1][Dbkeys.statusItemURL],
                                                                    imageBuilder:
                                                                        (context,
                                                                                imageProvider) =>
                                                                            Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                        image: DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover),
                                                                      ),
                                                                    ),
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                        color: Colors
                                                                            .grey[300],
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                        color: Colors
                                                                            .grey[300],
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
                                                            snapshot.data!.name,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
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
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: AppConstants
                                                                    .primaryColor,
                                                                width: 2)),
                                                        child: CircleAvatar(
                                                          radius: 15,
                                                          backgroundImage:
                                                              CachedNetworkImageProvider(
                                                            snapshot
                                                                .data!.photoURL,
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
                                      !(Responsive.isDesktop(context))
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      StatusView(
                                                        model: _cachedModel!,
                                                        prefs: widget.prefs,
                                                        callback:
                                                            (statuspublisherphone) {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionnstatus)
                                                              .where(
                                                                  Dbkeys
                                                                      .statusPUBLISHERPHONE,
                                                                  isEqualTo:
                                                                      statuspublisherphone)
                                                              .get()
                                                              .then((doc) {
                                                            if (doc.docs
                                                                .isNotEmpty) {
                                                              int i = statusProvider
                                                                  .contactsStatus
                                                                  .indexWhere((element) =>
                                                                      element[Dbkeys
                                                                          .statusPUBLISHERPHONE] ==
                                                                      statuspublisherphone);
                                                              statusProvider
                                                                  .replaceStatus(
                                                                      i,
                                                                      doc.docs
                                                                          .first);
                                                              setState(() {});
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
                                                        currentUserNo: widget
                                                            .currentUserNo,
                                                        statusDoc: statusProvider
                                                                .contactsStatus[
                                                            idx],
                                                        postedbyFullname: statusProvider
                                                            .joinedUserPhoneStringAsInServer
                                                            .elementAt(statusProvider
                                                                .joinedUserPhoneStringAsInServer
                                                                .toList()
                                                                .indexWhere((element) => statusProvider
                                                                    .contactsStatus[
                                                                        idx][
                                                                        Dbkeys
                                                                            .statusPUBLISHERPHONEVARIANTS]
                                                                    .contains(element
                                                                        .phone
                                                                        .toString())))
                                                            .name
                                                            .toString(),
                                                        postedbyPhotourl: null,
                                                      )))
                                          : ref
                                              .read(
                                                  arrangementProvider.notifier)
                                              .setArrangement(StatusView(
                                                model: _cachedModel!,
                                                prefs: widget.prefs,
                                                callback:
                                                    (statuspublisherphone) {
                                                  FirebaseFirestore.instance
                                                      .collection(DbPaths
                                                          .collectionnstatus)
                                                      .where(
                                                          Dbkeys
                                                              .statusPUBLISHERPHONE,
                                                          isEqualTo:
                                                              statuspublisherphone)
                                                      .get()
                                                      .then((doc) {
                                                    if (doc.docs.isNotEmpty) {
                                                      int i = statusProvider
                                                          .contactsStatus
                                                          .indexWhere((element) =>
                                                              element[Dbkeys
                                                                  .statusPUBLISHERPHONE] ==
                                                              statuspublisherphone);
                                                      statusProvider
                                                          .replaceStatus(i,
                                                              doc.docs.first);
                                                      setState(() {});
                                                    }
                                                  });
                                                  if (IsInterstitialAdShow ==
                                                          true &&
                                                      observer.isadmobshow ==
                                                          true &&
                                                      !kIsWeb) {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      _showInterstitialAd();
                                                    });
                                                  }
                                                },
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                statusDoc: statusProvider
                                                    .contactsStatus[idx],
                                                postedbyFullname: statusProvider
                                                    .joinedUserPhoneStringAsInServer
                                                    .elementAt(statusProvider
                                                        .joinedUserPhoneStringAsInServer
                                                        .toList()
                                                        .indexWhere((element) =>
                                                            statusProvider
                                                                .contactsStatus[
                                                                    idx][Dbkeys
                                                                        .statusPUBLISHERPHONEVARIANTS]
                                                                .contains(element
                                                                    .phone
                                                                    .toString())))
                                                    .name
                                                    .toString(),
                                                postedbyPhotourl: null,
                                              ));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          AppConstants.defaultNumericValue,
                                          0,
                                          0,
                                          0),
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
                                                !(Responsive.isDesktop(context))
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    StatusView(
                                                                      model:
                                                                          _cachedModel!,
                                                                      prefs: widget
                                                                          .prefs,
                                                                      callback:
                                                                          (statuspublisherphone) {
                                                                        FirebaseFirestore
                                                                            .instance
                                                                            .collection(DbPaths
                                                                                .collectionnstatus)
                                                                            .where(Dbkeys.statusPUBLISHERPHONE,
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
                                                                              statusProvider.replaceStatus(i, doc.docs.first);
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
                                                                      postedbyFullname: snapshot
                                                                          .data!
                                                                          .name,
                                                                      postedbyPhotourl: snapshot
                                                                          .data!
                                                                          .photoURL,
                                                                    )))
                                                    : ref
                                                        .read(
                                                            arrangementProvider
                                                                .notifier)
                                                        .setArrangement(
                                                            StatusView(
                                                          model: _cachedModel!,
                                                          prefs: widget.prefs,
                                                          callback:
                                                              (statuspublisherphone) {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionnstatus)
                                                                .where(
                                                                    Dbkeys
                                                                        .statusPUBLISHERPHONE,
                                                                    isEqualTo:
                                                                        statuspublisherphone)
                                                                .get()
                                                                .then((doc) {
                                                              if (doc.docs
                                                                  .isNotEmpty) {
                                                                int i = statusProvider
                                                                    .contactsStatus
                                                                    .indexWhere((element) =>
                                                                        element.data()[
                                                                            Dbkeys.statusPUBLISHERPHONE] ==
                                                                        statuspublisherphone);

                                                                if (i >= 0) {
                                                                  statusProvider
                                                                      .replaceStatus(
                                                                          i,
                                                                          doc.docs
                                                                              .first);
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
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  () {
                                                                _showInterstitialAd();
                                                              });
                                                            }
                                                          },
                                                          currentUserNo: widget
                                                              .currentUserNo,
                                                          statusDoc: statusProvider
                                                                  .contactsStatus[
                                                              idx],
                                                          postedbyFullname:
                                                              snapshot
                                                                  .data!.name,
                                                          postedbyPhotourl:
                                                              snapshot.data!
                                                                  .photoURL,
                                                        ));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10, bottom: 10),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppConstants.defaultNumericValue *
                                                                  1.2),
                                                      border: Border.all(
                                                          width: 3,
                                                          color: statusProvider
                                                                      .contactsStatus[idx][
                                                                          Dbkeys
                                                                              .statusITEMSLIST]
                                                                      .length ==
                                                                  seen
                                                              ? Colors.grey
                                                                  .withOpacity(
                                                                      0.8)
                                                              : AppConstants
                                                                  .primaryColor
                                                                  .withOpacity(0.8))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child:
                                                        statusProvider.contactsStatus[idx]
                                                                        [Dbkeys.statusITEMSLIST]
                                                                    [
                                                                    statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                        1][Dbkeys
                                                                    .statusItemTYPE] ==
                                                                Dbkeys
                                                                    .statustypeTEXT
                                                            ? Container(
                                                                width: 90.0,
                                                                height: 140.0,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color(int.parse(
                                                                      statusProvider
                                                                              .contactsStatus[idx]
                                                                          [
                                                                          Dbkeys.statusITEMSLIST][statusProvider
                                                                              .contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                              .length -
                                                                          1][Dbkeys.statusItemBGCOLOR],
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
                                                            : statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            [statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length - 1]
                                                                        [Dbkeys.statusItemTYPE] ==
                                                                    Dbkeys.statustypeVIDEO
                                                                ? Container(
                                                                    width: 90.0,
                                                                    height:
                                                                        140.0,
                                                                    decoration: BoxDecoration(
                                                                        image: DecorationImage(
                                                                          image:
                                                                              CachedNetworkImageProvider(
                                                                            statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST][statusProvider.contactsStatus[idx][Dbkeys.statusITEMSLIST].length -
                                                                                1]['thumbNail'],
                                                                          ),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                        color: AppConstants.primaryColor.withOpacity(.2),
                                                                        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .play_circle_fill_rounded,
                                                                        color: Colors
                                                                            .white54),
                                                                  )
                                                                : CachedNetworkImage(
                                                                    imageUrl: statusProvider
                                                                            .contactsStatus[idx]
                                                                        [
                                                                        Dbkeys.statusITEMSLIST][statusProvider
                                                                            .contactsStatus[idx][Dbkeys.statusITEMSLIST]
                                                                            .length -
                                                                        1][Dbkeys.statusItemURL],
                                                                    imageBuilder:
                                                                        (context,
                                                                                imageProvider) =>
                                                                            Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        image: DecorationImage(
                                                                            image:
                                                                                imageProvider,
                                                                            fit:
                                                                                BoxFit.cover),
                                                                      ),
                                                                    ),
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[300],
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Container(
                                                                      width:
                                                                          90.0,
                                                                      height:
                                                                          140.0,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .grey[300],
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
                                                          .indexWhere((element) =>
                                                              statusProvider
                                                                  .contactsStatus[
                                                                      idx][
                                                                      Dbkeys
                                                                          .statusPUBLISHERPHONEVARIANTS]
                                                                  .contains(element
                                                                      .phone)))
                                                      .name
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
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
            ),
            Container(
              color: !Teme.isDarktheme(prefs)
                  ? Colors.grey.withOpacity(.2)
                  : Colors.black,
              height: 7,
              width: width,
            ),
            ...feedList.when(
                data: (data) {
                  final otherUsers = ref.watch(otherUsersProvider(ref));
                  final userProfileProvider =
                      ref.watch(userProfileFutureProvider);

                  List<UserProfileModel> feedsUsers = [];
                  UserProfileModel? currentUser;

                  userProfileProvider.whenData((value) {
                    feedsUsers.add(value!);
                    currentUser = value;
                  });

                  otherUsers.whenData((value) {
                    final users = value.where((element) {
                      return data
                          .map((e) => e.phoneNumber)
                          .toList()
                          .contains(element.phoneNumber);
                    }).toList();
                    feedsUsers.addAll(users);
                  });

                  return data.isEmpty
                      ? (cachedFeedsList.isEmpty)
                          ? [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.2),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1),
                            ]
                          : cachedFeedsList.map((e) {
                              final user = cachedUSersList.firstWhere(
                                  (element) =>
                                      element.phoneNumber == e.phoneNumber);
                              return SingleFeedPost(
                                currentIndex: currentIndex,
                                cachedFeedsListSize: cachedFeedsList.length,
                                observer: observer,
                                adWidget: adWidget,
                                prefs: widget.prefs,
                                feed: e,
                                user: user,
                                currentUser: currentUser!,
                              );
                            })
                      : data.map((e) {
                          currentIndex++;
                          final user = feedsUsers.firstWhere((element) =>
                              element.phoneNumber == e.phoneNumber);

                          return SingleFeedPost(
                            currentIndex: currentIndex,
                            cachedFeedsListSize: data.length,
                            observer: observer,
                            adWidget: adWidget,
                            prefs: widget.prefs,
                            feed: e,
                            user: user,
                            currentUser: currentUser!,
                          );
                        });
                },
                error: (e, stack) => [
                      Text("${e.toString()}\n${stack.toString()}"),
                      SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child: const ErrorPage())
                    ],
                loading: () => [const SizedBox()]),
            SizedBox(
              height: MediaQuery.of(context).size.height * .1,
            )
          ],
        )),
      ],
    );
  }
}

class UserPicture extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  const UserPicture({
    super.key,
    required this.imageUrl,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final newSize = size ?? AppConstants.defaultNumericValue * 5;
    return Container(
      width: newSize,
      height: newSize,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultNumericValue * 0),
        border: Border.all(color: AppConstants.primaryColor, width: 2),
      ),
      child: ClipRRect(
        child: imageUrl == null || imageUrl!.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(
                  CupertinoIcons.person_fill,
                  color: AppConstants.primaryColor,
                  size: newSize * 0.8,
                ),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

// class HomePageNoUsersFoundWidget extends ConsumerWidget {
//   final SharedPreferences prefs;
//   final String currentUserNo;
//   const HomePageNoUsersFoundWidget({
//     required this.prefs,
//     required this.currentUserNo,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final interactions = ref.watch(interactionFutureProvider);
//     final closestUsers = ref.watch(closestUsersProvider);
//     // final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//     bool biometricEnabled = false;
//     DataModel _cachedModel = DataModel(prefs.getString(Dbkeys.phone));

//     return interactions.when(
//       data: (data) {
//         final users = closestUsers
//             .where((element) => !data.any((interaction) =>
//                 interaction.intractToUserId == element.user.phoneNumber))
//             .toList();

//         users.sort((a, b) => a.distance.compareTo(b.distance));

//         return Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: AppConstants.defaultNumericValue * 2),
//             child: users.isEmpty
//                 ? NoItemFoundWidget(
//                     prefs: prefs, text: LocaleKeys.nousersfound.tr())
//                 : AccountSettingsLandingWidget(
//                     builder: (data) {
//                       return ChangeRadiusFromHomePageWidget(
//                         prefs: prefs,
//                         closestUsersDistanceInKM: users.first.distance / 1000,
//                         user: data,
//                       );
//                     },
//                     currentUserNo: currentUserNo,
//                   ),
//           ),
//         );
//       },
//       error: (_, __) => const SizedBox(),
//       loading: () => const Center(
//         child: CircularProgressIndicator.adaptive(),
//       ),
//     );
//   }
// }

class ChangeRadiusFromHomePageWidget extends ConsumerStatefulWidget {
  final double closestUsersDistanceInKM;
  final UserProfileModel user;
  final SharedPreferences prefs;
  const ChangeRadiusFromHomePageWidget({
    super.key,
    required this.closestUsersDistanceInKM,
    required this.user,
    required this.prefs,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeRadiusFromHomePageWidgetState();
}

class _ChangeRadiusFromHomePageWidgetState
    extends ConsumerState<ChangeRadiusFromHomePageWidget> {
  late double _distanceInKm;
  late bool _isWorldWide;
  late double _maxDistanceInKm;

  @override
  void initState() {
    _distanceInKm = widget.user.userAccountSettingsModel.distanceInKm ??
        AppConfig.initialMaximumDistanceInKM;
    _isWorldWide = widget.user.userAccountSettingsModel.distanceInKm == null;
    _maxDistanceInKm = AppConfig.initialMaximumDistanceInKM;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NoItemFoundWidget(
              prefs: widget.prefs,
              text: LocaleKeys.nousersfound.tr(),
              isSmall: true),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: LocaleKeys.butyoucanchangeyourradius.tr(),
                ),
                TextSpan(
                  text: widget.closestUsersDistanceInKM.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(text: LocaleKeys.kmsAway.tr()),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.radius.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!_isWorldWide)
                  Text(
                    '${_distanceInKm.toInt()} km',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor),
                  ),
              ],
            ),
          ),
          if (_isWorldWide)
            const SizedBox(height: AppConstants.defaultNumericValue / 2),
          if (!_isWorldWide)
            Slider(
              value: _distanceInKm,
              min: 1,
              max: _maxDistanceInKm,
              onChanged: (value) {
                setState(() {
                  _distanceInKm = value;
                });
              },
            ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue),
            ),
            borderOnForeground: true,
            child: CheckboxListTile(
              value: _isWorldWide,
              controlAffinity: ListTileControlAffinity.leading,
              onChanged: (value) {
                setState(() {
                  _isWorldWide = value!;
                  _distanceInKm = value
                      ? AppConfig.initialMaximumDistanceInKM
                      : widget.user.userAccountSettingsModel.distanceInKm ??
                          AppConfig.initialMaximumDistanceInKM;
                });
              },
              title: Text(
                LocaleKeys.anywhere.tr(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          CustomButton(
            onPressed: () async {
              final UserAccountSettingsModel newSettingsModel =
                  widget.user.userAccountSettingsModel.copyWith(
                distanceInKm:
                    _isWorldWide ? null : _distanceInKm.toInt().toDouble(),
              );

              final userProfileModel = widget.user
                  .copyWith(userAccountSettingsModel: newSettingsModel);

              EasyLoading.show(status: LocaleKeys.updating.tr());

              await ref
                  .read(userProfileNotifier)
                  .updateUserProfile(userProfileModel)
                  .then((value) {
                ref.invalidate(userProfileFutureProvider);
                EasyLoading.dismiss();
              });
            },
            text: LocaleKeys.apply.tr(),
          ),
        ],
      ),
    );
  }
}

class CreateNewPostSection extends ConsumerWidget {
  const CreateNewPostSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final currentUserProfile = ref.watch(userProfileFutureProvider);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return currentUserProfile.when(
      data: (data) {
        return data == null
            ? const SizedBox()
            : Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top * 0,
                    bottom: 0,
                    left: 0,
                    right: 0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        !Responsive.isDesktop(context)
                            ? Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const FeedPostPage()),
                              )
                            : ref
                                .read(arrangementProviderExtend.notifier)
                                .setArrangement(const FeedPostPage());
                      },
                      child: Row(
                        children: [
                          UserCirlePicture(
                              imageUrl: data.profilePicture,
                              size: AppConstants.defaultNumericValue * 2.5),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                          Expanded(
                            child: Text(LocaleKeys.whatsonyourmind.tr(),
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                          WebsafeSvg.asset(
                            height: 30,
                            width: 30,
                            fit: BoxFit.fitHeight,
                            imgIcon,
                            colorFilter: const ColorFilter.mode(
                              // Colors.blueGrey,
                              AppConstants.primaryColor,
                              // AppConstants.secondaryColor,
                              // Colors.white,
                              // Colors.grey,
                              //  Colors.black,
                              BlendMode.srcIn,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultNumericValue),
                  ],
                ));
      },
      error: (_, __) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}

class SingleFeedPost extends ConsumerStatefulWidget {
  final FeedModel feed;
  final UserProfileModel user;
  final UserProfileModel currentUser;
  final SharedPreferences prefs;
  final int? currentIndex;
  final int? cachedFeedsListSize;
  final Observer? observer;
  final AdWidget? adWidget;
  const SingleFeedPost({
    super.key,
    required this.feed,
    required this.user,
    required this.currentUser,
    required this.prefs,
    this.currentIndex,
    this.cachedFeedsListSize,
    this.observer,
    this.adWidget,
  });

  @override
  ConsumerState<SingleFeedPost> createState() => _SingleFeedPostState();
}

class _SingleFeedPostState extends ConsumerState<SingleFeedPost> {
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();
  bool isGiftDialogOpen = false;
  bool isPurchaseDialogOpen = false;
  FirebaseFirestore db = FirebaseFirestore.instance;

  void _onTapSendMessage() async {
    _moreMenuController.hideMenu();
    // final prefs = ref.watch(sharedPreferences).value;
    DataModel? _cachedModel;
    _cachedModel ??= DataModel(widget.currentUser.phoneNumber);
    final MatchModel matchModel = MatchModel(
      id: widget.currentUser.phoneNumber + widget.user.phoneNumber,
      userIds: [widget.currentUser.phoneNumber, widget.user.phoneNumber],
      isMatched: false,
    );

    await createConversation(matchModel).then((matchResult) async {
      if (matchResult) {
        EasyLoading.dismiss();
        !Responsive.isDesktop(context)
            ? Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PreChat(
                    name: widget.user.fullName,
                    phone: widget.user.phoneNumber,
                    currentUserNo:
                        ref.watch(currentUserStateProvider)!.phoneNumber,
                    model: _cachedModel,
                    prefs: widget.prefs,
                  ),
                ),
              )
            : {
                updateCurrentIndex(ref, 10),
                // ref
                //     .read(arrangementProvider.notifier)
                //     .setArrangement(UserDetailsPage(
                //       user: widget.user,
                //     )),
                ref
                    .read(arrangementProviderExtend.notifier)
                    .setArrangement(PreChat(
                      name: widget.user.fullName,
                      phone: widget.user.phoneNumber,
                      currentUserNo:
                          ref.watch(currentUserStateProvider)!.phoneNumber,
                      model: _cachedModel,
                      prefs: widget.prefs,
                    ))
              };
      } else {
        EasyLoading.showInfo(LocaleKeys.somethingWentWrong.tr());
      }
    });
  }

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

  Future<void> onCommentSend(
      {required String commentType, required String msg}) async {
    await db
        .collection(FirebaseConstants.feedsCollection)
        .doc(widget.feed.id)
        .collection(FirebaseConst.comment)
        .add(FeedComment(
                id: widget.user.phoneNumber +
                    DateTime.now().millisecondsSinceEpoch.toString(),
                userName: widget.currentUser.userName,
                userImage: widget.currentUser.profilePicture ?? '',
                phoneNumber: widget.currentUser.phoneNumber,
                fullName: widget.currentUser.fullName,
                comment: msg,
                commentType: commentType,
                isVerify: widget.currentUser.isVerified)
            .toJson());
  }

  void createInteractionNotification(
      {required String title,
      required String body,
      required String image,
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
      image: image,
      createdAt: currentTime,
      isRead: false,
      isMatchingNotification: false,
      isInteractionNotification: true,
    );

    await addNotification(notificationModel);
  }

  void shareLink(FeedModel feed) async {
    final canonicalIdentifier = const Uuid().v4();
    BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'lamat/branch_$canonicalIdentifier',
        title: feed.caption ?? "${widget.user.userName}'s Lamat Feed",
        imageUrl: widget.user.profilePicture ??
            "https://play-lh.googleusercontent.com/ZgFIUKzhGURlAMar1drZJlCWlh8JfeEy5Lmkuag0q-ZsPWwdeCV8rOAeEMQ23CvgdQ=w240-h480-rw",
        contentDescription:
            feed.caption ?? "${widget.user.userName}'s Lamat Feed",
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata("feed_id", feed.id));
    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: [widget.user.userName, feed.caption!, Appname])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('referring_user_id', widget.user.userName)
      ..addControlParam('\$fallback_url', 'https://lamatt.web.app')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.appfliiq.jolii&pli=1');
    final response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp)
            .catchError((error) {
      Share.share(
        AppRes.checkOutThisAmazingProfile("https://lamatt.app.link"),
        subject: "${AppRes.look} at @${widget.user.userName}'s Post",
      );
      if (kDebugMode) {
        print('Error : - ${error.toString()}');
      }
      return error;
    });
    if (response.success) {
      Share.share(
        AppRes.checkOutThisAmazingProfile(response.result),
        subject: "${AppRes.look} at @${widget.user.userName}'s Post",
      );
    } else {
      if (kDebugMode) {
        print('Error : ${response.errorCode} - ${response.errorMessage}');
      }
    }
  }

  void initDeepLinkData() {
    String dateString =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    metadata = BranchContentMetaData()
      ..addCustomMetadata(
          'custom_string', widget.feed.caption ?? '$Appname - $dateString')
      ..addCustomMetadata('user_id', widget.user.phoneNumber)
      ..addCustomMetadata("username", widget.user.userName)
      ..addCustomMetadata('feed_id', widget.feed.id)
      ..addCustomMetadata('feed_date_created', widget.feed.createdAt.toString())
      ..addCustomMetadata('custom_date_created', dateString);
    //--optional Custom Metadata
    /*
      ..contentSchema = BranchContentSchema.COMMERCE_PRODUCT
      ..price = 50.99
      ..currencyType = BranchCurrencyType.BRL
      ..quantity = 50
      ..sku = 'sku'
      ..productName = 'productName'
      ..productBrand = 'productBrand'
      ..productCategory = BranchProductCategory.ELECTRONICS
      ..productVariant = 'productVariant'
      ..condition = BranchCondition.NEW
      ..rating = 100
      ..ratingAverage = 50
      ..ratingMax = 100
      ..ratingCount = 2
      ..setAddress(
          street: 'street',
          city: 'city',
          region: 'ES',
          country: 'Brazil',
          postalCode: '99999-987')
      ..setLocation(31.4521685, -114.7352207);
      */

    final canonicalIdentifier = const Uuid().v4();
    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch_$canonicalIdentifier',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        //canonicalUrl: 'https://flutter.dev',
        title: widget.feed.caption ?? '$Appname - $dateString',
        imageUrl: widget.feed.images.first.isNotEmpty
            ? widget.feed.images.first
            : "https://play-lh.googleusercontent.com/ZgFIUKzhGURlAMar1drZJlCWlh8JfeEy5Lmkuag0q-ZsPWwdeCV8rOAeEMQ23CvgdQ=w240-h480-rw",
        contentDescription: widget.feed.caption ?? '$Appname - $dateString',
        contentMetadata: metadata,
        keywords: ['Lamat', 'Share', 'Teel'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now()
            .add(const Duration(days: 365))
            .millisecondsSinceEpoch);
    lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: [widget.user.userName, widget.feed.caption ?? "", Appname])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('referring_user_id', widget.user.userName)
      ..addControlParam('\$fallback_url', 'https://lamatt.web.app')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.appfliiq.jolii&pli=1');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      ..adType = BranchEventAdType.BANNER;

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..alias = widget.user.userName;
  }

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;

  @override
  Widget build(BuildContext context) {
    // final prefs = ref.watch(sharedPreferences).value;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final appSettingsRef = ref.watch(appSettingsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      // padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      (widget.feed.phoneNumber ==
                              widget.currentUser.phoneNumber)
                          ? !Responsive.isDesktop(context)
                              ? await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProfileNested(
                                      isHome: true,
                                      prefs: widget.prefs,
                                    ),
                                  ),
                                )
                              : ref
                                  .watch(arrangementProvider.notifier)
                                  .setArrangement(ProfileNested(
                                    prefs: widget.prefs,
                                    isHome: true,
                                  ))
                          : !Responsive.isDesktop(context)
                              ? await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => UserDetailsPage(
                                      user: widget.user,
                                    ),
                                  ),
                                )
                              : ref
                                  .watch(arrangementProvider.notifier)
                                  .setArrangement(UserDetailsPage(
                                    user: widget.user,
                                  ));
                    },
                    child: UserCirlePicture(
                        imageUrl: widget.user.profilePicture,
                        size: AppConstants.defaultNumericValue * 2.5),
                  ),
                  // UserCirlePicture(
                  //     imageUrl: widget.user.profilePicture,
                  //     size: AppConstants.defaultNumericValue * 2.5),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      (widget.feed.phoneNumber ==
                              widget.currentUser.phoneNumber)
                          ? (!Responsive.isDesktop(context))
                              ? await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ProfileNested(
                                      prefs: widget.prefs,
                                      isHome: true,
                                    ),
                                  ),
                                )
                              : ref
                                  .watch(arrangementProvider.notifier)
                                  .setArrangement(ProfileNested(
                                    prefs: widget.prefs,
                                    isHome: true,
                                  ))
                          : !Responsive.isDesktop(context)
                              ? await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => UserDetailsPage(
                                      user: widget.user,
                                    ),
                                  ),
                                )
                              : ref
                                  .watch(arrangementProvider.notifier)
                                  .setArrangement(UserDetailsPage(
                                    user: widget.user,
                                  ));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.fullName,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          DateFormatter.toWholeDateTime(widget.feed.createdAt),
                          textAlign: TextAlign.end,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  (widget.feed.phoneNumber == widget.currentUser.phoneNumber)
                      ? CustomPopupMenu(
                          menuBuilder: () => ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue / 2),
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    MoreMenuTitle(
                                      title: LocaleKeys.edit.tr(),
                                      onTap: () async {
                                        _moreMenuController.hideMenu();
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  EditFeedPage(
                                                      feed: widget.feed)),
                                        );
                                      },
                                    ),
                                    MoreMenuTitle(
                                      title: LocaleKeys.delete.tr(),
                                      onTap: () {
                                        _moreMenuController.hideMenu();

                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  LocaleKeys.deleteFeed.tr(),
                                                ),
                                                content: Text(LocaleKeys
                                                    .areyousureyouwanttodeletethisfeed
                                                    .tr()),
                                                actions: [
                                                  TextButton(
                                                    child: Text(
                                                        LocaleKeys.cancel.tr()),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  Consumer(
                                                    builder:
                                                        (context, ref, child) {
                                                      return TextButton(
                                                        child: Text(LocaleKeys
                                                            .delete
                                                            .tr()),
                                                        onPressed: () async {
                                                          await deleteFeed(
                                                                  widget
                                                                      .feed.id)
                                                              .then((value) {
                                                            ref.invalidate(
                                                                getFeedsProvider);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                      );
                                                    },
                                                  )
                                                ],
                                              );
                                            });
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
                          barrierColor:
                              AppConstants.primaryColor.withOpacity(0.1),
                          child: GestureDetector(
                            child: const Icon(CupertinoIcons.ellipsis_vertical),
                          ),
                        )
                      : CustomPopupMenu(
                          menuBuilder: () => ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue / 2),
                            child: Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    widget.user.userAccountSettingsModel
                                                .allowAnonymousMessages ==
                                            true
                                        ? appSettingsRef.when(
                                            data: (data) {
                                              if (data?.isChattingEnabledBeforeMatch ==
                                                  true) {
                                                return MoreMenuTitle(
                                                    title: LocaleKeys
                                                        .sendMessage
                                                        .tr(),
                                                    onTap: _onTapSendMessage);
                                              } else {
                                                return const SizedBox();
                                              }
                                            },
                                            error: (error, stackTrace) =>
                                                const SizedBox(),
                                            loading: () => const SizedBox(),
                                          )
                                        : const SizedBox(),
                                    MoreMenuTitle(
                                      title: LocaleKeys.report.tr(),
                                      onTap: () {
                                        _moreMenuController.hideMenu();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReportPage(
                                                userProfileModel: widget.user),
                                          ),
                                        );
                                      },
                                    ),
                                    MoreMenuTitle(
                                      title: LocaleKeys.block.tr(),
                                      onTap: () async {
                                        _moreMenuController.hideMenu();
                                        showBlockDialog(
                                            context,
                                            widget.user.phoneNumber,
                                            ref
                                                .watch(
                                                    currentUserStateProvider)!
                                                .phoneNumber!);
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
                          barrierColor:
                              AppConstants.primaryColor.withOpacity(0.1),
                          child: GestureDetector(
                            child: const Icon(CupertinoIcons.ellipsis_vertical),
                          ),
                        )
                ],
              )),
          const SizedBox(
            height: AppConstants.defaultNumericValue,
          ),
          if (widget.feed.caption != null)
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PostText(postText: widget.feed.caption!)),
          if (widget.feed.images.isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (widget.feed.images.isNotEmpty)
            GestureDetector(
              onTap: () {
                !Responsive.isDesktop(context)
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoViewPage(
                              images: widget.feed.images, prefs: widget.prefs),
                        ),
                      )
                    : ref
                        .read(arrangementProviderExtend.notifier)
                        .setArrangement(PhotoViewPage(
                            images: widget.feed.images, prefs: widget.prefs));
              },
              child: PostImages(post: widget.feed),
            ),
          if (widget.feed.images.isNotEmpty) const SizedBox(height: 10),
          if (widget.feed.images.isEmpty)
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),
          Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        // width: width / 2,
                        child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          // width: AppConstants.defaultNumericValue * 2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue / 2,
                              vertical: AppConstants.defaultNumericValue / 3),
                          decoration: BoxDecoration(
                              color: Teme.isDarktheme(widget.prefs)
                                  ? Colors.white.withOpacity(.1)
                                  : Colors.black.withOpacity(.1),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(13),
                              )),
                          child: StreamBuilder<bool>(
                            stream: isLiked(
                                widget.feed.id,
                                ref
                                    .watch(currentUserStateProvider)!
                                    .phoneNumber!),
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    WebsafeSvg.asset(
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.fitHeight,
                                              snapshot.data == true
                                                  ? likeIcon
                                                  : emptyLikeIcon,
                                              colorFilter: ColorFilter.mode(
                                                // Colors.blueGrey,
                                                snapshot.data == true
                                                    ? Colors.red
                                                    : !Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? Colors.black
                                                        : Colors.white,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const SizedBox(
                                            width: AppConstants
                                                    .defaultNumericValue /
                                                4),
                                                const Text(
                                                  "0",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))
                                  ],
                                );
                                       
                              } else {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return InkWell(
                                    onTap: () async {
                                      (snapshot.data == false)
                                          ? await FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionusers)
                                              .doc(
                                                widget.feed.phoneNumber,
                                              )
                                              .set({
                                              'myPostLikes':
                                                  FieldValue.increment(1)
                                            }, SetOptions(merge: true))
                                          : await FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionusers)
                                              .doc(
                                                widget.feed.phoneNumber,
                                              )
                                              .set({
                                              'myPostLikes':
                                                  FieldValue.increment(-1)
                                            }, SetOptions(merge: true));
                                      await likeFeed(
                                              widget.feed.id,
                                              ref
                                                  .watch(
                                                      currentUserStateProvider)!
                                                  .phoneNumber!)
                                          .then((value) async {
                                        createInteractionNotification(
                                            title: "Post Likes",
                                            body:
                                                "Your Post now has ${widget.feed.likes.length + 1} likes",
                                            image: widget.feed.images.first,
                                            receiverId: widget.feed.phoneNumber,
                                            currentUser: widget.currentUser);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        WebsafeSvg.asset(
                                          height: 30,
                                          width: 30,
                                          fit: BoxFit.fitHeight,
                                          snapshot.data == true
                                              ? likeIcon
                                              : emptyLikeIcon,
                                          colorFilter: ColorFilter.mode(
                                            // Colors.blueGrey,
                                            snapshot.data == true
                                                ? Colors.red
                                                : !Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? Colors.black
                                                    : Colors.white,
                                            // AppConstants.secondaryColor,
                                            // Colors.white,
                                            // Colors.grey,
                                            //  Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: AppConstants
                                                    .defaultNumericValue /
                                                4),
                                        StreamBuilder<int>(
                                          stream: getTotalLikes(widget.feed.id),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<int> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Text(
                                                  "0",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                            } else if (snapshot.hasError) {
                                              return const Text(
                                                  '0',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                            } else {
                                              return Text(
                                                  snapshot.data.toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.defaultNumericValue),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue / 2,
                              vertical: AppConstants.defaultNumericValue / 3),
                          decoration: BoxDecoration(
                              color: Teme.isDarktheme(widget.prefs)
                                  ? Colors.white.withOpacity(.1)
                                  : Colors.black.withOpacity(.1),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(13),
                              )),
                          child: InkWell(
                            onTap: () {
                              !(Responsive.isDesktop(context))
                                  ? showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                      ),
                                      backgroundColor:
                                          Teme.isDarktheme(widget.prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return AnimatedPadding(
                                          duration:
                                              const Duration(milliseconds: 150),
                                          curve: Curves.easeOut,
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: com.CommentScreen(null, () {
                                            setState(() {});
                                          }, widget.feed),
                                        );
                                      },
                                    )
                                  : ref
                                      .read(arrangementProvider.notifier)
                                      .setArrangement(AnimatedPadding(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        curve: Curves.easeOut,
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: com.CommentScreen(null, () {
                                          createInteractionNotification(
                                              title: "New Comment",
                                              body:
                                                  "Your Post has a new comment",
                                              image: widget.feed.images.first,
                                              receiverId:
                                                  widget.feed.phoneNumber,
                                              currentUser: widget.currentUser);
                                          setState(() {});
                                        }, widget.feed),
                                      ));
                              // showAddCommentBottomSheet(context, widget.feed,
                              //     ref, widget.currentUser.phoneNumber);
                            },
                            child: Row(
                              children: [
                                WebsafeSvg.asset(
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.fitHeight,
                                  commentIcon,
                                  colorFilter: ColorFilter.mode(
                                    !Teme.isDarktheme(widget.prefs)
                                        ? Colors.black
                                        : Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(
                                  width: AppConstants.defaultNumericValue / 4,
                                ),
                                StreamBuilder<int>(
                                  stream: commentsCountStream(widget.feed.id),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("0");
                                    } else if (snapshot.hasError) {
                                      return const Text("0");
                                    } else {
                                      return InkWell(
                                          onTap: () {
                                            !(Responsive.isDesktop(context))
                                                ? showModalBottomSheet(
                                                    context: context,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(15),
                                                      ),
                                                    ),
                                                    backgroundColor: Teme
                                                            .isDarktheme(
                                                                widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      return AnimatedPadding(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    150),
                                                        curve: Curves.easeOut,
                                                        padding: EdgeInsets.only(
                                                            bottom:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                        child:
                                                            com.CommentScreen(
                                                                null, () {
                                                          setState(() {});
                                                        }, widget.feed),
                                                      );
                                                    },
                                                  )
                                                : ref
                                                    .read(arrangementProvider
                                                        .notifier)
                                                    .setArrangement(
                                                        AnimatedPadding(
                                                      duration: const Duration(
                                                          milliseconds: 150),
                                                      curve: Curves.easeOut,
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom),
                                                      child: com.CommentScreen(
                                                          null, () {
                                                        setState(() {});
                                                      }, widget.feed),
                                                    ));

                                            // showAddCommentBottomSheet(context, widget.feed, ref,
                                            //     widget.currentUser.phoneNumber);
                                          },
                                          child: Text(
                                              snapshot.data.toString(),
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold)));
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppConstants.defaultNumericValue,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue / 2,
                              vertical: AppConstants.defaultNumericValue / 3),
                          decoration: BoxDecoration(
                              color: Teme.isDarktheme(widget.prefs)
                                  ? Colors.white.withOpacity(.1)
                                  : Colors.black.withOpacity(.1),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(13),
                              )),
                          child: InkWell(
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                            onTap: () {
                              shareLink(widget.feed);
                            },
                            child: WebsafeSvg.asset(
                              shareIcon,
                              colorFilter: ColorFilter.mode(
                                !Teme.isDarktheme(widget.prefs)
                                    ? Colors.black
                                    : Colors.white,
                                BlendMode.srcIn,
                              ),
                              height: 30,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      ],
                    )),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultNumericValue / 2,
                            vertical: AppConstants.defaultNumericValue / 3),
                        decoration: BoxDecoration(
                            color: Teme.isDarktheme(widget.prefs)
                                ? Colors.white.withOpacity(.1)
                                : Colors.black.withOpacity(.1),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(13),
                            )),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    builder: (context) {
                                      return GiftSheet(
                                        onAddDymondsTap: onAddDymondsTap,
                                        onGiftSend: (gift) {
                                          EasyLoading.show(
                                              status:
                                                  LocaleKeys.sendinggift.tr());

                                          int value = gift!.coinPrice!;

                                          sendGiftProvider(
                                              giftCost: value,
                                              recipientId:
                                                  widget.user.phoneNumber);
                                          createInteractionNotification(
                                              title: "Received a GIFT!!",
                                              body:
                                                  "Your Post has a new gift \n ${gift.coinPrice} Coins",
                                              image: gift.image ??
                                                  widget.user.profilePicture ??
                                                  "",
                                              receiverId:
                                                  widget.feed.phoneNumber,
                                              currentUser: widget.currentUser);
                                          print("${gift.coinPrice}");

                                          // onCommentSend(
                                          //     commentType: FirebaseConst.image, msg: gift.image ?? '');
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            EasyLoading.dismiss();
                                          });
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                },
                                child: WebsafeSvg.asset(
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.fitHeight,
                                  giftIcon,
                                  colorFilter: ColorFilter.mode(
                                    !Teme.isDarktheme(widget.prefs)
                                        ? Colors.black
                                        : Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ])),
                  ])),
          const SizedBox(height: 10),
          Container(
            color: !Teme.isDarktheme(widget.prefs)
                ? Colors.grey.withOpacity(.2)
                : Colors.black,
            height: 7,
            width: width,
          ),
          const SizedBox(height: 10),
          if ((widget.currentIndex! % 5 == 0 && widget.currentIndex != 0) ||
              widget.cachedFeedsListSize! <= 1)
            !kIsWeb
                ? IsBannerAdShow == true &&
                        widget.observer!.isadmobshow == true &&
                        widget.adWidget != null &&
                        !kIsWeb
                    ? SizedBox(
                        // height: 70,
                        width: width,
                        
                        child: Center(
                          child: SubscriptionBuilder(
                            builder: (context, isPremiumUser) {
                              return (widget.user.isPremium ??
                                      false || isPremiumUser)
                                  ? const SizedBox()
                                  : !kIsWeb
                                      ? const MyBannerAd()
                                      : const SizedBox();
                            },
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      )
                : const SizedBox(
                    height: 0,
                  ),
                   const SizedBox(height: 10),
          Container(
            color: !Teme.isDarktheme(widget.prefs)
                ? Colors.grey.withOpacity(.2)
                : Colors.black,
            height: 7,
            width: width,
          ),
        ],
      ),
    );
  }
}

class PostText extends StatefulWidget {
  final String postText;
  const PostText({
    super.key,
    required this.postText,
  });

  @override
  State<PostText> createState() => _PostTextState();
}

class _PostTextState extends State<PostText> {
  int _maxLInes = 3;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _maxLInes = _maxLInes > 3 ? 3 : 99999;
        });
      },
      child: Text(
        widget.postText,
        textAlign: TextAlign.start,
        maxLines: _maxLInes,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16,
            ),
      ),
    );
  }
}

class PostImages extends StatefulWidget {
  final FeedModel post;

  const PostImages({
    super.key,
    required this.post,
  });

  @override
  _PostImagesState createState() => _PostImagesState();
}

class _PostImagesState extends State<PostImages> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SizedBox(
      child: widget.post.images.length == 1
          ? PostSingleImage(imageUrl: widget.post.images.first)
          : Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: width,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: widget.post.images
                      .map((item) => PostSingleImage(imageUrl: item))
                      .toList(),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.post.images.map((url) {
                      int index = widget.post.images.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? const Color.fromRGBO(0, 0, 0, 0.9)
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class PostSingleImage extends StatelessWidget {
  final String imageUrl;
  final String? moreNumberOfImages;
  const PostSingleImage({
    super.key,
    required this.imageUrl,
    this.moreNumberOfImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image: moreNumberOfImages != null
              ? DecorationImage(image: NetworkImage(imageUrl))
              : null,
        ),
        child: moreNumberOfImages == null
            ? ClipRRect(
                child:
                    CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover))
            : Container(
                color: Colors.black.withOpacity(0.47),
                child: Center(
                  child: Text(
                    moreNumberOfImages!,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ));
  }
}

// class StoriesRow extends ConsumerWidget {
//   StoriesRow({super.key});

//   final seenUserIds = <String>{};
//   final uniqueStories = <StoryModel>[];
//   List<StoryModel> allStories = [];

//   @override
//   Widget build(BuildContext context, ref) {
//     final myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//     final storyAsyncValue = ref.watch(q.getStoryProvider);

//     return storyAsyncValue.when(
//       data: (stories) {
//         allStories = stories;
//         for (final story in stories) {
//           if (seenUserIds.add(story.phoneNumber)) {
//             uniqueStories.add(story);
//           }
//         }
//         // Sort the stories so that the current user's story is first
//         uniqueStories.sort((a, b) {
//           if (b.phoneNumber == myphoneNumber) {
//             return 1;
//           } else if (a.phoneNumber == myphoneNumber) {
//             return -1;
//           } else {
//             return 0;
//           }
//         });

//         final otherUsers = ref.watch(otherUsersProvider);
//         final userProfileProvider = ref.watch(userProfileFutureProvider);

//         List<UserProfileModel> storiesUsers = [];

//         otherUsers.whenData((value) {
//           final users = value.where((element) {
//             return uniqueStories
//                 .map((e) => e.phoneNumber)
//                 .toList()
//                 .contains(element.phoneNumber);
//           }).toList();

//           storiesUsers.addAll(users);
//         });
//         UserProfileModel? currentUserPr;
//         userProfileProvider.whenData((value) {
//           storiesUsers.add(value!);
//           currentUserPr = value;
//         });

//         return ListView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: uniqueStories.length + 1,
//           itemBuilder: (context, index) {
//             // final story = uniqueStories[index];
//             // final user = storiesUsers
//             //     .firstWhere((element) => element.phoneNumber == story.phoneNumber);
//             if (uniqueStories.isNotEmpty) {
//               if (uniqueStories[0].phoneNumber == myphoneNumber && index == 0) {
//                 return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const CameraScreenStory()),
//                       );
//                     },
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.only(
//                               right: AppConstants.defaultNumericValue),
//                           width: 100.0,
//                           height: 200.0,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: NetworkImage(
//                                     currentUserPr!.profilePicture!),
//                                 fit: BoxFit.cover),
//                             // color: Colors.blue,
//                             borderRadius: BorderRadius.circular(20.0),
//                           ),
//                         ),
//                         Positioned(
//                             bottom: 0,
//                             right: 10,
//                             child: Container(
//                               height: 80,
//                               width: 110,
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(20),
//                                   bottomRight: Radius.circular(20),
//                                 ),
//                               ),
//                             )),
//                         Container(
//                             margin: const EdgeInsets.only(right: 11, top: 15),
//                             child: const CircleAvatar(
//                               backgroundColor: Colors.white,
//                               child: Icon(
//                                 Icons.add_circle_rounded,
//                                 color: AppConstants.primaryColor,
//                                 size: 40,
//                               ),
//                             )),
//                         const Positioned(
//                             bottom: 25,
//                             child: Text(
//                               "Create a \nStory",
//                               textAlign: TextAlign.center,
//                             ))
//                       ],
//                     ));
//               }
//             } else {
//               return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const CameraScreenStory()),
//                     );
//                   },
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Container(
//                         margin: const EdgeInsets.only(
//                             right: AppConstants.defaultNumericValue),
//                         width: 100.0,
//                         height: 200.0,
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                               image:
//                                   NetworkImage(currentUserPr!.profilePicture!),
//                               fit: BoxFit.cover),
//                           // color: Colors.blue,
//                           borderRadius: BorderRadius.circular(20.0),
//                         ),
//                       ),
//                       Positioned(
//                           bottom: 0,
//                           right: 10,
//                           child: Container(
//                             height: 80,
//                             width: 110,
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20),
//                               ),
//                             ),
//                           )),
//                       Container(
//                           margin: const EdgeInsets.only(right: 11, top: 15),
//                           child: const CircleAvatar(
//                             backgroundColor: Colors.white,
//                             child: Icon(
//                               Icons.add_circle_rounded,
//                               color: AppConstants.primaryColor,
//                               size: 40,
//                             ),
//                           )),
//                       const Positioned(
//                           bottom: 25,
//                           child: Text(
//                             "Create a \nStory",
//                             textAlign: TextAlign.center,
//                           ))
//                     ],
//                   ));
//             }

//             // Adjust the story index if the blue container is present
//             final storyIndex = index - 1;
//             final story = uniqueStories[storyIndex];
//             final user = storiesUsers.firstWhere(
//                 (element) => element.phoneNumber == story.phoneNumber);

//             return SizedBox(
//               width: 100.0,
//               child: Column(
//                 children: <Widget>[
//                   Stack(
//                     children: [
//                       GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               PageRouteBuilder(
//                                 pageBuilder:
//                                     (context, animation, secondaryAnimation) =>
//                                         StoryView(
//                                   users: storiesUsers,
//                                   stories: allStories,
//                                 ),
//                                 transitionsBuilder: (context, animation,
//                                     secondaryAnimation, child) {
//                                   var begin = const Offset(0.0, 1.0);
//                                   var end = Offset.zero;
//                                   var curve = Curves.ease;

//                                   var tween = Tween(begin: begin, end: end)
//                                       .chain(CurveTween(curve: curve));

//                                   return SlideTransition(
//                                     position: animation.drive(tween),
//                                     child: child,
//                                   );
//                                 },
//                               ),
//                             );
//                             // Navigator.push(
//                             //   context,
//                             //   MaterialPageRoute(
//                             //     builder: (context) => StoryView(
//                             //       users: storiesUsers,
//                             //       stories: allStories,
//                             //     ),
//                             //   ),
//                             // );
//                           },
//                           child: Container(
//                             height: 180,
//                             width: 100,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20.0),
//                               image: DecorationImage(
//                                 image: NetworkImage(story.thumbnail!),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           )),
//                       Positioned(
//                           top: 10,
//                           right: 10,
//                           child: Container(
//                             height: 40,
//                             width: 40,
//                             padding: const EdgeInsets.all(0),
//                             child: UserCirlePicture(
//                                 imageUrl: user.profilePicture,
//                                 size: AppConstants.defaultNumericValue * 2.5),
//                           )),
//                       Positioned(
//                         bottom: 10,
//                         left: 5,
//                         child: Text(
//                           textAlign: TextAlign.center,
//                           story.singer!,
//                           style: const TextStyle(
//                               fontSize: 18.0,
//                               fontWeight: FontWeight.w600,
//                               color: colorBG),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//       loading: () => const CircularProgressIndicator(),
//       error: (err, stack) => Text('Error: $err'),
//     );
//   }
// }

class StoryView extends StatefulWidget {
  final List<UserProfileModel> users;
  final List<StoryModel> stories;

  const StoryView({super.key, required this.users, required this.stories});

  @override
  _StoryViewState createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  late List<AnimationController> _animControllers;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    super.initState();
    _animControllers = List.generate(
      widget.stories.length,
      (index) => AnimationController(
        duration: parseDuration(widget.stories[index].duration!),
        vsync: this,
      ),
    );
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.stories[_currentIndex].postType == 'video') {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.stories[_currentIndex].uploadFile!));
      _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
        startStoryTimer();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.stories[_currentIndex].postType == 'image') {
      precacheImage(
              NetworkImage(widget.stories[_currentIndex].uploadFile!), context)
          .then((_) {
        startStoryTimer();
      });
    }
  }

  void startStoryTimer() {
    final storyDuration =
        parseDuration(widget.stories[_currentIndex].duration!);
    if (_currentIndex >= 1 &&
        widget.stories[_currentIndex].postType == 'video') {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.stories[_currentIndex].uploadFile!));
      _initializeVideoPlayerFuture = _controller!.initialize().then((value) {
        _animControllers[_currentIndex].forward().whenComplete(() {
          if (_currentIndex < widget.stories.length - 1) {
            _currentIndex++;
            _pageController.animateToPage(_currentIndex,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeIn);

            startStoryTimer();
          } else {
            Navigator.pop(context);
          }
        });
      });
    } else {
      _animControllers[_currentIndex].forward().whenComplete(() {
        if (_currentIndex < widget.stories.length - 1) {
          _currentIndex++;
          _pageController.animateToPage(_currentIndex,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn);

          startStoryTimer();
        } else {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    for (var controller in _animControllers) {
      controller.stop(); // Add this line
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.stories.length,
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            final user = widget.users.firstWhere(
                (element) => element.phoneNumber == story.phoneNumber);

            return Container(
              color: Colors.black,
              width: width,
              height: height,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (story.postType == 'image')
                    Image.network(story.uploadFile!)
                  else if (story.postType == 'video')
                    FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          );
                        } else {
                          return SizedBox(
                            width: width,
                            height: height,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  widget.stories[index].thumbnail!,
                                  fit: BoxFit.cover,
                                ),
                                BackdropFilter(
                                  filter:
                                      ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                                const Center(
                                    child: CircularProgressIndicator()),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  Positioned.fill(
                    child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            if (_currentIndex > 0) {
                              _currentIndex--;
                              _pageController.animateToPage(_currentIndex,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeIn);
                            }
                          },
                          child: Container(
                              color: Colors.transparent, width: width / 2),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_currentIndex < widget.stories.length - 1) {
                              _currentIndex++;
                              _pageController.animateToPage(_currentIndex,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeIn);
                            }
                          },
                          child: Container(
                              color: Colors.transparent, width: width / 2),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: List.generate(widget.stories.length, (index) {
                        return AnimatedBar(
                          animController: _animControllers[index],
                          position: index,
                          currentIndex: _currentIndex,
                        );
                      }),
                    ),
                  ),

                  // Add a close icon at the top right corner
                  Positioned(
                    top: 15,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  Positioned(
                      top: 20,
                      left: AppConstants.defaultNumericValue,
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(0),
                            child: UserCirlePicture(
                                imageUrl: user.profilePicture,
                                size: AppConstants.defaultNumericValue * 2.5),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            user.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white),
                          )
                        ],
                      )),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        height: 150,
                        width: width,
                        color: Colors.black45,
                      )),

                  Positioned(
                    bottom: 100,
                    right: AppConstants.defaultNumericValue,
                    child: IconButton(
                      icon: WebsafeSvg.asset(
                        emptyLikeIcon,
                        height: 25,
                        width: 25,
                        fit: BoxFit.fitHeight,
                        colorFilter: const ColorFilter.mode(
                          // Colors.blueGrey,
                          //  AppConstants.primaryColor,
                          // AppConstants.secondaryColor,
                          Colors.white,
                          // Colors.grey,
                          //  Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // Handle the like button tap here
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 55,
                    right: AppConstants.defaultNumericValue,
                    child: IconButton(
                      icon: WebsafeSvg.asset(
                        height: 30,
                        width: 30,
                        fit: BoxFit.fitHeight,
                        commentIcon,
                        colorFilter: const ColorFilter.mode(
                          // Colors.blueGrey,
                          //  AppConstants.primaryColor,
                          // AppConstants.secondaryColor,
                          Colors.white,
                          // Colors.grey,
                          //  Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        // Handle the like button tap here
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: AppConstants.defaultNumericValue,
                    child: Container(
                        padding: const EdgeInsets.only(
                            right: AppConstants.defaultNumericValue * 1.4),
                        width: width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              story.caption!,
                              maxLines: 2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.white),
                            )
                          ],
                        )),
                  ),
                  Positioned(
                      bottom: 100,
                      left: AppConstants.defaultNumericValue,
                      child: InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 5,
                            ),
                            width: MediaQuery.of(context).size.width * 0.25,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: const BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  CupertinoIcons.gift,
                                  size: 15,
                                ),
                                Text(
                                  LocaleKeys.sendGift.tr(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ))),
                ],
              ),
            );
          },
        ));
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    super.key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: <Widget>[
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}

Duration parseDuration(String input, {String separator = ':'}) {
  final parts = input.split(separator).map((t) => t.trim()).toList();

  int? hours;
  int? minutes;
  double? seconds;

  if (parts.length != 3) {
    throw const FormatException('Invalid duration format');
  }

  hours = int.parse(parts[0]);
  minutes = int.parse(parts[1]);
  seconds = double.parse(parts[2]);

  return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds.floor(),
      milliseconds: ((seconds - seconds.floor()) * 1000).round());
}

void showAddCommentBottomSheet(
    BuildContext context, FeedModel feed, ref, String currentUserNo) {
  final TextEditingController commentController = TextEditingController();
  // final addCommentProv = ref.watch(addCommentProvider);
  // final myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CloseButton(
                  color: Colors.transparent,
                  onPressed: () {},
                ),
                Expanded(
                  child: Text(
                    LocaleKeys.comments.tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const CloseButton(),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final commentsAsyncValue = ref.watch(commentsProvider(feed.id));
                final otherUsersAsyncValue = ref.watch(otherUsersProvider(ref));
                final currentUserProfileAsyncValue =
                    ref.watch(userProfileFutureProvider);

                return currentUserProfileAsyncValue.when(
                  data: (currentUserProfile) {
                    return otherUsersAsyncValue.when(
                      data: (otherUsers) {
                        // Create a map of userIds to user profiles
                        final userIdToProfile = {
                          for (var user in otherUsers) user.phoneNumber: user
                        };

                        // Add the current user's profile to the map
                        userIdToProfile[currentUserProfile!.phoneNumber] =
                            currentUserProfile;

                        return commentsAsyncValue.when(
                          data: (comments) => ListView.builder(
                            shrinkWrap: true,
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              // Get the user profile for this comment's phoneNumber
                              final userProfile =
                                  userIdToProfile[comment['phoneNumber']];
                              print(comment);

                              return ListTile(
                                title: Text(comment['text'] as String),
                                subtitle: Text(
                                    '${LocaleKeys.postedBy.tr()} ${userProfile?.fullName ?? LocaleKeys.unknown.tr()}'),
                                trailing: UserCirlePicture(
                                    imageUrl: userProfile?.profilePicture,
                                    size:
                                        AppConstants.defaultNumericValue * 2.5),
                              );
                            },
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => Text(LocaleKeys.erroroccured.tr()),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => Text(LocaleKeys.erroroccured.tr()),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => Text(LocaleKeys.erroroccured.tr()),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.addComment.tr(),
                      fillColor: AppConstants.primaryColor.withOpacity(.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final commentText = commentController.text.trim();
                    if (commentText.isNotEmpty) {
                      // Call the addComment function from your addCommentProvider here
                      // For example:
                      await addComment(feed.id, commentText, currentUserNo)
                          .then((value) => print("Commented ==> $value"));
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),
          ],
        ),
      );
    },
  );
}
