import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../constants.dart';

class MyBannerAd extends StatefulWidget {
  const MyBannerAd({super.key});

  @override
  State<MyBannerAd> createState() => _MyBannerAdState();
}

class _MyBannerAdState extends State<MyBannerAd> {
  late BannerAd myBanner;
  bool isLoaded = false;

  @override
  void initState() {
    BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (ad) {
        setState(() {
          isLoaded = true;
        });
      },
    );
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId:
            Platform.isAndroid ? AndroidAdUnits.bannerId : IOSAdUnits.bannerId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: bannerAdListener,
      );

      if (isAdmobAvailable) {
        myBanner.load();
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? Container(
            alignment: Alignment.center,
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
            child: AdWidget(ad: myBanner),
          )
        : const SizedBox();
  }
}
