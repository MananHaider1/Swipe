import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:lamatdating/constants.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> initPlatformStateForPurchases(String? phoneNumber) async {
  PurchasesConfiguration configuration;
  if (!kIsWeb) {
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(SubscriptionConstants.appleApiKey);

      if (phoneNumber != null) {
        configuration.appUserID = phoneNumber;
      }

      await Purchases.configure(configuration);

      if (phoneNumber != null) {
        await Purchases.logIn(phoneNumber);
      }
    } else if (Platform.isAndroid) {
      configuration =
          PurchasesConfiguration(SubscriptionConstants.googleApiKey);

      if (phoneNumber != null) {
        configuration.appUserID = phoneNumber;
      }

      await Purchases.configure(configuration);

      if (phoneNumber != null) {
        await Purchases.logIn(phoneNumber);
      }
    }
  }
}
