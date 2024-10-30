// ignore_for_file: no_logic_in_create_state, use_build_context_synchronously, library_private_types_in_public_api, unused_local_variable, void_checks

import 'dart:async';
import 'dart:math';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/views/teelsCamera/upload_teel.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/comment/comment_screen.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/hashtag/videos_by_hashtag.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/report/report_screen.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/profile/profile_nested_page.dart';
import 'package:lamatdating/views/tabs/teels/explore_teels_user_hashtags.dart';
import 'package:lamatdating/views/tabs/teels/following_screen.dart';
import 'package:lamatdating/views/teelsCamera/camera_teels.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

// ignore: must_be_immutable
class ItemVideo extends ConsumerStatefulWidget {
  final TeelsModel? videoData;
  final bool isProfile;

  ItemVideo(this.videoData, this.isProfile, {super.key});

  ItemVideoState? item;

  @override
  ItemVideoState createState() {
    item = ItemVideoState();
    return item!;
  }

  getState() => item;
}

class ItemVideoState extends ConsumerState<ItemVideo>
    with TickerProviderStateMixin {
  bool isPhoto = false;

  String? phone;

  bool isLiked = false;

  UserProfileModel? currentUserProf;
  UserProfileModel? myUserProf;

  refresh() {
    setState(() {});
  }

  var squareScaleA = 1.0;
  var squareScaleB = 1.0;
  late AnimationController _controllerA;
  late AnimationController _controllerB;
  bool? isLike;

  VideoPlayerController? controller;
  bool isIncreaseView = false;
  bool followOrNot = false;
  late AnimationController _animationController;
  bool _isPlaying = false;
  bool isGiftDialogOpen = false;
  bool isPurchaseDialogOpen = false;
  bool isInProfile = false;
  Box<dynamic>? box;
  SharedPreferences? prefs;

  @override
  void initState() {
    box = Hive.box(HiveConstants.hiveBox);
    phone = box!.get(Dbkeys.phone);
    isInProfile = widget.isProfile;
    super.initState();

    _controllerA = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 500));
    _controllerA.addListener(() {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    });
    _controllerA.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        likeTeel(widget.videoData!.id, phoneNumber!);
        isLike! == true
            ? await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(
                  widget.videoData!.phoneNumber,
                )
                .set({'myPostLikes': FieldValue.increment(1)},
                    SetOptions(merge: true))
            : await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(
                  widget.videoData!.phoneNumber,
                )
                .set({'myPostLikes': FieldValue.increment(-1)},
                    SetOptions(merge: true));
        createInteractionNotification(
            title: "You have new teel like",
            body:
                "${myUserProf!.userName} and ${widget.videoData!.likes.length} others liked your teel",
            receiverId: widget.videoData!.phoneNumber,
            currentUser: myUserProf!);
      }
    });

    _controllerB = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 500));
    _controllerB.addListener(() {
      setState(() {
        squareScaleB = _controllerB.value;
      });
    });
    _controllerB.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        saveTeel(widget.videoData!.id, phoneNumber!);
      }
    });

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isPlaying = false;
        });
        _animationController.reset();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      currentUserProf = await getUserProfile(widget.videoData!.phoneNumber);
      phoneNumber = ref.watch(authStateProvider).value!.phoneNumber;
      bool liked = widget.videoData!.likes.contains(phoneNumber) ? true : false;
      setState(() {
        isLike = liked;
      });
      final isLikeTeelAsyncValue =
          ref.read(isLikeTeel([widget.videoData!.id, phoneNumber!]));
      likeWidget = isLikeTeelAsyncValue.when(
        data: (islike) {
          bool? isliked = islike;
          return Transform.scale(
            scale: squareScaleA,
            child: WebsafeSvg.asset(
              likeIcon,
              colorFilter: ColorFilter.mode(
                (isliked == true) ? Colors.red : Colors.white,
                BlendMode.srcIn,
              ),
              height: 30,
              fit: BoxFit.fitHeight,
            ),
          );
        },
        loading: () => WebsafeSvg.asset(
          likeIcon,
          colorFilter: const ColorFilter.mode(
            // Colors.blueGrey,
            //  AppConstants.primaryColor,
            // AppConstants.secondaryColor,
            Colors.white,
            // Colors.grey,
            //  Colors.black,
            BlendMode.srcIn,
          ),
          height: 30,
          fit: BoxFit.fitHeight,
        ),
        error: (_, __) => const Text('0'),
      );
    });
    SharedPreferences.getInstance().then((pref) {
      prefs = pref;
      final int dialogOpen = pref.getInt('dialog_open') ?? 0;
      if (dialogOpen == 0) {
        //show dialog for one time only
        Future.delayed(const Duration(milliseconds: 1000), () {
          showAlertDialogue();
          pref.setInt("dialog_open", 1);
        });
      }
    });
  }

  String? phoneNumber;
  Widget? likeWidget;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  showAlertDialogue() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            color: AppConstants.primaryColor.withOpacity(.5),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Lottie.asset(
                  doubleTap,
                  height: MediaQuery.of(context).size.height / 2,
                  fit: BoxFit.fitWidth,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      LocaleKeys.doubletaptolike.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppConstants.textColor,
                        fontSize: 22,
                      ),
                    )),
                Align(
                    alignment: Alignment.center,
                    child: Text(
                      LocaleKeys.longpresstoreport.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textColor,
                          fontSize: 14),
                    )),
                Align(
                    alignment: Alignment.center,
                    child: CustomButton(
                      icon: Icons.thumb_up_outlined,
                      text: LocaleKeys.gotit.tr(),
                      onPressed: () => Navigator.of(context).pop(),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controllerA.dispose();
    super.dispose();
  }

  String formatNumber(int num) {
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    } else {
      return num.toString();
    }
  }

  void onGiftTap(ref) {
    // getProfile();
    isGiftDialogOpen = true;
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return GiftSheet(
          onAddDymondsTap: onAddDymondsTap,
          onGiftSend: (gift) async {
            if (gift?.coinPrice != null) {
              EasyLoading.show(status: LocaleKeys.sendinggift.tr());

              int value = gift!.coinPrice!;

              sendGiftProvider(
                  giftCost: value, recipientId: widget.videoData!.phoneNumber);
              if (kDebugMode) {
                print("${gift.coinPrice}");
              }

              // onCommentSend(
              //     commentType: FirebaseConst.image, msg: gift.image ?? '');
              Future.delayed(const Duration(seconds: 3), () {
                EasyLoading.dismiss();
              });
              Navigator.pop(context);
            } else {
              Navigator.pop(context);
            }
          },
        );
      },
    ).then((value) {
      isGiftDialogOpen = false;
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
      image: widget.videoData!.thumbnail,
      createdAt: currentTime,
      isRead: false,
      isMatchingNotification: false,
      isInteractionNotification: true,
    );

    await addNotification(notificationModel);
  }

  Future<UserProfileModel?> getUserProfile(String id) async {
    final userCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.userProfileCollection);
    final userDoc = userCollection.doc(id);
    final userProfile = await userDoc.get();
    if (userProfile.exists) {
      final userProfileModel = UserProfileModel.fromMap(userProfile.data()!);
      return userProfileModel;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final phoneNumber = ref.watch(authStateProvider).value!.phoneNumber;
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final currentUser = ref.watch(userProfileFutureProvider);
    final currentUserValue = ref.watch(userProfileFutureProvider).value;
    final totalLikesAsyncValue = ref.watch(getTotalLikes(widget.videoData!.id));
    final totalSavesAsyncValue = ref.watch(getTotalSaves(widget.videoData!.id));
    final likers = ref.watch(getTeelLikes(widget.videoData!.id));
    final followers = ref.watch(getFollowers(widget.videoData!.phoneNumber));
    final allSavesList = ref.watch(getTeelSaves(widget.videoData!.id));
    final userProfile = ref.read(userProfileNotifier);

    final UserProfileModel? user = currentUserProf;
    myUserProf = currentUserValue;

    final PageController pageController = PageController();

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
      // final prefs = ref.watch(sharedPreferencesProvider).value;

      await createConversation(matchModel).then((matchResult) async {
        final images = otherUser.mediaFiles;
        final cachedModel = DataModel(currentUser.phoneNumber);
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
                              color: Colors.transparent,
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
                                    DataModel? cachedModel;
                                    cachedModel ??= DataModel(phone);
                                    Navigator.pop(context);
                                    !Responsive.isDesktop(context)
                                        ? Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PreChat(
                                                name: otherUser.fullName,
                                                phone: otherUser.phoneNumber,
                                                currentUserNo: phone,
                                                model: cachedModel,
                                                prefs: prefs!,
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
                                                  currentUserNo: phone,
                                                  model: cachedModel,
                                                  prefs: prefs!,
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
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Teme.isDarktheme(prefs!)
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
                                        ),
                                  )
                            : Container(
                                decoration: BoxDecoration(
                                    color: Teme.isDarktheme(prefs!)
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
                                              width: 250,
                                              height: 250,
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

    final currentUserProfile = ref.watch(userProfileFutureProvider);
    // final prefs = ref.watch(sharedPreferencesProvider).value;

    // final myPhoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;

    // currentUserProfile.whenData((userProfile) {
    //   currentUserProfileModel = userProfile;
    // });

    return widget.videoData != null
        ? SubscriptionBuilder(builder: (context, isPremiumUser) {
            // Freemium Limitations
            final List<UserInteractionModel> data = [];
            final interactionProvider = ref.watch(interactionFutureProvider);
            return interactionProvider.when(
                loading: () => NoItemFoundWidget(
                    currentProfile: currentUserValue, prefs: prefs),
                error: (error, stackTrace) => NoItemFoundWidget(
                    currentProfile: currentUserValue, prefs: prefs),
                data: (value) {
                  data.addAll(value);

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  final interactionsToday = data
                      .where((element) => element.createdAt.isAfter(today))
                      .toList();

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
                        totalLiked >=
                            FreemiumLimitation.maxDailyLikeLimitPremium) {
                      canLike = false;
                    }

                    if (FreemiumLimitation.maxDailySuperLikeLimitPremium != 0 &&
                        totalSuperLiked >=
                            FreemiumLimitation.maxDailySuperLikeLimitPremium) {
                      canSuperLike = false;
                    }

                    if (FreemiumLimitation.maxDailyDislikeLimitPremium != 0 &&
                        totalDisliked >=
                            FreemiumLimitation.maxDailyDislikeLimitPremium) {
                      canDislike = false;
                    }
                  } else {
                    if (FreemiumLimitation.maxDailyLikeLimitFree != 0 &&
                        totalLiked >=
                            FreemiumLimitation.maxDailyLikeLimitFree) {
                      canLike = false;
                    }

                    if (FreemiumLimitation.maxDailySuperLikeLimitFree != 0 &&
                        totalSuperLiked >=
                            FreemiumLimitation.maxDailySuperLikeLimitFree) {
                      canSuperLike = false;
                    }

                    if (FreemiumLimitation.maxDailyDislikeLimitFree != 0 &&
                        totalDisliked >=
                            FreemiumLimitation.maxDailyDislikeLimitFree) {
                      canDislike = false;
                    }
                  }
                  double width = MediaQuery.of(context).size.width;
                  double height = MediaQuery.of(context).size.height;
                  return Stack(
                    children: [
                      InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => ReportScreen(
                                1, widget.videoData!.id.toString()),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        child: _ButterFlyAssetVideo(
                          widget.videoData!.postVideo,
                          widget.videoData!.id,
                          (controller) {
                            this.controller = controller;
                          },
                        ),
                        onDoubleTap: () async {
                          debugPrint('double tapped!!!!!!!!!!!!!!!!!!!!!!');
                          setState(() {
                            _isPlaying = true;
                          });
                          _animationController.forward();
                          if (widget.videoData!.phoneNumber != phoneNumber) {
                            if (canLike) {
                              final id = phone! + widget.videoData!.phoneNumber;
                              final UserInteractionModel interaction =
                                  UserInteractionModel(
                                id: id,
                                phoneNumber: phone!,
                                intractToUserId: widget.videoData!.phoneNumber,
                                isSuperLike: false,
                                isLike: true,
                                isDislike: false,
                                createdAt: DateTime.now(),
                              );
                              await createInteraction(interaction)
                                  .then((result) async {
                                if (result && currentUserValue != null) {
                                  await getExistingInteraction(
                                          widget.videoData!.phoneNumber, phone!)
                                      .then((otherUserInteraction) async {
                                    if (otherUserInteraction != null) {
                                      await showMatchingDialog(
                                          context: context,
                                          currentUser: currentUserValue,
                                          otherUser: user!);
                                    } else {
                                      createInteractionNotification(
                                          title: LocaleKeys
                                              .youhaveanewInteraction
                                              .tr(),
                                          body: LocaleKeys.someonehaslikedyou
                                              .tr(),
                                          receiverId:
                                              widget.videoData!.phoneNumber,
                                          currentUser: currentUserValue);
                                      // Navigator.pop(context);
                                    }
                                  });
                                }

                                // ref.invalidate(interactionFutureProvider);
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
                          }

                          await Future.delayed(const Duration(seconds: 3));
                          // EasyLoading.dismiss();

                          setState(() {
                            _isPlaying = false;
                          });
                        },
                      ),
                      if (!isInProfile)
                        Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            right: 15,
                            child: InkWell(
                              onTap: () {
                                !Responsive.isDesktop(context)
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExploreAllPage(
                                            prefs: prefs!,
                                          ),
                                        ),
                                      )
                                    : {
                                        // updateCurrentIndex(ref, 10),
                                        ref
                                            .read(arrangementProviderExtend
                                                .notifier)
                                            .setArrangement(ExploreAllPage(
                                              prefs: prefs!,
                                            ))
                                      };
                              },
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: WebsafeSvg.asset(
                                  searchIcon,
                                  colorFilter: const ColorFilter.mode(
                                    // Colors.blueGrey,
                                    //  AppConstants.primaryColor,
                                    // AppConstants.secondaryColor,
                                    Colors.white,
                                    // Colors.grey,
                                    //  Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  height: 30,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            )),
                      if (!isInProfile)
                        Positioned(
                            top: MediaQuery.of(context).padding.top + 60,
                            right: 12,
                            child: InkWell(
                              onTap: () async {
                                if (kIsWeb) {
                                  final imagePath =
                                      await pickMediaWeb(isVideo: true)
                                          .then((value) {
                                    final observer =
                                        ref.watch(observerProvider);
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
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
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
                              child: WebsafeSvg.asset(
                                cameraIcon,
                                colorFilter: const ColorFilter.mode(
                                  // Colors.blueGrey,
                                  //  AppConstants.primaryColor,
                                  // AppConstants.secondaryColor,
                                  Colors.white,
                                  // Colors.grey,
                                  //  Colors.black,
                                  BlendMode.srcIn,
                                ),
                                height: 35,
                                fit: BoxFit.fitHeight,
                              ),
                            )),
                      if (!isInProfile)
                        Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 15,
                            child: SizedBox(
                              height: 30,
                              width: 30,
                              child: InkWell(
                                onTap: () {
                                  !Responsive.isDesktop(context)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LiveStreamScreen(),
                                          ),
                                        )
                                      : {
                                          updateCurrentIndex(ref, 0),
                                        };
                                },
                                child: WebsafeSvg.asset(
                                  livestreamIcon,
                                  colorFilter: const ColorFilter.mode(
                                    // Colors.blueGrey,
                                    //  AppConstants.primaryColor,
                                    // AppConstants.secondaryColor,
                                    Colors.white,
                                    // Colors.grey,
                                    //  Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            )),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: VisibilityDetector(
                                onVisibilityChanged: (VisibilityInfo info) {
                                  var visiblePercentage =
                                      info.visibleFraction * 100;
                                  if (visiblePercentage > 50) {
                                    if (controller != null) {
                                      controller?.play();
                                      if (!isIncreaseView) {
                                        isIncreaseView = true;
                                        increaseTeelViewCount(
                                            widget.videoData!.id.toString(),
                                            phoneNumber!);
                                      }
                                    }
                                  } else {
                                    if (controller != null) {
                                      controller?.pause();
                                    }
                                  }
                                },
                                key: Key('key${widget.videoData!.postVideo!}'),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 15,
                                    bottom: !isInProfile
                                        ? MediaQuery.of(context).size.height *
                                            0.09
                                        : MediaQuery.of(context).size.height *
                                            0.02,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: widget.videoData!
                                            .profileCategoryName!.isNotEmpty,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 5,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          child: Text(
                                            widget.videoData!
                                                .profileCategoryName!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      InkWell(
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          otherUsers.when(
                                            data: (users) {
                                              final userProfile =
                                                  users.firstWhere(
                                                (otherUser) =>
                                                    widget
                                                        .videoData!.phoneNumber
                                                        .toString() ==
                                                    otherUser.phoneNumber,
                                              );
                                              return (!Responsive.isDesktop(
                                                      context))
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserDetailsPage(
                                                                user:
                                                                    userProfile,
                                                              )),
                                                    )
                                                  : ref
                                                      .watch(arrangementProvider
                                                          .notifier)
                                                      .setArrangement(
                                                          UserDetailsPage(
                                                        user: userProfile,
                                                      ));
                                            },
                                            error: (e, _) => Container(),
                                            loading: () {
                                              // return (!Responsive.isDesktop(context)) ? const CircularProgressIndicator() : null;
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              '${AppRes.atSign}${widget.videoData!.userName}',
                                              style: TextStyle(
                                                fontFamily: fNSfUiSemiBold,
                                                letterSpacing: 0.6,
                                                fontSize: 16,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: const Offset(1, 1),
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    blurRadius: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            (widget.videoData!.phoneNumber ==
                                                    phoneNumber)
                                                ? currentUser.when(
                                                    data: (user) {
                                                      return Image(
                                                        image: const AssetImage(
                                                            verifiedIcon),
                                                        height:
                                                            user!.isVerified ==
                                                                    true
                                                                ? 15
                                                                : 0,
                                                        width:
                                                            user.isVerified ==
                                                                    true
                                                                ? 15
                                                                : 0,
                                                      );
                                                    },
                                                    error: (e, _) =>
                                                        Container(),
                                                    loading: () {
                                                      return const CircularProgressIndicator();
                                                    })
                                                : otherUsers.when(
                                                    data: (users) {
                                                      final userProfile =
                                                          users.firstWhere(
                                                        (otherUser) =>
                                                            widget.videoData!
                                                                .phoneNumber
                                                                .toString() ==
                                                            otherUser
                                                                .phoneNumber,
                                                        // orElse: () => null,
                                                      );
                                                      return Image(
                                                        image: const AssetImage(
                                                            verifiedIcon),
                                                        height: userProfile
                                                                    .isVerified ==
                                                                true
                                                            ? 18
                                                            : 0,
                                                        width: userProfile
                                                                    .isVerified ==
                                                                true
                                                            ? 18
                                                            : 0,
                                                      );
                                                    },
                                                    error: (e, _) =>
                                                        Container(),
                                                    loading: () {
                                                      return const CircularProgressIndicator();
                                                    }, // Replace with your error widget
                                                  ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      Visibility(
                                          visible: widget
                                              .videoData!.caption!.isNotEmpty,
                                          child: SizedBox(
                                            width: width * .7,
                                            child: ExpandableText(
                                              widget.videoData!.caption!,
                                              expandText: keepFirstFourWords(
                                                  widget.videoData!.caption!),
                                              collapseText:
                                                  LocaleKeys.showless.tr(),
                                              maxLines: 1,
                                              linkColor: Colors.blue,
                                              style: TextStyle(
                                                fontFamily: fNSfUiRegular,
                                                letterSpacing: 0.6,
                                                fontSize: 13,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: const Offset(1, 1),
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    blurRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              onHashtagTap: (text) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        VideosByHashTagScreen(
                                                            text),
                                                  ),
                                                );
                                              },
                                            ),
                                          )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: const BoxDecoration(
                                                color: Colors.black26,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(AppConstants
                                                          .defaultNumericValue *
                                                      2),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  WebsafeSvg.asset(
                                                    musicIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      // Colors.blueGrey,
                                                      //  AppConstants.primaryColor,
                                                      // AppConstants.secondaryColor,
                                                      Colors.white,
                                                      // Colors.grey,
                                                      //  Colors.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 15,
                                                    fit: BoxFit.fitHeight,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: SizedBox(
                                                        // width: width * .35,
                                                        height: 13,
                                                        child: Marquee(
                                                          text: widget
                                                              .videoData!
                                                              .soundTitle!,
                                                          style: TextStyle(
                                                            letterSpacing: 0.5,
                                                            fontSize: 11,
                                                            color: Colors.white,
                                                            shadows: [
                                                              Shadow(
                                                                offset:
                                                                    const Offset(
                                                                        1, 1),
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 5,
                                                              ),
                                                            ],
                                                          ),
                                                          velocity: 30,
                                                          blankSpace: 20.0,
                                                        )),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Visibility(
                                            visible: phoneNumber !=
                                                widget.videoData!.phoneNumber,
                                            child: InkWell(
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              onTap: () {
                                                if (phoneNumber!.isNotEmpty) {
                                                  showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (context) {
                                                      return GiftSheet(
                                                        onAddDymondsTap:
                                                            onAddDymondsTap,
                                                        onGiftSend: (gift) {
                                                          EasyLoading.show(
                                                              status: LocaleKeys
                                                                  .sendinggift
                                                                  .tr());

                                                          int value =
                                                              gift!.coinPrice!;

                                                          sendGiftProvider(
                                                              giftCost: value,
                                                              recipientId: widget
                                                                  .videoData!
                                                                  .phoneNumber);
                                                          if (kDebugMode) {
                                                            print(
                                                                "${gift.coinPrice}");
                                                          }

                                                          // onCommentSend(
                                                          //     commentType: FirebaseConst.image, msg: gift.image ?? '');
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 3),
                                                              () {
                                                            EasyLoading
                                                                .dismiss();
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  bottom: 5,
                                                ),
                                                width: 85,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white38,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(AppConstants
                                                            .defaultNumericValue *
                                                        2),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Icon(
                                                      CupertinoIcons.gift,
                                                      size: 15,
                                                    ),
                                                    Text(
                                                      LocaleKeys.sendGift.tr(),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 30),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: 15,
                                  bottom: !isInProfile
                                      ? MediaQuery.of(context).size.height *
                                          0.08
                                      : MediaQuery.of(context).size.height *
                                          0.01),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BouncingWidget(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      scaleFactor: 1,
                                      onPressed: () {
                                        (widget.videoData!.phoneNumber ==
                                                phoneNumber)
                                            ? (!Responsive.isDesktop(context))
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileNested(
                                                              prefs: prefs!,
                                                              isHome: true,
                                                            )),
                                                  )
                                                : ref
                                                    .watch(arrangementProvider
                                                        .notifier)
                                                    .setArrangement(
                                                        ProfileNested(
                                                      prefs: prefs!,
                                                      isHome: true,
                                                    ))
                                            : otherUsers.when(
                                                data: (users) {
                                                  final userProfile =
                                                      users.firstWhere(
                                                    (otherUser) =>
                                                        widget.videoData!
                                                            .phoneNumber
                                                            .toString() ==
                                                        otherUser.phoneNumber,
                                                  );
                                                  return (!Responsive.isDesktop(
                                                          context))
                                                      ? Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UserDetailsPage(
                                                                    user:
                                                                        userProfile,
                                                                  )),
                                                        )
                                                      : ref
                                                          .watch(
                                                              arrangementProvider
                                                                  .notifier)
                                                          .setArrangement(
                                                              UserDetailsPage(
                                                            user: userProfile,
                                                          ));
                                                },
                                                error: (e, _) => Container(),
                                                loading: () {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }, // Replace with your error widget
                                              );
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            height: 45,
                                            width: 45,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // const Padding(
                                                //   padding: EdgeInsets.all(5.0),
                                                //   child: Image(
                                                //     image: AssetImage(icUserPlaceHolder),
                                                //     color: AppConstants.textColorLight,
                                                //   ),
                                                // ),
                                                SizedBox(
                                                  height: 40,
                                                  width: 40,
                                                  child: ClipOval(
                                                    child: (widget.videoData!
                                                                .phoneNumber ==
                                                            phoneNumber)
                                                        ? currentUser.when(
                                                            data: (user) {
                                                              return Image
                                                                  .network(
                                                                user!
                                                                    .profilePicture!,
                                                                fit: BoxFit
                                                                    .cover,
                                                              );
                                                            },
                                                            error: (e, _) =>
                                                                Container(),
                                                            loading: () {
                                                              return const CircularProgressIndicator();
                                                            })
                                                        : otherUsers.when(
                                                            data: (users) {
                                                              final userProfile =
                                                                  users
                                                                      .firstWhere(
                                                                (otherUser) =>
                                                                    widget
                                                                        .videoData!
                                                                        .phoneNumber
                                                                        .toString() ==
                                                                    otherUser
                                                                        .phoneNumber,
                                                                // orElse: () => null,
                                                              );
                                                              return Image
                                                                  .network(
                                                                userProfile
                                                                    .profilePicture!,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Container();
                                                                },
                                                              );
                                                            },
                                                            error: (e, _) =>
                                                                Container(),
                                                            loading: () {
                                                              return const CircularProgressIndicator();
                                                            }, // Replace with your error widget
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          followers.when(
                                            data: (allfollowers) {
                                              return (!allfollowers.contains(
                                                          phoneNumber) &&
                                                      phoneNumber !=
                                                          widget.videoData!
                                                              .phoneNumber)
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        top: 40,
                                                      ),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                          .defaultNumericValue *
                                                                      2)),
                                                      child: InkWell(
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        overlayColor:
                                                            WidgetStateProperty
                                                                .all(Colors
                                                                    .transparent),
                                                        onTap: () async {
                                                          userProfile.followUnfollow(
                                                              followUser: widget
                                                                  .videoData!
                                                                  .phoneNumber,
                                                              ref: ref);
                                                        },
                                                        child: WebsafeSvg.asset(
                                                          addIcon,
                                                          colorFilter:
                                                              const ColorFilter
                                                                  .mode(
                                                            // Colors.blueGrey,
                                                            AppConstants
                                                                .primaryColor,
                                                            // AppConstants.secondaryColor,
                                                            // Colors.white,
                                                            // Colors.grey,
                                                            //  Colors.black,
                                                            BlendMode.srcIn,
                                                          ),
                                                          height: 28,
                                                          fit: BoxFit.fitHeight,
                                                        ),
                                                      ))
                                                  : Container();
                                            },
                                            loading: () => Container(),
                                            error: (_, __) => const Text('0'),
                                          ),
                                        ],
                                      )),

                                  const SizedBox(
                                    height: AppConstants.defaultNumericValue,
                                  ),
                                  SizedBox(
                                    height: phoneNumber !=
                                            widget.videoData!.phoneNumber
                                        ? AppConstants.defaultNumericValue
                                        : 0,
                                  ),
                                  // SizedBox(
                                  //   height: 32,
                                  //   width: 32,
                                  //   child: InkWell(
                                  //       focusColor: Colors.transparent,
                                  //       hoverColor: Colors.transparent,
                                  //       highlightColor: Colors.transparent,
                                  //       overlayColor:
                                  //           MaterialStateProperty.all(Colors.transparent),
                                  //       onTap: () {
                                  //         _controllerA.forward(from: 0.0);
                                  //       },
                                  //       child: likeWidget),
                                  // ),

                                  likers.when(
                                    data: (allLikers) {
                                      return allLikers.contains(phoneNumber)
                                          ? InkWell(
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              onTap: () {
                                                //     if (!isLiked)
                                                // {  ref.read(addBalanceProvider(AppRes.likeRewards.toDouble()));}
                                                setState(() {
                                                  isLike = false;
                                                  isLiked = true;
                                                });

                                                _controllerA.forward(from: 0.0);
                                              },
                                              child: Transform.scale(
                                                  scale: squareScaleA,
                                                  child: WebsafeSvg.asset(
                                                    likeIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      // Colors.blueGrey,
                                                      //  AppConstants.primaryColor,
                                                      // AppConstants.secondaryColor,
                                                      Colors.red,
                                                      // Colors.grey,
                                                      //  Colors.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 30,
                                                    fit: BoxFit.fitHeight,
                                                  )))
                                          : InkWell(
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              onTap: () {
                                                setState(() {
                                                  isLike = true;
                                                });
                                                _controllerA.forward(from: 0.0);
                                              },
                                              child: Transform.scale(
                                                  scale: squareScaleA,
                                                  child: WebsafeSvg.asset(
                                                    likeIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      // Colors.blueGrey,
                                                      //  AppConstants.primaryColor,
                                                      // AppConstants.secondaryColor,
                                                      Colors.white,
                                                      // Colors.grey,
                                                      //  Colors.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 30,
                                                    fit: BoxFit.fitHeight,
                                                  )));
                                    },
                                    loading: () => WebsafeSvg.asset(
                                      likeIcon,
                                      colorFilter: const ColorFilter.mode(
                                        // Colors.blueGrey,
                                        //  AppConstants.primaryColor,
                                        // AppConstants.secondaryColor,
                                        Colors.white,
                                        // Colors.grey,
                                        //  Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 30,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    error: (_, __) => const Text('0'),
                                  ),
                                  widget.videoData!.videoShowLikes
                                      ? totalLikesAsyncValue.when(
                                          data: (totalLikes) => Text(
                                            formatNumber(totalLikes),
                                            style: TextStyle(
                                              color: AppConstants.textColor,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  offset: const Offset(1, 1),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          loading: () =>
                                              const CircularProgressIndicator(),
                                          error: (_, __) => const Text('0'),
                                        )
                                      : Container(),
                                  const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 2,
                                  ),
                                  widget.videoData!.canComment
                                      ? InkWell(
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          overlayColor: WidgetStateProperty.all(
                                              Colors.transparent),
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
                                                            .isDarktheme(prefs!)
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
                                                        child: CommentScreen(
                                                            widget.videoData,
                                                            () {
                                                          createInteractionNotification(
                                                              title:
                                                                  "You have new teel comment",
                                                              body:
                                                                  "${myUserProf!.userName} and ${widget.videoData!.comments.length} others commented on your teel",
                                                              receiverId: widget
                                                                  .videoData!
                                                                  .phoneNumber,
                                                              currentUser:
                                                                  myUserProf!);
                                                          setState(() {});
                                                        }, null),
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
                                                      child: CommentScreen(
                                                          widget.videoData, () {
                                                        setState(() {});
                                                      }, null),
                                                    ));
                                          },
                                          child: WebsafeSvg.asset(
                                            commentIconFilled,
                                            colorFilter: const ColorFilter.mode(
                                              // Colors.blueGrey,
                                              //  AppConstants.primaryColor,
                                              // AppConstants.secondaryColor,
                                              Colors.white,
                                              // Colors.grey,
                                              //  Colors.black,
                                              BlendMode.srcIn,
                                            ),
                                            height: 30,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                      : Container(),
                                  widget.videoData!.canComment
                                      ? Text(
                                          formatNumber(
                                            widget.videoData!.comments.length,
                                          ),
                                          style: TextStyle(
                                            color: AppConstants.textColor,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                offset: const Offset(1, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 2,
                                  ),
                                  // SaveUnsaveButton(
                                  //   videoData: widget.videoData,
                                  //   phoneNumber: phoneNumber!,
                                  // ),
                                  allSavesList.when(
                                    data: (allSaves) {
                                      return allSaves.contains(phoneNumber)
                                          ? InkWell(
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              onTap: () {
                                                _controllerB.forward(from: 0.0);
                                              },
                                              child: Transform.scale(
                                                  scale: squareScaleA,
                                                  child: WebsafeSvg.asset(
                                                    favIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      // Colors.blueGrey,
                                                      //  AppConstants.primaryColor,
                                                      // AppConstants.secondaryColor,
                                                      Colors.red,
                                                      // Colors.grey,
                                                      //  Colors.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 30,
                                                    fit: BoxFit.fitHeight,
                                                  )))
                                          : InkWell(
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              overlayColor:
                                                  WidgetStateProperty.all(
                                                      Colors.transparent),
                                              onTap: () {
                                                _controllerB.forward(from: 0.0);
                                              },
                                              child: Transform.scale(
                                                  scale: squareScaleA,
                                                  child: WebsafeSvg.asset(
                                                    favIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      // Colors.blueGrey,
                                                      //  AppConstants.primaryColor,
                                                      // AppConstants.secondaryColor,
                                                      Colors.white,
                                                      // Colors.grey,
                                                      //  Colors.black,
                                                      BlendMode.srcIn,
                                                    ),
                                                    height: 30,
                                                    fit: BoxFit.fitHeight,
                                                  )));
                                    },
                                    loading: () => WebsafeSvg.asset(
                                      favIcon,
                                      colorFilter: const ColorFilter.mode(
                                        // Colors.blueGrey,
                                        //  AppConstants.primaryColor,
                                        // AppConstants.secondaryColor,
                                        Colors.white,
                                        // Colors.grey,
                                        //  Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 30,
                                      fit: BoxFit.fitHeight,
                                    ),
                                    error: (_, __) => const Text('0'),
                                  ),
                                  totalSavesAsyncValue.when(
                                    data: (totalSaves) => Text(
                                      formatNumber(totalSaves),
                                      style: TextStyle(
                                        color: AppConstants.textColor,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    loading: () =>
                                        const CircularProgressIndicator(),
                                    error: (_, __) => const Text('0'),
                                  ),
                                  const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 2,
                                  ),
                                  InkWell(
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    onTap: () {
                                      shareLink(widget.videoData!);
                                    },
                                    child: WebsafeSvg.asset(
                                      shareIcon,
                                      colorFilter: const ColorFilter.mode(
                                        // Colors.blueGrey,
                                        //  AppConstants.primaryColor,
                                        // AppConstants.secondaryColor,
                                        Colors.white,
                                        // Colors.grey,
                                        //  Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      height: 30,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  MusicDisk(widget.videoData),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: _isPlaying,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Lottie.asset(
                            icCrushAnimation,
                            controller: _animationController,
                            height: MediaQuery.of(context).size.height,
                            repeat: true,
                          ),
                        ),
                      )
                    ],
                  );
                });
          })
        : FollowingScreen(user: currentUser.value);
  }

  String keepFirstFourWords(String caption) {
    List<String> words = caption.split(' ');
    if (words.length > 3) {
      words = words.take(3).toList();
    }
    return words.join(' ');
  }

  void shareLink(TeelsModel videoData) async {
    final canonicalIdentifier = const Uuid().v4();
    BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'lamat/branch_$canonicalIdentifier',
        title: videoData.userName,
        imageUrl: videoData.thumbnail ??
            "https://play-lh.googleusercontent.com/ZgFIUKzhGURlAMar1drZJlCWlh8JfeEy5Lmkuag0q-ZsPWwdeCV8rOAeEMQ23CvgdQ=w240-h480-rw",
        contentDescription:
            videoData.caption ?? "${videoData.singer}'s Lamat Teel",
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata("video_id", videoData.id));
    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'share',
        feature: 'sharing',
        stage: 'new share',
        campaign: 'campaign',
        tags: [
          widget.videoData!.userName,
          widget.videoData!.postHashTag!,
          Appname
        ])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('referring_user_id', widget.videoData!.userName)
      ..addControlParam('\$fallback_url', 'https://lamatt.web.app')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.appfliiq.jolii&pli=1');
    final response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp)
            .catchError((error) {
      Share.share(
        AppRes.checkOutThisAmazingProfile("https://lamatt.app.link"),
        subject: "${AppRes.look} at @${videoData.userName}'s Teel",
      );
      if (kDebugMode) {
        print('Error : - ${error.toString()}');
      }
      return error;
    });
    if (response.success) {
      Share.share(
        AppRes.checkOutThisAmazingProfile(response.result),
        subject: '${AppRes.look} ${videoData.userName}',
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
      ..addCustomMetadata('custom_string',
          widget.videoData!.caption ?? '$Appname - $dateString')
      ..addCustomMetadata('user_id', widget.videoData!.phoneNumber)
      ..addCustomMetadata("username", widget.videoData!.userName)
      ..addCustomMetadata('feed_id', widget.videoData!.id)
      ..addCustomMetadata(
          'feed_date_created', widget.videoData!.createdAt.toString())
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
        title: widget.videoData!.caption ?? '$Appname - $dateString',
        imageUrl: widget.videoData!.thumbnail ??
            "https://play-lh.googleusercontent.com/ZgFIUKzhGURlAMar1drZJlCWlh8JfeEy5Lmkuag0q-ZsPWwdeCV8rOAeEMQ23CvgdQ=w240-h480-rw",
        contentDescription:
            widget.videoData!.caption ?? '$Appname - $dateString',
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
        tags: [
          widget.videoData!.userName,
          widget.videoData!.postHashTag!,
          Appname
        ])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('\$ios_nativelink', true)
      ..addControlParam('\$match_duration', 7200)
      ..addControlParam('referring_user_id', widget.videoData!.userName)
      ..addControlParam('\$fallback_url', 'https://lamatt.web.app')
      ..addControlParam('\$android_url',
          'https://play.google.com/store/apps/details?id=com.appfliiq.jolii&pli=1');

    eventStandard = BranchEvent.standardEvent(BranchStandardEvent.ADD_TO_CART)
      //--optional Event data

      ..adType = BranchEventAdType.BANNER;

    eventCustom = BranchEvent.customEvent('Custom_event')
      ..alias = widget.videoData!.userName;
  }

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchLinkProperties lp = BranchLinkProperties();
  late BranchUniversalObject buo;
  late BranchEvent eventStandard;
  late BranchEvent eventCustom;
}

class MusicDisk extends StatefulWidget {
  final TeelsModel? videoData;

  const MusicDisk(this.videoData, {super.key});

  @override
  _MusicDiskState createState() => _MusicDiskState();
}

class _MusicDiskState extends State<MusicDisk>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => VideosBySoundScreen(widget.videoData),
        //   ),
        // );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: child,
          );
        },
        child: Container(
          height: 45,
          width: 45,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: AssetImage(icBgDisk)),
          ),
          padding: const EdgeInsets.all(10),
          child: ClipOval(
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConstants.primaryColor,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Image(
                        image: AssetImage(icMusic),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 24,
                    width: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      // color: AppConstants.primaryColor,
                    ),
                    child: Image.network(
                      (widget.videoData!.soundImage != null
                          ? widget.videoData!.soundImage!
                          : ''),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaveUnsaveButton extends ConsumerStatefulWidget {
  final TeelsModel? videoData;
  final String phoneNumber;

  const SaveUnsaveButton(
      {super.key, required this.phoneNumber, this.videoData});

  @override
  _SaveUnsaveButtonState createState() => _SaveUnsaveButtonState();
}

class _SaveUnsaveButtonState extends ConsumerState<SaveUnsaveButton>
    with TickerProviderStateMixin {
  var squareScaleA = 1.0;
  late AnimationController _controllerA;

  @override
  void initState() {
    isSave = widget.videoData!.saves.contains(widget.phoneNumber);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _controllerA = AnimationController(
        vsync: this,
        lowerBound: 0.5,
        upperBound: 1.0,
        duration: const Duration(milliseconds: 500));
    _controllerA.addListener(() {
      setState(() {
        squareScaleA = _controllerA.value;
      });
    });

    _controllerA.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isSave = !isSave;
        saveTeel(widget.videoData!.id, widget.phoneNumber);
        ref
            .read(userProfileNotifier)
            .saveFavouriteTeels(id: widget.videoData!.id, ref: ref);
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controllerA.dispose();
    super.dispose();
  }

  bool isSave = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () {
        _controllerA.forward(from: 0.0);
      },
      child: Transform.scale(
        scale: squareScaleA,
        child: WebsafeSvg.asset(
          favIcon,
          // color: isSave ? Colors.red : Colors.white,
          colorFilter: ColorFilter.mode(
            // Colors.blueGrey,
            //  AppConstants.primaryColor,
            // AppConstants.secondaryColor,
            isSave ? Colors.red : Colors.white,
            // Colors.grey,
            //  Colors.black,
            BlendMode.srcIn,
          ),
          height: 30,
          fit: BoxFit.fitHeight,
        ),
        //  Icon(
        //   CupertinoIcons.heart_fill,
        //   color: isLike ? Colors.red : Colors.white,
        //   size: 30,
        // ),
      ),
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  final String? url;
  final String? postId;
  final Function(VideoPlayerController?) function;

  const _ButterFlyAssetVideo(this.url, this.postId, this.function);

  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url!),
      // isCached: Platform.isAndroid,
    );
    _controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _controller!.setLooping(true);
    _controller!.initialize().then((_) => {setState(() {})});
    widget.function.call(_controller);
    _controller!.play();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _controller = null;
    widget.function.call(null);
    super.dispose();
  }

  bool isIncreaseView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: () {
              if (_controller != null && _controller!.value.isPlaying) {
                _controller!.pause();
              } else {
                _controller!.play();
              }
            },
            child: Center(
              child: SizedBox.expand(
                child: FittedBox(
                  fit: _controller?.value != null &&
                          _controller?.value.size != null &&
                          _controller?.value.size.width != null &&
                          _controller?.value.size.height != null &&
                          (_controller!.value.size.width >=
                                  (_controller!.value.size.height) ||
                              _controller?.value.size.height ==
                                  _controller?.value.size.width)
                      ? BoxFit.fitWidth
                      : BoxFit.cover,
                  child: SizedBox(
                    width: _controller?.value.size.width ?? 0,
                    height: _controller?.value.size.height ?? 0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Center(
                          child: VisibilityDetector(
                            onVisibilityChanged: (VisibilityInfo info) {},
                            key: Key(widget.postId.toString()),
                            child: VideoPlayer(
                              _controller!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
