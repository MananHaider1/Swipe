// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/status/components/VideoPicker/vid_picker.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HybridDocumentPicker extends ConsumerStatefulWidget {
  const HybridDocumentPicker(
      {super.key,
      required this.title,
      required this.prefs,
      required this.callback,
      this.profile = false});

  final String title;
  final Function callback;
  final SharedPreferences prefs;
  final bool profile;

  @override
  HybridDocumentPickerState createState() => HybridDocumentPickerState();
}

class HybridDocumentPickerState extends ConsumerState<HybridDocumentPicker> {
  File? _docFile;

  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  void captureFile() async {
    final observer = ref.watch(observerProvider);
    error = null;
    try {
      var file = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (file != null) {
        _docFile = File(file.paths[0]!);

        setState(() {});
        if (_docFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(_docFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _docFile = null;
          });
        } else {}
      }
    } catch (e) {
      Lamat.toast('Cannot Send this Document type');
      Navigator.of(this.context).pop();
    }
  }

  Widget _buildDoc() {
    if (_docFile != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.file_copy_rounded,
              size: 100, color: Color.fromARGB(255, 219, 199, 166)),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: Text(basename(_docFile!.path).toString(),
                style: const TextStyle(
                  fontSize: 14.0,
                  color: AppConstants.lamatGrey,
                )),
          ),
        ],
      );
    } else {
      return const Text("Choose a File to start",
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
            actions: _docFile != null
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
                          widget.callback(_docFile).then((imageUrl) {
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
                        : _buildDoc())),
            _buildButtons(context)
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
                    ))
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 60.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(const Key('retake'), Icons.add, () async {
                final info = DeviceInfoPlugin();
                final androidInfo = await info.androidInfo;
                final apiLevel = androidInfo.version.sdkInt;
                if (apiLevel >= 33) {
                  Lamat.checkAndRequestPermission(!kIsWeb
                          ? Platform.isIOS
                              ? Permission.mediaLibrary
                              : Permission.storage
                          : Permission.storage)
                      .then((res) {
                    if (res) {
                      captureFile();
                    } else {
                      Lamat.showRationale(
                        "Permission to access Storage need to Select File.",
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OpenSettings(
                                    prefs: widget.prefs,
                                  )));
                    }
                  });
                } else {
                  Lamat.checkAndRequestPermission(!kIsWeb
                          ? Platform.isIOS
                              ? Permission.mediaLibrary
                              : Permission.storage
                          : Permission.storage)
                      .then((res) {
                    if (res) {
                      captureFile();
                    } else {
                      Lamat.showRationale(
                        "Permission to access Storage need to Select File.",
                      );
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OpenSettings(
                                    prefs: widget.prefs,
                                  )));
                    }
                  });
                }
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return Expanded(
      child: IconButton(
          key: key,
          icon: Icon(icon, size: 30.0),
          color: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          onPressed: onPressed as void Function()?),
    );
  }
}
