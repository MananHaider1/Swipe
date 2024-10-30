// ignore_for_file: unused_result

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/app_settings_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';

// import 'package:lamatdating/helpers/constants.dart';

class GiftSheet extends ConsumerWidget {
  final Function(BuildContext context) onAddDymondsTap;
  final Function(Gifts? gifts) onGiftSend;

  const GiftSheet(
      {super.key, required this.onAddDymondsTap, required this.onGiftSend});

  @override
  Widget build(BuildContext context, ref) {
    final getGiftsRef = ref.watch(getGiftsProvider);
    final walletAsyncValue = ref.watch(walletsStreamProvider);
    final prefs = ref.watch(sharedPreferences).value;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Teme.isDarktheme(prefs!)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.defaultNumericValue),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        end: Alignment.centerRight,
                        begin: Alignment.centerLeft,
                        colors: [
                          AppConstants.secondaryColor,
                          AppConstants.primaryColor,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        WebsafeSvg.asset(
                          homeIcon,
                          height: 30,
                          fit: BoxFit.fitHeight,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        walletAsyncValue.when(
                          data: (snapshot) {
                            if (snapshot.docs.isEmpty) {
                              ref.read(createNewWalletProvider);
                              ref.refresh(walletsStreamProvider);
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              final wallet = WalletsModel.fromMap(
                                  snapshot.docs.first.data()
                                      as Map<String, dynamic>);
                              AppRes.walletBalance = wallet.balance;
                              return Text(
                                wallet.balance.toStringAsFixed(2),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 17),
                              );
                            }
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) =>
                              const Center(child: Text('An error occurred')),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => onAddDymondsTap(context),
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          end: Alignment.centerRight,
                          begin: Alignment.centerLeft,
                          colors: [
                            AppConstants.secondaryColor,
                            AppConstants.primaryColor,
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        LocaleKeys.addDiamonnds.tr(),
                        style:
                            const TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: getGiftsRef.when(
                data: (data) {
                  return GridView.builder(
                    itemCount: data!.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1 / 1.25,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      Gifts? gift = data[index];
                      return walletAsyncValue.when(
                        data: (snapshot) {
                          if (snapshot.docs.isEmpty) {
                            ref.read(createNewWalletProvider);
                            ref.refresh(walletsStreamProvider);
                            return const Center(
                                child: CircularProgressIndicator());
                          } else {
                            final wallet = WalletsModel.fromMap(
                                snapshot.docs.first.data()
                                    as Map<String, dynamic>);
                            AppRes.walletBalance = wallet.balance;
                            return InkWell(
                                onTap: () {
                                  if (gift.coinPrice!.toDouble() <
                                      wallet.balance) {
                                    onGiftSend(gift);
                                  } else {
                                    Navigator.pop(context);

                                    EasyLoading.showError(
                                        LocaleKeys.insufficientDiamonds.tr());
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        (gift.coinPrice ?? 0) < (wallet.balance)
                                            ? AppConstants.primaryColor
                                                .withOpacity(0.1)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.defaultNumericValue),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          gift.image!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          WebsafeSvg.asset(
                                            homeIcon,
                                           colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                            height: 17,
                                            fit: BoxFit.fitHeight,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Flexible(
                                            child: Text(
                                              ((gift.coinPrice)!.toDouble() -
                                                      .01)
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontFamily: fNSfUiLight),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ));
                          }
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
