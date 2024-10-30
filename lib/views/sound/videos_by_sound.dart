// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/others/item_post.dart';
import 'package:lamatdating/views/teelsCamera/camera_teels.dart';
import 'package:marquee/marquee.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/modal/uservideo/user_video.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';

class VideosBySoundScreen extends ConsumerStatefulWidget {
  final TeelsModel? videoData;

  const VideosBySoundScreen(this.videoData, {super.key});

  @override
  _VideosBySoundScreenState createState() => _VideosBySoundScreenState();
}

class _VideosBySoundScreenState extends ConsumerState<VideosBySoundScreen> {
  var start = 0;
  int? count = 0;
  bool isLoading = true;
  bool isPlay = false;
  bool isFav = true;
  final ScrollController _scrollController = ScrollController();
  final StreamController _streamController = StreamController<List<Data>?>();
  List<TeelsModel>? postList = [];
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    initIsFav();
    _scrollController.addListener(
      () {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          if (!isLoading) {
            callApiForGetPostsBySoundId();
          }
        }
      },
    );
    callApiForGetPostsBySoundId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    height: 50,
                    width: 40,
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      LocaleKeys.soundVideos.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 0.3,
              color: AppConstants.textColorLight.withOpacity(0.2),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.all(15),
                  height: 100,
                  width: 100,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        child: Image(
                          image: NetworkImage(
                            widget.videoData!.soundImage!,
                          ),
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(),
                        ),
                      ),
                      Center(
                        child: IconWithRoundGradient(
                          iconData: isPlay
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 35,
                          onTap: () async {
                            if (!isPlay) {
                              await audioPlayer.play(
                                UrlSource(widget.videoData!.postSound!),
                              );
                              audioPlayer.setReleaseMode(ReleaseMode.loop);
                            } else {
                              audioPlayer.release();
                            }
                            isPlay = !isPlay;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        height: 25,
                        child: Marquee(
                          text: widget.videoData!.soundTitle!,
                          style: const TextStyle(
                            fontFamily: fNSfUiMedium,
                            fontSize: 22,
                          ),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 50.0,
                          velocity: 100.0,
                          pauseAfterRound: const Duration(seconds: 1),
                          startPadding: 10.0,
                          accelerationDuration: const Duration(seconds: 1),
                          accelerationCurve: Curves.linear,
                          decelerationDuration:
                              const Duration(milliseconds: 500),
                          decelerationCurve: Curves.easeOut,
                        ),
                      ),
                      Text(
                        '$count ${LocaleKeys.videos.tr()}',
                        style: const TextStyle(
                          color: AppConstants.textColorLight,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          isFav = !isFav;
                          sessionManager.saveFavouriteMusic(
                              widget.videoData!.soundId.toString());
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFav
                                  ? [
                                      AppConstants.backgroundColorDark,
                                      AppConstants.backgroundColorDark,
                                    ]
                                  : [
                                      AppConstants.primaryColor,
                                      AppConstants.secondaryColor
                                    ],
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                          ),
                          height: 30,
                          width: isFav ? 130 : 110,
                          duration: const Duration(milliseconds: 500),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                !isFav
                                    ? Icons.bookmark_border_rounded
                                    : Icons.bookmark_rounded,
                                color: Colors.white,
                                size: !isFav ? 21 : 18,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                isFav
                                    ? LocaleKeys.unfavourite.tr()
                                    : LocaleKeys.favourite.tr(),
                                style: const TextStyle(fontFamily: fNSfUiBold),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, snapshot) {
                      List<TeelsModel>? userVideo = [];
                      if (snapshot.data != null) {
                        userVideo = (snapshot.data as List<TeelsModel>?)!;
                        postList?.addAll(userVideo);
                        _streamController.add(null);
                      }
                      return postList == null || postList!.isEmpty
                          ? const LoadingPage()
                          : GridView(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1 / 1.3,
                              ),
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 20),
                              children: List.generate(
                                postList?.length ?? 0,
                                (index) => ItemPost(
                                  list: postList,
                                  data: postList?[index],
                                  soundId: widget.videoData!.soundId.toString(),
                                  type: "video",
                                  onTap: () {
                                    audioPlayer.pause();
                                    isPlay = !isPlay;
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                    },
                  ),
                  Positioned(
                    bottom: 25,
                    right: 0,
                    left: 0,
                    child: Center(
                      child: Container(
                        height: 45,
                        width: 160,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                        child: InkWell(
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          onTap: () {
                            audioPlayer.pause();
                            isPlay = false;
                            setState(() {});
                            if (SessionManager.phoneNumber == -1) {
                              showModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                  ),
                                ),
                                isScrollControlled: true,
                                context: context,
                                builder: (context) {
                                  return const CameraScreenTeels();
                                },
                              ).then((value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraScreenTeels(
                                      soundId:
                                          widget.videoData!.soundId.toString(),
                                      soundTitle: widget.videoData!.soundTitle,
                                      soundUrl: widget.videoData!.postSound,
                                    ),
                                  ),
                                );
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraScreenTeels(
                                    soundId:
                                        widget.videoData!.soundId.toString(),
                                    soundTitle: widget.videoData!.soundTitle,
                                    soundUrl: widget.videoData!.postSound,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle_filled_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                LocaleKeys.useThisSound.tr(),
                                style: const TextStyle(
                                  fontFamily: fNSfUiSemiBold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callApiForGetPostsBySoundId() {
    final allTeels = ref.watch(getTeelsProvider);

    allTeels.when(
      data: (teelsList) {
        final typeTeels = teelsList
            .where((element) =>
                element.soundId!.contains(widget.videoData!.soundId.toString()))
            .toList();

        if (typeTeels.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
                child: NoItemFoundWidget(text: LocaleKeys.noFeedFound.tr())),
          );
        } else {
          start += 10;
          isLoading = false;
          if (count == 0) {
            count = typeTeels.length;
            setState(() {});
          }
          _streamController.add(typeTeels);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(LocaleKeys.errorOccured.tr())),
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  SessionManager sessionManager = SessionManager();

  void initIsFav() async {
    await sessionManager.initPref();
    isFav = sessionManager
        .getFavouriteMusic()
        .contains(widget.videoData!.soundId.toString());
    setState(() {});
  }
}
