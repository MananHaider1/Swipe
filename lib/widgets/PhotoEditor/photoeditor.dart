// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/PhotoEditor/widgets/common_widget.dart';
import 'package:lamatdating/widgets/PhotoEditor/widgets/crop_editor_helper.dart';
import 'package:lamatdating/widgets/PhotoEditor/widgets/image_picker/_image_picker_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PhotoEditor extends StatefulWidget {
  final File? imageFilePreSelected;
  final bool isPNG;
  final Function(File finalEditedimage) onImageEdit;
  final Function()? onClose;
  const PhotoEditor(
      {super.key,
      this.imageFilePreSelected,
      this.onClose,
      required this.onImageEdit,
      required this.isPNG});
  @override
  PhotoEditorState createState() => PhotoEditorState();
}

class PhotoEditorState extends State<PhotoEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>> popupMenuKey =
      GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>>();

  AspectRatioItem? _aspectRatio;

  EditorCropLayerPainter? _cropLayerPainter;

  @override
  void initState() {
    if (widget.imageFilePreSelected != null) {
      convertFileToImage();
    } else {
      _getImage();
    }
    _aspectRatio =
        AspectRatioItem(text: 'custom', value: CropAspectRatios.custom);
    _cropLayerPainter = const EditorCropLayerPainter();
    super.initState();
  }

  convertFileToImage() async {
    Uint8List bytes = widget.imageFilePreSelected!.readAsBytesSync();
    _memoryImage = bytes;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color bottomIconColor = Colors.white70;
    final List<AspectRatioItem> aspectRatios = <AspectRatioItem>[
      AspectRatioItem(text: "Custom", value: CropAspectRatios.custom),
      AspectRatioItem(text: "Original", value: CropAspectRatios.original),
      AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
      AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
      AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
      AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
      AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.close_outlined,
            color: Colors.white70,
          ),
          onPressed: () {
            if (widget.onClose != null) {
              widget.onClose!();
            }
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        actions: <Widget>[
          _memoryImage == null
              ? const SizedBox()
              : IconButton(
                  icon: const Icon(
                    Icons.done,
                    color: AppConstants.secondaryColor,
                  ),
                  onPressed: () async {
                    if (kIsWeb) {
                      _cropImage(false);
                    } else {
                      // _showCropDialog(context);
                      _cropImage(true);
                    }
                  },
                ),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
            child: _memoryImage != null
                ? ExtendedImage.memory(
                    _memoryImage!,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    enableLoadState: true,
                    extendedImageEditorKey: editorKey,
                    initEditorConfigHandler: (ExtendedImageState? state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                        cropLayerPainter: _cropLayerPainter!,
                        editorMaskColorHandler: (context, boo) {
                          return Colors.black.withOpacity(0.6);
                        },
                        initCropRectType: InitCropRectType.imageRect,
                        cropAspectRatio: _aspectRatio!.value,
                      );
                    },
                    cacheRawData: true,
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: Colors.white70,
                          size: 60,
                        ),
                        onPressed: _getImage,
                      ),
                    ),
                  )),
      ]),
      bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 80,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                FlatButtonWithIcon(
                  icon: Icon(Icons.crop, color: bottomIconColor),
                  label: IsShowTextLabelsInPhotoVideoEditorPage == false
                      ? const SizedBox()
                      : Text(
                          "Crop",
                          style:
                              TextStyle(fontSize: 10.0, color: bottomIconColor),
                        ),
                  textColor: Colors.white70,
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return Column(
                            children: <Widget>[
                              const Expanded(
                                child: SizedBox(),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(20.0),
                                  itemBuilder: (_, int index) {
                                    final AspectRatioItem item =
                                        aspectRatios[index];
                                    return GestureDetector(
                                      child: AspectRatioWidget(
                                        aspectRatio: item.value,
                                        aspectRatioS: item.text,
                                        isSelected: item == _aspectRatio,
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          _aspectRatio = item;
                                        });
                                      },
                                    );
                                  },
                                  itemCount: aspectRatios.length,
                                ),
                              ),
                            ],
                          );
                        });
                  },
                ),
                FlatButtonWithIcon(
                  icon: Icon(
                    Icons.flip,
                    color: bottomIconColor,
                  ),
                  label: IsShowTextLabelsInPhotoVideoEditorPage == false
                      ? const SizedBox()
                      : Text(
                          "Flip",
                          style:
                              TextStyle(fontSize: 10.0, color: bottomIconColor),
                        ),
                  textColor: Colors.white,
                  onPressed: () {
                    editorKey.currentState!.flip();
                  },
                ),
                FlatButtonWithIcon(
                  icon: Icon(
                    Icons.rotate_left,
                    color: bottomIconColor,
                  ),
                  label: IsShowTextLabelsInPhotoVideoEditorPage == false
                      ? const SizedBox()
                      : Text(
                          "Rotate Left",
                          style: TextStyle(
                            fontSize: 8.0,
                            color: bottomIconColor,
                          ),
                        ),
                  textColor: Colors.white,
                  onPressed: () {
                    editorKey.currentState!.rotate(right: false);
                  },
                ),
                FlatButtonWithIcon(
                  icon: Icon(
                    Icons.rotate_right,
                    color: bottomIconColor,
                  ),
                  label: IsShowTextLabelsInPhotoVideoEditorPage == false
                      ? const SizedBox()
                      : Text(
                          "Rotate Right",
                          style: TextStyle(
                            fontSize: 8.0,
                            color: bottomIconColor,
                          ),
                        ),
                  textColor: Colors.white,
                  onPressed: () {
                    editorKey.currentState!.rotate(right: true);
                  },
                ),
                FlatButtonWithIcon(
                  icon: Icon(
                    Icons.rounded_corner_sharp,
                    color: bottomIconColor,
                  ),
                  label: PopupMenuButton<EditorCropLayerPainter>(
                    color: Colors.white,
                    key: popupMenuKey,
                    enabled: false,
                    offset: const Offset(100, -300),
                    initialValue: _cropLayerPainter,
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<EditorCropLayerPainter>>[
                        const PopupMenuItem<EditorCropLayerPainter>(
                          value: EditorCropLayerPainter(),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.rounded_corner_sharp,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IsShowTextLabelsInPhotoVideoEditorPage == false
                                  ? SizedBox()
                                  : Text(
                                      "Default",
                                      style: TextStyle(
                                          color: AppConstants.lamatBlack),
                                    ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<EditorCropLayerPainter>(
                          value: CustomEditorCropLayerPainter(),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.circle,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IsShowTextLabelsInPhotoVideoEditorPage == false
                                  ? SizedBox()
                                  : Text(
                                      "Custom",
                                      style: TextStyle(
                                          color: AppConstants.lamatBlack),
                                    ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<EditorCropLayerPainter>(
                          value: CircleEditorCropLayerPainter(),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                CupertinoIcons.circle,
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              IsShowTextLabelsInPhotoVideoEditorPage == false
                                  ? SizedBox()
                                  : Text(
                                      "Circle",
                                      style: TextStyle(
                                          color: AppConstants.lamatBlack),
                                    ),
                            ],
                          ),
                        ),
                      ];
                    },
                    onSelected: (EditorCropLayerPainter value) {
                      if (_cropLayerPainter != value) {
                        setState(() {
                          if (value is CircleEditorCropLayerPainter) {
                            _aspectRatio = aspectRatios[2];
                          }
                          _cropLayerPainter = value;
                        });
                      }
                    },
                    child: Text(
                      "Painter",
                      style: TextStyle(
                        fontSize: 8.0,
                        color: bottomIconColor,
                      ),
                    ),
                  ),
                  textColor: Colors.white,
                  onPressed: () {
                    popupMenuKey.currentState!.showButtonMenu();
                  },
                ),
                FlatButtonWithIcon(
                  icon: Icon(
                    Icons.restore,
                    color: bottomIconColor,
                  ),
                  label: IsShowTextLabelsInPhotoVideoEditorPage == false
                      ? const SizedBox()
                      : Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 10.0,
                            color: bottomIconColor,
                          ),
                        ),
                  textColor: Colors.white,
                  onPressed: () {
                    editorKey.currentState!.reset();
                  },
                ),
              ],
            ),
          )),
    );
  }

  Future<void> _cropImage(bool useNative) async {
    try {
      Uint8List? fileData;

      /// native library
      if (useNative) {
        fileData = await cropImageDataWithNativeLibrary(
            state: editorKey.currentState!);
      } else {
        fileData =
            await cropImageDataWithDartLibrary(state: editorKey.currentState!);
      }
      final String? filePath = await ImageSaver.save(
          '${DateTime.now().millisecondsSinceEpoch}.jpg', fileData!);

      Navigator.of(context).pop();
      widget.onImageEdit(File(filePath!));
    } catch (e) {
      Lamat.toast("Failed. ERROR: $e");
    }
  }

  Uint8List? _memoryImage;
  Future<void> _getImage() async {
    _memoryImage = await pickImage(context);
    //when back to current page, may be editorKey.currentState is not ready.
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (editorKey.currentState != null) {
        setState(() {
          editorKey.currentState!.reset();
        });
      }
    });
  }
}

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  const CustomEditorCropLayerPainter();
  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Paint paint = Paint()
      ..color = painter.cornerColor
      ..style = PaintingStyle.fill;
    final Rect cropRect = painter.cropRect;
    const double radius = 6;
    canvas.drawCircle(Offset(cropRect.left, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.left, cropRect.bottom), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.bottom), radius, paint);
  }
}

class CircleEditorCropLayerPainter extends EditorCropLayerPainter {
  const CircleEditorCropLayerPainter();

  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    // do nothing
  }

  @override
  void paintMask(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect rect = Offset.zero & size;
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    canvas.drawCircle(cropRect.center, cropRect.width / 2.0,
        Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    if (painter.pointerDown) {
      canvas.save();
      canvas.clipPath(Path()..addOval(cropRect));
      super.paintLines(canvas, size, painter);
      canvas.restore();
    }
  }
}
