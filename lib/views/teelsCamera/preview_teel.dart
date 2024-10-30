// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'dart:ui' as ui;

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:video_player/video_player.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/storyCamera/camera_story_page.dart';
import 'package:lamatdating/views/storyCamera/edit_video.dart';
import 'package:lamatdating/views/teelsCamera/upload_teel.dart';

class PreviewScreenTeels extends StatefulWidget {
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final String? soundId;
  final bool? isPhoto;

  const PreviewScreenTeels({
    super.key,
    this.postVideo,
    this.thumbNail,
    this.sound,
    this.soundId,
    this.isPhoto,
  });

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreenTeels> {
  VideoPlayerController? _controller;
  UploadScreenTeels? uploadScreen;

  @override
  void initState() {
    uploadScreen = UploadScreenTeels(
        postVideo: widget.postVideo,
        thumbNail: widget.thumbNail,
        soundId: widget.soundId,
        sound: widget.sound,
        isPhoto: widget.isPhoto);
    if (kDebugMode) {
      print(widget.postVideo);
    }
    if (widget.isPhoto == false) {
      _controller = VideoPlayerController.file(File(widget.postVideo!));
      _controller?.addListener(() {
        setState(() {});
      });
      _controller?.setLooping(true);
      _controller?.initialize().then((_) => {setState(() {})});
      _controller?.play();
    }
    super.initState();
  }

  Future<double> _getImageRatio(String imagePath) async {
    final Uint8List bytes = await File(imagePath).readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image.width / frameInfo.image.height;
  }

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
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 0,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   systemOverlayStyle: SystemUiOverlayStyle.dark,
      // ),
      body: Stack(
        children: [
          (widget.isPhoto == false)
              ? Center(
                  child: AspectRatio(
                      aspectRatio: _controller?.value.aspectRatio ?? 2 / 3,
                      child: VideoPlayer(_controller!)),
                )
              : Center(
                  child: FutureBuilder<double>(
                    future: _getImageRatio(widget.postVideo!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text(
                              '${LocaleKeys.error.tr()}: ${snapshot.error}');
                        } else {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              // aspectRatio: snapshot.data!,
                              child: Image.network(widget.postVideo!)
                              //               CachedNetworkImage(
                              //   imageUrl: widget.postVideo!,
                              //   placeholder: (context, url) =>
                              //       const Center(child: CircularProgressIndicator.adaptive()),
                              //   errorWidget: (context, url, error) =>
                              //       const Center(child: Icon(CupertinoIcons.photo)),
                              //   fit: BoxFit.fitWidth,
                              // )
                              );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: () {
                _controller?.pause();
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
              },
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
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: () {
                if (mounted && widget.postVideo != null) {
                  widget.isPhoto == false
                      ? Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => VidEditor(
                              file: File(widget.postVideo!),
                              isPhoto: widget.isPhoto,
                              soundId: widget.soundId,
                              thumbNail: widget.thumbNail,
                              sound: widget.sound,
                              isTeel: true,
                            ),
                          ),
                        )
                      : {};
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10, right: 20),
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryColor,
                ),
                child: const Icon(
                  Icons.crop_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
