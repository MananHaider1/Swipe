// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/utils/theme_management.dart';
// import 'package:lamatdating/helpers/api_service.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/my_loading/costumview/common_ui.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';
import 'package:flutter/material.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final int reportType;
  final String? id;

  const ReportScreen(this.reportType, this.id, {super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? currentValue;
  String reason = '';
  String description = '';
  String contactInfo = '';

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return Scaffold(
      body: Container(
        color: Teme.isDarktheme(prefs!) == true
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        padding: const EdgeInsets.only(top: 40),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Center(
                      child: Text(
                        AppRes.whatReport(widget.reportType),
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10, left: 10),
                          child: Icon(
                            Icons.close_rounded,
                            color: Teme.isDarktheme(prefs) == true
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 0.2,
                  color: AppConstants.textColorLight,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.selectReason.tr(),
                        style: const TextStyle(
                            fontSize: 15, fontFamily: fNSfUiMedium),
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding:
                            const EdgeInsets.only(right: 15, left: 15, top: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: DropdownButton<String>(
                          value: currentValue,
                          underline: Container(),
                          isExpanded: true,
                          elevation: 16,
                          style: const TextStyle(
                            color: AppConstants.textColorLight,
                          ),
                          dropdownColor: Teme.isDarktheme(prefs) == true
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor,
                          onChanged: (String? newValue) {
                            currentValue = newValue;
                            setState(() {});
                          },
                          items: reportReasons
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style:
                                    const TextStyle(fontFamily: fNSfUiMedium),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Text(
                        LocaleKeys.howItHurtsYou.tr(),
                        style: const TextStyle(
                          fontFamily: fNSfUiMedium,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding:
                            const EdgeInsets.only(right: 15, left: 15, top: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            hintText: LocaleKeys.explainBriefly.tr(),
                            hintStyle: const TextStyle(
                              color: AppConstants.textColorLight,
                            ),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontFamily: fNSfUiMedium),
                          onChanged: (value) {
                            description = value;
                          },
                          maxLines: 7,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                      ),
                      Text(
                        LocaleKeys.contactDetailMailOrMobile.tr(),
                        style: const TextStyle(
                            fontSize: 15, fontFamily: fNSfUiMedium),
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding:
                            const EdgeInsets.only(right: 15, left: 15, top: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            hintText: LocaleKeys.mailOrPhone.tr(),
                            hintStyle: const TextStyle(
                              color: AppConstants.textColorLight,
                            ),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            contactInfo = value;
                          },
                          style: const TextStyle(
                              color: Colors.white, fontFamily: fNSfUiMedium),
                          maxLines: 1,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: 175,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              if (currentValue == null ||
                                  currentValue!.isEmpty) {
                                CommonUI.showToast(
                                    msg: LocaleKeys.pleaseSelectReason.tr());
                                return;
                              }
                              if (description.isEmpty) {
                                CommonUI.showToast(
                                    msg:
                                        LocaleKeys.pleaseEnterDescription.tr());
                                return;
                              }
                              if (contactInfo.isEmpty) {
                                CommonUI.showToast(
                                    msg: LocaleKeys.pleaseEnterContactDetail
                                        .tr());
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (context) => const LoaderDialog(),
                              );
                              // ApiService()
                              //     .reportUserOrPost(
                              //   widget.reportType == 1 ? "2" : "1",
                              //   widget.id,
                              //   currentValue,
                              //   description,
                              //   contactInfo,
                              // )
                              //     .then((value) {
                              //   if (kDebugMode) {
                              //     print(value.status);
                              //   }
                              //   Navigator.pop(context);
                              //   Navigator.pop(context);
                              // });
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                AppConstants.primaryColor,
                              ),
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              LocaleKeys.submit.tr().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: fNSfUiSemiBold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Text(
                          LocaleKeys
                              .byClickingThisSubmitButtonyouAgreeThatnyouAreTakingAll
                              .tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppConstants.textColorLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebViewScreen(3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            LocaleKeys.policyCenter.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
