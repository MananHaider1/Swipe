import 'package:flutter/material.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'package:lamatdating/constants.dart';

class MoreMenuTitle extends StatelessWidget {
  final VoidCallback onTap;

  final String title;
  final String? icon;
  const MoreMenuTitle({
    super.key,
    required this.onTap,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Row(
          children: [
            const SizedBox(
              width: AppConstants.defaultNumericValue / 2,
            ),
            WebsafeSvg.asset(
              icon ?? homeIcon,
              height: 28,
              width: 28,
              fit: BoxFit.scaleDown,
               colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue,
                  vertical: AppConstants.defaultNumericValue / 2),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.black87)),
            ),
          ],
        ));
  }
}

class ChatAddMenuItem extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  const ChatAddMenuItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultNumericValue,
            vertical: AppConstants.defaultNumericValue / 1.2),
        child: Row(
          children: [
            Icon(
              icon,
              size: Theme.of(context).textTheme.titleSmall!.fontSize,
              color: Colors.white,
            ),
            const SizedBox(width: AppConstants.defaultNumericValue),
            Expanded(
              child: Text(title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
