// ignore_for_file: library_private_types_in_public_api, prefer_final_fields

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/models/sounds_model.dart';
import 'package:lamatdating/providers/sounds_provider.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/music/item_fav_music_screen.dart';

class SearchMusicScreen extends ConsumerStatefulWidget {
  final Function onSoundClick;
  final List<SoundData>? soundList;
  const SearchMusicScreen(
      {super.key, required this.onSoundClick, this.soundList});

  @override
  _SearchMusicScreenState createState() => _SearchMusicScreenState();
}

class _SearchMusicScreenState extends ConsumerState<SearchMusicScreen> {
  bool isSearch = true;

  @override
  Widget build(BuildContext context) {
    final favMusicListAsyncValue =
        isSearch ? ref.watch(soundListSearchProvider) : null;

    return favMusicListAsyncValue?.when(
          data: (favMusicList) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: List<ItemFavMusicScreen>.generate(
                favMusicList.length,
                (index) => ItemFavMusicScreen(favMusicList[index], (soundUrl) {
                  widget.onSoundClick(soundUrl);
                }, 2),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Text('${LocaleKeys.error.tr()} $error'),
        ) ??
        const LoadingPage();
  }
}
