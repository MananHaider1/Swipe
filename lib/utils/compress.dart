import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:lamatdating/constants.dart';

Future<File> compressAndGetFile(File file, String targetPath) async {
  // var result = await FlutterImageCompress.compressAndGetFile(
  //   file.absolute.path,
  //   targetPath,
  //   quality: 50,
  //   rotate: 0,
  // );

  File? compressedImage;

  File originalImageFile = File(file.path); // Convert XFile to File

  XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
    originalImageFile.absolute.path,
    targetPath,
    quality: ImageQualityCompress,
    rotate: 0,
  );

  if (compressedXFile != null) {
    compressedImage = File(compressedXFile.path); // Convert XFile to File
  }

  // print(file.lengthSync());
  // print(result!.lengthSync());

  return compressedImage!;
}
