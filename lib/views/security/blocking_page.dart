import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/block_user_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';

class BlockingPage extends ConsumerWidget {
  const BlockingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedUsersFuture = ref.watch(blockedUsersFutureProvider);
    final allOtherUsersFuture =
        ref.watch(otherUsersWithoutBlockedProvider(ref));
    // final prefs = ref.watch(sharedPreferencesProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.blocking.tr()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
              child: Text(LocaleKeys.listofblocked.tr())),
          const Divider(),
          Expanded(
            child: blockedUsersFuture.when(
              data: (data) {
                if (data.isEmpty) {
                  return Center(
                    child: Text(LocaleKeys.youhaventblockedanyoneyet.tr()),
                  );
                } else {
                  return allOtherUsersFuture.when(
                    data: (users) {
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          final blockedModel = data[index];
                          final user = users.firstWhere((user) =>
                              user.phoneNumber == blockedModel.blockedUserId);

                          return ListTile(
                            title: Text(user.fullName),
                            leading: UserCirlePicture(
                                imageUrl: user.profilePicture, size: 35),
                            trailing: TextButton(
                              onPressed: () async {
                                await unblockUser(blockedModel.id)
                                    .then((value) {
                                  ref.invalidate(blockedUsersFutureProvider);
                                  ref.invalidate(otherUsersProvider);
                                });
                              },
                              child: Text(LocaleKeys.unblock.tr()),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: data.length,
                      );
                    },
                    error: (_, __) => const ErrorPage(),
                    loading: () => const LoadingPage(),
                  );
                }
              },
              error: (_, __) => const ErrorPage(),
              loading: () => const LoadingPage(),
            ),
          ),
        ],
      ),
    );
  }
}
