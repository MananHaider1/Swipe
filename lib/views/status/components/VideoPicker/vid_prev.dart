// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/widgets/DownloadManager/save_image_videos_in_gallery.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class PreviewVideo extends StatefulWidget {
  final bool isdownloadallowed;
  final String filename;
  final String videourl;
  final String? id;
  final double? aspectratio;
  final SharedPreferences prefs;

  const PreviewVideo(
      {super.key,
      required this.id,
      required this.videourl,
      required this.isdownloadallowed,
      required this.filename,
      required this.prefs,
      this.aspectratio});
  @override
  PreviewVideoState createState() => PreviewVideoState();
}

class PreviewVideoState extends State<PreviewVideo> {
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  late ChewieController _chewieController;
  String videoUrl = '';
  bool isShowvideo = false;
  double? thisaspectratio = 1.14;

  @override
  void initState() {
    setState(() {
      thisaspectratio = widget.aspectratio;
    });
    super.initState();

    _videoPlayerController1 = VideoPlayerController.network(widget.videourl);
    _videoPlayerController2 = VideoPlayerController.network(widget.videourl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      allowFullScreen: true,
      showControlsOnInitialize: false,
      aspectRatio: thisaspectratio,
      autoPlay: true,
      looping: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  final GlobalKey<State> _keyLoader =
      GlobalKey<State>(debugLabel: 'qqqdseqeqsseaadqeqe');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.2,
        elevation: 0.4,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          widget.isdownloadallowed == true
              ? IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: () async {
                    _videoPlayerController1.pause();
                    GalleryDownloader.saveNetworkVideoInGallery(
                        context,
                        widget.videourl,
                        false,
                        widget.filename,
                        _keyLoader,
                        widget.prefs);
                  })
              : const SizedBox()
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: Padding(
        padding: EdgeInsets.only(
            bottom: !kIsWeb
                ? Platform.isIOS
                    ? 30
                    : 10
                : 30),
        child: Chewie(
          controller: _chewieController,
        ),
      )),
    );
  }
}
