// ignore_for_file: prefer_typing_uninitialized_variables, use_build_context_synchronously

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class StatusVideoEditor extends ConsumerStatefulWidget {
  const StatusVideoEditor({
    super.key,
    required this.title,
    required this.prefs,
    required this.callback,
  });

  final String title;
  final Function(String str, File file, double duration) callback;
  final SharedPreferences prefs;
  @override
  StatusVideoEditorState createState() => StatusVideoEditorState();
}

class StatusVideoEditorState extends ConsumerState<StatusVideoEditor> {
  File? _video;
  final videoInfo = FlutterVideoInfo();

  ImagePicker picker = ImagePicker();
  final TextEditingController textEditingController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  var info;
  String? error;

  _pickVideo() async {
    final observer = ref.watch(observerProvider);
    error = null;
    XFile? pickedFile = await (picker.pickVideo(source: ImageSource.gallery));

    _video = File(pickedFile!.path);

    if (_video!.lengthSync() / 1000000 > observer.maxFileSizeAllowedInMB) {
      error =
          'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(_video!.lengthSync() / 1000000).round()}MB';

      setState(() {
        _video = null;
      });
    } else {
      info = await videoInfo.getVideoInfo(pickedFile.path);

      setState(() {});
      _videoPlayerController = VideoPlayerController.file(_video!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
        });
    }
  }

  // This funcion will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    final observer = ref.watch(observerProvider);
    error = null;
    XFile? pickedFile = await (picker.pickVideo(source: ImageSource.camera));

    if (pickedFile != null) {
      _video = File(pickedFile.path);

      if (_video!.lengthSync() / 1000000 > observer.maxFileSizeAllowedInMB) {
        error =
            'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(_video!.lengthSync() / 1000000).round()}MB';

        setState(() {
          _video = null;
        });
      } else {
        info = await videoInfo.getVideoInfo(pickedFile.path);

        setState(() {});
        _videoPlayerController = VideoPlayerController.file(_video!)
          ..initialize().then((_) {
            setState(() {});
            _videoPlayerController.play();
          });
      }
    }
  }

  _buildVideo(BuildContext context) {
    if (_video != null) {
      return _videoPlayerController.value.isInitialized
          ? AspectRatio(
              aspectRatio: _videoPlayerController.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController),
            )
          : Container();
    } else {
      return Text("",
          style: TextStyle(
            fontSize: 18.0,
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
          ));
    }
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  const Key('retake'), Icons.video_library_rounded, () {
                Lamat.checkAndRequestPermission(!kIsWeb
                        ? Platform.isIOS
                            ? Permission.mediaLibrary
                            : Permission.storage
                        : Permission.storage)
                    .then((res) {
                  if (res) {
                    _pickVideo();
                  } else {
                    Lamat.showRationale(
                      LocaleKeys.pgv.tr(),
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OpenSettings(
                                  prefs: widget.prefs,
                                )));
                  }
                });
              }),
              _buildActionButton(const Key('upload'), Icons.photo_camera, () {
                Lamat.checkAndRequestPermission(Permission.camera).then((res) {
                  if (res) {
                    _pickVideoFromCamera();
                  } else {
                    Lamat.showRationale(
                      LocaleKeys.pcv.tr(),
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OpenSettings(
                                  prefs: widget.prefs,
                                )));
                  }
                });
              }),
            ]));
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      appBar: AppBar(
        elevation: 0.4,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 30,
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
          ),
        ),
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18,
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
          ),
        ),
        actions: _video != null
            ? <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.check,
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(widget.prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor),
                    ),
                    onPressed: () {
                      _videoPlayerController.pause();
                      widget.callback(
                          textEditingController.text.isEmpty
                              ? ''
                              : textEditingController.text,
                          _video!,
                          info.duration);
                    }),
                const SizedBox(
                  width: 8.0,
                )
              ]
            : [],
      ),
      body: Stack(children: [
        Column(children: [
          Expanded(
              child: Center(
                  child: error != null
                      ? fileSizeErrorWidget(error!)
                      : _buildVideo(context))),
          _video != null
              ? Container(
                  padding: const EdgeInsets.all(12),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Row(children: [
                    Flexible(
                      child: TextField(
                        maxLength: 100,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18.0, color: AppConstants.lamatWhite),
                        controller: textEditingController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: BorderRadius.circular(1),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                          ),
                          hoverColor: Colors.transparent,
                          focusedBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderRadius: BorderRadius.circular(1),
                            borderSide: const BorderSide(
                                color: Colors.transparent, width: 1.5),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(1),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          contentPadding: const EdgeInsets.fromLTRB(7, 4, 7, 4),
                          hintText: LocaleKeys.typeacaption.tr(),
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                    ),
                  ]),
                )
              : _buildButtons()
        ]),
        Positioned(
          child: isLoading
              ? Container(
                  color: pickTextColorBasedOnBgColorAdvanced(
                          !Teme.isDarktheme(widget.prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor)
                      .withOpacity(0.6),
                  child: const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppConstants.secondaryColor)),
                  ),
                )
              : Container(),
        )
      ]),
    );
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return Expanded(
      child: IconButton(
          key: key,
          icon: Icon(icon, size: 30.0),
          color: AppConstants.primaryColor,
          onPressed: onPressed as void Function()?),
    );
  }
}

Widget fileSizeErrorWidget(String error) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 60, color: Colors.red[300]),
          const SizedBox(
            height: 15,
          ),
          Text(error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red[300])),
        ],
      ),
    ),
  );
}
