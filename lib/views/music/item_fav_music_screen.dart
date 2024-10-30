// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/sounds_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';

import 'package:lamatdating/helpers/my_loading/my_loading.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:flutter/material.dart';

class ItemFavMusicScreen extends ConsumerStatefulWidget {
  final SoundData soundList;
  final Function onItemClick;
  final int type;

  const ItemFavMusicScreen(this.soundList, this.onItemClick, this.type,
      {super.key});

  @override
  _ItemFavMusicScreenState createState() => _ItemFavMusicScreenState();
}

class _ItemFavMusicScreenState extends ConsumerState<ItemFavMusicScreen> {
  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    // initSessionManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final myLoadingProviderProvider = ref.watch(myLoadingProvider);
    final userProfile = ref.read(userProfileNotifier);

    return InkWell(
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: () {
        widget.onItemClick(widget.soundList);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Consumer(
              builder: (context, ref, child) => Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image(
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      image: NetworkImage(widget.soundList.soundImage!),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 70,
                          width: 70,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: WebsafeSvg.asset(
                            menuIcon,
                            height: 70,
                            width: 70,
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
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: myLoadingProviderProvider.lastSelectSoundId ==
                        widget.soundList.sound!,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          !myLoadingProviderProvider.getLastSelectSoundIsPlay
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.soundList.soundTitle!,
                    style: const TextStyle(
                      fontSize: AppConstants.defaultNumericValue,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.soundList.singer!,
                    style: const TextStyle(
                      color: AppConstants.textColorLight,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    widget.soundList.duration!,
                    style: const TextStyle(
                      color: AppConstants.textColorLight,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
            InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                onTap: () async {
                  await userProfile.saveFavouriteMusic(
                      soundId: widget.soundList.soundId.toString(),
                      phoneNumber: phoneNumber);

                  setState(() {});
                },
                child: FutureBuilder<List<String>>(
                  future:
                      userProfile.getFavouriteMusic(phoneNumber: phoneNumber!),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Icon(
                        Icons.bookmark_border_rounded,
                        color: AppConstants.primaryColor,
                      ); // or another widget while waiting
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Icon(
                        snapshot.data!
                                .contains(widget.soundList.soundId.toString())
                            ? Icons.bookmark
                            : Icons.bookmark_border_rounded,
                        color: AppConstants.primaryColor,
                      );
                    }
                  },
                )),
            Consumer(
              builder: (context, ref, child) => Visibility(
                visible: myLoadingProviderProvider.lastSelectSoundId ==
                    widget.soundList.sound!,
                child: InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  onTap: () async {
                    myLoadingProviderProvider.setIsDownloadClick(true);
                    if (kDebugMode) {
                      print(widget.soundList.toJson());
                    }
                    widget.onItemClick(widget.soundList);
                  },
                  child: Container(
                    width: 50,
                    height: 25,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: AppConstants.primaryColor,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
