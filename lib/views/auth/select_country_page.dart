import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/country_codes_provider.dart';
import 'package:lamatdating/views/auth/login_with_phone_page.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectCountryPage extends ConsumerStatefulWidget {
  final String? title;
  final User? user;
  final bool isVerifying;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final String? phoneNumber;
  const SelectCountryPage({
    super.key,
    this.title,
    this.user,
    required this.isaccountapprovalbyadminneeded,
    required this.accountApprovalMessage,
    required this.prefs,
    required this.doc,
    required this.isblocknewlogins,
    required this.isVerifying,
    required this.phoneNumber,
  });

  @override
  ConsumerState<SelectCountryPage> createState() => _SelectCountryPageState();
}

class _SelectCountryPageState extends ConsumerState<SelectCountryPage> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final countryCodesData = ref.watch(countryCodesProvider);
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
        body: countryCodesData.when(
          data: (data) {
            final filteredData = data
                .where((e) => e.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();

            return Column(
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
                      text: 'selectCountry'.tr(),
                    )),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                  height: 0.3,
                  color: AppConstants.hintColor,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                  // padding: const EdgeInsets.all(
                  //     AppConstants.defaultNumericValue / 3),
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultNumericValue),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultNumericValue,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        hintText: 'searchCountry'.tr(),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(top: 12),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: WebsafeSvg.asset(
                            searchIcon,
                            width: 26,
                            height: 26,
                            colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue * 1.5),
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.defaultNumericValue),
                      margin: const EdgeInsets.only(
                          left: AppConstants.defaultNumericValue,
                          right: AppConstants.defaultNumericValue,
                          bottom: AppConstants.defaultNumericValue),
                      width: MediaQuery.of(context).size.width * .8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        color: Teme.isDarktheme(widget.prefs) == true
                            ? AppConstants.backgroundColor.withOpacity(.1)
                            : AppConstants.backgroundColorDark.withOpacity(.1),
                      ),
                      child: Scrollbar(
                        radius: const Radius.circular(
                            AppConstants.defaultNumericValue),
                        child: ListView(
                          children: filteredData
                              .map((e) => ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LoginWithPhoneNumberPage(
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
                                            countryCode: e,
                                            phoneNumber: widget.phoneNumber,
                                          ),
                                        ),
                                      );
                                    },
                                    title: Text(e.name),
                                    trailing: Text(getFormattedCountryCode(e)),
                                  ))
                              .toList(),
                        ),
                      )),
                ),
              ],
            );
          },
          error: (_, __) => Center(child: Text('error'.tr())),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
        ),
      ),
    );
  }
}
