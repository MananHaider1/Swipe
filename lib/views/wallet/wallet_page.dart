// ignore_for_file: unused_result

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/app_settings_model.dart';

import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';
import 'package:lamatdating/views/wallet/live_rewards.dart';
import 'package:lamatdating/views/wallet/my_card.dart';
import 'package:lamatdating/views/wallet/send_balance_page.dart';
import 'package:lamatdating/views/wallet/transactions.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // double width = MediaQuery.of(context).size.width;
    final prefss = ref.watch(sharedPreferences).value;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Teme.isDarktheme(prefss!)
          ? Brightness.light
          : Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Teme.isDarktheme(prefss)
          ? Brightness.light
          : Brightness.dark, // For iOS (dark icons)
    ));

    final walletAsyncValue = ref.watch(walletsStreamProvider);

    return Scaffold(
      body: walletAsyncValue.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            ref.read(createNewWalletProvider);
            ref.refresh(walletsStreamProvider);
            return const Center(child: CircularProgressIndicator());
          } else {
            final wallet = WalletsModel.fromMap(
                snapshot.docs.first.data() as Map<String, dynamic>);
            AppRes.walletBalance = wallet.balance;
            final transactions = wallet.transactions;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.defaultNumericValue),
                Padding(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultNumericValue,
                    right: AppConstants.defaultNumericValue,
                    top: MediaQuery.of(context).padding.top,
                  ),
                  child: CustomAppBar(
                    leading: Row(children: [
                      CustomIconButton(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 1.8),
                          onPressed: () {
                            (!Responsive.isDesktop(context))
                                ? Navigator.pop(context)
                                : ref.invalidate(arrangementProviderExtend);
                          },
                          color: AppConstants.primaryColor,
                          icon: leftArrowSvg),
                    ]),
                    title: Center(
                        child: CustomHeadLine(
                      text: LocaleKeys.wallet.tr(),
                    )),
                    // trailing: CustomIconButton(
                    //   icon: ellipsisIcon,
                    //   onPressed: () {},
                    // ),
                  ),
                ),
                const CreditCard(),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const SizedBox(width: AppConstants.defaultNumericValue * 2),
                  Text(LocaleKeys.services.tr(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const SizedBox(width: AppConstants.defaultNumericValue),
                  Expanded(
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllTransactionsPage(
                                transactions: transactions!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                            // width: width * 0.44,
                            padding: const EdgeInsets.only(
                              top: AppConstants.defaultNumericValue,
                              bottom: AppConstants.defaultNumericValue,
                              left: AppConstants.defaultNumericValue,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WebsafeSvg.asset(
                                    transactionsIcon,
                                  colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  Text(LocaleKeys.transactions.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.white,
                                      ))
                                ]))),
                  ),
                  const SizedBox(width: AppConstants.defaultNumericValue),
                  Expanded(
                    child: InkWell(
                        onTap: () {
                          !Responsive.isDesktop(context)
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyCardPage(),
                                  ),
                                )
                              : {
                                  ref
                                      .read(arrangementProviderExtend.notifier)
                                      .setArrangement(MyCardPage())
                                };
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => MyCardPage(),
                          //   ),
                          // );
                        },
                        child: Container(
                            // width: width * 0.44,
                            padding: const EdgeInsets.only(
                              top: AppConstants.defaultNumericValue,
                              bottom: AppConstants.defaultNumericValue,
                              left: AppConstants.defaultNumericValue,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppConstants.secondaryColor.withOpacity(.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue),
                            ),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WebsafeSvg.asset(
                                    transactionsIcon,
                                  colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(
                                      height:
                                          AppConstants.defaultNumericValue / 2),
                                  Text(LocaleKeys.myCard.tr(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.white,
                                      ))
                                ]))),
                  ),
                  const SizedBox(width: AppConstants.defaultNumericValue),
                ]),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const SizedBox(width: AppConstants.defaultNumericValue),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SendBalancePage(),
                          ),
                        );
                      },
                      child: Container(
                          // width: width * 0.44,
                          padding: const EdgeInsets.only(
                            top: AppConstants.defaultNumericValue,
                            bottom: AppConstants.defaultNumericValue,
                            left: AppConstants.defaultNumericValue,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.midColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                WebsafeSvg.asset(
                                  transactionsIcon,
                                colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.midColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(
                                    height:
                                        AppConstants.defaultNumericValue / 2),
                                Text(LocaleKeys.sendDymonds.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.white,
                                    ))
                              ])),
                    ),
                  ),
                  const SizedBox(width: AppConstants.defaultNumericValue),
                ]),
              ],
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
            child: Text(
          LocaleKeys.errorOccured.tr(),
        )),
      ),
    );
  }
}

class CreditCard extends ConsumerStatefulWidget {
  const CreditCard({super.key});

  @override
  CreditCardState createState() => CreditCardState();
}

class CreditCardState extends ConsumerState<CreditCard> {
  // String balance = '0.00 ';
  String hiddenBalance = '********';
  bool isHidden = false;
  String currency = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    final walletAsyncValue = ref.watch(walletsStreamProvider).value!.docs;
    final appSettingsRef = ref.watch(appSettingsProvider).value;
    final AppSettingsModel appSettings = appSettingsRef!;
    final wallet = WalletsModel.fromMap(
        walletAsyncValue.first.data() as Map<String, dynamic>);
    AppRes.walletBalance = wallet.balance;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 260,
        width: 380,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 14.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GifView.asset(
                          coinsIcon,
                          height: 30,
                          width: 30,
                          frameRate: 60, // default is 15 FPS
                        ),
                        const SizedBox(
                          width: AppConstants.defaultNumericValue / 2,
                        ),
                        Text(
                            isHidden
                                ? hiddenBalance
                                : wallet.balance.toStringAsFixed(0),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                            )),
                        const Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                          },
                          child: WebsafeSvg.asset(
                              height: 36,
                              width: 36,
                              fit: BoxFit.fitHeight,
                              isHidden ? unhidenIcon : hidenIcon,
                             colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),),
                        ),
                      ],
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => const DialogCoinsPlan(),
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: SizedBox(
                          // width: width * 0.3,
                          child: Row(children: [
                        Text(LocaleKeys.getDymonds.tr(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        const Expanded(child: SizedBox()),
                        WebsafeSvg.asset(
                          height: 36,
                          width: 36,
                          fit: BoxFit.fitHeight,
                          rightArrowIcon,
                         colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                        )
                      ])),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: AppConstants.hintColor,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LiveRewardsPage(),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LocaleKeys.liveRewards.tr(),
                              style: const TextStyle(
                                fontSize: 26.0,
                                color: Color(0xff66646d),
                                fontWeight: FontWeight.w600,
                              )),
                          const Expanded(child: SizedBox()),
                          WebsafeSvg.asset(
                            height: 36,
                            width: 36,
                            fit: BoxFit.fitHeight,
                            rightArrowIcon,
                           colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Text(appSettings.currency ?? '',
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Text(
                                ((wallet.balance
                                           ) *
                                        appSettings.coinValue!)
                                    .toStringAsFixed(2),
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
