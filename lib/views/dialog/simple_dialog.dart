import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:lamatdating/constants.dart';

class SimpleCustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positiveText;
  final String negativeText;

  //onButtonClick 0=Negative, 1=Positive
  final Function onButtonClick;

  const SimpleCustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.negativeText,
    required this.positiveText,
    required this.onButtonClick,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
            child: Center(
              child: Container(
                height: 300,
                width: 275,
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: fNSfUiSemiBold,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Image(
                      image: AssetImage(icLogo),
                      height: 80,
                      color: Colors.black45,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: fNSfUiLight,
                            decoration: TextDecoration.none,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 55,
                      decoration: const BoxDecoration(
                        color: AppConstants.chatMyTextColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              onTap: () {
                                onButtonClick(0);
                                Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  negativeText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: fNSfUiLight,
                                    decoration: TextDecoration.none,
                                    color: AppConstants.textColorLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              onTap: () {
                                onButtonClick(1);
                              },
                              child: Center(
                                child: Text(
                                  positiveText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: fNSfUiLight,
                                    decoration: TextDecoration.none,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
