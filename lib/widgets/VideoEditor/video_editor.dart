// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/helpers/size.dart';
import 'package:lamatdating/helpers/transition.dart';
import 'package:lamatdating/helpers/widg/animated_interactive_viewer.dart';
import 'package:lamatdating/helpers/widg/widgets.dart';

import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lamatdating/views/storyCamera/export_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor(
      {super.key,
      required this.file,
      this.onClose,
      required this.thumbnailQuality,
      required this.videoQuality,
      required this.prefs,
      required this.maxDuration,
      required this.onEditExported});

  final File file;
  final Function()? onClose;
  final int thumbnailQuality;
  final SharedPreferences prefs;
  final int videoQuality;
  final int maxDuration;
  final Function(File videoFile, File thumbnailFile) onEditExported;

  @override
  VideoEditorState createState() => VideoEditorState();
}

class VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  final bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: Duration(seconds: widget.maxDuration))
      ..initialize().then((_) => setState(() {})).catchError((onError) {
        Navigator.of(context).pop();
      });
    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => CropScreen(controller: _controller)));
  void _exportVideo() async {
    _isExporting.value = true;
    setState(() {});

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
      
      onCompleted: (file) async {
        _isExporting.value = false;
        if (!mounted) return;
        // ignore: unnecessary_null_comparison
        if (file != null) {
          if (_controller.selectedCoverVal == null) {
            final configc = CoverFFmpegVideoEditorConfig(_controller, quality: 50);
    final executec = await configc.getExecuteConfig();
    if (executec == null) {
      EasyLoading.showError("Error on cover exportation initialization.");
      return;
    }
    await ExportService.runFFmpegCommand(
      executec,
      onError: (e, s) {
        _exportText = "Error on export video :( \n\nERROR: $e";
              Navigator.of(context).pop();
              Lamat.toast(_exportText);
        },
      onCompleted: (coverFile) {
        Navigator.of(context).pop();
                      widget.onEditExported(file, coverFile);
      },
      
    );
            
          } else if (_controller.selectedCoverVal!.timeMs == 0) {
            final configc = CoverFFmpegVideoEditorConfig(_controller, quality: 50);
    final executec = await configc.getExecuteConfig();
    if (executec == null) {
      EasyLoading.showError("Error on cover exportation initialization.");
      return;
    }
    await ExportService.runFFmpegCommand(
      executec,
      onError: (e, s) {
        _exportText = "Error on export video :( \n\nERROR: $e";
              Navigator.of(context).pop();
              Lamat.toast(_exportText);
        },
      onCompleted: (coverFile) {
        Navigator.of(context).pop();
                      widget.onEditExported(file, coverFile);
      },
      
    );
            
          } else {
            Uint8List imageInUnit8List;
            
            if (_controller.selectedCoverVal!.thumbData == null) {
              final configc = CoverFFmpegVideoEditorConfig(_controller, quality: 50);
    final executec = await configc.getExecuteConfig();
    if (executec == null) {
      EasyLoading.showError("Error on cover exportation initialization.");
      return;
    }
    await ExportService.runFFmpegCommand(
      executec,
      onError: (e, s) {
        _exportText = "Error on export video :( \n\nERROR: $e";
              Navigator.of(context).pop();
              Lamat.toast(_exportText);
        },
      onCompleted: (coverFile) async {
        imageInUnit8List = coverFile.readAsBytesSync();
                    final tempDir = await getTemporaryDirectory();
                    File thumbnailFile = await File(
                            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png')
                        .create();
                    thumbnailFile.writeAsBytesSync(imageInUnit8List);
                    Navigator.of(context).pop();
                    widget.onEditExported(file, thumbnailFile);
      },
      
    );
              // await _controller.extractCover(
              //     onCompleted: (coverFile) async {
              //       imageInUnit8List = coverFile.readAsBytesSync();
              //       final tempDir = await getTemporaryDirectory();
              //       File thumbnailFile = await File(
              //               '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png')
              //           .create();
              //       thumbnailFile.writeAsBytesSync(imageInUnit8List);
              //       Navigator.of(context).pop();
              //       widget.onEditExported(file, thumbnailFile);
              //     },
              //     quality: widget.thumbnailQuality);
            } else {
              imageInUnit8List = _controller.selectedCoverVal!.thumbData!;
              final tempDir = await getTemporaryDirectory();
              File thumbnailFile = await File(
                      '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png')
                  .create();
              thumbnailFile.writeAsBytesSync(imageInUnit8List);
              Navigator.of(context).pop();
              widget.onEditExported(file, thumbnailFile);
            }
          }
        } else {
          _exportText = "Error on export video :(";
          Navigator.of(context).pop();
          Lamat.toast(_exportText);
        }
      },
    );
     

    
  }
  // void _exportCover() async {
  //   setState(() => _exported = false);

  //   await _controller.extractCover(
  //       onCompleted: (cover) {
  //         if (!mounted) return;

  //         if (cover != null) {
  //           _exportText = "Cover exported! ${cover.path}";
  //           showModalBottomSheet(
  //             context: context,
  //             backgroundColor: Colors.black54,
  //             builder: (BuildContext context) =>
  //                 Image.memory(cover.readAsBytesSync()),
  //           );
  //         } else
  //           _exportText = "Error on cover exportation :(";

  //         setState(() => _exported = true);
  //         Misc.delayed(2000, () => setState(() => _exported = false));
  //       },
  //       quality: widget.thumbnailQuality);
  // }

  DateTime? currentBackPressTime = DateTime.now();
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime!) > const Duration(seconds: 3)) {
      currentBackPressTime = now;
      Lamat.toast(
        "Double Tap To Go Back",
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light));
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _controller.initialized
              ? SafeArea(
                  child: Stack(children: [
                  Column(children: [
                    _topNavBar(),
                    Expanded(
                        child: DefaultTabController(
                            length: 2,
                            child: Column(children: [
                              Expanded(
                                  child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Stack(alignment: Alignment.center, children: [
                                    CropGridViewer.preview(
                                      controller: _controller,
                                    ),
                                    AnimatedBuilder(
                                      animation: _controller.video,
                                      builder: (_, __) => OpacityTransition(
                                        visible: !_controller.isPlaying,
                                        child: GestureDetector(
                                          onTap: _controller.video.play,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.play_arrow,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  CoverViewer(controller: _controller)
                                ],
                              )),
                              Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 18),
                                  child: Column(children: [
                                    const TabBar(
                                      indicatorWeight: 1,
                                      indicatorColor: Colors.white30,
                                      dividerColor: Colors.transparent,
                                      tabs: [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                      Icons.content_cut,
                                                      size: 16,
                                                      // color: Colors.white,
                                                    )),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                if (IsShowTextLabelsInPhotoVideoEditorPage ==
                                                    true)
                                                  Text(
                                                    "Trim",
                                                  )
                                              ]),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                      Icons.video_label,
                                                      size: 16,
                                                      // color: Colors.white
                                                    )),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                if (IsShowTextLabelsInPhotoVideoEditorPage ==
                                                    true)
                                                  Text(
                                                    "Cover",
                                                  )
                                              ]),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider()),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [_coverSelection()]),
                                        ],
                                      ),
                                    )
                                  ])),
                              _customSnackBar(),
                              ValueListenableBuilder(
                                valueListenable: _isExporting,
                                builder: (_, bool export, __) =>
                                    OpacityTransition(
                                        visible: export,
                                        child: Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: ValueListenableBuilder(
                                              valueListenable:
                                                  _exportingProgress,
                                              builder: (_, double value, __) =>
                                                  LinearPercentIndicator(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.2,
                                                      lineHeight: 8.0,
                                                      percent:
                                                          (value * 100).ceil() /
                                                              100,
                                                      progressColor: AppConstants
                                                          .lamatGreenColorAccent),
                                            ))),
                              )
                            ])))
                  ])
                ]))
              : const Center(child: CircularProgressIndicator()),
        ));
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.left),
                child: Icon(
                  Icons.rotate_left,
                  color: _isExporting.value ? Colors.transparent : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _controller.rotate90Degrees(RotateDirection.right),
                child: Icon(
                  Icons.rotate_right,
                  color: _isExporting.value ? Colors.transparent : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _openCropScreen,
                child: Icon(
                  Icons.crop,
                  color: _isExporting.value ? Colors.transparent : Colors.white,
                ),
              ),
            ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: _exportCover,
            //     child: Icon(Icons.close, color: Colors.grey),
            //   ),
            // ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.close,
                    color:
                        _isExporting.value ? Colors.transparent : Colors.grey),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _exportVideo,
                child: Icon(
                  Icons.done,
                  color: _isExporting.value
                      ? Colors.transparent
                      : AppConstants.secondaryColor,
                ),
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
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.only(left: height / 4, right: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  const SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: height / 4, bottom: height / 4),
        child: TrimSlider(
            controller: _controller,
            height: height,
            horizontalMargin: height / 4,
            child: TrimTimeline(
                controller: _controller,
                padding: const EdgeInsets.only(top: 10))),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.only(left: height / 4, right: height / 4),
        child: CoverSelection(
          // quality: widget.thumbnailQuality,
          controller: _controller,
          size: height,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

//-----------------//
//CROP VIDEO SCREEN//
//-----------------//
class CropScreen extends StatelessWidget {
  const CropScreen({super.key, required this.controller});

  final VideoEditorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(children: [
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.rotate90Degrees(RotateDirection.left),
                  child: const Icon(Icons.rotate_left, color: Colors.white),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.rotate90Degrees(RotateDirection.right),
                  child: const Icon(Icons.rotate_right, color: Colors.white),
                ),
              )
            ]),
            const SizedBox(height: 15),
            Expanded(
              child: AnimatedInteractiveViewer(
                maxScale: 2.4,
                child: CropGridViewer.edit(
                    controller: controller,
                    margin: const EdgeInsets.symmetric(horizontal: 30)),
              ),
            ),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(
                child: SplashTap(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      "Cancel ".toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              buildSplashTap("16:9", 16 / 9,
                  padding: const Margin.horizontal(10)),
              buildSplashTap("1:1", 1 / 1),
              buildSplashTap("4:5", 4 / 5,
                  padding: const Margin.horizontal(10)),
              buildSplashTap("No".toUpperCase(), null,
                  padding: const Margin.right(10)),
              Expanded(
                child: SplashTap(
                  onTap: () {
                    //2 WAYS TO UPDATE CROP
                    //WAY 1:
                    controller.applyCacheCrop();
                    /*WAY 2:
                    controller.minCrop = controller.cacheMinCrop;
                    controller.maxCrop = controller.cacheMaxCrop;
                    */
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      "Ok".toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget buildSplashTap(
    String title,
    double? aspectRatio, {
    EdgeInsetsGeometry? padding,
  }) {
    return SplashTap(
      onTap: () => controller.preferredCropAspectRatio = aspectRatio,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.aspect_ratio, color: Colors.white),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
