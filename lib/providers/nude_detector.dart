// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_nude_detector/flutter_nude_detector.dart';

Future<bool> detectNudity(String imagePath) async {
  final hasNudity = await FlutterNudeDetector.detect(path: imagePath);

  return hasNudity;
}
