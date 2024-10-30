// ignore_for_file: unused_element, deprecated_member_use

// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/translate_notifs.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/key_res.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/localization/language.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class LanguagesScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const LanguagesScreen({super.key, required this.prefs});

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  String? selectedLanguage;
  SessionManager prefService = SessionManager();

  @override
  void initState() {
    prefData();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   toolbarHeight: 0,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   // systemOverlayStyle: SystemUiOverlayStyle.dark,
      // ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
          color: Teme.isDarktheme(widget.prefs) == true
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
        ),
        child: Column(
          children: [
            // const SizedBox(height: AppConstants.defaultNumericValue),
            Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
                color: Teme.isDarktheme(widget.prefs) == true
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.defaultNumericValue,
                  horizontal: AppConstants.defaultNumericValue),
              child: CustomAppBar(
                leading: CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                    onPressed: () => Navigator.pop(context),
                    color: AppConstants.primaryColor,
                    icon: leftArrowSvg),
                title: Center(
                    child: CustomHeadLine(
                  // prefs: widget.prefs,
                  text: LocaleKeys.languages.tr(),
                )),
              ),
            ),
            // const SizedBox(height: AppConstants.defaultNumericValue),
            // Container(
            //   height: 0.3,
            //   color: AppConstants.textColorLight,
            // ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.defaultNumericValue),
                  // margin: const EdgeInsets.only(
                  //     bottom: AppConstants.defaultNumericValue),
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    color: Teme.isDarktheme(widget.prefs) == true
                        ? AppConstants.backgroundColor.withOpacity(.1)
                        : AppConstants.backgroundColorDark.withOpacity(.1),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return RadioListTile(
                        value: index,
                        groupValue: value,
                        dense: true,
                        fillColor: MaterialStateProperty.all(
                            AppConstants.primaryColor),
                        tileColor: Colors.transparent,
                        onChanged: onLanguageChange,
                        title: Text(languages[index],
                            style: const TextStyle(fontSize: 15)),
                        subtitle: Text(subLanguage[index],
                            style: const TextStyle(
                              color: AppConstants.textColorLight,
                            )),
                      );
                    },
                    itemCount: languages.length,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  int? value = 0;
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

  void onLanguageChange(int? value) async {
    this.value = value;
    prefService.saveString(KeyRes.languageCode, languageCode[value ?? 0]);
    selectedLanguage = languageCode[value ?? 0];
    // MyApp.of(context)?.setLocale(selectedLanguage!);
    AppRes.selectedLanguage = selectedLanguage!;
    context.setLocale(Locale(
        selectedLanguage ?? prefService.getString(KeyRes.languageCode)!));
    setState(() {});
  }

  void _changeLanguage(Language language) async {
    Future.delayed(const Duration(milliseconds: 800), () {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.prefs.getString(Dbkeys.phone))
          .update({
        Dbkeys.notificationStringsMap:
            getTranslateNotificationStringsMap(context),
      });
    });

    setState(() {});
  }

  void prefData() async {
    final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;
    final Locale primaryLocale = systemLocales.first;
    await prefService.initPref();
    selectedLanguage = prefService.getString(KeyRes.languageCode) ??
        primaryLocale.languageCode.split('_')[0];
    value = languageCode.indexOf(selectedLanguage);
    // setState(() {});
  }
}
