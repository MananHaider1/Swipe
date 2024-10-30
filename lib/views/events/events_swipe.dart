import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/providers/event_interactions.dart';
import 'package:lamatdating/providers/events_provider.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/events/events.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/widgets/Subscriptions/subscription_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/settings/account_settings.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/home/notification_page.dart';
import 'package:lamatdating/views/tabs/home/user_card_widget.dart';

class EventSwipePage extends ConsumerStatefulWidget {
  bool isVerify;
  final SharedPreferences prefs;
  final UserProfileModel currentUserProf;
  final String typeEvent;
  EventSwipePage({
    super.key,
    this.isVerify = false,
    required this.prefs,
    required this.currentUserProf,
    required this.typeEvent,
  });

  @override
  ConsumerState<EventSwipePage> createState() => EventSwipePageState();
}

class EventSwipePageState extends ConsumerState<EventSwipePage> {
  String? myphoneNumber;
  UserProfileModel? currentUserProf;
  Box<dynamic>? box;
  List<UserProfileModel> users = [];

  @override
  void initState() {
    super.initState();
    currentUserProf = widget.currentUserProf;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      ),
    );

    return SizedBox(
        height: height,
        width: width,
        child: Consumer(builder: (context, ref, child) {
          final eventUsers =
              ref.watch(freeNumbersProvider(widget.typeEvent)).value;
          if (eventUsers != null && eventUsers.isNotEmpty) {
            for (var user in eventUsers) {
              if (user != currentUserProf!.phoneNumber) {
                final userRef = FirebaseFirestore.instance
                    .collection('userProfile')
                    .doc(user);
                userRef.get().then((value) {
                  if (value.exists) {
                    final userProfile =
                        UserProfileModel.fromMap(value.data() ?? {});
                    if (userProfile.gender != currentUserProf!.gender) {
                      if (widget.isVerify) {
                        if (userProfile.isVerified) {
                          users.add(userProfile);
                        }
                      } else {
                        users.add(userProfile);
                      }
                    }
                  }
                });
              }
            }
          }

          if (users.isNotEmpty) {
            debugPrint("filteredOtherUsersProvider: ${users.length}");

            users.sort((a, b) {
              if (b.isBoosted && !a.isBoosted) return 1;
              if (!b.isBoosted && a.isBoosted) return -1;
              return 0;
            });
          }

          return users.isEmpty
              ? Container(
                  color: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  child: const Center(
                      child: NoItemFoundWidget(
                          text: "No users in event yet", isSmall: true)),
                )
              : SubscriptionBuilder(
                  builder: (context, isPremiumUser) {
                    return FilterInteraction(
                      typeEvent: widget.typeEvent,
                      currentUserProf: currentUserProf!,
                      prefs: widget.prefs,
                      isPremiumUser:
                          isPremiumUser || currentUserProf!.isPremium!,
                      users: users,
                      onNavigateBack: () async {},
                    );
                  },
                );
        }));
  }
}

class NotificationButton extends ConsumerWidget {
  const NotificationButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final matchingNotifications = ref.watch(notificationsStreamProvider);
    // final prefs = ref.watch(sharedPreferencesProvider).value;

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
          color: AppConstants.primaryColor,
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
              label: Text(
                count.toString(),
              ),
            ),
          ),
      ],
    );
  }
}

class FilterInteraction extends ConsumerWidget {
  final UserProfileModel currentUserProf;
  final SharedPreferences prefs;
  final String typeEvent;
  final bool isPremiumUser;
  final List<UserProfileModel> users;
  final VoidCallback? onNavigateBack;
  const FilterInteraction({
    super.key,
    required this.currentUserProf,
    required this.isPremiumUser,
    required this.users,
    this.onNavigateBack,
    required this.prefs,
    required this.typeEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionProvider =
        ref.watch(eventInteractionFutureProvider(typeEvent));
    List<UserProfileModel> filteredUsers = [];
    // List<UserInteractionModel>? interactionsToday;
    DateTime ntpTimeUtc = DateTime.now().toUtc();
    // final closestUsers = ref.watch(closestUsersProvider(ref));
    final myInterests = currentUserProf.interests;

    return interactionProvider.when(
        data: (data) {
          // List<UserProfileModel> filteredUsers = [];
          if (!kDebugMode) {
            for (UserProfileModel user in users) {
              if (!data.any((element) =>
                  element.intractToUserId.contains(user.phoneNumber))) {
                final userCollection = FirebaseFirestore.instance
                    .collection(FirebaseConstants.userProfileCollection);

                if (user.isBoosted == true) {
                  final boostType = user.boostType;
                  final boostedTime =
                      DateTime.fromMillisecondsSinceEpoch(user.boostedOn!);
                  Duration boostDuration = ntpTimeUtc.difference(boostedTime);
                  if ((boostType == AppRes.daily &&
                          boostDuration > const Duration(hours: 24)) ||
                      (boostType == AppRes.weekly &&
                          boostDuration > const Duration(hours: 168)) ||
                      (boostType == AppRes.monthly &&
                          boostDuration > const Duration(hours: 720))) {
                    final newUserProf = user.copyWith(isBoosted: false);
                    user = newUserProf;

                    userCollection
                        .doc(newUserProf.phoneNumber)
                        .set(newUserProf.toMap(), SetOptions(merge: true));

                    debugPrint("NewCachedOtherUsersProvider: Boost Expired");
                  }
                }
                filteredUsers.add(user);
              }
            }
          } else {
            for (UserProfileModel user in users) {
              // final currentTime = ntpTime!;

              final userCollection = FirebaseFirestore.instance
                  .collection(FirebaseConstants.userProfileCollection);

              if (user.isBoosted == true) {
                final boostType = user.boostType;
                final boostedTime =
                    DateTime.fromMillisecondsSinceEpoch(user.boostedOn!);
                Duration boostDuration = ntpTimeUtc.difference(boostedTime);
                if ((boostType == AppRes.daily &&
                        boostDuration > const Duration(hours: 24)) ||
                    (boostType == AppRes.weekly &&
                        boostDuration > const Duration(hours: 168)) ||
                    (boostType == AppRes.monthly &&
                        boostDuration > const Duration(hours: 720))) {
                  final newUserProf = user.copyWith(isBoosted: false);
                  user = newUserProf;

                  userCollection
                      .doc(newUserProf.phoneNumber)
                      .set(newUserProf.toMap(), SetOptions(merge: true));

                  debugPrint("NewCachedOtherUsersProvider: Boost Expired");
                }
              }
              filteredUsers.add(user);
            }
          }

          List<ClosestUser> closestUsers = [];

          final UserAccountSettingsModel mySettings =
              currentUserProf.userAccountSettingsModel;

          for (var user in filteredUsers) {
            final userLocation = user.userAccountSettingsModel.location;

            double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                    mySettings.location.latitude,
                    mySettings.location.longitude,
                    userLocation.latitude,
                    userLocation.longitude) /
                1;

            closestUsers.add(
                ClosestUser(user: user, distance: distanceBetweenMeAndUser));
          }

          closestUsers.sort((a, b) => a.distance.compareTo(b.distance));

          // final List<SimilarUser> mostSimilarProfiles = [];
          for (var user in closestUsers) {
            final otherInterest = user.user.interests;
            double similarity = 0.0;
            for (final interest in myInterests) {
              if (otherInterest.contains(interest)) {
                similarity + 1;
              }
            }
            final index = closestUsers.indexOf(user);

            // update the user at index of the list with the similarity

            closestUsers[index] = ClosestUser(
                user: user.user, distance: user.distance - similarity);
          }

          filteredUsers = closestUsers.map((e) => e.user).toList();

          filteredUsers.sort((a, b) {
            if (b.isBoosted && !a.isBoosted) return 1;
            if (!b.isBoosted && a.isBoosted) return -1;
            return 0;
          });

          debugPrint("interactionFutureProvider: ${filteredUsers.length}");

          // Freemium Limitations
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final interactionsToday = data
              .where((element) => element.createdAt.isAfter(today))
              .toList();

          return closestUsers.isEmpty
              ? Container(
                  color: Teme.isDarktheme(prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  child: const Center(
                      child: NoItemFoundWidget(
                          text: "No Close By Users", isSmall: true)),
                )
              : HomeBody(
                  prefs: prefs,
                  currentUserProf: currentUserProf,
                  users: filteredUsers,
                  isPremiumUser: isPremiumUser || currentUserProf.isPremium!,
                  interactionsToday: interactionsToday,
                  onNavigateBack: onNavigateBack,
                  eventType: typeEvent,
                );
        },
        error: (_, e) => Center(
              child: Text(LocaleKeys.somethingWentWrong.tr() + e.toString()),
            ),
        loading: () {
          return Center(
              child: NoItemFoundWidget(
                  text: LocaleKeys.nousersfound.tr(), isSmall: true));
        }
        // : HomeBody(
        //     prefs: prefs,
        //     users: filteredUsers,
        //     isPremiumUser: isPremiumUser,
        //     interactionsToday: interactionsToday!,
        //     onNavigateBack: onNavigateBack,
        //   ),
        );
  }
}

class HomeBody extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final UserProfileModel currentUserProf;
  final List<UserProfileModel> users;
  final List<UserInteractionModel> interactionsToday;
  final bool isPremiumUser;
  final VoidCallback? onNavigateBack;
  final String eventType;
  const HomeBody({
    super.key,
    required this.isPremiumUser,
    required this.currentUserProf,
    required this.users,
    required this.interactionsToday,
    this.onNavigateBack,
    required this.prefs,
    required this.eventType,
  });

  @override
  ConsumerState<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<HomeBody> {
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  List<String> userIds = [];

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  // bool isLiking = false;
  // bool isDisliking = false;
  bool isSuperliking = false;
  bool isSuperLike = false;
  bool isSwipeRight = false;
  bool isSwipeLeft = false;
  bool canLike = true;
  bool canDislike = true;
  bool canSuperLike = true;
  UserProfileModel? userProf;
  UserInteractionModel? interaction;
  Box<dynamic>? box;
  DateTime? _ntpTime;

  String method = "";

  @override
  void initState() {
    // final users = widget.users;
    // users.shuffle();
    // box = Hive.box(HiveConstants.hiveBox);
    // final user = box!.get(HiveConstants.currentUserProf);
    // currentUserProf = UserProfileModel.fromJson(user);

    for (var user in widget.users) {
      _swipeItems.add(
        SwipeItem(
          content: user,
          likeAction: () async {
            ref.invalidate(arrangementProvider);
            ref.read(isToggledProvider.notifier).state = true;
            if (canLike) {
              _matchEngine.currentItem?.like();
              final newInteraction = interaction!
                  .copyWith(isLike: true, createdAt: DateTime.now());
              await createEventInteraction(newInteraction, widget.eventType)
                  .then((result) async {
                if (result) {
                  await getExistingInteraction(
                          user.phoneNumber,
                          widget.prefs.getString(Dbkeys.phone)!,
                          widget.eventType)
                      .then((otherUserInteraction) {
                    if (otherUserInteraction != null) {
                      showMatchingDialog(
                          context: context,
                          currentUser: userProf!,
                          otherUser: user);
                    } else {
                      createInteractionNotification(
                          title: LocaleKeys.youhaveanewInteraction.tr(),
                          body:
                              "${user.fullName} ${LocaleKeys.hasLikedYourProfileYouShouldCheckTheirProfile.tr()}",
                          receiverId: user.phoneNumber,
                          currentUser: userProf!);
                    }
                  });
                }
              });

              // if (_isInterstitialAdLoaded) {
              //   _interstitialAd?.show();
              //   _isInterstitialAdLoaded = false;
              // }
            } else {
              EasyLoading.showError(
                  LocaleKeys.youhavereachedyourdailylimitoflikes.tr());
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(
              //       LocaleKeys
              //           .youhavereachedyourdailylimitoflikes
              //           .tr(),
              //     ),
              //   ),
              // );
            }
            ref.read(isToggledProvider.notifier).state = false;

            // (canLike == true)
            //     ? _matchEngine.currentItem!.like()
            //     : EasyLoading.showError(
            //         LocaleKeys.youhavereachedyourdailylimitoflikes.tr());
          },
          nopeAction: () async {
            ref.invalidate(arrangementProvider);
            ref.read(isToggledNopeProvider.notifier).state = true;
            if (canDislike) {
              _matchEngine.currentItem!.nope();
              final newInteraction = interaction!
                  .copyWith(isDislike: true, createdAt: DateTime.now());
              await createEventInteraction(newInteraction, widget.eventType);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LocaleKeys.youhavereachedyourdailylimitofdislikes.tr(),
                  ),
                ),
              );
            }
            ref.read(isToggledNopeProvider.notifier).state = false;
          },
          superlikeAction: () async {
            ref.invalidate(arrangementProvider);
            ref.read(isToggledSuperProvider.notifier).state = true;

            if (canSuperLike) {
              _matchEngine.currentItem?.superLike();
              final newInteraction = interaction!
                  .copyWith(isSuperLike: true, createdAt: DateTime.now());

              await createEventInteraction(newInteraction, widget.eventType)
                  .then((result) async {
                if (result) {
                  await getExistingInteraction(user.phoneNumber,
                          userProf!.phoneNumber, widget.eventType)
                      .then((otherUserInteraction) {
                    if (otherUserInteraction != null) {
                      showMatchingDialog(
                          context: context,
                          currentUser: userProf!,
                          otherUser: user);
                    } else {
                      createInteractionNotification(
                          title: LocaleKeys.youhaveanewInteraction.tr(),
                          body:
                              "${user.fullName} ${LocaleKeys.hasLikedYourProfileYouShouldCheckTheirProfile.tr()}",
                          receiverId: user.phoneNumber,
                          currentUser: userProf!);
                    }
                  });
                }
              });

              // if (_isInterstitialAdLoaded) {
              //   _interstitialAd?.show();
              //   _isInterstitialAdLoaded = false;
              // }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    LocaleKeys.youhavereachedyourdailylimitofsuperlikes.tr(),
                  ),
                ),
              );
            }
            ref.read(isToggledSuperProvider.notifier).state = false;
          },
        ),
      );
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);

    if (!widget.isPremiumUser || widget.currentUserProf.isPremium!) {
      if (isAdmobAvailable) {
        if (!kIsWeb) {
          InterstitialAd.load(
            adUnitId: Platform.isAndroid
                ? AndroidAdUnits.interstitialId
                : IOSAdUnits.interstitialId,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                setState(() {
                  _interstitialAd = ad;
                  _isInterstitialAdLoaded = true;
                });
              },
              onAdFailedToLoad: (error) {},
            ),
          );
        }
      }
    }

    super.initState();
    _getNTPTime();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   for (var user in widget.users) {
  //     for (var imageUrl in user.mediaFiles) {
  //       await precacheImage(NetworkImage(imageUrl), context);
  //     }
  //   }
  // }

  Future<void> _getNTPTime() async {
    _ntpTime = DateTime.now().toUtc();
    setState(() {}); // Trigger UI rebuild
  }

  void saveUserId(String phoneNumber) {
    userIds.add(phoneNumber);
  }

  void deleteLastUserId() {
    if (userIds.isNotEmpty) {
      userIds.removeLast();
    }
  }

  String getLastUserId() {
    if (userIds.isNotEmpty) {
      return userIds.last;
    }
    return ""; // Return null or handle the case when the list is empty
  }

  @override
  void dispose() {
    _matchEngine.dispose();
    super.dispose();
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

  final PageController _pageController = PageController();

  void showMatchingDialog({
    required BuildContext context,
    required UserProfileModel currentUser,
    required UserProfileModel otherUser,
  }) async {
    final MatchModel matchModel = MatchModel(
      id: currentUser.phoneNumber + otherUser.phoneNumber,
      userIds: [currentUser.phoneNumber, otherUser.phoneNumber],
      isMatched: true,
    );
    // final cachedModel = DataModel(widget.prefs.getString(Dbkeys.phone));
    // final images = otherUser.mediaFiles;

    await createConversation(matchModel).then((matchResult) async {
      final cachedModel = DataModel(widget.prefs.getString(Dbkeys.phone));
      final images = otherUser.mediaFiles;
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
                    height: MediaQuery.of(context).size.height * .9,
                    decoration: BoxDecoration(
                      color: Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor,
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
                                                _pageController, // PageController
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
                                              _pageController.animateToPage(
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
                      // header: widget.user.isOnline
                      //     ? const Align(
                      //         alignment: Alignment.topCenter,
                      //         child: Padding(
                      //           padding: EdgeInsets.all(8),
                      //           child: OnlineStatus(),
                      //         ),
                      //       )
                      //     : const SizedBox(),
                      footer: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultNumericValue / 3),
                        decoration: BoxDecoration(
                            color: Teme.isDarktheme(widget.prefs)
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
                                        child: Text(LocaleKeys.notNow.tr())))),
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
                                              prefs: widget.prefs,
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
                                                prefs: widget.prefs,
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
                                      child: GifView.asset(itsAMatch,
                                          // color: AppConstants.primaryColor,
                                          width:
                                              Responsive.isMobile(context)
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
                                      ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Teme.isDarktheme(widget.prefs)
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
                                          width:
                                              Responsive.isMobile(context)
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
                                      ),
                                )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue / 2)),
                              child: Stack(
                                children: [
                                  PageView(
                                    controller: _pageController,
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
                                              borderRadius: BorderRadius
                                                  .circular(AppConstants
                                                          .defaultNumericValue /
                                                      2),
                                              child: CachedNetworkImage(
                                                imageUrl: e,
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (context, loadingProgress) {
                                                  return Center(
                                                    child: Lottie.asset(
                                                        loadingDiam,
                                                        fit: BoxFit.cover,
                                                        width: 60,
                                                        height: 60,
                                                        repeat: true),
                                                  );
                                                },
                                                errorWidget: (context, error,
                                                    stackTrace) {
                                                  return const Center(
                                                      child: Icon(CupertinoIcons
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
                                                      _pageController.previousPage(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          curve:
                                                              Curves.easeInOut);
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _pageController.nextPage(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          curve:
                                                              Curves.easeInOut);
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
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
                                        ),
                                  )
                                ],
                              )),
                    )

                    // Stack(
                    //   children: [
                    //     Column(
                    //       children: [
                    //         Center(child: Text(LocaleKeys.matched.tr())),
                    //         const SizedBox(
                    //             height: AppConstants.defaultNumericValue),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             UserCirlePicture(
                    //                 imageUrl: otherUser.profilePicture, size: 40),
                    //             const SizedBox(
                    //                 width: AppConstants.defaultNumericValue / 4),
                    //             UserCirlePicture(
                    //                 imageUrl: currentUser.profilePicture,
                    //                 size: 40),
                    //           ],
                    //         ),
                    //         const SizedBox(
                    //             height: AppConstants.defaultNumericValue),
                    //         Center(
                    //           child: Text(
                    //               "${LocaleKeys.youarenowmatchedwith.tr()}${otherUser.fullName}"),
                    //         ),
                    //         const SizedBox(
                    //             height: AppConstants.defaultNumericValue),
                    //         Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Expanded(
                    //                 child: OutlinedButton(
                    //                     onPressed: () {
                    //                       Navigator.of(context).pop();
                    //                     },
                    //                     child: Text(LocaleKeys.notNow.tr()))),
                    //             const SizedBox(
                    //                 width: AppConstants.defaultNumericValue),
                    //             Expanded(
                    //               child: ElevatedButton(
                    //                   onPressed: () {
                    //                     Navigator.of(context).pop();
                    //                     Navigator.of(context).push(
                    //                       MaterialPageRoute(
                    //                         builder: (context) => PreChat(
                    //                           name: otherUser.fullName,
                    //                           phone: otherUser.phoneNumber,
                    //                           currentUserNo: ref
                    //                               .watch(
                    //                                   currentUserStateProvider)!
                    //                               .phoneNumber,
                    //                           model: cachedModel,
                    //                           prefs: widget.prefs,
                    //                         ),
                    //                       ),
                    //                     );
                    //                     // Navigator.of(context).push(
                    //                     //   MaterialPageRoute(
                    //                     //     builder: (context) => ChatPage(
                    //                     //       matchId: matchModel.id,
                    //                     //       otherUserId: otherUser.phoneNumber,
                    //                     //     ),
                    //                     //   ),
                    //                     // );
                    //                   },
                    //                   child: Text(LocaleKeys.startChat.tr())),
                    //             ),
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // )
                    ),
              );
            },
          );
        });
      }
    });
  }

  int refreshed = 1;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    // final isRefreshed = ref.watch(isNewInteractionListFutureProvider);
    final isToggledLike = ref.watch(isToggledProvider);
    final isToggledNope = ref.watch(isToggledNopeProvider);
    final isToggledSuper = ref.watch(isToggledSuperProvider);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // Check limits

    int totalLiked = widget.interactionsToday
        .where((element) => element.isLike)
        .toList()
        .length;

    int totalSuperLiked = widget.interactionsToday
        .where((element) => element.isSuperLike)
        .toList()
        .length;

    int totalDisliked = widget.interactionsToday
        .where((element) => element.isDislike)
        .toList()
        .length;

    // bool canLike = true;
    // bool canSuperLike = true;
    // bool canDislike = true;

    if (widget.isPremiumUser || widget.currentUserProf.isPremium!) {
      if (FreemiumLimitation.maxDailyLikeLimitPremium != 0 &&
          totalLiked >= FreemiumLimitation.maxDailyLikeLimitPremium) {
        canLike = false;
      }

      if (FreemiumLimitation.maxDailySuperLikeLimitPremium != 0 &&
          totalSuperLiked >= FreemiumLimitation.maxDailySuperLikeLimitPremium) {
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
          totalSuperLiked >= FreemiumLimitation.maxDailySuperLikeLimitFree) {
        canSuperLike = false;
      }

      if (FreemiumLimitation.maxDailyDislikeLimitFree != 0 &&
          totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitFree) {
        canDislike = false;
      }
    }
    return (_swipeItems.isEmpty)
        ? HomePageNoUsersFoundWidget(
            eventType: widget.eventType,
            phone: widget.currentUserProf.phoneNumber)
        : Center(
            child: SizedBox(
                height: height,
                width: width,
                child: Stack(
                  children: [
                    SwipeCards(
                      leftSwipeAllowed: true,
                      rightSwipeAllowed: true,
                      upSwipeAllowed: true,
                      likeTag: Positioned(
                        top: 0,
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Lottie.asset(
                            // height: 500,
                            width: Responsive.isDesktop(context)
                                ? width * .25
                                : width,
                            fit: BoxFit.fitWidth,
                            niceAnim2,
                            repeat: true,
                            reverse: true,
                            animate: kDebugMode ? false : true,
                          ),
                        ),
                      ),
                      nopeTag: Positioned(
                        top: height * .1,
                        right: width * .02,
                        child: Lottie.asset(
                          height: 150,
                          nopeAnim2,
                          repeat: true,
                          reverse: true,
                          animate: kDebugMode ? false : true,
                        ),
                      ),
                      matchEngine: _matchEngine,
                      itemChanged: (p0, p1) {
                        if (p1 == 10) {
                          if (_isInterstitialAdLoaded) {
                            _interstitialAd?.show();
                            _isInterstitialAdLoaded = false;
                          }
                        }
                      },
                      onStackFinished: () async {
                        // await box!.put(HiveConstants.lastUpdatedKey,
                        //     DateTime.now().subtract(const Duration(days: 2)));
                        // ref.invalidate(interactionFutureProvider);
                        ref.invalidate(arrangementProvider);
                        // ref.watch(filteredOtherUsersProvider(ref));
                        // ref.read(nextUsersProvider.notifier).state = true;
                        // final profiles =
                        //     ref.refresh(filteredOtherUsersProvider(ref)).value;
                        // await box!.put(HiveConstants.cachedProfiles, profiles);
                      },
                      itemBuilder: (context, index) {
                        final user =
                            _swipeItems[index].content as UserProfileModel;

                        userProf = user;

                        final String myPhoneNumber =
                            ref.watch(currentUserStateProvider)!.phoneNumber!;
                        final String id = myPhoneNumber + user.phoneNumber;

                        interaction = UserInteractionModel(
                          id: id,
                          phoneNumber: myPhoneNumber,
                          intractToUserId: user.phoneNumber,
                          isSuperLike: false,
                          isLike: false,
                          isDislike: false,
                          createdAt: DateTime.now(),
                        );

                        return UserCardWidget(
                          currentUserProf: widget.currentUserProf,
                          prefs: widget.prefs,
                          onNavigateBack: widget.onNavigateBack,
                          user: _swipeItems[index].content,
                          onTapRewind: () async {
                            if (widget.isPremiumUser ||
                                widget.currentUserProf.isPremium!) {
                              await deleteInteraction(
                                      getLastUserId(), widget.eventType)
                                  .then((value) {
                                // ref.invalidate(interactionFutureProvider);
                              });
                              deleteLastUserId();
                              _matchEngine.rewindMatch();
                            }
                          },
                          onTapBolt: () async {
                            ref.invalidate(arrangementProvider);
                            ref.read(isToggledSuperProvider.notifier).state =
                                true;
                            if (canSuperLike) {
                              _matchEngine.currentItem?.superLike();
                              final newInteraction = interaction!.copyWith(
                                  isSuperLike: true, createdAt: DateTime.now());

                              await createEventInteraction(
                                      newInteraction, widget.eventType)
                                  .then((result) async {
                                if (result) {
                                  await getExistingInteraction(user.phoneNumber,
                                          myPhoneNumber, widget.eventType)
                                      .then((otherUserInteraction) {
                                    if (otherUserInteraction != null) {
                                      showMatchingDialog(
                                          context: context,
                                          currentUser: widget.currentUserProf,
                                          otherUser: user);
                                    } else {
                                      createInteractionNotification(
                                          title: LocaleKeys
                                              .youhaveanewInteraction
                                              .tr(),
                                          body:
                                              "${user.fullName} ${LocaleKeys.hasLikedYourProfileYouShouldCheckTheirProfile.tr()}",
                                          receiverId: user.phoneNumber,
                                          currentUser: widget.currentUserProf);
                                    }
                                  });
                                }
                              });
                              Future.delayed(const Duration(seconds: 0), () {
                                ref
                                    .read(isToggledSuperProvider.notifier)
                                    .state = false;
                              });
                              // ref.read(isToggledSuperProvider.notifier).state = false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys
                                        .youhavereachedyourdailylimitofsuperlikes
                                        .tr(),
                                  ),
                                ),
                              );
                            }
                          },
                          onTapCross: () async {
                            ref.invalidate(arrangementProvider);
                            ref.read(isToggledNopeProvider.notifier).state =
                                true;
                            if (canDislike) {
                              _matchEngine.currentItem?.nope();
                              final newInteraction = interaction!.copyWith(
                                  isDislike: true, createdAt: DateTime.now());
                              await createEventInteraction(
                                  newInteraction, widget.eventType);
                              Future.delayed(const Duration(seconds: 1), () {
                                ref.read(isToggledNopeProvider.notifier).state =
                                    false;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys
                                        .youhavereachedyourdailylimitofdislikes
                                        .tr(),
                                  ),
                                ),
                              );
                            }
                          },
                          onTapHeart: () async {
                            // showMatchingDialog(
                            //               context: context,
                            //               currentUser: widget.currentUserProf,
                            //               otherUser: user);
                            ref.invalidate(arrangementProvider);
                            ref.read(isToggledProvider.notifier).state = true;
                            if (canLike) {
                              _matchEngine.currentItem?.like();
                              final newInteraction = interaction!.copyWith(
                                  isLike: true, createdAt: DateTime.now());
                              await createEventInteraction(
                                      newInteraction, widget.eventType)
                                  .then((result) async {
                                if (result) {
                                  await getExistingInteraction(user.phoneNumber,
                                          myPhoneNumber, widget.eventType)
                                      .then((otherUserInteraction) {
                                    if (otherUserInteraction != null) {
                                      showMatchingDialog(
                                          context: context,
                                          currentUser: widget.currentUserProf,
                                          otherUser: user);
                                    } else {
                                      createInteractionNotification(
                                          title: LocaleKeys
                                              .youhaveanewInteraction
                                              .tr(),
                                          body:
                                              "${user.fullName} ${LocaleKeys.hasLikedYourProfileYouShouldCheckTheirProfile.tr()}",
                                          receiverId: user.phoneNumber,
                                          currentUser: widget.currentUserProf);
                                    }
                                  });
                                }
                              });

                              ref.read(isToggledProvider.notifier).state =
                                  false;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys
                                        .youhavereachedyourdailylimitoflikes
                                        .tr(),
                                  ),
                                ),
                              );
                            }
                          },
                          onTapBoost: () async {
                            ref.invalidate(arrangementProvider);
                            if (widget.currentUserProf.isBoosted == false &&
                                widget.currentUserProf.boostBalance >
                                    oneBoostCost.round()) {
                              // final timeNow = _ntpTime;
                              final newUserProfileModel = widget.currentUserProf
                                  .copyWith(
                                      boostBalance:
                                          widget.currentUserProf.boostBalance -
                                              1,
                                      isBoosted: true,
                                      boostedOn:
                                          _ntpTime!.millisecondsSinceEpoch,
                                      boostType: AppRes.daily);

                              await ref
                                  .read(userProfileNotifier)
                                  .updateUserProfile(newUserProfileModel)
                                  .then((value) {
                                EasyLoading.showSuccess(
                                    LocaleKeys.success.tr());
                              });
                            } else if (widget.currentUserProf.isBoosted ==
                                true) {
                              EasyLoading.showSuccess("Boosted Already");
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onVerticalDragDown: (details) {},
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: height * .05,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: AppConstants
                                                          .defaultNumericValue),
                                              child: CustomAppBar(
                                                leading: CustomIconButton(
                                                    padding: const EdgeInsets
                                                        .all(AppConstants
                                                                .defaultNumericValue /
                                                            1.5),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    color: AppConstants
                                                        .primaryColor,
                                                    icon: closeIcon),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * .03,
                                            ),
                                            Center(
                                              child: Text(
                                                LocaleKeys.beseenfirst.tr(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * .02,
                                            ),
                                            Text(
                                              LocaleKeys.beatopprofilein.tr(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(
                                              height: height * .02,
                                            ),
                                            CarouselSlider(
                                              options: CarouselOptions(
                                                height: height * .42,
                                                enableInfiniteScroll: false,
                                              ),
                                              items: [
                                                {
                                                  'category': LocaleKeys
                                                      .cheapest
                                                      .tr()
                                                      .toUpperCase(),
                                                  'title':
                                                      '1 ${LocaleKeys.boost.tr()}',
                                                  'description':
                                                      oneBoostCost.toString(),
                                                  'save':
                                                      "${LocaleKeys.no.tr()} ${LocaleKeys.save.tr()}",
                                                  'color': Teme.isDarktheme(
                                                          widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                },
                                                {
                                                  'category': LocaleKeys.popular
                                                      .tr()
                                                      .toUpperCase(),
                                                  'title':
                                                      '$popularBoostAmount ${LocaleKeys.boosts.tr()}',
                                                  'description':
                                                      popularBoostCost
                                                          .toString(),
                                                  'save':
                                                      '${LocaleKeys.save.tr()} ${100 - ((popularBoostCost / (oneBoostCost * popularBoostAmount) * 100)).round()}%'
                                                          .toUpperCase(),
                                                  'color': Teme.isDarktheme(
                                                          widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                },
                                                {
                                                  'category': LocaleKeys
                                                      .bestValue
                                                      .tr()
                                                      .toUpperCase(),
                                                  'title':
                                                      '$bestValueBoostAmount ${LocaleKeys.boosts.tr()}',
                                                  'description':
                                                      bestValueCost.toString(),
                                                  'save':
                                                      '${LocaleKeys.save.tr()} ${100 - ((bestValueCost / (oneBoostCost * bestValueBoostAmount) * 100)).round()}%'
                                                          .toUpperCase(),
                                                  'color': Teme.isDarktheme(
                                                          widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                },
                                                // Add more items here
                                              ].map<Widget>(
                                                  (Map<String, dynamic> item) {
                                                return Builder(
                                                  builder:
                                                      (BuildContext context) {
                                                    return Container(
                                                      width: width,
                                                      height: height * .4,
                                                      margin: const EdgeInsets
                                                          .all(AppConstants
                                                              .defaultNumericValue),
                                                      decoration: BoxDecoration(
                                                        color: item['color'],
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 1.0,
                                                        ),
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.1),
                                                            spreadRadius: 10.0,
                                                            blurRadius: 25.0,
                                                            offset: const Offset(
                                                                0,
                                                                0), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height:
                                                                  height * .06,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppConstants
                                                                    .primaryColor
                                                                    .withOpacity(
                                                                        .1),
                                                                borderRadius: const BorderRadius
                                                                    .only(
                                                                    topLeft: Radius.circular(
                                                                        AppConstants.defaultNumericValue *
                                                                            .95),
                                                                    topRight: Radius.circular(
                                                                        AppConstants.defaultNumericValue *
                                                                            .95)),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                    item[
                                                                        'category'],
                                                                    style: const TextStyle(
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              )),
                                                          SizedBox(
                                                            height:
                                                                height * .02,
                                                          ),
                                                          Text(item['title'],
                                                              style: const TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                            height:
                                                                height * .02,
                                                          ),
                                                          Text(item[
                                                              'description']),
                                                          SizedBox(
                                                            height:
                                                                height * .01,
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                    AppConstants
                                                                            .defaultNumericValue /
                                                                        2,
                                                                horizontal:
                                                                    AppConstants
                                                                        .defaultNumericValue),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppConstants
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      .1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          AppConstants.defaultNumericValue *
                                                                              2),
                                                            ),
                                                            child: Text(
                                                                item['save'],
                                                                style: const TextStyle(
                                                                    color: AppConstants
                                                                        .primaryColor,
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                height * .02,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                  child:
                                                                      Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        AppConstants
                                                                            .defaultNumericValue),
                                                                child:
                                                                    CustomButton(
                                                                        onPressed:
                                                                            () async {
                                                                          EasyLoading
                                                                              .show();
                                                                          try {
                                                                            await minusBalanceProvider(
                                                                                    ref,
                                                                                    (item['category'] == LocaleKeys.cheapest.tr().toUpperCase())
                                                                                        ? oneBoostCost.toDouble()
                                                                                        : (item['category'] == LocaleKeys.popular.tr().toUpperCase())
                                                                                            ? popularBoostCost.toDouble()
                                                                                            : bestValueCost.toDouble())
                                                                                .then((value) async {
                                                                              final newUserProfileModel = widget.currentUserProf.copyWith(
                                                                                boostBalance: (item['category'] == LocaleKeys.cheapest.tr().toUpperCase())
                                                                                    ? widget.currentUserProf.boostBalance + 1
                                                                                    : (item['category'] == LocaleKeys.popular.tr().toUpperCase())
                                                                                        ? widget.currentUserProf.boostBalance + popularBoostAmount
                                                                                        : widget.currentUserProf.boostBalance + bestValueBoostAmount,
                                                                              );
                                                                              (value)
                                                                                  ? {
                                                                                      await ref.read(userProfileNotifier).updateUserProfile(newUserProfileModel).then((value) {
                                                                                        EasyLoading.dismiss();
                                                                                        ref.invalidate(userProfileFutureProvider);
                                                                                        // Navigator.pop(context);
                                                                                      })
                                                                                    }
                                                                                  : {
                                                                                      EasyLoading.showError(LocaleKeys.purchaseFailed.tr())
                                                                                    };
                                                                            });
                                                                          } catch (e) {
                                                                            EasyLoading.dismiss(); // Hide loading indicator
                                                                            if (kDebugMode) {
                                                                              showERRORSheet(context, e.toString());
                                                                            }
                                                                          }

                                                                          EasyLoading
                                                                              .dismiss();
                                                                        },
                                                                        text: LocaleKeys
                                                                            .select
                                                                            .tr()
                                                                            .toUpperCase()),
                                                              )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const SizedBox(
                                                  width: AppConstants
                                                      .defaultNumericValue,
                                                ),
                                                Container(
                                                  height: 1,
                                                  width: width / 2.5,
                                                  color: Colors.grey,
                                                ),
                                                Text(
                                                  LocaleKeys.or.tr(),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey),
                                                ),
                                                Container(
                                                  height: 1,
                                                  width: width / 2.5,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(
                                                  width: AppConstants
                                                      .defaultNumericValue,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: width,
                                              height: height * .2,
                                              margin: const EdgeInsets.all(
                                                  AppConstants
                                                      .defaultNumericValue),
                                              decoration: BoxDecoration(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(AppConstants
                                                        .defaultNumericValue),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.1),
                                                    spreadRadius: 10.0,
                                                    blurRadius: 25.0,
                                                    offset: const Offset(0,
                                                        0), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height: height * .06,
                                                      decoration: BoxDecoration(
                                                        color: AppConstants
                                                            .primaryColor
                                                            .withOpacity(.1),
                                                        borderRadius: const BorderRadius
                                                            .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    AppConstants
                                                                            .defaultNumericValue *
                                                                        .95),
                                                            topRight:
                                                                Radius.circular(
                                                                    AppConstants
                                                                            .defaultNumericValue *
                                                                        .95)),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                            '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                                                            style: const TextStyle(
                                                                color: AppConstants
                                                                    .primaryColor,
                                                                fontSize: 16.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      )),
                                                  SizedBox(
                                                    height: height * .02,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Image.asset(
                                                        AppConstants.logo,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      Text(
                                                        LocaleKeys.getgold.tr(),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SubscriptionBuilder(
                                                          builder: (context,
                                                              isPremiumUser) {
                                                        return isPremiumUser ||
                                                                widget
                                                                    .currentUserProf
                                                                    .isPremium!
                                                            ? const SizedBox()
                                                            : Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        AppConstants
                                                                            .defaultNumericValue),
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () {
                                                                    // SubscriptionBuilder.showSubscriptionBottomSheet(context: context);
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (context) => Container(
                                                                          decoration: BoxDecoration(color: AppConstants.backgroundColor, borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                          height: height * .6,
                                                                          width: width * .8,
                                                                          margin: EdgeInsets.symmetric(horizontal: width * .05, vertical: height * .1),
                                                                          child: Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Center(
                                                                                  child: Text(
                                                                                LocaleKeys.upgradetoGold.tr(),
                                                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFFE9A238)),
                                                                              )),
                                                                              Center(
                                                                                child: AppRes.appLogo != null
                                                                                    ? CachedNetworkImage(
                                                                                        imageUrl: AppRes.appLogo!,
                                                                                        width: 150,
                                                                                        height: 150,
                                                                                        fit: BoxFit.contain,
                                                                                      )
                                                                                    : Image.asset(
                                                                                        AppConstants.logo,
                                                                                        color: AppConstants.primaryColor,
                                                                                        width: 150,
                                                                                        height: 150,
                                                                                        fit: BoxFit.contain,
                                                                                      ),
                                                                              ),
                                                                              Center(
                                                                                  child: Text(
                                                                                '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 18,
                                                                                ),
                                                                              )),
                                                                              Center(
                                                                                  child: Text(
                                                                                LocaleKeys.andallthefeaturesofGold.tr(),
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.normal,
                                                                                  fontSize: 14,
                                                                                ),
                                                                              )),
                                                                              Container(
                                                                                width: width,
                                                                                height: 1,
                                                                                color: const Color(0xFFE9A238),
                                                                              ),
                                                                              SubscriptionBuilder(builder: (context, isPremiumUser) {
                                                                                return isPremiumUser || widget.currentUserProf.isPremium!
                                                                                    ? const SizedBox()
                                                                                    : Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                              child: Padding(
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                                                  child: CustomButton(
                                                                                                    text: LocaleKeys.continu.tr(),
                                                                                                    onPressed: () {
                                                                                                      showModalBottomSheet(context: context, constraints: BoxConstraints(maxHeight: height - MediaQuery.of(context).padding.top * 2), isScrollControlled: true, builder: (context) => const SubscriptionWidget());
                                                                                                    },
                                                                                                  )))
                                                                                        ],
                                                                                      );
                                                                              }),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Center(
                                                                                    child: Text(
                                                                                  LocaleKeys.noThanks.tr().toUpperCase(),
                                                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
                                                                                )),
                                                                              )
                                                                            ],
                                                                          )),
                                                                    );
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                          side: const BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(AppConstants.defaultNumericValue * 2),
                                                                          )),
                                                                  child: Text(
                                                                    LocaleKeys
                                                                        .select
                                                                        .tr()
                                                                        .toUpperCase(),
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ));
                                                      }),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: height * .02,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }
                          },
                        );
                      },
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue / 2),
                          width: Responsive.isDesktop(context)
                              ? width * .25
                              : width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                AppConstants.logo,
                                color: Colors.white,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              IconButton(
                                icon: const Icon(
                                  MaterialCommunityIcons.feature_search_outline,
                                  // Icons.join_inner_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  !Responsive.isDesktop(context)
                                      ? Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EventsPage(prefs: widget.prefs),
                                          ),
                                        )
                                      : ref
                                          .read(arrangementProvider.notifier)
                                          .setArrangement(
                                              EventsPage(prefs: widget.prefs));
                                },
                              )
                            ],
                          )),
                    ),
                    Visibility(
                      visible: isToggledLike,
                      child: Positioned(
                        top: 0,
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Lottie.asset(
                            // height: 500,
                            width: Responsive.isDesktop(context)
                                ? width * .25
                                : width,
                            fit: BoxFit.fitWidth,
                            niceAnim2,
                            repeat: true,
                            reverse: true,
                            animate: kDebugMode ? false : true,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isToggledNope,
                      child: Positioned(
                        top: Responsive.isDesktop(context)
                            ? height * .12
                            : height * .1,
                        right: width * .1,
                        child: Lottie.asset(
                          height: 150,
                          nopeAnim2,
                          repeat: true,
                          reverse: true,
                          animate: kDebugMode ? false : true,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isToggledSuper,
                      child: Positioned(
                        bottom: 0,
                        child: Lottie.asset(
                          // height: 500,
                          width: Responsive.isDesktop(context)
                              ? width * .25
                              : width,
                          fit: BoxFit.fitWidth,
                          niceAnim2,
                          repeat: true,
                          reverse: true,
                          animate: kDebugMode ? false : true,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isToggledLike,
                      child: Positioned(
                        top: height * .13,
                        left: width * .8,
                        child: Lottie.asset(
                          height: 150,
                          niceAnim,
                          repeat: true,
                          reverse: true,
                          animate: kDebugMode ? false : true,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isToggledSuper,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Lottie.asset(
                            // height: 150,
                            width: Responsive.isDesktop(context)
                                ? width * .25
                                : width,
                            niceAnim2,
                            repeat: true,
                            reverse: true,
                            animate: kDebugMode ? false : true,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: BottomNavigationBar(
                          showSelectedLabels: false, // <-- HERE
                          showUnselectedLabels: false, // <-- AND HERE
                          unselectedLabelStyle: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                          selectedLabelStyle: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          type: BottomNavigationBarType.fixed,
                          currentIndex: 0,
                          unselectedItemColor: Colors.grey,
                          selectedItemColor: Colors.grey,
                          // onTap: (index) async {
                          //   setState(() {
                          //     ref.invalidate(
                          //         arrangementProviderExtend);
                          //     ref.invalidate(
                          //         arrangementProvider);
                          //     _currentIndex = index;
                          //     updateCurrentIndex(
                          //         ref, index);
                          //   });
                          // },
                          items: [
                            // Back Icon
                            BottomNavigationBarItem(
                                icon: GestureDetector(
                              onTap: () {
                                Responsive.isDesktop(context)
                                    ? ref.invalidate(arrangementProvider)
                                    : {Navigator.pop(context)};
                              },
                              child: const SizedBox(
                                width: 25,
                                height: 25,
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 15,
                                ),
                              ),
                            )),
                            // Home Icon
                            BottomNavigationBarItem(
                                icon: GestureDetector(
                              onTap: () {
                                Responsive.isDesktop(context)
                                    ? ref.invalidate(arrangementProvider)
                                    : {
                                        Navigator.pop(context),
                                        Navigator.pop(context)
                                      };
                              },
                              child: const SizedBox(
                                height: 25,
                                width: 25,
                                child: Icon(
                                  Icons.home_outlined,
                                  size: 15,
                                ),
                              ),
                            ))
                          ]),
                    )
                  ],
                )),
          );
  }
}

class HomePageNoUsersFoundWidget extends ConsumerWidget {
  final String eventType;
  final String phone;
  const HomePageNoUsersFoundWidget({
    super.key,
    required this.eventType,
    required this.phone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactions = ref.watch(eventInteractionFutureProvider(eventType));
    final closestUsers = ref.watch(closestUsersProvider(ref));
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final prefs = ref.watch(sharedPreferencesProvider).value;
    // bool biometricEnabled = false;
    // DataModel cachedModel = DataModel(phoneNumber);

    return interactions.when(
      data: (data) {
        final users = closestUsers
            .where((element) => !data.any((interaction) =>
                interaction.intractToUserId == element.user.phoneNumber))
            .toList();

        users.sort((a, b) => a.distance.compareTo(b.distance));

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue * 2),
            child: users.isEmpty
                ? Container(
                    color: Teme.isDarktheme(prefs!)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    child: Center(
                      child:
                          NoItemFoundWidget(text: LocaleKeys.noCardFound.tr()),
                    ),
                  )
                : AccountSettingsLandingWidget(
                    builder: (data) {
                      return ChangeRadiusFromHomePageWidget(
                        closestUsersDistanceInKM: users.first.distance / 1000,
                        user: data,
                      );
                    },
                    currentUserNo: phoneNumber!,
                  ),
          ),
        );
      },
      error: (_, __) => const SizedBox(),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

class ChangeRadiusFromHomePageWidget extends ConsumerStatefulWidget {
  final double closestUsersDistanceInKM;
  final UserProfileModel user;
  const ChangeRadiusFromHomePageWidget({
    super.key,
    required this.closestUsersDistanceInKM,
    required this.user,
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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NoItemFoundWidget(text: LocaleKeys.nousersfound.tr(), isSmall: true),
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

final isToggledProvider = StateProvider<bool>((ref) => false);
final isToggledNopeProvider = StateProvider<bool>((ref) => false);
final isToggledSuperProvider = StateProvider<bool>((ref) => false);

// class MessageConsumerBottomNavIcon extends ConsumerWidget {
//   const MessageConsumerBottomNavIcon({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final matchingNotifications = ref.watch(notificationsStreamProvider);
//     final matchStream = ref.watch(matchStreamProvider);
//     int unreadCount = 0;

//     matchingNotifications.whenData((value) {
//       for (var element in value) {
//         if (element.isRead == false) {
//           unreadCount++;
//         }
//       }
//     });

//     return matchStream.when(
//       data: (data) {
//         final List<MessageViewModel> messages = [];

//         messages.addAll(getAllMessages(ref, data));

//         for (var e in messages) {
//           unreadCount += e.unreadCount;
//         }

//         return MessageIcon(unreadCount: unreadCount);
//       },
//       error: (_, __) => MessageIcon(unreadCount: 0),
//       loading: () => MessageIcon(unreadCount: 0),
//     );
//   }
// }

// class MessageIcon extends StatelessWidget {
//   final int unreadCount;
//   final _exploreKey = GlobalKey();
//   MessageIcon({
//     Key? key,
//     required this.unreadCount,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//       ),
//     );
//     return Stack(
//       children: [
//         CustomIconButton(
//           key: _exploreKey,
//           icon: mailIcon,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MessageConsumerPage(),
//               ),
//             );
//           },
//           padding: const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
//         ),
//         if (unreadCount > 0)
//           Positioned(
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(1),
//               decoration: BoxDecoration(
//                 color: Colors.red,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
//               child: Center(
//                 child: Text(
//                   '$unreadCount',
//                   style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 7,
//                       fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
