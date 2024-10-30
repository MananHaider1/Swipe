import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/providers/sounds_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/music/item_fav_music_screen.dart';

class DiscoverPage extends ConsumerWidget {
  final Function? onPlayClick;

  const DiscoverPage(
      {super.key,
      this.onPlayClick,
      required Null Function(dynamic value) onMoreClick});

  @override
  Widget build(BuildContext context, ref) {
    final soundListAsyncValue = ref.watch(soundListProvider);
    return soundListAsyncValue.when(
      data: (soundList) {
        soundList.isNotEmpty ? {} : {};
        return soundList.isNotEmpty
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: soundList.length,
                itemBuilder: (context, index) {
                  return ItemFavMusicScreen(
                    soundList[index],
                    (soundUrl) {
                      onPlayClick!(soundUrl);
                    },
                    1,
                  );
                },
              )
            : NoItemFoundWidget(
                text: LocaleKeys.noMediafound.tr(),
              );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('${LocaleKeys.error.tr()}: $error')),
    );
  }
}


// // ignore_for_file: library_private_types_in_public_api

// import 'package:lamatdating/v2/api/api_service.dart';
// import 'package:lamatdating/v2/modal/sound/sound.dart';
// import 'package:flutter/material.dart';

// import 'item_discover_screen.dart';

// class DiscoverPage extends StatefulWidget {
//   final Function? onMoreClick;
//   final Function? onPlayClick;

//   const DiscoverPage({super.key, this.onMoreClick, this.onPlayClick});

//   @override
//   _DiscoverPageState createState() => _DiscoverPageState();
// }

// class _DiscoverPageState extends State<DiscoverPage> {
//   List<SoundCategory>? soundCategoryList = [];

//   @override
//   void initState() {
//     getDiscoverSound();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return (soundCategoryList != null)
//         ? ListView(
//             physics: const BouncingScrollPhysics(),
//             children: List<ItemDiscoverScreen>.generate(
//               soundCategoryList!.length,
//               (index) => ItemDiscoverScreen(
//                 soundCategoryList![index],
//                 (soundList) {
//                   widget.onMoreClick!.call(soundList);
//                 },
//                 widget.onPlayClick,
//               ),
//             ),
//           )
//         : Container();
//   }

//   final ApiService _apiService = ApiService();

//   void getDiscoverSound() {
//     _apiService.getSoundList().then((value) {
//       soundCategoryList = value.data;
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _apiService.client.close();
//     super.dispose();
//   }
// }
