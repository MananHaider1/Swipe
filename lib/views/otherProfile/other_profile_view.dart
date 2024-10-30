// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_result, unnecessary_null_comparison, unused_local_variable, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/profile/followers/followers_page.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/report/report_page.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/plan_date/create_meetup_page.dart';
import 'package:lamatdating/views/settings/verification/verification_steps.dart';
import 'package:lamatdating/views/tabs/home/user_card_widget.dart';
import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';
import 'package:lamatdating/views/tabs/profile/edit_profile_page.dart';

class OtherProfileView extends ConsumerStatefulWidget {
  final DataModel model;
  final UserProfileModel user;
  final String? matchId;
  final List<String> userImages;
  const OtherProfileView(
      {required this.user,
      required this.userImages,
      this.matchId,
      required this.model,
      super.key});

  @override
  ConsumerState<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends ConsumerState<OtherProfileView>
    with WidgetsBindingObserver {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final CustomPopupMenuController _moreMenuController =
      CustomPopupMenuController();
  String? deviceid;
  var mapDeviceInfo = {};
  SharedPreferences? prefs;
  TabController? controller;

  bool isFetching = true;
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

  bool isPurchaseDialogOpen = false;

  @override
  void initState() {
    getPrefs();
    // if (!kIsWeb) {
    setdeviceinfo();
    // }

    WidgetsBinding.instance.addObserver(this);

    super.initState();
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

  @override
  void didChangeDependencies() async {
    myphoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber!;

    getModel();
    super.didChangeDependencies();
  }

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
      } else if (Platform.isIOS == true) {
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

  void _onTapSendMessage() async {
    // _moreMenuController.hideMenu();
    final prefs = ref.watch(sharedPreferences).value;
    final String myphoneNumber =
        ref.watch(currentUserStateProvider)!.phoneNumber!;
    DataModel? _cachedModel;
    _cachedModel ??= DataModel(myphoneNumber);
    final MatchModel matchModel = MatchModel(
      id: myphoneNumber + widget.user.phoneNumber,
      userIds: [myphoneNumber, widget.user.phoneNumber],
      isMatched: false,
    );
    (Responsive.isDesktop(context))
        ? {
            ref.read(arrangementProviderExtend.notifier).setArrangement(PreChat(
                  name: widget.user.fullName,
                  phone: widget.user.phoneNumber,
                  currentUserNo:
                      ref.watch(currentUserStateProvider)!.phoneNumber,
                  model: _cachedModel,
                  prefs: prefs!,
                )),
            updateCurrentIndex(ref, 10),
          }
        : Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PreChat(
                  name: widget.user.fullName,
                  phone: widget.user.phoneNumber,
                  currentUserNo:
                      ref.watch(currentUserStateProvider)!.phoneNumber,
                  model: _cachedModel,
                  prefs: prefs!,
                )));

    // await createConversation(matchModel).then((matchResult) async {
    //   if (matchResult) {
    //     EasyLoading.dismiss();
    //     Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) => PreChat(
    //           name: widget.user.fullName,
    //           phone: widget.user.phoneNumber,
    //           currentUserNo: ref.watch(currentUserStateProvider)!.phoneNumber,
    //           model: _cachedModel,
    //           prefs: prefs!,
    //         ),
    //         // ChatScreen(
    //         //                 isSharingIntentForwarded: false,
    //         //                 prefs: prefs!,
    //         //                 unread: 0,
    //         //                 currentUserNo: myphoneNumber,
    //         //                 model: widget.model,
    //         //                 peerNo: widget.user.phoneNumber)
    //       ),
    //     );
    //   } else {
    //     EasyLoading.showInfo(LocaleKeys.somethingWentWrong.tr());
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final PageController _pageController = PageController();
    final currentUserProfile = ref.watch(userProfileFutureProvider);
    final String myphoneNumber =
        ref.watch(currentUserStateProvider)!.phoneNumber!;
    final String id = myphoneNumber + widget.user.phoneNumber;
    final userProfile = ref.read(userProfileNotifier);
    final followers = ref.watch(getFollowers(widget.user.phoneNumber));

    bool canLike = true;
    bool canSuperLike = true;
    bool canDislike = true;
    int currentIndex = 0;
    bool? isUser;
    bool? istyping;
    bool? isLoading;
    bool? isShowOnlySpinner;

    return SubscriptionBuilder(builder: (context, isPremiumUser) {
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

      int totalLiked =
          interactionsToday.where((element) => element.isLike).toList().length;

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
            totalSuperLiked >= FreemiumLimitation.maxDailySuperLikeLimitFree) {
          canSuperLike = false;
        }

        if (FreemiumLimitation.maxDailyDislikeLimitFree != 0 &&
            totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitFree) {
          canDislike = false;
        }
      }
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      final List<String> profPic = [widget.user.profilePicture!];

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: height * .07,
          ),
          Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: AppConstants.defaultNumericValue * 4),
                  Center(
                    child: ClipRRect(
                      child: Container(
                        // width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue),
                          color: Colors.white12,
                        ),
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue),
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultNumericValue),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                  height: AppConstants.defaultNumericValue * 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${widget.user.fullName},",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          AppConstants.defaultNumericValue *
                                              1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AppConstants.defaultNumericValue / 2,
                                  ),
                                  Text(
                                    (DateTime.now()
                                                .difference(
                                                    widget.user.birthDay)
                                                .inDays ~/
                                            365)
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize:
                                          AppConstants.defaultNumericValue *
                                              1.2,
                                    ),
                                  ),
                                  if (widget.user.isVerified)
                                    GestureDetector(
                                      onTap: () {
                                        EasyLoading.showToast(
                                            LocaleKeys.verifiedUser.tr());
                                      },
                                      child: const Padding(
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              left: AppConstants
                                                      .defaultNumericValue /
                                                  2),
                                          child: Image(
                                            image: AssetImage(verifiedIcon),
                                            height: 20,
                                            width: 20,
                                          )),
                                    ),
                                  if (widget.user.isBoosted)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5,
                                          left:
                                              AppConstants.defaultNumericValue /
                                                  2),
                                      child: WebsafeSvg.asset(
                                        boostedIcon,
                                        // color: const Color(0xFFFF8543),
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFFFF8543),
                                          BlendMode.srcIn,
                                        ),
                                        width: 22,
                                        height: 22,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                ],
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "${widget.user.myPostLikes}",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          LocaleKeys.likes.tr(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        )
                                      ],
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          !Responsive.isDesktop(context)
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowersConsumerPage(
                                                            followers: widget
                                                                .user
                                                                .followers!,
                                                            title: LocaleKeys
                                                                .followers
                                                                .tr(),
                                                          )))
                                              : ref
                                                  .read(arrangementProvider
                                                      .notifier)
                                                  .setArrangement(
                                                      FollowersConsumerPage(
                                                    followers:
                                                        widget.user.followers!,
                                                    title: LocaleKeys.followers
                                                        .tr(),
                                                  ));
                                        },
                                        child: SizedBox(
                                            child: Column(
                                          children: [
                                            Text(
                                              '${widget.user.followers!.length}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              LocaleKeys.followers.tr(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ))),
                                    GestureDetector(
                                        onTap: () {
                                          !Responsive.isDesktop(context)
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FollowersConsumerPage(
                                                            followers: widget
                                                                .user
                                                                .following!,
                                                            title: LocaleKeys
                                                                .following
                                                                .tr(),
                                                          )))
                                              : ref
                                                  .read(arrangementProvider
                                                      .notifier)
                                                  .setArrangement(
                                                      FollowersConsumerPage(
                                                    followers:
                                                        widget.user.following!,
                                                    title: LocaleKeys.following
                                                        .tr(),
                                                  ));
                                        },
                                        child: SizedBox(
                                            child: Column(
                                          children: [
                                            Text(
                                              '${widget.user.following!.length}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              LocaleKeys.following.tr(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ))),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            followers.when(
                                                data: (allfollowers) {
                                                  return (allfollowers.contains(
                                                          myphoneNumber))
                                                      ? showModalBottomSheet(
                                                          context: context,
                                                          backgroundColor: Teme
                                                                  .isDarktheme(
                                                                      prefs!)
                                                              ? AppConstants
                                                                  .backgroundColorDark
                                                              : AppConstants
                                                                  .backgroundColor,
                                                          barrierColor:
                                                              AppConstants
                                                                  .primaryColor
                                                                  .withOpacity(
                                                                      .3),
                                                          constraints:
                                                              BoxConstraints(
                                                            maxHeight:
                                                                height * .5,
                                                          ),
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .vertical(
                                                              top: Radius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                            ),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            return StatefulBuilder(
                                                                builder: (BuildContext
                                                                        context,
                                                                    StateSetter
                                                                        setrState) {
                                                              return Column(
                                                                  children: [
                                                                    const SizedBox(
                                                                      height: AppConstants
                                                                          .defaultNumericValue,
                                                                    ),
                                                                    Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                AppConstants.defaultNumericValue,
                                                                          ),
                                                                          InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: WebsafeSvg.asset(
                                                                                closeIcon,
                                                                                colorFilter: const ColorFilter.mode(
                                                                                  // Colors.blueGrey,
                                                                                  //  AppConstants.primaryColor,
                                                                                  AppConstants.secondaryColor,
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
                                                                            width:
                                                                                width * .33,
                                                                          ),
                                                                          Container(
                                                                              width: AppConstants.defaultNumericValue * 3,
                                                                              height: 4,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(16),
                                                                                color: AppConstants.hintColor,
                                                                              )),
                                                                        ]),
                                                                    const SizedBox(
                                                                      width: AppConstants
                                                                          .defaultNumericValue,
                                                                    ),
                                                                    Text(
                                                                      widget
                                                                          .user
                                                                          .userName,
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .titleLarge!
                                                                          .copyWith(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Teme.isDarktheme(prefs!) ? Colors.white : Colors.black),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          AppConstants.defaultNumericValue *
                                                                              2,
                                                                    ),

                                                                    // Start Content
                                                                    Container(
                                                                      height: 1,
                                                                      width:
                                                                          width,
                                                                      color: AppConstants
                                                                          .hintColor,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        userProfile.followUnfollow(
                                                                            followUser:
                                                                                widget.user.phoneNumber,
                                                                            ref: ref);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(LocaleKeys
                                                                            .unfollow
                                                                            .tr()),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                        left: AppConstants
                                                                            .defaultNumericValue,
                                                                      ),
                                                                      height: 1,
                                                                      width:
                                                                          width,
                                                                      color: AppConstants
                                                                          .hintColor,
                                                                    ),

                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _moreMenuController
                                                                            .hideMenu();
                                                                        showBlockDialog(
                                                                            context,
                                                                            widget.user.phoneNumber,
                                                                            myphoneNumber);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(LocaleKeys
                                                                            .block
                                                                            .tr()),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                        left: AppConstants
                                                                            .defaultNumericValue,
                                                                      ),
                                                                      height:
                                                                          .5,
                                                                      width:
                                                                          width,
                                                                      color: AppConstants
                                                                          .hintColor,
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _moreMenuController
                                                                            .hideMenu();
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ReportPage(userProfileModel: widget.user),
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(LocaleKeys
                                                                            .report
                                                                            .tr()),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: 1,
                                                                      width:
                                                                          width,
                                                                      color: AppConstants
                                                                          .hintColor,
                                                                    ),
                                                                    // End Content
                                                                    const SizedBox(
                                                                        height:
                                                                            AppConstants.defaultNumericValue *
                                                                                2),
                                                                  ]);
                                                            });
                                                          })
                                                      : {
                                                          userProfile.followUnfollow(
                                                              followUser: widget
                                                                  .user
                                                                  .phoneNumber,
                                                              ref: ref),
                                                          setState(() {})
                                                        };
                                                },
                                                loading: () => {},
                                                error: (_, __) => {});
                                          },
                                          child: Container(
                                              height: 40,
                                              // width: width * .2,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: followers.when(
                                                  data: (allfollowers) {
                                                    return (allfollowers
                                                            .contains(
                                                                myphoneNumber))
                                                        ? Colors.black
                                                            .withOpacity(.3)
                                                        : AppConstants
                                                            .backgroundColor
                                                            .withOpacity(.3);
                                                  },
                                                  loading: () => AppConstants
                                                      .secondaryColor,
                                                  error: (_, __) => AppConstants
                                                      .secondaryColor,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(AppConstants
                                                            .defaultNumericValue *
                                                        .6),
                                              ),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        followers.when(
                                                          data: (allfollowers) {
                                                            return (allfollowers
                                                                    .contains(
                                                                        myphoneNumber))
                                                                ? LocaleKeys
                                                                    .following
                                                                    .tr()
                                                                : LocaleKeys
                                                                    .follow
                                                                    .tr();
                                                          },
                                                          loading: () =>
                                                              LocaleKeys.follow
                                                                  .tr(),
                                                          error: (_, __) =>
                                                              LocaleKeys.follow
                                                                  .tr(),
                                                        ),
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    const SizedBox(width: 5),
                                                    followers.when(
                                                      data: (allfollowers) {
                                                        return (allfollowers
                                                                .contains(
                                                                    myphoneNumber))
                                                            ? const Icon(
                                                                CupertinoIcons
                                                                    .chevron_down,
                                                                size: 16,
                                                                color: Colors
                                                                    .white)
                                                            : const SizedBox();
                                                      },
                                                      loading: () =>
                                                          const SizedBox(),
                                                      error: (_, __) =>
                                                          const SizedBox(),
                                                    ),
                                                  ])),
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Expanded(
                                        child: InkWell(
                                            onTap: () => _onTapSendMessage(),
                                            child: Container(
                                              height: 40,
                                              // width: width * .2,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppConstants
                                                    .backgroundColor
                                                    .withOpacity(.3),
                                                borderRadius: BorderRadius
                                                    .circular(AppConstants
                                                            .defaultNumericValue *
                                                        .6),
                                              ),
                                              child: Center(
                                                child: Text(LocaleKeys.msg.tr(),
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white)),
                                              ),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      // OutlinedButton(
                                      //   onPressed: () {
                                      //     custom_url_launcher(
                                      //         "https://instagram.com/${widget.user.instaUrl}");
                                      //   },
                                      //   style: OutlinedButton.styleFrom(
                                      //     side: const BorderSide(
                                      //       color: Colors.transparent,
                                      //     ),
                                      //   ),
                                      //   child: WebsafeSvg.asset(instagramLogo,
                                      //       color: Colors.white),
                                      // ),
                                      // const SizedBox(
                                      //   width:
                                      //       AppConstants.defaultNumericValue /
                                      //           2,
                                      // ),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CustomPopupMenu(
                                          menuBuilder: () => ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.white),
                                              child: IntrinsicWidth(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    MoreMenuTitle(
                                                      icon: meetupIcon,
                                                      title: LocaleKeys
                                                          .requestDate,
                                                      onTap: () async {
                                                        _moreMenuController
                                                            .hideMenu();

                                                        !Responsive.isDesktop(
                                                                context)
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      CreateMeetupPage(
                                                                          user:
                                                                              widget.user),
                                                                ),
                                                              )
                                                            : ref
                                                                .read(arrangementProviderExtend
                                                                    .notifier)
                                                                .setArrangement(
                                                                    CreateMeetupPage(
                                                                        user: widget
                                                                            .user));

                                                        // custom_url_launcher(
                                                        //     "https://facebook.com/${widget.user.fbUrl}");
                                                      },
                                                    ),
                                                    MoreMenuTitle(
                                                      icon: giftIcon,
                                                      title:
                                                          LocaleKeys.sendGift,
                                                      onTap: () async {
                                                        _moreMenuController
                                                            .hideMenu();
                                                        showModalBottomSheet(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          builder: (context) {
                                                            return GiftSheet(
                                                              onAddDymondsTap:
                                                                  onAddDymondsTap,
                                                              onGiftSend:
                                                                  (gift) async {
                                                                EasyLoading.show(
                                                                    status: LocaleKeys
                                                                        .sendinggift
                                                                        .tr());

                                                                int value = gift!
                                                                    .coinPrice!;

                                                                sendGiftProvider(
                                                                    giftCost:
                                                                        value,
                                                                    recipientId:
                                                                        widget
                                                                            .user
                                                                            .phoneNumber);
                                                                // print("${gift.coinPrice}");

                                                                // onCommentSend(
                                                                //     commentType: FirebaseConst.image, msg: gift.image ?? '');
                                                                Future.delayed(
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
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
                                                        // custom_url_launcher(
                                                        //     "https://youtube.com/${widget.user.youtubeUrl}");
                                                      },
                                                    ),
                                                    // MoreMenuTitle(
                                                    //   icon: instagramLogo,
                                                    //   title: "Instagram",
                                                    //   onTap: () async {
                                                    //     _moreMenuController
                                                    //         .hideMenu();
                                                    //     custom_url_launcher(
                                                    //         "https://instagram.com/${widget.user.instaUrl}");
                                                    //   },
                                                    // )
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
                                          barrierColor: AppConstants
                                              .primaryColor
                                              .withOpacity(0.1),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _moreMenuController.showMenu();
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: AppConstants
                                                    .backgroundColor
                                                    .withOpacity(.3),
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue *
                                                          .6), // Adjust radius as desired
                                                )),
                                            child: WebsafeSvg.asset(
                                              height: 18,
                                              width: 18,
                                              fit: BoxFit.fitHeight,
                                              downArrowAlt,
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
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              Center(
                                  child: Text(widget.user.about!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      )))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue * 10),
                          border: Border.all(
                              color: Colors.transparent,
                              width: AppConstants.defaultNumericValue / 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue * 10),
                          child: SizedBox(
                            width: AppConstants.defaultNumericValue * 7,
                            height: AppConstants.defaultNumericValue * 7,
                            child: widget.user.profilePicture == null ||
                                    widget.user.profilePicture!.isEmpty
                                ? CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: AppConstants.primaryColor,
                                      size:
                                          AppConstants.defaultNumericValue * 5,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: widget.user.profilePicture!,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator
                                            .adaptive()),
                                    errorWidget: (context, url, error) =>
                                        const Center(child: Icon(Icons.error)),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SinglePhotoViewPage(
                                    images: profPic,
                                    index: 0,
                                    title: LocaleKeys.images.tr()),
                              ),
                            );
                          },
                          child: Transform.rotate(
                              angle: pi,
                              child: const SizedBox(
                                  width: AppConstants.defaultNumericValue * 8,
                                  height: AppConstants.defaultNumericValue * 8,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 6,
                                      color: AppConstants.secondaryColor,
                                      value: 100 / 100)))),
                      Positioned(
                        top: 10,
                        right: -10,
                        child: widget.user.isOnline
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: OnlineStatus(),
                              )
                            : const SizedBox(),
                      ),
                      // const ProfileCompletenessAndGetVerifiedWidget(),
                    ],
                  )),
            ],
          ),
        ],
      );
    });
  }
}

class ProfileCompletenessAndGetVerifiedWidget extends ConsumerWidget {
  const ProfileCompletenessAndGetVerifiedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final userCurrent = ref.watch(userProfileFutureProvider);
    return userCurrent.when(
      data: (data) {
        int percentageComplete = _getProfilePercentageComplete(data!);

        debugPrint('USer verificaitons status:${data.isVerified}');

        return percentageComplete == 100
            ? data.isVerified
                ? const SizedBox()
                : Positioned(
                    bottom: 0,
                    left: 0,
                    child: CustomButtonComplete(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GetVerifiedPage(user: data),
                          ),
                        );
                      },
                      text: LocaleKeys.getVerified.tr(),
                    ))
            : Positioned(
                bottom: 0,
                left: 0,
                child: CustomButtonComplete(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(userProfileModel: data),
                      ),
                    );
                  },
                  text: "$percentageComplete% ${LocaleKeys.complete.tr()}",
                ));
      },
      error: (error, stackTrace) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }
}

int _getProfilePercentageComplete(UserProfileModel profile) {
  int total = 100;

  if (profile.about == null || profile.about!.isEmpty) {
    total -= 10;
  }

  if ((profile.phoneNumber == null || profile.phoneNumber.isEmpty) &&
      (profile.email == null || profile.email!.isEmpty)) {
    total -= 10;
  }

  // Images
  if (profile.mediaFiles.isEmpty) {
    total -= 10;
  }

  // Interests
  if (profile.interests.isEmpty) {
    total -= 10;
  }

  //Profile Picture
  if (profile.profilePicture == null || profile.profilePicture!.isEmpty) {
    total -= 10;
  }

  return total;
}

class CustomButtonComplete extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final IconData? icon;
  final Widget? child;
  final bool isWhite;
  final Color? borderColor;

  const CustomButtonComplete({
    super.key,
    required this.onPressed,
    this.text,
    this.icon,
    this.isWhite = false,
    this.borderColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
        color: isWhite ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold);
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 2),
      onTap: onPressed,
      splashColor: AppConstants.primaryColor,
      child: Container(
        width: AppConstants.defaultNumericValue * 9.3,
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultNumericValue * 1.5, vertical: 5),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppConstants.defaultNumericValue * 2),
          gradient: const LinearGradient(
              colors: [AppConstants.primaryColor, Color(0xFF9875FF)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter),
          color: isWhite ? Colors.white : null,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
          boxShadow: isWhite
              ? null
              : [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: AppConstants.defaultNumericValue * 2,
                    spreadRadius: AppConstants.defaultNumericValue / 4,
                    offset: const Offset(0, AppConstants.defaultNumericValue),
                  ),
                ],
        ),
        child: child ??
            (text == null && icon == null
                ? Text(
                    LocaleKeys.next.tr(),
                    textAlign: TextAlign.center,
                    style: buttonTextStyle,
                  )
                : text != null && icon != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            color: isWhite ? Colors.black : Colors.white,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                          Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          ),
                          const SizedBox(
                              width: AppConstants.defaultNumericValue),
                        ],
                      )
                    : text != null
                        ? Text(
                            text!,
                            textAlign: TextAlign.center,
                            style: buttonTextStyle,
                          )
                        : Icon(
                            icon!,
                            color: isWhite ? Colors.black : Colors.white,
                          )),
      ),
    );
  }
}
