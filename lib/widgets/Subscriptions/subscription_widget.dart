import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/subscription_builder.dart';
import 'package:lamatdating/views/subscriptions/subscriptions.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';

class SubscriptionWidget extends ConsumerStatefulWidget {
  const SubscriptionWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SubscriptionWidgetState createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends ConsumerState<SubscriptionWidget> {
  String method = "";

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferences).value;
    final UserProfileModel? user = ref.watch(userProfileFutureProvider).value;

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SubscriptionBuilder(builder: (context, isPremiumUser) {
      return Container(
          decoration: BoxDecoration(
              color: Teme.isDarktheme(prefs!)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultNumericValue)),
          height: height * .6,
          width: width * .8,
          margin: EdgeInsets.symmetric(
              horizontal: width * .05, vertical: height * .1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        color: AppConstants.primaryColor,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
              ),
              Row(children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: Colors.blueGrey,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${FreemiumLimitation.maxMonnthlyBoostLimitPremium} ${LocaleKeys.boostspermonth.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              ]),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Row(children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: Colors.blueGrey,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${LocaleKeys.superlikeupto.tr()} ${FreemiumLimitation.maxDailySuperLikeLimitPremium} ${LocaleKeys.timesperday.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              ]),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Row(children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: Colors.blueGrey,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '${LocaleKeys.rewindupto.tr()} ${FreemiumLimitation.maxDailyRewindLimitPremium} ${LocaleKeys.timesperday.tr()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              ]),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Row(children: [
                const SizedBox(
                  width: AppConstants.defaultNumericValue,
                ),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: Colors.blueGrey,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  LocaleKeys.noads.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )
              ]),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Center(
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebViewScreen(1),
                          ),
                        );
                      },
                      child: Text(
                        LocaleKeys.learnmoreabtgold.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppConstants.secondaryColor),
                      ))),
              Container(
                width: width,
                height: 1,
                color: const Color(0xFFE9A238),
              ),
              isPremiumUser || user!.isPremium!
                  ? const SizedBox()
                  : Row(
                      children: [
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        AppConstants.defaultNumericValue),
                                child: CustomButton(
                                  text: LocaleKeys.continu.tr(),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                          decoration: BoxDecoration(
                                            color: Teme.isDarktheme(prefs)
                                                ? AppConstants
                                                    .backgroundColorDark
                                                : AppConstants.backgroundColor,
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                    .defaultNumericValue),
                                          ),
                                          child: Column(children: [
                                            const SizedBox(
                                                height: AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                const Spacer(),
                                                Text(
                                                  LocaleKeys.selectMethod.tr(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: const Icon(
                                                      Icons.close_rounded),
                                                ),
                                                const SizedBox(
                                                    width: AppConstants
                                                        .defaultNumericValue),
                                              ],
                                            ),
                                            const SizedBox(
                                                height: AppConstants
                                                    .defaultNumericValue),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // const Spacer(),
                                                  if (!kIsWeb)
                                                    TextButton(
                                                      onPressed: () {
                                                        method =
                                                            "in_app_purchase";
                                                        SubscriptionBuilder
                                                            .showSubscriptionBottomSheet(
                                                                context:
                                                                    context);
                                                      },
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppConstants
                                                              .secondaryColor
                                                              .withOpacity(.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://weabbble.c1.is/drive/applegoogle.png",
                                                                width: 50,
                                                                fit: BoxFit
                                                                    .contain),
                                                            // const Text("Appstore"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (bitmuk)
                                                    TextButton(
                                                      onPressed: () {
                                                        method = "bitmuk";
                                                        showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return GestureDetector(
                                                                  onVerticalDragDown:
                                                                      (details) {},
                                                                  child: SubscriptionsPage(
                                                                      prefs:
                                                                          prefs,
                                                                      user:
                                                                          user,
                                                                      method:
                                                                          method));
                                                            });
                                                      },
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppConstants
                                                              .secondaryColor
                                                              .withOpacity(.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://weabbble.c1.is/drive/bitmuk.png",
                                                                width: 50,
                                                                color:
                                                                    Colors.blue,
                                                                fit: BoxFit
                                                                    .contain),
                                                            // Text(LocaleKeys.bitmuk.tr()),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (paypal)
                                                    TextButton(
                                                      onPressed: () {
                                                        method = "paypal";
                                                        showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return GestureDetector(
                                                                  onVerticalDragDown:
                                                                      (details) {},
                                                                  child: SubscriptionsPage(
                                                                      prefs:
                                                                          prefs,
                                                                      user:
                                                                          user,
                                                                      method:
                                                                          method));
                                                            });
                                                      },
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppConstants
                                                              .secondaryColor
                                                              .withOpacity(.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://cdn.iconscout.com/icon/free/png-256/free-paypal-5-226456.png?f=webp&w=256",
                                                                width: 50,
                                                                fit: BoxFit
                                                                    .contain),
                                                            // Text(LocaleKeys.paypal.tr()),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                  // const Spacer(),
                                                ]),
                                            const SizedBox(
                                                height: AppConstants
                                                    .defaultNumericValue),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (paystack)
                                                  TextButton(
                                                    onPressed: () {
                                                      method = "paystack";
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GestureDetector(
                                                                onVerticalDragDown:
                                                                    (details) {},
                                                                child: SubscriptionsPage(
                                                                    prefs:
                                                                        prefs,
                                                                    user: user,
                                                                    method:
                                                                        method));
                                                          });
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      decoration: BoxDecoration(
                                                        color: AppConstants
                                                            .secondaryColor
                                                            .withOpacity(.2),
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CachedNetworkImage(
                                                              imageUrl:
                                                                  "https://upload.wikimedia.org/wikipedia/commons/0/0b/Paystack_Logo.png",
                                                              width: 50),
                                                          // Text(LocaleKeys.paystack.tr()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (stripe)
                                                  TextButton(
                                                    onPressed: () {
                                                      method = "stripe";
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GestureDetector(
                                                                onVerticalDragDown:
                                                                    (details) {},
                                                                child: SubscriptionsPage(
                                                                    prefs:
                                                                        prefs,
                                                                    user: user,
                                                                    method:
                                                                        method));
                                                          });
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      decoration: BoxDecoration(
                                                        color: AppConstants
                                                            .secondaryColor
                                                            .withOpacity(.2),
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CachedNetworkImage(
                                                              imageUrl:
                                                                  "https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Stripe_Logo%2C_revised_2016.svg/2560px-Stripe_Logo%2C_revised_2016.svg.png",
                                                              width: 50),
                                                          // const Text("Stripe"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (flutterwave)
                                                  TextButton(
                                                    onPressed: () {
                                                      method = "flutterwave";
                                                      showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          builder: (BuildContext
                                                              context) {
                                                            return GestureDetector(
                                                                onVerticalDragDown:
                                                                    (details) {},
                                                                child: SubscriptionsPage(
                                                                    prefs:
                                                                        prefs,
                                                                    user: user,
                                                                    method:
                                                                        method));
                                                          });
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      decoration: BoxDecoration(
                                                        color: AppConstants
                                                            .secondaryColor
                                                            .withOpacity(.2),
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                .defaultNumericValue),
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CachedNetworkImage(
                                                              imageUrl:
                                                                  "https://cdn.freelogovectors.net/wp-content/uploads/2022/11/flutterwave-logo-freelogovectors.net_.png",
                                                              width: 50,
                                                              fit: BoxFit
                                                                  .contain),
                                                          // const Text("F-Wave"),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(
                                                height: AppConstants
                                                    .defaultNumericValue),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (momo)
                                                    TextButton(
                                                      onPressed: () {
                                                        method = "momo";
                                                        showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return GestureDetector(
                                                                  onVerticalDragDown:
                                                                      (details) {},
                                                                  child: SubscriptionsPage(
                                                                      prefs:
                                                                          prefs,
                                                                      user:
                                                                          user,
                                                                      method:
                                                                          method));
                                                            });
                                                      },
                                                      child: Container(
                                                        height: 100,
                                                        width: 100,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppConstants
                                                              .secondaryColor
                                                              .withOpacity(.2),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CachedNetworkImage(
                                                                imageUrl:
                                                                    "https://i.ibb.co/j4rvWXh/8766d22f-ba58-4e9d-87c7-024691b61972-thumb-removebg-preview.png",
                                                                width: 50,
                                                                fit: BoxFit
                                                                    .contain),
                                                            // const Text("F-Wave"),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ])
                                          ])),
                                    );
                                  },
                                )))
                      ],
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Center(
                    child: Text(
                  LocaleKeys.noThanks.tr().toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey),
                )),
              )
            ],
          ));
    });
  }
}
