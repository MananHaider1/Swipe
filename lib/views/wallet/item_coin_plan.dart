// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/bitmuk_payment.dart';
import 'package:lamatdating/providers/mtn_momo.dart';
import 'package:lamatdating/providers/paypal_pay.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/stripe_pay.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/paystack_payment/paystack_page.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/modal/plan/coin_plans.dart';

import 'package:lamatdating/constants.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

class ItemCoinPlan extends ConsumerStatefulWidget {
  final CoinPlanData plan;
  final Function purchaseCoin;

  const ItemCoinPlan(this.plan, this.purchaseCoin, {super.key});

  @override
  ConsumerState<ItemCoinPlan> createState() => _ItemCoinPlanState();
}

class _ItemCoinPlanState extends ConsumerState<ItemCoinPlan> {
  String method = "";
  Box<dynamic>? box;
  UserProfileModel? currentUserProf;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  void initState() {
    box = Hive.box(HiveConstants.hiveBox);
    final user = box!.get(HiveConstants.currentUserProf);
    currentUserProf = UserProfileModel.fromJson(user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prefss = ref.watch(sharedPreferences).value;
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Row(children: [
            const SizedBox(
              width: AppConstants.defaultNumericValue * 2.4,
            ),
            Text(
              '${widget.plan.coinPlanName}',
            )
          ]),
          Row(
            children: [
              GifView.asset(
                coinsIcon,
                height: 36,
                width: 36,
                frameRate: 60, // default is 15 FPS
              ),
              const SizedBox(
                width: AppConstants.defaultNumericValue / 2,
              ),
              Expanded(
                child: Text(
                  '${widget.plan.coinAmount}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                width: 85,
                child: CustomButton(
                  onPressed: () async {
                    // showDialog(
                    //   context: context,
                    //   builder: (context) => const LoaderDialog(),
                    // );
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Teme.isDarktheme(prefss!)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor,
                            borderRadius: BorderRadius.circular(
                                AppConstants.defaultNumericValue),
                          ),
                          child: Column(children: [
                            const SizedBox(
                                height: AppConstants.defaultNumericValue / 2),
                            Row(
                              children: [
                                const Spacer(),
                                Text(
                                  LocaleKeys.selectMethod.tr(),
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                                const SizedBox(
                                    width: AppConstants.defaultNumericValue),
                              ],
                            ),
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (!kIsWeb)
                                    TextButton(
                                      onPressed: () async {
                                        method = "in_app_purchase";
                                        EasyLoading.show(
                                            status: 'Processing...');

                                        try {
                                          // LamatCamera.inAppPurchase(
                                          //   Platform.isAndroid
                                          //       ? '${widget.plan.playstoreProductId}'
                                          //       : '${widget.plan.appstoreProductId}',
                                          // );
                                          final bool available =
                                              await InAppPurchase.instance
                                                  .isAvailable();
                                          if (available) {
                                            final ProductDetailsResponse
                                                response = Platform.isAndroid
                                                    ? await InAppPurchase
                                                        .instance
                                                        .queryProductDetails({
                                                        widget.plan
                                                            .playstoreProductId!
                                                      })
                                                    : await InAppPurchase
                                                        .instance
                                                        .queryProductDetails({
                                                        widget.plan
                                                            .appstoreProductId!
                                                      });
                                            if (response
                                                .notFoundIDs.isNotEmpty) {
                                              // Handle the error.
                                            }
                                            List<ProductDetails> products =
                                                response.productDetails;
                                            final ProductDetails
                                                productDetails = products.first;
                                            final PurchaseParam purchaseParam =
                                                PurchaseParam(
                                                    productDetails:
                                                        productDetails);
                                            final purchase = await InAppPurchase
                                                .instance
                                                .buyConsumable(
                                                    purchaseParam:
                                                        purchaseParam);
                                            if (purchase) {
                                              widget.purchaseCoin(
                                                  widget.plan.coinAmount);
                                            } else {
                                              EasyLoading.dismiss();
                                              EasyLoading.showError(LocaleKeys
                                                  .purchaseFailed
                                                  .tr());
                                            }
                                          }
                                        } catch (error) {
                                          EasyLoading
                                              .dismiss(); // Hide loading indicator
                                          if (kDebugMode) {
                                            showERRORSheet(
                                                context, error.toString());
                                          }
                                        }
                                        EasyLoading.dismiss();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppConstants.secondaryColor
                                              .withOpacity(.2),
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.network(
                                                "https://weabbble.c1.is/drive/applegoogle.png",
                                                width: 50,
                                                height: 50),
                                            const Text("Apple/Google Pay"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (paypal)
                                    TextButton(
                                      onPressed: () async {
                                        method = "paypal";

                                        await paypalProvider(
                                                context,
                                                ref,
                                                widget.plan.coinPlanPrice! *
                                                    100,
                                                currentUserProf!.phoneNumber)
                                            .then((value) async {
                                          (value['payToken'] != null)
                                              ? {
                                                  ref.read(addBalanceProvider(
                                                      widget.plan.coinAmount!
                                                          .toDouble()))
                                                }
                                              : {
                                                  EasyLoading.showError(
                                                      LocaleKeys.purchaseFailed
                                                          .tr())
                                                };
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppConstants.secondaryColor
                                              .withOpacity(.2),
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                        ),
                                        child: Column(
                                          children: [
                                            Image.network(
                                                "https://cdn.iconscout.com/icon/free/png-256/free-paypal-5-226456.png?f=webp&w=256",
                                                width: 50,
                                                height: 50),
                                            Text(LocaleKeys.paypal.tr()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (bitmuk)
                                    TextButton(
                                      onPressed: () async {
                                        method = "bitmuk";
                                        Map<String, dynamic> myMap = {
                                          'ref_code':
                                              '${currentUserProf!.phoneNumber}-DateTime.now().toString()',
                                          'currency': 'USD',
                                          'amount': widget.plan.coinAmount!
                                              .toDouble(),
                                          'ipn_url':
                                              '	https://webhook.site/86a5ad32-c2ac-4134-9c1a-40c55b8ee0db',
                                          'cancel_url':
                                              'http://example.com/cancel_url.php',
                                          'success_url':
                                              'http://example.com/success_url.php',
                                          'customer_email':
                                              currentUserProf!.email ??
                                                  currentUserProf!.phoneNumber
                                        };
                                        await bitmukPaymentRequest(myMap)
                                            .then((value) async {
                                          if (value) {
                                            ref.read(addBalanceProvider(widget
                                                .plan.coinAmount!
                                                .toDouble()));
                                            EasyLoading.showSuccess(
                                                LocaleKeys.success.tr());
                                            await Restart.restartApp();
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: AppConstants.secondaryColor
                                              .withOpacity(.2),
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CachedNetworkImage(
                                                imageUrl:
                                                    "https://weabbble.c1.is/drive/bitmuk.png",
                                                width: 50,
                                                color: Colors.blue,
                                                fit: BoxFit.contain),
                                            // Text(LocaleKeys.bitmuk.tr()),
                                          ],
                                        ),
                                      ),
                                    ),
                                ]),
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (paystack)
                                  TextButton(
                                    onPressed: () {
                                      method = "paystack";
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => CheckoutPage(
                                                  onSuccess: () async {
                                                    EasyLoading.dismiss();

                                                    ref.read(addBalanceProvider(
                                                        widget.plan.coinAmount!
                                                            .toDouble()));
                                                  },
                                                  price: (widget.plan
                                                              .coinPlanPrice! *
                                                          100)
                                                      .round(),
                                                )),
                                      );
                                    },
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: AppConstants.secondaryColor
                                            .withOpacity(.2),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    onPressed: () async {
                                      method = "stripe";
                                      showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                color: Teme.isDarktheme(prefss)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                borderRadius: BorderRadius
                                                    .circular(AppConstants
                                                        .defaultNumericValue),
                                              ),
                                              child: SingleChildScrollView(
                                                padding: const EdgeInsets.all(
                                                    AppConstants
                                                        .defaultNumericValue),
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      currentUserProf!
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Text(
                                                                      currentUserProf!
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: (currentUserProf!.email !=
                                                                            null &&
                                                                        currentUserProf!.email !=
                                                                            "")
                                                                    ? Text(currentUserProf!
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
                                                                            if (value == null ||
                                                                                value.isEmpty) {
                                                                              return 'Please enter email';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .headlineSmall,
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                                  color: Teme.isDarktheme(
                                                                          prefss)
                                                                      ? AppConstants
                                                                          .backgroundColor
                                                                          .withOpacity(
                                                                              .1)
                                                                      : AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              .1),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppConstants
                                                                              .defaultNumericValue),
                                                                ),
                                                                child: Padding(
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
                                                                          value
                                                                              .isEmpty) {
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
                                                            child: CustomButton(
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
                                                                      (widget.plan.coinPlanPrice!.round() *
                                                                              100)
                                                                          .toString(),
                                                                      AppConfig
                                                                          .currency,
                                                                      currentUserProf!
                                                                          .fullName,
                                                                      _emailController
                                                                          .text,
                                                                      currentUserProf!
                                                                          .phoneNumber,
                                                                      _cityController
                                                                          .text,
                                                                      _countryController
                                                                          .text,
                                                                      _addressController
                                                                          .text,
                                                                      _address2Controller
                                                                          .text,
                                                                      _postalCodeController
                                                                          .text,
                                                                      _stateController
                                                                          .text,
                                                                      () {
                                                                    ref.read(addBalanceProvider(widget
                                                                        .plan
                                                                        .coinAmount!
                                                                        .toDouble()));
                                                                  });
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ])),
                                              )));
                                    },
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: AppConstants.secondaryColor
                                            .withOpacity(.2),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Checkout2Page(
                                                  user: currentUserProf!,
                                                  onSuccess: () async {
                                                    EasyLoading.dismiss();

                                                    ref.read(addBalanceProvider(
                                                        widget.plan.coinAmount!
                                                            .toDouble()));
                                                  },
                                                  price: (widget.plan
                                                              .coinPlanPrice! *
                                                          100)
                                                      .round()
                                                      .toString(),
                                                )),
                                      );
                                    },
                                    child: Container(
                                      height: 100,
                                      width: 100,
                                      padding: const EdgeInsets.all(0),
                                      decoration: BoxDecoration(
                                        color: AppConstants.secondaryColor
                                            .withOpacity(.2),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.defaultNumericValue),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl:
                                                  "https://cdn.freelogovectors.net/wp-content/uploads/2022/11/flutterwave-logo-freelogovectors.net_.png",
                                              width: 50,
                                              fit: BoxFit.contain),
                                          // const Text("F-Wave"),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (momo)
                                    TextButton(
                                      onPressed: () async {
                                        method = "momo";

                                        await requestToPay(ref,
                                                amount: (widget.plan
                                                            .coinPlanPrice! *
                                                        100)
                                                    .round()
                                                    .toString(),
                                                currency: AppConfig.currency,
                                                type: "Coins",
                                                partyId1: removeCountryCode(
                                                    currentUserProf!
                                                        .phoneNumber))
                                            .then((value) {
                                          if (value == true) {
                                            ref.read(addBalanceProvider(widget
                                                .plan.coinAmount!
                                                .toDouble()));
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        padding: const EdgeInsets.all(0),
                                        decoration: BoxDecoration(
                                          color: AppConstants.secondaryColor
                                              .withOpacity(.2),
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.defaultNumericValue),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CachedNetworkImage(
                                                imageUrl:
                                                    "https://i.ibb.co/j4rvWXh/8766d22f-ba58-4e9d-87c7-024691b61972-thumb-removebg-preview.png",
                                                width: 50,
                                                fit: BoxFit.contain),
                                            // const Text("F-Wave"),
                                          ],
                                        ),
                                      ),
                                    ),
                                ]),
                            const SizedBox(
                                height: AppConstants.defaultNumericValue),
                          ])),
                    );
                  },
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(AppConstants.primaryColor),
                  // ),
                  child: Center(
                    child: Text(
                      '${widget.plan.coinPlanPrice}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Container(
            height: 0.3,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  String removeCountryCode(String phoneNumber) {
    final regex =
        RegExp(r'^\+?[\d\s]*'); // Regular expression for any country code
    final match = regex.firstMatch(phoneNumber);
    return match?.group(0) == null
        ? phoneNumber
        : phoneNumber.substring(match!.end);
  }
}
