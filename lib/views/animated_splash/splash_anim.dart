import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

import 'package:lamatdating/constants.dart';

class SplashAnimPage extends StatefulWidget {
  const SplashAnimPage({super.key});

  @override
  State<SplashAnimPage> createState() => SplashAnimState();
}

class SplashAnimState extends State<SplashAnimPage> {
  Image? myImage;
  Image? myAnimImage;

  @override
  void initState() {
    myImage = Image.asset(AppConstants.splashBg);
    myAnimImage = Image.asset(AppConstants.splashAnimLight);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(myImage!.image, context);
    precacheImage(myAnimImage!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.splashBg), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              GifView.asset(
                AppConstants.splashAnimLight,
                height: 150,
                width: 200,
                frameRate: 60, // default is 15 FPS
              ),
              const Spacer(),
            ],
          )),
        ),
      ),
    );
  }
}
