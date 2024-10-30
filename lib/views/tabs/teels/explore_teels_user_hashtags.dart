// ignore_for_file: no_logic_in_create_state, use_build_context_synchronously, void_checks

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/match_model.dart';
import 'package:lamatdating/models/notification_model.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/notifiaction_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/comment/comment_screen.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';
import 'package:lamatdating/views/hashtag/videos_by_hashtag.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/report/report_screen.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/home/user_image_card.dart';
import 'package:lamatdating/views/tabs/live/widgets/gift_sheet.dart';
import 'package:lamatdating/views/tabs/profile/profile_nested_page.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

int indexa = 1;

class ExploreAllPage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final int? index;
  const ExploreAllPage({
    super.key,
    this.index,
    required this.prefs,
  });

  @override
  ConsumerState<ExploreAllPage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExploreAllPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.defaultNumericValue),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: CustomAppBar(
              leading: CustomIconButton(
                  icon: leftArrowSvg,
                  onPressed: () {
                    (!Responsive.isDesktop(context))
                        ? Navigator.pop(context)
                        : {
                            updateCurrentIndex(ref, 3),
                            ref.invalidate(arrangementProviderExtend)
                          };
                  },
                  padding: const EdgeInsets.all(
                      AppConstants.defaultNumericValue / 1.8)),
              title: Center(
                child: CustomHeadLine(
                  text: LocaleKeys.exploreTeels.tr(),
                ),
              ),
              trailing: CustomIconButton(
                icon: searchIcon,
                onPressed: () {
                  setState(() {
                    _isSearchBarVisible = !_isSearchBarVisible;
                    _searchController.clear();
                  });
                },
                padding: const EdgeInsets.all(
                    AppConstants.defaultNumericValue / 1.8),
              ),
            ),
          ),
          _isSearchBarVisible
              ? const SizedBox(height: AppConstants.defaultNumericValue)
              : const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(sizeFactor: animation, child: child);
              },
              child: _isSearchBarVisible
                  ? Container(
                      key: const Key('searchBar'),
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 3),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (_) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: LocaleKeys.search.tr(),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            CupertinoIcons.search,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(key: Key('noSearchBar')),
            ),
          ),
          _isSearchBarVisible
              ? const SizedBox(height: AppConstants.defaultNumericValue)
              : const SizedBox(height: 0),
          Expanded(
            child: SubscriptionBuilder(
              builder: (context, isPremiumUser) {
                return ExploreUsersBody(
                  prefs: widget.prefs,
                  index: widget.index,
                  query: _searchController.text,
                  isPremiumUser: isPremiumUser,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreUsersBody extends ConsumerStatefulWidget {
  final String? query;
  final bool isPremiumUser;
  final int? index;
  final SharedPreferences prefs;
  const ExploreUsersBody({
    super.key,
    this.query,
    required this.isPremiumUser,
    required this.prefs,
    this.index,
  });

  @override
  ConsumerState<ExploreUsersBody> createState() => _ExploreUsersBodyState();
}

class _ExploreUsersBodyState extends ConsumerState<ExploreUsersBody> {
  int? _index;
  List<Widget> mList = [];
  int start = 0;
  int limit = 10;

  bool isShowFull = false;

  int? initIndex;

  // int initialIndex;

// var initIndex;

  Future<List<DocumentSnapshot>> fetchHashtags() async {
    final hashtagCollection = FirebaseFirestore.instance.collection('hashtags');
    final hashtagQuerySnapshot = await hashtagCollection.get();
    return hashtagQuerySnapshot.docs;
  }

  @override
  void initState() {
    _index = widget.index;
    if (!widget.isPremiumUser && isAdmobAvailable && !kIsWeb) {
      InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? AndroidAdUnits.interstitialId
            : IOSAdUnits.interstitialId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) async {
            debugPrint('InterstitialAd loaded.');

            await Future.delayed(const Duration(seconds: 4)).then((value) {
              ad.show();
            });
          },
          onAdFailedToLoad: (error) {},
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    PageController pageController = PageController(initialPage: initIndex ?? 0);
    final filteredUsers = ref.watch(filteredOtherUsersProvider(ref));

    return filteredUsers.when(
      data: (users) {
        final interactionProvider = ref.watch(interactionFutureProvider);

        return interactionProvider.when(
          data: (data) {
            final List<UserProfileModel> filteredUsers = [];

            for (final user in users) {
              if (!data.any((element) =>
                  element.intractToUserId.contains(user.phoneNumber))) {
                filteredUsers.add(user);
              }
            }

            if (widget.query != null && widget.query!.isNotEmpty) {
              filteredUsers.retainWhere((element) => element.fullName
                  .toLowerCase()
                  .contains(widget.query!.toLowerCase()));
            }

            return DefaultTabController(
              initialIndex: _index ?? 0,
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    isScrollable: true,
                    labelColor: AppConstants.primaryColor,
                    tabs: [
                      Tab(
                        child: Text(LocaleKeys.users.tr()),
                      ),
                      Tab(
                        child: Text(LocaleKeys.hashtags.tr()),
                      ),
                      Tab(
                        child: Text(LocaleKeys.teels.tr()),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      // final filteredUsers = users
                      //     .where((element) => element.interests.contains(e))
                      //     .toList();

                      filteredUsers.isEmpty
                          ? const NoItemFoundWidget()
                          : GridView(
                              padding: const EdgeInsets.all(
                                  AppConstants.defaultNumericValue),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing:
                                    AppConstants.defaultNumericValue,
                                mainAxisSpacing:
                                    AppConstants.defaultNumericValue,
                              ),
                              children: filteredUsers.map((user) {
                                return UserImageCard(user: user);
                              }).toList(),
                            ),
                      FutureBuilder<List<DocumentSnapshot>>(
                        future: fetchHashtags(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                  '${LocaleKeys.error.tr()}: ${snapshot.error}'),
                            );
                          }

                          final hashtagDocuments = snapshot.data;

                          return GridView.builder(
                            padding: const EdgeInsets.all(
                                AppConstants.defaultNumericValue),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing:
                                  AppConstants.defaultNumericValue,
                              mainAxisSpacing: AppConstants.defaultNumericValue,
                            ),
                            itemCount: hashtagDocuments!.length,
                            itemBuilder: (context, index) {
                              final hashtag = hashtagDocuments[index];
                              final name = hashtag['name'];
                              final image = hashtag['image'];
                              final createdAt = hashtag['createdAt'];

                              return GestureDetector(
                                  onTap: () {},
                                  child: GridTile(
                                    footer: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical:
                                            AppConstants.defaultNumericValue /
                                                2,
                                        horizontal:
                                            AppConstants.defaultNumericValue,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue /
                                                2),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(
                                                AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius
                                                  .circular(AppConstants
                                                          .defaultNumericValue /
                                                      2),
                                              color: Colors.black38,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "#$name",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    header: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(createdAt.toDate().toString())
                                        ],
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                      ),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                          child: CachedNetworkImage(
                                            imageUrl: image,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive()),
                                            errorWidget: (context, url, error) {
                                              return const Center(
                                                  child: Icon(
                                                      CupertinoIcons.photo));
                                            },
                                          )),
                                    ),
                                  ));
                            },
                          );
                        },
                      ),

                      teelsListAsyncValue.when(
                        data: (teelsList) {
                          int end = (start + limit > teelsList.length)
                              ? teelsList.length
                              : start + limit;
                          if (kDebugMode) {
                            print("Teels => ${teelsList.length.toString()}");
                          }

                          List<Widget> newItems = List<Widget>.generate(
                            ((end - start) < 0) ? 0 : end - start,
                            (index) => ItemVideo(
                              teelsList[start + index],
                              prefs: widget.prefs,
                            ),
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
                          (start + limit > teelsList.length)
                              ? start += teelsList.length
                              : start += limit;
                          return Stack(
                            children: [
                              GridView.builder(
                                padding: const EdgeInsets.all(
                                    AppConstants.defaultNumericValue),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing:
                                      AppConstants.defaultNumericValue,
                                  mainAxisSpacing:
                                      AppConstants.defaultNumericValue,
                                ),
                                itemCount: mList.length,
                                itemBuilder: (context, index) {
                                  // final teel = mList[index];
                                  final teelModel = teelsList[index];
                                  // final name = hashtag['name'];
                                  // final image = hashtag['image'];
                                  // final createdAt = hashtag['createdAt'];

                                  return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isEnlarged = true;
                                          initIndex = index;
                                        });

                                        showBottomSheet(
                                          context: context,
                                          builder: (context) => PageView(
                                            physics:
                                                const ClampingScrollPhysics(),
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
                                          ),
                                        );
                                      },
                                      child: GridTile(
                                        footer: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppConstants
                                                    .defaultNumericValue /
                                                2,
                                            horizontal: AppConstants
                                                .defaultNumericValue,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 10.0, sigmaY: 10.0),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                    AppConstants
                                                            .defaultNumericValue /
                                                        2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue /
                                                          2),
                                                  color: Colors.black38,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    teelsList[index].userName,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        header: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Text(DateFormat('dd-MMM-yyyy')
                                                  .format(teelsList[index]
                                                      .createdAt))
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                    .defaultNumericValue),
                                          ),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppConstants
                                                          .defaultNumericValue),
                                              child: CachedNetworkImage(
                                                imageUrl: (teelModel
                                                                .thumbnail !=
                                                            null &&
                                                        teelModel.thumbnail !=
                                                            "")
                                                    ? teelModel.thumbnail!
                                                    : "https://cdn.pixabay.com/photo/2023/01/25/10/52/ai-generated-7743272_1280.jpg",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                        child:
                                                            CircularProgressIndicator
                                                                .adaptive()),
                                                errorWidget:
                                                    (context, url, error) {
                                                  return const Center(
                                                      child: Icon(
                                                          CupertinoIcons.photo,
                                                          color: AppConstants
                                                              .primaryColor,
                                                          size: 30));
                                                },
                                              )),
                                        ),
                                      ));
                                },
                              ),
                              Positioned(
                                  bottom: AppConstants.defaultNumericValue,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomButton(
                                          text: LocaleKeys.more.tr(),
                                          onPressed: () async {
                                            mList.length >= 10
                                                ? await getLatestTeels()
                                                : {};
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: AppConstants
                                                    .defaultNumericValue,
                                                vertical: AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            child: Text(LocaleKeys.more.tr(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              // isEnlarged
                              //     ? PageView(
                              //         physics: const ClampingScrollPhysics(),
                              //         controller: pageController,
                              //         pageSnapping: true,
                              //         onPageChanged: (value) {
                              //           if (kDebugMode) {
                              //             print(value);
                              //           }
                              //           if (value == mList.length - 1) {
                              //             getLatestTeels();
                              //           }
                              //         },
                              //         scrollDirection: Axis.vertical,
                              //         children: mList,
                              //       )
                              //     : const SizedBox()
                            ],
                          );
                        },
                        loading: () => const LoadingPage(),
                        error: (e, _) => const ErrorPage(),
                      )
                    ]),
                  )
                ],
              ),
            );
          },
          error: (_, __) => Center(
            child: Text(LocaleKeys.somethingWentWrong.tr()),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
      error: (_, __) => Center(
        child: Text(LocaleKeys.somethingWentWrong.tr()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }

  Future<void> getLatestTeels() async {
    final teelsListAsyncValue = ref.watch(getTeelsProvider);

    teelsListAsyncValue.when(
      data: (teelsList) {
        int end = (start + limit > teelsList.length)
            ? teelsList.length
            : start + limit;
        if (kDebugMode) {
          print("Teels => ${teelsList.length.toString()}");
        }

        List<Widget> newItems = List<Widget>.generate(
          end - start,
          (index) => ItemVideo(
            teelsList[start + index],
            prefs: widget.prefs,
          ),
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
        (start + limit > teelsList.length)
            ? start += teelsList.length
            : start += limit;
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    );
  }
}

bool isEnlarged = false;

// ignore: must_be_immutable
class ItemVideo extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final TeelsModel? videoData;

  ItemVideo(this.videoData, {super.key, required this.prefs});

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

  @override
  void initState() {
    // followOrNot = widget.videoData!.followOrNot == 1;
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
    _controllerA.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        likeTeel(widget.videoData!.id, phoneNumber!);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
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
              // color: (isliked == true) ? Colors.red : Colors.white,
               colorFilter:   ColorFilter.mode(
                                                    (isliked == true) ? Colors.red : Colors.white,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                   
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
                                                  BlendMode.srcIn,),
          height: 30,
          fit: BoxFit.fitHeight,
        ),
        error: (_, __) => const Text('0'),
      );
    });
    SharedPreferences.getInstance().then((prefs) {
      final int dialogOpen = prefs.getInt('dialog_open') ?? 0;
      if (dialogOpen == 0) {
        //show dialog for one time only
        Future.delayed(const Duration(milliseconds: 1000), () {
          prefs.setInt("dialog_open", 1);
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

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final currentUser = ref.watch(userProfileFutureProvider);
    final totalLikesAsyncValue = ref.watch(getTotalLikes(widget.videoData!.id));
    final totalSavesAsyncValue = ref.watch(getTotalSaves(widget.videoData!.id));
    final likers = ref.watch(getTeelLikes(widget.videoData!.id));
    final followers = ref.watch(getFollowers(widget.videoData!.phoneNumber));
    final allSavesList = ref.watch(getTeelSaves(widget.videoData!.id));
    final userProfile = ref.read(userProfileNotifier);

    final UserProfileModel? user = ref.watch(allUsersProvider(ref)).when(
          data: (data) {
            debugPrint("filteredOtherUsersProvider: ${data.length}");

            final list = data;

            final UserProfileModel matchingUser = list.firstWhere(
              (user) => user.phoneNumber == widget.videoData!.phoneNumber,
            );

            return matchingUser;
          },
          error: (_, __) => null,
          loading: () => null,
        );

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
      final prefs = ref.watch(sharedPreferencesProvider).value;

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
                              color: Teme.isDarktheme(prefs!)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor,
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

                                      return images.length <= 1
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
                              color: Teme.isDarktheme(prefs)
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
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue),
                                  child: const Center(
                                      child: Icon(CupertinoIcons.photo)),
                                ),
                              )
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

    final currentUserProfile = ref.watch(userProfileFutureProvider);

    final String myPhoneNumber =
        ref.watch(currentUserStateProvider)!.phoneNumber!;
    final String id = myPhoneNumber + widget.videoData!.phoneNumber;

    final UserInteractionModel interaction = UserInteractionModel(
      id: id,
      phoneNumber: myPhoneNumber,
      intractToUserId: widget.videoData!.phoneNumber,
      isSuperLike: false,
      isLike: false,
      isDislike: false,
      createdAt: DateTime.now(),
    );

    UserProfileModel? currentUserProfileModel;
    currentUserProfile.whenData((userProfile) {
      currentUserProfileModel = userProfile;
    });

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

      if (isPremiumUser) {
        if (FreemiumLimitation.maxDailyLikeLimitPremium != 0 &&
            totalLiked >= FreemiumLimitation.maxDailyLikeLimitPremium) {
          canLike = false;
        }

        if (FreemiumLimitation.maxDailySuperLikeLimitPremium != 0 &&
            totalSuperLiked >=
                FreemiumLimitation.maxDailySuperLikeLimitPremium) {}

        if (FreemiumLimitation.maxDailyDislikeLimitPremium != 0 &&
            totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitPremium) {}
      } else {
        if (FreemiumLimitation.maxDailyLikeLimitFree != 0 &&
            totalLiked >= FreemiumLimitation.maxDailyLikeLimitFree) {
          canLike = false;
        }

        if (FreemiumLimitation.maxDailySuperLikeLimitFree != 0 &&
            totalSuperLiked >= FreemiumLimitation.maxDailySuperLikeLimitFree) {}

        if (FreemiumLimitation.maxDailyDislikeLimitFree != 0 &&
            totalDisliked >= FreemiumLimitation.maxDailyDislikeLimitFree) {}
      }
      double width = MediaQuery.of(context).size.width;
      return Stack(
        children: [
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onLongPress: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    ReportScreen(1, widget.videoData!.id.toString()),
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
              setState(() {
                _isPlaying = true;
              });
              _animationController.forward();
              if (widget.videoData!.phoneNumber != phoneNumber) {
                if (canLike) {
                  final newInteraction = interaction.copyWith(
                      isLike: true, createdAt: DateTime.now());
                  await createInteraction(newInteraction).then((result) async {
                    if (result && currentUserProfileModel != null) {
                      await getExistingInteraction(
                              widget.videoData!.phoneNumber, myPhoneNumber)
                          .then((otherUserInteraction) async {
                        if (otherUserInteraction != null) {
                          await showMatchingDialog(
                              context: context,
                              currentUser: currentUserProfileModel!,
                              otherUser: user!);
                        } else {
                          createInteractionNotification(
                              title: LocaleKeys.youhaveanewInteraction.tr(),
                              body: LocaleKeys.someonehaslikedyou.tr(),
                              receiverId: widget.videoData!.phoneNumber,
                              currentUser: currentUserProfileModel!);
                          Navigator.pop(context);
                        }
                      });
                    }

                    ref.invalidate(interactionFutureProvider);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          LocaleKeys.youhavereachedyourdailylimitoflikes.tr()),
                    ),
                  );
                }
              }

              await Future.delayed(const Duration(seconds: 3));

              setState(() {
                _isPlaying = false;
              });
            },
          ),
          isEnlarged
              ? Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: MediaQuery.of(context).size.width * .44,
                  child: InkWell(
                    onTap: () {},
                    child: CustomIconButton(
                      onPressed: () {
                        setState(() {
                          isEnlarged = false;
                        });
                        Navigator.pop(context);
                      },
                      icon: closeIcon,
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 2),
                      color: AppConstants.primaryColor,
                    ),
                  ))
              : Container(),
          isEnlarged
              ? Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: VisibilityDetector(
                          onVisibilityChanged: (VisibilityInfo info) {
                            var visiblePercentage = info.visibleFraction * 100;
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
                              bottom: MediaQuery.of(context).size.height * 0.12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: widget.videoData!
                                      .profileCategoryName!.isNotEmpty,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    child: Text(
                                      widget.videoData!.profileCategoryName!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.defaultNumericValue / 2,
                                ),
                                Visibility(
                                  visible: phoneNumber !=
                                      widget.videoData!.phoneNumber,
                                  child: InkWell(
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    onTap: () {
                                      if (phoneNumber!.isNotEmpty) {
                                        showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return GiftSheet(
                                              onAddDymondsTap: onAddDymondsTap,
                                              onGiftSend: (gift) {
                                                EasyLoading.show(
                                                    status: LocaleKeys
                                                        .sendinggift
                                                        .tr());

                                                int value = gift!.coinPrice!;

                                                sendGiftProvider(
                                                    giftCost: value,
                                                    recipientId: widget
                                                        .videoData!
                                                        .phoneNumber);
                                                if (kDebugMode) {
                                                  print("${gift.coinPrice}");
                                                }

                                                // onCommentSend(
                                                //     commentType: FirebaseConst.image, msg: gift.image ?? '');
                                                Future.delayed(
                                                    const Duration(seconds: 3),
                                                    () {
                                                  EasyLoading.dismiss();
                                                });
                                                Navigator.pop(context);
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
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              AppConstants.defaultNumericValue *
                                                  2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.defaultNumericValue / 2,
                                ),
                                InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () => !Responsive.isMobile(context)
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserDetailsPage(
                                              user: user!,
                                            ),
                                          ),
                                        )
                                      : ref
                                          .watch(arrangementProvider.notifier)
                                          .setArrangement(UserDetailsPage(
                                            user: user!,
                                          )),
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
                                              color:
                                                  Colors.black.withOpacity(0.5),
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
                                                      user!.isVerified == true
                                                          ? 15
                                                          : 0,
                                                  width: user.isVerified == true
                                                      ? 15
                                                      : 0,
                                                );
                                              },
                                              error: (e, _) => Container(),
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
                                                      otherUser.phoneNumber,
                                                  // orElse: () => null,
                                                );
                                                return Image(
                                                  image: const AssetImage(
                                                      verifiedIcon),
                                                  height:
                                                      userProfile.isVerified ==
                                                              true
                                                          ? 18
                                                          : 0,
                                                  width:
                                                      userProfile.isVerified ==
                                                              true
                                                          ? 18
                                                          : 0,
                                                );
                                              },
                                              error: (e, _) => Container(),
                                              loading: () {
                                                return const CircularProgressIndicator();
                                              }, // Replace with your error widget
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: AppConstants.defaultNumericValue / 2,
                                ),
                                Visibility(
                                    visible:
                                        widget.videoData!.caption!.isNotEmpty,
                                    child: SizedBox(
                                      width: width * .7,
                                      child: ExpandableText(
                                        widget.videoData!.caption!,
                                        expandText: keepFirstFourWords(
                                            widget.videoData!.caption!),
                                        collapseText: LocaleKeys.showless.tr(),
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
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        onHashtagTap: (text) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  VideosByHashTagScreen(text),
                                            ),
                                          );
                                        },
                                      ),
                                    )),
                                // Visibility(
                                //     visible: widget.videoData!.caption!.isNotEmpty,
                                //     child: SizedBox(
                                //       width: width * .7,
                                //       child: DetectableText(
                                //         text: widget.videoData!.caption!,
                                //         maxLines: 5,
                                //         detectedStyle: TextStyle(
                                //           fontFamily: fNSfUiBold,
                                //           letterSpacing: 0.6,
                                //           fontSize: 13,
                                //           color: Colors.white,
                                //           shadows: [
                                //             Shadow(
                                //               offset: const Offset(1, 1),
                                //               color: Colors.black.withOpacity(0.5),
                                //               blurRadius: 5,
                                //             ),
                                //           ],
                                //         ),
                                //         basicStyle: TextStyle(
                                //           fontFamily: fNSfUiRegular,
                                //           letterSpacing: 0.6,
                                //           fontSize: 13,
                                //           color: Colors.white,
                                //           shadows: [
                                //             Shadow(
                                //               offset: const Offset(1, 1),
                                //               color: Colors.black.withOpacity(0.5),
                                //               blurRadius: 5,
                                //             ),
                                //           ],
                                //         ),
                                //         onTap: (text) {
                                //           Navigator.push(
                                //             context,
                                //             MaterialPageRoute(
                                //               builder: (context) =>
                                //                   VideosByHashTagScreen(text),
                                //             ),
                                //           );
                                //         },
                                //         detectionRegExp:
                                //             detectionRegExp(hashtag: true)!,
                                //       ),
                                //     )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: width * .6,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          AppConstants.defaultNumericValue * 2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      WebsafeSvg.asset(
                                        musicIcon,
                                       colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                        height: 15,
                                        fit: BoxFit.fitHeight,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),

                                      SizedBox(
                                          width: width * .47,
                                          height: 13,
                                          child: Marquee(
                                            text: widget.videoData!.soundTitle!,
                                            style: TextStyle(
                                              letterSpacing: 0.5,
                                              fontSize: 11,
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
                                            velocity: 30,
                                            blankSpace: 20.0,
                                          ))

                                      // Text(
                                      //   widget.videoData!.soundTitle != null
                                      //       ? widget.videoData!.soundTitle!
                                      //       : '',
                                      //   maxLines: 1,
                                      //   style: TextStyle(
                                      //     fontFamily: fNSfUiMedium,
                                      //     letterSpacing: 0.5,
                                      //     fontSize: 11,
                                      //     color: Colors.white,
                                      //     shadows: [
                                      //       Shadow(
                                      //         offset: const Offset(1, 1),
                                      //         color: Colors.black.withOpacity(0.5),
                                      //         blurRadius: 5,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          right: 15,
                          bottom: MediaQuery.of(context).size.height * 0.12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BouncingWidget(
                                duration: const Duration(milliseconds: 100),
                                scaleFactor: 1,
                                onPressed: () {
                                  (widget.videoData!.phoneNumber == phoneNumber)
                                      ? (!Responsive.isDesktop(context))
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileNested(
                                                        prefs: widget.prefs,
                                                        isHome: true,
                                                      )),
                                            )
                                          : ref
                                              .watch(
                                                  arrangementProvider.notifier)
                                              .setArrangement(ProfileNested(
                                                prefs: widget.prefs,
                                                isHome: true,
                                              ))
                                      : otherUsers.when(
                                          data: (users) {
                                            final userProfile =
                                                users.firstWhere(
                                              (otherUser) =>
                                                  widget.videoData!.phoneNumber
                                                      .toString() ==
                                                  otherUser.phoneNumber,
                                            );
                                            return !Responsive.isDesktop(
                                                    context)
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UserDetailsPage(
                                                              user: userProfile,
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
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          },
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
                                                        return Image.network(
                                                          user!.profilePicture!,
                                                          fit: BoxFit.cover,
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
                                                        return Image.network(
                                                          userProfile
                                                              .profilePicture!,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
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
                                        return (!allfollowers
                                                    .contains(phoneNumber) &&
                                                phoneNumber !=
                                                    widget
                                                        .videoData!.phoneNumber)
                                            ? Container(
                                                margin: const EdgeInsets.only(
                                                  top: 40,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius
                                                        .circular(AppConstants
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
                                                      WidgetStateProperty.all(
                                                          Colors.transparent),
                                                  onTap: () async {
                                                    userProfile.followUnfollow(
                                                        followUser: widget
                                                            .videoData!
                                                            .phoneNumber,
                                                        ref: ref);
                                                  },
                                                  child: WebsafeSvg.asset(
                                                    addIcon,
                                                    colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
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
                              height:
                                  phoneNumber != widget.videoData!.phoneNumber
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
                                        highlightColor: Colors.transparent,
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          _controllerA.forward(from: 0.0);
                                        },
                                        child: Transform.scale(
                                            scale: squareScaleA,
                                            child: WebsafeSvg.asset(
                                              likeIcon,
                                             colorFilter: const ColorFilter.mode(
                                                    Colors.red,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                              height: 30,
                                              fit: BoxFit.fitHeight,
                                            )))
                                    : InkWell(
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          _controllerA.forward(from: 0.0);
                                        },
                                        child: Transform.scale(
                                            scale: squareScaleA,
                                            child: WebsafeSvg.asset(
                                              likeIcon,
                                              colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
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
                                                  BlendMode.srcIn,),
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
                                  )
                                : Container(),
                            const SizedBox(
                              height: AppConstants.defaultNumericValue / 2,
                            ),
                            widget.videoData!.canComment
                                ? InkWell(
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    overlayColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(15),
                                          ),
                                        ),
                                        backgroundColor:
                                            AppConstants.backgroundColor,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return AnimatedPadding(
                                            duration: const Duration(
                                                milliseconds: 150),
                                            curve: Curves.easeOut,
                                            padding: EdgeInsets.only(
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            child: CommentScreen(
                                                widget.videoData, () {
                                              setState(() {});
                                            }, null),
                                          );
                                        },
                                      );
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
                                                  BlendMode.srcIn,),
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
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            const SizedBox(
                              height: AppConstants.defaultNumericValue / 2,
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
                                        highlightColor: Colors.transparent,
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          _controllerB.forward(from: 0.0);
                                        },
                                        child: Transform.scale(
                                            scale: squareScaleA,
                                            child: WebsafeSvg.asset(
                                              favIcon,
                                              colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.red,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                              height: 30,
                                              fit: BoxFit.fitHeight,
                                            )))
                                    : InkWell(
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        onTap: () {
                                          _controllerB.forward(from: 0.0);
                                        },
                                        child: Transform.scale(
                                            scale: squareScaleA,
                                            child: WebsafeSvg.asset(
                                              favIcon,
                                            colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
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
                                                  BlendMode.srcIn,),
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
                                      color: Colors.black.withOpacity(0.5),
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const Text('0'),
                            ),
                            const SizedBox(
                              height: AppConstants.defaultNumericValue / 2,
                            ),
                            InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
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
                                                  BlendMode.srcIn,),
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
                )
              : Container(),
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
  }

  String keepFirstFourWords(String caption) {
    List<String> words = caption.split(' ');
    if (words.length > 3) {
      words = words.take(3).toList();
    }
    return words.join(' ');
  }

  void shareLink(TeelsModel videoData) async {
    showDialog(
      context: context,
      builder: (context) => const LoaderDialog(),
    );
    BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: videoData.userName,
        imageUrl: videoData.postVideo!,
        contentDescription: '',
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: BranchContentMetaData()
          ..addCustomMetadata(videoData.id, videoData.id));
    BranchLinkProperties lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        stage: 'share',
        tags: ['one', 'two', 'three']);
    lp.addControlParam('url', 'http://www.google.com');
    lp.addControlParam('url2', 'http://flutter.dev');
    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
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
    Navigator.pop(context);
  }
}

class MusicDisk extends StatefulWidget {
  final TeelsModel? videoData;

  const MusicDisk(this.videoData, {super.key});

  @override
  MusicDiskState createState() => MusicDiskState();
}

class MusicDiskState extends State<MusicDisk>
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

// class LikeUnLikeButton extends ConsumerStatefulWidget {
//   final TeelsModel? videoData;
//   final String phoneNumber;
//   final bool isLike;

//   const LikeUnLikeButton(
//       {super.key,
//       required this.phoneNumber,
//       this.videoData,
//       required this.isLike});

//   @override
//   _LikeUnLikeButtonState createState() => _LikeUnLikeButtonState();
// }

class SaveUnsaveButton extends ConsumerStatefulWidget {
  final TeelsModel? videoData;
  final String phoneNumber;

  const SaveUnsaveButton(
      {super.key, required this.phoneNumber, this.videoData});

  @override
  SaveUnsaveButtonState createState() => SaveUnsaveButtonState();
}

class SaveUnsaveButtonState extends ConsumerState<SaveUnsaveButton>
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
          colorFilter:   ColorFilter.mode(
                                                    isSave ? Colors.red : Colors.white,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                 
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
