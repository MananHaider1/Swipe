import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/tabs/home/home_page.dart';
import 'package:lamatdating/views/tabs/home/user_image_card.dart';

class FollowersConsumerPage extends ConsumerWidget {
  final List<String> followers;
  final String title;
  final bool? isInvite;
  final String? channelId;
  final String? inviteePhone;
  final GoalModel? goalModel;
  final bool? isHost;
  final bool? isCoHost;
  final String? status;
  const FollowersConsumerPage(
      {super.key,
      required this.followers,
      required this.title,
      this.isInvite,
      this.channelId,
      this.inviteePhone,
      this.goalModel,
      this.isHost,
      this.isCoHost,
      this.status});

  @override
  Widget build(BuildContext context, ref) {
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final prefs = ref.watch(sharedPreferences).value;

    return otherUsers.when(
      data: (data) {
        if (data.isEmpty) {
          return Center(
            child: NoItemFoundWidget(text: LocaleKeys.nomatchesfound.tr()),
          );
        } else {
          final List<UserProfileModel> users = data;
          final List<String> followersNumbers = followers;
          final List<UserProfileModel> followersProfiles = [];
          for (var user in users) {
            if (followersNumbers.contains(user.phoneNumber)) {
              followersProfiles.add(user);
            }
          }

          return FollowersPage(
              matchesView: followersProfiles,
              prefs: prefs!,
              title: title,
              isInvite: isInvite ?? false,
              channelId: channelId,
              inviteePhone: inviteePhone,
              goalModel: goalModel,
              isHost: isHost ?? false,
              isCoHost: isCoHost ?? false,
              status: status);
        }
      },
      error: (_, __) => const ErrorPage(),
      loading: () => const LoadingPage(),
    );
  }
}

class FollowersPage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final List<UserProfileModel> matchesView;
  final String title;
  final bool? isInvite;
  final String? channelId;
  final String? inviteePhone;
  final GoalModel? goalModel;
  final bool? isHost;
  final bool? isCoHost;
  final String? status;
  const FollowersPage(
      {super.key,
      required this.matchesView,
      required this.prefs,
      required this.title,
      this.isInvite,
      this.channelId,
      this.inviteePhone,
      this.goalModel,
      this.isHost,
      this.isCoHost,
      this.status});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FollowersBodyState();
}

class _FollowersBodyState extends ConsumerState<FollowersPage> {
  bool _isSearchBarVisible = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchedUsers = widget.matchesView.where((element) {
      return element.fullName
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
    }).toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.defaultNumericValue),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultNumericValue),
            child: CustomAppBar(
              leading: Row(children: [
                CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                    onPressed: () {
                      !Responsive.isDesktop(context)
                          ? Navigator.pop(context)
                          : ref.invalidate(arrangementProvider);
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
                      _searchController.clear();
                    });
                  },
                  padding: const EdgeInsets.all(
                      AppConstants.defaultNumericValue / 1.8),
                )
              ]),
              title: Center(
                  child: CustomHeadLine(
                text: widget.title,
              )),
              trailing: const NotificationButton(),
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          Expanded(
            child: Column(
              children: [
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
                            key: const Key('searchBar1'),
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
                        : const SizedBox(key: Key('noSearchBar1')),
                  ),
                ),
                _isSearchBarVisible
                    ? const SizedBox(height: AppConstants.defaultNumericValue)
                    : const SizedBox(height: 0),
                searchedUsers.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: SizedBox(),
                        ),
                      )
                    : Expanded(
                        child: GridView(
                          padding: const EdgeInsets.only(
                            left: AppConstants.defaultNumericValue,
                            right: AppConstants.defaultNumericValue,
                            bottom: AppConstants.defaultNumericValue,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppConstants.defaultNumericValue,
                            mainAxisSpacing: AppConstants.defaultNumericValue,
                          ),
                          children: searchedUsers.map((match) {
                            return UserImageCard(
                                channelId: widget.channelId,
                                goalModel: widget.goalModel,
                                isHost: false,
                                isCoHost: true,
                                status: widget.status,
                                inviteePhone: widget.inviteePhone,
                                user: match,
                                isInvite: widget.isInvite);
                          }).toList(),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
