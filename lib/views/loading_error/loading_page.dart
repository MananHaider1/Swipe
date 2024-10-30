import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:lamatdating/constants.dart';
// import 'package:websafe_svg/websafe_svg.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              AppRes.appLogo != null
                  ? Image.network(
                      AppRes.appLogo!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      AppConstants.logo,
                      color: AppConstants.primaryColor,
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
              const Spacer(),
              Lottie.asset(loadingDiam,
                  fit: BoxFit.cover, width: 60, height: 60, repeat: true),
              const SizedBox(height: AppConstants.defaultNumericValue * 2),
            ],
          )),
        ),
      ),
    );
  }
}
