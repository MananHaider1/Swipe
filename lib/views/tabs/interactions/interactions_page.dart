import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/interaction_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/tabs/home/user_image_card.dart';

class InteractionsPage extends ConsumerStatefulWidget {
  const InteractionsPage({
    super.key,
  });

  @override
  ConsumerState<InteractionsPage> createState() => _InteractionsPageState();
}

class _InteractionsPageState extends ConsumerState<InteractionsPage> {
  final _searchController = TextEditingController();

  bool _isSearchBarVisible = false;

  void onLongPressUserCard(String id) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(LocaleKeys.deleteInteraction.tr()),
            content: Text(LocaleKeys
                .areyousureyouwanttodeletethisuserfromyourinteractions
                .tr()),
            actions: <Widget>[
              TextButton(
                child: Text(LocaleKeys.cancel.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(LocaleKeys.delete.tr()),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await deleteInteraction(id).then((value) {
                    ref.invalidate(interactionFutureProvider);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final interactions = ref.watch(interactionFutureProvider);
    // final prefs = ref.watch(sharedPreferencesProvider).value;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                  trailing: CustomIconButton(
                    icon: questionIcon,
                    onPressed: () {
                      EasyLoading.showInfo(
                          LocaleKeys
                              .longpressonausertoremovefromyourinteractions
                              .tr(),
                          duration: const Duration(seconds: 4),
                          dismissOnTap: true);
                    },
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                  ),
                  title: Center(
                    child: CustomHeadLine(
                      text: LocaleKeys.interactions.tr(),
                    ),
                  ),
                  leading: Row(children: [
                    CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () {
                          (!Responsive.isDesktop(context))
                              ? Navigator.pop(context)
                              : ref.invalidate(arrangementProviderExtend);
                        },
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                    const SizedBox(
                      width: 10,
                    ),
                    CustomIconButton(
                      icon: searchIcon,
                      onPressed: () {
                        setState(() {
                          _isSearchBarVisible = !_isSearchBarVisible;
                          if (_isSearchBarVisible) {
                            _searchController.clear();
                          }
                        });
                      },
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8),
                    ),
                  ])),
            ),
            const SizedBox(height: AppConstants.defaultNumericValue / 2),
            const Divider(height: 0),
            Expanded(
              child: interactions.when(
                data: (data) {
                  final otherUsers = ref.watch(otherUsersProvider(ref));
                  final matchedUsersProvider = ref.watch(matchStreamProvider);

                  final List<UserProfileModel> usersWithoutMatched = [];

                  otherUsers.whenData((value) {
                    matchedUsersProvider.whenData((matchedUsers) {
                      matchedUsers
                          .removeWhere((element) => element.isMatched == false);

                      for (var user in value) {
                        if (!matchedUsers.any((element) =>
                            element.userIds.contains(user.phoneNumber))) {
                          usersWithoutMatched.add(user);
                        }
                      }
                    });
                  });

                  final List<UserProfileModel> searchedUsers = [];

                  for (var value in usersWithoutMatched) {
                    if (value.fullName
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase())) {
                      searchedUsers.add(value);
                    }
                  }

                  final List<UserInteractionViewModel> likedUsers = [];
                  final List<UserInteractionViewModel> superLikedUsers = [];
                  final List<UserInteractionViewModel> dislikedUsers = [];

                  for (var user in searchedUsers) {
                    if (data.any((element) =>
                        element.intractToUserId == user.phoneNumber &&
                        element.isLike == true)) {
                      final UserInteractionViewModel userInteractionViewModel =
                          UserInteractionViewModel(
                        user: user,
                        interaction: data.firstWhere((element) =>
                            element.intractToUserId == user.phoneNumber &&
                            element.isLike == true),
                      );
                      likedUsers.add(userInteractionViewModel);
                    } else if (data.any((element) =>
                        element.intractToUserId == user.phoneNumber &&
                        element.isSuperLike == true)) {
                      final UserInteractionViewModel userInteractionViewModel =
                          UserInteractionViewModel(
                        user: user,
                        interaction: data.firstWhere((element) =>
                            element.intractToUserId == user.phoneNumber &&
                            element.isSuperLike == true),
                      );
                      superLikedUsers.add(userInteractionViewModel);
                    } else if (data.any((element) =>
                        element.intractToUserId == user.phoneNumber &&
                        element.isDislike == true)) {
                      final UserInteractionViewModel userInteractionViewModel =
                          UserInteractionViewModel(
                        user: user,
                        interaction: data.firstWhere((element) =>
                            element.intractToUserId == user.phoneNumber &&
                            element.isDislike == true),
                      );
                      dislikedUsers.add(userInteractionViewModel);
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TabBar(
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.transparent,
                        labelColor: AppConstants.primaryColor,
                        tabs: [
                          Tab(
                            icon: const Icon(CupertinoIcons.heart_fill),
                            text:
                                "${LocaleKeys.liked.tr()}(${likedUsers.length})",
                          ),
                          Tab(
                            icon: const Icon(Icons.bolt),
                            text:
                                "${LocaleKeys.superliked.tr()} (${superLikedUsers.length})",
                          ),
                          Tab(
                            icon: const Icon(Icons.clear),
                            text:
                                "${LocaleKeys.disliked.tr()} (${dislikedUsers.length})",
                          ),
                        ],
                      ),
                      _isSearchBarVisible
                          ? const SizedBox(
                              height: AppConstants.defaultNumericValue / 2)
                          : const SizedBox(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultNumericValue),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return SizeTransition(
                                sizeFactor: animation, child: child);
                          },
                          child: _isSearchBarVisible
                              ? Container(
                                  key: const Key('searchBar'),
                                  padding: const EdgeInsets.all(
                                      AppConstants.defaultNumericValue / 3),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor
                                        .withOpacity(0.2),
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
                                      )),
                                )
                              : const SizedBox(key: Key('noSearchBar')),
                        ),
                      ),
                      _isSearchBarVisible
                          ? const SizedBox(
                              height: AppConstants.defaultNumericValue / 2)
                          : const SizedBox(height: 0),
                      Expanded(
                        child: TabBarView(
                          // physics: const NeverScrollableScrollPhysics(),
                          children: [
                            likedUsers.isEmpty
                                ? Center(
                                    child: NoItemFoundWidget(
                                        text: LocaleKeys.nolikeduserfound.tr()),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      ref.invalidate(interactionFutureProvider);
                                    },
                                    child: GridView.builder(
                                      itemCount: likedUsers.length,
                                      padding: const EdgeInsets.all(
                                          AppConstants.defaultNumericValue / 2),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                        mainAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            onLongPressUserCard(
                                                likedUsers[index]
                                                    .interaction
                                                    .id);
                                          },
                                          child: UserImageCard(
                                              user: likedUsers[index].user),
                                        );
                                      },
                                    ),
                                  ),
                            superLikedUsers.isEmpty
                                ? Center(
                                    child: NoItemFoundWidget(
                                        text: LocaleKeys.nosuperlikeduserfound
                                            .tr()),
                                  )
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      ref.invalidate(interactionFutureProvider);
                                    },
                                    child: GridView.builder(
                                      itemCount: superLikedUsers.length,
                                      padding: const EdgeInsets.all(
                                          AppConstants.defaultNumericValue / 2),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                        mainAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            onLongPressUserCard(
                                                superLikedUsers[index]
                                                    .interaction
                                                    .id);
                                          },
                                          child: UserImageCard(
                                              user:
                                                  superLikedUsers[index].user),
                                        );
                                      },
                                    ),
                                  ),
                            dislikedUsers.isEmpty
                                ? Center(
                                    child: NoItemFoundWidget(
                                        text: LocaleKeys.nodislikeduserfound
                                            .tr()))
                                : RefreshIndicator(
                                    onRefresh: () async {
                                      ref.invalidate(interactionFutureProvider);
                                    },
                                    child: GridView.builder(
                                      itemCount: dislikedUsers.length,
                                      padding: const EdgeInsets.all(
                                          AppConstants.defaultNumericValue / 2),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.8,
                                        crossAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                        mainAxisSpacing:
                                            AppConstants.defaultNumericValue /
                                                2,
                                      ),
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onLongPress: () {
                                            onLongPressUserCard(
                                                dislikedUsers[index]
                                                    .interaction
                                                    .id);
                                          },
                                          child: UserImageCard(
                                              user: dislikedUsers[index].user),
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                error: (_, __) => Center(
                  child: Text(LocaleKeys.somethingWentWrong.tr()),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInteractionViewModel {
  UserInteractionModel interaction;
  UserProfileModel user;
  UserInteractionViewModel({
    required this.interaction,
    required this.user,
  });
}
