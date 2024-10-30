// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/otherProfile/subscribe_page.dart';
import 'package:lamatdating/views/tabs/bottom_nav_bar_page.dart';
import 'package:lamatdating/views/video/video_list_screen.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/block_user_provider.dart';
import 'package:lamatdating/providers/feed_provider.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/otherProfile/other_profile_view.dart';
import 'package:lamatdating/views/report/report_page.dart';
import 'package:lamatdating/views/security/security_and_privacy_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/feeds/feeds_home_page.dart';
import 'package:lamatdating/views/tabs/home/explore_page.dart';
import 'package:lamatdating/views/tabs/home/user_card_widget.dart';
import 'package:lamatdating/views/tabs/interactions/interactions_page.dart';
import 'package:lamatdating/views/tabs/matches/matches_page.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';
import 'package:lamatdating/views/wallet/wallet_page.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';

class UserDetailsPage extends ConsumerStatefulWidget {
  final UserProfileModel user;
  final String? matchId;
  final bool? isStreaming;
  final Function? onBackFunc;

  const UserDetailsPage({
    super.key,
    required this.user,
    this.matchId,
    this.isStreaming,
    this.onBackFunc,
  });

  @override
  UserDetailsPageState createState() => UserDetailsPageState();
}

class UserDetailsPageState extends ConsumerState<UserDetailsPage>
    with WidgetsBindingObserver {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceid;
  var mapDeviceInfo = {};
  SharedPreferences? prefs;
  TabController? controller;

  bool isFetching = true;
  List phoneNumberVariants = [];

  bool isAuthenticating = false;

  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);

  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;
  String? myphoneNumber;

  
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  Observer? observer;

  @override
  void initState() {
    getPrefs();

    WidgetsBinding.instance.addObserver(this);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      observer = ref.watch(observerProvider);
      WidgetsBinding.instance.addObserver(this);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (IsVideoAdShow == true && observer!.isadmobshow == true && !kIsWeb) {
          _createRewardedAd();
        }
      });
    });
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

  void _showRewardedAd(Future<dynamic> goNext) {
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
        goNext;
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

  DataModel? _cachedModel;
  DataModel? getModel() {
    myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
    _cachedModel ??= DataModel(myphoneNumber);
    return _cachedModel;
  }

  Future<SharedPreferences> getPrefs() async {
    if (!kIsWeb) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        prefs = await SharedPreferences.getInstance();
        return prefs!;
      } else {
        await Permission.storage.request();
        prefs = await SharedPreferences.getInstance();
        return prefs!;
      }
    } else {
      prefs = await SharedPreferences.getInstance();
      return prefs!;
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

  @override
  void didChangeDependencies() async {
    myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;
    getModel();
    super.didChangeDependencies();
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = ref.watch(userProviderProvider);

    userProvider.getUserDetails(myphoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final prefs = ref.watch(sharedPreferencesProvider).value;
    final String myPhoneNumber =
        ref.watch(currentUserStateProvider)!.phoneNumber!;

    final PageController pageController = PageController();

    final currentUserProfile = ref.watch(userProfileFutureProvider);

    final String myphoneNumber =
        ref.watch(currentUserStateProvider)!.phoneNumber!;
    final String id = myphoneNumber + widget.user.phoneNumber;

    bool canLike = true;
    bool canSuperLike = true;
    bool canDislike = true;
    int currentIndex = 0;
    bool? isUser;
    bool? istyping;
    bool? isLoading;
    bool? isShowOnlySpinner;

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

// final PageController pageController = PageController();

    Future<void> showMatchingDialog({
      required BuildContext context,
      required UserProfileModel currentUser,
      required UserProfileModel otherUser,
    }) async {
      final MatchModel matchModel = MatchModel(
        id: currentUser.phoneNumber + otherUser.phoneNumber,
        userIds: [currentUser.phoneNumber, otherUser.phoneNumber],
        isMatched: true,
      );
      final prefs = ref.watch(sharedPreferencesProvider).value;

      await createConversation(matchModel).then((matchResult) async {
        final images = otherUser.mediaFiles;
        final cachedModel = DataModel(myphoneNumber);
        if (matchResult) {
          final currentTime = DateTime.now();
          final id =
              matchModel.id + currentTime.millisecondsSinceEpoch.toString();
          final NotificationModel notificationModel = NotificationModel(
            id: id,
            phoneNumber: currentUser.phoneNumber,
            receiverId: otherUser.phoneNumber,
            matchId: matchModel.id,
            title: currentUser.fullName,
            body: LocaleKeys.youhaveanewmatch.tr(),
            image: currentUser.profilePicture,
            createdAt: currentTime,
            isRead: false,
            isMatchingNotification: true,
            isInteractionNotification: false,
          );

          await addNotification(notificationModel).then((value) async {
            await showDialog(
              context: context,
              builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.bounceInOut,
                      width: MediaQuery.of(context).size.width * .7,
                      height: MediaQuery.of(context).size.height * .7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                      ),
                      child: GridTile(
                        header: Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue)),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: AppConstants.defaultNumericValue,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top + 5,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      final screenWidth = constraints.maxWidth;
                                      final dotWidth =
                                          (screenWidth * .87) / images.length;

                                      return images.isNotEmpty
                                          ? SmoothPageIndicator(
                                              controller:
                                                  pageController, // PageController
                                              count: images.length,
                                              effect: WormEffect(
                                                  dotHeight: 5,
                                                  dotWidth:
                                                      dotWidth, // set the width of the dot
                                                  activeDotColor:
                                                      AppConstants.primaryColor,
                                                  dotColor: Colors
                                                      .black54), // your preferred effect
                                              onDotClicked: (index) {
                                                pageController.animateToPage(
                                                  index,
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                            )
                                          : const SizedBox();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: AppConstants.defaultNumericValue,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UserCirlePicture(
                                      imageUrl: otherUser.profilePicture,
                                      size: 70),
                                  const SizedBox(
                                      width:
                                          AppConstants.defaultNumericValue / 4),
                                  UserCirlePicture(
                                      imageUrl: currentUser.profilePicture,
                                      size: 70),
                                ],
                              ),
                            ],
                          ),
                        ),
                        footer: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue / 3),
                          decoration: BoxDecoration(
                              color: Teme.isDarktheme(prefs!)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Center(
                                          child:
                                              Text(LocaleKeys.notNow.tr())))),
                              const SizedBox(
                                  width: AppConstants.defaultNumericValue),
                              Expanded(
                                child: CustomButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    !Responsive.isDesktop(context)
                                        ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PreChat(
                                                name: otherUser.fullName,
                                                phone: otherUser.phoneNumber,
                                                currentUserNo: ref
                                                    .watch(
                                                        currentUserStateProvider)!
                                                    .phoneNumber,
                                                model: cachedModel,
                                                prefs: prefs,
                                              ),
                                            ),
                                          )
                                        : {
                                            updateCurrentIndex(ref, 10),
                                            ref
                                                .read(arrangementProviderExtend
                                                    .notifier)
                                                .setArrangement(PreChat(
                                                  name: otherUser.fullName,
                                                  phone: otherUser.phoneNumber,
                                                  currentUserNo: ref
                                                      .watch(
                                                          currentUserStateProvider)!
                                                      .phoneNumber,
                                                  model: cachedModel,
                                                  prefs: prefs,
                                                ))
                                          };
                                  },
                                  text: LocaleKeys.startChat.tr(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: images.isEmpty
                            ? (otherUser.profilePicture!.isNotEmpty &&
                                    otherUser.profilePicture != null)
                                ? Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              otherUser.profilePicture!)),
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.defaultNumericValue),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.defaultNumericValue),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                          child: GifView.asset(itsAMatch,
                                              // color: AppConstants.primaryColor,
                                              width: Responsive.isMobile(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .8
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .8,
                                              height:
                                                  Responsive.isMobile(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .8
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          .8,
                                              fit: BoxFit.contain)
                                          // child: const Center(
                                          //     child: Icon(CupertinoIcons.photo)),
                                          ),
                                      // child: const Center(
                                      //     child: Icon(CupertinoIcons.photo)),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Teme.isDarktheme(prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                      borderRadius: BorderRadius.circular(
                                          AppConstants.defaultNumericValue),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        child: GifView.asset(itsAMatch,
                                            // color: AppConstants.primaryColor,
                                            width: Responsive.isMobile(context)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .8,
                                            height: Responsive.isMobile(context)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .8
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    .8,
                                            fit: BoxFit.contain)
                                        // child: const Center(
                                        //     child: Icon(CupertinoIcons.photo)),
                                        ))
                            : Container(
                                decoration: BoxDecoration(
                                    color: Teme.isDarktheme(prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.defaultNumericValue / 2)),
                                child: Stack(
                                  children: [
                                    PageView(
                                      controller: pageController,
                                      onPageChanged: (_) {
                                        setState(() {});
                                      },
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: images.map((e) {
                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 56),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue /
                                                          2)),
                                              child: ClipRRect(
                                                child: Image.network(
                                                  e,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child: Lottie.asset(
                                                          loadingDiam,
                                                          fit: BoxFit.cover,
                                                          width: 60,
                                                          height: 60,
                                                          repeat: true),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Icon(
                                                            CupertinoIcons
                                                                .photo));
                                                  },
                                                ),
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        pageController.previousPage(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            curve: Curves
                                                                .easeInOut);
                                                      },
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        pageController.nextPage(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                            curve: Curves
                                                                .easeInOut);
                                                      },
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                    Center(
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                          child: GifView.asset(itsAMatch,
                                              // color: AppConstants.primaryColor,
                                              width: Responsive.isMobile(
                                                      context)
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .8
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      .8,
                                              height:
                                                  Responsive.isMobile(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .8
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          .8,
                                              fit: BoxFit.contain)
                                          // child: const Center(
                                          //     child: Icon(CupertinoIcons.photo)),
                                          ),
                                    )
                                  ],
                                )),
                      )),
                );
              },
            );
          });
        }
      });
    }

    final UserInteractionModel interaction = UserInteractionModel(
      id: id,
      phoneNumber: myPhoneNumber,
      intractToUserId: widget.user.phoneNumber,
      isSuperLike: false,
      isLike: false,
      isDislike: false,
      createdAt: DateTime.now(),
    );

    UserProfileModel? currentUserProfileModel;
    currentUserProfile.whenData((userProfile) {
      currentUserProfileModel = userProfile;
    });

    return SubscriptionBuilder(
      builder: (context, isPremiumUser) {
        // Freemium Limitations
        final List<UserInteractionModel> data = [];
        final interactionProvider = ref.watch(interactionFutureProvider);
        interactionProvider.whenData((value) {
          data.addAll(value);
        });

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final interactionsToday =
            data.where((element) => element.createdAt.isAfter(today)).toList();

        // Check limits

        int totalLiked = interactionsToday
            .where((element) => element.isLike)
            .toList()
            .length;

        int totalSuperLiked = interactionsToday
            .where((element) => element.isSuperLike)
            .toList()
            .length;

        int totalDisliked = interactionsToday
            .where((element) => element.isDislike)
            .toList()
            .length;

        bool canLike = true;
        bool canSuperLike = true;
        bool canDislike = true;

        if (isPremiumUser) {
          if (FreemiumLimitation.maxDailyLikeLimitPremium != 0 &&
              totalLiked >= FreemiumLimitation.maxDailyLikeLimitPremium) {
            canLike = false;
          }

          if (FreemiumLimitation.maxDailySuperLikeLimitPremium != 0 &&
              totalSuperLiked >=
                  FreemiumLimitation.maxDailySuperLikeLimitPremium) {
            canSuperLike = false;
          }

          if (FreemiumLimitation.maxDailyDislikeLimitPremium != 0 &&
              totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitPremium) {
            canDislike = false;
          }
        } else {
          if (FreemiumLimitation.maxDailyLikeLimitFree != 0 &&
              totalLiked >= FreemiumLimitation.maxDailyLikeLimitFree) {
            canLike = false;
          }

          if (FreemiumLimitation.maxDailySuperLikeLimitFree != 0 &&
              totalSuperLiked >=
                  FreemiumLimitation.maxDailySuperLikeLimitFree) {
            canSuperLike = false;
          }

          if (FreemiumLimitation.maxDailyDislikeLimitFree != 0 &&
              totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitFree) {
            canDislike = false;
          }
        }
        double width = MediaQuery.of(context).size.width;
        double height = MediaQuery.of(context).size.height;

        return Scaffold(
          body: Stack(
            children: [
              DetailsBodyNested(
                isStreaming: widget.isStreaming,
                onBackFunc: widget.onBackFunc,
                cachedModel: _cachedModel,
                user: widget.user,
                currentUserProf: currentUserProfileModel!,
                matchId: widget.matchId,
                myPhoneNumber: myPhoneNumber,
                
              ),
              (widget.matchId != null)
                  ? Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.8),
                            padding: const EdgeInsets.only(
                                bottom: AppConstants.defaultNumericValue * 2,
                                top: AppConstants.defaultNumericValue),
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: CustomButton(
                                text: LocaleKeys.sendaMessage.tr(),
                                onPressed: () {
                                  if (IsVideoAdShow == true &&
                                      observer!.isadmobshow == true &&
                                      !kIsWeb) {
                                    _showRewardedAd(Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PreChat(
                                          name: widget.user.fullName,
                                          phone: widget.user.phoneNumber,
                                          currentUserNo: ref
                                              .watch(currentUserStateProvider)!
                                              .phoneNumber,
                                          model: _cachedModel,
                                          prefs: prefs!,
                                        ),
                                      ),
                                    ));
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PreChat(
                                          name: widget.user.fullName,
                                          phone: widget.user.phoneNumber,
                                          currentUserNo: ref
                                              .watch(currentUserStateProvider)!
                                              .phoneNumber,
                                          model: _cachedModel,
                                          prefs: prefs!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Positioned(
                      bottom: AppConstants.defaultNumericValue,
                      left: width * .22,
                      right: width * .22,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue * 2),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.6),
                            padding: const EdgeInsets.only(
                                bottom: AppConstants.defaultNumericValue / 2,
                                top: AppConstants.defaultNumericValue / 2),
                            width: MediaQuery.of(context).size.width * .6,
                            child: Center(
                              child: UserLikeActions(
                                // onTapRewind: () async {},
                                currentUserProf: currentUserProfileModel!,
                                isDetailsPage: true,
                                onTapCross: () async {
                                  ref.invalidate(arrangementProvider);
                                  ref.invalidate(arrangementProviderExtend);
                                  if (canDislike) {
                                    final newInteraction = interaction.copyWith(
                                        isDislike: true,
                                        createdAt: DateTime.now());
                                    await createInteraction(newInteraction)
                                        .then((value) {
                                      Navigator.pop(context);
                                      ref.invalidate(interactionFutureProvider);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys
                                            .youhavereachedyourdailylimitofdislikes
                                            .tr()),
                                      ),
                                    );
                                  }
                                },
                                onTapBolt: () async {
                                  ref.invalidate(arrangementProvider);
                                  if (canSuperLike) {
                                    final newInteraction = interaction.copyWith(
                                        isSuperLike: true,
                                        createdAt: DateTime.now());
                                    await createInteraction(newInteraction)
                                        .then((result) async {
                                      if (result &&
                                          currentUserProfileModel != null) {
                                        await getExistingInteraction(
                                                widget.user.phoneNumber,
                                                myPhoneNumber)
                                            .then((otherUserInteraction) async {
                                          if (otherUserInteraction != null) {
                                            await showMatchingDialog(
                                                context: context,
                                                currentUser:
                                                    currentUserProfileModel!,
                                                otherUser: widget.user);
                                          } else {
                                            createInteractionNotification(
                                                title: LocaleKeys
                                                    .youhaveanewInteraction
                                                    .tr(),
                                                body: LocaleKeys
                                                    .someonehassuperlikedyou
                                                    .tr(),
                                                receiverId:
                                                    widget.user.phoneNumber,
                                                currentUser:
                                                    currentUserProfileModel!);
                                            Navigator.pop(context);
                                          }
                                        });
                                      }

                                      ref.invalidate(interactionFutureProvider);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys
                                            .youhavereachedyourdailylimitoflikes
                                            .tr()),
                                      ),
                                    );
                                  }
                                },
                                onTapHeart: () async {
                                  ref.invalidate(arrangementProvider);
                                  if (canLike) {
                                    final newInteraction = interaction.copyWith(
                                        isLike: true,
                                        createdAt: DateTime.now());
                                    await createInteraction(newInteraction)
                                        .then((result) async {
                                      if (result &&
                                          currentUserProfileModel != null) {
                                        await getExistingInteraction(
                                                widget.user.phoneNumber,
                                                myPhoneNumber)
                                            .then((otherUserInteraction) async {
                                          if (otherUserInteraction != null) {
                                            await showMatchingDialog(
                                                context: context,
                                                currentUser:
                                                    currentUserProfileModel!,
                                                otherUser: widget.user);
                                          } else {
                                            createInteractionNotification(
                                                title: LocaleKeys
                                                    .youhaveanewInteraction
                                                    .tr(),
                                                body: LocaleKeys
                                                    .someonehaslikedyou
                                                    .tr(),
                                                receiverId:
                                                    widget.user.phoneNumber,
                                                currentUser:
                                                    currentUserProfileModel!);
                                            Navigator.pop(context);
                                          }
                                        });
                                      }

                                      ref.invalidate(interactionFutureProvider);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(LocaleKeys
                                            .youhavereachedyourdailylimitoflikes
                                            .tr()),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class DetailsBodyNested extends ConsumerStatefulWidget {
  const DetailsBodyNested({
    super.key,
    required this.user,
    required this.currentUserProf,
    required this.myPhoneNumber,
    required this.matchId,
    required this.cachedModel,
    this.onBackFunc,
    this.isStreaming,
  });
  final UserProfileModel user;
  final UserProfileModel currentUserProf;
  final String myPhoneNumber;
  final String? matchId;
  final DataModel? cachedModel;
  final Function? onBackFunc;
  final bool? isStreaming;
  @override
  ConsumerState<DetailsBodyNested> createState() => _DetailsBodyNestedState();
}

class _DetailsBodyNestedState extends ConsumerState<DetailsBodyNested>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();
  late TabController _tabController;

  final ScrollController _controller = ScrollController();
  double maxExtent = 500;
  double currentExtent = 500;
  SharedPreferences? prefs;

  DataModel? _cachedModel;

  List mySubs = [];

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  Observer? observer;

  @override
  void initState() {
    getPrefs();
    _cachedModel = widget.cachedModel;
    // getModel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      maxExtent = 500;
      currentExtent = maxExtent;

      _controller.addListener(() {
        setState(() {
          currentExtent = maxExtent - _controller.offset;
          if (currentExtent < 100) currentExtent = 0.0;
          if (currentExtent > maxExtent) currentExtent = maxExtent;
        });
      });
      observer = ref.watch(observerProvider);
      WidgetsBinding.instance.addObserver(this);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (IsVideoAdShow == true && observer!.isadmobshow == true && !kIsWeb) {
          _createRewardedAd();
        }
      });
    });
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuilds the TabBar when the tab selection changes
    });
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

  void _showRewardedAd(Future<dynamic> goNext) {
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
        goNext;
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

  Future<SharedPreferences> getPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  // DataModel? getModel() {
  //   _cachedModel ??= DataModel(widget.myPhoneNumber);
  //   return _cachedModel;
  // }

  getUser() async {
    await getPrefs();

    _cachedModel!
        .addUser(widget.user.toMap() as DocumentSnapshot<Map<String, dynamic>>);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                isSharingIntentForwarded: false,
                prefs: prefs!,
                unread: 0,
                currentUserNo: widget.myPhoneNumber,
                model: _cachedModel!,
                peerNo: widget.user.phoneNumber)));
  }

  void _onTapUnmatch() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleKeys.unmatch.tr()),
            content: Text(LocaleKeys.areyousureyouwanttounmatch.tr()),
            actions: [
              TextButton(
                child: Text(LocaleKeys.cancel.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(LocaleKeys.unmatch.tr()),
                onPressed: () async {
                  EasyLoading.show(status: LocaleKeys.unmatching.tr());

                  await unMatchUser(widget.matchId!, widget.user.phoneNumber,
                          widget.myPhoneNumber)
                      .then((value) {
                    EasyLoading.dismiss();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
  }

  void _onTapSendMessage() async {
    // final MatchModel matchModel = MatchModel(
    //   id: widget.myPhoneNumber + widget.user.phoneNumber,
    //   userIds: [widget.myPhoneNumber, widget.user.phoneNumber],
    //   isMatched: false,
    // );

    // EasyLoading.show(status: LocaleKeys.creatingconversation.tr());
    // await createConversation(matchModel).then((matchResult) async {
    //   if (matchResult) {
    //     EasyLoading.dismiss();
    _showRewardedAd(Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PreChat(
              name: widget.user.fullName,
              phone: widget.user.phoneNumber,
              currentUserNo: ref.watch(currentUserStateProvider)!.phoneNumber,
              model: widget.cachedModel,
              prefs: prefs!,
            ),
          ),
        ));
        
    //   } else {
    //     EasyLoading.showInfo(LocaleKeys.somethingWentWrong);
    //   }
    // });
   
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_rewardedAd != null) {
      _rewardedAd!.dispose();
    }
    super.dispose();
  }

  bool _isSelected(int index) {
    return _tabController.index == index;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final prefs = ref.watch(sharedPreferences).value;
    final userProfileRef = ref.watch(userProfileFutureProvider);
    // final walletAsyncValue = ref.watch(walletsStreamProvider);
    final feedList = ref.watch(getFeedsProvider(ref));
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    final appSettingsRef = ref.watch(appSettingsProvider);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Teme.isDarktheme(prefs!)
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          elevation: 0,
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
        ),
        body: DefaultTabController(
          length: 4,
          child: NestedScrollView(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Teme.isDarktheme(prefs)
                      ? AppConstants.primaryColorDark
                      : AppConstants.primaryColor,
                  title: Container(
                      color: Teme.isDarktheme(prefs)
                          ? AppConstants.primaryColorDark
                          : AppConstants.primaryColor,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: (!Responsive.isDesktop(context))
                                  ? () {
                                      (widget.isStreaming != null)
                                          ? widget.onBackFunc
                                          : Navigator.pop(context);
                                      if (widget.isStreaming != null) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  : () {
                                      ref.invalidate(arrangementProvider);
                                    },
                              child: WebsafeSvg.asset(
                                leftArrowSvg,
                                height: 30,
                                width: 30,
                                colorFilter: const ColorFilter.mode(
                                  // Colors.blueGrey,
                                  //  AppConstants.primaryColor,
                                  // AppConstants.secondaryColor,
                                  Colors.white,
                                  // Colors.grey,
                                  //  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.contain,
                              )),
                          const SizedBox(
                            width: AppConstants.defaultNumericValue / 2,
                          ),
                          CustomPopupMenu(
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
                                            if (widget.matchId != null)
                                              MoreMenuTitle(
                                                title: LocaleKeys.unmatch.tr(),
                                                onTap: () async {
                                                  _moreMenuController
                                                      .hideMenu();
                                                  _onTapUnmatch();
                                                },
                                              ),
                                            if (widget
                                                    .user
                                                    .userAccountSettingsModel
                                                    .allowAnonymousMessages ==
                                                true)
                                              appSettingsRef.when(
                                                data: (data) {
                                                  if (data?.isChattingEnabledBeforeMatch ==
                                                      true) {
                                                    return MoreMenuTitle(
                                                      title: LocaleKeys
                                                          .sendMessage
                                                          .tr(),
                                                      onTap: _onTapSendMessage,
                                                    );
                                                  } else {
                                                    return const SizedBox();
                                                  }
                                                },
                                                error: (error, stackTrace) =>
                                                    const SizedBox(),
                                                loading: () => const SizedBox(),
                                              ),
                                            MoreMenuTitle(
                                              title: LocaleKeys.report.tr(),
                                              onTap: () {
                                                _moreMenuController.hideMenu();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReportPage(
                                                            userProfileModel:
                                                                widget.user),
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
                                                    widget.myPhoneNumber);
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
                              child: InkWell(
                                onTap: () {
                                  _moreMenuController.showMenu();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "@${widget.user.userName}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            AppConstants.defaultNumericValue *
                                                1.2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // const Padding(
                                    //     padding: EdgeInsets.symmetric(
                                    //         horizontal: 10),
                                    //     child: Icon(CupertinoIcons.chevron_down,
                                    //         color: Colors.white))
                                  ],
                                ),
                              )),
                          widget.user.isVerified
                              ? GestureDetector(
                                  onTap: () {
                                    EasyLoading.showToast(
                                        LocaleKeys.verifiedUser.tr());
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            AppConstants.defaultNumericValue *
                                                .5),
                                    child: Image(
                                      image: AssetImage(verifiedIcon),
                                      width: 20,
                                    ),
                                  ),
                                )
                              : Container(),
                          Expanded(
                              child: Container(
                            height: 50,
                            width: width / 2,
                            color: Teme.isDarktheme(prefs)
                                ? AppConstants.primaryColorDark
                                : AppConstants.primaryColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      showModalBottomSheet(
                                          context: context,
                                          backgroundColor: Teme.isDarktheme(
                                                  prefs)
                                              ? AppConstants.backgroundColorDark
                                              : AppConstants.backgroundColor,
                                          barrierColor: AppConstants
                                              .primaryColor
                                              .withOpacity(.3),
                                          constraints: BoxConstraints(
                                            maxHeight: height * .5,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(AppConstants
                                                  .defaultNumericValue),
                                            ),
                                          ),
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setrState) {
                                              return Column(children: [
                                                const SizedBox(
                                                  height: AppConstants
                                                      .defaultNumericValue,
                                                ),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(
                                                        width: AppConstants
                                                            .defaultNumericValue,
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              WebsafeSvg.asset(
                                                            closeIcon,
                                                            colorFilter:
                                                                const ColorFilter
                                                                    .mode(
                                                              // Colors.blueGrey,
                                                              //  AppConstants.primaryColor,
                                                              AppConstants
                                                                  .secondaryColor,
                                                              // Colors.white,
                                                              // Colors.grey,
                                                              //  Colors.black,
                                                              BlendMode.srcIn,
                                                            ),
                                                            height: 32,
                                                            width: 32,
                                                            fit: BoxFit.contain,
                                                          )),
                                                      SizedBox(
                                                        width: width * .33,
                                                      ),
                                                      Container(
                                                          width: AppConstants
                                                                  .defaultNumericValue *
                                                              3,
                                                          height: 4,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16),
                                                            color: AppConstants
                                                                .hintColor,
                                                          )),
                                                    ]),
                                                const SizedBox(
                                                  width: AppConstants
                                                      .defaultNumericValue,
                                                ),
                                                Text(
                                                  widget.user.userName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge!
                                                      .copyWith(
                                                          fontWeight: FontWeight
                                                              .bold,
                                                          color:
                                                              Teme.isDarktheme(
                                                                      prefs)
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                ),
                                                const SizedBox(
                                                  height: AppConstants
                                                          .defaultNumericValue *
                                                      2,
                                                ),

                                                // Start Content
                                                Container(
                                                  height: 1,
                                                  width: width,
                                                  color: AppConstants.hintColor,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _moreMenuController
                                                        .hideMenu();
                                                    showBlockDialog(
                                                        context,
                                                        widget.user.phoneNumber,
                                                        widget.myPhoneNumber);
                                                  },
                                                  child: ListTile(
                                                    title: Text(
                                                        LocaleKeys.block.tr()),
                                                  ),
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    left: AppConstants
                                                        .defaultNumericValue,
                                                  ),
                                                  height: .5,
                                                  width: width,
                                                  color: AppConstants.hintColor,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _moreMenuController
                                                        .hideMenu();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ReportPage(
                                                                userProfileModel:
                                                                    widget
                                                                        .user),
                                                      ),
                                                    );
                                                  },
                                                  child: ListTile(
                                                    title: Text(
                                                        LocaleKeys.report.tr()),
                                                  ),
                                                ),
                                                // Container(
                                                //   margin: const EdgeInsets.only(
                                                //     left: AppConstants
                                                //         .defaultNumericValue,
                                                //   ),
                                                //   height: .5,
                                                //   width: width,
                                                //   color: AppConstants.hintColor,
                                                // ),
                                                // GestureDetector(
                                                //   onTap: () {},
                                                //   child: const ListTile(
                                                //     title: Text(
                                                //         "Copy profile URL"),
                                                //   ),
                                                // ),
                                                // Container(
                                                //   margin: const EdgeInsets.only(
                                                //     left: AppConstants
                                                //         .defaultNumericValue,
                                                //   ),
                                                //   height: .5,
                                                //   width: width,
                                                //   color: AppConstants.hintColor,
                                                // ),
                                                // GestureDetector(
                                                //   onTap: () {},
                                                //   child: ListTile(
                                                //     title: Text(S
                                                //         .of(context)
                                                //         .shareProfile),
                                                //   ),
                                                // ),
                                                // Container(
                                                //   margin: const EdgeInsets.only(
                                                //     left: AppConstants
                                                //         .defaultNumericValue,
                                                //   ),
                                                //   height: .5,
                                                //   width: width,
                                                //   color: AppConstants.hintColor,
                                                // ),
                                                // GestureDetector(
                                                //   onTap: () {},
                                                //   child: const ListTile(
                                                //     title: Text("QR code"),
                                                //   ),
                                                // ),
                                                Container(
                                                  // margin: const EdgeInsets.only(
                                                  //   left: AppConstants
                                                  //       .defaultNumericValue,
                                                  // ),
                                                  height: .5,
                                                  width: width,
                                                  color: AppConstants.hintColor,
                                                ),
                                                // End Content
                                                const SizedBox(
                                                    height: AppConstants
                                                            .defaultNumericValue *
                                                        2),
                                              ]);
                                            });
                                          });
                                    },
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: Colors.white))
                              ],
                            ),
                          ))
                        ],
                      )),
                  // backgroundColor: AppConstants.secondaryColor,
                  flexibleSpace: FlexibleSpaceBar.createSettings(
                      currentExtent: currentExtent,
                      minExtent: 0,
                      maxExtent: maxExtent,
                      child: FlexibleSpaceBar(
                        background: OtherProfileView(
                          model: _cachedModel!,
                          user: widget.user,
                          userImages: widget.user.mediaFiles,
                        ),
                      )),
                  expandedHeight: maxExtent,
                  automaticallyImplyLeading: false,
                  floating: false,
                  pinned: true,
                  primary: true,
                  snap: false,
                ),
                SliverPersistentHeader(
                  delegate: MyDelegate(
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(
                            icon: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              superLikeIcon,
                              colorFilter: ColorFilter.mode(
                                // Colors.blueGrey,
                                _isSelected(0)
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                // AppConstants.secondaryColor,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Tab(
                            icon: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              gridIcon,
                              colorFilter: ColorFilter.mode(
                                // Colors.blueGrey,
                                _isSelected(1)
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                // AppConstants.secondaryColor,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Tab(
                            icon: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              reelsIcon,
                              colorFilter: ColorFilter.mode(
                                // Colors.blueGrey,
                                _isSelected(2)
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                // AppConstants.secondaryColor,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Tab(
                            icon: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              feedsIcon,
                              colorFilter: ColorFilter.mode(
                                // Colors.blueGrey,
                                _isSelected(3)
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                // AppConstants.secondaryColor,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          Tab(
                            icon: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              crownIcon,
                              colorFilter: ColorFilter.mode(
                                // Colors.blueGrey,
                                _isSelected(4)
                                    ? AppConstants.primaryColor
                                    : Colors.grey,
                                // AppConstants.secondaryColor,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ],
                        indicatorColor: AppConstants.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        labelColor: AppConstants.primaryColor,
                      ),
                      prefs),
                  pinned: true,
                )
              ];
            },
            body: TabBarView(controller: _tabController, children: [
              // Tab 1

              CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverList(
                        delegate: SliverChildListDelegate(
                      [
                        const SizedBox(
                          height: AppConstants.defaultNumericValue,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue,
                              vertical: AppConstants.defaultNumericValue / 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: AppConstants.primaryColor),
                              const SizedBox(
                                  width: AppConstants.defaultNumericValue / 4),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    final myProfile =
                                        ref.watch(userProfileFutureProvider);
                                    return myProfile.when(
                                      data: (data) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (widget
                                                    .user
                                                    .userAccountSettingsModel
                                                    .showLocation !=
                                                false)
                                              Text(
                                                widget
                                                    .user
                                                    .userAccountSettingsModel
                                                    .location
                                                    .addressText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        color: AppConstants
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            if (data != null)
                                              Text(
                                                '${(Geolocator.distanceBetween(data.userAccountSettingsModel.location.latitude, data.userAccountSettingsModel.location.longitude, widget.user.userAccountSettingsModel.location.latitude, widget.user.userAccountSettingsModel.location.longitude) / 1000).toStringAsFixed(2)} km',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              )
                                          ],
                                        );
                                      },
                                      error: (_, __) => const SizedBox(),
                                      loading: () => const SizedBox(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue / 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: Text(
                            LocaleKeys.about.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue / 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: Text(widget.user.about == null ||
                                  widget.user.about!.isEmpty
                              ? LocaleKeys.notavailable.tr()
                              : widget.user.about!),
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue * 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocaleKeys.interests.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: widget.user.interests.isEmpty
                              ? Text(LocaleKeys.notavailable.tr())
                              : Wrap(
                                  spacing: AppConstants.defaultNumericValue / 2,
                                  runSpacing:
                                      AppConstants.defaultNumericValue / 2,
                                  alignment: WrapAlignment.start,
                                  children:
                                      widget.user.interests.map((interest) {
                                    int? index;
                                    for (var element in AppConfig.interests) {
                                      if (element.toLowerCase().trim() ==
                                          interest.toLowerCase().trim()) {
                                        index = AppConfig.interests
                                            .indexOf(element);
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        if (index != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ExplorePage(
                                                index: index,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(LocaleKeys
                                                  .theinterestisnotavailable
                                                  .tr()),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(AppConstants
                                                    .defaultNumericValue /
                                                2),
                                          ),
                                          color: AppConstants.primaryColor
                                              .withOpacity(0.1),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: AppConstants
                                                .defaultNumericValue,
                                            vertical: AppConstants
                                                    .defaultNumericValue /
                                                2),
                                        child: Text(interest[0].toUpperCase() +
                                            interest.substring(1)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue * 2),
                      ],
                    ))
                  ]),

              // Tab 2

              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SinglePhotoViewPage(
                                  images: widget.user.mediaFiles,
                                  title: LocaleKeys.photos.tr(),
                                  index: index,
                                ),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.user.mediaFiles[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                            errorWidget: (context, url, error) {
                              return const Center(
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        );
                      },
                      childCount: widget.user.mediaFiles.length,
                    ),
                  ),
                ],
              ),

              // Tab 3

              teelsListAsyncValue.when(
                data: (teelsList) {
                  final myTeels = teelsList
                      .where((element) =>
                          element.phoneNumber == widget.user.phoneNumber)
                      .toList();

                  if (myTeels.isEmpty) {
                    return CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                                child: NoItemFoundWidget(
                                    text: LocaleKeys.noFeedFound.tr())),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return CustomScrollView(
                      slivers: <Widget>[
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // number of columns
                            childAspectRatio: 0.6, // aspect ratio
                            crossAxisSpacing: 2, // horizontal spacing
                            mainAxisSpacing: 2, // vertical spacing
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  !(Responsive.isDesktop(context))
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VideoListScreen(
                                                    list: myTeels,
                                                    index: myTeels.indexOf(
                                                        myTeels[index]),
                                                    type: "video",
                                                    phoneNumber:
                                                        widget.user.phoneNumber,
                                                    soundId:
                                                        myTeels[index].soundId,
                                                  )))
                                      : ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(VideoListScreen(
                                            list: myTeels,
                                            index:
                                                myTeels.indexOf(myTeels[index]),
                                            type: "video",
                                            phoneNumber:
                                                widget.user.phoneNumber,
                                            soundId: myTeels[index].soundId,
                                          ));
                                },
                                child: GridTile(
                                  child: CachedNetworkImage(
                                    imageUrl: myTeels[index].thumbnail!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                                    errorWidget: (context, url, error) {
                                      return const Center(
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            childCount: teelsList.length - 1,
                          ),
                        ),
                      ],
                    );
                  }
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    const Center(child: Text('An error occurred!')),
              ),

              // Tab 4

              CustomScrollView(
                slivers: <Widget>[
                  feedList.when(
                    data: (feed) {
                      final myFeeds = feed
                          .where((element) =>
                              element.phoneNumber == widget.user.phoneNumber)
                          .toList();

                      if (myFeeds.isEmpty) {
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Center(
                                child: NoItemFoundWidget(
                                    text: LocaleKeys.noFeedFound.tr())),
                          ),
                        );
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final feeds = myFeeds[index];

                              return SingleFeedPost(
                                prefs: prefs,
                                feed: feeds,
                                user: widget.user,
                                currentUser: widget.currentUserProf,
                              );
                            },
                            childCount: myFeeds.length,
                          ),
                        );
                      }
                    },
                    error: (_, __) => SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                    ),
                    loading: () => SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              // Tab 5
              (widget.currentUserProf.subbedTo!.any((subscriber) =>
                          subscriber == widget.user.phoneNumber) ||
                      (boxMain.get('subbedToList') != null &&
                          boxMain.get('subbedToList').any((subscriber) =>
                              subscriber == widget.user.phoneNumber)))
                  ? CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: <Widget>[
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SinglePhotoViewPage(
                                          images: widget.user.subsFiles ?? [],
                                          index: index,
                                          title: LocaleKeys.images.tr()),
                                    ),
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.user.subsFiles![index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(),
                                  ),
                                  errorWidget: (context, url, error) {
                                    return const Center(
                                      child: Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: widget.user.subsFiles != null
                                ? widget.user.subsFiles!.length
                                : 0,
                          ),
                        ),
                      ],
                    )
                  : Column(children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppConstants.primaryColor,
                              width: 5,
                            )),
                        child: Center(
                          child: WebsafeSvg.asset(
                            height: 45,
                            width: 45,
                            fit: BoxFit.fitHeight,
                            crownIcon,
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
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text("Subscribers Only",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                          "Subscribe to ${widget.user.userName} to access exclusive content.",
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(
                        height: 20,
                      ),
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) {
                                return SubscriptionPage(
                                    user: widget.user,
                                    myProfile: widget.currentUserProf,
                                    myPhoneNumber: widget.myPhoneNumber,
                                    prefs: prefs);
                              },
                            );
                          },
                          child: Text(
                            LocaleKeys.subscribe.tr(),
                            style: TextStyle(
                                color: Teme.isDarktheme(prefs)
                                    ? AppConstants.secondaryColor
                                    : AppConstants.primaryColor),
                          ))
                    ]),
            ]),
          ),
        ));
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar, this.prefs);
  final TabBar tabBar;
  final SharedPreferences prefs;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Teme.isDarktheme(prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      child: Center(
        child: tabBar,
      ),
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

void profileMore(
  BuildContext context,
  ref,
) {
  // List of your pages
  List<Widget> pages = [
    const LiveStreamScreen(),
    const WalletPage(),
    const WalletPage(),
    const InteractionsPage(),
    const MatchesConsumerPage(),
    const ExplorePage(),
    const SecurityAndPrivacyLandingPage(),
    const PrivacyPolicyViewer(),
    const WebViewScreen(1),
    const WebViewScreen(4),
    // Add all your pages here
  ];
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
          child: ListView.builder(
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: WebsafeSvg.asset(
                    height: 36,
                    width: 36,
                    fit: BoxFit.fitHeight,
                    svgIcons[index]),
                title: Text(listText[index]),
                onTap: index != 10
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => pages[index]),
                        );
                      }
                    : () async {
                        EasyLoading.show(status: 'Logging out...');
                        final currentUserId =
                            ref.read(currentUserStateProvider)?.phoneNumber;

                        if (currentUserId != null) {
                          await ref
                              .read(userProfileNotifier)
                              .updateOnlineStatus(
                                  isOnline: false, phoneNumber: currentUserId);
                        }
                        await ref.read(authProvider).signOut();
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                      },
              );
            },
          ));
    },
  );
}

// List of your SVG icons
List<String> svgIcons = [
  liveIcon,
  walletIcon,
  liveIcon,
  walletIcon,
  liveIcon,
  walletIcon,
  liveIcon,
  walletIcon,
  liveIcon,
  walletIcon,
  // walletIcon,

  // Add all your SVG icons here
];

// List of your list text
List<String> listText = [
  'Go Live',
  "Wallet",
  "Rewards",
  "Likes",
  "Matches",
  "Find Me",
  "Security",
  "Privacy",
  "FAQ",
  "Customer Support",
  // "Logout",
  // Add all your list text here
];

Future<void> showBlockDialog(
    BuildContext context, String phoneNumber, String myPhoneNumber) async {
  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocaleKeys.block.tr()),
          content: Text(LocaleKeys.areyousureyouwanttoblockthisuser.tr()),
          actions: [
            TextButton(
              child: Text(LocaleKeys.cancel.tr()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer(builder: (context, ref, child) {
              return TextButton(
                child: Text(LocaleKeys.block.tr()),
                onPressed: () async {
                  EasyLoading.show(status: LocaleKeys.blocking.tr());

                  await blockUser(phoneNumber, myPhoneNumber).then((value) {
                    ref.invalidate(otherUsersProvider);
                    ref.invalidate(blockedUsersFutureProvider);
                    EasyLoading.dismiss();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  });
                },
              );
            }),
          ],
        );
      });
}
