import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/modal/plan/coin_plans.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/wallet/item_coin_plan.dart';

class DialogCoinsPlan extends ConsumerStatefulWidget {
  const DialogCoinsPlan({super.key});

  @override
  ConsumerState<DialogCoinsPlan> createState() => _DialogCoinsPlanState();
}

class _DialogCoinsPlanState extends ConsumerState<DialogCoinsPlan> {
  List<CoinPlanData>? plans = [];
  int coinAmount = 0;

  @override
  void initState() {
    getCoinPlanList().then((value) {
      plans = value.data;
      setState(() {});
    });
    const MethodChannel(ConstRes.lamatCamera)
        .setMethodCallHandler((payload) async {
      if (kDebugMode) {
        print(payload.arguments);
      }
      if (payload.method == 'is_success_purchase' &&
          (payload.arguments as bool)) {
        if (kDebugMode) {
          print(coinAmount);
        }
        ref.read(addBalanceProvider(coinAmount.toDouble()));

        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
      return;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferences).value;
    return Container(
      height: 450,
      decoration: BoxDecoration(
        color: Teme.isDarktheme(prefs!)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            height: 55,
            decoration: BoxDecoration(
                gradient: AppConstants.premiumGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.dymondsStore.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 20, bottom: 25),
              children: List.generate(
                plans!.length,
                (index) => ItemCoinPlan(
                  plans![index],
                  (coinAmount) {
                    this.coinAmount = coinAmount;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
