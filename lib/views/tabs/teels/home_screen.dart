// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

import 'package:lamatdating/helpers/my_loading/my_loading.dart';
import 'package:lamatdating/views/tabs/teels/following_screen.dart';
import 'package:lamatdating/views/tabs/teels/for_u_screen.dart';

class TeelsPage extends ConsumerStatefulWidget {
  const TeelsPage({super.key});

  @override
  ConsumerState<TeelsPage> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<TeelsPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // For Android (dark icons)
      ),
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final myLoading = ref.watch(myLoadingProvider);
    final currentUser = ref.watch(userProfileFutureProvider);
    PageController controller = PageController(initialPage: 1, keepPage: true);
    return Scaffold(
        body: currentUser.when(
      data: (data) {
        final user = data;

        return Stack(
          children: [
            PageView(
              physics: const BouncingScrollPhysics(),
              controller: controller,
              children: [
                FollowingScreen(user: user),
                const ForYouScreen(),
              ],
              onPageChanged: (value) {
                _tabController!.animateTo(value);
                myLoading.setIsForYouSelected(value == 1);
              },
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Consumer(
                    builder: (BuildContext context, ref, Widget? child) {
                      final myLoading = ref.watch(myLoadingProvider);
                      return Padding(
                        padding: EdgeInsets.only(
                            right: 65,
                            top: MediaQuery.of(context).padding.top + 5),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          dividerColor: Colors.transparent,
                          indicatorColor: AppConstants.primaryColor,
                          // labelColor: Colors.transparent,
                          onTap: (index) {
                            (index == 0)
                                ? {
                                    controller.animateToPage(0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInToLinear),
                                    _tabController!.index = 0,
                                    setState(() {})
                                  }
                                : {
                                    controller.animateToPage(1,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInToLinear),
                                    _tabController!.index = 1,
                                    setState(() {})
                                  };
                          },
                          tabs: [
                            Tab(
                              height: 40,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  LocaleKeys.following.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: fNSfUiSemiBold,
                                    color: !myLoading.isForYou
                                        ? Colors.white
                                        : AppConstants.textColorLight,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0.5, 0.5),
                                        color: !myLoading.isForYou
                                            ? Colors.black54
                                            : Colors.transparent,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Tab(
                              height: 40,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  LocaleKeys.forYou.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: fNSfUiSemiBold,
                                    color: myLoading.isForYou
                                        ? Colors.white
                                        : AppConstants.textColorLight,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(1, 1),
                                        color: myLoading.isForYou
                                            ? Colors.black54
                                            : Colors.transparent,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ])
          ],
        );
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    ));
  }
}
