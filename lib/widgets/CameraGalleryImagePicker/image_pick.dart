import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

Future<File?> pickSingleImage(BuildContext context) async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: const AssetPickerConfig(
        maxAssets: 1,
        pathThumbnailSize: ThumbnailSize.square(84),
        gridCount: 3,
        pageSize: 900,
        requestType: RequestType.image,
        textDelegate: EnglishAssetPickerTextDelegate()),
  );
  if (result != null) {
    return result.first.file;
  }
  return null;
}
