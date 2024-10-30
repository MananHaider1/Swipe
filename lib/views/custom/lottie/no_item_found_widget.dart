import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';

class NoItemFoundWidget extends ConsumerWidget {
  final String? text;
  final bool isSmall;
  final SharedPreferences? prefs;
  final UserProfileModel? currentProfile;
  const NoItemFoundWidget(
      {super.key,
      this.text,
      this.isSmall = false,
      this.prefs,
      this.currentProfile});

  @override
  Widget build(BuildContext context, ref) {
    final userRef = ref.watch(userProfileFutureProvider);
    // final box = Hive.box(HiveConstants.hiveBox);
    // final userProfileRef =
    //     box.get(HiveConstants.currentUserProf) as UserProfileModel;
    return Container(
        color: prefs != null
            ? Teme.isDarktheme(prefs!)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor
            : Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 5,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: LottieBuilder.asset(
                    lottieSearch,
                    width: 250,
                    height: 250,
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  ),
                ),
                userRef.when(
                  data: (data) => CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      (data != null &&
                              data.profilePicture != "" &&
                              data.profilePicture != null)
                          ? data.profilePicture!
                          : "",
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  error: (error, stackTrace) => const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(loading_gif),
                  ),
                  loading: () => const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage(loading_gif),
                  ),
                ),
              ],
            ),
            Center(
              child: Text(text ?? ""),
            ),
          ],
        ));
  }
}
