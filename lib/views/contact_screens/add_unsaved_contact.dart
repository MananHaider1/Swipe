import 'dart:core';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/MobileInputWithOutline/mobile_input_no_outline.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/widgets/MySimpleButton/my_simple_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddunsavedNumber extends ConsumerStatefulWidget {
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const AddunsavedNumber(
      {super.key,
      required this.currentUserNo,
      required this.model,
      required this.prefs});

  @override
  AddunsavedNumberState createState() => AddunsavedNumberState();
}

class AddunsavedNumberState extends ConsumerState<AddunsavedNumber> {
  bool? isLoading, isUser = true;
  bool istyping = true;
  BannerAd? myBanner;
  AdWidget? adWidget;
  @override
  initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.mediumRectangle,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.read(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  getUser(String searchphone) {
    // Lamat.toast(searchphone);
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .where(Dbkeys.phonenumbervariants, arrayContains: searchphone)
        .get()
        .then((user) {
      if (user.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
          istyping = false;
          isUser = true;

          if (isUser!) {
            // var peer = user;
            widget.model!.addUser(user.docs[0]);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: searchphone)));
          }
        });
      } else {
        setState(() {
          isLoading = false;
          isUser = false;
          istyping = false;
        });
      }
    }).catchError((err) {});
  }

  final _phoneNo = TextEditingController();

  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  Widget buildWidget() {
    final observer = ref.watch(observerProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 52, 17, 8),
          child: Container(
            margin: const EdgeInsets.only(top: 0),

            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            // height: 63,
            height: 63,
            // width: w / 1.18,
            child: Form(
              // key: _enterNumberFormKey,
              child: MobileInputWithOutline(
                buttonhintTextColor: AppConstants.lamatGrey,
                borderColor: AppConstants.lamatGrey.withOpacity(0.2),
                controller: _phoneNo,
                initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                onSaved: (phone) {
                  setState(() {
                    phoneCode = phone!.countryCode;
                    istyping = true;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 22, 13, 8),
          child: isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.secondaryColor)),
                )
              : MySimpleButton(
                  buttoncolor: AppConstants.primaryColor.withOpacity(0.99),
                  buttontext: 'searchuser'.tr(),
                  onpressed: () {
                    // RegExp e164 = RegExp(r'^\+[1-9]\d{1,14}$');

                    String phone = _phoneNo.text.toString().trim();
                    if ((phone.isNotEmpty
                        // &&
                        //         e164.hasMatch(phoneCode! + _phone)
                        ) &&
                        widget.currentUserNo != phoneCode! + phone) {
                      setState(() {
                        isLoading = true;
                      });

                      getUser(phoneCode! + phone);
                    } else {
                      Lamat.toast(
                        widget.currentUserNo != phoneCode! + phone
                            ? 'validnum'.tr()
                            : 'validnum'.tr(),
                      );
                    }
                  },
                ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        IsBannerAdShow == true &&
                observer.isadmobshow == true &&
                adWidget != null &&
                !kIsWeb
            ? Container(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(
                  bottom: 5.0,
                  top: 2,
                ),
                child: adWidget!)
            : const SizedBox(
                height: 0,
              ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(Scaffold(
          appBar: AppBar(
              elevation: 0.4,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              title: Text(
                'chatws'.tr(),
                style: TextStyle(
                  fontSize: 17,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              )),
          body: Stack(children: <Widget>[
            Center(
              child: !isUser!
                  ? istyping == true
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              const SizedBox(
                                height: 140,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(28.0),
                                child: Text(
                                    '${phoneCode!}-${_phoneNo.text.trim()} ${'notexist'.tr()} $Appname',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20.0)),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              myElevatedButton(
                                color: AppConstants.primaryColor,
                                child: Text(
                                  "${'inviteTo'.tr()} $Appname",
                                  style: const TextStyle(
                                      color: AppConstants.lamatWhite),
                                ),
                                onPressed: () {
                                  Lamat.invite(context, ref);
                                },
                              ),
                            ])
                  : Container(),
            ),
            // Loading
            buildWidget()
          ]),
          backgroundColor: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
        )));
  }
}
