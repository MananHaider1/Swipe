// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/views/status/components/VideoPicker/vid_picker.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusImageEditor extends ConsumerStatefulWidget {
  const StatusImageEditor({
    super.key,
    required this.title,
    required this.callback,
    required this.prefs,
  });

  final String title;
  final Function(String str, File file) callback;
  final SharedPreferences prefs;

  @override
  StatusImageEditorState createState() => StatusImageEditorState();
}

class StatusImageEditorState extends ConsumerState<StatusImageEditor> {
  File? _imageFile;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController textEditingController = TextEditingController();
  void captureImage(ImageSource captureMode) async {
    final observer = ref.watch(observerProvider);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);

        if (_imageFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(_imageFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _imageFile = null;
          });
        } else {
          setState(() {});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return CachedNetworkImage(
        imageUrl: _imageFile!.path,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator.adaptive()),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(CupertinoIcons.photo)),
        fit: BoxFit.cover,
      );
    } else {
      return const Text("Image",
          style: TextStyle(
            fontSize: 18.0,
            color: AppConstants.lamatGrey,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Lamat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
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
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            actions: _imageFile != null
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
                          widget.callback(
                              textEditingController.text.isEmpty
                                  ? ''
                                  : textEditingController.text,
                              _imageFile!);
                        }),
                    const SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          Column(children: [
            Expanded(
                child: Center(
                    child: error != null
                        ? fileSizeErrorWidget(error!)
                        : _buildImage())),
            _imageFile != null
                ? Container(
                    padding: const EdgeInsets.all(12),
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                    child: Row(children: [
                      Flexible(
                        child: TextField(
                          maxLength: int.tryParse(
                              (MaxTextlettersInStatus / 1.7).toString()),
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
                                borderSide: const BorderSide(
                                    color: Colors.transparent)),
                            contentPadding:
                                const EdgeInsets.fromLTRB(7, 4, 7, 4),
                            hintText: "Type a caption",
                            hintStyle: const TextStyle(
                                color: Colors.grey, fontSize: 16),
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
                                AppConstants.secondaryColor))),
                  )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(const Key('retake'), Icons.photo_library, () {
                Lamat.checkAndRequestPermission(Permission.storage).then((res) {
                  if (res) {
                    captureImage(ImageSource.gallery);
                  } else {
                    Lamat.showRationale(
                      "Permission to access Gallery need to select Photos",
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
                    captureImage(ImageSource.camera);
                  } else {
                    "Permission to access Camera need to select Photos";
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
