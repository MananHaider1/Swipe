import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/report_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

final _reportsCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.reportsCollection);

Future<bool> reportUser(ReportModel reportModel) async {
  try {
    List<File> images = [];
    for (var image in reportModel.images) {
      images.add(File(image));
    }

    await _uploadReportImages(
            files: images, phoneNumber: reportModel.reportingUserId)
        .then((value) {
      final newReportModel = reportModel.copyWith(images: value);
      _reportsCollection.doc(newReportModel.id).set(newReportModel.toMap());
    });

    return true;
  } catch (e) {
    return false;
  }
}

Future<List<String>> _uploadReportImages(
    {required List<File> files, required String phoneNumber}) async {
  try {
    final List<String> urls = [];

    for (var element in files) {
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.reportsCollection)
          .child(phoneNumber)
          .child(currentTime.millisecondsSinceEpoch.toString() +
              phoneNumber +
              element.path.split('/').last);

      final uploadTask = ref.putFile(element);
      String? url;
      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      if (url != null) {
        urls.add(url!);
      }
    }

    return urls;
  } catch (e) {
    return [];
  }
}

final getMyReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final reports = await _reportsCollection
      .where('reportedByUserId', isEqualTo: phoneNumber)
      .get();
  final List<ReportModel> reportModels = [];
  for (var element in reports.docs) {
    reportModels.add(ReportModel.fromMap(element.data()));
  }
  return reportModels;
});
