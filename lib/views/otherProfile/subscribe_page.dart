import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/subscribers_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/tabs/bottom_nav_bar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends ConsumerWidget {
  final UserProfileModel user;
  final UserProfileModel myProfile;
  final SharedPreferences prefs;
  final String myPhoneNumber;
  const SubscriptionPage(
      {super.key,
      required this.user,
      required this.myProfile,
      required this.prefs,
      required this.myPhoneNumber});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      backgroundColor: Teme.isDarktheme(prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Teme.isDarktheme(prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 46,
              width: 46 * 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(myProfile.profilePicture!),
                      radius: 46 / 2,
                    ),
                  ),
                  Positioned(
                    right: 15,
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(user.profilePicture!),
                        radius: 46 / 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${user.userName}'s subscription",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "500 Diamonds monthly · Cancel anytime",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "This creator is offering the following:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOfferingItem("Subscriber badge"),
            _buildOfferingItem("Exclusive content"),
            _buildOfferingItem("Social and broadcast channels"),
            _buildOfferingItem("Ask me anything"),
            _buildOfferingItem("Shout-outs"),
            _buildOfferingItem("Product reviews"),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final subModel = SubscribersModel(
                  phoneNumber: myPhoneNumber,
                  subExpiryDate: DateTime.now()
                      .add(const Duration(days: 30))
                      .toUtc()
                      .millisecondsSinceEpoch,
                );
                EasyLoading.show();
                ref
                    .read(sendBalanceProvider(
                        {'recipientId': user.phoneNumber, 'amount': 400}))
                    .when(
                        data: (send) {
                          if (send) {
                            minusBalanceProvider(ref, 100).then((minus) async {
                              if (minus) {
                                await subToUser(
                                    subModel: subModel,
                                    phoneNumber: user.phoneNumber);
                                final oldList =
                                    await boxMain.get('subbedToList');
                                if (oldList != null) {
                                  oldList.add(user.phoneNumber);
                                  await boxMain.put(
                                    'subbedToList',
                                    oldList,
                                  );
                                } else {
                                  await boxMain.put(
                                    'subbedToList',
                                    [user.phoneNumber],
                                  );
                                }
                                EasyLoading.showSuccess(
                                    LocaleKeys.success.tr());
                              } else {
                                EasyLoading.showError(
                                    LocaleKeys.insufficientBalance.tr());
                              }
                            });
                            ref.refresh(userProfileFutureProvider).value;
                            EasyLoading.dismiss();
                            Navigator.pop(context);
                          }
                        },
                        error: (_, __) {},
                        loading: () {});
              },
              child: Text(LocaleKeys.subscribe.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 8),
            const Text(
              "By tapping Subscribe, you agree to the Subscription Terms",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.star_rounded,
              size: 8, color: AppConstants.primaryColor),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
