// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/landing_page_model.dart';
import 'package:lamatdating/providers/country_codes_provider.dart';
import 'package:lamatdating/providers/get_current_location_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/auth/login_page.dart';
import 'package:lamatdating/views/privacypolicy&TnC/privacypage.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class WebHomePage extends ConsumerStatefulWidget {
  final String? title;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  const WebHomePage(
      {super.key,
      this.title,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.doc,
      required this.isblocknewlogins});

  @override
  WebHomePageState createState() => WebHomePageState();
}

class WebHomePageState extends ConsumerState<WebHomePage> {
  HomePageModel? homePageContent;
  HomePageModel? homePageContentEdited;
  bool isLoading = true;
  final placeholderImage =
      "https://raw.githubusercontent.com/julien-gargot/images-placeholder/master/placeholder-square.png";

  TextEditingController phoneController = TextEditingController();

  bool isOpenHomeDialog = false;

  @override
  void initState() {
    super.initState();
    fetchPrivacyPolicy();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      final webHomepage = await FirebaseFirestore.instance
          .collection('web_homepage')
          .doc('latest')
          .get();

      if (webHomepage.exists) {
        setState(() {
          homePageContent = HomePageModel.fromMap(webHomepage.data() ?? {});

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching Home Page: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomSheet: (widget.prefs.getBool('privacyDialogOpen') == false ||
              widget.prefs.getBool('privacyDialogOpen') == null)
          ? (isOpenHomeDialog == false)
              ? Container(
                  height: height * .1,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: !Responsive.isDesktop(context)
                            ? width * .68
                            : width * .2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.locationpermissionsaredenied.tr() +
                                  Appname,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.none,
                                color: AppConstants.textColorLight,
                              ),
                            ),
                            // Text(
                            //   LocaleKeys
                            //       .pleaseCheckThesePrivacyPolicyAndTermsOfUseBefore
                            //       .tr(),
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     fontSize: 10,
                            //     decoration: TextDecoration.none,
                            //     color: Teme.isDarktheme(widget.prefs)
                            //         ? AppConstants.textColor
                            //         : AppConstants.textColorLight,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WebViewScreen(2),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    child: Text(
                                      LocaleKeys.tnc.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: AppConstants.primaryColor,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  width: 3,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: const BoxDecoration(
                                    color: AppConstants.primaryColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                          type:
                                              PageTransitionType.bottomToTopPop,
                                          childCurrent: widget,
                                          child: const PrivacyPolicyViewer(),
                                        ));
                                  },
                                  child: SizedBox(
                                    child: Text(
                                      LocaleKeys.privacyPolicy.tr(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                        color: AppConstants.primaryColor,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: !Responsive.isDesktop(context)
                            ? width * .2
                            : width * .1,
                        child: Column(
                          children: [
                            Expanded(
                              child: InkWell(
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                onTap: () {
                                  widget.prefs
                                      .setBool('privacyDialogOpen', true);
                                  // myLoading.setIsHomeDialogOpen(false);
                                  // Navigator.pop(context);
                                  setState(() {
                                    isOpenHomeDialog = true;
                                  });
                                  AppRes.countryCodesData =
                                      ref.watch(countryCodesProvider).value;
                                  AppRes.currentLocationProviderProvider ??= ref
                                      .watch(getCurrentLocationProviderProvider)
                                      .value;
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppConstants.primaryColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      LocaleKeys.accept.tr(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                overlayColor:
                                    WidgetStateProperty.all(Colors.transparent),
                                onTap: () {
                                  setState(() {
                                    isOpenHomeDialog = true;
                                  });
                                  widget.prefs
                                      .setBool('privacyDialogOpen', false);
                                  // Navigator.pop(context);
                                },
                                child: SizedBox(
                                  child: Center(
                                    child: Text(
                                      LocaleKeys.rjt.tr(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ))
              : const SizedBox()
          : const SizedBox(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HeaderSection(
              phoneNumber: '',
              prefs: widget.prefs,
              accountApprovalMessage: widget.accountApprovalMessage,
              isaccountapprovalbyadminneeded:
                  widget.isaccountapprovalbyadminneeded,
              isblocknewlogins: widget.isblocknewlogins,
              title: widget.title,
              doc: widget.doc,
            ),
            Container(
              color: Colors.white,
              height: height - 100,
              width: width,
              child: Row(
                children: [
                  Container(
                    width: (Responsive.isDesktop(context)) ? width * .6 : width,
                    padding: EdgeInsets.only(
                        right: (Responsive.isDesktop(context))
                            ? width * .1
                            : width * .05,
                        left: width * .05),
                    color: const Color(0xFFE9D8FF),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: height * .05),
                        Text(
                            homePageContent != null
                                ? homePageContent!.heroTitle ?? "..."
                                : "Here’s to dating \nwith confidence.",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: const Color(0xFFCC261A),
                                  fontSize:
                                      Responsive.isDesktop(context) ? 70 : 40,
                                )
                            //  TextStyle(
                            //     fontSize: Responsive.isDesktop(context) ? 70 : 40,
                            //     fontWeight: FontWeight.w900,
                            //     color: const Color(0xFFCC261A)),
                            ),
                        const SizedBox(height: 10),
                        Text(
                          homePageContent != null
                              ? homePageContent!.heroDescription ?? "..."
                              : "Helping to put more of the real you in, \nfor dating you feel good about.",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: Responsive.isDesktop(context) ? 35 : 18,
                              color: Colors.black),
                        ),
                        SizedBox(height: height * .07),
                        Row(
                          children: [
                            SizedBox(
                              width: Responsive.isDesktop(context)
                                  ? width * .2
                                  : width * .4,
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                                decoration: InputDecoration(
                                  constraints: BoxConstraints(
                                      minWidth: (Responsive.isDesktop(context))
                                          ? 200
                                          : 100,
                                      minHeight: 54),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: '650 XXXX XXX (NO COUNTRY CODE)',
                                  hintStyle: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(35),
                                      borderSide: const BorderSide(
                                        color: Colors.black,
                                        width: 1,
                                      )),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width:
                                  (Responsive.isDesktop(context)) ? 300 : 150,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.bottomToTopPop,
                                      childCurrent: widget,
                                      child: PhoneLoginLandingWidget(
                                        phoneNumber:
                                            phoneController.text.trim(),
                                        prefs: widget.prefs,
                                        accountApprovalMessage:
                                            widget.accountApprovalMessage,
                                        isaccountapprovalbyadminneeded: widget
                                            .isaccountapprovalbyadminneeded,
                                        isblocknewlogins:
                                            widget.isblocknewlogins,
                                        title: widget.title,
                                        doc: widget.doc,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(200, 54),
                                ),
                                child: const Text('Sign up',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Or",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.g_mobiledata,
                                    size: 28, color: Colors.black),
                                label: Text(
                                  (Responsive.isDesktop(context))
                                      ? 'Continue with Google'
                                      : "Google",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 54),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        side: const BorderSide(
                                            color: Colors.black))),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.facebook,
                                    color: Colors.black),
                                label: Text(
                                  (Responsive.isDesktop(context))
                                      ? 'Continue with Facebook'
                                      : "Facebook",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(200, 54),
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        side: const BorderSide(
                                            color: Colors.black))),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTopPop,
                                        childCurrent: widget,
                                        child: LoginPage(
                                          prefs: widget.prefs,
                                          accountApprovalMessage:
                                              widget.accountApprovalMessage,
                                          isaccountapprovalbyadminneeded: widget
                                              .isaccountapprovalbyadminneeded,
                                          isblocknewlogins:
                                              widget.isblocknewlogins,
                                          title: widget.title,
                                          doc: widget.doc,
                                        )));
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  const Text(
                                    "By signing up, you agree to our ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: const Text(
                                      "Terms & Conditions.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    " Learn how we use your data in our ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: const Text(
                                      "Privacy Policy.",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: height * .1,
                        ),
                      ],
                    ),
                  ),
                  if (Responsive.isDesktop(context))
                    Expanded(
                      child: SizedBox(
                        height: height - 100,
                        child: CachedNetworkImage(
                          imageUrl: homePageContent != null
                              ? homePageContent!.heroImage ?? placeholderImage
                              : placeholderImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFFF3EAFF),
              height: height * .7,
              width: width,
              padding: EdgeInsets.symmetric(
                horizontal:
                    (Responsive.isDesktop(context)) ? width * .1 : width * .05,
                vertical: (Responsive.isDesktop(context))
                    ? height * .15
                    : height * .05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (Responsive.isDesktop(context))
                    SizedBox(
                      width: width * .3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            32.0), // Adjust the radius as needed
                        child: CachedNetworkImage(
                          imageUrl: homePageContent != null
                              ? homePageContent!.confidenceImage ??
                                  placeholderImage
                              : placeholderImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (Responsive.isDesktop(context))
                    const SizedBox(
                      width: 60,
                    ),
                  SizedBox(
                    width: (Responsive.isDesktop(context))
                        ? width * .3
                        : width * .8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          homePageContent != null
                              ? homePageContent!.confidenceTitle ?? "..."
                              : "We’re all about confidence.",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                color: Colors.black,
                                fontSize:
                                    (Responsive.isDesktop(context)) ? 32 : 25,
                              ),
                        ),
                        const Spacer(),
                        if (!Responsive.isDesktop(context))
                          SizedBox(
                            width: width * .8,
                            height: height * .25,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  32.0), // Adjust the radius as needed
                              child: CachedNetworkImage(
                                imageUrl: homePageContent != null
                                    ? homePageContent!.confidenceImage ??
                                        placeholderImage
                                    : placeholderImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        if (!Responsive.isDesktop(context)) const Spacer(),
                        Text(
                          homePageContent != null
                              ? homePageContent!.confidenceP1 ?? "..."
                              : "With our latest tech that helps combat fake, scam and spam accounts, you can trust that you’re talking to genuine people.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  (Responsive.isDesktop(context)) ? 18 : 14),
                          maxLines: 3,
                        ),
                        const Spacer(),
                        Text(
                          homePageContent != null
                              ? homePageContent!.confidenceP2 ?? "..."
                              : "Our support and safety tools help put the real, most confident you out there — so you can find the relationships that matter.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize:
                                  (Responsive.isDesktop(context)) ? 18 : 14),
                          maxLines: 3,
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTopPop,
                                childCurrent: widget,
                                child: PhoneLoginLandingWidget(
                                  phoneNumber: '',
                                  prefs: widget.prefs,
                                  accountApprovalMessage:
                                      widget.accountApprovalMessage,
                                  isaccountapprovalbyadminneeded:
                                      widget.isaccountapprovalbyadminneeded,
                                  isblocknewlogins: widget.isblocknewlogins,
                                  title: widget.title,
                                  doc: widget.doc,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(200, 54),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  side: const BorderSide(color: Colors.black))),
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ), // Text color to black
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height:
                  (Responsive.isDesktop(context)) ? height * .8 : height * .9,
              width: width,
              child: Padding(
                padding: EdgeInsets.only(left: width * .1, right: width * .1),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: height * .05,
                                ),
                                Text(
                                  homePageContent != null
                                      ? homePageContent!.readyTitle ?? "..."
                                      : "Ready to chat now?",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        color: Colors.black,
                                        fontSize:
                                            (Responsive.isDesktop(context))
                                                ? 32
                                                : 25,
                                      ),
                                ),
                                if (!Responsive.isDesktop(context))
                                  const Spacer(),
                                if (!Responsive.isDesktop(context))
                                  SizedBox(
                                    width: width,
                                    height: width,
                                    child: Center(
                                      child: CachedNetworkImage(
                                        imageUrl: homePageContent != null
                                            ? homePageContent!.readyImage ??
                                                placeholderImage
                                            : placeholderImage,
                                        width: width,
                                        height: width,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if (!Responsive.isDesktop(context))
                                  SizedBox(
                                    height: height * .01,
                                  ),
                                if (!Responsive.isDesktop(context))
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Text(
                                        "Models used for illustrative purposes only",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                      ),
                                    ],
                                  )),
                                const Spacer(),
                                Text(
                                  homePageContent != null
                                      ? homePageContent!.readyP1 ?? "..."
                                      : "There’s no need to wait for a match.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                ),
                                const Spacer(),
                                Text(
                                  homePageContent != null
                                      ? homePageContent!.readyP2 ?? "..."
                                      : "Dive into the chats that go a little deeper, and get straight to the good stuff. You know, the bit where you really get to know each other.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                ),
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.bottomToTopPop,
                                        childCurrent: widget,
                                        child: PhoneLoginLandingWidget(
                                          phoneNumber: '',
                                          prefs: widget.prefs,
                                          accountApprovalMessage:
                                              widget.accountApprovalMessage,
                                          isaccountapprovalbyadminneeded: widget
                                              .isaccountapprovalbyadminneeded,
                                          isblocknewlogins:
                                              widget.isblocknewlogins,
                                          title: widget.title,
                                          doc: widget.doc,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(200, 54),
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          side: const BorderSide(
                                              color: Colors.black))),
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ), // Text color to black
                                  ),
                                ),
                                if (Responsive.isDesktop(context))
                                  SizedBox(
                                    height: height * .05,
                                  ),
                                if (Responsive.isDesktop(context))
                                  Expanded(
                                      child: Container(
                                    alignment: Alignment.bottomCenter,
                                    child: Row(
                                      children: [
                                        Text(
                                          "Models used for illustrative purposes only",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                        ),
                                      ],
                                    ),
                                  )),
                                SizedBox(
                                  height: height * .05,
                                ),
                              ],
                            ),
                          ),
                          (Responsive.isDesktop(context))
                              ? const SizedBox(width: 50)
                              : const SizedBox(width: 0),
                          (Responsive.isDesktop(context))
                              ? Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: CachedNetworkImage(
                                      imageUrl: homePageContent != null
                                          ? homePageContent!.readyImage ??
                                              placeholderImage
                                          : placeholderImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFFF3EAFF),
              height: height * .8,
              width: width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width:
                            Responsive.isDesktop(context) ? width * .5 : width,
                        height: height * 0.8,
                        child: CachedNetworkImage(
                          imageUrl: homePageContent != null
                              ? homePageContent!.meetImage ?? placeholderImage
                              : placeholderImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Responsive.isDesktop(context)
                          ? Container(
                              padding: EdgeInsets.only(
                                  top: height * .1,
                                  bottom: height * .1,
                                  left: width * 0.1,
                                  right: width * 0.1),
                              width: width * 0.5,
                              height: height * 0.8,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.meetTitle ?? "..."
                                        : "Meet people who want the same thing.",
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.meetP1 ?? "..."
                                        : "Get what you want out of dating. No need to apologise.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.meetP2 ?? "..."
                                        : "Just want to chat? That's OK. Ready to settle down? Love that.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.meetP3 ?? "..."
                                        : "And if you ever change your mind, you absolutely can.",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type:
                                              PageTransitionType.bottomToTopPop,
                                          childCurrent: widget,
                                          child: PhoneLoginLandingWidget(
                                            phoneNumber: '',
                                            prefs: widget.prefs,
                                            accountApprovalMessage:
                                                widget.accountApprovalMessage,
                                            isaccountapprovalbyadminneeded: widget
                                                .isaccountapprovalbyadminneeded,
                                            isblocknewlogins:
                                                widget.isblocknewlogins,
                                            title: widget.title,
                                            doc: widget.doc,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(200, 54),
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            side: const BorderSide(
                                                color: Colors.black))),
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ), // Text color to black
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: 0, height: 0),
                    ],
                  ),
                  Positioned(
                    left: 20,
                    top: 50,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.verified_rounded,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          homePageContent != null
                              ? homePageContent!.meetUser ?? "..."
                              : "Emma, 35",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OptionButton(
                          icon: Icons.coffee,
                          label: 'Here to date',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                        ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: OptionButton(
                              icon: Icons.favorite,
                              label: 'Ready for a relationship',
                              onPressed: () {},
                            )),
                        const SizedBox(height: 20),
                        ImageFiltered(
                            imageFilter:
                                ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                            child: OptionButton(
                              icon: Icons.chat_bubble,
                              label: 'Open to chat',
                              onPressed: () {},
                            )),
                      ],
                    ),
                  ),
                  (!Responsive.isDesktop(context))
                      ? Positioned(
                          right: 20,
                          top: 50,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return PopScope(
                                          canPop: false,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 10, sigmaY: 10),
                                            child: Dialog(
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: width * .08),
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Container(
                                                height: kIsWeb
                                                    ? Responsive.isMobile(
                                                            context)
                                                        ? height * .7
                                                        : height * .7
                                                    : height * .7,
                                                width: kIsWeb
                                                    ? Responsive.isMobile(
                                                            context)
                                                        ? width * .8
                                                        : width * .5
                                                    : width * .8,
                                                decoration: BoxDecoration(
                                                  color: Teme.isDarktheme(
                                                          widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(22)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    const Spacer(),
                                                    Image.asset(
                                                      AppConstants.symbol,
                                                      color: AppConstants
                                                          .primaryColor,
                                                      width: 90,
                                                      height: 90,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    const Spacer(),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: AppConstants
                                                              .defaultNumericValue,
                                                          right: AppConstants
                                                              .defaultNumericValue),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Container(
                                                              height: 2,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            1),
                                                                gradient:
                                                                    const LinearGradient(
                                                                  // Set your glow color gradient
                                                                  begin: Alignment
                                                                      .centerLeft,
                                                                  end: Alignment
                                                                      .centerRight,
                                                                  colors: [
                                                                    AppConstants
                                                                        .primaryColor,
                                                                    AppConstants
                                                                        .midColor,
                                                                    AppConstants
                                                                        .secondaryColor
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        homePageContent != null
                                                            ? homePageContent!
                                                                    .meetTitle ??
                                                                "..."
                                                            : "Meet people who want the same thing.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 32,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .textColor
                                                              : AppConstants
                                                                  .textColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        homePageContent != null
                                                            ? homePageContent!
                                                                    .meetP1 ??
                                                                "..."
                                                            : "Get what you want out of dating. No need to apologise.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .textColor
                                                              : AppConstants
                                                                  .textColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        homePageContent != null
                                                            ? homePageContent!
                                                                    .meetP2 ??
                                                                "..."
                                                            : "Just want to chat? That's OK. Ready to settle down? Love that.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .textColor
                                                              : AppConstants
                                                                  .textColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        homePageContent != null
                                                            ? homePageContent!
                                                                    .meetP3 ??
                                                                "..."
                                                            : "And if you ever change your mind, you absolutely can.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          color: Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .textColor
                                                              : AppConstants
                                                                  .textColorLight,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const WebViewScreen(
                                                                            2),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Text(
                                                              LocaleKeys.tnc
                                                                  .tr(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 3,
                                                          width: 3,
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      5),
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppConstants
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            3)),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                PageTransition(
                                                                  type: PageTransitionType
                                                                      .bottomToTopPop,
                                                                  childCurrent:
                                                                      widget,
                                                                  child:
                                                                      const PrivacyPolicyViewer(),
                                                                ));
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Text(
                                                              LocaleKeys
                                                                  .privacyPolicy
                                                                  .tr(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            overlayColor:
                                                                WidgetStateProperty
                                                                    .all(Colors
                                                                        .transparent),
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                PageTransition(
                                                                  type: PageTransitionType
                                                                      .bottomToTopPop,
                                                                  childCurrent:
                                                                      widget,
                                                                  child:
                                                                      PhoneLoginLandingWidget(
                                                                    phoneNumber:
                                                                        '',
                                                                    prefs: widget
                                                                        .prefs,
                                                                    accountApprovalMessage:
                                                                        widget
                                                                            .accountApprovalMessage,
                                                                    isaccountapprovalbyadminneeded:
                                                                        widget
                                                                            .isaccountapprovalbyadminneeded,
                                                                    isblocknewlogins:
                                                                        widget
                                                                            .isblocknewlogins,
                                                                    title: widget
                                                                        .title,
                                                                    doc: widget
                                                                        .doc,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 55,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: AppConstants
                                                                    .primaryColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                ),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  LocaleKeys
                                                                      .start
                                                                      .tr(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            overlayColor:
                                                                WidgetStateProperty
                                                                    .all(Colors
                                                                        .transparent),
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                              // exitApp();
                                                            },
                                                            child: Container(
                                                              height: 55,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: AppConstants
                                                                    .secondaryColor,
                                                                borderRadius: BorderRadius
                                                                    .only(
                                                                        // bottomLeft: Radius.circular(20),
                                                                        bottomRight:
                                                                            Radius.circular(20)),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  LocaleKeys.rjt
                                                                      .tr(),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .none,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      barrierDismissible: false);
                                },
                                child: const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.info_outlined,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: 0, height: 0),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height:
                  (Responsive.isDesktop(context)) ? height * .9 : height * .75,
              width: width,
              child: Padding(
                padding: EdgeInsets.only(
                  left: width * .1,
                  right: width * .1,
                  top: height * .05,
                  bottom: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homePageContent != null
                          ? homePageContent!.successTitle ?? "..."
                          : "Lamat Success Stories",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.black,
                            fontSize: (Responsive.isDesktop(context)) ? 32 : 25,
                          ),
                    ),
                    SizedBox(
                      height: height * .05,
                    ),
                    SizedBox(
                      height:
                          Responsive.isDesktop(context) ? height * .61 : width,
                      width: Responsive.isDesktop(context)
                          ? width * .9
                          : width * .8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStoryCard(
                              name: 'Kevin',
                              name2: "Natasha",
                              quote: homePageContent != null
                                  ? homePageContent!.successP1 ?? "..."
                                  : "I received his message 10 minutes after I signed up.",
                              imageUrl: homePageContent != null
                                  ? homePageContent!.successImage1 ??
                                      placeholderImage
                                  : placeholderImage, // Replace with actual image path
                            ),
                            const SizedBox(width: 30),
                            _buildStoryCard(
                              name: 'Enrique',
                              name2: "Nicole",
                              quote: homePageContent != null
                                  ? homePageContent!.successP2 ?? "..."
                                  : "He was my first thought when I woke up in the morning.",
                              imageUrl: homePageContent != null
                                  ? homePageContent!.successImage2 ??
                                      placeholderImage
                                  : placeholderImage, // Replace with actual image path
                            ),
                            const SizedBox(width: 30),
                            _buildStoryCard(
                              name: 'Christopher',
                              name2: "Kelly",
                              quote: homePageContent != null
                                  ? homePageContent!.successP3 ?? "..."
                                  : "It's thanks to Lamat that Marine and I are able to live this beautiful life.",
                              imageUrl: homePageContent != null
                                  ? homePageContent!.successImage3 ??
                                      placeholderImage
                                  : placeholderImage, // Replace with actual image path
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.bottomToTopPop,
                            childCurrent: widget,
                            child: PhoneLoginLandingWidget(
                              phoneNumber: '',
                              prefs: widget.prefs,
                              accountApprovalMessage:
                                  widget.accountApprovalMessage,
                              isaccountapprovalbyadminneeded:
                                  widget.isaccountapprovalbyadminneeded,
                              isblocknewlogins: widget.isblocknewlogins,
                              title: widget.title,
                              doc: widget.doc,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(200, 54),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                              side: const BorderSide(color: Colors.black))),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white), // Text color to black
                      ),
                    ),
                    // const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFFB492DE),
              height:
                  (Responsive.isDesktop(context)) ? height * .5 : height * .8,
              width: width,
              padding: EdgeInsets.only(
                top: height * .1,
                // bottom: height * .1,
                left: width * .05,
                right: width * .05,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: height * .35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                homePageContent != null
                                    ? homePageContent!.experienceTitle ?? "..."
                                    : "We know what we’re doing.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      (Responsive.isDesktop(context)) ? 32 : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: width * .4,
                                child: Text(
                                  homePageContent != null
                                      ? homePageContent!.experienceP1 ?? "..."
                                      : "Trust us. We've brought millions (and millions, and millions) of people together since 2006.",
                                  textAlign: TextAlign.left,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.experienceP2 ?? "..."
                                        : "100M+",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    homePageContent != null
                                        ? homePageContent!.experienceP3 ?? "..."
                                        : "Downloads",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                homePageContent != null
                                    ? homePageContent!.experienceP4 ?? "..."
                                    : "Google Play Store",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                        (Responsive.isDesktop(context))
                            ? Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: homePageContent != null
                                      ? homePageContent!.experienceImage ??
                                          placeholderImage
                                      : placeholderImage,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  (!Responsive.isDesktop(context))
                      ? Expanded(
                          child: CachedNetworkImage(
                            imageUrl: homePageContent != null
                                ? homePageContent!.experienceImage ??
                                    placeholderImage
                                : placeholderImage,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(
      {required String name,
      required String quote,
      required String imageUrl,
      required String name2}) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: Responsive.isDesktop(context) ? width * .3 : width * .8,
      height: Responsive.isDesktop(context) ? height * .61 : width,
      child: Column(
        children: [
          SizedBox(
            height: Responsive.isDesktop(context) ? width * .3 : width * .8,
            child: Stack(
              children: [
                Card(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF600B36),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF600B36),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Text(
                      name2,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              quote,
              maxLines: 3,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const OptionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 32,
        color: Colors.black,
      ),
      label: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18), // Rounded corners
        ),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
        textStyle: const TextStyle(
            fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final HomePageModel? homePageContent;
  final String? title;
  final User? user;
  final bool? isVerifying;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final String? phoneNumber;
  const HeaderSection(
      {super.key,
      this.homePageContent,
      this.title,
      this.user,
      this.isVerifying,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.doc,
      required this.isblocknewlogins,
      required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // final double height = MediaQuery.of(context).size.height;
    const placeholderImage =
        "https://raw.githubusercontent.com/julien-gargot/images-placeholder/master/placeholder-square.png";
    return Container(
      height: 100,
      width: width,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * .05,
          ),
          CachedNetworkImage(
            imageUrl: homePageContent != null
                ? homePageContent!.logo ?? placeholderImage
                : placeholderImage,
            height: 50,
            fit: BoxFit.contain,
          ),
          const Expanded(child: SizedBox()),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.bottomToTopPop,
                          childCurrent: WebHomePage(
                            prefs: prefs,
                            accountApprovalMessage: accountApprovalMessage,
                            isaccountapprovalbyadminneeded:
                                isaccountapprovalbyadminneeded,
                            isblocknewlogins: isblocknewlogins,
                            title: title,
                            doc: doc,
                          ),
                          child: LoginPage(
                            prefs: prefs,
                            accountApprovalMessage: accountApprovalMessage,
                            isaccountapprovalbyadminneeded:
                                isaccountapprovalbyadminneeded,
                            isblocknewlogins: isblocknewlogins,
                            title: title,
                            doc: doc,
                          )));
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(143, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: const BorderSide(
                          width: 1,
                          color: Colors.black,
                        ))),
                child: const Text('Log in',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.bottomToTopPop,
                      childCurrent: WebHomePage(
                        prefs: prefs,
                        accountApprovalMessage: accountApprovalMessage,
                        isaccountapprovalbyadminneeded:
                            isaccountapprovalbyadminneeded,
                        isblocknewlogins: isblocknewlogins,
                        title: title,
                        doc: doc,
                      ),
                      child: PhoneLoginLandingWidget(
                        phoneNumber: '',
                        prefs: prefs,
                        accountApprovalMessage: accountApprovalMessage,
                        isaccountapprovalbyadminneeded:
                            isaccountapprovalbyadminneeded,
                        isblocknewlogins: isblocknewlogins,
                        title: title,
                        doc: doc,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(143, 50),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Sign up',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          SizedBox(
            width: width * .05,
          ),
        ],
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  final HomePageModel? homePageContent;

  const FooterSection({super.key, this.homePageContent});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    String language = "English (United Kingdom)";
    const placeholderImage =
        "https://raw.githubusercontent.com/julien-gargot/images-placeholder/master/placeholder-square.png";
    return Container(
      color: Colors.white,
      height: (Responsive.isDesktop(context)) ? height * 0.55 : height * 0.85,
      width: width,
      padding: EdgeInsets.symmetric(
          horizontal: width * 0.05, vertical: width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height:
                (Responsive.isDesktop(context)) ? height * 0.33 : height * 0.28,
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (!Responsive.isDesktop(context))
                      Text(
                        '${homePageContent != null ? homePageContent!.appName ?? "..." : Appname} is part of ${homePageContent != null ? homePageContent!.company ?? "..." : "ABBBLE CO"}.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.black),
                      ),
                    if (!Responsive.isDesktop(context))
                      const SizedBox(
                        height: 20,
                      ),
                    Text(
                      "Overview",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.black),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Lamat - The Blog link tap
                    //   },
                    //   child: const Text('Lamat - The Blog'),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Safety Centre link tap
                    //   },
                    //   child: const Text('Safety Centre'),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Careers link tap
                    //   },
                    //   child: const Text('Careers'),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Dongin Piry and the Google Firy Ingo am link tap
                    //   },
                    //   child: const Text('Dongin Piry and the Google Firy Ingo am'),
                    // ),
                    InkWell(
                      onTap: () {
                        // Handle Chat link tap
                      },
                      child: Text(
                        'Chat',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        // Handle Chat link tap
                      },
                      child: Text(
                        'FAQ',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        // Handle Terms and conditions link tap
                      },
                      child: Text(
                        'Terms and conditions',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Notice At Collection link tap
                    //   },
                    //   child: const Text('Notice At Collection'),
                    // ),
                    InkWell(
                      onTap: () {
                        // Handle Privacy policy link tap
                      },
                      child: Text(
                        'Privacy policy',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Community Guidelines link tap
                    //   },
                    //   child: const Text('Community Guidelines'),
                    // ),
                    InkWell(
                      onTap: () {
                        // Handle Cookie Policy link tap
                      },
                      child: Text(
                        'Cookie Policy',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Manage cookies link tap
                    //   },
                    //   child: const Text('Manage cookies'),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     // Handle Modern Slavery Act statement link tap
                    //   },
                    //   child: const Text('Modern Slavery Act statement'),
                    // ),
                  ],
                ),
                if (Responsive.isDesktop(context))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${homePageContent != null ? homePageContent!.appName ?? "..." : Appname} is part of ${homePageContent != null ? homePageContent!.company ?? "..." : "ABBBLE CO"}.',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        'Language',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: DropdownButton<String>(
                          value: language,
                          onChanged: (newValue) {
                            language = newValue ?? "English (United Kingdom)";
                          },
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.black),
                          underline: Container(
                            height: 0,
                            color: Colors.transparent,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down_sharp,
                            color: Colors.black,
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(14.0),
                          items: <String>[
                            'English (United Kingdom)',
                            'English (United States)',
                            'Spanish',
                            'French',
                            'German',
                            'Italian',
                            'Japanese',
                            'Korean',
                            'Russian',
                            'Thai',
                            'Turkish',
                            'Vietnamese',
                            'Arabic',
                            'Bengali',
                            'Bulgarian',
                            'Catalan',
                            'Chinese',
                            'Croatian',
                            'Czech',
                            'Danish',
                            'Dutch',
                            'English (Australia)',
                            'Filipino',
                            'Finnish',
                            'Greek',
                            'Hindi',
                            'Hungarian',
                            'Indonesian',
                            'Malay',
                            'Norwegian',
                            'Persian',
                            'Portuguese',
                            'Romanian',
                            'Swedish',
                            'Thai',
                            'Turkish',
                            'Ukrainian',
                            'Vietnamese',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Text(
                        'Follow us',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          // Icons widgets for social media (e.g., Facebook, Twitter)

                          InkWell(
                            onTap: () async {
                              // launch url
                              await launchUrl(Uri.parse(
                                  'https://fb.com/${homePageContent != null ? homePageContent!.facebookUrl ?? "..." : "https://fb.com/"}'));
                            },
                            child: Column(
                              children: [
                                const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(FontAwesome.facebook,
                                        color: Colors.white)),
                                Text(
                                  "Facebook",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              // launch url
                              await launchUrl(Uri.parse(
                                  'https://instagram.com/${homePageContent != null ? homePageContent!.instagramUrl ?? "..." : "https://instagram.com/"}'));
                            },
                            child: Column(
                              children: [
                                const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(FontAwesome.instagram,
                                        color: Colors.white)),
                                Text(
                                  "Instagram",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              // launch url
                              await launchUrl(Uri.parse(
                                  'https://x.com/${homePageContent != null ? homePageContent!.twitterUrl ?? "..." : "https://x.com/"}'));
                            },
                            child: Column(
                              children: [
                                const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(FontAwesome.twitter,
                                        color: Colors.white)),
                                Text(
                                  "X",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              // launch url
                              await launchUrl(Uri.parse(
                                  'https://linkedin.com/${homePageContent != null ? homePageContent!.linkedinUrl ?? "..." : "https://linkedin.com"}'));
                            },
                            child: Column(
                              children: [
                                const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(FontAwesome.linkedin,
                                        color: Colors.white)),
                                Text(
                                  "LinkedIn",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                if (Responsive.isDesktop(context))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 100,
                              height: 100,
                              child: CachedNetworkImage(
                                imageUrl: homePageContent != null
                                    ? homePageContent!.appIcon ??
                                        placeholderImage
                                    : placeholderImage,
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 130,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      await launchUrl(Uri.parse(
                                          homePageContent != null
                                              ? homePageContent!.googleUrl ??
                                                  "https://play.google.com/"
                                              : "https://play.google.com/"));
                                    },
                                    child: SizedBox(
                                        width: 120,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "https://i.ibb.co/5KcZqzj/android-download.png",
                                          fit: BoxFit.contain,
                                        ))),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                    onTap: () async {
                                      await launchUrl(Uri.parse(
                                          homePageContent != null
                                              ? homePageContent!.appleUrl ??
                                                  "https://apps.apple.com/us/"
                                              : "https://apps.apple.com/us/"));
                                    },
                                    child: SizedBox(
                                        width: 120,
                                        height: 50,
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              "https://i.ibb.co/SvWwKj8/ios-download.png",
                                          fit: BoxFit.contain,
                                        ))),
                                // InkWell(
                                //     onTap: () async {
                                //       await launchUrl(
                                //           Uri.parse(
                                //           homePageContent != null
                                //               ? homePageContent!.linkedinUrl ?? "..."
                                //               : "..."));
                                //     },
                                //     child: SizedBox(
                                //         width: 120,
                                //         height: 50,
                                //         child: Image.asset(
                                //           'assets/icons/appgallery-badge.webp',
                                //         ))),
                                const SizedBox(height: 10),
                                const Text(
                                  'Apple and the Apple Logo are trademarks of Apple Inc.\n'
                                  'Google Play and the Google Play logo are trademarks of Google LLC.\n',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (!Responsive.isDesktop(context)) const SizedBox(height: 10),
          if (!Responsive.isDesktop(context))
            SizedBox(
              height: height * 0.12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Follow us',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: <Widget>[
                      // Icons widgets for social media (e.g., Facebook, Twitter)

                      InkWell(
                        onTap: () async {
                          // launch url
                          await launchUrl(Uri.parse(
                              'https://fb.com/${homePageContent != null ? homePageContent!.facebookUrl ?? "..." : "https://fb.com/"}'));
                        },
                        child: Column(
                          children: [
                            const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Icon(FontAwesome.facebook,
                                    color: Colors.white)),
                            Text(
                              "Facebook",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          // launch url
                          await launchUrl(Uri.parse(
                              'https://instagram.com/${homePageContent != null ? homePageContent!.instagramUrl ?? "..." : "https://instagram.com/"}'));
                        },
                        child: Column(
                          children: [
                            const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Icon(FontAwesome.instagram,
                                    color: Colors.white)),
                            Text(
                              "Instagram",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          // launch url
                          await launchUrl(Uri.parse(
                              'https://x.com/${homePageContent != null ? homePageContent!.twitterUrl ?? "..." : "https://x.com/"}'));
                        },
                        child: Column(
                          children: [
                            const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Icon(FontAwesome.twitter,
                                    color: Colors.white)),
                            Text(
                              "X",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      InkWell(
                        onTap: () async {
                          // launch url
                          await launchUrl(Uri.parse(
                              'https://linkedin.com/${homePageContent != null ? homePageContent!.linkedinUrl ?? "..." : "https://linkedin.com"}'));
                        },
                        child: Column(
                          children: [
                            const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black,
                                child: Icon(FontAwesome.linkedin,
                                    color: Colors.white)),
                            Text(
                              "LinkedIn",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(color: Colors.black),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (!Responsive.isDesktop(context)) const SizedBox(height: 10),
          if (!Responsive.isDesktop(context))
            SizedBox(
              height: height * 0.28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    'Download',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: homePageContent != null
                                ? homePageContent!.appIcon ?? placeholderImage
                                : placeholderImage,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        width: 130,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                                onTap: () async {
                                  await launchUrl(Uri.parse(
                                      homePageContent != null
                                          ? homePageContent!.googleUrl ??
                                              "https://play.google.com/"
                                          : "https://play.google.com/"));
                                },
                                child: SizedBox(
                                    width: 120,
                                    height: 50,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://i.ibb.co/5KcZqzj/android-download.png",
                                      fit: BoxFit.contain,
                                    ))),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                                onTap: () async {
                                  await launchUrl(Uri.parse(
                                      homePageContent != null
                                          ? homePageContent!.appleUrl ??
                                              "https://apps.apple.com/us/"
                                          : "https://apps.apple.com/us/"));
                                },
                                child: SizedBox(
                                    width: 120,
                                    height: 50,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://i.ibb.co/SvWwKj8/ios-download.png",
                                      fit: BoxFit.contain,
                                    ))),
                            // InkWell(
                            //     onTap: () async {
                            //       await launchUrl(
                            //           Uri.parse(
                            //           homePageContent != null
                            //               ? homePageContent!.linkedinUrl ?? "..."
                            //               : "..."));
                            //     },
                            //     child: SizedBox(
                            //         width: 120,
                            //         height: 50,
                            //         child: Image.asset(
                            //           'assets/icons/appgallery-badge.webp',
                            //         ))),
                            const SizedBox(height: 10),
                            const Text(
                              'Apple and the Apple Logo are trademarks of Apple Inc.\n'
                              'Google Play and the Google Play logo are trademarks of Google LLC.\n',
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(
            height: 20,
          ),

          Text(
            homePageContent != null
                ? homePageContent!.copyright ?? "..."
                : "Copyright © 2006 – present. Lamat. All rights reserved.",
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          // const Spacer(),
        ],
      ),
    );
  }
}
