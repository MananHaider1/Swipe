// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_result, unnecessary_null_comparison, unused_local_variable

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:lamatdating/widgets/Subscriptions/subscription_widget.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/settings/verification/verification_steps.dart';
import 'package:lamatdating/views/tabs/profile/edit_profile_page.dart'
    if (dart.library.html) 'package:lamatdating/views/tabs/profile/edit_profile_page_web.dart';
import 'package:lamatdating/views/tabs/profile/followers/followers_page.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, ref) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final userProfileRef = ref.watch(userProfileFutureProvider);
    final walletAsyncValue = ref.watch(walletsStreamProvider);
    final observer = ref.watch(observerProvider);
    final prefs = ref.watch(sharedPreferences).value;
    String method = "";

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

    return walletAsyncValue.when(
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          ref.read(createNewWalletProvider);
          ref.refresh(walletsStreamProvider);
          return const Center(child: CircularProgressIndicator());
        } else {
          final wallet = WalletsModel.fromMap(
              snapshot.docs.first.data() as Map<String, dynamic>);
          AppRes.walletBalance = wallet.balance;
          return userProfileRef.when(
            data: (data) {
              int percentageComplete = _getProfilePercentageComplete(data!);
              final List<String> profilepic = [data.profilePicture ?? ""];
              return data == null
                  ? Center(child: Text(LocaleKeys.nousersfound.tr()))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height * .08,
                        ),
                        Stack(
                          children: [
                            Column(
                              children: [
                                const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue * 4),
                                Center(
                                  child: ClipRRect(
                                    child: Container(
                                      // width:
                                      //     MediaQuery.of(context).size.width *
                                      //         0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                        color: Colors.white12,
                                      ),
                                      padding: const EdgeInsets.all(
                                          AppConstants.defaultNumericValue),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal:
                                              AppConstants.defaultNumericValue),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                                height: AppConstants
                                                        .defaultNumericValue *
                                                    5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${data.fullName},",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: AppConstants
                                                            .defaultNumericValue *
                                                        1.2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: AppConstants
                                                          .defaultNumericValue /
                                                      2,
                                                ),
                                                Text(
                                                  (DateTime.now()
                                                              .difference(
                                                                  data.birthDay)
                                                              .inDays ~/
                                                          365)
                                                      .toString(),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: AppConstants
                                                            .defaultNumericValue *
                                                        1.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "${data.myPostLikes}",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                      !Responsive.isDesktop(
                                                              context)
                                                          ? Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FollowersConsumerPage(
                                                                            followers:
                                                                                data.followers!,
                                                                            title:
                                                                                LocaleKeys.followers.tr(),
                                                                          )))
                                                          : ref
                                                              .read(
                                                                  arrangementProvider
                                                                      .notifier)
                                                              .setArrangement(
                                                                  FollowersConsumerPage(
                                                                followers: data
                                                                    .followers!,
                                                                title: LocaleKeys
                                                                    .followers
                                                                    .tr(),
                                                              ));
                                                    },
                                                    child: SizedBox(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            '${data.followers!.length}',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            LocaleKeys.followers
                                                                .tr(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      !Responsive.isDesktop(
                                                              context)
                                                          ? Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FollowersConsumerPage(
                                                                            followers:
                                                                                data.following!,
                                                                            title:
                                                                                LocaleKeys.following.tr(),
                                                                          )))
                                                          : ref
                                                              .read(
                                                                  arrangementProvider
                                                                      .notifier)
                                                              .setArrangement(
                                                                  FollowersConsumerPage(
                                                                followers: data
                                                                    .following!,
                                                                title: LocaleKeys
                                                                    .following
                                                                    .tr(),
                                                              ));
                                                    },
                                                    child: SizedBox(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            '${data.following!.length}',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            LocaleKeys.following
                                                                .tr(),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                data.about!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: AppConstants
                                                          .defaultNumericValue *
                                                      1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppConstants
                                                    .defaultNumericValue),
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
                                            AppConstants.defaultNumericValue *
                                                10),
                                        border: Border.all(
                                            color: Colors.transparent,
                                            width: AppConstants
                                                    .defaultNumericValue /
                                                2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue *
                                                10),
                                        child: SizedBox(
                                          width:
                                              AppConstants.defaultNumericValue *
                                                  7,
                                          height:
                                              AppConstants.defaultNumericValue *
                                                  7,
                                          child: data.profilePicture == null ||
                                                  data.profilePicture!.isEmpty
                                              ? CircleAvatar(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  child: const Icon(
                                                    CupertinoIcons.person_fill,
                                                    color: AppConstants
                                                        .primaryColor,
                                                    size: AppConstants
                                                            .defaultNumericValue *
                                                        5,
                                                  ),
                                                )
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      data.profilePicture!,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                          child:
                                                              CircularProgressIndicator
                                                                  .adaptive()),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Center(
                                                              child: Icon(
                                                                  Icons.error)),
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
                                              builder: (context) =>
                                                  SinglePhotoViewPage(
                                                      images: profilepic,
                                                      index: 0,
                                                      title: LocaleKeys.images
                                                          .tr()),
                                            ),
                                          );
                                        },
                                        child: Transform.rotate(
                                            angle: pi,
                                            child: SizedBox(
                                                width: AppConstants
                                                        .defaultNumericValue *
                                                    8,
                                                height: AppConstants
                                                        .defaultNumericValue *
                                                    8,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 6,
                                                        color: AppConstants
                                                            .secondaryColor,
                                                        value:
                                                            percentageComplete /
                                                                100)))),
                                    Positioned(
                                        top: 10,
                                        right: -10,
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              !(Responsive.isDesktop(context))
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditProfilePage(
                                                                  userProfileModel:
                                                                      data),
                                                          fullscreenDialog:
                                                              true))
                                                  : ref
                                                      .read(arrangementProvider
                                                          .notifier)
                                                      .setArrangement(
                                                          EditProfilePage(
                                                              userProfileModel:
                                                                  data));
                                            }, // icon of the button
                                            style: ElevatedButton.styleFrom(
                                              // styling the button
                                              shadowColor: Colors.black,
                                              shape: const CircleBorder(),
                                              padding: const EdgeInsets.all(6),
                                              backgroundColor:
                                                  Colors.white, // Button color
                                              foregroundColor:
                                                  Colors.white, // Splash color
                                            ),
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: WebsafeSvg.asset(
                                                  height: 25,
                                                  width: 25,
                                                  fit: BoxFit.fitHeight,
                                                  editIcon,
                                                   colorFilter: const ColorFilter.mode(
                                                    Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                )),
                                          ),
                                        )),
                                    const ProfileCompletenessAndGetVerifiedWidget(),
                                  ],
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: AppConstants.defaultNumericValue / 2,
                        ),
                        SubscriptionBuilder(builder: (context, isPremiumUser) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      // width: width * .27,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Teme.isDarktheme(prefs!)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        WebsafeSvg.asset(
                                          superLikeIcon,
                                          height: 20,
                                          width: 20,
                                          colorFilter: const ColorFilter.mode(
                                                    Colors.blueAccent,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                          fit: BoxFit.fitHeight,
                                        ),
                                        Text(
                                            (FreemiumLimitation
                                                            .maxDailySuperLikeLimitFree !=
                                                        0 &&
                                                    totalSuperLiked <=
                                                        FreemiumLimitation
                                                            .maxDailySuperLikeLimitPremium)
                                                ? '${FreemiumLimitation.maxDailySuperLikeLimitFree - totalSuperLiked} ${LocaleKeys.superlikes.tr()}'
                                                : "0",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppConstants
                                                    .subtitleTextColor)),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: -0,
                                      child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: FloatingActionButton(
                                            backgroundColor:
                                                Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Container(
                                                    decoration: BoxDecoration(
                                                        color: Teme.isDarktheme(
                                                                prefs)
                                                            ? AppConstants
                                                                .backgroundColorDark
                                                            : AppConstants
                                                                .backgroundColor,
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue)),
                                                    height: height * .6,
                                                    width: width * .8,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * .05,
                                                            vertical:
                                                                height * .1),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Center(
                                                            child: Text(
                                                          LocaleKeys
                                                              .upgradetoGold
                                                              .tr(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 22,
                                                              color: Color(
                                                                  0xFFE9A238)),
                                                        )),
                                                        Center(
                                                          child:
                                                              AppRes.appLogo !=
                                                                      null
                                                                  ? Image
                                                                      .network(
                                                                      AppRes
                                                                          .appLogo!,
                                                                      width:
                                                                          120,
                                                                      height:
                                                                          120,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    )
                                                                  : Image.asset(
                                                                      AppConstants
                                                                          .logo,
                                                                      color: AppConstants
                                                                          .primaryColor,
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          150,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                        ),
                                                        Center(
                                                            child: Text(
                                                          '${LocaleKeys.superlikeupto.tr()} ${FreemiumLimitation.maxDailySuperLikeLimitPremium} ${LocaleKeys.timesperday.tr()}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        )),
                                                        Center(
                                                            child: Text(
                                                          LocaleKeys
                                                              .andallthefeaturesofGold
                                                              .tr(),
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 14,
                                                          ),
                                                        )),
                                                        Container(
                                                          width: width,
                                                          height: 1,
                                                          color: const Color(
                                                              0xFFE9A238),
                                                        ),
                                                        isPremiumUser ||
                                                                data.isPremium!
                                                            ? const SizedBox()
                                                            : Row(
                                                                children: [
                                                                  Expanded(
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                          child: CustomButton(
                                                                            text:
                                                                                LocaleKeys.continu.tr(),
                                                                            onPressed:
                                                                                () {
                                                                              showModalBottomSheet(context: context, constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top*2),
                                isScrollControlled:
                                    true, builder: (context) => const SubscriptionWidget());
                                                                            },
                                                                          )))
                                                                ],
                                                              ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                            LocaleKeys.cancel
                                                                .tr()
                                                                .toUpperCase(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .grey),
                                                          )),
                                                        )
                                                      ],
                                                    )),
                                              );
                                            },
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(AppConstants
                                                            .defaultNumericValue *
                                                        2))),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      // width: width * .27,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Teme.isDarktheme(prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        WebsafeSvg.asset(
                                          boltIcon,
                                          height: 20,
                                          width: 20,
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
                                        Text(
                                            '${data.boostBalance} ${LocaleKeys.boosts.tr()}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppConstants
                                                    .subtitleTextColor)),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: -0,
                                      child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: FloatingActionButton(
                                            heroTag: Boosters1,
                                            backgroundColor:
                                                Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder:
                                                      (BuildContext context) {
                                                    return GestureDetector(
                                                      onVerticalDragDown:
                                                          (details) {},
                                                      child: Container(
                                                        height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height,
                                                        color: Teme.isDarktheme(
                                                                prefs)
                                                            ? AppConstants
                                                                .backgroundColorDark
                                                            : AppConstants
                                                                .backgroundColor,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            SizedBox(
                                                              height:
                                                                  height * .05,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      AppConstants
                                                                          .defaultNumericValue),
                                                              child:
                                                                  CustomAppBar(
                                                                leading:
                                                                    CustomIconButton(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            AppConstants.defaultNumericValue /
                                                                                1.5),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        color: AppConstants
                                                                            .primaryColor,
                                                                        icon:
                                                                            closeIcon),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  height * .03,
                                                            ),
                                                            Center(
                                                              child: Text(
                                                                LocaleKeys
                                                                    .beseenfirst
                                                                    .tr(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  height * .02,
                                                            ),
                                                            Text(
                                                              LocaleKeys
                                                                  .beatopprofilein
                                                                  .tr(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  height * .02,
                                                            ),
                                                            CarouselSlider(
                                                              options:
                                                                  CarouselOptions(
                                                                height: height *
                                                                    .42,
                                                                enableInfiniteScroll:
                                                                    false,
                                                              ),
                                                              items: [
                                                                {
                                                                  'category':
                                                                      LocaleKeys
                                                                          .cheapest
                                                                          .tr()
                                                                          .toUpperCase(),
                                                                  'title':
                                                                      '1 ${LocaleKeys.boost.tr()}',
                                                                  'description':
                                                                      oneBoostCost
                                                                          .toString(),
                                                                  'save':
                                                                      "${LocaleKeys.no.tr()} ${LocaleKeys.save.tr()}",
                                                                  'color': Teme
                                                                          .isDarktheme(
                                                                              prefs)
                                                                      ? AppConstants
                                                                          .backgroundColorDark
                                                                      : AppConstants
                                                                          .backgroundColor,
                                                                },
                                                                {
                                                                  'category':
                                                                      LocaleKeys
                                                                          .popular
                                                                          .tr()
                                                                          .toUpperCase(),
                                                                  'title':
                                                                      '$popularBoostAmount ${LocaleKeys.boosts.tr()}',
                                                                  'description':
                                                                      popularBoostCost
                                                                          .toString(),
                                                                  'save': '${LocaleKeys.save.tr()} ${100 - ((popularBoostCost / (oneBoostCost * popularBoostAmount) * 100)).round()}%'
                                                                      .toUpperCase(),
                                                                  'color': Teme
                                                                          .isDarktheme(
                                                                              prefs)
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
                                                                      bestValueCost
                                                                          .toString(),
                                                                  'save': '${LocaleKeys.save.tr()} ${100 - ((bestValueCost / (oneBoostCost * bestValueBoostAmount) * 100)).round()}%'
                                                                      .toUpperCase(),
                                                                  'color': Teme
                                                                          .isDarktheme(
                                                                              prefs)
                                                                      ? AppConstants
                                                                          .backgroundColorDark
                                                                      : AppConstants
                                                                          .backgroundColor,
                                                                },
                                                                // Add more items here
                                                              ].map<
                                                                  Widget>((Map<
                                                                      String,
                                                                      dynamic>
                                                                  item) {
                                                                return Builder(
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return Container(
                                                                      width:
                                                                          width,
                                                                      height:
                                                                          height *
                                                                              .4,
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: item[
                                                                            'color'],
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.grey,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(AppConstants.defaultNumericValue),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.1),
                                                                            spreadRadius:
                                                                                10.0,
                                                                            blurRadius:
                                                                                25.0,
                                                                            offset:
                                                                                const Offset(0, 0), // changes position of shadow
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: height * .06,
                                                                              decoration: BoxDecoration(
                                                                                color: AppConstants.primaryColor.withOpacity(.1),
                                                                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppConstants.defaultNumericValue * .95), topRight: Radius.circular(AppConstants.defaultNumericValue * .95)),
                                                                              ),
                                                                              child: Center(
                                                                                child: Text(item['category'], style: const TextStyle(color: AppConstants.primaryColor, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                              )),
                                                                          SizedBox(
                                                                            height:
                                                                                height * .02,
                                                                          ),
                                                                          Text(
                                                                              item['title'],
                                                                              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                          SizedBox(
                                                                            height:
                                                                                height * .02,
                                                                          ),
                                                                          Text(
                                                                              "${item['description']} ${LocaleKeys.diamonds.tr()}",
                                                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                          SizedBox(
                                                                            height:
                                                                                height * .01,
                                                                          ),
                                                                          Container(
                                                                            padding:
                                                                                const EdgeInsets.symmetric(vertical: AppConstants.defaultNumericValue / 2, horizontal: AppConstants.defaultNumericValue),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: AppConstants.primaryColor.withOpacity(.1),
                                                                              borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 2),
                                                                            ),
                                                                            child:
                                                                                Text(item['save'], style: const TextStyle(color: AppConstants.primaryColor, fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                height * .02,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Expanded(
                                                                                  child: Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                                child: CustomButton(
                                                                                    onPressed: () async {
                                                                                      EasyLoading.show();
                                                                                      try {
                                                                                        await minusBalanceProvider(
                                                                                                ref,
                                                                                                (item['category'] == LocaleKeys.cheapest.tr().toUpperCase())
                                                                                                    ? oneBoostCost.toDouble()
                                                                                                    : (item['category'] == LocaleKeys.popular.tr().toUpperCase())
                                                                                                        ? popularBoostCost.toDouble()
                                                                                                        : bestValueCost.toDouble())
                                                                                            .then((value) async {
                                                                                          final newUserProfileModel = data.copyWith(
                                                                                            boostBalance: (item['category'] == LocaleKeys.cheapest.tr().toUpperCase())
                                                                                                ? data.boostBalance + 1
                                                                                                : (item['category'] == LocaleKeys.popular.tr().toUpperCase())
                                                                                                    ? data.boostBalance + popularBoostAmount
                                                                                                    : data.boostBalance + bestValueBoostAmount,
                                                                                          );
                                                                                          (value)
                                                                                              ? {
                                                                                                  await ref.read(userProfileNotifier).updateUserProfile(newUserProfileModel).then((value) {
                                                                                                    EasyLoading.dismiss();
                                                                                                    ref.invalidate(userProfileFutureProvider);
                                                                                                    EasyLoading.showSuccess(LocaleKeys.success.tr());
                                                                                                  })
                                                                                                }
                                                                                              : {
                                                                                                  EasyLoading.showError(LocaleKeys.purchaseFailed.tr())
                                                                                                };
                                                                                        });
                                                                                      } catch (e) {
                                                                                        EasyLoading.dismiss(); // Hide loading indicator
                                                                                        if (kDebugMode) showERRORSheet(context, e.toString());
                                                                                      }

                                                                                      // EasyLoading.dismiss();
                                                                                    },
                                                                                    text: LocaleKeys.select.tr().toUpperCase()),
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
                                                                  width: width /
                                                                      2.5,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                Text(
                                                                  LocaleKeys.or
                                                                      .tr(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                Container(
                                                                  height: 1,
                                                                  width: width /
                                                                      2.5,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                                const SizedBox(
                                                                  width: AppConstants
                                                                      .defaultNumericValue,
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              width: width,
                                                              height:
                                                                  height * .2,
                                                              margin: const EdgeInsets
                                                                  .all(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Teme
                                                                        .isDarktheme(
                                                                            prefs)
                                                                    ? AppConstants
                                                                        .backgroundColorDark
                                                                    : AppConstants
                                                                        .backgroundColor,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppConstants
                                                                            .defaultNumericValue),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.1),
                                                                    spreadRadius:
                                                                        10.0,
                                                                    blurRadius:
                                                                        25.0,
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
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      height:
                                                                          height *
                                                                              .06,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                        borderRadius: const BorderRadius
                                                                            .only(
                                                                            topLeft: Radius.circular(AppConstants.defaultNumericValue *
                                                                                .95),
                                                                            topRight:
                                                                                Radius.circular(AppConstants.defaultNumericValue * .95)),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child: Text(
                                                                            '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                                                                            style: const TextStyle(
                                                                                color: AppConstants.primaryColor,
                                                                                fontSize: 16.0,
                                                                                fontWeight: FontWeight.bold)),
                                                                      )),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            .02,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      AppRes.appLogo !=
                                                                              null
                                                                          ? Image
                                                                              .network(
                                                                              AppRes.appLogo!,
                                                                              width: 40,
                                                                              height: 40,
                                                                              fit: BoxFit.contain,
                                                                            )
                                                                          : Image
                                                                              .asset(
                                                                              AppConstants.logo,
                                                                              width: 40,
                                                                              height: 40,
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                      Text(
                                                                        LocaleKeys
                                                                            .getgold
                                                                            .tr(),
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                      isPremiumUser ||
                                                                              data.isPremium!
                                                                          ? const SizedBox()
                                                                          : Padding(
                                                                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                              child: OutlinedButton(
                                                                                onPressed: () {
                                                                                  // SubscriptionBuilder.showSubscriptionBottomSheet(context: context);
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (context) => Container(
                                                                                        decoration: BoxDecoration(color: Teme.isDarktheme(prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor, borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue)),
                                                                                        height: height * .6,
                                                                                        width: width * .8,
                                                                                        margin: EdgeInsets.symmetric(horizontal: width * .05, vertical: height * .1),
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                          children: [
                                                                                            Center(
                                                                                                child: Text(
                                                                                              LocaleKeys.upgradetoGold.tr(),
                                                                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFFE9A238)),
                                                                                            )),
                                                                                            Center(
                                                                                              child: AppRes.appLogo != null
                                                                                                  ? Image.network(
                                                                                                      AppRes.appLogo!,
                                                                                                      width: 120,
                                                                                                      height: 120,
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
                                                                                            isPremiumUser || data.isPremium!
                                                                                                ? const SizedBox()
                                                                                                : Row(
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                          child: Padding(
                                                                                                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                                                              child: CustomButton(
                                                                                                                text: LocaleKeys.continu.tr(),
                                                                                                                onPressed: () {
                                                                                                                  showModalBottomSheet(context: context, constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top*2),
                                isScrollControlled:
                                    true, builder: (context) => const SubscriptionWidget());
                                                                                                                },
                                                                                                              )))
                                                                                                    ],
                                                                                                  ),
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
                                                                                style: OutlinedButton.styleFrom(
                                                                                    side: const BorderSide(width: 1, color: Colors.grey),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue * 2),
                                                                                    )),
                                                                                child: Text(
                                                                                  LocaleKeys.select.tr().toUpperCase(),
                                                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                              )),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        height *
                                                                            .02,
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(AppConstants
                                                            .defaultNumericValue *
                                                        2))),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      // width: width * .27,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Teme.isDarktheme(prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        WebsafeSvg.asset(
                                          homeIcon,
                                          height: 35,
                                          width: 35,
                                          colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: -0,
                                      child: SizedBox(
                                          width: 25,
                                          height: 25,
                                          child: FloatingActionButton(
                                            heroTag: Boosters,
                                            backgroundColor:
                                                Teme.isDarktheme(prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Container(
                                                    decoration: BoxDecoration(
                                                        color: Teme.isDarktheme(
                                                                prefs)
                                                            ? AppConstants
                                                                .backgroundColorDark
                                                            : AppConstants
                                                                .backgroundColor,
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue)),
                                                    height: height * .6,
                                                    width: width * .8,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * .05,
                                                            vertical:
                                                                height * .1),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Center(
                                                            child: Text(
                                                          LocaleKeys
                                                              .upgradetoGold
                                                              .tr(),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 22,
                                                              color: Color(
                                                                  0xFFE9A238)),
                                                        )),
                                                        Center(
                                                          child:
                                                              AppRes.appLogo !=
                                                                      null
                                                                  ? Image
                                                                      .network(
                                                                      AppRes
                                                                          .appLogo!,
                                                                      width:
                                                                          120,
                                                                      height:
                                                                          120,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    )
                                                                  : Image.asset(
                                                                      AppConstants
                                                                          .logo,
                                                                      color: AppConstants
                                                                          .primaryColor,
                                                                      width:
                                                                          150,
                                                                      height:
                                                                          150,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                        ),
                                                        Row(children: [
                                                          const SizedBox(
                                                            width: AppConstants
                                                                .defaultNumericValue,
                                                          ),
                                                          const CircleAvatar(
                                                            radius: 2,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          )
                                                        ]),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                .defaultNumericValue),
                                                        Row(children: [
                                                          const SizedBox(
                                                            width: AppConstants
                                                                .defaultNumericValue,
                                                          ),
                                                          const CircleAvatar(
                                                            radius: 2,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            '${LocaleKeys.superlikeupto.tr()} ${FreemiumLimitation.maxDailySuperLikeLimitPremium} ${LocaleKeys.timesperday.tr()}',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          )
                                                        ]),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                .defaultNumericValue),
                                                        Row(children: [
                                                          const SizedBox(
                                                            width: AppConstants
                                                                .defaultNumericValue,
                                                          ),
                                                          const CircleAvatar(
                                                            radius: 2,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            '${LocaleKeys.rewindupto.tr()} ${FreemiumLimitation.maxDailyRewindLimitPremium} ${LocaleKeys.timesperday.tr()}',
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          )
                                                        ]),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                .defaultNumericValue),
                                                        Row(children: [
                                                          const SizedBox(
                                                            width: AppConstants
                                                                .defaultNumericValue,
                                                          ),
                                                          const CircleAvatar(
                                                            radius: 2,
                                                            backgroundColor:
                                                                Colors.blueGrey,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            LocaleKeys.noads
                                                                .tr(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          )
                                                        ]),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                .defaultNumericValue),
                                                        Center(
                                                            child: InkWell(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          const WebViewScreen(
                                                                              1),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  LocaleKeys
                                                                      .learnmoreabtgold
                                                                      .tr(),
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          14,
                                                                      color: AppConstants
                                                                          .secondaryColor),
                                                                ))),
                                                        Container(
                                                          width: width,
                                                          height: 1,
                                                          color: const Color(
                                                              0xFFE9A238),
                                                        ),
                                                        isPremiumUser ||
                                                                data.isPremium!
                                                            ? const SizedBox()
                                                            : Row(
                                                                children: [
                                                                  Expanded(
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultNumericValue),
                                                                          child: CustomButton(
                                                                            text:
                                                                                LocaleKeys.continu.tr(),
                                                                            onPressed:
                                                                                () {
                                                                              showModalBottomSheet(context: context, constraints: BoxConstraints(
                                    maxHeight: height -
                                        MediaQuery.of(context).padding.top*2),
                                isScrollControlled:
                                    true, builder: (context) => const SubscriptionWidget());
                                                                            },
                                                                          )))
                                                                ],
                                                              ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                            LocaleKeys.noThanks
                                                                .tr()
                                                                .toUpperCase(),
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .grey),
                                                          )),
                                                        )
                                                      ],
                                                    )),
                                              );
                                            },
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(AppConstants
                                                            .defaultNumericValue *
                                                        2))),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        })
                      ],
                    );
            },
            error: (_, e) =>
                const Center(child: Text(LocaleKeys.somethingWentWrong)),
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
          child: Text(
        LocaleKeys.erroroccured.tr(),
      )),
    );
  }
}

class SuperLikes {}

class Boosters {}

class Boosters1 {}

class ProfileCompletenessAndGetVerifiedWidget extends ConsumerWidget {
  const ProfileCompletenessAndGetVerifiedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final user = ref.watch(userProfileFutureProvider);
    return user.when(
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
                    !(Responsive.isDesktop(context))
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditProfilePage(userProfileModel: data),
                                fullscreenDialog: true))
                        : ref.read(arrangementProvider.notifier).setArrangement(
                            EditProfilePage(userProfileModel: data));
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
          gradient: AppConstants.premiumGradient,
          boxShadow: [
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
                    LocaleKeys.ok.tr(),
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
                            color: Colors.white,
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
                            color: Colors.white,
                          )),
      ),
    );
  }
}
