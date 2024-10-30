// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unused_result, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/settings/account_settings.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:lamatdating/views/tabs/feeds/feed_post_page.dart'
    if (dart.library.html) 'package:lamatdating/views/tabs/feeds/feed_post_page_web.dart';
import 'package:lamatdating/views/tabs/home/explore_page.dart';
import 'package:lamatdating/views/teelsCamera/camera_teels.dart';
import 'package:lamatdating/views/teelsCamera/upload_teel.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:restart_app/restart_app.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/views/others/photo_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/feed_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/tabs/live/screen/live_stream_screen.dart';
import 'package:lamatdating/views/plan_date/my_meetings.dart';
import 'package:lamatdating/views/security/security_and_privacy_page.dart';
import 'package:lamatdating/views/tabs/feeds/feeds_home_page.dart';
import 'package:lamatdating/views/tabs/interactions/interactions_page.dart';
import 'package:lamatdating/views/tabs/matches/matches_page.dart';
import 'package:lamatdating/views/tabs/profile/profile_view.dart';
import 'package:lamatdating/views/video/video_list_screen.dart';
import 'package:lamatdating/views/wallet/wallet_page.dart';

class ProfileNested extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final bool? isHome;
  const ProfileNested({
    super.key,
    this.isHome,
    required this.prefs,
  });
  @override
  ConsumerState<ProfileNested> createState() => _ProfileNestedState();
}

class _ProfileNestedState extends ConsumerState<ProfileNested>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScrollController _controller = ScrollController();
  late double maxExtent;
  double currentExtent = 500;
  bool biometricEnabled = false;
  DataModel? _cachedModel;
  UserProfileModel? currentUserProf;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = Hive.box(HiveConstants.hiveBox);
      currentUserProf = UserProfileModel.fromJson(
          await box.get(HiveConstants.currentUserProf));
      maxExtent = 500;
      currentExtent = maxExtent;
      // prefs = ref.watch(sharedPreferences).value;
      getModel();
      // setStatusBarColor(prefs!);

      _controller.addListener(() {
        setState(() {
          currentExtent = maxExtent - _controller.offset;
          if (currentExtent < 100) currentExtent = 0.0;
          if (currentExtent > maxExtent) currentExtent = maxExtent;
        });
      });
    });
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuilds the TabBar when the tab selection changes
    });
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.prefs.getString(Dbkeys.phone));
    return _cachedModel;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isSelected(int index) {
    return _tabController.index == index;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final preffs = ref.watch(sharedPreferences).value;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
          Teme.isDarktheme(preffs!) ? Brightness.light : Brightness.dark,
      statusBarIconBrightness:
          Teme.isDarktheme(preffs) ? Brightness.light : Brightness.dark,
    ));

    final userProfileRef = ref.watch(userProfileFutureProvider);
    final walletAsyncValue = ref.watch(walletsStreamProvider);
    final feedList = ref.watch(getFeedsProvider(ref));
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    final phone = ref.watch(currentUserStateProvider)!.phoneNumber!;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Teme.isDarktheme(preffs)
              ? AppConstants.primaryColorDark
              : AppConstants.primaryColor,
          elevation: 0,
          toolbarHeight: 10,
          automaticallyImplyLeading: false,
          // systemOverlayStyle: const SystemUiOverlayStyle(
          //   statusBarBrightness: Brightness.light,
          //   statusBarIconBrightness: Brightness.light,
          // )
        ),
        body: walletAsyncValue.when(
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
                  // final phone = data!.phoneNumber;
                  final user = data ?? currentUserProf!;
                  return (data != null || currentUserProf != null)
                      ? DefaultTabController(
                          length: 3,
                          child: NestedScrollView(
                            controller: _controller,
                            physics: const BouncingScrollPhysics(),
                            headerSliverBuilder:
                                (context, bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                  // toolbarHeight: 45,
                                  backgroundColor:
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.primaryColorDark
                                          : AppConstants.primaryColor,
                                  title: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.primaryColorDark
                                            : AppConstants.primaryColor,
                                        // width: width / 3,
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            if (widget.isHome != null)
                                              GestureDetector(
                                                onTap: () {
                                                  if (!Responsive.isDesktop(
                                                      context)) {
                                                    Navigator.of(context).pop();
                                                  } else {
                                                    ref.invalidate(
                                                        arrangementProvider);
                                                  }
                                                },
                                                child: WebsafeSvg.asset(
                                                  height: 22,
                                                  width: 22,
                                                  fit: BoxFit.fitHeight,
                                                  leftArrowSvg,
                                                  // color: Colors.white,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                    //  AppConstants.primaryColor,
                                                    Colors.white,
                                                    //  Colors.black,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "@${user.userName}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: AppConstants
                                                        .defaultNumericValue *
                                                    1.2,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            user.isVerified
                                                ? GestureDetector(
                                                    onTap: () {
                                                      EasyLoading.showToast(
                                                          LocaleKeys
                                                              .verifiedUser
                                                              .tr());
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: AppConstants
                                                                  .defaultNumericValue *
                                                              .5),
                                                      child: Image(
                                                        image: AssetImage(
                                                            verifiedIcon),
                                                        width: 20,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            const Expanded(
                                              child: SizedBox(),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) {
                                                    return const DialogCoinsPlan();
                                                  },
                                                );
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Colors.red,
                                                        Colors.purple,
                                                        Colors.orange,
                                                        Colors.pink,
                                                      ], // Change colors as desired
                                                      begin: Alignment
                                                          .topLeft, // Adjust gradient direction if needed
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius: BorderRadius
                                                        .circular(AppConstants
                                                                .defaultNumericValue *
                                                            2), // Adjust corner radius
                                                  ),
                                                  // Other container properties (width, height, padding, etc.)
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      decoration: BoxDecoration(
                                                        color: Teme.isDarktheme(
                                                                widget.prefs)
                                                            ? AppConstants
                                                                .primaryColorDark
                                                            : AppConstants
                                                                .primaryColor,
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                    .defaultNumericValue *
                                                                2), // Adjust corner radius
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          GifView.asset(
                                                            coinsIcon,
                                                            height: 24,
                                                            width: 24,
                                                            frameRate:
                                                                60, // default is 15 FPS
                                                          ),
                                                          const SizedBox(
                                                            width: AppConstants
                                                                    .defaultNumericValue /
                                                                4,
                                                          ),
                                                          Text(
                                                              wallet.balance
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleSmall!
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900)),
                                                        ],
                                                      ))),
                                            ),
                                            const SizedBox(
                                                width: AppConstants
                                                        .defaultNumericValue /
                                                    1.1),
                                            SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: OutlinedButton(
                                                  onPressed: () {
                                                    profileMore2(
                                                        context,
                                                        ref,
                                                        widget.prefs,
                                                        user.phoneNumber,
                                                        user);
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          side:
                                                              const BorderSide(
                                                            width: 2.0,
                                                            style: BorderStyle
                                                                .solid,
                                                            color: Colors.white,
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants.defaultNumericValue /
                                                                              2), // Adjust corner radius
                                                                  side:
                                                                      const BorderSide(
                                                                    width: 8.0,
                                                                    style: BorderStyle
                                                                        .solid,
                                                                    color: Colors
                                                                        .white,
                                                                  ))),
                                                  child: const Center(
                                                    child: Icon(
                                                        Icons.add_rounded,
                                                        size: 20,
                                                        color: Colors.white),
                                                  )),
                                            ),
                                            const SizedBox(
                                                width: AppConstants
                                                        .defaultNumericValue /
                                                    3),
                                            IconButton(
                                                onPressed: () {
                                                  profileMore(
                                                      context,
                                                      ref,
                                                      widget.prefs,
                                                      user.phoneNumber,
                                                      user);
                                                },
                                                icon: const Icon(
                                                    Icons.menu_rounded,
                                                    color: Colors.white)),
                                            const SizedBox(
                                                width: AppConstants
                                                        .defaultNumericValue /
                                                    2)
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                  // backgroundColor: AppConstants.secondaryColor,
                                  flexibleSpace:
                                      FlexibleSpaceBar.createSettings(
                                          currentExtent: currentExtent,
                                          minExtent: 0,
                                          maxExtent: maxExtent,
                                          child: const FlexibleSpaceBar(
                                            background: ProfileView(),
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
                                        dividerColor: Colors.transparent,
                                        controller: _tabController,
                                        tabs: [
                                          Tab(
                                            icon: _isSelected(0)
                                                ? WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    gridIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      AppConstants.primaryColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                : WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    gridIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                          ),
                                          Tab(
                                            icon: _isSelected(1)
                                                ? WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    reelsIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      AppConstants.primaryColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                : WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    reelsIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                          ),
                                          Tab(
                                            icon: _isSelected(2)
                                                ? WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    feedsIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      AppConstants.primaryColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                : WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    feedsIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                          ),
                                          Tab(
                                            icon: _isSelected(3)
                                                ? WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    crownIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      AppConstants.primaryColor,
                                                      BlendMode.srcIn,
                                                    ),
                                                  )
                                                : WebsafeSvg.asset(
                                                    height: 36,
                                                    width: 36,
                                                    fit: BoxFit.fitHeight,
                                                    crownIcon,
                                                    colorFilter:
                                                        const ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.srcIn,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                        indicatorColor:
                                            AppConstants.primaryColor,
                                        unselectedLabelColor: Colors.grey,
                                        labelColor: AppConstants.primaryColor,
                                      ),
                                      widget.prefs),
                                  pinned: true,
                                )
                              ];
                            },
                            body: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Tab 1

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
                                                    builder: (context) =>
                                                        SinglePhotoViewPage(
                                                            images:
                                                                user.mediaFiles,
                                                            index: index,
                                                            title: LocaleKeys
                                                                .images
                                                                .tr()),
                                                  ),
                                                );
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    user.mediaFiles[index],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator
                                                          .adaptive(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) {
                                                  return const Center(
                                                    child: Icon(Icons
                                                        .image_not_supported),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          childCount: user.mediaFiles.length,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Tab 2

                                  teelsListAsyncValue.when(
                                    data: (teelsList) {
                                      final myTeels = teelsList
                                          .where((element) =>
                                              element.phoneNumber ==
                                              user.phoneNumber)
                                          .toList();

                                      if (myTeels.isEmpty) {
                                        return SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          child: Center(
                                              child: NoItemFoundWidget(
                                                  text: LocaleKeys.noFeedFound
                                                      .tr())),
                                        );
                                      } else {
                                        return CustomScrollView(
                                          slivers: <Widget>[
                                            SliverGrid(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    3, // number of columns
                                                childAspectRatio:
                                                    0.6, // aspect ratio
                                                crossAxisSpacing:
                                                    2, // horizontal spacing
                                                mainAxisSpacing:
                                                    2, // vertical spacing
                                              ),
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                                (BuildContext context,
                                                    int index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      !(Responsive.isDesktop(
                                                              context))
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        VideoListScreen(
                                                                  list: myTeels,
                                                                  index: myTeels
                                                                      .indexOf(
                                                                          myTeels[
                                                                              index]),
                                                                  type: "video",
                                                                  phoneNumber: user
                                                                      .phoneNumber,
                                                                  soundId: myTeels[
                                                                          index]
                                                                      .soundId,
                                                                ),
                                                              ),
                                                            )
                                                          : ref
                                                              .read(
                                                                  arrangementProvider
                                                                      .notifier)
                                                              .setArrangement(
                                                                  VideoListScreen(
                                                                list: myTeels,
                                                                index: myTeels
                                                                    .indexOf(
                                                                        myTeels[
                                                                            index]),
                                                                type: "video",
                                                                phoneNumber: user
                                                                    .phoneNumber,
                                                                soundId: myTeels[
                                                                        index]
                                                                    .soundId,
                                                              ));
                                                    },
                                                    onLongPress: () async {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          // return dialog content
                                                          return AlertDialog(
                                                            title: Text(
                                                                LocaleKeys
                                                                    .confirm
                                                                    .tr()),
                                                            content: Text(
                                                                "${LocaleKeys.deleteFeed.tr()}?"),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () {
                                                                  deleteTeel(
                                                                      myTeels[index]
                                                                          .id);
                                                                  myTeels
                                                                      .removeAt(
                                                                          index);
                                                                  ref.invalidate(
                                                                      getTeelsProvider);
                                                                  // ref.invalidate(provider)
                                                                  Navigator.pop(
                                                                      context,
                                                                      true); // User pressed Yes
                                                                },
                                                                child: Text(
                                                                    LocaleKeys
                                                                        .yes
                                                                        .tr()),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context,
                                                                      false); // User pressed No
                                                                },
                                                                child: Text(
                                                                    LocaleKeys
                                                                        .no
                                                                        .tr()),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      // await  deleteTeel(myTeels[index].id);
                                                    },
                                                    child: GridTile(
                                                      footer: GridTileBar(
                                                        backgroundColor:
                                                            Colors.black54,
                                                        title: Text(
                                                          myTeels[index]
                                                                  .views
                                                                  .length
                                                                  .toString() +
                                                              LocaleKeys.views
                                                                  .tr(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: myTeels[index]
                                                            .thumbnail!,
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CircularProgressIndicator
                                                                  .adaptive(),
                                                        ),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return const Center(
                                                            child: Icon(Icons
                                                                .image_not_supported),
                                                          );
                                                        },
                                                      ),

                                                      //  Image.network(
                                                      //   teelsList[index].thumbnail!,
                                                      //   fit: BoxFit.cover,
                                                      // ),
                                                    ),
                                                  );
                                                },
                                                childCount: myTeels.length,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                    loading: () => const Center(
                                        child: CircularProgressIndicator()),
                                    error: (error, stack) => Center(
                                        child: Text(LocaleKeys.error.tr())),
                                  ),

                                  // Tab 3

                                  Column(
                                    children: [
                                      feedList.when(
                                        data: (feed) {
                                          final myFeeds = feed
                                              .where((element) =>
                                                  element.phoneNumber ==
                                                  user.phoneNumber)
                                              .toList();

                                          if (myFeeds.isEmpty) {
                                            return SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              child: Center(
                                                  child: NoItemFoundWidget(
                                                      text: LocaleKeys
                                                          .noFeedFound
                                                          .tr())),
                                            );
                                          } else {
                                            return ListView.builder(
                                                shrinkWrap: true,
                                                physics: const ScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final feeds = myFeeds[index];

                                                  return SingleFeedPost(
                                                    prefs: widget.prefs,
                                                    feed: feeds,
                                                    user: user,
                                                    currentUser: user,
                                                  );
                                                },
                                                itemCount: myFeeds.length);
                                          }
                                        },
                                        error: (_, __) => SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                        ),
                                        loading: () => SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Tab 4

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
                                                    builder: (context) =>
                                                        SinglePhotoViewPage(
                                                            images:
                                                                user.subsFiles ??
                                                                    [],
                                                            index: index,
                                                            title: LocaleKeys
                                                                .images
                                                                .tr()),
                                                  ),
                                                );
                                              },
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    user.subsFiles![index],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child: SizedBox(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) {
                                                  return const Center(
                                                    child: Icon(Icons
                                                        .image_not_supported),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          childCount: user.subsFiles != null
                                              ? user.subsFiles!.length
                                              : 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                                // .map((tab) => GridView.count(
                                //       physics: const BouncingScrollPhysics(),
                                //       crossAxisCount: 3,
                                //       shrinkWrap: true,
                                //       mainAxisSpacing: 2.0,
                                //       crossAxisSpacing: 2.0,
                                //       children: posts
                                //           .map((e) => Container(
                                //                 decoration: BoxDecoration(
                                //                     image: DecorationImage(
                                //                         image: AssetImage(e),
                                //                         fit: BoxFit.fill)),
                                //               ))
                                //           .toList(),
                                //     ))
                                // .toList(),
                                ),
                          ),
                        )
                      : Center(
                          child: NoItemFoundWidget(
                            prefs: widget.prefs,
                          ),
                        );
                },
                error: (_, e) =>
                    Center(child: Text(LocaleKeys.somethingWentWrong.tr())),
                loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(LocaleKeys.error.tr())),
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

void profileMore(BuildContext context, ref, SharedPreferences prefs,
    String phone, UserProfileModel user) {
  // final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  // final phone = ref.read(currentUserStateProvider)!.phoneNumber;
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    constraints: BoxConstraints(
      maxHeight: height * 0.7,
      minHeight: height * 0.6,
    ),
    backgroundColor: Teme.isDarktheme(prefs)
        ? AppConstants.backgroundColorDark
        : AppConstants.backgroundColor,
    builder: (BuildContext context) {
      // List of your list text
      List<String> listText = [
        LocaleKeys.settings.tr(),
        LocaleKeys.goLive.tr(),
        LocaleKeys.wallet.tr(),
        LocaleKeys.meetups.tr(),
        LocaleKeys.likes.tr(),
        LocaleKeys.matches.tr(),
        "Find New Friends",
        LocaleKeys.security.tr(),
        LocaleKeys.privacyPolicy.tr(),
        LocaleKeys.faq.tr(),
        LocaleKeys.help.tr(),
        LocaleKeys.logout.tr(),
      ];
      List<Widget> pages = [
        AccountSettingsLandingWidget(
          currentUserNo: phone,
          userProfile: user,
        ),
        const LiveStreamScreen(),
        const WalletPage(),
        const MeetingsPage(),
        const InteractionsPage(),
        const MatchesConsumerPage(),
        const ExplorePage(),
        const SecurityAndPrivacyLandingPage(),
        const PrivacyPolicyViewer(),
        const WebViewScreen(1),
        const WebViewScreen(1),
        const LandingWidget(),
      ];
      return SizedBox(
        width: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * .45,
        child: Column(
          children: [
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: WebsafeSvg.asset(
                        closeIcon,
                        // color: AppConstants.secondaryColor,
                        colorFilter: const ColorFilter.mode(
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
                  const Spacer(),
                  Container(
                      width: AppConstants.defaultNumericValue * 3,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppConstants.hintColor,
                      )),
                  const Spacer(),
                  const SizedBox(
                    width: 32,
                  ),
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  ),
                ]),
            const SizedBox(
              width: AppConstants.defaultNumericValue,
            ),
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  child: ListView.builder(
                    itemCount: pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: WebsafeSvg.asset(
                            height: 36,
                            width: 36,
                            fit: BoxFit.fitHeight,
                            colorFilter: ColorFilter.mode(
                              Teme.isDarktheme(prefs)
                                  ? AppConstants.backgroundColor
                                  : AppConstants.backgroundColorDark,
                              // Colors.white,
                              // Colors.grey,
                              //  Colors.black,
                              BlendMode.srcIn,
                            ),
                            svgIcons[index]),
                        title: Text(listText[index]),
                        onTap: index != 11
                            ? () {
                                Navigator.pop(context);
                                !Responsive.isDesktop(context)
                                    ? Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => pages[index]),
                                      )
                                    : {
                                        // updateCurrentIndex(ref, 10),
                                        ref
                                            .read(arrangementProviderExtend
                                                .notifier)
                                            .setArrangement(pages[index])
                                      };
                              }
                            : () async {
                                EasyLoading.show(
                                    status: LocaleKeys.loggingout.tr());
                                final currentUserId = ref
                                    .read(currentUserStateProvider)!
                                    .phoneNumber;

                                if (currentUserId != null) {
                                  ref
                                      .read(userProfileNotifier)
                                      .updateOnlineStatus(
                                          isOnline: false,
                                          phoneNumber: currentUserId);
                                }
                                if (!kIsWeb) {
                                  await prefs.clear();
                                }
                                // Future.delayed(Duration(seconds: 3), () {
                                //   if (kIsWeb) {
                                //     ref.read(authProvider).signOut();
                                //   }
                                // });

                                Hive.close();
                                Hive.deleteBoxFromDisk(HiveConstants.hiveBox);

                                await ref.read(authProvider).signOut();
                                EasyLoading.dismiss();
                                await Restart.restartApp();
                              },
                      );
                    },
                  )),
            ),
          ],
        ),
      );
    },
  );
}

void profileMore2(BuildContext context, ref, SharedPreferences prefs,
    String phone, UserProfileModel user) {
  // final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final box = Hive.box(HiveConstants.hiveBox);
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    constraints: BoxConstraints(
      maxHeight: height * 0.7,
      minHeight: height * 0.6,
    ),
    backgroundColor: Teme.isDarktheme(prefs)
        ? AppConstants.backgroundColorDark
        : AppConstants.backgroundColor,
    builder: (BuildContext context) {
      bool isPhoto = false;
      // List of your list text
      List<String> listText = [
        LocaleKeys.teel.tr(),
        LocaleKeys.post.tr(),
        LocaleKeys.createStory.tr(),
        LocaleKeys.live.tr(),
        LocaleKeys.subscribers.tr(),
        LocaleKeys.addImages.tr(),
      ];
      List<Function()> pages = [
        () async {
          if (kIsWeb) {
            final imagePath = await pickMediaWeb(isVideo: true).then((value) {
              final observer = ref.watch(observerProvider);
              isPhoto = false;
              if (value != null) {
                if (value.lengthInBytes / (1024 * 1024) <
                    observer.maxFileSizeAllowedInMB) {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SingleChildScrollView(
                        child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
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
                    backgroundColor: AppConstants.backgroundColor,
                    isScrollControlled: true,
                  );
                } else {
                  EasyLoading.showError(
                      "${LocaleKeys.filesizeexceeded.tr()}: ${observer.maxFileSizeAllowedInMB}MB");
                }
              }
            });
          } else {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CameraScreenTeels()));
          }
        },
        () {
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
        () {
          !Responsive.isDesktop(context)
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraScreenStory(
                            prefs: prefs,
                          )),
                )
              : ref
                  .read(arrangementProvider.notifier)
                  .setArrangement(CameraScreenStory(
                    prefs: prefs,
                  ));
        },
        () {
          !Responsive.isDesktop(context)
              ? Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const LiveStreamScreen(),
                  ),
                )
              : ref.read(arrangementProvider.notifier).setArrangement(
                    const LiveStreamScreen(),
                  );
        },
        () async {
          final pickedImage = await pickMediaAsData().then(
            (value) async {
              final observer = ref.watch(observerProvider);
              isPhoto = false;
              final storageRef = FirebaseStorage.instance.ref();
              String? imageUrl;

              if (value != null &&
                  value.pickedFile != null &&
                  value.fileName != "") {
                final metadata = SettableMetadata(
                  contentType:
                      'image/${value.fileName!.substring(value.fileName!.lastIndexOf(".") + 1)}',
                );
                if (value.pickedFile!.lengthInBytes / (1024 * 1024) <
                    observer.maxFileSizeAllowedInMB) {
                  final editedImage = await showModalBottomSheet(
                    context: context,
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width),
                    builder: (context) => ImageEditor(
                      image: value.pickedFile,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    backgroundColor: AppConstants.backgroundColor,
                    isScrollControlled: true,
                  );
                  EasyLoading.show(
                      status: LocaleKeys.uploading.tr(), dismissOnTap: false);

                  final imageRef = storageRef.child(
                      "user_media_files/${user.phoneNumber}/${DateTime.now().millisecondsSinceEpoch}-${value.fileName}");
                  final uploadTask = imageRef.putData(editedImage, metadata);
                  await uploadTask.whenComplete(() async {
                    imageUrl = await imageRef.getDownloadURL();
                  });
                  // add image url to user collection media files list
                  await userCollection.doc(user.phoneNumber).set({
                    "subsFiles": FieldValue.arrayUnion([imageUrl])
                  }, SetOptions(merge: true));
                  final userImages = user.subsFiles ?? [];
                  userImages.add(imageUrl!);
                  final newProfile = user.copyWith(
                    subsFiles: userImages,
                  );
                  await box.put(
                      HiveConstants.currentUserProf, newProfile.toJson());
                  debugPrint(
                      "User Profile =======> SET: ${newProfile.toJson()}");
                  await box.put(
                      HiveConstants.lastUserProfileUpdatedKey, DateTime.now());
                  EasyLoading.dismiss();
                } else {
                  EasyLoading.showError(
                      "${LocaleKeys.filesizeexceeded.tr()}: ${observer.maxFileSizeAllowedInMB}MB");
                }
              }
            },
          );
        },
        () async {
          final pickedImage = await pickMediaAsData().then(
            (value) async {
              final observer = ref.watch(observerProvider);
              isPhoto = false;
              final storageRef = FirebaseStorage.instance.ref();
              String? imageUrl;

              if (value != null &&
                  value.pickedFile != null &&
                  value.fileName != "") {
                final metadata = SettableMetadata(
                  contentType:
                      'image/${value.fileName!.substring(value.fileName!.lastIndexOf(".") + 1)}',
                );
                if (value.pickedFile!.lengthInBytes / (1024 * 1024) <
                    observer.maxFileSizeAllowedInMB) {
                  final editedImage = await showModalBottomSheet(
                    context: context,
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width),
                    builder: (context) => ImageEditor(
                      image: value.pickedFile,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    backgroundColor: AppConstants.backgroundColor,
                    isScrollControlled: true,
                  );
                  EasyLoading.show(
                      status: LocaleKeys.uploading.tr(), dismissOnTap: false);

                  final imageRef = storageRef.child(
                      "user_media_files/${user.phoneNumber}/${DateTime.now().millisecondsSinceEpoch}-${value.fileName}");
                  final uploadTask = imageRef.putData(editedImage, metadata);
                  await uploadTask.whenComplete(() async {
                    imageUrl = await imageRef.getDownloadURL();
                  });
                  // add image url to user collection media files list
                  await userCollection.doc(user.phoneNumber).set({
                    "mediaFiles": FieldValue.arrayUnion([imageUrl])
                  }, SetOptions(merge: true));
                  final userImages = user.subsFiles ?? [];
                  userImages.add(imageUrl!);
                  final newProfile = user.copyWith(
                    subsFiles: userImages,
                  );
                  await box.put(
                      HiveConstants.currentUserProf, newProfile.toJson());
                  debugPrint(
                      "User Profile =======> SET: ${newProfile.toJson()}");
                  await box.put(
                      HiveConstants.lastUserProfileUpdatedKey, DateTime.now());
                  EasyLoading.dismiss();
                } else {
                  EasyLoading.showError(
                      "${LocaleKeys.filesizeexceeded.tr()}: ${observer.maxFileSizeAllowedInMB}MB");
                }
              }
            },
          );
        },
      ];
      return SizedBox(
        width: !Responsive.isDesktop(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * .45,
        child: Column(
          children: [
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: WebsafeSvg.asset(
                        closeIcon,
                        colorFilter: const ColorFilter.mode(
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
                  const Spacer(),
                  Container(
                      width: AppConstants.defaultNumericValue * 3,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppConstants.hintColor,
                      )),
                  const Spacer(),
                  const SizedBox(
                    width: 32,
                  ),
                  const SizedBox(
                    width: AppConstants.defaultNumericValue,
                  ),
                ]),
            const SizedBox(
              width: AppConstants.defaultNumericValue / 2,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      LocaleKeys.create.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
            const SizedBox(
              width: AppConstants.defaultNumericValue / 2,
            ),
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.all(AppConstants.defaultNumericValue),
                  child: ListView.builder(
                    itemCount: pages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          leading: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              colorFilter: ColorFilter.mode(
                                Teme.isDarktheme(prefs)
                                    ? AppConstants.backgroundColor
                                    : AppConstants.backgroundColorDark,
                                // Colors.white,
                                // Colors.grey,
                                //  Colors.black,
                                BlendMode.srcIn,
                              ),
                              svgIcons2[index]),
                          title: Text(listText[index]),
                          onTap: pages[index]);
                    },
                  )),
            ),
          ],
        ),
      );
    },
  );
}

// List of your SVG icons (MORE)
List<String> svgIcons = [
  settingsLinearIcon,
  lamatStarIcon,
  liveIcon,
  walletIcon,
  meetupIcon,
  likeIcon,
  likeIcon,
  profileIcon,
  boltIcon,
  boltIcon,
  boltIcon,
  boltIcon,
  logoutIcon
];

// List of your SVG icons (CREATE)
List<String> svgIcons2 = [
  lamatStarIcon,
  lamatStarIcon,
  lamatStarIcon,
  liveIcon,
  lamatStarIcon,
  lamatStarIcon,
];
