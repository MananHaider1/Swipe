import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:restart_app/restart_app.dart';

class ErrorPage extends ConsumerWidget {
  final String? title;
  const ErrorPage({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context, ref) {
    // final prefs = ref.watch(sharedPreferencesProvider).value;
    return Scaffold(
      body: Padding(
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
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.4,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      AppConstants.logo,
                      color: AppConstants.primaryColor,
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
              const Spacer(),
              Text(
                LocaleKeys.somethingWentWrong.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.black87),
              ),
              if (title != null)
                const SizedBox(height: AppConstants.defaultNumericValue * 2),
              if (title != null)
                CustomButton(
                  onPressed: () {
                    showERRORSheet(
                      context,
                      title!,
                    );
                    debugPrint(title);
                    debugPrint(title);
                  },
                  text: LocaleKeys.more.tr(),
                  icon: Icons.info_outline,
                ),
              if (title != null)
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
              CustomButton(
                onPressed: () {
                  Restart.restartApp();
                },
                text: LocaleKeys.reloadScr.tr(),
                icon: Icons.sync,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
