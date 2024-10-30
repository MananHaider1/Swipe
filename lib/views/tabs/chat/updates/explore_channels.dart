import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/tabs/home/user_image_card.dart';

class ExploreChannel extends ConsumerStatefulWidget {
  final UserProfileModel currentUserProf;
  final int? index;
  final SharedPreferences prefs;
  const ExploreChannel({super.key, this.index, required this.prefs, required this.currentUserProf});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreChannelState();
}

class _ExploreChannelState extends ConsumerState<ExploreChannel> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchBarVisible = false;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(widget.prefs);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return Expanded(
      child: Scaffold(
        // appBar: AppBar(
        //   toolbarHeight: 0,
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   systemOverlayStyle: SystemUiOverlayStyle.,
        // ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppConstants.defaultNumericValue / 2),
            !_isSearchBarVisible
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
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
                        ),
                      ],
                    ),
                  )
                : const SizedBox(height: 0),
            _isSearchBarVisible
                ? const SizedBox(height: AppConstants.defaultNumericValue / 2)
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
                  return ExploreChannelsBody(
                    prefs: prefs,
                    currentUserProf: widget.currentUserProf,
                    index: widget.index,
                    query: _searchController.text,
                    isPremiumUser: isPremiumUser,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreChannelsBody extends ConsumerStatefulWidget {
  final SharedPreferences? prefs;
  final UserProfileModel currentUserProf;
  final String? query;
  final bool isPremiumUser;
  final int? index;
  const ExploreChannelsBody({
    super.key,
    this.query,
    required this.isPremiumUser,
    required this.prefs,
   required this.currentUserProf,
    this.index,
  });

  @override
  ConsumerState<ExploreChannelsBody> createState() =>
      _ExploreChannelsBodyState();
}

class _ExploreChannelsBodyState extends ConsumerState<ExploreChannelsBody> {
  @override
  void initState() {
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
    final filteredChannel = ref.watch(allChannelsListProvider);

    return filteredChannel.when(
      data: (groups) {
        final List<GroupModel> filteredUsers = [];

        for (final group in groups) {
          if (!groups.any((element) =>
              element.docmap[Dbkeys.groupADMINLIST]
                  .contains(widget.currentUserProf.phoneNumber) &&
              element.docmap[Dbkeys.groupMEMBERSLIST]
                  .contains(widget.currentUserProf.phoneNumber))) {
            filteredUsers.add(group);
          }
        }

        if (widget.query != null && widget.query!.isNotEmpty) {
          filteredUsers.retainWhere((element) => element
              .docmap[Dbkeys.groupNAME]
              .toLowerCase()
              .contains(widget.query!.toLowerCase()));
        }

        return filteredUsers.isEmpty
            ? const NoItemFoundWidget()
            : GridView(
                padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: AppConstants.defaultNumericValue,
                  mainAxisSpacing: AppConstants.defaultNumericValue,
                ),
                children: filteredUsers.map((user) {
                  return GroupImageCard(
                    user: user,
                  );
                }).toList(),
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
}
