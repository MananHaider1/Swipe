// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
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

class SingleImagePicker extends ConsumerStatefulWidget {
  const SingleImagePicker(
      {super.key,
      required this.title,
      required this.prefs,
      required this.callback,
      this.profile = false});

  final String title;
  final SharedPreferences prefs;
  final Function callback;
  final bool profile;

  @override
  SingleImagePickerState createState() => SingleImagePickerState();
}

class SingleImagePickerState extends ConsumerState<SingleImagePicker> {
  File? _imageFile;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  void captureImage(ImageSource captureMode) async {
    final observer = ref.watch(observerProvider);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
        setState(() {});
        if (_imageFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(_imageFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = File(_imageFile!.path);
          });
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
      return kIsWeb ? Image.network(_imageFile!.path) : Image.file(_imageFile!);
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
                          setState(() {
                            isLoading = true;
                          });
                          widget.callback(_imageFile).then((imageUrl) {
                            Navigator.pop(context, imageUrl);
                          });
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
            _buildButtons()
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
          color: AppConstants.secondaryColor,
          onPressed: onPressed as void Function()?),
    );
  }
}
