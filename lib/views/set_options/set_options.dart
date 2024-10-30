// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
// import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/key_res.dart';

import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/custom_url_launcher.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/languages_screen/languages_screen.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';

class SettingsOption extends ConsumerStatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  final String currentUserNo;
  const SettingsOption(
      {super.key,
      required this.biometricEnabled,
      required this.currentUserNo,
      required this.type});

  @override
  SettingsOptionState createState() => SettingsOptionState();
}

class SettingsOptionState extends ConsumerState<SettingsOption> {
  late Stream myDocStream;
  bool isLoading = false;
  // final systemLocales = WidgetsBinding.instance.window.locales.first.languageCode.split('_')[0];

  String selectedLanguage =
      WidgetsBinding.instance.window.locales.first.languageCode.split('_')[0];
  SessionManager prefService = SessionManager();
  int? value = 0;

  @override
  void initState() {
    super.initState();
    myDocStream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .snapshots();
  }

  void onLanguageChange(int? value) async {
    this.value = value;
    prefService.saveString(KeyRes.languageCode, languageCode[value ?? 0]);
    selectedLanguage = languageCode[value ?? 0];
    context.setLocale(Locale(selectedLanguage));
    // setState(() {});
  }

  void prefData() async {
    await prefService.initPref();
    selectedLanguage = prefService.getString(KeyRes.languageCode) ??
        WidgetsBinding.instance.window.locales.first.languageCode.split('_')[0];
    value = languageCode.indexOf(selectedLanguage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    final observer = ref.watch(observerProvider);
    final prefs = ref.watch(sharedPreferences).value;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness:
          Teme.isDarktheme(prefs!) ? Brightness.light : Brightness.light,
      statusBarIconBrightness:
          Teme.isDarktheme(prefs) ? Brightness.light : Brightness.light,
    ));
    // const SystemUiOverlayStyle(
    //     statusBarBrightness: Brightness.light,
    //     statusBarIconBrightness: Brightness.light);
    return PickupLayout(
        prefs: prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
          backgroundColor: Teme.isDarktheme(prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Teme.isDarktheme(prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            elevation: 0,
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
            // systemOverlayStyle:  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            //   statusBarBrightness: Teme.isDarktheme(prefs!) ? Brightness.dark : Brightness.light,
            //   statusBarIconBrightness: Teme.isDarktheme(prefs!) ? Brightness.dark : Brightness.light,
            // ))
          ),
          body: ListView(
            children: [
              // const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue,
                  // top: MediaQuery.of(context).padding.top,
                ),
                child: CustomAppBar(
                  leading: Row(children: [
                    CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () => Navigator.pop(context),
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                  ]),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.settings.tr(),
                  )),
                  // trailing: CustomIconButton(
                  //   icon: ellipsisIcon,
                  //   onPressed: () {},
                  // ),
                ),
              ),
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
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),
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
                                              const AlwaysStoppedAnimation<
                                                      Color>(
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
                                                        ? Dbkeys
                                                            .topicUSERSandroid
                                                        : Platform.isIOS
                                                            ? Dbkeys
                                                                .topicUSERSios
                                                            : Dbkeys
                                                                .topicUSERSweb
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
                                                .unsubscribeFromTopic(Platform
                                                        .isAndroid
                                                    ? Dbkeys.topicUSERSandroid
                                                    : Platform.isIOS
                                                        ? Dbkeys.topicUSERSios
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
                                  3,
                                  AppConstants.defaultNumericValue,
                                  3),
                              title: Text(
                                LocaleKeys.generalnotification.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  LocaleKeys.generalnotificationdesc.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppConstants.lamatGrey),
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(30, 3, 25, 3),
                            title: Text(
                              LocaleKeys.generalnotification.tr(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                  )),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                LocaleKeys.generalnotificationdesc.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppConstants.lamatGrey),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
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
                    3,
                    AppConstants.defaultNumericValue,
                    3),
                title: Text(
                  LocaleKeys.feedback.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    LocaleKeys.givesuggestions.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, color: AppConstants.lamatGrey),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  onTapRateApp();
                },
                contentPadding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultNumericValue,
                    3,
                    AppConstants.defaultNumericValue,
                    3),
                title: Text(
                  LocaleKeys.rate.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    LocaleKeys.leavereview.tr(),
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
                          prefs: prefs,
                        ),
                      ));
                },
                contentPadding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultNumericValue,
                    3,
                    AppConstants.defaultNumericValue,
                    3),
                title: Text(
                  LocaleKeys.language.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    LocaleKeys.setlang.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, color: AppConstants.lamatGrey),
                  ),
                ),
              ),
              if (IsHIDELightDarkModeSwitchInApp == false)
                ListTile(
                  onTap: () {
                    final themeChange = ref.watch(darkThemeProvider.notifier);

                    themeChange.darkTheme = !Teme.isDarktheme(prefs);

                    Navigator.of(this.context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (BuildContext context) => const MyApp(),
                      ),
                      (Route route) => false,
                    );
                  },
                  contentPadding: const EdgeInsets.fromLTRB(
                      AppConstants.defaultNumericValue,
                      3,
                      AppConstants.defaultNumericValue,
                      3),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      Teme.isDarktheme(prefs) == false
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                      color: Teme.isDarktheme(prefs)
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
                            Teme.isDarktheme(prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      !Teme.isDarktheme(prefs) == false
                          ? LocaleKeys.dark.tr()
                          : LocaleKeys.light.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, color: AppConstants.lamatGrey),
                    ),
                  ),
                ),
              ListTile(
                onTap: () {
                  Lamat.invite(this.context, ref);
                },
                contentPadding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultNumericValue,
                    3,
                    AppConstants.defaultNumericValue,
                    3),
                leading: Icon(
                  Icons.people_rounded,
                  color: AppConstants.primaryColor.withOpacity(0.85),
                  size: 26,
                ),
                title: Text(
                  LocaleKeys.share.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(prefs)
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
                          await ref
                              .read(userProfileNotifier)
                              .updateOnlineStatus(
                                  isOnline: false, phoneNumber: currentUserId);
                        }
                        await prefs.clear();
                        await Hive.close();
                        await Hive.deleteBoxFromDisk(HiveConstants.hiveBox);
                        ref.read(authProvider).signOut();
                        EasyLoading.showSuccess(LocaleKeys.loggingout.tr());
                        ref.invalidate(currentUserStateProvider);
                      },
                      contentPadding: const EdgeInsets.fromLTRB(30, 0, 10, 6),
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppConstants.lamatREDbuttonColor,
                        size: 26,
                      ),
                      title: Text(
                        LocaleKeys.logOut.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(prefs)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor),
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  : const SizedBox(),

              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  'v ${prefs.getString('app_version') ?? ""}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppConstants.lamatGrey, fontSize: 12),
                ),
              ),
              const SizedBox(
                height: 17,
              )
            ],
          ),
        )));
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
                            : custom_url_launcher(AppConfig.webAppRatingUrl);
                      }))
            ],
          );
        });
  }

  List<String> languages = [
    'عربي',
    'dansk',
    'Nederlands',
    'English',
    'Français',
    'Deutsch',
    'Ελληνικά',
    'हिंदी',
    'bahasa Indonesia',
    'Italiano',
    '日本',
    '한국인',
    'Norsk Bokmal',
    'Polski',
    'Português',
    'Русский',
    '简体中文',
    'Español',
    'แบบไทย',
    'Türkçe',
    'Tiếng Việt',
  ];
  List<String> subLanguage = [
    'Arabic',
    'Danish',
    'Dutch',
    'English',
    'French',
    'German',
    'Greek',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Norwegian Bokmal',
    'Polish',
    'Portuguese',
    'Russian',
    'Simplified Chinese',
    'Spanish',
    'Thai',
    'Turkish',
    'Vietnamese',
  ];
  List languageCode = [
    'ar',
    'da',
    'nl',
    'en',
    'fr',
    'de',
    'el',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'nb',
    'pl',
    'pt',
    'ru',
    'zh',
    'es',
    'th',
    'tr',
    'vi',
  ];
}
