// ignore_for_file: depend_on_referenced_packages

import 'dart:isolate';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http_client_helper/http_client_helper.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart';

Future<Uint8List?> cropImageDataWithDartLibrary(
    {required ExtendedImageEditorState state}) async {
  if (kDebugMode) {
    print('dart library start cropping');
  }

  final Rect? cropRect = state.getCropRect();

  if (kDebugMode) {
    print('getCropRect : $cropRect');
  }

  final Uint8List data = kIsWeb &&
          state.widget.extendedImageState.imageWidget.image
              is ExtendedNetworkImageProvider
      ? await _loadNetwork(state.widget.extendedImageState.imageWidget.image
          as ExtendedNetworkImageProvider)
      : state.rawImageData;

  final EditActionDetails editAction = state.editAction!;

  final DateTime time1 = DateTime.now();

  img.Image? src;

  if (kIsWeb) {
    src = img.decodeImage(data);
  } else {
    src = await compute(img.decodeImage, data);
  }
  if (src != null) {
    final DateTime time2 = DateTime.now();

    src = img.bakeOrientation(src);

    if (editAction.needCrop) {
      src = img.copyCrop(src,
          x: cropRect!.left.toInt(),
          y: cropRect.top.toInt(),
          width: cropRect.width.toInt(),
          height: cropRect.height.toInt());
    }

    if (editAction.needFlip) {
      if (editAction.flipY && editAction.flipX) {
        src = img.flipHorizontal(src);
        src = img.flipVertical(src);
      } else if (editAction.flipY) {
        src = img.flipHorizontal(src);
      } else if (editAction.flipX) {
        src = img.flipVertical(src);
      }
    }

    if (editAction.hasRotateAngle) {
      src = img.copyRotate(src, angle: editAction.rotateAngle);
    }
    final DateTime time3 = DateTime.now();
    if (kDebugMode) {
      print('${time3.difference(time2)} : crop/flip/rotate');
    }
  }

  List<int>? fileData;
  if (kDebugMode) {
    print('start encode');
  }
  final DateTime time4 = DateTime.now();
  if (src != null) {
    if (kIsWeb) {
      fileData = img.encodeJpg(src);
    } else {
      fileData = await compute(img.encodeJpg, src);
    }
  }
  final DateTime time5 = DateTime.now();
  if (kDebugMode) {
    print('${time5.difference(time4)} : encode');
  }
  if (kDebugMode) {
    print('${time5.difference(time1)} : total time');
  }
  return Uint8List.fromList(fileData!);
}

Future<Uint8List?> cropImageDataWithNativeLibrary(
    {required ExtendedImageEditorState state}) async {
  if (kDebugMode) {
    print('native library start cropping');
  }

  final Rect? cropRect = state.getCropRect();
  final EditActionDetails action = state.editAction!;

  final int rotateAngle = action.rotateAngle.toInt();
  final bool flipHorizontal = action.flipY;
  final bool flipVertical = action.flipX;
  final Uint8List img = state.rawImageData;

  final ImageEditorOption option = ImageEditorOption();

  if (action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect!));
  }

  if (action.needFlip) {
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  final DateTime start = DateTime.now();
  final Uint8List? result = await ImageEditor.editImage(
    image: img,
    imageEditorOption: option,
  );

  if (kDebugMode) {
    print('${DateTime.now().difference(start)} ：total time');
  }
  return result;
}

Future<dynamic> isolateDecodeImage(List<int> data) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateDecodeImage, response.sendPort);
  final dynamic sendPort = await response.first;
  final ReceivePort answer = ReceivePort();
  // ignore: always_specify_types
  sendPort.send([answer.sendPort, data]);
  return answer.first;
}

Future<dynamic> isolateEncodeImage(img.Image src) async {
  final ReceivePort response = ReceivePort();
  await Isolate.spawn(_isolateEncodeImage, response.sendPort);
  final dynamic sendPort = await response.first;
  final ReceivePort answer = ReceivePort();
  // ignore: always_specify_types
  sendPort.send([answer.sendPort, src]);
  return answer.first;
}

void _isolateDecodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final List<int> data = message[1] as List<int>;
    send.send(img.decodeImage(Uint8List.fromList(data)));
  });
}

void _isolateEncodeImage(SendPort port) {
  final ReceivePort rPort = ReceivePort();
  port.send(rPort.sendPort);
  rPort.listen((dynamic message) {
    final SendPort send = message[0] as SendPort;
    final img.Image src = message[1] as img.Image;
    send.send(img.encodeJpg(src));
  });
}

/// it may be failed, due to Cross-domain
Future<Uint8List> _loadNetwork(ExtendedNetworkImageProvider key) async {
  try {
    final Response? response = await HttpClientHelper.get(Uri.parse(key.url),
        headers: key.headers,
        timeLimit: key.timeLimit,
        timeRetry: key.timeRetry,
        retries: key.retries,
        cancelToken: key.cancelToken);
    return response!.bodyBytes;
  } on OperationCanceledError catch (_) {
    if (kDebugMode) {
      print('User cancel request ${key.url}.');
    }
    return Future<Uint8List>.error(
        StateError('User cancel request ${key.url}.'));
  } catch (e) {
    return Future<Uint8List>.error(StateError('failed load ${key.url}. \n $e'));
  }
}
