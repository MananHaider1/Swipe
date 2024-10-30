// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/status/components/VideoPicker/vid_picker.dart';
import 'package:lamatdating/providers/observer.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MultiDocumentPicker extends ConsumerStatefulWidget {
  const MultiDocumentPicker(
      {super.key,
      required this.title,
      required this.callback,
      required this.prefs,
      this.writeMessage,
      this.profile = false});

  final String title;
  final Function callback;
  final SharedPreferences prefs;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;

  @override
  MultiDocumentPickerState createState() => MultiDocumentPickerState();
}

class MultiDocumentPickerState extends ConsumerState<MultiDocumentPicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<PlatformFile> seletedFiles = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = ref.watch(observerProvider);
    if (seletedFiles.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = ref.watch(observerProvider);
    int index = seletedFiles.indexWhere((file) =>
        File(file.path!).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureMultiPageDoc(bool isAddOnly) async {
    final observer = ref.watch(observerProvider);

    error = null;

    try {
      FilePickerResult? files = await FilePicker.platform
          .pickFiles(type: FileType.any, allowMultiple: true);

      if (files != null) {
        if (files.files.length > 1) {
          seletedFiles = files.files;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (files.files.length == 1) {
          if (File(files.files[0].path!).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(File(files.files[0].path!).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              seletedFiles = files.files;
            });
          }
        }
      }
    } catch (e) {
      Lamat.toast('Cannot Send this Document type');
      Navigator.of(this.context).pop();
    }
  }

  Widget _buildSingleFile({File? file}) {
    if (file != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.yellow[900],
            size: 74,
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Text(
              basename(seletedFiles[0].path!).toString(),
              maxLines: 3,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: AppConstants.lamatGrey,
              ),
            ),
          )
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

  Widget _buildMultiDocLoading() {
    return Container(
      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor)
          .withOpacity(0.8),
      child: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currentUploadingIndex + 1}/${seletedFiles.length}',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                color: AppConstants.primaryColor),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Sending...",
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor)),
          )
        ],
      )),
    );
  }

  Widget _buildMultiDoc() {
    final observer = ref.watch(observerProvider);
    if (seletedFiles.isNotEmpty) {
      return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: seletedFiles.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: Colors.yellow[900],
                          size: 44,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            basename(seletedFiles[i].path!).toString(),
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: AppConstants.lamatBlack),
                          ),
                        )
                      ],
                    ),
                  ),
                  File(seletedFiles[i].path!).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.all(10),
                              child: Text(
                                'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\nSelected File size is - ${(File(seletedFiles[i].path!).lengthSync() / 1000000).round()}MB',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppConstants.lamatREDbuttonColor,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          seletedFiles.removeAt(i);
                          if (seletedFiles.length <= 1) {
                            mode = "single";
                          }
                        });
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // decoration: BoxDecoration(
              //     color: Colors.amber, borderRadius: BorderRadius.circular(15)),
            );
          });
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
    final observer = ref.watch(observerProvider);
    return Lamat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        appBar: AppBar(
            elevation: 0.4,
            leading: IconButton(
              onPressed: () {
                if (!isLoading) {
                  Navigator.of(context).pop();
                }
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
              seletedFiles.isNotEmpty
                  ? '${seletedFiles.length} Selected'
                  : widget.title,
              style: const TextStyle(
                fontSize: 18,
                color: AppConstants.lamatGrey,
              ),
            ),
            backgroundColor: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            actions: seletedFiles.isNotEmpty && !isLoading
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        onPressed: checkTotalNoOfFilesIfExceeded() == false
                            ? (checkIfAnyFileSizeExceeded() == false
                                ? () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    uploadEach(0);
                                  }
                                : () {
                                    Lamat.toast(
                                        'One or more file size exceeded the allowed maximum Size: ${observer.maxFileSizeAllowedInMB}MB');
                                  })
                            : () {
                                Lamat.toast(
                                    'Maximum number of files can be selected: ${observer.maxNoOfFilesInMultiSharing}');
                              }),
                    const SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          Column(children: [
            mode == 'single'
                ? Expanded(
                    child: Center(
                        child: error != null
                            ? fileSizeErrorWidget(error!)
                            : _buildSingleFile(
                                file: seletedFiles.isNotEmpty
                                    ? File(seletedFiles[0].path!)
                                    : null)))
                : Expanded(child: Center(child: _buildMultiDoc())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && seletedFiles.length > 1
                    ? _buildMultiDocLoading()
                    : Container(
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

  uploadEach(int index) async {
    if (index > seletedFiles.length) {
      Navigator.of(this.context).pop();
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await widget
          .callback(File(seletedFiles[index].path!),
              timestamp: messagetime, totalFiles: seletedFiles.length)
          .then((fileUrl) async {
        await widget.writeMessage!(fileUrl, messagetime).then((value) {
          if (seletedFiles.last == seletedFiles[index]) {
            Navigator.of(this.context).pop();
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
    }
  }

  Widget _buildButtons() {
    final observer = ref.watch(observerProvider);
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  const Key('multi'),
                  Icons.add,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Lamat.checkAndRequestPermission(
                                  Permission.manageExternalStorage)
                              .then((res) {
                            if (res == true) {
                              captureMultiPageDoc(false);
                            } else if (res == false) {
                              Lamat.showRationale(
                                "Permission to access Gallery need to select Photos",
                              );
                              Navigator.push(
                                  this.context,
                                  MaterialPageRoute(
                                      builder: (context) => OpenSettings(
                                            prefs: widget.prefs,
                                          )));
                            } else {}
                          });
                        }
                      : () {
                          Lamat.toast(
                              'Maximum number of files can be selected: ${observer.maxNoOfFilesInMultiSharing}');
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
