// ignore_for_file: unused_element, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/plan_date/create_meetup_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/widgets/Subscriptions/subscription_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/lottie/lottie_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
// import 'package:lamatdating/views/plan_date/create_meetup_page.dart';

class UserCardWidget extends ConsumerStatefulWidget {
  final UserProfileModel user;
  final VoidCallback onTapCross;
  final VoidCallback onTapHeart;
  final VoidCallback onTapBolt;
  final VoidCallback? onTapRewind;
  final VoidCallback? onTapBoost;
  final VoidCallback? onNavigateBack;
  final SharedPreferences prefs;
  final UserProfileModel currentUserProf;
  const UserCardWidget({
    super.key,
    required this.user,
    required this.onTapCross,
    required this.onTapHeart,
    required this.onTapBolt,
    this.onTapRewind,
    this.onTapBoost,
    this.onNavigateBack,
    required this.prefs,
    required this.currentUserProf,
  });

  @override
  ConsumerState<UserCardWidget> createState() => _UserCardWidgetState();
}

class _UserCardWidgetState extends ConsumerState<UserCardWidget> {
  final List<String> _images = [];
  final PageController _pageController = PageController();
  Box<dynamic>? box;
  // UserProfileModel? currentUserProf;
  DataModel? _cachedModel;

  @override
  void initState() {
    if (widget.user.profilePicture != null) {
      _images.add(widget.user.profilePicture!);
    }
    for (var image in widget.user.mediaFiles) {
      _images.add(image);
    }

    getModel();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var imageUrl in _images) {
        precacheImage(NetworkImage(imageUrl), context);
      }
    });
    super.initState();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   for (var imageUrl in _images) {
  //      precacheImage(NetworkImage(imageUrl), context);
  //   }
  // }

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.prefs.getString(Dbkeys.phone));
    return _cachedModel;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final prefs = ref.watch(sharedPreferencesProvider).value;
    final myProfile = ref.watch(userProfileFutureProvider).value;

    return GridTile(
      header: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 5,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final screenWidth = constraints.maxWidth;
              final dotWidth = (screenWidth * .87) / _images.length;

              return SmoothPageIndicator(
                controller: _pageController, // PageController
                count: _images.length,
                effect: WormEffect(
                    dotHeight: 5,
                    dotWidth: dotWidth, // set the width of the dot
                    activeDotColor: Colors.white,
                    dotColor: Colors.black54), // your preferred effect
                onDotClicked: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
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
      footer: ClipRRect(
        child:
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            //   child:
            Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [
                  0,
                  0.3,
                  1
                ]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.user.isOnline
                      ? const Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: AppConstants.defaultNumericValue,
                                bottom: AppConstants.defaultNumericValue / 2),
                            child: OnlineStatus(),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 5),
                  widget.user.isBoosted
                      ? Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppConstants.defaultNumericValue / 2,
                              top: 5,
                              left: AppConstants.defaultNumericValue / 2),
                          child: WebsafeSvg.asset(
                            boostedIcon,
                           colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                            width: 26,
                            height: 26,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              // const SizedBox(height: AppConstants.defaultNumericValue),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      // width: width * .85,
                      child: GestureDetector(
                          onTap: () async {
                            (!Responsive.isDesktop(context))
                                ? await Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => UserDetailsPage(
                                        user: widget.user,
                                      ),
                                    ),
                                  ).then((value) {
                                    widget.onNavigateBack?.call();
                                  })
                                : ref
                                    .read(arrangementProvider.notifier)
                                    .setArrangement(UserDetailsPage(
                                      user: widget.user,
                                    ));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: AppConstants.defaultNumericValue),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${widget.user.nickname} ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 32,
                                        ),
                                      ),
                                      if (widget.user.userAccountSettingsModel
                                              .showAge !=
                                          false)
                                        TextSpan(
                                          text: (DateTime.now()
                                                      .difference(
                                                          widget.user.birthDay)
                                                      .inDays ~/
                                                  365)
                                              .toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 25),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              widget.user.isVerified
                                  ? GestureDetector(
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
                                            height: 24,
                                            width: 24,
                                          )),
                                    )
                                  : const SizedBox(),
                            ],
                          )),
                    ),
                  ),
                  InkWell(
                      onTap: () async {
                        !Responsive.isDesktop(context)
                            ? Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PreChat(
                                      prefs: widget.prefs,
                                      model: _cachedModel,
                                      name: widget.user.nickname,
                                      phone: widget.user.phoneNumber,
                                      currentUserNo:
                                          widget.currentUserProf.phoneNumber),
                                ),
                              )
                            : ref
                                .read(arrangementProviderExtend.notifier)
                                .setArrangement(PreChat(
                                    prefs: widget.prefs,
                                    model: _cachedModel,
                                    name: widget.user.nickname,
                                    phone: widget.user.phoneNumber,
                                    currentUserNo:
                                        widget.currentUserProf.phoneNumber));
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: WebsafeSvg.asset(
                            mailIcon,
                            height: 40,
                            width: 40,
                           colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                            fit: BoxFit.contain,
                          ),
                        ),
                      )),
                  const SizedBox(
                    width: AppConstants.defaultNumericValue / 2,
                  ),
                  InkWell(
                      onTap: () async {
                        (!Responsive.isDesktop(context))
                            ? showModalBottomSheet<void>(
                                context: context,
                                builder: (BuildContext context) {
                                  return UserDetailsPage(
                                    user: widget.user,
                                  ); // Replace with your actual full-screen page widget
                                },
                                constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top),
                                isScrollControlled:
                                    true, // Makes the sheet full screen
                              )
                            : ref
                                .read(arrangementProvider.notifier)
                                .setArrangement(UserDetailsPage(
                                  user: widget.user,
                                ));
                        // await Navigator.push(
                        //   context,
                        //   CupertinoPageRoute(
                        //     builder: (context) => UserDetailsPage(
                        //       user: widget.user,
                        //     ),
                        //   ),
                        // ).then((value) {
                        //   widget.onNavigateBack?.call();
                        // });
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: WebsafeSvg.asset(
                          upwardArrow,
                          height: 40,
                          width: 40,
                          colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                          fit: BoxFit.contain,
                        ),
                      )),
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  )
                ],
              ),
              Consumer(
                builder: (context, ref, child) {
                  final myProfile = ref.watch(userProfileFutureProvider);
                  int? currentPageIndex = _pageController.page?.round();
                  return myProfile.when(
                      data: (data) {
                        if (data != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(
                                  height: AppConstants.defaultNumericValue / 4),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left:
                                        AppConstants.defaultNumericValue / 1.2),
                                child: (currentPageIndex == 0)
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          WebsafeSvg.asset(
                                            height: 22,
                                            width: 22,
                                            fit: BoxFit.fitHeight,
                                            houseIcon,
                                            colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                          ),
                                          const SizedBox(
                                              width: AppConstants
                                                      .defaultNumericValue /
                                                  4),
                                          Text(
                                            (widget
                                                    .user
                                                    .userAccountSettingsModel
                                                    .location
                                                    .addressText)
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 16),
                                          )
                                        ],
                                      )
                                    : (currentPageIndex == 1)
                                        ? InterestsSimilarityList(
                                            otherUser: widget.user,
                                            myProfile: data,
                                            color: Colors.white)
                                        : (currentPageIndex == 2)
                                            ? Text(
                                                (widget.user.about).toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  WebsafeSvg.asset(
                                                    height: 22,
                                                    width: 22,
                                                    fit: BoxFit.fitHeight,
                                                    houseIcon,
                                                   colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                  ),
                                                  const SizedBox(
                                                      width: AppConstants
                                                              .defaultNumericValue /
                                                          4),
                                                  Text(
                                                    (widget
                                                            .user
                                                            .userAccountSettingsModel
                                                            .location
                                                            .addressText)
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 16),
                                                  )
                                                ],
                                              ),
                              ),
                              const SizedBox(
                                  height: AppConstants.defaultNumericValue / 4),
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  (currentPageIndex == 1)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: AppConstants
                                                  .defaultNumericValue),
                                          child: InterestsSimilarityWidget(
                                            otherUser: widget.user,
                                            myProfile: data,
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              left: AppConstants
                                                      .defaultNumericValue /
                                                  1.2),
                                          child: Row(children: [
                                            Expanded(
                                                child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                WebsafeSvg.asset(
                                                  height: 22,
                                                  width: 22,
                                                  fit: BoxFit.fitHeight,
                                                  pinIcon,
                                                  colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                ),
                                                const SizedBox(
                                                    width: AppConstants
                                                            .defaultNumericValue /
                                                        4),
                                                Text(
                                                  '${(Geolocator.distanceBetween(data.userAccountSettingsModel.location.latitude, data.userAccountSettingsModel.location.longitude, widget.user.userAccountSettingsModel.location.latitude, widget.user.userAccountSettingsModel.location.longitude) / 1000).toStringAsFixed(2)} ${LocaleKeys.kmsAway.tr()}',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16),
                                                )
                                              ],
                                            )),
                                            LottieButton(
                                              onPressed: () {
                                                !Responsive.isDesktop(context)
                                                    ? Navigator.of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              CreateMeetupPage(
                                                                  user: widget
                                                                      .user),
                                                        ),
                                                      )
                                                    : ref
                                                        .read(
                                                            arrangementProvider
                                                                .notifier)
                                                        .setArrangement(
                                                            CreateMeetupPage(
                                                                user: widget
                                                                    .user));
                                                // !Responsive.isDesktop(context)
                                                //     ? Navigator.of(context)
                                                //         .push(
                                                //         MaterialPageRoute(
                                                //           builder: (context) => PreChat(
                                                //               prefs:
                                                //                   widget.prefs,
                                                //               model:
                                                //                   _cachedModel,
                                                //               name: widget.user
                                                //                   .nickname,
                                                //               phone: widget.user
                                                //                   .phoneNumber,
                                                //               currentUserNo: widget
                                                //                   .currentUserProf
                                                //                   .phoneNumber),
                                                //         ),
                                                //       )
                                                //     : ref
                                                //         .read(
                                                //             arrangementProviderExtend
                                                //                 .notifier)
                                                //         .setArrangement(
                                                //             // CreateMeetupPage(
                                                //             //     user: widget
                                                //             //         .user)
                                                //             PreChat(
                                                //                 prefs: widget
                                                //                     .prefs,
                                                //                 model:
                                                //                     _cachedModel,
                                                //                 name: widget
                                                //                     .user
                                                //                     .nickname,
                                                //                 phone: widget
                                                //                     .user
                                                //                     .phoneNumber,
                                                //                 currentUserNo: widget
                                                //                     .currentUserProf
                                                //                     .phoneNumber));
                                              },
                                              lottieAsset:
                                                  'assets/json/lottie/button.json',
                                              child: Stack(
                                                children: [
                                                  Text(
                                                    LocaleKeys.planMeetup.tr(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      foreground: Paint()
                                                        ..style =
                                                            PaintingStyle.stroke
                                                        ..strokeWidth = 2
                                                        ..color = Colors.black
                                                            .withOpacity(.5),
                                                        
                                                    ),
                                                  ),
                                                  Text(
                                                    LocaleKeys.planMeetup.tr(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        )
                                ],
                              ),
                              const SizedBox(
                                  height: AppConstants.defaultNumericValue),
                              UserLikeActions(
                                  onTapCross: widget.onTapCross,
                                  onTapBolt: widget.onTapBolt,
                                  onTapHeart: widget.onTapHeart,
                                  onTapRewind: widget.onTapRewind,
                                  onTapBoost: widget.onTapBoost,
                                  showShadow: true,
                                  isDetailsPage: false,
                                  currentUserProf: widget.currentUserProf),
                              // if (!Responsive.isDesktop(context) && !kIsWeb)
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          AppConstants.defaultNumericValue),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                      error: (_, __) => const SizedBox(),
                      loading: () => const SizedBox());
                },
              ),
              if (!Responsive.isDesktop(context))
                const SizedBox(height: AppConstants.defaultNumericValue * 4),
            ],
          ),
        ),
      ),
      child: PageView(
        controller: _pageController,
        onPageChanged: (_) {
          setState(() {});
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _images.map((e) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.only(bottom: 56),
                decoration: BoxDecoration(
                  color: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                ),
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl: e,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder:
                        (context, child, loadingProgress) {
                      // if (loadingProgress == null) return child;
                      return Center(
                        child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: LottieBuilder.asset(
                    lottieSearch,
                    width: 250,
                    height: 250,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
                ),
                CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                       widget.currentUserProf.profilePicture!
                         ,
                    ),
                    backgroundColor: Colors.transparent,
                  ),
              ],
            ),
                      );
                    },
                    errorWidget: (context, error, stackTrace) {
                      return const Center(
                          child: Icon(CupertinoIcons.photo,
                              color: AppConstants.primaryColor));
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
                          HapticFeedback.lightImpact();
                          if (_pageController.page! == 0) return;
                          _pageController.previousPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (_pageController.page! == _images.length - 1) {
                            return;
                          }
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
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
    );
  }
}

class InterestsSimilarityWidget extends StatelessWidget {
  final UserProfileModel otherUser;
  final UserProfileModel myProfile;
  final Color? color;
  const InterestsSimilarityWidget({
    super.key,
    required this.otherUser,
    required this.myProfile,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final myInterests = myProfile.interests;
    final otherInterests = otherUser.interests;

    double similarity = 0;
    for (final interest in myInterests) {
      if (otherInterests.contains(interest)) {
        similarity++;
      }
    }

    double percentage = (similarity / myInterests.length) * 100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.join_inner,
          size: 16,
          color: color ?? Colors.white,
        ),
        const SizedBox(width: AppConstants.defaultNumericValue / 4),
        Text(
          '${percentage.toStringAsFixed(0)}% ${LocaleKeys.similarity.tr()}',
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class InterestsSimilarityList extends StatelessWidget {
  final UserProfileModel otherUser;
  final UserProfileModel myProfile;
  final Color? color;
  const InterestsSimilarityList({
    super.key,
    required this.otherUser,
    required this.myProfile,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final myInterests = myProfile.interests;
    final otherInterests = otherUser.interests;

    double similarity = 0;
    for (final interest in myInterests) {
      if (otherInterests.contains(interest)) {
        similarity++;
      }
    }

    double percentage = (similarity / myInterests.length) * 100;

    return Wrap(
      spacing: 8.0, // gap between adjacent chips
      runSpacing: 4.0, // gap between lines
      children: otherInterests.map((String interest) {
        return ChoiceChip(
          label: Text(interest,
              style: TextStyle(
                  color: myInterests.contains(interest)
                      ? Colors.white
                      : Colors.black,
                  fontWeight: myInterests.contains(interest)
                      ? FontWeight.bold
                      : FontWeight.normal)),
          selected: myInterests.contains(interest),
          shape: myInterests.contains(interest)
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                  side: const BorderSide(
                      color: AppConstants.primaryColor, width: 1),
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue * 2),
                  side: const BorderSide(color: Colors.transparent, width: 1),
                ),
          onSelected: (bool selected) {},
          showCheckmark: false,
          selectedColor: AppConstants.primaryColor.withOpacity(.7),
          disabledColor: color!.withOpacity(0.2),
          backgroundColor: color!.withOpacity(0.2),
        );
      }).toList()
        ..sort((a, b) {
          return a.selected
              ? 1
              : b.selected
                  ? 1
                  : 0;
        }),
    );
  }
}

class UserLikeActions extends ConsumerWidget {
  final VoidCallback onTapCross;
  final VoidCallback onTapBolt;
  final VoidCallback onTapHeart;
  final VoidCallback? onTapRewind;
  final VoidCallback? onTapBoost;
  final bool? isDetailsPage;
  final bool showShadow;
  final UserProfileModel currentUserProf;
  const UserLikeActions(
      {super.key,
      required this.onTapCross,
      required this.onTapBolt,
      required this.onTapHeart,
      this.onTapRewind,
      this.onTapBoost,
      this.isDetailsPage,
      this.showShadow = false,
      required this.currentUserProf});

  @override
  Widget build(BuildContext context, ref) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final prefss = ref.watch(sharedPreferences).value;
    String method = "";

    List<BoxShadow> boxShadow = showShadow
        ? const [
            BoxShadow(
              color: Colors.black45,
              spreadRadius: 4,
              blurRadius: 8,
              offset: Offset(0, 2), // changes position of shadow
            ),
          ]
        : [];

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isDetailsPage! ? 0 : AppConstants.defaultNumericValue),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (!isDetailsPage!)
              ? SubscriptionBuilder(builder: (context, isPremiumUser) {
                  return isPremiumUser || currentUserProf.isPremium!
                      ? GestureDetector(
                          onTap: onTapRewind,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                    AppConstants.defaultNumericValue),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: boxShadow,
                                  color: AppConstants.primaryColorDark
                                      .withOpacity(.5),
                                ),
                                child: Image.asset(
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fitHeight,
                                  rewindIconAlt,
                                ),
                              ),
                              if (AppConfig.showInteractionButtonText)
                                const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 3),
                              if (AppConfig.showInteractionButtonText)
                                Text(AppConfig.dislikeButtonText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => Container(
                                decoration: BoxDecoration(
                                    color: Teme.isDarktheme(prefss!)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.defaultNumericValue)),
                                height: height * .6,
                                width: width * .8,
                                margin: EdgeInsets.symmetric(
                                    horizontal: width * .05,
                                    vertical: height * .1),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Center(
                                        child: Text(
                                      LocaleKeys.upgradetoGold.tr(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22,
                                          color: Color(0xFFE9A238)),
                                    )),
                                    Center(
                                      child: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: AppRes.appLogo != null
                                            ? Image.network(
                                                AppRes.appLogo!,
                                                color: const Color(0xFFE9A238),
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.contain,
                                              )
                                            : Image.asset(
                                                icLogo,
                                                color: const Color(0xFFE9A238),
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                    ),
                                    Center(
                                        child: Text(
                                      '${LocaleKeys.rewindupto.tr()} ${FreemiumLimitation.maxDailyRewindLimitPremium} ${LocaleKeys.timesperday.tr()}',
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
                                    SubscriptionBuilder(
                                        builder: (context, isPremiumUser) {
                                      return isPremiumUser ||
                                              currentUserProf.isPremium!
                                          ? const SizedBox()
                                          : Row(
                                              children: [
                                                Expanded(
                                                    child: Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: AppConstants
                                                                .defaultNumericValue),
                                                        child: CustomButton(
                                                          text: LocaleKeys
                                                              .continu
                                                              .tr(),
                                                          onPressed: () {
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                    constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top*2),
                                isScrollControlled:
                                    true,
                                                                builder:
                                                                    (context) =>
                                                                        const SubscriptionWidget());
                                                            // Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(
                                                            //       builder:
                                                            //           (context) =>
                                                            //               CheckoutPage(
                                                            //                 price: int.parse((50 * 100).toString()),
                                                            //               )),
                                                            // );
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
                                        LocaleKeys.cancel.tr().toUpperCase(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.grey),
                                      )),
                                    )
                                  ],
                                )),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                    AppConstants.defaultNumericValue),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: boxShadow,
                                  color: AppConstants.primaryColorDark
                                      .withOpacity(.5),
                                ),
                                child: Image.asset(
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fitHeight,
                                  rewindIconAlt,
                                  color: Colors.grey,
                                ),
                              ),
                              if (AppConfig.showInteractionButtonText)
                                const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 3),
                              if (AppConfig.showInteractionButtonText)
                                Text(AppConfig.dislikeButtonText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                })
              : Container(),
          GestureDetector(
            onTap: onTapCross,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: boxShadow,
                    color: AppConstants.primaryColorDark.withOpacity(.5),
                  ),
                  child: Image.asset(
                    height: 34,
                    width: 34,
                    fit: BoxFit.fitHeight,
                    dislikeIconAlt,
                  ),
                ),
                if (AppConfig.showInteractionButtonText)
                  const SizedBox(height: AppConstants.defaultNumericValue / 3),
                if (AppConfig.showInteractionButtonText)
                  Text(AppConfig.dislikeButtonText,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppConfig.dislikeButtonColor,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SubscriptionBuilder(builder: (context, isPremiumUser) {
            return isPremiumUser || currentUserProf.isPremium!
                ? GestureDetector(
                    onTap: onTapBolt,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: boxShadow,
                            color:
                                AppConstants.primaryColorDark.withOpacity(.5),
                          ),
                          child: Image.asset(
                            height: 24,
                            width: 24,
                            fit: BoxFit.fitHeight,
                            superLikeIconAlt,
                          ),
                        ),
                        if (AppConfig.showInteractionButtonText)
                          const SizedBox(
                              height: AppConstants.defaultNumericValue / 3),
                        if (AppConfig.showInteractionButtonText)
                          Text(AppConfig.superLikeButtonText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => Container(
                          decoration: BoxDecoration(
                              color: Teme.isDarktheme(prefss!)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue)),
                          height: height * .6,
                          width: width * .8,
                          margin: EdgeInsets.symmetric(
                              horizontal: width * .05, vertical: height * .1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                  child: Text(
                                LocaleKeys.upgradetoGold.tr(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                    color: Color(0xFFE9A238)),
                              )),
                              Center(
                                child: SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: AppRes.appLogo != null
                                      ? Image.network(
                                          AppRes.appLogo!,
                                          color: const Color(0xFFE9A238),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.asset(
                                          icLogo,
                                          color: const Color(0xFFE9A238),
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),
                              Center(
                                  child: Text(
                                '${LocaleKeys.superlikeupto.tr()} ${FreemiumLimitation.maxDailySuperLikeLimitPremium} ${LocaleKeys.timesperday.tr()}',
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
                              SubscriptionBuilder(
                                  builder: (context, isPremiumUser) {
                                return isPremiumUser ||
                                        currentUserProf.isPremium!
                                    ? const SizedBox()
                                    : Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: AppConstants
                                                          .defaultNumericValue),
                                                  child: CustomButton(
                                                    text:
                                                        LocaleKeys.continu.tr(),
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                          context: context,
                                                          constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top*2),
                                isScrollControlled:
                                    true,
                                                          builder: (context) =>
                                                              const SubscriptionWidget());
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
                                  LocaleKeys.cancel.tr().toUpperCase(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.grey),
                                )),
                              )
                            ],
                          )),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: boxShadow,
                            color:
                                AppConstants.primaryColorDark.withOpacity(.5),
                          ),
                          child: Image.asset(
                            height: 24,
                            width: 24,
                            fit: BoxFit.fitHeight,
                            superLikeIconAlt,
                            // color: Colors.grey,
                          ),
                        ),
                        if (AppConfig.showInteractionButtonText)
                          const SizedBox(
                              height: AppConstants.defaultNumericValue / 3),
                        if (AppConfig.showInteractionButtonText)
                          Text(AppConfig.superLikeButtonText,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
          }),
          GestureDetector(
            onTap: onTapHeart,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: boxShadow,
                    color: AppConstants.primaryColorDark.withOpacity(.5),
                  ),
                  child: Image.asset(
                    height: 34,
                    width: 34,
                    fit: BoxFit.fitHeight,
                    likeIconAlt,
                  ),
                ),
                if (AppConfig.showInteractionButtonText)
                  const SizedBox(height: AppConstants.defaultNumericValue / 3),
                if (AppConfig.showInteractionButtonText)
                  Text(AppConfig.likeButtonText,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppConfig.likeButtonColor,
                          fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          (!isDetailsPage!)
              ? GestureDetector(
                  onTap: onTapBoost,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: boxShadow,
                          color: AppConstants.primaryColorDark.withOpacity(.5),
                        ),
                        child: Image.asset(
                          height: 24,
                          width: 24,
                          fit: BoxFit.fitHeight,
                          boltIconAlt,
                        ),
                      ),
                      if (AppConfig.showInteractionButtonText)
                        const SizedBox(
                            height: AppConstants.defaultNumericValue / 3),
                      if (AppConfig.showInteractionButtonText)
                        Text(AppConfig.dislikeButtonText,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class OnlineStatus extends StatelessWidget {
  const OnlineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.onlineStatus,
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black12,
        //     spreadRadius: 0,
        //     blurRadius: 2,
        //     offset: Offset(0, 1), // changes position of shadow
        //   ),
        // ],
      ),
      child: Text(
        LocaleKeys.online.tr(),
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: const Color(0xFF002B4E),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
      ),
    );
  }
}
