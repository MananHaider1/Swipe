import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/helpers/date_formater.dart';
import 'package:lamatdating/main.dart';
// import 'package:lamatdating/models/banned_user_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/banned_users_provider.dart';
import 'package:lamatdating/views/custom/custom_button.dart';

class UserIsBannedPage extends ConsumerWidget {
  const UserIsBannedPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final isMeBanned = ref.watch(isMeBannedProvider);
    final prefs = ref.watch(sharedPreferencesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.banned.tr()),
      ),
      body: isMeBanned.when(
          data: (bannedUserModel) {
            if (bannedUserModel != null) {
              final int daysOfBan =
                  bannedUserModel.bannedUntil.difference(DateTime.now()).inDays;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.youarebanned.tr(),
                      style: const TextStyle(fontSize: 30),
                    ),
                    bannedUserModel.isLifetimeBan
                        ? Column(
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                "${LocaleKeys.youarebannedforlife.tr()} \n${LocaleKeys.youcancontactustoappealtheban.tr()}",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                            ],
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                  '${LocaleKeys.youarebannedfor.tr()}$daysOfBan ${LocaleKeys.days.tr()}'),
                              const SizedBox(height: 8),
                              Text(
                                  "${LocaleKeys.tryagainon.tr()}${DateFormatter.toYearMonthDay2(bannedUserModel.bannedUntil)}"),
                              const SizedBox(height: 24),
                            ],
                          ),
                    CustomButton(
                      text: LocaleKeys.logOut,
                      onPressed: () async {
                        EasyLoading.show(status: LocaleKeys.loggingout.tr());
                        await prefs!.clear();
                        await Hive.close();
                        await Hive.deleteBoxFromDisk(HiveConstants.hiveBox);
                        await ref.read(authProvider).signOut();
                        EasyLoading.dismiss();
                      },
                    )
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
          error: (_, __) => const SizedBox(),
          loading: () => const SizedBox()),
    );
  }
}
