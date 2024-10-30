// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/sounds_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/music/item_fav_music_screen.dart';

class FavouritePage extends ConsumerWidget {
  final Function? onClick;

  const FavouritePage({super.key, this.onClick});

  @override
  Widget build(BuildContext context, ref) {
    final userProfile = ref.watch(userProfileNotifier);
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final favSongsIdsFuture =
        userProfile.getFavouriteMusic(phoneNumber: phoneNumber!);
    final soundListAsyncValue = ref.watch(soundListProvider);

    return FutureBuilder<List<String>>(
      future: favSongsIdsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator()); // or another widget while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Now we have the list of favorite song IDs
          final favSongsIds = snapshot.data!;

          // Fetch the SoundData objects for these IDs
          final favMusicList = soundListAsyncValue.maybeWhen(
            data: (data) => data
                .where((sound) => favSongsIds.contains(sound.soundId))
                .toList(),
            orElse: () => [],
          );

          return favMusicList.isNotEmpty
              ? ListView(
                  physics: const BouncingScrollPhysics(),
                  children: List<ItemFavMusicScreen>.generate(
                    favMusicList.length,
                    (index) =>
                        ItemFavMusicScreen(favMusicList[index], (soundUrl) {
                      onClick!(soundUrl);
                    }, 2),
                  ),
                )
              : NoItemFoundWidget(
                  text: LocaleKeys.noMediafound.tr(),
                );
        }
      },
    );
  }
}
