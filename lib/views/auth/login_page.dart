// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, unused_local_variable, deprecated_member_use

import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/my_loading/my_loading.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/models/country_code.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/country_codes_provider.dart';
import 'package:lamatdating/providers/get_current_location_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/auth/login_with_phone_page.dart';
import 'package:lamatdating/views/auth/select_country_page.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/languages_screen/languages_screen.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? title;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  const LoginPage(
      {super.key,
      this.title,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.doc,
      required this.isblocknewlogins});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  SessionManager sessionManager = SessionManager();
  TextEditingController emailController = TextEditingController();

  bool isOpenHomeDialog = false;

  @override
  void initState() {
    super.initState();
    setStatusBarColorLoginPage(widget.prefs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.prefs.getBool('privacyDialogOpen') == false ||
          widget.prefs.getBool('privacyDialogOpen') == null) {
        if (isOpenHomeDialog == false) {
          homeScreenDialog();
        }
      } else {
        AppRes.countryCodesData = ref.watch(countryCodesProvider).value;
        AppRes.currentLocationProviderProvider ??=
            ref.watch(getCurrentLocationProviderProvider).value;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final myUserProvider = ref.read(authProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(!Teme.isDarktheme(widget.prefs)
                      ? AppConstants.splashBg
                      : AppConstants.splashBgDark),
                  fit: BoxFit.cover)),
          // decoration: const BoxDecoration(color: AppConstants.primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top / 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  //---- Dark mode/light mode switch----
                  if (IsShowLightDarkModeSwitchInLoginScreen == true &&
                      IsHIDELightDarkModeSwitchInApp != true)
                    IconButton(
                      onPressed: () {
                        final themeChange =
                            ref.read(darkThemeProvider.notifier);

                        themeChange.darkTheme = !Teme.isDarktheme(widget.prefs);
                        setState(() {});
                        Future.delayed(const Duration(milliseconds: 500), () {
                          setStatusBarColorLoginPage(widget.prefs);
                        });
                      },
                      icon: Icon(
                        Teme.isDarktheme(widget.prefs)
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        color: AppConstants.backgroundColor,
                      ),
                    ),
                  LangaugeSwitcher(
                      color: AppConstants.backgroundColor,
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return WillPopScope(
                                  onWillPop: () async {
                                    return false;
                                  },
                                  child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 10, sigmaY: 10),
                                      child: Dialog(
                                          insetPadding: EdgeInsets.symmetric(
                                              horizontal: width * .08),
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                              height: kIsWeb
                                                  ? Responsive.isMobile(context)
                                                      ? height * .8
                                                      : height * .8
                                                  : height * .8,
                                              width: kIsWeb
                                                  ? Responsive.isMobile(context)
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
                                              child: LanguagesScreen(
                                                prefs: widget.prefs,
                                              )))));
                            });
                      },
                      icon: translateSvg)
                ],
              ),
              const Spacer(),

              //Logo Image
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: AppRes.appLogo != null
                        ? Image.network(
                            AppRes.appLogo!,
                            // color: Colors.white,
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            icLogo,
                            // color: Colors.white,
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const Spacer(),
                ],
              ),

              const Spacer(),

              //Terms Text Section
              Center(
                  child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: LocaleKeys.byTappingLogin.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    TextSpan(
                      text: "${LocaleKeys.terms.tr()}.",
                      style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(2),
                            ),
                          );
                        },
                    ),
                    TextSpan(
                      text: "\n${LocaleKeys.learnHowWeProcess.tr()}",
                      style: const TextStyle(
                          height: 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    TextSpan(
                      text: "\n${LocaleKeys.privacyPolicy.tr()}",
                      style: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(3),
                            ),
                          );
                        },
                    ),
                    TextSpan(
                      text: " ${LocaleKeys.and.tr()} ",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                    TextSpan(
                      text: "${LocaleKeys.cookiesPolicy.tr()}.",
                      style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                          decoration: TextDecoration.underline,
                          decorationThickness: 2.0,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(3),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              )),
              const SizedBox(
                height: AppConstants.defaultNumericValue,
              ),

              // Login with Apple
              Visibility(
                visible: kIsWeb ? false : Platform.isIOS,
                child: LoginButton(
                  prefs: widget.prefs,
                  icon: WebsafeSvg.asset(
                    appleLogoSvg,
                    width: AppConstants.defaultNumericValue * 1.5,
                    colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                  ),
                  onPressed: () async {
                    EasyLoading.show(status: LocaleKeys.login.tr());
                    await myUserProvider.signInWithApple(
                        scopes: [Scope.email, Scope.fullName]).then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneLoginLandingWidget(
                            phoneNumber: "",
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
                    });
                    EasyLoading.showSuccess(LocaleKeys.youNeedVerifyPhone.tr());
                    EasyLoading.dismiss();
                  },
                  text: LocaleKeys.singInWithApple.tr(),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),

              //Login with Phone
              if (isPhoneAuthAvailable)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb
                          ? Responsive.isMobile(context)
                              ? 0
                              : width / 3
                          : 0),
                  child: LoginButton(
                    prefs: widget.prefs,
                    icon: WebsafeSvg.asset(
                      phoneLogoSvg,
                      width: AppConstants.defaultNumericValue * 1.5,
                      colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhoneLoginLandingWidget(
                            phoneNumber: "",
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
                    text: LocaleKeys.loginWithPhone.tr(),
                  ),
                ),
              if (isPhoneAuthAvailable)
                const SizedBox(height: AppConstants.defaultNumericValue),

              // Login with Google
              if (isGoogleAuthAvailable)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: kIsWeb
                          ? Responsive.isMobile(context)
                              ? 0
                              : width / 3
                          : 0),
                  child: LoginButton(
                    prefs: widget.prefs,
                    icon: WebsafeSvg.asset(
                      googleLogoSvg,
                      width: AppConstants.defaultNumericValue * 1.5,
                       colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                    ),
                    onPressed: () async {
                      EasyLoading.show(status: LocaleKeys.loginWithGoogle.tr());
                      await myUserProvider.signInWithGoogle().then((value) => {
                            if (value != null)
                              {
                                EasyLoading.dismiss(),
                                (value.phoneNumber != null &&
                                        value.phoneNumber != "")
                                    ? {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const LandingWidget(),
                                          ),
                                        )
                                      }
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhoneLoginLandingWidget(
                                            phoneNumber: "",
                                            user: value,
                                            isVerifying: true,
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
                                      )
                              }
                            else
                              {
                                EasyLoading.showError(
                                    LocaleKeys.failedlogin.tr()),
                              }
                          });
                      EasyLoading.dismiss();
                    },
                    text: LocaleKeys.loginWithGoogle.tr(),
                  ),
                ),
              if (isGoogleAuthAvailable)
                const SizedBox(height: AppConstants.defaultNumericValue),

              //Login with Facebook
              // if (isFacebookAuthAvailable)
              //   LoginButton(
              //     prefs: widget.prefs,
              //     icon: WebsafeSvg.asset(
              //       facebookLogoSvg,
              //       width: AppConstants.defaultNumericValue * 1.6,
              //       color: AppConstants.primaryColor,
              //     ),
              //     onPressed: () async {
              //       EasyLoading.show(status: 'Logging in...');
              //       await ref.read(authProvider).signInWithFacebook();
              //       EasyLoading.dismiss();
              //     },
              //     text: "Log in with facebook",
              //   ),
              // if (isFacebookAuthAvailable)
              //   const SizedBox(height: AppConstants.defaultNumericValue),

              // //Login with Password
              // if (isEmailLoginAvailable)
              //   LoginButton(
              //     prefs: widget.prefs,
              //     icon: WebsafeSvg.asset(
              //       emailLogoSvg,
              //       width: AppConstants.defaultNumericValue * 1.5,
              //       color: AppConstants.primaryColor,
              //     ),
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => const SignInScreen(),
              //           ));
              //     },
              //     text: LocaleKeys.contWithEmail,
              //   ),
              // if (isEmailLoginAvailable)
              //   const SizedBox(height: AppConstants.defaultNumericValue),

              //Register with email
              // if (isEmailLoginAvailable)
              //   LoginButton(
              //     prefs: widget.prefs,
              //     icon: WebsafeSvg.asset(
              //       emailLogoSvg,
              //       width: AppConstants.defaultNumericValue * 1.5,
              //       color: AppConstants.primaryColor,
              //     ),
              //     onPressed: () {
              //       Navigator.push(context, MaterialPageRoute(
              //         builder: (context) {
              //           return const SignUpScreen();
              //         },
              //       ));
              //     },
              //     text: LocaleKeys.regWithEmail,
              //   ),
              // if (isEmailLoginAvailable)
              //   const SizedBox(height: AppConstants.defaultNumericValue),

              //Reset Email Login Password
              // if (isEmailLoginAvailable)
              //   TextButton(
              //     onPressed: () {
              //       emailController.clear();

              //       showModalBottomSheet(
              //           context: context,
              //           isScrollControlled: true,
              //           shape: const RoundedRectangleBorder(
              //             borderRadius: BorderRadius.only(
              //               topLeft: Radius.circular(20),
              //               topRight: Radius.circular(20),
              //             ),
              //           ),
              //           builder: (BuildContext context) {
              //             return Padding(
              //               padding: EdgeInsets.only(
              //                   bottom:
              //                       MediaQuery.of(context).viewInsets.bottom),
              //               child: SingleChildScrollView(
              //                 child: Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: <Widget>[
              //                     Padding(
              //                       padding: const EdgeInsets.all(16),
              //                       child: Row(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.center,
              //                           children: [
              //                             const SizedBox(
              //                               width: 24,
              //                             ),
              //                             const Expanded(
              //                                 child: Text('Reset Password',
              //                                     textAlign: TextAlign.center,
              //                                     style: TextStyle(
              //                                         fontSize: 24,
              //                                         fontWeight:
              //                                             FontWeight.bold))),
              //                             InkWell(
              //                               onTap: () {
              //                                 Navigator.pop(context);
              //                               },
              //                               child: const Icon(
              //                                 Icons.close_rounded,
              //                                 color: AppConstants.textColorLight,
              //                               ),
              //                             )
              //                           ]),
              //                     ),
              //                     const Divider(),
              //                     const SizedBox(height: 16),
              //                     Padding(
              //                         padding: const EdgeInsets.all(16),
              //                         child: TextField(
              //                           controller: emailController,
              //                           textAlign: TextAlign.center,
              //                           decoration: const InputDecoration(
              //                             fillColor: Colors.black12,
              //                             filled: true,
              //                             border: OutlineInputBorder(
              //                               borderRadius: BorderRadius.all(
              //                                   Radius.circular(30.0)),
              //                               borderSide: BorderSide.none,
              //                             ),
              //                             hintText: 'Enter your email',
              //                           ),
              //                         )),
              //                     const SizedBox(
              //                       height:
              //                           AppConstants.defaultNumericValue * 2,
              //                     ),
              //                     SizedBox(
              //                       width: width,
              //                       child: Padding(
              //                           padding: const EdgeInsets.symmetric(
              //                               horizontal: AppConstants
              //                                   .defaultNumericValue),
              //                           child: CustomButton(
              //                             prefs: widget.prefs,
              //                             onPressed: onResetBtnClick,
              //                             text: 'Send reset link',
              //                           )),
              //                     ),
              //                     const SizedBox(
              //                       height: AppConstants.defaultNumericValue,
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             );
              //           });
              //     },
              //     child: Text(
              //       LocaleKeys.troubleSignIn,
              //       style: const TextStyle(
              //           color: Colors.white, fontWeight: FontWeight.normal),
              //     ),
              //   ),
              // if (isEmailLoginAvailable)
              //   const SizedBox(height: AppConstants.defaultNumericValue),
              const SizedBox(height: AppConstants.defaultNumericValue),
            ],
          ),
        ),
      ),
    );
  }

  void onResetBtnClick() async {
    EasyLoading.show(
        status: "${LocaleKeys.reset.tr()} ${LocaleKeys.password.tr()}...");
    final String email = emailController.text;
    final myUserProvider = ref.read(authProvider);
    await myUserProvider.passwordReset(email);
    Navigator.pop(context);
    emailController.clear();
  }

  void exitApp() async {
    // SystemNavigator.pop();
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text(
            'Are you sure you want to reject T&Cs and exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocaleKeys.no.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LocaleKeys.yes.tr()),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Call exit(0) only if user confirms
      exit(0);
    }
  }

  Future<void> homeScreenDialog() async {
    isOpenHomeDialog = true;
    final myLoading = ref.watch(myLoadingProvider);
    final observer = ref.watch(observerProvider);
    await Future.delayed(Duration.zero);
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    myLoading.getIsHomeDialogOpen || isDemo
        ? showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Dialog(
                    insetPadding: EdgeInsets.symmetric(horizontal: width * .08),
                    backgroundColor: Colors.transparent,
                    child: Container(
                      height: kIsWeb
                          ? Responsive.isMobile(context)
                              ? height * .5
                              : height * .5
                          : height * .5,
                      width: kIsWeb
                          ? Responsive.isMobile(context)
                              ? width * .8
                              : width * .5
                          : width * .8,
                      decoration: BoxDecoration(
                        color: Teme.isDarktheme(widget.prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          const Spacer(),
                          Image.asset(
                            AppConstants.symbol,
                            color: AppConstants.primaryColor,
                            width: 90,
                            height: 90,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: AppConstants.defaultNumericValue,
                                right: AppConstants.defaultNumericValue),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      gradient: const LinearGradient(
                                        // Set your glow color gradient
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          AppConstants.primaryColor,
                                          AppConstants.midColor,
                                          AppConstants.secondaryColor
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
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              LocaleKeys
                                  .pleaseCheckThesePrivacyPolicyAndTermsOfUseBefore
                                  .tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                color: Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.textColor
                                    : AppConstants.textColorLight,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              LocaleKeys.locationpermissionsaredenied.tr() +
                                  Appname,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                color: Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.textColor
                                    : AppConstants.textColorLight,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(LocaleKeys.tnc.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.primaryColor,
                                          )

                                      // const TextStyle(
                                      //   fontWeight: FontWeight.bold,
                                      //   fontSize: 12,
                                      // ),
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
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WebViewScreen(3),
                                      ));
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(LocaleKeys.privacyPolicy.tr(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.primaryColor,
                                          )),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  onTap: () {
                                    widget.prefs
                                        .setBool('privacyDialogOpen', true);
                                    // myLoading.setIsHomeDialogOpen(false);
                                    Navigator.pop(context);
                                    (AppRes.countryCodesData == null &&
                                            AppRes.currentLocationProviderProvider ==
                                                null)
                                        ? {
                                            AppRes.countryCodesData = ref
                                                .watch(countryCodesProvider)
                                                .value,
                                            AppRes.currentLocationProviderProvider ??= ref
                                                .watch(
                                                    getCurrentLocationProviderProvider)
                                                .value
                                          }
                                        : {};
                                  },
                                  child: Container(
                                    height: 55,
                                    decoration: const BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: Text(
                                        LocaleKeys.accept.tr(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Expanded(
                              //   child: InkWell(
                              //     focusColor: Colors.transparent,
                              //     hoverColor: Colors.transparent,
                              //     highlightColor: Colors.transparent,
                              //     overlayColor: MaterialStateProperty.all(
                              //         Colors.transparent),
                              //     onTap: () {
                              //       widget.prefs
                              //           .setBool('privacyDialogOpen', false);
                              //       Navigator.pop(context);
                              //     },
                              //     child: Container(
                              //       height: 55,
                              //       decoration: const BoxDecoration(
                              //         color: AppConstants.secondaryColor,
                              //         borderRadius: BorderRadius.only(
                              //             // bottomLeft: Radius.circular(20),
                              //             bottomRight: Radius.circular(20)),
                              //       ),
                              //       child: Center(
                              //         child: Text(
                              //           LocaleKeys.rjt.tr(),
                              //           style: const TextStyle(
                              //             fontSize: 14,
                              //             fontWeight: FontWeight.bold,
                              //             decoration: TextDecoration.none,
                              //             color: Colors.white,
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            barrierDismissible: false)
        : const SizedBox();
  }
}

class PhoneLoginLandingWidget extends ConsumerStatefulWidget {
  final String? title;
  final User? user;
  final bool? isVerifying;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final String? phoneNumber;
  const PhoneLoginLandingWidget(
      {super.key,
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
  _PhoneLoginLandingWidgetState createState() =>
      _PhoneLoginLandingWidgetState();
}

class _PhoneLoginLandingWidgetState
    extends ConsumerState<PhoneLoginLandingWidget> {
  List<CountryCode>? countryCodes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (AppRes.countryCodesData != null &&
          AppRes.currentLocationProviderProvider != null) {
        countryCodes = AppRes.countryCodesData!
            .where((element) => AppRes
                .currentLocationProviderProvider!.addressText
                .contains(element.name))
            .toList();
      }
    });
  }

  Future<List<CountryCode>?> fetchDataAndProcess() async {
    (AppRes.countryCodesData == null &&
            AppRes.currentLocationProviderProvider == null)
        ? {
            AppRes.countryCodesData = ref.watch(countryCodesProvider).value,
            AppRes.currentLocationProviderProvider ??=
                ref.watch(getCurrentLocationProviderProvider).value
          }
        : {};
    // delay by 5 seconds
    if (AppRes.currentLocationProviderProvider == null) {
      await Future.delayed(const Duration(seconds: 3));
    }
    (AppRes.countryCodesData != null &&
            AppRes.currentLocationProviderProvider != null)
        ? {
            countryCodes = AppRes.countryCodesData!
                .where((element) => AppRes
                    .currentLocationProviderProvider!.addressText
                    .contains(element.name))
                .toList(),
          }
        : {};
    return countryCodes;
  }

  @override
  Widget build(BuildContext context) {
    return (countryCodes != [] && countryCodes != null)
        ? LoginWithPhoneNumberPage(
            phoneNumber: widget.phoneNumber,
            user: widget.user,
            isVerifying: widget.isVerifying ?? false,
            prefs: widget.prefs,
            accountApprovalMessage: widget.accountApprovalMessage,
            isaccountapprovalbyadminneeded:
                widget.isaccountapprovalbyadminneeded,
            isblocknewlogins: widget.isblocknewlogins,
            title: widget.title,
            doc: widget.doc,
            countryCode: countryCodes!.first)
        : FutureBuilder<void>(
            future: fetchDataAndProcess(),
            builder: (context, innerSnapshot) {
              if (innerSnapshot.connectionState == ConnectionState.done) {
                // Data fetched and processed, display your widget
                return (countryCodes == null || countryCodes == [])
                    ? SelectCountryPage(
                        phoneNumber: widget.phoneNumber,
                        user: widget.user,
                        isVerifying: widget.isVerifying ?? false,
                        prefs: widget.prefs,
                        accountApprovalMessage: widget.accountApprovalMessage,
                        isaccountapprovalbyadminneeded:
                            widget.isaccountapprovalbyadminneeded,
                        isblocknewlogins: widget.isblocknewlogins,
                        title: widget.title,
                        doc: widget.doc,
                      )
                    : LoginWithPhoneNumberPage(
                        phoneNumber: widget.phoneNumber,
                        user: widget.user,
                        isVerifying: widget.isVerifying ?? false,
                        prefs: widget.prefs,
                        accountApprovalMessage: widget.accountApprovalMessage,
                        isaccountapprovalbyadminneeded:
                            widget.isaccountapprovalbyadminneeded,
                        isblocknewlogins: widget.isblocknewlogins,
                        title: widget.title,
                        doc: widget.doc,
                        countryCode: countryCodes!.first);
              } else {
                return const LoadingPage();
              }
            },
          );

    // } : {
    //   return SelectCountryPage(
    //     phoneNumber: widget.phoneNumber,
    //     isVerifying: widget.isVerifying ?? false,
    //     prefs: widget.prefs,
    //     accountApprovalMessage: widget.accountApprovalMessage,
    //     isaccountapprovalbyadminneeded:
    //         widget.isaccountapprovalbyadminneeded,
    //     isblocknewlogins: widget.isblocknewlogins,
    //     title: widget.title,
    //     doc: widget.doc,
    //   );
    // }
    // },
    // error: (_, e) {
    //   return const ErrorPage();
    // },
    // loading: () => const LoadingPage());
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String text;
  final SharedPreferences prefs;
  const LoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButtonLogin(
      prefs: prefs,
      onPressed: onPressed,
      isWhite: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          icon,
          const SizedBox(width: AppConstants.defaultNumericValue),
          Text(
            text.toUpperCase(),
            textAlign: TextAlign.start,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
          ),
          const SizedBox(width: AppConstants.defaultNumericValue),
        ],
      ),
    );
  }
}

class LangaugeSwitcher extends StatelessWidget {
  final VoidCallback? onPressed;
  final String icon;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? backgroundColor;

  const LangaugeSwitcher({
    super.key,
    required this.onPressed,
    required this.icon,
    this.padding,
    this.margin,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        splashColor: color?.withOpacity(0.3) ?? Colors.black38,
        onTap: onPressed,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultNumericValue),
            color: backgroundColor ??
                color?.withOpacity(0.1) ??
                Colors.black.withOpacity(0.07),
          ),
          child: WebsafeSvg.asset(
            icon,
             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
            height: 32,
            width: 32,
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
    );
  }
}
