import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lamatdating/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CommonFun {
  static void bannerAd(Function(Ad ad) ad) {
    if (!kIsWeb) {
      BannerAd(
        adUnitId: Platform.isIOS
            ? "${SettingRes.admobBannerIos}"
            : "${SettingRes.admobBanner}",
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: ad,
          onAdFailedToLoad: (ad, err) {
            // print('Failed to load a banner ad: ${err.message}');
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  static Future<void> interstitialAd(
      Function(InterstitialAd ad) onAdLoaded) async {
    if (!kIsWeb) {
      InterstitialAd.load(
        adUnitId: Platform.isIOS
            ? "${SettingRes.admobIntIos}"
            : "${SettingRes.admobInt}",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: onAdLoaded,
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('onAdFailedToLoad');
            }
          },
        ),
      );
    }
  }
}
