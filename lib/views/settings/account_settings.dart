// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/views/others/set_user_location_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/languages_screen/languages_screen.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:websafe_svg/websafe_svg.dart';

class AccountSettingsLandingWidget extends ConsumerWidget {
  final String currentUserNo;
  final Widget Function(UserProfileModel data)? builder;
  final UserProfileModel? userProfile;
  const AccountSettingsLandingWidget({
    super.key,
    this.builder,
    this.userProfile,
    required this.currentUserNo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileFutureProvider);

    return userProfile != null
        ? AccountSettingsPage(
            user: userProfile!, currentUserNo: userProfile!.phoneNumber)
        : user.when(
            data: (data) {
              return data == null
                  ? const ErrorPage()
                  : builder == null
                      ? AccountSettingsPage(
                          user: data, currentUserNo: currentUserNo)
                      : builder!(data);
            },
            error: (_, __) => const ErrorPage(),
            loading: () => const LoadingPage(),
          );
  }
}

class AccountSettingsPage extends ConsumerStatefulWidget {
  final UserProfileModel user;
  final String currentUserNo;
  const AccountSettingsPage({
    super.key,
    required this.user,
    required this.currentUserNo,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  UserLocation? _userLocation;
  late double _distanceInKm;
  late bool _isWorldWide;
  late double _minimumAge;
  late double _maximumAge;
  String? _interestedIn;
  bool? _showAge;
  bool? _showLocation;
  bool? _showOnlineStatus;
  bool? _showOnlyToPremiumUsers;
  bool? _allowAnonymousMessages;
  late Stream myDocStream;
  bool isLoading = false;
  String selectedLanguage =
      WidgetsBinding.instance.window.locales.first.languageCode.split('_')[0];
  SessionManager prefService = SessionManager();
  int? value = 0;

  @override
  void initState() {
    _distanceInKm = widget.user.userAccountSettingsModel.distanceInKm ??
        AppConfig.initialMaximumDistanceInKM;
    _isWorldWide = widget.user.userAccountSettingsModel.distanceInKm == null;
    _interestedIn = widget.user.userAccountSettingsModel.interestedIn;

    _userLocation = AppRes.currentLocationProviderProvider;
    _minimumAge = widget.user.userAccountSettingsModel.minimumAge.toDouble();
    _maximumAge = widget.user.userAccountSettingsModel.maximumAge.toDouble();

    // _maxDistanceInKm = AppConfig.initialMaximumDistanceInKM;

    _showAge = widget.user.userAccountSettingsModel.showAge;
    _showLocation = widget.user.userAccountSettingsModel.showLocation;
    _showOnlineStatus = widget.user.userAccountSettingsModel.showOnlineStatus;

    _showOnlyToPremiumUsers =
        widget.user.userAccountSettingsModel.showOnlyToPremiumUsers;

    _allowAnonymousMessages =
        widget.user.userAccountSettingsModel.allowAnonymousMessages;

    super.initState();
    myDocStream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .snapshots();
  }

  // void onLanguageChange(int? value) async {
  //   this.value = value;
  //   prefService.saveString(KeyRes.languageCode, languageCode[value ?? 0]);
  //   selectedLanguage = languageCode[value ?? 0];
  //   MyApp.of(context)?.setLocale(selectedLanguage);
  //   // setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final appSettingsRef = ref.watch(appSettingsProvider);
    final prefss = ref.watch(sharedPreferences).value;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final observer = ref.watch(observerProvider);
    var w = MediaQuery.of(this.context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
          Teme.isDarktheme(prefss!) ? Brightness.light : Brightness.light,
      statusBarIconBrightness:
          Teme.isDarktheme(prefss) ? Brightness.light : Brightness.light,
    ));

    return Scaffold(
      body: SingleChildScrollView(
          child: SubscriptionBuilder(builder: (context, isPremiumUser) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Padding(
                padding: const EdgeInsets.only(
                    left: AppConstants.defaultNumericValue),
                child: CustomAppBar(
                  leading: CustomIconButton(
                      icon: leftArrowSvg,
                      onPressed: () {
                        !Responsive.isDesktop(context)
                            ? Navigator.pop(context)
                            : ref.invalidate(arrangementProviderExtend);
                      },
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8)),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.settings.tr(),
                  )),
                  trailing: const SizedBox(
                      width: AppConstants.defaultNumericValue * 2),
                )),
            const SizedBox(height: AppConstants.defaultNumericValue),
            Padding(
                padding: const EdgeInsets.only(
                    left: AppConstants.defaultNumericValue),
                child: Text(
                  LocaleKeys.discovery.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: AppConstants.defaultNumericValue),
            Container(
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            GestureDetector(
              onTap: (widget.user.isPremium ?? false || isPremiumUser)
                  ? () async {
                      final newLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SetUserLocation()));

                      if (newLocation != null) {
                        setState(() {
                          _userLocation = newLocation;
                        });
                      }
                    }
                  : () {
                      EasyLoading.showError("Premium Feature");
                    },
              child: ListTile(
                  tileColor: Teme.isDarktheme(prefss)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  contentPadding: const EdgeInsets.only(
                      left: AppConstants.defaultNumericValue,
                      right: AppConstants
                          .defaultNumericValue), // remove padding for seamless blending
                  leading: const Icon(
                    Icons.location_on,
                  ),
                  title: Text(
                    LocaleKeys.location.tr(),
                    style: TextStyle(
                        color: Teme.isDarktheme(prefss)
                            ? Colors.white
                            : Colors.black),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    (widget.user.isPremium ?? false || isPremiumUser)
                        ? Text(
                            _userLocation != null
                                ? _userLocation!.addressText
                                : "",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          )
                        : Text(
                            LocaleKeys.currentLocation.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(
                      width: AppConstants.defaultNumericValue / 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                    ),
                  ])),
            ),

            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),

            GestureDetector(
              onTap: () => showModalBottomSheet(
                  context: context,
                  barrierColor: AppConstants.primaryColor.withOpacity(.3),
                  constraints: BoxConstraints(
                    maxHeight: height * .3,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.defaultNumericValue),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder: (BuildContext context,
                        StateSetter setrState /*You can rename this!*/) {
                      return Column(children: [
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
                                    colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                    height: 32,
                                    width: 32,
                                    fit: BoxFit.contain,
                                  )),
                              SizedBox(
                                width: width * .3,
                              ),
                              Container(
                                  width: AppConstants.defaultNumericValue * 3,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppConstants.hintColor,
                                  )),
                            ]),
                        const SizedBox(
                          width: AppConstants.defaultNumericValue,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.radius.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                                width: AppConstants.defaultNumericValue),
                            if (!_isWorldWide)
                              Text(
                                '${_distanceInKm.toInt()} km',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.primaryColor),
                              ),
                          ],
                        ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue / 2),
                        Text(LocaleKeys.thisradiusisused.tr(),
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue),
                        if (!_isWorldWide)
                          Slider(
                            value: _distanceInKm,
                            min: 1,
                            max: (widget.user.isPremium ??
                                    false || isPremiumUser)
                                ? 999999
                                : AppConfig.initialDistanceInKM,
                            onChanged: (value) {
                              _distanceInKm = value;
                              setrState(() {});
                              setState(() {
                                _distanceInKm = value;
                              });
                              setrState(() {});
                            },
                          ),
                        if ((widget.user.isPremium ?? false || isPremiumUser))
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue),
                            ),
                            borderOnForeground: true,
                            child: CheckboxListTile(
                              value: _isWorldWide,
                              controlAffinity: ListTileControlAffinity.leading,
                              checkboxShape: const CircleBorder(),
                              onChanged: (value) {
                                setrState(() {});
                                setState(() {
                                  _isWorldWide = value!;
                                  _distanceInKm = value
                                      ? AppConfig.initialMaximumDistanceInKM
                                      : widget.user.userAccountSettingsModel
                                              .distanceInKm ??
                                          AppConfig.initialMaximumDistanceInKM;
                                });
                                setrState(() {});
                              },
                              title: Text(
                                LocaleKeys.anywhere.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        const SizedBox(
                            height: AppConstants.defaultNumericValue * 2),
                      ]);
                    });
                  }),
              child: ListTile(
                  tileColor: Teme.isDarktheme(prefss)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  contentPadding: const EdgeInsets.only(
                      left: AppConstants.defaultNumericValue,
                      right: AppConstants
                          .defaultNumericValue), // remove padding for seamless blending
                  leading: const Icon(
                    CupertinoIcons.arrow_up_to_line,
                  ),
                  title: Text(
                    LocaleKeys.distPref.tr(),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    (widget.user.isPremium ?? false || isPremiumUser)
                        ? Text(
                            LocaleKeys.anywhere.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor),
                          )
                        : Text(
                            '${_distanceInKm.toInt()} km',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(
                      width: AppConstants.defaultNumericValue / 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                    ),
                  ])),
            ),
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Show me **********************************************************
            GestureDetector(
              onTap: () => showModalBottomSheet(
                  context: context,
                  backgroundColor: Teme.isDarktheme(prefss)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  barrierColor: AppConstants.primaryColor.withOpacity(.3),
                  constraints: BoxConstraints(
                    maxHeight: height * .3,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppConstants.defaultNumericValue),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setrState) {
                      return Column(children: [
                        const SizedBox(
                          height: AppConstants.defaultNumericValue,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                    height: 32,
                                    width: 32,
                                    fit: BoxFit.contain,
                                  )),
                              SizedBox(
                                width: width * .33,
                              ),
                              Container(
                                  width: AppConstants.defaultNumericValue * 3,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: AppConstants.hintColor,
                                  )),
                            ]),
                        const SizedBox(
                          width: AppConstants.defaultNumericValue,
                        ),
                        Text(
                          LocaleKeys.showMe.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Teme.isDarktheme(prefss)
                                      ? Colors.white
                                      : Colors.black),
                        ),
                        const SizedBox(
                          height: AppConstants.defaultNumericValue * 2,
                        ),

                        // Start Content
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: AppConstants.defaultNumericValue / 2,
                          runSpacing: AppConstants.defaultNumericValue / 2,
                          children: [
                            _GenderButton(
                              prefs: prefss,
                              text: AppConfig.maleText.toUpperCase(),
                              isSelected: _interestedIn == AppConfig.maleText,
                              onPressed: () {
                                setState(() {
                                  _interestedIn = AppConfig.maleText;
                                });
                                setrState(() {});
                              },
                            ),
                            _GenderButton(
                              prefs: prefss,
                              text: AppConfig.femaleText.toUpperCase(),
                              isSelected: _interestedIn == AppConfig.femaleText,
                              onPressed: () {
                                setState(() {
                                  _interestedIn = AppConfig.femaleText;
                                });
                                setrState(() {});
                              },
                            ),
                            if (AppConfig.allowTransGender)
                              _GenderButton(
                                prefs: prefss,
                                text: AppConfig.transText.toUpperCase(),
                                isSelected:
                                    _interestedIn == AppConfig.transText,
                                onPressed: () {
                                  setState(() {
                                    _interestedIn = AppConfig.transText;
                                  });
                                  setrState(() {});
                                },
                              ),
                            _GenderButton(
                              prefs: prefss,
                              text: AppConfig.allowTransGender
                                  ? LocaleKeys.all.tr().toUpperCase()
                                  : LocaleKeys.both.tr().toUpperCase(),
                              isSelected: _interestedIn == null,
                              onPressed: () {
                                setState(() {
                                  _interestedIn = null;
                                });
                                setrState(() {});
                              },
                            ),
                          ],
                        ),
                        // End Content
                        const SizedBox(
                            height: AppConstants.defaultNumericValue * 2),
                      ]);
                    });
                  }),
              child: ListTile(
                  tileColor: Teme.isDarktheme(prefss)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  contentPadding: const EdgeInsets.only(
                      left: AppConstants.defaultNumericValue,
                      right: AppConstants.defaultNumericValue),
                  leading: const Icon(
                    Icons.people_rounded,
                  ),
                  title: Text(
                    LocaleKeys.showMe.tr(),
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      _interestedIn ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: AppConstants.defaultNumericValue / 2,
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppConstants.hintColor,
                    ),
                  ])),
            ),

            // End Show me  **************************************************************
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Start Age Range ************************************************************

            ListTile(
              tileColor: Teme.isDarktheme(prefss)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              contentPadding: const EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue),
              title: Text(LocaleKeys.ageRange.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
              trailing: Text(
                '${_minimumAge.toInt()}-${_maximumAge.toInt()}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: AppConstants.primaryColor),
              ),
            ),

            RangeSlider(
              values:
                  RangeValues(_minimumAge.toDouble(), _maximumAge.toDouble()),
              min: AppConfig.minimumAgeRequired.toDouble(),
              max: AppConfig.maximumUserAge.toDouble(),
              onChanged: (RangeValues values) {
                setState(() {
                  _minimumAge = values.start;
                  _maximumAge = values.end;
                });
              },
            ),
            const SizedBox(
              height: AppConstants.defaultNumericValue,
            ),

            // End Age Range ************************************************************
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Start ShowAge ************************************************************

            ListTile(
              tileColor: Teme.isDarktheme(prefss)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              contentPadding: const EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue),
              title: Text(
                LocaleKeys.showAge.tr(),
              ),
              trailing: Switch(
                activeColor: AppConstants.primaryColor,
                activeTrackColor: AppConstants.primaryColor.withOpacity(.5),
                value: _showAge ?? true,
                onChanged: (value) {
                  setState(() {
                    _showAge = value;
                  });
                },
              ),
            ),

            // End ShowAge ************************************************************
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Start ShowLocation ************************************************************

            // ListTile(
            //   tileColor: Teme.isDarktheme(prefss)
            //       ? AppConstants.backgroundColorDark
            //       : AppConstants.backgroundColor,
            //   contentPadding: const EdgeInsets.only(
            //       left: AppConstants.defaultNumericValue,
            //       right: AppConstants.defaultNumericValue),
            //   title: Text(
            //     LocaleKeys.showLocation.tr(),
            //   ),
            //   trailing: Switch(
            //     activeColor: AppConstants.primaryColor,
            //     activeTrackColor: AppConstants.primaryColor.withOpacity(.5),
            //     value: _showLocation ?? true,
            //     onChanged: (value) {
            //       setState(() {
            //         _showLocation = value;
            //       });
            //     },
            //   ),
            // ),

            // // End ShowLocation ************************************************************
            // Container(
            //   margin: const EdgeInsets.only(
            //     left: AppConstants.defaultNumericValue,
            //   ),
            //   height: .2,
            //   width: width,
            //   color: AppConstants.hintColor,
            // ),
            // Start ShowOnlineStatus ************************************************************

            ListTile(
              tileColor: Teme.isDarktheme(prefss)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              contentPadding: const EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue),
              title: Text(
                LocaleKeys.showOnlineStatus.tr(),
              ),
              trailing: Switch(
                activeColor: AppConstants.primaryColor,
                activeTrackColor: AppConstants.primaryColor.withOpacity(.5),
                value: _showOnlineStatus ?? true,
                onChanged: (value) {
                  setState(() {
                    _showOnlineStatus = value;
                  });
                },
              ),
            ),

            // End ShowOnlineStatus ************************************************************
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Start ShowonlytoPremiumUsers ************************************************************

            ListTile(
              tileColor: Teme.isDarktheme(prefss)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              contentPadding: const EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue),
              title: Text(
                LocaleKeys.showonlytoPremiumUsers.tr(),
              ),
              trailing: Switch(
                activeColor: AppConstants.primaryColor,
                activeTrackColor: AppConstants.primaryColor.withOpacity(.5),
                value: _showOnlyToPremiumUsers ?? false,
                onChanged: (value) {
                  setState(() {
                    _showOnlyToPremiumUsers = value;
                  });
                },
              ),
            ),

            // End ShowonlytoPremiumUsers ************************************************************
            Container(
              margin: const EdgeInsets.only(
                left: AppConstants.defaultNumericValue,
              ),
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            // Start Allowanonymousmessages ************************************************************

            appSettingsRef.when(
              data: (data) {
                bool isAnonymousMessagesEnabled =
                    data?.isChattingEnabledBeforeMatch ?? false;
                if (isAnonymousMessagesEnabled) {
                  return ListTile(
                    tileColor: Teme.isDarktheme(prefss)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    contentPadding: const EdgeInsets.only(
                        left: AppConstants.defaultNumericValue,
                        right: AppConstants.defaultNumericValue),
                    title: Text(
                      LocaleKeys.allowanonymousmessages.tr(),
                    ),
                    trailing: Switch(
                      activeColor: AppConstants.primaryColor,
                      activeTrackColor:
                          AppConstants.primaryColor.withOpacity(.5),
                      value: _allowAnonymousMessages ?? false,
                      onChanged: (value) {
                        setState(() {
                          _allowAnonymousMessages = value;
                        });
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
              error: (error, stackTrace) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppConstants.defaultNumericValue),
            Padding(
                padding: const EdgeInsets.only(
                    left: AppConstants.defaultNumericValue),
                child: Text(
                  LocaleKeys.appSettings.tr(),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: AppConstants.defaultNumericValue),
            Container(
              height: .2,
              width: width,
              color: AppConstants.hintColor,
            ),
            const SizedBox(height: AppConstants.defaultNumericValue / 2),
            SizedBox(
              // padding: EdgeInsets.fromLTRB(0, 19, 0, 10),
              // height: 100,
              width: w,
              child: StreamBuilder(
                  stream: myDocStream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData && snapshot.data.exists) {
                      var myDoc = snapshot.data;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            trailing: SizedBox(
                              width: 40,
                              child: isLoading == true
                                  ? Align(
                                      child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: LinearProgressIndicator(
                                        backgroundColor: AppConstants
                                            .primaryColor
                                            .withOpacity(0.4),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppConstants.primaryColor),
                                      ),
                                    ))
                                  : Switch(
                                      activeColor: AppConstants.primaryColor,
                                      inactiveThumbColor: Colors.blueGrey,
                                      inactiveTrackColor: Colors.grey[300],
                                      activeTrackColor: AppConstants
                                          .primaryColor
                                          .withOpacity(.5),
                                      onChanged: (b) async {
                                        if (b == true) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          //subscribe to token
                                          await FirebaseMessaging.instance
                                              .subscribeToTopic(widget
                                                  .currentUserNo
                                                  .replaceFirst(
                                                      RegExp(r'\+'), ''))
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });
                                          await FirebaseMessaging.instance
                                              .subscribeToTopic(
                                                  Dbkeys.topicUSERS)
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });
                                          await FirebaseMessaging.instance
                                              .subscribeToTopic(!kIsWeb
                                                  ? Platform.isAndroid
                                                      ? Dbkeys.topicUSERSandroid
                                                      : Platform.isIOS
                                                          ? Dbkeys.topicUSERSios
                                                          : Dbkeys.topicUSERSweb
                                                  : Dbkeys.topicUSERSweb)
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });
                                          String? fcmToken =
                                              await FirebaseMessaging.instance
                                                  .getToken();
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionusers)
                                              .doc(widget.currentUserNo)
                                              .update({
                                            Dbkeys.notificationTokens: [
                                              fcmToken
                                            ],
                                          });
                                          isLoading = false;
                                          setState(() {});
                                        } else {
                                          //unsubscribe to token
                                          setState(() {
                                            isLoading = true;
                                          });

                                          await FirebaseMessaging.instance
                                              .unsubscribeFromTopic(widget
                                                  .currentUserNo
                                                  .replaceFirst(
                                                      RegExp(r'\+'), ''))
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });
                                          await FirebaseMessaging.instance
                                              .unsubscribeFromTopic(
                                                  Dbkeys.topicUSERS)
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });
                                          await FirebaseMessaging.instance
                                              .unsubscribeFromTopic(!kIsWeb
                                                  ? Platform.isAndroid
                                                      ? Dbkeys.topicUSERSandroid
                                                      : Platform.isIOS
                                                          ? Dbkeys.topicUSERSios
                                                          : Dbkeys.topicUSERSweb
                                                  : Dbkeys.topicUSERSweb)
                                              .catchError((err) {
                                            debugPrint(
                                                'ERROR SUBSCRIBING NOTIFICATION$err');
                                          });

                                          await FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionusers)
                                              .doc(widget.currentUserNo)
                                              .update({
                                            Dbkeys.notificationTokens: [],
                                          });
                                          isLoading = false;
                                          setState(() {});
                                        }
                                      },
                                      value: myDoc[Dbkeys.notificationTokens]
                                                  .length >
                                              0
                                          ? true
                                          : false,
                                    ),
                            ),
                            onTap: () {
                              // widget.onTapEditProfile();
                            },
                            contentPadding: const EdgeInsets.fromLTRB(
                                AppConstants.defaultNumericValue,
                                0,
                                AppConstants.defaultNumericValue,
                                0),
                            title: Text(
                              LocaleKeys.generalnotification.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(prefss)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          trailing: SizedBox(
                              width: 40,
                              child: Align(
                                  child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: LinearProgressIndicator(
                                  backgroundColor: AppConstants.primaryColor
                                      .withOpacity(0.4),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppConstants.primaryColor,
                                  ),
                                ),
                              ))),
                          onTap: () {
                            // widget.onTapEditProfile();
                          },
                          contentPadding: const EdgeInsets.fromLTRB(
                              AppConstants.defaultNumericValue,
                              0,
                              AppConstants.defaultNumericValue,
                              0),
                          title: Text(
                            LocaleKeys.generalnotification.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(prefss)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor,
                                )),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            if (IsHIDELightDarkModeSwitchInApp == false)
              ListTile(
                onTap: () {
                  final themeChange = ref.watch(darkThemeProvider.notifier);

                  themeChange.darkTheme = !Teme.isDarktheme(prefss);

                  // Navigator.of(this.context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (BuildContext context) => const MyApp(),
                  //   ),
                  //   (Route route) => false,
                  // );
                },
                contentPadding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultNumericValue,
                    0,
                    AppConstants.defaultNumericValue,
                    0),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Icon(
                    Teme.isDarktheme(prefss) == false
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    color: Teme.isDarktheme(prefss)
                        ? AppConstants.primaryColor
                        : AppConstants.secondaryColor,
                    size: 29,
                  ),
                ),
                title: Text(
                  LocaleKeys.theme.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefss)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    !Teme.isDarktheme(prefss) == false ? "Dark" : "Light",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, color: AppConstants.lamatGrey),
                  ),
                ),
              ),
            ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LanguagesScreen(
                        prefs: prefss,
                      ),
                    ));
              },
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultNumericValue,
                  0,
                  AppConstants.defaultNumericValue,
                  0),
              title: Text(
                LocaleKeys.language.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefss)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor)),
              ),
            ),
            ListTile(
              onTap: () async {
                if (observer.feedbackEmail.contains('@')) {
                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: observer.feedbackEmail,
                  );

                  await launchUrl(emailLaunchUri);
                } else {
                  custom_url_launcher(observer.feedbackEmail);
                }
              },
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultNumericValue,
                  0,
                  AppConstants.defaultNumericValue,
                  0),
              title: Text(
                LocaleKeys.feedback.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefss)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor)),
              ),
            ),
            ListTile(
              onTap: () {
                onTapRateApp();
              },
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultNumericValue,
                  0,
                  AppConstants.defaultNumericValue,
                  0),
              title: Text(
                LocaleKeys.rate.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefss)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor)),
              ),
            ),

            ListTile(
              onTap: () {
                Lamat.invite(this.context, ref);
              },
              contentPadding: const EdgeInsets.fromLTRB(
                  AppConstants.defaultNumericValue,
                  0,
                  AppConstants.defaultNumericValue,
                  0),
              title: Text(
                LocaleKeys.share.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    color: pickTextColorBasedOnBgColorAdvanced(
                        Teme.isDarktheme(prefss)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor)),
              ),
            ),
            observer.isLogoutButtonShowInSettingsPage == true
                ? const Divider()
                : const SizedBox(),
            observer.isLogoutButtonShowInSettingsPage == true
                ? ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      final currentUserId =
                          ref.read(currentUserStateProvider)?.phoneNumber;

                      if (currentUserId != null) {
                        await ref.read(userProfileNotifier).updateOnlineStatus(
                            isOnline: false, phoneNumber: currentUserId);
                      }
                      await prefss.clear();
                      await Hive.close();
                      await Hive.deleteBoxFromDisk(HiveConstants.hiveBox);
                      ref.read(authProvider).signOut();
                      EasyLoading.showSuccess(LocaleKeys.loggingout.tr());
                      ref.invalidate(currentUserStateProvider);
                    },
                    contentPadding: const EdgeInsets.fromLTRB(
                        AppConstants.defaultNumericValue,
                        0,
                        AppConstants.defaultNumericValue,
                        0),
                    title: Center(
                        child: Text(
                      LocaleKeys.logout.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 16,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(prefss)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                          fontWeight: FontWeight.w600),
                    )),
                  )
                : const SizedBox(),
            observer.isLogoutButtonShowInSettingsPage == true
                ? const Divider()
                : const SizedBox(),

            Padding(
                padding: const EdgeInsets.all(5),
                child: Column(children: [
                  AppRes.appLogo != null
                      ? Image.network(
                          AppRes.appLogo!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        )
                      : Image.asset(
                          AppConstants.logo,
                          color: AppConstants.primaryColor,
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                  Text(
                    'v ${prefss.getString('app_version') ?? ""}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppConstants.lamatGrey, fontSize: 17),
                  ),
                ])),
            const SizedBox(
              height: 17,
            ),
            const SizedBox(height: AppConstants.defaultNumericValue * 2),
          ],
        );
      })),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
          child: CustomButton(
            onPressed: () async {
              final UserAccountSettingsModel userAccountSettingsModel =
                  UserAccountSettingsModel(
                distanceInKm:
                    _isWorldWide ? null : _distanceInKm.toInt().toDouble(),
                interestedIn: _interestedIn,
                minimumAge: _minimumAge.toInt(),
                maximumAge: _maximumAge.toInt(),
                location: _userLocation ??
                    widget.user.userAccountSettingsModel.location,
                showAge: _showAge,
                showLocation: _showLocation,
                showOnlineStatus: _showOnlineStatus,
                showOnlyToPremiumUsers: _showOnlyToPremiumUsers,
                allowAnonymousMessages: _allowAnonymousMessages,
              );

              final userProfileModel = widget.user.copyWith(
                userAccountSettingsModel: userAccountSettingsModel,
                isOnline: _showOnlineStatus == false ? false : true,
              );
              EasyLoading.show(status: LocaleKeys.updating.tr());

              await ref
                  .read(userProfileNotifier)
                  .updateUserProfile(userProfileModel)
                  .then((value) {
                ref.invalidate(userProfileFutureProvider);
                EasyLoading.dismiss();
                !Responsive.isDesktop(context) ? Navigator.pop(context) : {};
              });
            },
            text: LocaleKeys.apply.tr(),
          ),
        ),
      ),
    );
  }

  onTapRateApp() {
    final observer = ref.watch(observerProvider);
    final prefs = ref.watch(sharedPreferences).value;
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Teme.isDarktheme(prefs!)
                ? AppConstants.dialogColorDark
                : AppConstants.backgroundColor,
            children: <Widget>[
              ListTile(
                  contentPadding: const EdgeInsets.only(top: 20),
                  subtitle: const Padding(padding: EdgeInsets.only(top: 10.0)),
                  title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40,
                          color: AppConstants.lamatGrey,
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: AppConstants.lamatGrey,
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: AppConstants.lamatGrey,
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: AppConstants.lamatGrey,
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: AppConstants.lamatGrey,
                        ),
                      ]),
                  onTap: () {
                    Navigator.of(context).pop();
                    !kIsWeb
                        ? Platform.isAndroid
                            ? custom_url_launcher(ConnectWithAdminApp == true
                                ? observer.userAppSettingsDoc!
                                    .data()![Dbkeys.newapplinkandroid]
                                : RateAppUrlAndroid)
                            : custom_url_launcher(ConnectWithAdminApp == true
                                ? observer.userAppSettingsDoc!
                                    .data()![Dbkeys.newapplinkios]
                                : RateAppUrlIOS)
                        : custom_url_launcher(AppConfig.webAppUrl);
                  }),
              const Divider(),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    LocaleKeys.loved.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
                              ? AppConstants.dialogColorDark
                              : AppConstants.backgroundColor),
                    ),
                    textAlign: TextAlign.center,
                  )),
              Center(
                  child: myElevatedButton(
                      color: AppConstants.primaryColor,
                      child: Text(
                        LocaleKeys.rate.tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        !kIsWeb
                            ? Platform.isAndroid
                                ? custom_url_launcher(
                                    ConnectWithAdminApp == true
                                        ? observer.userAppSettingsDoc!
                                            .data()![Dbkeys.newapplinkandroid]
                                        : RateAppUrlAndroid)
                                : custom_url_launcher(
                                    ConnectWithAdminApp == true
                                        ? observer.userAppSettingsDoc!
                                            .data()![Dbkeys.newapplinkios]
                                        : RateAppUrlIOS)
                            : custom_url_launcher(AppConfig.webAppUrl);
                      }))
            ],
          );
        });
  }
}

// ignore: unused_element
class _GenderButton extends StatelessWidget {
  final SharedPreferences prefs;
  final VoidCallback onPressed;
  final String text;
  final bool isSelected;
  const _GenderButton({
    required this.onPressed,
    required this.text,
    required this.isSelected,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultNumericValue * 1.5,
          vertical: AppConstants.defaultNumericValue,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor
              : AppConstants.primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(
            AppConstants.defaultNumericValue,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.2),
                    blurRadius: AppConstants.defaultNumericValue,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isSelected
                    ? Colors.white
                    : Teme.isDarktheme(prefs)
                        ? Colors.white
                        : Colors.black,
              ),
        ),
      ),
    );
  }
}
