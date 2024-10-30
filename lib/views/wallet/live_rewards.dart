// ignore_for_file: unused_result

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/bank_card_model.dart';

import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/models/withdrawal_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

class LiveRewardsPage extends ConsumerStatefulWidget {
  const LiveRewardsPage({super.key});

  @override
  ConsumerState<LiveRewardsPage> createState() => _LiveRewardsPageState();
}

class _LiveRewardsPageState extends ConsumerState<LiveRewardsPage> {
  TextEditingController amountController = TextEditingController();
  bool isWithdrawing = false;
  MyWithdrawalCard? myCard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final myWithdrawalCardRef = ref.watch(getMyWithdrawalCard).value;
      if (myWithdrawalCardRef != null) {
        myCard = myWithdrawalCardRef;
      } else {
        // showBottomSheet(
        //     context: context,
        //     builder: (context) {
        //       return const Column(children: [
        //         SizedBox(height: 10),
        //         CustomHeadLine(
        //           text: 'No card found',
        //         ),
        //         SizedBox(height: 10),
        //         Text(
        //           'Please add a card to your wallet to start earning rewards.',
        //           style: TextStyle(
        //             fontSize: 14,
        //           ),
        //         ),
        //         SizedBox(height: 10),
        //       ]);
        //     });
      }

      Future.delayed(const Duration(seconds: 2), () {
        EasyLoading.dismiss();
      });
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final prefss = ref.watch(sharedPreferences).value;
    final appSettingsRef = ref.watch(appSettingsProvider).value;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Teme.isDarktheme(prefss!)
          ? Brightness.light
          : Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Teme.isDarktheme(prefss)
          ? Brightness.light
          : Brightness.dark, // For iOS (dark icons)
    ));
    // final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final walletAsyncValue = ref.watch(walletsStreamProvider);

    void onWithdraw() {
      if (myCard == null) {
      } else {
        EasyLoading.show(status: LocaleKeys.loading.tr());
        final phone = ref.watch(currentUserStateProvider)!.phoneNumber;
        final id = phone! + DateTime.now().millisecondsSinceEpoch.toString();
        final currentTime = DateTime.now();
        final withdrawalModel = WithrawalModel(
          id: id,
          amount: double.parse(amountController.text),
          status: "pending",
          createdAt: currentTime,
          phoneNumber: phone,
          accountNumber: myCard!.accountNumber ?? 0,
          bankName: myCard!.bankName ?? "",
          accountName: myCard!.accountName ?? "",
          address: myCard!.address ?? "",
          city: myCard!.city ?? "",
          state: myCard!.state ?? "",
          zipCode: myCard!.zipCode ?? "",
          country: myCard!.country ?? "",
          paypalEmail: myCard!.paypalEmail ?? "",
        );

        (prefss.getInt('lastWithdrawal') != null &&
                (prefss.getInt('lastWithdrawal')! -
                        currentTime.millisecondsSinceEpoch) >
                    86400000)
            ? prefss.setDouble('todayWithdrawal', 0.00)
            : {};

        (double.parse(amountController.text) <=
                ((appSettingsRef!.dailyWithdrawalLimit)!.toDouble() -
                    (prefss.getDouble('todayWithdrawal') ?? 0.00)))
            ? minusBalanceProvider(
                    ref,
                    double.parse(amountController.text) /
                        (appSettingsRef.coinValue)!.toDouble())
                .then((value) => {
                      if (value)
                        {
                          addWithdrawal(withdrawalModel).then((value) => {
                                if (value)
                                  {
                                    EasyLoading.showSuccess(
                                        LocaleKeys.success.tr()),
                                    prefss.setDouble('todayWithdrawal',
                                        double.parse(amountController.text)),
                                    prefss.setInt('lastWithdrawal',
                                        DateTime.now().millisecondsSinceEpoch),
                                    Navigator.pop(context)
                                  }
                                else
                                  {
                                    addBalanceProvider(
                                        double.parse(amountController.text) /
                                            (appSettingsRef.coinValue)!
                                                .toDouble()),
                                    EasyLoading.showError(
                                        LocaleKeys.errorOccured.tr()),
                                    Navigator.pop(context)
                                  }
                              }),
                        }
                      else
                        {
                          EasyLoading.showError(LocaleKeys.errorOccured.tr()),
                          Navigator.pop(context)
                        }
                    })
            : EasyLoading.showError(LocaleKeys.reachedDailyWithdrawalLim.tr());
      }
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Wallet'),
      // ),
      body: walletAsyncValue.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            ref.read(createNewWalletProvider);
            ref.refresh(walletsStreamProvider);
            return const Center(child: CircularProgressIndicator());
          } else {
            final wallet = WalletsModel.fromMap(
                snapshot.docs.first.data() as Map<String, dynamic>);
            return SingleChildScrollView(
              child: Column(
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
                            onPressed: () => Navigator.pop(context),
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
                  const SizedBox(height: AppConstants.defaultNumericValue * 2),
                  Center(
                    child: Text(
                      LocaleKeys.balance.tr(),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GifView.asset(
                        coinsIcon,
                        height: 20,
                        width: 20,
                        frameRate: 60, // default is 15 FPS
                      ),
                      const SizedBox(
                        width: AppConstants.defaultNumericValue / 2,
                      ),
                      Center(
                        child: Text(
                          wallet.balance.toStringAsFixed(6),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "~ ${appSettingsRef!.currency ?? ''}  ${(wallet.balance * appSettingsRef.coinValue!.toDouble()).toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Center(
                  //       child: Text(
                  //         "${LocaleKeys.accumulatedDymonds.tr()} ",
                  //         style:
                  //             const TextStyle(fontSize: 15, color: Colors.grey),
                  //       ),
                  //     ),
                  //     Center(
                  //       child: GifView.asset(
                  //         coinsIcon,
                  //         height: 20,
                  //         width: 20,
                  //         frameRate: 60, // default is 15 FPS
                  //       ),
                  //     ),
                  //     const SizedBox(
                  //       width: AppConstants.defaultNumericValue / 4,
                  //     ),
                  //     // Center(
                  //     //   child: Text(
                  //     //     ((wallet.earningsTotal +
                  //     //             wallet.rewardsTotal +
                  //     //             wallet.giftsTotal))
                  //     //         .toStringAsFixed(2),
                  //     //     style:
                  //     //         const TextStyle(fontSize: 15, color: Colors.grey),
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                  const SizedBox(
                      height: AppConstants.defaultNumericValue * 1.5),
                  Center(
                      child: CustomButton(
                          onPressed: () {
                            (wallet.balance >
                                    appSettingsRef.minWithdrawal!.toDouble())
                                ? {
                                    setState(() {
                                      isWithdrawing = true;
                                    })
                                  }
                                : EasyLoading.showError(
                                    LocaleKeys.insufficientBalance.tr());
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.34,
                            ),
                            child: Text(
                              LocaleKeys.withdraw.tr(),
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ))),
                  const SizedBox(height: AppConstants.defaultNumericValue),
                  Center(
                      child: Text(
                    "${LocaleKeys.withdrawlimit.tr()}: ${appSettingsRef.currency ?? ''} ${appSettingsRef.dailyWithdrawalLimit}",
                  )),
                  (isWithdrawing)
                      ? const SizedBox(height: AppConstants.defaultNumericValue)
                      : const SizedBox(),
                  (isWithdrawing)
                      ? Padding(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue),
                          child: Container(
                              width: width * 0.9,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.defaultNumericValue,
                                  vertical: AppConstants.defaultNumericValue),
                              decoration: BoxDecoration(
                                color:
                                    AppConstants.primaryColor.withOpacity(.1),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.defaultNumericValue),
                              ),
                              child: Column(children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: AppConstants
                                                    .defaultNumericValue /
                                                2),
                                        child: Text(
                                          LocaleKeys.amount.tr(),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: amountController,
                                          autofocus: false,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return LocaleKeys
                                                  .pleaseenterwdwamount
                                                  .tr();
                                            }
                                            return null;
                                          },
                                          // textCapitalization: TextCapitalization.words,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: AppConstants.primaryColor
                                                .withOpacity(.1),
                                            hintText: "1000",
                                            border: OutlineInputBorder(
                                              // Set outline border
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppConstants
                                                          .defaultNumericValue),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                const SizedBox(
                                  height: AppConstants.defaultNumericValue,
                                ),
                                Center(
                                    child: CustomButton(
                                  onPressed: () {
                                    if (amountController.text.isEmpty) {
                                      EasyLoading.showError(
                                          LocaleKeys.pleaseenterwdwamount.tr());
                                    } else {
                                      onWithdraw();
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.28,
                                    ),
                                    child: Text(LocaleKeys.confirm.tr(),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ))
                              ])),
                        )
                      : const SizedBox(),
                  const SizedBox(height: AppConstants.defaultNumericValue * 2),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    const SizedBox(width: AppConstants.defaultNumericValue),
                    Text(LocaleKeys.dymondsBreakdown.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ))
                  ]),
                  ListTile(
                      title: Text(LocaleKeys.liveRewards.tr()),
                      subtitle: Text(wallet.rewardsTotal.toStringAsFixed(6)),
                      trailing: TextButton(
                        onPressed: () {
                          wallet.rewardsTotal > 0.000001
                              ? {
                                  ref.read(
                                      addBalanceProvider(wallet.rewardsTotal)),
                                  ref.read(
                                      minusRewardProvider(wallet.rewardsTotal)),
                                  ref.read(addRewardProvider(0.0000000001)),
                                }
                              : {
                                  EasyLoading.showError(
                                      LocaleKeys.insrewardsforred.tr())
                                };
                        },
                        child: Text(LocaleKeys.redeem.tr()),
                      )),
                  ListTile(
                      title: Text(LocaleKeys.earnings.tr()),
                      subtitle: Text(wallet.earningsTotal.toStringAsFixed(6)),
                      trailing: TextButton(
                        onPressed: () {
                          wallet.earningsTotal > 0.000001
                              ? {
                                  ref.read(
                                      addBalanceProvider(wallet.earningsTotal)),
                                  ref.read(minusEarningProvider(
                                      wallet.earningsTotal)),
                                  ref.read(addEarningProvider(0.0000000001)),
                                }
                              : {
                                  EasyLoading.showError(
                                      LocaleKeys.insearningsforred.tr())
                                };
                        },
                        child: Text(LocaleKeys.redeem.tr()),
                      )),
                  ListTile(
                      title: Text(LocaleKeys.gifts.tr()),
                      subtitle: Text(wallet.giftsTotal.toStringAsFixed(6)),
                      trailing: TextButton(
                        onPressed: () {
                          wallet.giftsTotal > 0.000001
                              ? {
                                  ref.read(
                                      addBalanceProvider(wallet.giftsTotal)),
                                  ref.read(
                                      minusGiftProvider(wallet.giftsTotal)),
                                  ref.read(addGiftProvider(0.0000000001)),
                                }
                              : {
                                  EasyLoading.showError(
                                      LocaleKeys.insgiftsforred.tr())
                                };
                        },
                        child: Text(LocaleKeys.redeem.tr()),
                      )),
                ],
              ),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(LocaleKeys.errorOccured.tr())),
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
  bool isHidden = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final walletAsyncValue = ref.watch(walletsStreamProvider).value!.docs;
    final wallet = WalletsModel.fromMap(
        walletAsyncValue.first.data() as Map<String, dynamic>);
    final appSettingsRef = ref.watch(appSettingsProvider).value;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 216,
        width: 380,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 18.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.6,
                          child: Row(
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
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: AppConstants.defaultNumericValue,
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
                              width: width * 0.3,
                              child: Row(children: [
                                Text(LocaleKeys.getDymonds.tr()),
                                const SizedBox(width: 10),
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
                        )
                      ],
                    ),
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
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 28.0,
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
                        InkWell(
                          onTap: () {},
                          child: WebsafeSvg.asset(
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
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(appSettingsRef!.currency ?? '',
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                              ((wallet.balance +
                                          wallet.earningsTotal +
                                          wallet.rewardsTotal +
                                          wallet.giftsTotal) /
                                      6)
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
