// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/bitmuk_payment.dart';
import 'package:lamatdating/providers/mtn_momo.dart';
import 'package:lamatdating/providers/paypal_pay.dart';
import 'package:lamatdating/providers/stripe_pay.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/paystack_payment/paystack_page.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionsPage extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final UserProfileModel user;
  final String method;
  const SubscriptionsPage(
      {super.key, required this.prefs, required this.user, required this.method});

  @override
  ConsumerState<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends ConsumerState<SubscriptionsPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _stateController = TextEditingController();

  String removeCountryCode(String phoneNumber) {
    final regex =
        RegExp(r'^\+?[\d\s]*'); // Regular expression for any country code
    final match = regex.firstMatch(phoneNumber);
    return match?.group(0) == null
        ? phoneNumber
        : phoneNumber.substring(match!.end);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Teme.isDarktheme(widget.prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: height * .05,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: CustomAppBar(
                leading: CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.5),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: AppConstants.primaryColor,
                    icon: closeIcon),
              ),
            ),
            SizedBox(
              height: height * .03,
            ),
            Center(
              child: Text(
                LocaleKeys.subscribe.tr(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: height * .02,
            ),
            Text(
              LocaleKeys.beatopprofilein.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: height * .02,
            ),
            CarouselSlider(
              options: CarouselOptions(
                height: height * .42,
                enableInfiniteScroll: false,
              ),
              items: [
                {
                  'category': LocaleKeys.cheapest.tr().toUpperCase(),
                  'title': '1 ${LocaleKeys.days.tr()}',
                  'description': dailySubCost.toString(),
                  'save': "${LocaleKeys.no.tr()} ${LocaleKeys.save.tr()}",
                  'color': Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  'product_url': ""
                },
                {
                  'category': LocaleKeys.popular.tr().toUpperCase(),
                  'title': '1 Month',
                  'description': monthlySubCost.toString(),
                  'save':
                      '${LocaleKeys.save.tr()} ${100 - ((monthlySubCost / (dailySubCost * 30) * 100)).round()}%'
                          .toUpperCase(),
                  'color': Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  'product_url': ""
                },
                {
                  'category': LocaleKeys.bestValue.tr().toUpperCase(),
                  'title': '1 Year',
                  'description': yearlySubCost.toString(),
                  'save':
                      '${LocaleKeys.save.tr()} ${100 - ((yearlySubCost / (dailySubCost * 365) * 100)).round()}%'
                          .toUpperCase(),
                  'color': Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  'product_url': ""
                },
                // Add more items here
              ].map<Widget>((Map<String, dynamic> item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: width,
                      height: height * .4,
                      margin: const EdgeInsets.all(
                          AppConstants.defaultNumericValue),
                      decoration: BoxDecoration(
                        color: item['color'],
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 10.0,
                            blurRadius: 25.0,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: height * .06,
                              decoration: BoxDecoration(
                                color:
                                    AppConstants.primaryColor.withOpacity(.1),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(
                                        AppConstants.defaultNumericValue * .95),
                                    topRight: Radius.circular(
                                        AppConstants.defaultNumericValue *
                                            .95)),
                              ),
                              child: Center(
                                child: Text(item['category'],
                                    style: const TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold)),
                              )),
                          SizedBox(
                            height: height * .02,
                          ),
                          Text(item['title'],
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: height * .02,
                          ),
                          Text(item['description']),
                          SizedBox(
                            height: height * .01,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultNumericValue / 2,
                                horizontal: AppConstants.defaultNumericValue),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue * 2),
                            ),
                            child: Text(item['save'],
                                style: const TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: height * .02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppConstants.defaultNumericValue),
                                child: CustomButton(
                                    onPressed: () async {
                                      final newUserProfileModel =
                                          widget.user.copyWith(
                                        isPremium: true,
                                        boostBalance: widget.user.boostBalance +
                                            FreemiumLimitation
                                                .maxMonnthlyBoostLimitPremium,
                                        premiumExpiryDate: DateTime.now()
                                            .add(Duration(
                                                days: (item['category'] ==
                                                        LocaleKeys.cheapest
                                                            .tr()
                                                            .toUpperCase())
                                                    ? 1
                                                    : (item['category'] ==
                                                            LocaleKeys.popular
                                                                .tr()
                                                                .toUpperCase())
                                                        ? 30
                                                        : 365))
                                            .microsecondsSinceEpoch,
                                      );
                                      try {
                                        if (widget.method == 'bitmuk') {
                                          Map<String, dynamic> myMap = {
                                            'ref_code':
                                                '${widget.user.phoneNumber}-DateTime.now().toString()',
                                            'currency': 'USD',
                                            'amount': (item['category'] ==
                                                    LocaleKeys.cheapest
                                                        .tr()
                                                        .toUpperCase())
                                                ? dailySubCost
                                                : (item['category'] ==
                                                        LocaleKeys.popular
                                                            .tr()
                                                            .toUpperCase())
                                                    ? monthlySubCost
                                                    : yearlySubCost,
                                            'ipn_url':
                                                '	https://webhook.site/86a5ad32-c2ac-4134-9c1a-40c55b8ee0db',
                                            'cancel_url':
                                                'http://example.com/cancel_url.php',
                                            'success_url':
                                                'http://example.com/success_url.php',
                                            'customer_email':
                                                widget.user.email ??
                                                    widget.user.phoneNumber
                                          };
                                          await bitmukPaymentRequest(myMap)
                                              .then((value) async {
                                            (value)
                                                ? {
                                                    await ref
                                                        .read(
                                                            userProfileNotifier)
                                                        .updateUserProfile(
                                                            newUserProfileModel)
                                                        .then((value) async {
                                                      EasyLoading.dismiss();
                                                      ref.invalidate(
                                                          userProfileFutureProvider);
                                                      EasyLoading.showSuccess(
                                                          LocaleKeys.success
                                                              .tr());
                                                      await Restart
                                                          .restartApp();
                                                    })
                                                  }
                                                : {
                                                    EasyLoading.showError(
                                                        LocaleKeys
                                                            .purchaseFailed
                                                            .tr())
                                                  };
                                          });
                                        }
                                        if (widget.method == 'flutterwave') {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          Checkout2Page(
                                                            user: widget.user,
                                                            price: (item['category'] ==
                                                                    LocaleKeys
                                                                        .cheapest
                                                                        .tr()
                                                                        .toUpperCase())
                                                                ? (dailySubCost *
                                                                        100)
                                                                    .round()
                                                                    .toString()
                                                                : (item['category'] ==
                                                                        LocaleKeys
                                                                            .popular
                                                                            .tr()
                                                                            .toUpperCase())
                                                                    ? (monthlySubCost *
                                                                            100)
                                                                        .round()
                                                                        .toString()
                                                                    : (yearlySubCost *
                                                                            100)
                                                                        .round()
                                                                        .toString(),
                                                            onSuccess:
                                                                () async {
                                                              await ref
                                                                  .read(
                                                                      userProfileNotifier)
                                                                  .updateUserProfile(
                                                                      newUserProfileModel)
                                                                  .then(
                                                                      (value) async {
                                                                EasyLoading
                                                                    .dismiss();
                                                                ref.invalidate(
                                                                    userProfileFutureProvider);
                                                                EasyLoading.showSuccess(
                                                                    LocaleKeys
                                                                        .success
                                                                        .tr());
                                                                await Restart
                                                                    .restartApp();
                                                              });
                                                            },
                                                          )));
                                        }
                                        if (widget.method == 'momo') {
                                          await requestToPay(ref,
                                              amount: (item['category'] ==
                                                      LocaleKeys.cheapest
                                                          .tr()
                                                          .toUpperCase())
                                                  ? (dailySubCost * 100)
                                                      .toString()
                                                  : (item['category'] ==
                                                          LocaleKeys.popular
                                                              .tr()
                                                              .toUpperCase())
                                                      ? (monthlySubCost * 100)
                                                          .toString()
                                                      : (yearlySubCost * 100)
                                                          .toString(),
                                              currency: AppConfig.currency,
                                              type: "Subscription",
                                              partyId1: removeCountryCode(
                                                  widget.user.phoneNumber));
                                        }
                                        if (widget.method == 'paypal') {
                                          await paypalProvider(
                                                  context,
                                                  ref,
                                                  (item['category'] ==
                                                          LocaleKeys.cheapest
                                                              .tr()
                                                              .toUpperCase())
                                                      ? dailySubCost * 100
                                                      : (item['category'] ==
                                                              LocaleKeys.popular
                                                                  .tr()
                                                                  .toUpperCase())
                                                          ? monthlySubCost * 100
                                                          : yearlySubCost * 100,
                                                  widget.user.phoneNumber)
                                              .then((value) async {
                                            (value['payToken'] != null)
                                                ? {
                                                    await ref
                                                        .read(
                                                            userProfileNotifier)
                                                        .updateUserProfile(
                                                            newUserProfileModel)
                                                        .then((value) async {
                                                      EasyLoading.dismiss();
                                                      ref.invalidate(
                                                          userProfileFutureProvider);
                                                      EasyLoading.showSuccess(
                                                          LocaleKeys.success
                                                              .tr());
                                                      await Restart
                                                          .restartApp();
                                                    })
                                                  }
                                                : {
                                                    EasyLoading.showError(
                                                        LocaleKeys
                                                            .purchaseFailed
                                                            .tr())
                                                  };
                                          });
                                        }
                                        if (widget.method == 'stripe') {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) => Container(
                                                  decoration: BoxDecoration(
                                                    color: Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor,
                                                    borderRadius: BorderRadius
                                                        .circular(AppConstants
                                                            .defaultNumericValue),
                                                  ),
                                                  child: Form(
                                                      key: _formKey,
                                                      child: Column(children: [
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Row(
                                                          children: [
                                                            const Spacer(),
                                                            Text(
                                                              LocaleKeys.stripe
                                                                  .tr(),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headlineSmall,
                                                            ),
                                                            const Spacer(),
                                                            IconButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              icon: const Icon(Icons
                                                                  .close_rounded),
                                                            ),
                                                            const SizedBox(
                                                                width: AppConstants
                                                                    .defaultNumericValue),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                .defaultNumericValue),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        widget
                                                                            .user
                                                                            .fullName),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                        widget
                                                                            .user
                                                                            .phoneNumber),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child: (widget.user.email !=
                                                                              null &&
                                                                          widget.user.email !=
                                                                              "")
                                                                      ? Text(widget
                                                                          .user
                                                                          .email!)
                                                                      : Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              TextFormField(
                                                                            controller:
                                                                                _emailController,
                                                                            autovalidateMode:
                                                                                AutovalidateMode.onUserInteraction,
                                                                            validator:
                                                                                (value) {
                                                                              if (value == null || value.isEmpty) {
                                                                                return 'Please enter email';
                                                                              }
                                                                              return null;
                                                                            },
                                                                            style:
                                                                                Theme.of(context).textTheme.headlineSmall,
                                                                            decoration: InputDecoration(
                                                                                hintText: 'janedoe@gmail.com',
                                                                                border: InputBorder.none,
                                                                                hintStyle: Theme.of(context).textTheme.headlineSmall),
                                                                          ),
                                                                        )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _cityController,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter city';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText: LocaleKeys
                                                                              .city
                                                                              .tr(),
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _countryController,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter country';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText: LocaleKeys
                                                                              .country
                                                                              .tr(),
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _addressController,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter address';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText: LocaleKeys
                                                                              .address
                                                                              .tr(),
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _address2Controller,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter address 2';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText:
                                                                              "${LocaleKeys.address.tr()} 2",
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _postalCodeController,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter postal code';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText: LocaleKeys
                                                                              .zipcode
                                                                              .tr(),
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(children: [
                                                            Expanded(
                                                              child: Container(
                                                                  height: 60,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColor
                                                                            .withOpacity(
                                                                                .1)
                                                                        : AppConstants
                                                                            .primaryColor
                                                                            .withOpacity(.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            AppConstants.defaultNumericValue),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          _stateController,
                                                                      autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter state';
                                                                        }
                                                                        return null;
                                                                      },
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headlineSmall,
                                                                      decoration: InputDecoration(
                                                                          hintText: LocaleKeys
                                                                              .state
                                                                              .tr(),
                                                                          border: InputBorder
                                                                              .none,
                                                                          hintStyle: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall),
                                                                    ),
                                                                  )),
                                                            ),
                                                          ]),
                                                        ),
                                                        const SizedBox(
                                                            height: AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  CustomButton(
                                                                text: LocaleKeys
                                                                    .confirm
                                                                    .tr(),
                                                                onPressed:
                                                                    () async {
                                                                  final stripePaymentHandle =
                                                                      StripePaymentHandle();
                                                                  if (_formKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    await stripePaymentHandle.stripeMakePayment(
                                                                        item['category'] == LocaleKeys.cheapest.tr().toUpperCase()
                                                                            ? (dailySubCost.round() * 100).toString()
                                                                            : (item['category'] == LocaleKeys.popular.tr().toUpperCase())
                                                                                ? (monthlySubCost.round() * 100).toString()
                                                                                : (yearlySubCost.round() * 100).toString(),
                                                                        AppConfig.currency,
                                                                        widget.user.fullName,
                                                                        _emailController.text,
                                                                        widget.user.phoneNumber,
                                                                        _cityController.text,
                                                                        _countryController.text,
                                                                        _addressController.text,
                                                                        _address2Controller.text,
                                                                        _postalCodeController.text,
                                                                        _stateController.text, () async {
                                                                      await ref
                                                                          .read(
                                                                              userProfileNotifier)
                                                                          .updateUserProfile(
                                                                              newUserProfileModel)
                                                                          .then(
                                                                              (value) async {
                                                                        EasyLoading
                                                                            .dismiss();
                                                                        ref.invalidate(
                                                                            userProfileFutureProvider);
                                                                        EasyLoading.showSuccess(LocaleKeys
                                                                            .success
                                                                            .tr());
                                                                        await Restart
                                                                            .restartApp();
                                                                      });
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ]))));

                                          await stripeProvider(
                                                  ref,
                                                  (item['category'] ==
                                                          LocaleKeys.cheapest
                                                              .tr()
                                                              .toUpperCase())
                                                      ? dailySubCost
                                                              .toDouble() *
                                                          100
                                                      : (item['category'] ==
                                                              LocaleKeys.popular
                                                                  .tr()
                                                                  .toUpperCase())
                                                          ? monthlySubCost
                                                                  .toDouble() *
                                                              100
                                                          : yearlySubCost
                                                                  .toDouble() *
                                                              100,
                                                  widget.user.phoneNumber,
                                                  item['product_url'])
                                              .then((value) async {
                                            EasyLoading.dismiss();
                                            (value)
                                                ? {
                                                    await ref
                                                        .read(
                                                            userProfileNotifier)
                                                        .updateUserProfile(
                                                            newUserProfileModel)
                                                        .then((value) async {
                                                      EasyLoading.dismiss();
                                                      ref.invalidate(
                                                          userProfileFutureProvider);
                                                      EasyLoading.showSuccess(
                                                          LocaleKeys.success
                                                              .tr());
                                                      await Restart
                                                          .restartApp();
                                                    })
                                                  }
                                                : {
                                                    EasyLoading.showError(
                                                        LocaleKeys
                                                            .purchaseFailed
                                                            .tr())
                                                  };
                                          });
                                        }
                                        if (widget.method == 'paystack') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CheckoutPage(
                                                      onSuccess: () async {
                                                        EasyLoading.dismiss();

                                                        await ref
                                                            .read(
                                                                userProfileNotifier)
                                                            .updateUserProfile(
                                                                newUserProfileModel)
                                                            .then(
                                                                (value) async {
                                                          EasyLoading.dismiss();
                                                          ref.invalidate(
                                                              userProfileFutureProvider);
                                                          EasyLoading
                                                              .showSuccess(
                                                                  LocaleKeys
                                                                      .success
                                                                      .tr());
                                                          await Restart
                                                              .restartApp();
                                                        });
                                                      },
                                                      price: (item[
                                                                  'category'] ==
                                                              LocaleKeys
                                                                  .cheapest
                                                                  .tr()
                                                                  .toUpperCase())
                                                          ? (dailySubCost * 100)
                                                              .round()
                                                          : (item['category'] ==
                                                                  LocaleKeys
                                                                      .popular
                                                                      .tr()
                                                                      .toUpperCase())
                                                              ? (monthlySubCost *
                                                                      100)
                                                                  .round()
                                                              : (yearlySubCost *
                                                                      100)
                                                                  .round(),
                                                    )),
                                          );
                                        }
                                      } catch (e) {
                                        EasyLoading
                                            .dismiss(); // Hide loading indicator
                                        if (kDebugMode) {
                                          showERRORSheet(context, e.toString());
                                        }
                                      }

                                      EasyLoading.dismiss();
                                    },
                                    text: LocaleKeys.select.tr().toUpperCase()),
                              )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                Container(
                  height: 1,
                  width: width / 2.5,
                  color: Colors.grey,
                ),
                Text(
                  LocaleKeys.or.tr(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Container(
                  height: 1,
                  width: width / 2.5,
                  color: Colors.grey,
                ),
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
              ],
            ),
            Container(
              width: width,
              height: height * .2,
              margin: const EdgeInsets.all(AppConstants.defaultNumericValue),
              decoration: BoxDecoration(
                color: Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor,
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultNumericValue),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 10.0,
                    blurRadius: 25.0,
                    offset: const Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: height * .06,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(.1),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                                AppConstants.defaultNumericValue * .95),
                            topRight: Radius.circular(
                                AppConstants.defaultNumericValue * .95)),
                      ),
                      child: Center(
                        child: Text(
                            '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                            style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold)),
                      )),
                  SizedBox(
                    height: height * .02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppRes.appLogo != null
                          ? Image.network(
                              AppRes.appLogo!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              AppConstants.logo,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                      Text(
                        LocaleKeys.getgold.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SubscriptionBuilder(builder: (context, isPremiumUser) {
                        return isPremiumUser
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppConstants.defaultNumericValue),
                                child: OutlinedButton(
                                  onPressed: () {
                                    // SubscriptionBuilder.showSubscriptionBottomSheet(context: context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                              borderRadius: BorderRadius
                                                  .circular(AppConstants
                                                      .defaultNumericValue)),
                                          height: height * .6,
                                          width: width * .8,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: width * .05,
                                              vertical: height * .1),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Center(
                                                  child: Text(
                                                LocaleKeys.upgradetoGold.tr(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 22,
                                                    color: Color(0xFFE9A238)),
                                              )),
                                              Center(
                                                child: AppRes.appLogo != null
                                                    ? Image.network(
                                                        AppRes.appLogo!,
                                                        width: 120,
                                                        height: 120,
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image.asset(
                                                        AppConstants.logo,
                                                        color: AppConstants
                                                            .primaryColor,
                                                        width: 150,
                                                        height: 150,
                                                        fit: BoxFit.contain,
                                                      ),
                                              ),
                                              Center(
                                                  child: Text(
                                                '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              )),
                                              Center(
                                                  child: Text(
                                                LocaleKeys
                                                    .andallthefeaturesofGold
                                                    .tr(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                ),
                                              )),
                                              Container(
                                                width: width,
                                                height: 1,
                                                color: const Color(0xFFE9A238),
                                              ),
                                              SubscriptionBuilder(builder:
                                                  (context, isPremiumUser) {
                                                return isPremiumUser
                                                    ? const SizedBox()
                                                    : Row(
                                                        children: [
                                                          Expanded(
                                                              child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                  child:
                                                                      CustomButton(
                                                                    text: LocaleKeys
                                                                        .continu
                                                                        .tr(),
                                                                    onPressed:
                                                                        () {
                                                                      SubscriptionBuilder.showSubscriptionBottomSheet(
                                                                          context:
                                                                              context);
                                                                    },
                                                                  )))
                                                        ],
                                                      );
                                              }),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Center(
                                                    child: Text(
                                                  LocaleKeys.noThanks
                                                      .tr()
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.grey),
                                                )),
                                              )
                                            ],
                                          )),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 1, color: Colors.grey),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue *
                                                2),
                                      )),
                                  child: Text(
                                    LocaleKeys.select.tr().toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ));
                      }),
                    ],
                  ),
                  SizedBox(
                    height: height * .02,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
