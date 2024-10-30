// ignore_for_file: avoid_web_libraries_in_flutter, depend_on_referenced_packages, unused_local_variable

import 'dart:async';
import 'dart:io' as i;

import "package:universal_html/html.dart";
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> pickMediaWeb({bool? isVideo, bool? isCamera}) async {
  // final ImagePickerWeb picker = ImagePickerWeb();
  Uint8List? pickedFile;
  String? fileName;
  bool isVid = isVideo ?? false;
  // final Uint8List? pickedFile = (isVid == false)
  //     ? await ImagePickerWeb.getImageAsBytes()
  //     : await ImagePickerWeb.getVideoAsBytes();
  final result = !isVid
      ? await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image)
      : await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.video);
  if (result != null) {
    pickedFile = result.files.first.bytes!;
    fileName = result.files.first.name;
    return pickedFile;
  }

  return null;
}

Future<Uint8List?> pickMediaAsBytes({bool? isVideo, bool? isCamera}) async {
  // final ImagePickerWeb picker = ImagePickerWeb();
  Uint8List? pickedFile;
  String? fileName;
  bool isVid = isVideo ?? false;
  // final Uint8List? pickedFile = (isVid == false)
  //     ? await ImagePickerWeb.getImageAsBytes()
  //     : await ImagePickerWeb.getVideoAsBytes();
  final result = !isVid
      ? await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image)
      : await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.video);
  if (result != null) {
    pickedFile = result.files.first.bytes!;
    fileName = result.files.first.name;
    return pickedFile;
  }

  return null;
}

// Future<File?> pickMediaAsFile({bool? isVideo, bool? isCamera}) async {
//   // final ImagePickerWeb picker = ImagePickerWeb();
//   bool isVid = isVideo ?? false;
//   final File? pickedFile = (isVid == false)
//       ? await ImagePickerWeb.getImageAsFile()
//       : await ImagePickerWeb.getVideoAsFile();

//   return pickedFile;
// }

Future<Uint8List?> convertFileToBytes(File file) async {
  final reader = FileReader();
  final completer = Completer<Uint8List?>();

  reader.readAsArrayBuffer(file);
  reader.onLoadEnd.listen((event) {
    completer.complete(reader.result as Uint8List);
  });

  return completer.future;
}

Future<Uint8List> compressUint8List(Uint8List list, int? quality) async {
  final result = await FlutterImageCompress.compressWithList(
    list,
    quality: quality ?? 50,
    // format: CompressFormat.jpeg, // Or any other supported format
  );
  return result;
}

Future<Uint8List> fileToBytes(i.File file) async {
  final bytes = await file.readAsBytes();
  return bytes;
}

Future<Uint8List?> thumbnailGenerator(File file, int width, int height) async {
  final thumbnail = VideoThumbnail.thumbnailData(
      video: file.relativePath!,
      imageFormat: ImageFormat.JPEG,
      maxWidth: width,
      maxHeight: height,
      quality: 100);
  return thumbnail;
}

Future<String> convertFileToDataURL(File file) async {
  final reader = FileReader();
  final completer = Completer<String>();

  reader.readAsDataUrl(file);
  reader.onLoadEnd.listen((event) {
    completer.complete(reader.result as String);
  });

  return completer.future;
}

Future<Uint8List?> getUint8ListFromUrl(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle error: Throw an exception or print an error message
      throw Exception('Failed to download image: ${response.statusCode}');
    }
  } catch (error) {
    // Handle other exceptions
    if (kDebugMode) {
      print('Error fetching image: $error');
    }
    return null;
  }
}

Future<Uint8List?> xFileToBytes(XFile xFile) async {
  try {
    final bytes = await xFile.readAsBytes();
    return bytes;
  } on PlatformException catch (e) {
    // Handle platform-specific errors (optional)
    if (kDebugMode) {
      print("Error reading file: $e");
    }
    return null; // Or throw an appropriate exception
  }
}

// Future<String> convertUint8ListToDataURL(Uint8List file) async {
//   final reader = FileReader();
//   final completer = Completer<String>();

//   reader.readAsDataUrl(file);
//   reader.onLoadEnd.listen((event) {
//     completer.complete(reader.result as String);
//   });

//   return completer.future;
// }

Future<String?> uploadFile(File file, Reference storageRe) async {
  final storageRef = storageRe;

  final reader = FileReader();
  final completer = Completer<String?>();
  // String? downloadUrl;

  reader.readAsArrayBuffer(file);
  reader.onLoadEnd.listen((event) {
    final uploadTask =
        storageRef.child(file.name).putData(reader.result as Uint8List);
    uploadTask.then((taskSnapshot) async {
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      completer.complete(downloadUrl);
    });
  });

  return completer.future;
}

Future<String?> uploadFileStory(Uint8List? file, Reference storageRe) async {
  // final currentTime = DateTime.now();
  final storageRef = storageRe;

  final completer = Completer<String?>();

  final metadata = SettableMetadata(
    contentType: 'image/jpeg',
  );
  try {
    final uploadTask = storageRef.putData(file!, metadata);
    uploadTask.whenComplete(() async {
      final downloadUrl = await storageRef.getDownloadURL();
      completer.complete(downloadUrl);
    });
  } on FirebaseException catch (e) {
    // Handle errors
    if (kDebugMode) {
      print('Error uploading file: $e');
    }
    return null;
  }

  return completer.future;
}

// Future<Blob?> trimVideo(File videoFile) async {
//   Blob? videoBlob;
//   try {
//     final reader = FileReader();
//     reader.readAsArrayBuffer(videoFile);
//     reader.onLoadEnd.listen((event) async {
//       // Invoke ffmpeg.wasm's trimming function (replace with actual calls)
//       final trimmedData =
//           await _trimVideoWithFfmpegWasm(reader.result as ByteBuffer);

//       // Create a Blob from the trimmed data
//       videoBlob = Blob([Uint8List.view(trimmedData)], 'video/mp4');
//     });
//     return videoBlob;
//   } catch (error) {
//     showERRORSheet(context as BuildContext, "", message: error.toString());
//     debugPrint('Error trimming video: $error');
//     rethrow; // Or handle the error as needed
//   }
// }

// Future<ByteBuffer> _trimVideoWithFfmpegWasm(ByteBuffer videoData) async {
//   // 1. Access ffmpeg.wasm functions using dart:js
//   final ffmpegWasm =
//       context['ffmpeg']; // Assuming ffmpeg.wasm is globally available

//   // 2. Create a temporary file or in-memory object to store trimmed data
//   final trimmedData = Blob([], 'video/mp4'); // Adjust MIME type if needed

//   // 3. Use ffmpeg.wasm's functions to construct a command string
//   final command = '-i $videoData'
//       ' -ss 00:00:00'
//       ' -to 00:00:15'
//       ' -c copy';
//   trimmedData;

//   // 4. Execute the command using ffmpeg.wasm
//   await ffmpegWasm.run(command);

//   // 5. Read the trimmed data from the temporary file or object
//   // (adjust based on how you stored the trimmed data)
//   final trimmedDataUrl = Url.createObjectUrlFromBlob(trimmedData);
//   final trimmedDataArrayBuffer =
//       (await HttpRequest.request(trimmedDataUrl)).response;

//   // 6. Return the trimmed data as a ByteBuffer
//   return trimmedDataArrayBuffer;
// }



// Future<List<Uint8List>> pickImage() async {
//   final bytes = await ImagePickerWeb.getMultiImagesAsBytes();
//   if (bytes != null) {
//     return bytes;
//   }
//   return [];
// }

// Future<Uint8List?> pickSingleImage() async {
//   final bytes = await ImagePickerWeb.getImageAsBytes();

//   return bytes!;
// }

// Future<h.File?> pickSingleImageFile() async {
//   final bytes = await ImagePickerWeb.getImageAsFile();

//   return bytes!;
// }

// Future<h.File?> pickSingleVideo() async {
//   final videoFile = await ImagePickerWeb.getVideoAsFile();
//   return videoFile!; // No need to wrap in a Future
// }
