// ignore_for_file: unused_element

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_paypal/flutter_paypal.dart'
    if (dart.library.html) 'package:flutter_paypal/flutter_paypal_web.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';

Future<Map<dynamic, dynamic>> paypalProvider(context, ref, amount, name) async {
  // final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  // final walletsCollection = FirebaseFirestore.instance
  //     .collection(FirebaseConstants.walletsCollection);
  Map<dynamic, dynamic>? paramsFinal;
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return UsePaypal(
          sandboxMode: true,
          clientId: Paypal_ClientId,
          secretKey: Paypal_Secret,
          returnURL: ReturnUrlSuccess,
          cancelURL: ReturnUrlCancel,
          transactions: [
            {
              "amount": {
                "total": amount.toString(),
                "currency": AppConfig.currency,
                "details": {
                  "subtotal": amount.toString(),
                  "shipping": '0',
                  "shipping_discount": 0
                }
              },
              "description": "$Appname ${LocaleKeys.dymondsStore.tr()}",
              "item_list": {
                "items": [
                  {
                    "name": name,
                    "quantity": 1,
                    "price": amount.toString(),
                    "currency": AppConfig.currency
                  }
                ],
              }
            }
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            debugPrint("onSuccess: $params");
            paramsFinal = params;
            return params;
          },
          onError: (error) {
            debugPrint("onError: $error");
            EasyLoading.showError("$error");
            // Map<dynamic, dynamic> params = {};
            // return params;
            return null;
          },
          onCancel: (params) {
            debugPrint('cancelled: $params');
            paramsFinal = params;
            return params;
          });
    },
  );
  // .then((value) => {paramsFinal = value});
  // Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) => UsePaypal(
  //             sandboxMode: true,
  //             clientId: Paypal_ClientId,
  //             secretKey: Paypal_Secret,
  //             returnURL: ReturnUrlSuccess,
  //             cancelURL: ReturnUrlCancel,
  //             transactions: [
  //               {
  //                 "amount": {
  //                   "total": amount.toString(),
  //                   "currency": AppConfig.currency,
  //                   "details": {
  //                     "subtotal": amount.toString(),
  //                     "shipping": '0',
  //                     "shipping_discount": 0
  //                   }
  //                 },
  //                 "description": "$Appname ${LocaleKeys.dymondsStore.tr()}",
  //                 "item_list": {
  //                   "items": [
  //                     {
  //                       "name": name,
  //                       "quantity": 1,
  //                       "price": amount.toString(),
  //                       "currency": AppConfig.currency
  //                     }
  //                   ],
  //                 }
  //               }
  //             ],
  //             note: "Contact us for any questions on your order.",
  //             onSuccess: (Map params) async {
  //               debugPrint("onSuccess: $params");
  //               paramsFinal = params;
  //               return params;
  //             },
  //             onError: (error) {
  //               debugPrint("onError: $error");
  //               EasyLoading.showError("$error");
  //               // Map<dynamic, dynamic> params = {};
  //               // return params;
  //               return null;
  //             },
  //             onCancel: (params) {
  //               debugPrint('cancelled: $params');
  //               paramsFinal = params;
  //               return params;
  //             }))).then((value) => {paramsFinal = value});

  return paramsFinal ?? {};
}
