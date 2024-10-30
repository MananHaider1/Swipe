// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

Future<Uint8List?> pickImage(BuildContext context) async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: const AssetPickerConfig(
      maxAssets: 1,
      pathThumbnailSize: ThumbnailSize.square(84),
      gridCount: 3,
      pageSize: 900,
      requestType: RequestType.image,
      textDelegate: EnglishAssetPickerTextDelegate(),
    ),
  );
  if (result != null) {
    return result.first.originBytes;
  }
  return null;
}

// class ImageSaver {
//   const ImageSaver._();

//   static Future<String?> save(String name, Uint8List fileData) async {
//     final String title = '${DateTime.now().millisecondsSinceEpoch}.jpg';
//     final AssetEntity? imageEntity = await PhotoManager.editor.saveImage(
//       fileData,
//       title: title,
//     );
//     final File? file = await imageEntity?.file;
//     return file?.path;
//   }
// }

class ImageSaver {
  const ImageSaver._();

  static Future<String?> save(String name, Uint8List fileData) async {
    if (kIsWeb) {
      // Web platform
      final String title = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FileSaver().saveAs(
        // Create instance before calling saveAs
        bytes: fileData,
        name: title,
        ext: '.jpg',
        mimeType: MimeType.jpeg,
      );
      return null;
    } else {
      // Non-web platform
      final AssetEntity? imageEntity = await PhotoManager.editor.saveImage(
        fileData,
        title: name, filename: name,
      );
      final File? file = await imageEntity?.file;
      return file?.path;
    }
  }
}
