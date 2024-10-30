// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/sounds_model.dart';
import 'package:lamatdating/views/music/discover_page.dart';
import 'package:lamatdating/views/music/favourite_page.dart';
import 'package:lamatdating/views/music/search_screen.dart';

import 'package:lamatdating/helpers/my_loading/my_loading.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';

class MainMusicScreen extends ConsumerStatefulWidget {
  final Function(SoundData?, String) onSelectMusic;

  const MainMusicScreen(this.onSelectMusic, {super.key});

  @override
  _MainMusicScreenState createState() => _MainMusicScreenState();
}

class _MainMusicScreenState extends ConsumerState<MainMusicScreen> {
  PageController? _controller;
  final FocusNode _focus = FocusNode();
  List<SoundData>? soundList;
  bool isPlay = false;
  SoundData? lastSoundListData;

  AudioPlayer? audioPlayer = AudioPlayer();

  String _localPath = '';
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _bindBackgroundIsolate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focus.addListener(() {
      ref.watch(myLoadingProvider).setIsSearchMusic(_focus.hasFocus);
      soundList = null;
    });
    _controller = PageController(
        initialPage: ref.watch(myLoadingProvider).getMusicPageIndex,
        keepPage: true);
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (kDebugMode) {
      print('🙃');
    }
    _port.listen((dynamic data) {
      DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      setState(() {});

      if (status.index == 3) {
        widget.onSelectMusic(
            lastSoundListData, _localPath + lastSoundListData!.sound!);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    final myLoadingProviderProvider = ref.watch(myLoadingProvider);
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          const SizedBox(
            height: AppConstants.defaultNumericValue,
          ),
          SafeArea(
            bottom: false,
            child: Consumer(
              builder: (context, ref, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: soundList != null &&
                          myLoadingProviderProvider.isSearchMusic,
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          if (myLoadingProviderProvider
                              .musicSearchText.isEmpty) {
                            FocusScope.of(context).unfocus();

                            myLoadingProviderProvider.setIsSearchMusic(false);
                            myLoadingProviderProvider.setLastSelectSoundId("");
                            soundList = null;
                            if (audioPlayer != null) {
                              audioPlayer?.release();
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15, top: 15),
                          width: 45,
                          child: Text(
                            LocaleKeys.back.tr(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                            left: soundList != null
                                ? 0
                                : AppConstants.defaultNumericValue,
                            top: AppConstants.defaultNumericValue,
                            right: AppConstants.defaultNumericValue),
                        padding: const EdgeInsets.only(
                            left: AppConstants.defaultNumericValue,
                            right: AppConstants.defaultNumericValue,
                            bottom: 5),
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(.1),
                          borderRadius: const BorderRadius.all(Radius.circular(
                              AppConstants.defaultNumericValue * 3)),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            if (audioPlayer != null) {
                              audioPlayer?.release();
                            }

                            myLoadingProviderProvider.setMusicSearchText(value);
                            myLoadingProviderProvider.setLastSelectSoundId("");
                          },
                          focusNode: _focus,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LocaleKeys.search.tr(),
                            hintStyle: const TextStyle(
                              fontSize: AppConstants.defaultNumericValue,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: AppConstants.defaultNumericValue,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: soundList == null &&
                          myLoadingProviderProvider.isSearchMusic,
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          if (myLoadingProviderProvider
                              .musicSearchText.isEmpty) {
                            FocusScope.of(context).unfocus();
                            if (audioPlayer != null) {
                              audioPlayer?.release();
                            }
                            myLoadingProviderProvider.setIsSearchMusic(false);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: 60,
                          child: Text(
                            myLoadingProviderProvider.musicSearchText.isNotEmpty
                                ? LocaleKeys.search.tr()
                                : 'cancel'.tr(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 18),
            height: 0,
          ),
          Consumer(
            builder: (context, ref, child) {
              return Visibility(
                visible: !myLoadingProviderProvider.isSearchMusic,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          _controller!.animateToPage(0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        },
                        child: Center(
                          child: Text(
                            LocaleKeys.discover.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  myLoadingProviderProvider.getMusicPageIndex ==
                                          0
                                      ? AppConstants.primaryColor
                                      : AppConstants.textColorLight,
                              fontSize: AppConstants.defaultNumericValue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          _controller!.animateToPage(1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        },
                        child: Center(
                          child: Text(
                            LocaleKeys.favourite.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  myLoadingProviderProvider.getMusicPageIndex ==
                                          1
                                      ? AppConstants.primaryColor
                                      : AppConstants.textColorLight,
                              fontSize: AppConstants.defaultNumericValue,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return !myLoadingProviderProvider.isSearchMusic
                    ? PageView(
                        controller: _controller,
                        onPageChanged: (value) {
                          myLoadingProviderProvider.setLastSelectSoundId("");
                          myLoadingProviderProvider.setMusicPageIndex(value);
                          audioPlayer?.release();
                        },
                        children: [
                          DiscoverPage(
                            onMoreClick: (value) {
                              soundList = value;
                              myLoadingProviderProvider.setIsSearchMusic(true);
                            },
                            onPlayClick: (data) {
                              playMusic(data, 1);
                            },
                          ),
                          FavouritePage(
                            onClick: (data) {
                              playMusic(data, 2);
                            },
                          ),
                        ],
                      )
                    : (soundList != null && soundList!.isNotEmpty
                        ? SearchMusicScreen(
                            soundList: soundList,
                            onSoundClick: (data) {
                              playMusic(data, 3);
                            },
                          )
                        : SearchMusicScreen(
                            onSoundClick: (data) {
                              playMusic(data, 3);
                            },
                          ));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    audioPlayer?.release();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  void playMusic(SoundData data, int type) async {
    final myLoadingProviderProvider = ref.watch(myLoadingProvider);
    if (myLoadingProviderProvider.isDownloadClick) {
      showDialog(
        context: context,
        builder: (context) => const LoaderDialog(),
      );
      myLoadingProviderProvider.setIsDownloadClick(false);
      _localPath = "${await _findLocalPath()}/${ConstRes.camera}";

      final savedDir = Directory(_localPath);

      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      if (File(savedDir.path + data.sound!).existsSync()) {
        File(savedDir.path + data.sound!).deleteSync();
      }
      await FlutterDownloader.enqueue(
        url: data.sound!,
        savedDir: _localPath,
      );
      return;
    }
    if (lastSoundListData == data) {
      if (isPlay) {
        isPlay = false;
        audioPlayer?.pause();
      } else {
        isPlay = true;
        audioPlayer?.resume();
      }
      myLoadingProviderProvider.setLastSelectSoundIsPlay(isPlay);
      return;
    }
    lastSoundListData = data;
    myLoadingProviderProvider.setLastSelectSoundId(lastSoundListData!.sound!);
    myLoadingProviderProvider.setLastSelectSoundIsPlay(true);
    if (audioPlayer != null) {
      audioPlayer?.release();
    }
    audioPlayer?.play(UrlSource("${lastSoundListData?.sound}"));
    isPlay = true;
  }

  Future<String> _findLocalPath() async {
    final directory = !kIsWeb
        ? Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();
    if (kDebugMode) {
      print(directory?.path);
    }
    return "${directory?.path}";
  }
}
