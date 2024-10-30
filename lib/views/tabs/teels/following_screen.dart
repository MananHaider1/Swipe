// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';

import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';

import 'package:lamatdating/views/video/item_video.dart';

class FollowingScreen extends ConsumerStatefulWidget {
  final UserProfileModel? user;
  final VoidCallback? onNavigateBack;
  const FollowingScreen({
    super.key,
    required this.user,
    this.onNavigateBack,
  });

  @override
  ConsumerState<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends ConsumerState<FollowingScreen>
    with AutomaticKeepAliveClientMixin {
  List<Widget> mList = [];
  List<Widget> mListFollow = [];
  int start = 0;
  int limit = 10;
  List<String> teelsUser = [];
  List<bool> isFollowing = [];

  List<String> teelsToFollow = [];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    final userProfile = ref.read(userProfileNotifier);
    final filteredUsers = ref.watch(filteredOtherUsersProvider(ref));
    final List<Widget> usersToFollow = filteredUsers.when(
      data: (data) {
        if (data.isNotEmpty) {
          for (var i = 0; i < data.length; i++) {
            isFollowing.add(false);
          }
          return data
              .where((user) => teelsToFollow.contains(user.phoneNumber))
              .toList()
              .map((user) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * .6,
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultNumericValue),
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(user.profilePicture!),
                      fit: BoxFit.cover)),
              // Add your container widget properties here
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultNumericValue / 2,
                      horizontal: AppConstants.defaultNumericValue,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue / 2),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue / 2),
                            color: Colors.black38,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => UserDetailsPage(
                                          user: user,
                                        ),
                                      ),
                                    ).then((value) {
                                      widget.onNavigateBack?.call();
                                    });
                                  },
                                  child: Text("@${user.userName}",
                                      maxLines:
                                          1, // Set the maximum number of lines
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          )),
                                ),
                                const Spacer(),
                                Text(user.followers!.length.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(Icons.people, color: Colors.white),
                                const Spacer(),
                                CustomButton(
                                  color: isFollowing[data.indexOf(user)]
                                      ? AppConstants.primaryColor
                                          .withOpacity(.5)
                                      : AppConstants.primaryColor,
                                  text: isFollowing[data.indexOf(user)]
                                      ? LocaleKeys.following.tr()
                                      : LocaleKeys.follow.tr(),
                                  onPressed: () {
                                    userProfile.followUnfollow(
                                        followUser: user.phoneNumber, ref: ref);
                                    // Update isFollowing after follow/unfollow action
                                    isFollowing[data.indexOf(user)] =
                                        !isFollowing[data.indexOf(user)];
                                    setState(() {});
                                  },
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        } else {
          return [];
        }
      },
      error: (Object error, StackTrace stackTrace) {
        // Handle error case
        return [];
      },
      loading: () {
        // Handle loading case
        return [];
      },
    );

    PageController pageController = PageController();

    return teelsListAsyncValue.when(
      data: (teelsList) {
        // teelsToFollow = teelsList;
        final myFollowers = widget.user!.following;
        final followingTeels = teelsList
            .where((element) =>
                myFollowers!.any((user) => user == element.phoneNumber))
            .toList();
        int end = (start + limit > followingTeels.length)
            ? followingTeels.length
            : start + limit;

        List<Widget> newItems = [];
        if (followingTeels.isNotEmpty) {
          int itemCount = ((end - start) <= 0) ? 0 : end - start;
          if (start + itemCount > followingTeels.length) {
            itemCount = followingTeels.length - start;
          }
          newItems = List<Widget>.generate(
            itemCount,
            (index) => Container(
                color: AppConstants.backgroundColorDark,
                child: ItemVideo(followingTeels[start + index], false)),
          );
        }

        List<String> teelsUserPhone = followingTeels
            .map((e) => e.phoneNumber)
            .where((element) => element != widget.user!.phoneNumber)
            .toList();
        setState(() {
          teelsUser = teelsUserPhone;
        });

        List<String> teelsUsersPhone = teelsList
            .map((e) => e.phoneNumber)
            .where((element) => element != widget.user!.phoneNumber)
            .toList();
        setState(() {
          teelsToFollow = teelsUsersPhone;
        });

        if (mList.isEmpty && newItems.isNotEmpty) {
          mList = newItems;
        } else if (newItems.isNotEmpty) {
          mList.addAll(newItems);
        }

        List<Widget> newItemsFollow = followingTeels.isNotEmpty
            ? List<Widget>.generate(
                ((end - start) < 0) ? 0 : end - start,
                (index) => Container(
                    color: AppConstants.backgroundColorDark,
                    child: ItemVideo(followingTeels[start + index], false)),
              )
            : [];
        mListFollow.addAll(newItemsFollow);
        // if (kDebugMode) {
        //   print(mList.toString());
        // }

        setState(() {});
        (start + limit > followingTeels.length)
            ? start = followingTeels.length
            : start += limit;

        return mList.isNotEmpty
            ? PageView(
                physics: const ClampingScrollPhysics(),
                controller: pageController,
                pageSnapping: true,
                onPageChanged: (value) {
                  if (kDebugMode) {
                    print(value);
                  }
                  if (value == mList.length - 1) {
                    getLatestTeels();
                  }
                },
                scrollDirection: Axis.vertical,
                children: mList,
              )
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                  ),
                  AppRes.appLogo != null
                      ? Image.network(
                          AppRes.appLogo!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          AppConstants.logo,
                          color: AppConstants.primaryColor,
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Text(
                  //   LocaleKeys.popularCreator,
                  //   style: const TextStyle(
                  //       fontSize: 18,
                  //       fontFamily: fNSfUiSemiBold,
                  //       color: Colors.black),
                  // ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    LocaleKeys.followSomeCreatorsTonWatchTheirVideos.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppConstants.textColorLight,
                      fontFamily: fNSfUiRegular,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(bottom: 50),
                      margin: const EdgeInsets.only(top: 30),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: true,
                          scrollPhysics: const BouncingScrollPhysics(),
                          height: MediaQuery.of(context).size.width +
                              (MediaQuery.of(context).size.width / 100),
                          enableInfiniteScroll: true,
                          viewportFraction: 0.65,
                        ),
                        items: usersToFollow,
                      ),
                    ),
                  )
                  // : NoItemFoundWidget(text: LocaleKeys.noMediafound)
                ],
              );
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    );
  }

  Future<void> getLatestTeels() async {
    final teelsListAsyncValue = ref.watch(getTeelsProvider);

    teelsListAsyncValue.when(
      data: (teelsList) {
        final myFollowers = widget.user!.following;
        final followingTeels = teelsList
            .where((element) =>
                myFollowers!.any((user) => user == element.phoneNumber))
            .toList();
        int end = (start + limit > followingTeels.length)
            ? followingTeels.length
            : start + limit;
        if (kDebugMode) {
          print("Teels => ${followingTeels.length.toString()}");
        }

        List<Widget> newItems = List<Widget>.generate(
          end - start,
          (index) => Container(
              color: AppConstants.backgroundColorDark,
              child: ItemVideo(followingTeels[start + index], false)),
        );

        if (mList.isEmpty) {
          mList = newItems;
        } else {
          mList.addAll(newItems);
        }
        if (kDebugMode) {
          print(mList.toString());
        }

        setState(() {});
        (start + limit > followingTeels.length)
            ? start = followingTeels.length - 1
            : start += limit;
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    );
  }
}
