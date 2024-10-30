// import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/views/FAQ/faqs_page.dart';
import 'package:lamatdating/views/about/about.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/privacypolicy&TnC/terms_policy.dart';

class WebViewScreen extends StatelessWidget {
  final int type;

  const WebViewScreen(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    // if (Platform.isAndroid) WebViewWidget. = SurfaceAndroidWebView();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 55,
              child: Stack(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppConstants.secondaryColor,
                                AppConstants.primaryColor,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )),
                  Center(
                    child: Text(
                      getTitle(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.3,
              color: AppConstants.textColorLight,
            ),
            if (type == 3) const PrivacyPolicyViewer(),
            if (type == 2) const TermsViewer(),
            if (type == 1) const FAQsPage(),
            if (type == 4) const AboutUsViewer(),
          ],
        ),
      ),
    );
  }

  String getTitle() {
    String title = '';
    if (type == 1) {
      title = LocaleKeys.help.tr();
    } else if (type == 2) {
      title = LocaleKeys.termsOfUse.tr();
    } else if (type == 3) {
      title = LocaleKeys.privacyPolicy.tr();
    } else if (type == 4) {
      title = LocaleKeys.aboutUs.tr();
    }
    return title;
  }
}
