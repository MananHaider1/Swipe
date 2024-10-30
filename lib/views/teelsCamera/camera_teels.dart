// ignore_for_file: library_private_types_in_public_api, prefer_typing_uninitialized_variables, depend_on_referenced_packages, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_local_variable

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
// import 'package:lamatdating/lamat_camera.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/sounds_model.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';
import 'package:lamatdating/views/dialog/simple_dialog.dart';
import 'package:lamatdating/views/music/main_music_screen.dart';
import 'package:lamatdating/views/teelsCamera/preview_teel.dart';

class CameraScreenTeels extends ConsumerStatefulWidget {
  final String? soundUrl;
  final String? soundTitle;
  final String? soundId;

  const CameraScreenTeels(
      {super.key, this.soundUrl, this.soundTitle, this.soundId});

  @override
  _CameraScreenTeelsState createState() => _CameraScreenTeelsState();
}

class _CameraScreenTeelsState extends ConsumerState<CameraScreenTeels>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool isFlashOn = false;
  bool isFront = false;
  bool isSelected15s = true;
  bool isMusicSelect = false;
  bool isStartRecording = false;
  bool isShowPlayer = false;
  String? soundId = '';
  String? imagePath;

  var videoController;

  Timer? timer;
  double currentSecond = 0;
  double currentPercentage = 0;
  int currentTime = 0;
  double totalSeconds = 15;

  AudioPlayer? _audioPlayer;

  SoundData? _selectedMusic;
  String? _localMusic;

  bool _isFlashlightOn = false;

  late CameraController _cameraController;
  late Future<void> _cameraFuture;

  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _cameraFuture = _initializeCamera();
    // bool _isPhoto = isPhoto;
    _tabController = TabController(length: 2, vsync: this);
    if (widget.soundUrl != null) {
      soundId = widget.soundId;
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
      downloadMusic();
    }
    // const MethodChannel(ConstRes.lamatCamera)
    //     .setMethodCallHandler((payload) async {
    //   log('🙌${payload.toString()}');
    //   _isPhoto
    //       ? gotoPreviewScreenPhoto(payload.arguments.toString())
    //       : gotoPreviewScreen(payload.arguments.toString());
    //   return;
    // });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController =
        CameraController(cameras.first, ResolutionPreset.medium);
    return _cameraController.initialize();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    timer?.cancel();
    _cameraController.dispose();
    _audioPlayer?.release();
    _audioPlayer?.dispose();
    _unbindBackgroundIsolate();
    super.dispose();
  }

  final Map<String, dynamic> creationParams = <String, dynamic>{};
  final FlutterVideoInfo _flutterVideoInfo = FlutterVideoInfo();
  int _currentIndex = 0;
  int cameraPressed = 1;
  int videoPressed = 0;
  bool isPhoto = true;

  @override
  Widget build(BuildContext context) {
    // final myLoadingProviderProvider = ref.watch(myLoadingProvider);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: FutureBuilder(
            future: _cameraFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error initializing camera: ${snapshot.error}');
                }
                return Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: CameraPreview(_cameraController),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 35, right: 20, left: 20),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.white,
                              value: currentPercentage / 100,
                            ),
                          ),
                        ),
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
                      top: 65,
                      right: 65,
                      left: 65,
                      child: Visibility(
                        visible: isMusicSelect,
                        child: Text(
                          widget.soundTitle != null
                              ? widget.soundTitle!
                              : _selectedMusic != null
                                  ? _selectedMusic!.soundTitle!
                                  : '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: IconWithRoundGradient(
                              size: 20,
                              iconData: !isFlashOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              onTap: () async {
                                isFlashOn = !isFlashOn;
                                setState(() {});
                                _toggleFlashlight();
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: IconWithRoundGradient(
                              iconData: Icons.flip_camera_android_rounded,
                              size: 20,
                              onTap: () async {
                                isFront = !isFront;
                                _flipCamera();
                                setState(() {});
                              },
                            ),
                          ),
                          Visibility(
                            visible: soundId == null || soundId!.isEmpty,
                            child: InkWell(
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              onTap: () => showModalBottomSheet(
                                context: context,
                                barrierColor:
                                    AppConstants.primaryColor.withOpacity(.3),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        AppConstants.defaultNumericValue),
                                    topRight: Radius.circular(
                                        AppConstants.defaultNumericValue),
                                  ),
                                ),
                                backgroundColor: AppConstants.backgroundColor,
                                builder: (context) => MainMusicScreen(
                                  (data, localMusic) async {
                                    isMusicSelect = true;
                                    _selectedMusic = data;
                                    _localMusic = localMusic;
                                    soundId = data?.soundId.toString();
                                    setState(() {});
                                  },
                                ),
                                isScrollControlled: true,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: ImageWithRoundGradient(icMusic, 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Visibility(
                            visible: !isMusicSelect,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () {
                                    setState(() {
                                      isSelected15s = true;
                                      totalSeconds = 15;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected15s
                                          ? Colors.white54
                                          : Colors.black54,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    height: 28,
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        AppRes.fiftySecond,
                                        style: TextStyle(
                                          color: isSelected15s
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () {
                                    setState(() {
                                      isSelected15s = false;
                                      totalSeconds = 30;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: isSelected15s
                                            ? Colors.black54
                                            : Colors.white54,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                    height: 28,
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        AppRes.thirtySecond,
                                        style: TextStyle(
                                          color: isSelected15s
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 40,
                                height: isMusicSelect ? 0 : 40,
                                child: IconWithRoundGradient(
                                  iconData: Icons.image,
                                  size: isMusicSelect ? 0 : 20,
                                  onTap: () {
                                    showFilePicker();
                                  },
                                ),
                              ),
                              ClipOval(
                                child: InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  onTap: () async {
                                    isPhoto
                                        ? {takePhoto()}
                                        : {
                                            isStartRecording =
                                                !isStartRecording,
                                            setState(() {}),
                                            startProgress()
                                          };
                                  },
                                  child: Container(
                                    height: 85,
                                    width: 85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppConstants
                                            .primaryColor, // Border color
                                        width: 5.0, // Border width
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                          isStartRecording ? 13.0 : 10.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppConstants.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                                isStartRecording
                                                    ? AppConstants
                                                        .defaultNumericValue
                                                    : AppConstants
                                                            .defaultNumericValue *
                                                        3)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              isStartRecording
                                  ? const SizedBox(
                                      height: 38,
                                      width: 38,
                                    )
                                  : IconWithRoundGradient(
                                      iconData: Icons.check_circle_rounded,
                                      size: 20,
                                      onTap: () async {
                                        if (soundId != null &&
                                            soundId!.isNotEmpty &&
                                            Platform.isIOS) {
                                          // await LamatCamera.mergeAudioVideo(
                                          //     _localMusic ?? '');
                                        } else {
                                          _stopRecordingVideo();
                                        }
                                      },
                                    ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TabBar(
                            controller: _tabController,
                            tabAlignment: TabAlignment.center,
                            dividerColor: Colors.transparent,
                            indicatorColor: Colors.transparent,
                            isScrollable: true,
                            onTap: (index) {
                              setState(() {
                                _currentIndex = index;
                                isPhoto = !isPhoto;
                              });
                              if (index == 0) {
                                setState(() {
                                  isPhoto = true;
                                });
                                if (videoPressed == 1) {
                                  // LamatCamera.imageCapture;
                                  setState(() {
                                    videoPressed = 0;
                                  });
                                }
                              } else if (index == 1) {
                                setState(() {
                                  isPhoto = false;
                                });
                                if (videoPressed == 0) {
                                  // LamatCamera.videoCapture;
                                  setState(() {
                                    videoPressed = 1;
                                  });
                                }
                              }

                              if (kDebugMode) {
                                print(isPhoto.toString());
                              }
                            },
                            tabs: [
                              Tab(
                                height: 30,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: _currentIndex == 1
                                          ? Colors.transparent
                                          : AppConstants.primaryColor
                                              .withOpacity(.5)),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(LocaleKeys.camera.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                              Tab(
                                height: 30,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: _currentIndex == 0
                                          ? Colors.transparent
                                          : AppConstants.primaryColor
                                              .withOpacity(.5)),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(LocaleKeys.video.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(color: Colors.white)),
                                  ),
                                ),
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
                );
              }
              return const Center(child: CircularProgressIndicator());
            }));
  }

  final ReceivePort _port = ReceivePort();

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      int status = data[1];

      if (status == 3) {
        Navigator.pop(context);
        _audioPlayer = AudioPlayer();
        isMusicSelect = true;
        _localMusic = '${_localMusic!}/${widget.soundUrl!}';
        setState(() {});
      }
    });
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
      if (_isFlashlightOn) {
        _cameraController.setFlashMode(FlashMode.torch);
      } else {
        _cameraController.setFlashMode(FlashMode.off);
      }
    });
  }

  // void _flipCamera() async {
  //   final cameras = await availableCameras();
  //   if (cameras.length > 1) {
  //     final newCamera = cameras[_cameraController.description.lensDirection ==
  //             CameraLensDirection.front
  //         ? 1
  //         : 0];
  //     await _cameraController.dispose();
  //     _cameraController = CameraController(newCamera, ResolutionPreset.medium);
  //     await _cameraController.initialize();
  //     setState(() {});
  //   } else {
  //     EasyLoading.showError(LocaleKeys.devicehas1camera.tr());
  //   }
  // }

  void _flipCamera() async {
    // final cameras = await availableCameras();
    if (cameras.length <= 1) return; // Early exit if only 1 camera

    final newCamera = CameraLensDirection.values.firstWhere(
      (lensDir) => lensDir != _cameraController.description.lensDirection,
      // orElse: (_) => null,
    );

    // ignore: unnecessary_null_comparison
    if (newCamera == null) return; // Early exit if no opposite camera

    await _cameraController.dispose();
    _cameraController = CameraController(
        cameras.firstWhere((camera) => camera.lensDirection == newCamera),
        ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {});
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await (getExternalStorageDirectory())
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  void downloadMusic() async {
    _localMusic =
        (await _findLocalPath()) + Platform.pathSeparator + ConstRes.camera;
    final savedDir = Directory(_localMusic!);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    if (File(_localMusic! + widget.soundUrl!).existsSync()) {
      File(_localMusic! + widget.soundUrl!).deleteSync();
    }
    await FlutterDownloader.enqueue(
      url: widget.soundUrl!,
      savedDir: _localMusic!,
      showNotification: false,
      openFileFromNotification: false,
    );
    showDialog(
      context: context,
      builder: (context) => const LoaderDialog(),
    );
  }

  Future<void> cropImage(String path) async {
    final File imageFile = File(path);
    final Uint8List bytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);

    final double deviceAspectRatio = MediaQuery.of(context).size.aspectRatio;
    final double imageAspectRatio = image!.width / image.height;

    int cropWidth, cropHeight;
    if (deviceAspectRatio > imageAspectRatio) {
      cropWidth = image.width;
      cropHeight = image.width ~/ deviceAspectRatio;
    } else {
      cropWidth = (image.height * deviceAspectRatio).toInt();
      cropHeight = image.height;
    }

    final img.Image croppedImage =
        img.copyCrop(image, x: 0, y: 0, width: cropWidth, height: cropHeight);
    final img.Image resizedImage = img.copyResize(croppedImage,
        width: cropWidth * 10, height: cropHeight * 10);

    final File croppedFile = await imageFile.copy('${imageFile.path}_cropped');
    final finalFile =
        await croppedFile.writeAsBytes(img.encodeJpg(resizedImage));
    setState(() {
      imagePath = croppedFile.path;
    });
  }

  Future<void> takePhoto() async {
    try {
      final XFile image = await _cameraController.takePicture();
      await cropImage(File(image.path).path);
      (soundId != null && soundId != '')
          ? gotoPreviewScreenPhoto(imagePath!)
          : EasyLoading.showError("Please select sound");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _startRecordingVideo() async {
    try {
      await _cameraController
          .startVideoRecording(); // No need to capture the returned XFile
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _stopRecordingVideo() async {
    try {
      final XFile video = await _cameraController.stopVideoRecording();

      gotoPreviewScreen(video.path);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void startProgress() async {
    if (timer == null) {
      final startTime = DateTime.now();

      timer = Timer.periodic(const Duration(milliseconds: 100), (time) async {
        final elapsed = DateTime.now().difference(startTime);
        currentSecond = elapsed.inMilliseconds / 1000.0;
        currentPercentage = (currentSecond / totalSeconds) * 100;
        if (currentSecond >= totalSeconds) {
          timer?.cancel();
          timer = null;
          if (soundId != null && soundId!.isNotEmpty && Platform.isIOS) {
            // await LamatCamera.mergeAudioVideo(_localMusic ?? '');
          } else {
            _stopRecordingVideo();
          }
        }
        setState(() {});
      });
    } else {
      if (isStartRecording) {
        timer!.cancel();
        timer = null;

        final startTime = DateTime.now();

        timer = Timer.periodic(const Duration(milliseconds: 100), (time) async {
          final elapsed = DateTime.now().difference(startTime);
          currentSecond = elapsed.inMilliseconds / 1000.0;
          currentPercentage = (currentSecond / totalSeconds) * 100;
          if (currentSecond >= totalSeconds) {
            timer?.cancel();
            timer = null;
            if (soundId != null && soundId!.isNotEmpty && Platform.isIOS) {
              // await LamatCamera.mergeAudioVideo(_localMusic ?? '');
            } else {
              _stopRecordingVideo();
            }
          }
          setState(() {});
        });
      } else {
        timer!.cancel();
        timer = null;
      }
    }
    if (isStartRecording) {
      if (currentSecond == 0) {
        if (soundId != null && soundId!.isNotEmpty) {
          _audioPlayer = AudioPlayer(playerId: '1');
          await _audioPlayer!.play(
            DeviceFileSource(_localMusic!),
            mode: PlayerMode.mediaPlayer,
            ctx:   AudioContext(
              android: const AudioContextAndroid(isSpeakerphoneOn: true),
              iOS: AudioContextIOS(
                  category: AVAudioSessionCategory.playAndRecord,
               options: const {
                    AVAudioSessionOptions.allowAirPlay,
                    AVAudioSessionOptions.allowBluetooth,
                    AVAudioSessionOptions.allowBluetoothA2DP,
                    AVAudioSessionOptions.defaultToSpeaker,
                  }
                  ),
            ),
          );
          var totalSecond = await Future.delayed(
              const Duration(milliseconds: 300),
              () => _audioPlayer!.getDuration());
          totalSeconds = totalSecond!.inSeconds.toDouble();
          timer?.cancel();
          final startTime = DateTime.now();

          timer =
              Timer.periodic(const Duration(milliseconds: 100), (time) async {
            final elapsed = DateTime.now().difference(startTime);
            currentSecond = elapsed.inMilliseconds / 1000.0;
            currentPercentage = (currentSecond / totalSeconds) * 100;
            if (currentSecond >= totalSeconds) {
              timer?.cancel();
              timer = null;
              if (soundId != null && soundId!.isNotEmpty && Platform.isIOS) {
                // await LamatCamera.mergeAudioVideo(_localMusic ?? '');
              } else {
                _stopRecordingVideo();
              }
            }
            setState(() {});
          });
        }
        _startRecordingVideo();
      } else {
        await _audioPlayer?.resume();
        await _cameraController.resumeVideoRecording();
      }
    } else {
      await _audioPlayer?.pause();
      await _cameraController.pauseVideoRecording();
    }
  }

  void gotoPreviewScreen(String pathOfVideo) async {
    if (soundId != null && soundId!.isNotEmpty) {
      showLoader();
      String f = await _findLocalPath();
      if (!Platform.isAndroid) {
        FFmpegKit.execute(
                '-i $pathOfVideo -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
            .then(
          (returnCode) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreenTeels(
                    postVideo: pathOfVideo,
                    thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                    soundId: soundId,
                    isPhoto: false),
              ),
            );
          },
        );
      } else {
        if (Platform.isAndroid && isFront) {
          await FFmpegKit.execute(
              '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
          FFmpegKit.execute(
                  "-i \"$f${Platform.pathSeparator}out1.mp4\" -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
              .then((returnCode) {
            FFmpegKit.execute(
                    '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
                .then(
              (returnCode) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreenTeels(
                        postVideo: '$f${Platform.pathSeparator}out.mp4',
                        thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                        soundId: soundId,
                        isPhoto: false),
                  ),
                );
              },
            );
          });
        } else {
          FFmpegKit.execute(
                  "-i $pathOfVideo -i $_localMusic -y -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 -shortest $f${Platform.pathSeparator}out.mp4")
              .then((returnCode) {
            FFmpegKit.execute(
                    '-i $f${Platform.pathSeparator}out.mp4 -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
                .then(
              (returnCode) {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreenTeels(
                        postVideo: '$f${Platform.pathSeparator}out.mp4',
                        thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                        soundId: soundId,
                        isPhoto: false),
                  ),
                );
              },
            );
          });
        }
      }
      return;
    }
    showLoader();
    String f = await _findLocalPath();
    String soundPath =
        '$f${Platform.pathSeparator + DateTime.now().millisecondsSinceEpoch.toString()}sound.wav';
    await FFmpegKit.execute('-i "$pathOfVideo" -y $soundPath');
    if (Platform.isAndroid && isFront) {
      await FFmpegKit.execute(
          '-i "$pathOfVideo" -y -vf hflip "$f${Platform.pathSeparator}out1.mp4"');
      FFmpegKit.execute(
              '-i "$f${Platform.pathSeparator}out1.mp4" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
          .then(
        (returnCode) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreenTeels(
                  postVideo: '$f${Platform.pathSeparator}out1.mp4',
                  thumbNail: '$f${Platform.pathSeparator}thumbNail.png',
                  sound: soundPath,
                  isPhoto: false),
            ),
          );
        },
      );
    } else {
      FFmpegKit.execute(
              '-i "$pathOfVideo" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
          .then(
        (returnCode) {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreenTeels(
                  postVideo: pathOfVideo,
                  thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                  sound: soundPath,
                  isPhoto: false),
            ),
          );
        },
      );
    }
  }

  Future<File> compressImage(XFile xfile) async {
    // Convert XFile to File
    File file = File(xfile.path);

    final filePath = file.absolute.path;

    // Create output file path
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";

    var compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 20,
    );

    File xcompressed = File(compressed!.path);

    return xcompressed;
  }

  void gotoPreviewScreenPhoto(String pathOfPhoto) async {
    if (soundId != null && soundId!.isNotEmpty) {
      showLoader();

      if (!Platform.isAndroid) {
        {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreenTeels(
                  postVideo: pathOfPhoto,
                  thumbNail: pathOfPhoto,
                  soundId: soundId,
                  isPhoto: isPhoto),
            ),
          );
        }
      } else {
        if (Platform.isAndroid && isFront) {
          {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreenTeels(
                    postVideo: pathOfPhoto,
                    thumbNail: pathOfPhoto,
                    soundId: soundId,
                    isPhoto: isPhoto),
              ),
            );
          }
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreenTeels(
                  postVideo: pathOfPhoto,
                  thumbNail: pathOfPhoto,
                  soundId: soundId,
                  isPhoto: isPhoto),
            ),
          );
        }
      }
      // showLoader();
      return;
    } else {
      EasyLoading.showError(LocaleKeys.selectsoundfirst.tr());
    }
  }

  void showFilePicker() async {
    if (!kIsWeb) {
      if (Platform.isIOS && isPhoto == false) {
        ImagePicker()
            .pickVideo(
                source: ImageSource.gallery,
                maxDuration: const Duration(minutes: 1))
            .then(
          (value) async {
            if (value != null && value.path.isNotEmpty) {
              VideoData? a = await (_flutterVideoInfo.getVideoInfo(value.path));
              if (a!.filesize! / 1000000 > 40) {
                showDialog(
                  context: context,
                  builder: (mContext) => SimpleCustomDialog(
                    title: LocaleKeys.tooLargeVideo.tr(),
                    message: LocaleKeys
                        .thisVideoIsGreaterThan50MbnpleaseSelectAnother
                        .tr(),
                    negativeText: LocaleKeys.cancel.tr(),
                    positiveText: LocaleKeys.selectAnother.tr(),
                    onButtonClick: (clickType) {
                      if (clickType == 1) {
                        showFilePicker();
                      } else {}
                      Navigator.pop(context);
                    },
                  ),
                );
                return;
              }
              if (a.duration! / 1000 > 60) {
                showDialog(
                  context: context,
                  builder: (mContext) => SimpleCustomDialog(
                    title: LocaleKeys.tooLongVideo,
                    message: LocaleKeys
                        .thisVideoIsGreaterThan1MinnpleaseSelectAnother
                        .tr(),
                    negativeText: LocaleKeys.cancel.tr(),
                    positiveText: LocaleKeys.selectAnother.tr(),
                    onButtonClick: (clickType) {
                      if (clickType == 1) {
                        showFilePicker();
                      } else {}
                    },
                  ),
                );
                return;
              }
              showLoader();
              String f = await _findLocalPath();
              await FFmpegKit.execute(
                  '-i "${value.path}" -y $f${Platform.pathSeparator}sound.wav');

              FFmpegKit.execute(
                      '-i "${value.path}" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
                  .then(
                (returnCode) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewScreenTeels(
                          postVideo: value.path,
                          thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                          sound: "$f${Platform.pathSeparator}sound.wav",
                          isPhoto: isPhoto),
                    ),
                  );
                },
              );
            } else {}
          },
        );
      } else if (Platform.isAndroid && isPhoto == false) {
        final ImagePicker _picker = ImagePicker();
        // Pick an image
        final XFile? result =
            await _picker.pickVideo(source: ImageSource.gallery);
        if (result == null) return;
        VideoData? a = await (_flutterVideoInfo.getVideoInfo(result.path));
        if (a!.filesize! / 1000000 > 40) {
          showDialog(
            context: context,
            builder: (mContext) => SimpleCustomDialog(
              title: LocaleKeys.tooLargeVideo.tr(),
              message: LocaleKeys.thisVideoIsGreaterThan50MbnpleaseSelectAnother
                  .tr(),
              negativeText: LocaleKeys.cancel.tr(),
              positiveText: LocaleKeys.selectAnother.tr(),
              onButtonClick: (clickType) {
                if (clickType == 1) {
                  showFilePicker();
                } else {}
                Navigator.pop(context);
              },
            ),
          );
          return;
        }
        if (a.duration! / 1000 > 60) {
          showDialog(
            context: context,
            builder: (mContext) => SimpleCustomDialog(
              title: LocaleKeys.tooLongVideo.tr(),
              message: LocaleKeys.thisVideoIsGreaterThan1MinnpleaseSelectAnother
                  .tr(),
              negativeText: LocaleKeys.cancel.tr(),
              positiveText: LocaleKeys.selectAnother.tr(),
              onButtonClick: (clickType) {
                if (clickType == 1) {
                  showFilePicker();
                } else {}
              },
            ),
          );
          return;
        }
        showLoader();
        String f = await _findLocalPath();
        await FFmpegKit.execute(
            '-i "${result.path}" -y $f${Platform.pathSeparator}sound.wav');

        FFmpegKit.execute(
                '-i "${result.path}" -y -ss 00:00:01.000 -vframes 1 "$f${Platform.pathSeparator}thumbNail.png"')
            .then(
          (returnCode) {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreviewScreenTeels(
                    postVideo: result.path,
                    thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
                    sound: "$f${Platform.pathSeparator}sound.wav",
                    isPhoto: isPhoto),
              ),
            );
          },
        );
      } else if (Platform.isAndroid && isPhoto == true) {
        final ImagePicker _picker = ImagePicker();
        // Pick an image
        final XFile? result =
            await _picker.pickImage(source: ImageSource.gallery);
        if (result == null) return;

        File image = File(result.path); // Replace with your image file path
        int bytes = (await image.readAsBytes()).lengthInBytes;
        double kb = bytes / 1024;
        double mb = kb / 1024;

        if (mb > 40) {
          showDialog(
            context: context,
            builder: (mContext) => SimpleCustomDialog(
              title: LocaleKeys.imageTooLarge.tr(),
              message: LocaleKeys.filesizeexceeded.tr(),
              negativeText: LocaleKeys.cancel.tr(),
              positiveText: LocaleKeys.selectAnother.tr(),
              onButtonClick: (clickType) {
                if (clickType == 1) {
                  showFilePicker();
                } else {}
                Navigator.pop(context);
              },
            ),
          );
          return;
        }

        gotoPreviewScreenPhoto(result.path);
      } else {
        final imagePath = await pickMedia(isVideo: true);
        {
          if (imagePath != null) {
            MaterialPageRoute(
              builder: (context) => PreviewScreenTeels(
                  postVideo: imagePath,
                  thumbNail: imagePath,
                  sound: "",
                  isPhoto: isPhoto),
            );
            // Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => PreviewScreenTeels(
            //             postVideo: value.path,
            //             thumbNail: "$f${Platform.pathSeparator}thumbNail.png",
            //             sound: "$f${Platform.pathSeparator}sound.wav",
            //             isPhoto: isPhoto),
            //       ),
            //     );
          }
        }
      }
    }
  }

  void showLoader() {
    showDialog(
      context: context,
      builder: (context) => const LoaderDialog(),
    );
  }
}

class IconWithRoundGradient extends StatelessWidget {
  final IconData iconData;
  final double size;
  final Function? onTap;

  const IconWithRoundGradient(
      {super.key, required this.iconData, required this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onTap: () {
          onTap?.call();
        },
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(gradient: AppConstants.defaultGradient),
          child: Icon(
            iconData,
            color: Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }
}

class ImageWithRoundGradient extends StatelessWidget {
  final String imageData;
  final double padding;

  const ImageWithRoundGradient(this.imageData, this.padding, {super.key});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(gradient: AppConstants.defaultGradient),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Image(
            image: AssetImage(imageData),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
