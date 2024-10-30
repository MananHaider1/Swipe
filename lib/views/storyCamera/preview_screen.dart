// ignore_for_file: library_private_types_in_public_api, avoid_web_libraries_in_flutter, use_build_context_synchronously

import 'dart:io';

// import 'package:lamatdating/views/storyCamera/edit_video.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import "package:universal_html/html.dart" as h;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:lamatdating/views/storyCamera/upload_screen.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final SharedPreferences prefs;
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final String? soundId;
  final bool? isPhoto;
  final h.File? videoWeb;
  final h.File? photoWeb;
  final h.File? thumbNailWeb;

  const PreviewScreen(
      {super.key,
      required this.prefs,
      this.postVideo,
      this.thumbNail,
      this.sound,
      this.soundId,
      this.isPhoto,
      this.thumbNailWeb,
      this.photoWeb,
      this.videoWeb});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  VideoPlayerController? _controller;
  UploadScreenStory? uploadScreen;

  Uint8List? imageData;
  File? fileImg;

  bool isEdited = false;

  @override
  void initState() {
    uploadScreen = UploadScreenStory(
        postVideo: widget.postVideo,
        thumbNail: widget.thumbNail,
        soundId: widget.soundId,
        sound: widget.sound,
        isPhoto: widget.isPhoto);
    if (kDebugMode) {
      print(widget.postVideo);
    }
    if (widget.isPhoto == false && !kIsWeb) {
      _controller = VideoPlayerController.file(File(widget.postVideo!));
      _controller?.addListener(() {
        setState(() {});
      });
      _controller?.setLooping(true);
      _controller?.initialize().then((_) => {setState(() {})});
      _controller?.play();
    }
    super.initState();

    widget.isPhoto == true ? _openImageEditor() : {};
  }

  void _openImageEditor() async {
    // Assuming you have a function to handle image selection and editing
    final img2Bytes = !kIsWeb
        ? await File(widget.postVideo!).readAsBytes()
        : await convertFileToBytes(widget.photoWeb!);

    final editedImage = (!Responsive.isDesktop(context))
        ? await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImageEditor(
                image: img2Bytes,
              ),
            ),
          )
        : {
            Navigator.pop(context),
            Navigator.pop(context),
            ref.invalidate(arrangementProvider),
            updateCurrentIndex(ref, 10),
            ref.read(arrangementProviderExtend)
          };

    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      final File file = File('${tempDir.path}/temp-edit.jpg');
      fileImg = await file.writeAsBytes(editedImage).then((value) {
        if (kDebugMode) {
          print(
            "FILE: ${value.path}",
          );
        }
        return value;
      });
    }
    // setState(() {
    //   isEdited = true;
    // });

    // if (editedImage != null) {
    //   fileImg = file;

    // }

    // setState(() {
    //   isEdited = true;
    //   uploadScreen = UploadScreen(
    //       postVideo: !kIsWeb ? fileImg!.path : null,
    //       videoWeb: !kIsWeb ? null : widget.videoWeb,
    //       photoWeb: !kIsWeb ? null : h.File(editedImage, widget.photoWeb!.name),
    //       thumbNail: !kIsWeb ? widget.thumbNail : null,
    //       thumbNailWeb:
    //           !kIsWeb ? null : h.File(editedImage, widget.thumbNailWeb!.name),
    //       soundId: widget.soundId,
    //       sound: widget.sound,
    //       isPhoto: widget.isPhoto);
    // });
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: uploadScreen)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      backgroundColor: AppConstants.backgroundColor,
      isScrollControlled: true,
    );
  }

  // Future<double> _getImageRatio(String imagePath) async {
  //   final Uint8List bytes = await File(imagePath).readAsBytes();
  //   final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  //   final ui.FrameInfo frameInfo = await codec.getNextFrame();
  //   return frameInfo.image.width / frameInfo.image.height;
  // }

  // Future<double> _getImageRatio(String imagePath) async {
  //   final ByteData data = await rootBundle.load(imagePath);
  //   final ui.Codec codec =
  //       await ui.instantiateImageCodec(data.buffer.asUint8List());
  //   final ui.FrameInfo frameInfo = await codec.getNextFrame();
  //   return frameInfo.image.width / frameInfo.image.height;
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    final preffs = ref.watch(sharedPreferences).value;
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 0,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   systemOverlayStyle: SystemUiOverlayStyle.dark,
      // ),
      backgroundColor: Teme.isDarktheme(preffs!)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: Stack(
        children: [
          (widget.isPhoto == false)
              ? Center(
                  child: AspectRatio(
                      aspectRatio: _controller?.value.aspectRatio ?? 2 / 3,
                      child: VideoPlayer(_controller!)),
                )
              : const SizedBox(),
          // Center(
          //     child: FutureBuilder<double>(
          //       future: isEdited
          //           ? _getImageRatio(fileImg!.path)
          //           : _getImageRatio(widget.postVideo!),
          //       builder: (context, snapshot) {
          //         if (snapshot.connectionState == ConnectionState.done) {
          //           if (snapshot.hasError) {
          //             return Text('Error: ${snapshot.error}');
          //           } else {
          //             return SizedBox(
          //               width: MediaQuery.of(context).size.width,
          //               height: MediaQuery.of(context).size.height,

          //               child: Image.file(File(widget.postVideo!),
          //                   fit: BoxFit.fitWidth),
          //             );
          //           }
          //         } else {
          //           return const Center(child: CircularProgressIndicator());
          //         }
          //       },
          //     ),
          //   ),
          if (widget.isPhoto == false)
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => SingleChildScrollView(
                      child: Container(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: uploadScreen)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  backgroundColor: AppConstants.backgroundColor,
                  isScrollControlled: true,
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: AppConstants.defaultNumericValue),
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstants.primaryColor,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // if (widget.isPhoto == false)
          // Align(
          //   alignment: Alignment.topRight,
          //   child: InkWell(
          //     focusColor: Colors.transparent,
          //     hoverColor: Colors.transparent,
          //     highlightColor: Colors.transparent,
          //     overlayColor: MaterialStateProperty.all(Colors.transparent),
          //     onTap: () async {
          //       if (widget.isPhoto == false) {
          //         if (mounted && widget.postVideo != null) {
          //           final editedVideo = await Navigator.push(
          //             context,
          //             MaterialPageRoute<void>(
          //               builder: (BuildContext context) => VidEditor(
          //                 file: File(widget.postVideo!),
          //                 isPhoto: widget.isPhoto,
          //                 soundId: widget.soundId,
          //                 thumbNail: widget.thumbNail,
          //                 sound: widget.sound,
          //                 isTeel: false,
          //               ),
          //             ),
          //           );
          //         }
          //       } else {
          //         final img2Bytes = await File(widget.postVideo!).readAsBytes();
          //         final editedImage = await Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => ImageEditor(
          //               image: img2Bytes,
          //               appBar: Teme.isDarktheme(preffs!)
          //                   ? AppConstants.backgroundColorDark
          //                   : AppConstants.backgroundColor,
          //               // bottomBarColor: Colors.blue,
          //             ),
          //           ),
          //         );
          //         final tempDir = await getTemporaryDirectory();
          //         final File file = File('${tempDir.path}/temp-edit.jpg');
          //         fileImg = await file.writeAsBytes(editedImage).then((value) {
          //           if (kDebugMode) {
          //             print(
          //               "FILE: ${value.path}",
          //             );
          //           }
          //           return value;
          //         });
          //         setState(() {
          //           isEdited = true;
          //         });

          //         // if (editedImage != null) {
          //         //   fileImg = file;

          //         // }

          //         setState(() {
          //           isEdited = true;
          //           uploadScreen = UploadScreen(
          //               postVideo: fileImg!.path,
          //               thumbNail: widget.thumbNail,
          //               soundId: widget.soundId,
          //               sound: widget.sound,
          //               isPhoto: widget.isPhoto);
          //         });
          //         showModalBottomSheet(
          //           context: context,
          //           builder: (context) => SingleChildScrollView(
          //               child: Container(
          //                   padding: EdgeInsets.only(
          //                       bottom:
          //                           MediaQuery.of(context).viewInsets.bottom),
          //                   child: uploadScreen)),
          //           shape: const RoundedRectangleBorder(
          //             borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(15),
          //               topRight: Radius.circular(15),
          //             ),
          //           ),
          //           backgroundColor: AppConstants.backgroundColor,
          //           isScrollControlled: true,
          //         );
          //       }
          //     },
          //     child: Container(
          //       margin: EdgeInsets.only(
          //           top: MediaQuery.of(context).padding.top + 10, right: 20),
          //       height: 50,
          //       width: 50,
          //       decoration: const BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: AppConstants.primaryColor,
          //       ),
          //       child: const Icon(
          //         Icons.crop_rounded,
          //         color: Colors.white,
          //       ),
          //     ),
          //   ),
          // ),
          Padding(
            padding: EdgeInsets.only(
                left: 20, top: MediaQuery.of(context).padding.top + 18),
            child: IconWithRoundGradient(
              size: 22,
              iconData: Icons.close_rounded,
              onTap: () {
                Navigator.pop(context);
                // showDialog(
                //   context: context,
                //   builder: (mContext) => SimpleCustomDialog(
                //     title: LocaleKeys.areYouSure,
                //     message: LocaleKeys.doYouReallyWantToGoBack,
                //     negativeText: LocaleKeys.no,
                //     positiveText: LocaleKeys.yes,
                //     onButtonClick: (clickType) {
                //       if (clickType == 1) {
                //         Navigator.pop(context);
                //       } else {}
                //     },
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (widget.isPhoto == false) {
      _controller!.dispose();
    }
    _controller = null;
    super.dispose();
  }
}
