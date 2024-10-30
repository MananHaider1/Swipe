// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/storyCamera/export_service.dart';
import 'package:video_editor/video_editor.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/storyCamera/crop_page.dart';
import 'package:lamatdating/views/storyCamera/export_result.dart';
import 'package:lamatdating/views/storyCamera/upload_screen.dart';
import 'package:lamatdating/views/teelsCamera/upload_teel.dart';

class VidEditor extends StatefulWidget {
  const VidEditor(
      {super.key,
      required this.file,
      this.thumbNail,
      this.sound,
      this.soundId,
      this.isPhoto,
      required this.isTeel});

  final File file;
  final String? thumbNail;
  final String? sound;
  final String? soundId;
  final bool? isPhoto;
  final bool isTeel;

  @override
  State<VidEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VidEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  // final _isVideoEdited = ValueNotifier<bool>(false);
  // final _isCoverSelected = ValueNotifier<bool>(false);
  final double height = 60;
  UploadScreenStory? uploadScreen;
  UploadScreenTeels? uploadScreenTeels;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  // CoverFFmpegVideoEditorConfig getCoverFFmpegVideoEditorConfig() {
  //   // Method implementation
  // }

  @override
  void initState() {
    uploadScreen = UploadScreenStory(
        postVideo: widget.file.path,
        thumbNail: widget.thumbNail,
        soundId: widget.soundId,
        sound: widget.sound,
        isPhoto: widget.isPhoto);
    uploadScreenTeels = UploadScreenTeels(
        postVideo: widget.file.path,
        thumbNail: widget.thumbNail,
        soundId: widget.soundId,
        sound: widget.sound,
        isPhoto: widget.isPhoto);
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  Future<void> updateUploadScreen({
    String? cover,
    String? file,
  }) async {
    dynamic uploadScreenNewO;
    if (widget.isTeel == false) {
      final uploadScreenNew = UploadScreenStory(
          postVideo: file ?? widget.file.path,
          thumbNail: cover ?? widget.thumbNail,
          soundId: widget.soundId,
          sound: widget.sound,
          isPhoto: widget.isPhoto);
      uploadScreenNewO = uploadScreenNew;
    } else {
      final uploadScreenNew = UploadScreenTeels(
          postVideo: file ?? widget.file.path,
          thumbNail: cover ?? widget.thumbNail,
          soundId: widget.soundId,
          sound: widget.sound,
          isPhoto: widget.isPhoto);
      uploadScreenNewO = uploadScreenNew;
    }
    setState(() {
      widget.isTeel == false
          ? uploadScreen = uploadScreenNewO
          : uploadScreenTeels = uploadScreenNewO;
    });
  }

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    // ExportService.dispose();
    super.dispose();
  }

  void _exportVideo({bool? isUplodRefresh}) async {
    _exportingProgress.value = 0;
    _isExporting.value = true;

    final config = VideoFFmpegVideoEditorConfig(
      _controller,
    );

    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        _exportingProgress.value =
            config.getFFmpegProgress(stats.getTime().round());
      },
      onError: (e, s) => EasyLoading.showError("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
        if (isUplodRefresh == true) {
          updateUploadScreen(file: file.path);
        } else {
          showDialog(
            context: context,
            builder: (_) => VideoResultPopup(video: file),
          );
        }
      },
    );

    // _controller.exportVideo(
    //   onProgress: (p0, p1) {
    //     _exportingProgress.value = p1;
    //   },
    //   onCompleted: (file) {
    //     _isExporting.value = false;
    //     if (!mounted) return;

    //     showDialog(
    //       context: context,
    //       builder: (_) => VideoResultPopup(video: file),
    //     );
    //   }, // show the exported video
    // );
  }

//    void _setVideo() async {

//     _controller.exportVideo(
//   onCompleted: (file) {
//     updateUploadScreen(file: file.path);
//   }, // show the exported video
// );
//   }

  void _setVideo() async {
    // Check if the video is trimmed, cropped, or rotated
    if (_controller.isTrimmed ||
        _controller.croppedArea != Size.zero ||
        _controller.isRotated) {
      // Export the video with the applied changes
      // _controller.exportVideo(
      //   onCompleted: (file) {
      //     // Update the uploadScreen with the new video file
      //     updateUploadScreen(file: file.path);
      //   },
      // );
      _exportVideo(isUplodRefresh: true);
    } else {
      // If no changes were made, update the uploadScreen with the original video file
      updateUploadScreen(file: widget.file.path);
    }
  }

  void _exportCover({bool? isRefreshScreen}) async {
    final config = CoverFFmpegVideoEditorConfig(_controller);
    final execute = await config.getExecuteConfig();
    if (execute == null) {
      EasyLoading.showError("Error on cover exportation initialization.");
      return;
    }

    await ExportService.runFFmpegCommand(
      execute,
      onError: (e, s) => EasyLoading.showError("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;
        if (isRefreshScreen == true) {
         updateUploadScreen(cover: cover.path);
        } else {
          showDialog(
            context: context,
            builder: (_) => CoverResultPopup(cover: cover),
          );
        }
      },
    );

    // _controller.extractCover(
    //   onCompleted: (cover) {
    //     _isExporting.value = false;
    //     if (!mounted) return;

    //     showDialog(
    //       context: context,
    //       builder: (_) => CoverResultPopup(cover: cover),
    //     );
    //   }, // show the exported video
    // );
  }

  void _setCover() async {
    _exportCover(isRefreshScreen: true);
    // _controller.extractCover(
    //   onCompleted: (cover) {
    //     _isExporting.value = false;
    //     if (!mounted) return;
    //     updateUploadScreen(cover: cover.path);
    //   }, // show the exported video
    // );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // backgroundColor: Colors.wh,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                              controller: _controller),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity:
                                                  _controller.isPlaying ? 0 : 1,
                                              duration: kThemeAnimationDuration,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CoverViewer(controller: _controller)
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      TabBar(
                                        dividerColor: Colors.transparent,
                                        indicatorColor: Colors.transparent,
                                        tabs: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                        Icons.content_cut)),
                                                Text(
                                                  LocaleKeys.trim.tr(),
                                                )
                                              ]),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child:
                                                      Icon(Icons.video_label)),
                                              Text(
                                                LocaleKeys.cover.tr(),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider(),
                                            ),
                                            _coverSelection(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isExporting,
                                  builder: (_, bool export, Widget? child) =>
                                      AnimatedSize(
                                    duration: kThemeAnimationDuration,
                                    child: export ? child : null,
                                  ),
                                  child: AlertDialog(
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, __) => Text(
                                        "${(value * 100).ceil()}%",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: (widget.isTeel == true)
                              ? uploadScreenTeels
                              : uploadScreen)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  backgroundColor: AppConstants.backgroundColor,
                  isScrollControlled: true,
                ),
                child: Text(
                  LocaleKeys.upload.tr(),
                  style: const TextStyle(color: AppConstants.primaryColor),
                ),
              ),
              // tooltip: 'Upload Video',
            ),
            // const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () {
                  _controller.rotate90Degrees(RotateDirection.left);
                  _setVideo();
                },
                icon: const Icon(Icons.rotate_left),
                tooltip: LocaleKeys.rotateleft.tr(),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  _controller.rotate90Degrees(RotateDirection.right);
                  _setVideo();
                },
                icon: const Icon(Icons.rotate_right),
                tooltip: LocaleKeys.rotateright.tr(),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CropPage(controller: _controller),
                  ),
                ),
                icon: const Icon(Icons.crop),
                tooltip: LocaleKeys.openCropScr.tr(),
              ),
            ),
            // const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: PopupMenuButton(
                tooltip: LocaleKeys.openExportMenu.tr(),
                icon: const Icon(Icons.save),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: _exportCover,
                    child: Text(
                      LocaleKeys.exportCover.tr(),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: _exportVideo,
                    child: Text(
                      LocaleKeys.exportVideo.tr(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_rounded),
                tooltip: LocaleKeys.openCropScr.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final int duration = _controller.videoDuration.inSeconds;
          final double pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: InkWell(
              onFocusChange: (change) {
                change == true ? _setVideo() : null;
                // _setVideo();
              },
              child: TrimTimeline(
                controller: _controller,
                padding: const EdgeInsets.only(top: 10),
              )),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return InkWell(
                  onTap: () {
                    _setCover();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      cover,
                      Icon(
                        Icons.check_circle,
                        color: const CoverSelectionStyle().selectedBorderColor,
                      )
                    ],
                  ));
            },
          ),
        ),
      ),
    );
  }
}
