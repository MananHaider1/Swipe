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

class MultiImagePicker extends ConsumerStatefulWidget {
  const MultiImagePicker(
      {super.key,
      required this.title,
      required this.prefs,
      required this.callback,
      this.writeMessage,
      this.profile = false});

  final String title;
  final SharedPreferences prefs;
  final Function callback;
  final bool profile;
  final Future<void> Function(String url, int timestamp)? writeMessage;

  @override
  MultiImagePickerState createState() => MultiImagePickerState();
}

class MultiImagePickerState extends ConsumerState<MultiImagePicker> {
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  String mode = 'single';
  List<XFile> selectedImages = [];
  int currentUploadingIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  bool checkTotalNoOfFilesIfExceeded() {
    final observer = ref.read(observerProvider);
    if (selectedImages.length > observer.maxNoOfFilesInMultiSharing) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfAnyFileSizeExceeded() {
    final observer = ref.read(observerProvider);
    int index = selectedImages.indexWhere((file) =>
        File(file.path).lengthSync() / 1000000 >
        observer.maxFileSizeAllowedInMB);
    if (index >= 0) {
      return true;
    } else {
      return false;
    }
  }

  void captureSingleImage(ImageSource captureMode) async {
    final observer = ref.read(observerProvider);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        if (File(pickedImage.path).lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(File(pickedImage.path).lengthSync() / 1000000).round()}MB';

          setState(() {
            mode = "single";
            selectedImages = [];
          });
        } else {
          setState(() {
            mode = "single";
            selectedImages.add(pickedImage);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void captureMultiPageImage(bool isAddOnly) async {
    final observer = ref.watch(observerProvider);
    error = null;
    try {
      if (isAddOnly) {
        //--- Is adding to already selected images list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images.isNotEmpty) {
          for (var image in images) {
            if (!selectedImages.contains(image)) {
              selectedImages.add(image);
            }
          }

          mode = 'multi';
          error = null;
          setState(() {});
        }
      } else {
        //--- Is adding to empty selected image list.
        List<XFile>? images = await picker.pickMultiImage();
        if (images.length > 1) {
          selectedImages = images;
          mode = 'multi';
          error = null;
          setState(() {});
        } else if (images.length == 1) {
          if (File(images[0].path).lengthSync() / 1000000 >
              observer.maxFileSizeAllowedInMB) {
            error =
                'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(File(images[0].path).lengthSync() / 1000000).round()}MB';

            setState(() {
              mode = "single";
            });
          } else {
            setState(() {
              mode = "single";
              selectedImages = images;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Widget _buildSingleImage({File? file}) {
    if (file != null) {
      return kIsWeb ? Image.network(file.path) : Image.file(file);
    } else {
      return const Text("Image",
          style: TextStyle(
            fontSize: 18.0,
            color: AppConstants.lamatGrey,
          ));
    }
  }

  Widget _buildMultiImageLoading() {
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
            '${currentUploadingIndex + 1}/${selectedImages.length}',
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

  Widget _buildMultiImage() {
    final observer = ref.read(observerProvider);
    if (selectedImages.isNotEmpty) {
      return GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7),
          itemCount: selectedImages.length,
          itemBuilder: (BuildContext context, i) {
            return Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  Container(
                    height: (MediaQuery.of(context).size.width / 2) - 20,
                    width: (MediaQuery.of(context).size.width / 2) - 20,
                    color: AppConstants.lamatGrey.withOpacity(0.4),
                  ),
                  kIsWeb
                      ? Image.network(
                          selectedImages[i].path,
                          fit: BoxFit.cover,
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                        )
                      : Image.file(
                          File(selectedImages[i].path),
                          fit: BoxFit.cover,
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                        ),
                  File(selectedImages[i].path).lengthSync() / 1000000 >
                          observer.maxFileSizeAllowedInMB
                      ? Container(
                          height: (MediaQuery.of(context).size.width / 2) - 20,
                          width: (MediaQuery.of(context).size.width / 2) - 20,
                          color: Colors.white70,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.all(10),
                              child: Text(
                                'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\nSelected File size is - ${(File(selectedImages[i].path).lengthSync() / 1000000).round()}MB',
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
                          selectedImages.removeAt(i);
                          if (selectedImages.length <= 1) {
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
      return const Text("Image",
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
              selectedImages.isNotEmpty
                  ? '${selectedImages.length} Selected'
                  : widget.title,
              style: TextStyle(
                fontSize: 18,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
              ),
            ),
            backgroundColor: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
            actions: selectedImages.isNotEmpty && !isLoading
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
                            : _buildSingleImage(
                                file: selectedImages.isNotEmpty
                                    ? File(selectedImages[0].path)
                                    : null)))
                : Expanded(child: Center(child: _buildMultiImage())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? mode == "multi" && selectedImages.length > 1
                    ? _buildMultiImageLoading()
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
    if (index > selectedImages.length) {
      Navigator.of(context).pop();
    } else {
      int messagetime = DateTime.now().millisecondsSinceEpoch;
      setState(() {
        currentUploadingIndex = index;
      });
      await widget
          .callback(File(selectedImages[index].path),
              timestamp: messagetime, totalFiles: selectedImages.length)
          .then((imageUrl) async {
        await widget.writeMessage!(imageUrl, messagetime).then((value) {
          if (selectedImages.last == selectedImages[index]) {
            Navigator.of(context).pop();
          } else {
            uploadEach(currentUploadingIndex + 1);
          }
        });
      });
    }
  }

  Widget _buildButtons() {
    final observer = ref.read(observerProvider);
    return ConstrainedBox(
        constraints: const BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                  const Key('multi'),
                  Icons.photo_library,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Lamat.checkAndRequestPermission(Permission.storage)
                              .then((res) {
                            if (res == true) {
                              captureMultiPageImage(false);
                            } else if (res == false) {
                              Lamat.showRationale(
                                "Permission to access Gallery need to select Photos",
                              );
                              Navigator.push(
                                  context,
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
              selectedImages.isEmpty
                  ? const SizedBox()
                  : _buildActionButton(
                      const Key('multi'),
                      Icons.add,
                      checkTotalNoOfFilesIfExceeded() == false
                          ? () {
                              Lamat.checkAndRequestPermission(
                                      Permission.storage)
                                  .then((res) {
                                if (res == true) {
                                  captureMultiPageImage(true);
                                } else if (res == false) {
                                  Lamat.showRationale(
                                    "Permission to access Gallery need to select Photos",
                                  );
                                  Navigator.push(
                                      context,
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
              _buildActionButton(
                  const Key('upload'),
                  Icons.photo_camera,
                  checkTotalNoOfFilesIfExceeded() == false
                      ? () {
                          Lamat.checkAndRequestPermission(Permission.camera)
                              .then((res) {
                            if (res == true) {
                              captureSingleImage(ImageSource.camera);
                            } else if (res == false) {
                              "Permission to access Camera need to select Photos";
                              Navigator.push(
                                  context,
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
