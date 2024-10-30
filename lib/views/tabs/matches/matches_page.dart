import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/tabs/home/home_page.dart';
import 'package:lamatdating/views/tabs/home/user_image_card.dart';

class MatchesConsumerPage extends ConsumerWidget {
  final bool? isHome;
  const MatchesConsumerPage({
    super.key,
    this.isHome,
  });

  @override
  Widget build(BuildContext context, ref) {
    final matchedUsersProvider = ref.watch(matchStreamProvider);
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final prefs = ref.watch(sharedPreferences).value;

    return otherUsers.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(
            child: SizedBox(),
          );
        } else {
          return matchedUsersProvider.when(
            data: (matches) {
              final List<MatchedUsersView> matchedViews = [];

              matches.removeWhere((element) => element.isMatched == false);

              for (final user in data) {
                if (matches.any(
                    (element) => element.userIds.contains(user.phoneNumber))) {
                  matchedViews.add(MatchedUsersView(
                      user: user,
                      matchId: matches
                          .firstWhere((element) =>
                              element.userIds.contains(user.phoneNumber))
                          .id));
                }
              }

              return MatchesPage(
                  matchesView: matchedViews,
                  prefs: prefs!,
                  isHome: isHome ?? false);
            },
            error: (_, __) {
              return const ErrorPage();
            },
            loading: () => MatchesPage(
                matchesView: const [], prefs: prefs!, isHome: isHome ?? false),
          );
        }
      },
      error: (_, __) => const ErrorPage(),
      loading: () => MatchesPage(
          matchesView: const [], prefs: prefs!, isHome: isHome ?? false),
    );
  }
}

class MatchesPage extends ConsumerStatefulWidget {
  final bool isHome;
  final SharedPreferences prefs;
  final List<MatchedUsersView> matchesView;
  const MatchesPage({
    super.key,
    required this.isHome,
    required this.matchesView,
    required this.prefs,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MatchBodyState();
}

class _MatchBodyState extends ConsumerState<MatchesPage> {
  bool _isSearchBarVisible = false;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchedUsers = widget.matchesView.where((element) {
      return element.user.fullName
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
          if (!widget.isHome)
            const SizedBox(height: AppConstants.defaultNumericValue),
          if (!widget.isHome)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: CustomAppBar(
                leading: Row(children: [
                  if (!widget.isHome)
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
                        _searchController.clear();
                      });
                    },
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                  )
                ]),
                title: Center(
                    child: CustomHeadLine(
                  text: LocaleKeys.matches.tr(),
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
                    child: _isSearchBarVisible || (widget.isHome)
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
                              autofocus: false,
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
                _isSearchBarVisible || (widget.isHome)
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
                                user: match.user, matchId: match.matchId);
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

class MatchedUsersView {
  UserProfileModel user;
  String matchId;
  MatchedUsersView({
    required this.user,
    required this.matchId,
  });

  MatchedUsersView copyWith({
    UserProfileModel? user,
    String? matchId,
  }) {
    return MatchedUsersView(
      user: user ?? this.user,
      matchId: matchId ?? this.matchId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'user': user.toMap()});
    result.addAll({'matchId': matchId});

    return result;
  }

  factory MatchedUsersView.fromMap(Map<String, dynamic> map) {
    return MatchedUsersView(
      user: UserProfileModel.fromMap(map['user']),
      matchId: map['matchId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MatchedUsersView.fromJson(String source) =>
      MatchedUsersView.fromMap(json.decode(source));

  @override
  String toString() => 'MatchedUsersView(user: $user, matchId: $matchId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MatchedUsersView &&
        other.user == user &&
        other.matchId == matchId;
  }

  @override
  int get hashCode => user.hashCode ^ matchId.hashCode;
}
