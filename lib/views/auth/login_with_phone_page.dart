// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/country_code.dart';
import 'package:lamatdating/views/auth/otp_page.dart';
import 'package:lamatdating/views/auth/select_country_page.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWithPhoneNumberPage extends ConsumerStatefulWidget {
  final String? title;
  final User? user;
  final bool isVerifying;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final CountryCode countryCode;
  final String? phoneNumber;
  const LoginWithPhoneNumberPage({
    super.key,
    this.title,
    this.user,
    required this.isVerifying,
    required this.isaccountapprovalbyadminneeded,
    required this.accountApprovalMessage,
    required this.prefs,
    required this.doc,
    required this.isblocknewlogins,
    required this.countryCode,
    required this.phoneNumber,
  });

  @override
  ConsumerState<LoginWithPhoneNumberPage> createState() =>
      _LoginWithPhoneNumberPageState();
}

class _LoginWithPhoneNumberPageState
    extends ConsumerState<LoginWithPhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  late CountryCode _countryCode;

  @override
  void initState() {
    _countryCode = widget.countryCode;
    setStatusBarColor(widget.prefs);
    _phoneController.text = widget.phoneNumber ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.defaultNumericValue),
                Padding(
                  padding: const EdgeInsets.symmetric(
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
                      text: !kIsWeb
                          ? widget.isVerifying
                              ? LocaleKeys.verifyPhone.tr()
                              : LocaleKeys.login.tr()
                          : "",
                    )),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue * 3),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultNumericValue * 2),
                  child: Row(
                    mainAxisAlignment: kIsWeb
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: [
                      CustomHeadLine(
                        // prefs: widget.prefs,
                        text: LocaleKeys.myPhoneNumber.tr(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: kIsWeb
                            ? Responsive.isMobile(context)
                                ? AppConstants.defaultNumericValue
                                : width / 3
                            : AppConstants.defaultNumericValue),
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return LocaleKeys.phoneNumberReq.tr();
                        }
                        return null;
                      },
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          letterSpacing: 5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppConstants.primaryColor.withOpacity(.1),
                        border: OutlineInputBorder(
                          // Set outline border
                          borderRadius: BorderRadius.circular(
                              AppConstants.defaultNumericValue),
                          borderSide: BorderSide.none,
                        ),
                        hintText: "XXXXXXX",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: AppConstants.defaultNumericValue),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectCountryPage(
                                          isVerifying: widget.isVerifying,
                                          prefs: widget.prefs,
                                          accountApprovalMessage:
                                              widget.accountApprovalMessage,
                                          isaccountapprovalbyadminneeded: widget
                                              .isaccountapprovalbyadminneeded,
                                          isblocknewlogins:
                                              widget.isblocknewlogins,
                                          title: widget.title,
                                          doc: widget.doc,
                                          phoneNumber: widget.phoneNumber,
                                        )),
                              );
                            },
                            child:
                                // Image.asset(
                                //   "assets/flags/${getFormattedCountryCode(_countryCode).toLowerCase()}.png",
                                //   width: 25,
                                //   height: 25,
                                //   fit: BoxFit.fitWidth,
                                // ),

                                Text(
                              getFormattedCountryCode(_countryCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                            ),
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    )),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue),
                    child: Row(
                      mainAxisAlignment: kIsWeb
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Text('weWillSendYouACode'.tr()),
                      ],
                    )),
              ],
            )),
          ),
          bottomNavigationBar: SafeArea(
              child: Padding(
                  padding: !kIsWeb
                      ? const EdgeInsets.all(AppConstants.defaultNumericValue)
                      : EdgeInsets.only(
                          right: AppConstants.defaultNumericValue,
                          bottom: AppConstants.defaultNumericValue * 2,
                          left: width * .7),
                  child: CustomButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OtpPage(
                                        user: widget.user,
                                        countryCode: _countryCode.dialCode,
                                        phoneNumber: _countryCode.dialCode +
                                            _phoneController.text,
                                        prefs: widget.prefs,
                                        accountApprovalMessage:
                                            widget.accountApprovalMessage,
                                        isaccountapprovalbyadminneeded: widget
                                            .isaccountapprovalbyadminneeded,
                                        isblocknewlogins:
                                            widget.isblocknewlogins,
                                        title: widget.title,
                                        doc: widget.doc,
                                        rawPhoneNum: _phoneController.text,
                                        isVerifying: widget.isVerifying,
                                      )));
                        }
                      },
                      prefs: widget.prefs,
                      text: 'next'.tr())))),
    );
  }
}

String getFormattedCountryCode(CountryCode country) {
  return country.dialCode.trim();
}
