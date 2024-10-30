import 'package:easy_localization/easy_localization.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/sounds_model.dart';

import 'package:lamatdating/views/music/item_fav_music_screen.dart';
import 'package:flutter/material.dart';

class ItemDiscoverScreen extends StatelessWidget {
  final SoundCategory soundData;
  final Function onMoreClick;
  final Function? onPlayClick;

  const ItemDiscoverScreen(this.soundData, this.onMoreClick, this.onPlayClick,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  soundData.soundCategoryName ?? '',
                  style: const TextStyle(
                      color: AppConstants.primaryColor,
                      overflow: TextOverflow.ellipsis),
                ),
              ),
              InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                onTap: () {
                  onMoreClick.call(soundData.soundList);
                },
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.more.tr(),
                      style: const TextStyle(
                        color: AppConstants.textColorLight,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    WebsafeSvg.asset(
                      menuIcon,
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                 AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: soundData.soundList?.length,
          itemBuilder: (context, index) {
            return ItemFavMusicScreen(
              soundData.soundList![index],
              (soundUrl) {
                onPlayClick!(soundUrl);
              },
              1,
            );
          },
        )
      ],
    );
  }
}
