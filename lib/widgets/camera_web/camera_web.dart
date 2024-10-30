// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

/// Camera example home widget.
class CameraWebHome extends StatefulWidget {
  final Function(Uint8List file, bool isVideo, String fileName, File? videoData)
      onTakeFileWeb;
  final SharedPreferences prefs;

  /// Default Constructor
  const CameraWebHome({
    super.key,
    required this.onTakeFileWeb,
    required this.prefs,
  });

  @override
  State<CameraWebHome> createState() {
    return _CameraWebHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  // This enum is from a different package, so a new value could be added at
  // any time. The example should keep working if that happens.
  // ignore: dead_code
  return Icons.camera;
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraWebHomeState extends State<CameraWebHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  XFile? videoFile;
  VideoPlayerController? videoController;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  late AnimationController _flashModeControlRowAnimationController;
  late AnimationController _exposureModeControlRowAnimationController;
  late AnimationController _focusModeControlRowAnimationController;
  final double _minAvailableZoom = 1.0;
  final double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  late List<CameraDescription> _cameras;

  bool isStartRecording = false;

  TabController? _tabController;
  bool isPhoto = true;
  int _currentIndex = 0;

  bool isPaused = false;

//   // Fetch the available cameras before initializing the app.

  @override
  void initState() {
    getCameras();
    // bool _isPhoto = isPhoto;
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void getCameras() async {
    // try {
    //   cameras = await availableCameras();
    // } on CameraException catch (e) {
    //   logError(e.code, e.description);
    // }
    _cameras = await availableCameras();
    controller = CameraController(
      _cameras.first,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.max,
      enableAudio: enableAudio,
    );
    controller!.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (controller!.value.hasError) {
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
    EasyLoading.dismiss();
    // return controller.initialize();
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();

    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //     // title: const Text('Camera example'),
      //     ),
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(
                color: controller != null && controller!.value.isRecordingVideo
                    ? Colors.redAccent
                    : Colors.grey,
                width: 3.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: _cameraPreviewWidget(),
              ),
            ),
          ),

          // Positioned(
          //   bottom: 0,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       _captureControlRowWidget(),
          //       _modeControlRowWidget(),
          //       Padding(
          //         padding: const EdgeInsets.all(5.0),
          //         child: Row(
          //           children: <Widget>[
          //             _cameraTogglesRowWidget(),
          //             _thumbnailWidget(),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: IconWithRoundGradient(
                  size: 22,
                  iconData: Icons.close_rounded,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    ClipOval(
                      child: InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        overlayColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onTap: () {
                          if (isPhoto == true) {
                            onTakePictureButtonPressed();
                          }

                          if (isPhoto == false && isStartRecording == false) {
                            onVideoRecordButtonPressed();
                          }
                          if (isStartRecording == true) {
                            onPauseButtonPressed();

                            isPaused = true;
                          }
                          if (isPaused == true) {
                            onResumeButtonPressed();

                            isPaused = false;
                          }
                        },
                        child: Container(
                          height: 85,
                          width: 85,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppConstants.primaryColor, // Border color
                              width: 5.0, // Border width
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.all(isStartRecording ? 13.0 : 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppConstants.primaryColor,
                                  borderRadius: BorderRadius.circular(
                                      isStartRecording
                                          ? AppConstants.defaultNumericValue
                                          : AppConstants.defaultNumericValue *
                                              3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // isStartRecording || isPaused
                    //     ? ClipOval(
                    //         child: InkWell(
                    //           focusColor: Colors.transparent,
                    //           hoverColor: Colors.transparent,
                    //           highlightColor: Colors.transparent,
                    //           overlayColor:
                    //               MaterialStateProperty.all(Colors.transparent),
                    //           onTap: () async {

                    //                     controller!.value.isRecordingVideo
                    //                 ? onStopButtonPressed()
                    //                 : null;
                    //           },
                    //           child: Container(
                    //             height: 45,
                    //             width: 45,
                    //             decoration: BoxDecoration(
                    //               border: Border.all(
                    //                 color: AppConstants
                    //                     .primaryColor, // Border color
                    //                 width: 5.0, // Border width
                    //               ),
                    //               shape: BoxShape.circle,
                    //             ),
                    //             child: Padding(
                    //               padding: EdgeInsets.all(10.0),
                    //               child: Container(
                    //                 decoration: BoxDecoration(
                    //                     color: AppConstants.primaryColor,
                    //                     borderRadius: BorderRadius.circular(
                    //                         AppConstants.defaultNumericValue)),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       )
                    //     : SizedBox(
                    //         width: 10,
                    //       ),

                    IconWithRoundGradient(
                      iconData: Icons.check_circle_rounded,
                      size: 20,
                      onTap: () async {
                        if (isStartRecording || isPaused) {
                          onStopButtonPressed();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.transparent,
                      isScrollable: true,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                          index == 0 ? isPhoto = true : isPhoto = false;
                          // isPhoto = !isPhoto;
                        });
                        // if (index == 0) {
                        //   LamatCamera.imageCapture;
                        // } else {
                        //   LamatCamera.videoCapture;
                        // }

                        if (kDebugMode) {
                          print(isPhoto.toString());
                        }
                      },
                      tabs: [
                        SizedBox(
                          height: 30,
                          width: 75,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: _currentIndex == 1
                                    ? Colors.transparent
                                    : AppConstants.primaryColor
                                        .withOpacity(.2)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(LocaleKeys.camera.tr()),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                          width: 70,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: _currentIndex == 0
                                    ? Colors.transparent
                                    : AppConstants.primaryColor
                                        .withOpacity(.2)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(LocaleKeys.video.tr()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              onTapDown: (TapDownDetails details) =>
                  onViewFinderTap(details, constraints),
            );
          }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() async {
    takePicture().then((XFile? file) async {
      if (mounted) {
        setState(() {
          imageFile = file;
          videoController?.dispose();
          videoController = null;
        });
        if (file != null) {
          showInSnackBar('Picture saved to ${file.path}');
        }
      }
      if (imageFile != null) {
        http.Response response = await http.get(Uri.parse(imageFile!.path));
        final editedImage = await showModalBottomSheet(
          context: context,
          builder: (context) => ImageEditor(
            image: response.bodyBytes,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          backgroundColor: AppConstants.backgroundColor,
          isScrollControlled: true,
        );
        widget.onTakeFileWeb(
            editedImage, false, imageFile!.name, File(imageFile!.path));
      }
    });
  }

  void onFlashModeButtonPressed() {
    if (_flashModeControlRowAnimationController.value == 1) {
      _flashModeControlRowAnimationController.reverse();
    } else {
      _flashModeControlRowAnimationController.forward();
      _exposureModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onExposureModeButtonPressed() {
    if (_exposureModeControlRowAnimationController.value == 1) {
      _exposureModeControlRowAnimationController.reverse();
    } else {
      _exposureModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _focusModeControlRowAnimationController.reverse();
    }
  }

  void onFocusModeButtonPressed() {
    if (_focusModeControlRowAnimationController.value == 1) {
      _focusModeControlRowAnimationController.reverse();
    } else {
      _focusModeControlRowAnimationController.forward();
      _flashModeControlRowAnimationController.reverse();
      _exposureModeControlRowAnimationController.reverse();
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetExposureModeButtonPressed(ExposureMode mode) {
    setExposureMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Exposure mode set to ${mode.toString().split('.').last}');
    });
  }

  void onSetFocusModeButtonPressed(FocusMode mode) {
    setFocusMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Focus mode set to ${mode.toString().split('.').last}');
    });
  }

  void onVideoRecordButtonPressed() {
    debugPrint('Start Video Recording');
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {
          isStartRecording = true;
        });
      }
    });
  }

  Future<void> onStopButtonPressed() async {
    debugPrint('Stop Video Recording');
    stopVideoRecording().then((XFile? file) async {
      if (mounted) {
        setState(() {
          videoFile = file;
          isStartRecording = false;
          isPaused = false;
        });
      }
      if (file != null) {
        showInSnackBar('Video recorded to ${file.path}');

        debugPrint("Sending video file to server");
        http.Response response = await http.get(Uri.parse(file.path));
        debugPrint("Got VideoBytes");
        widget.onTakeFileWeb(
            response.bodyBytes, true, file.name, File(file.path));
      }
    });
  }

  Future<void> onPausePreviewButtonPressed() async {
    debugPrint('Pause Camera Preview');

    if (controller == null || !controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (controller!.value.isPreviewPaused) {
      await controller!.resumePreview();
    } else {
      await controller!.pausePreview();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onPauseButtonPressed() {
    debugPrint('Pause Video Recording');
    pauseVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording paused');
    });
  }

  void onResumeButtonPressed() {
    debugPrint('Resume Video Recording');
    resumeVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
      }
      showInSnackBar('Video recording resumed');
    });
  }

  Future<void> startVideoRecording() async {
    debugPrint('Start Video Recording');

    if (controller == null || !controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (controller!.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    debugPrint('Stop Video Recording');

    if (controller == null || !controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      return controller!.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    debugPrint('Pause Video Recording');

    if (controller == null || !controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    debugPrint('Resume Video Recording');

    if (controller == null || !controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setExposureMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setExposureOffset(double offset) async {
    if (controller == null) {
      return;
    }

    setState(() {});
    try {
      offset = await controller!.setExposureOffset(offset);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFocusMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

/// CameraApp is the Main Application.
// class CameraApp extends StatelessWidget {
//   /// Default Constructor
//   const CameraApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: CameraWebHome(),
//     );
//   }
// }

// List<CameraDescription> _cameras = <CameraDescription>[];

// Future<void> main() async {
//   // Fetch the available cameras before initializing the app.
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     _cameras = await availableCameras();
//   } on CameraException catch (e) {
//     _logError(e.code, e.description);
//   }
//   runApp(const CameraApp());
// }
