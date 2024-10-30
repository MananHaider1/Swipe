import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/verification_form_model.dart';

final verificationProvider =
    ChangeNotifierProvider<VerificationProvider>((ref) {
  return VerificationProvider();
});

class VerificationProvider extends ChangeNotifier {
  final _verificationCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.verificationFormsCollection);

  //Verification
  Future<VerificationFormModel?> getVerifiedStatus(String currentUserId) async {
    return _verificationCollection.doc(currentUserId).get().then((value) {
      if (value.exists) {
        return VerificationFormModel.fromMap(value.data()!);
      } else {
        return null;
      }
    });
  }

  Future<void> submitVerificationForm(VerificationFormModel model) async {
    try {
      await _verificationCollection.doc(model.phoneNumber).set(model.toMap());
      EasyLoading.showSuccess("Verification form submitted!");
      notifyListeners();
    } catch (e) {
      EasyLoading.showError("Something Went Wrong");
    }
  }

  Future<void> updateVerificationForm(VerificationFormModel model) async {
    try {
      await _verificationCollection
          .doc(model.phoneNumber)
          .update(model.toMap());
      EasyLoading.showSuccess("Verification form updated!");
      notifyListeners();
    } catch (e) {
      EasyLoading.showError("Something Went Wrong");
    }
  }
}
