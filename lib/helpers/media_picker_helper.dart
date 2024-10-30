import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

Future<String?> pickMedia({bool? isVideo, bool? isCamera}) async {
  final info = DeviceInfoPlugin();
  final androidInfo = await info.androidInfo;
  final apiLevel = androidInfo.version.sdkInt;
  if (apiLevel >= 33) {
    // Request READ_MEDIA_IMAGES for Android 13+
    final statusPhoto = await Permission.photos.request();
    final statusVideo = await Permission.videos.request();
    if (statusPhoto.isGranted && statusVideo.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = isVideo ?? false
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(
              source:
                  isCamera ?? false ? ImageSource.camera : ImageSource.gallery);

      return pickedFile?.path;
    } else {
      // Permission denied or permanently declined by user
      return null;
    }
  } else {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = isVideo ?? false
          ? await picker.pickVideo(source: ImageSource.gallery)
          : await picker.pickImage(
              source:
                  isCamera ?? false ? ImageSource.camera : ImageSource.gallery);

      return pickedFile?.path;
    } else {
      // Request permission if not granted
      var requestResult = await Permission.storage.request();
      if (requestResult == PermissionStatus.granted) {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = isVideo ?? false
            ? await picker.pickVideo(source: ImageSource.gallery)
            : await picker.pickImage(
                source: isCamera ?? false
                    ? ImageSource.camera
                    : ImageSource.gallery);

        return pickedFile?.path;
      } else {
        // Permission denied or permanently declined by user
        return null;
      }
    }
    // return null;
  }
}

Future<PickedFileModel?> pickMediaAsData(
    {bool? isVideo, bool? isCamera}) async {
  // final ImagePickerWeb picker = ImagePickerWeb();
  Uint8List? pickedFile;
  String? fileName;
  bool isVid = isVideo ?? false;
  bool isCam = isCamera ?? false;
  final ImagePicker picker = ImagePicker();
  // final Uint8List? pickedFile = (isVid == false)
  //     ? await ImagePickerWeb.getImageAsBytes()
  //     : await ImagePickerWeb.getVideoAsBytes();
  FilePickerResult? result;
  XFile? resultCam;
  if (isCam && !kIsWeb) {
    resultCam = await picker.pickImage(source: ImageSource.camera);
    final pickedFile = await resultCam?.readAsBytes();
    final fileName = resultCam?.name;
    final PickedFileModel pickedFileModel =
        PickedFileModel(pickedFile: pickedFile, fileName: fileName);
    if (fileName!.contains(".png") ||
        fileName.contains(".PNG") ||
        fileName.contains(".jpg") ||
        fileName.contains(".JPG") ||
        fileName.contains(".jpeg") ||
        fileName.contains(".JPEG") ||
        fileName.contains(".mp4") ||
        fileName.contains(".MP4")) {
      return pickedFileModel;
    }
    EasyLoading.showError("Only JPEG, JPG, PNG, MP4 Files Allowed");
  } else {
    result = !isVid
        ? await FilePicker.platform.pickFiles(
            allowMultiple: false, type: FileType.image, withData: true)
        : await FilePicker.platform.pickFiles(
            allowMultiple: false, type: FileType.video, withData: true);

    if (result != null) {
      pickedFile = result.files.first.bytes!;
      fileName = result.files.first.name;
      final PickedFileModel pickedFileModel =
          PickedFileModel(pickedFile: pickedFile, fileName: fileName);
      if (fileName.contains(".png") ||
          fileName.contains(".PNG") ||
          fileName.contains(".jpg") ||
          fileName.contains(".JPG") ||
          fileName.contains(".jpeg") ||
          fileName.contains(".JPEG") ||
          fileName.contains(".mp4") ||
          fileName.contains(".MP4")) {
        return pickedFileModel;
      } else {
        EasyLoading.showError("Only JPEG, JPG, PNG, MP4 Files Allowed");
        return null;
      }
    }
    return null;
  }

  return null;
}

class PickedFileModel {
  final Uint8List? pickedFile;
  final String? fileName;
  PickedFileModel({this.pickedFile, this.fileName});
}



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
