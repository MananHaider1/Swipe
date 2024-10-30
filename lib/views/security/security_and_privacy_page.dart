import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/account_delete_request_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/account_delete_request_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/security/blocking_page.dart';
import 'package:lamatdating/views/settings/verification/verification_steps.dart';

class SecurityAndPrivacyLandingPage extends ConsumerWidget {
  const SecurityAndPrivacyLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileFutureProvider);

    return user.when(
      data: (data) {
        return data == null
            ? const ErrorPage()
            : SecurityAndPrivacyPage(user: data);
      },
      error: (_, __) => const ErrorPage(),
      loading: () => const LoadingPage(),
    );
  }
}

class SecurityAndPrivacyPage extends ConsumerStatefulWidget {
  final UserProfileModel user;
  const SecurityAndPrivacyPage({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SecurityAndPrivacyPageState();
}

class _SecurityAndPrivacyPageState
    extends ConsumerState<SecurityAndPrivacyPage> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(LocaleKeys.secandPrivacy.tr()),
      // ),
      body: Column(
        children: [
          SizedBox(
            height: height * .17,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultNumericValue),
              child: CustomAppBar(
                leading: CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                    onPressed: () {
                      (!Responsive.isDesktop(context))
                          ? Navigator.pop(context)
                          : ref.invalidate(arrangementProviderExtend);
                    },
                    color: AppConstants.primaryColor,
                    icon: leftArrowSvg),
                title: Center(
                    child: CustomHeadLine(
                  // prefs: widget.prefs,
                  text: LocaleKeys.secandPrivacy.tr(),
                )),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.block),
                  title: Text(LocaleKeys.block.tr()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BlockingPage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(LocaleKeys.status.tr()),
                  subtitle: Text(
                    widget.user.isVerified
                        ? LocaleKeys.verified.tr()
                        : LocaleKeys.notverified.tr(),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            widget.user.isVerified ? Colors.green : Colors.red),
                  ),
                  onTap: (widget.user.isVerified)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GetVerifiedPage(user: widget.user)),
                          );
                        },
                ),
                const Divider(),
              ],
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    LocaleKeys.dangerZone.tr(),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.deletingyouraccountwillpermanently.tr(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(LocaleKeys.deleteAccount.tr()),
                            content: Text(LocaleKeys
                                .areyousureyouwanttodeleteyouraccount
                                .tr()),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(LocaleKeys.cancel.tr()),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Add delete Request!
                                  final currentUserRef =
                                      ref.read(currentUserStateProvider);

                                  if (currentUserRef != null) {
                                    final phoneNumber =
                                        currentUserRef.phoneNumber;
                                    final requestDate = DateTime.now();
                                    final deleteDate = requestDate
                                        .add(const Duration(days: 30));

                                    final AccountDeleteRequestModel request =
                                        AccountDeleteRequestModel(
                                      phoneNumber: phoneNumber!,
                                      requestDate: requestDate,
                                      deleteDate: deleteDate,
                                    );

                                    EasyLoading.show(
                                        status: LocaleKeys.deleteAccount.tr());
                                    await AccountDeleteProvider
                                            .requestAccountDelete(request)
                                        .then((value) async {
                                      if (value) {
                                        await EasyLoading.dismiss();
                                        await ref
                                            .read(authProvider)
                                            .signOut()
                                            .then((value) async {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        await EasyLoading.showError(LocaleKeys
                                            .errorDeletingAccount
                                            .tr());
                                      }
                                    });
                                  }
                                },
                                child: Text(LocaleKeys.delete.tr()),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(LocaleKeys.deleteAccount.tr(),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
