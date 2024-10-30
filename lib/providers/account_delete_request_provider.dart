import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/account_delete_request_model.dart';

class AccountDeleteProvider {
  static Future<AccountDeleteRequestModel?> getAccountDeleteRequest(
      String phoneNumber) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.accountDeleteRequestCollection);

    final doc = await collection.doc(phoneNumber).get();
    if (doc.exists) {
      return AccountDeleteRequestModel.fromMap(doc.data()!);
    } else {
      return null;
    }
  }

  static Future<bool> requestAccountDelete(
      AccountDeleteRequestModel model) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.accountDeleteRequestCollection);

    try {
      await collection.doc(model.phoneNumber).set(model.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelAccountDeleteRequest(String phoneNumber) async {
    final collection = FirebaseFirestore.instance
        .collection(FirebaseConstants.accountDeleteRequestCollection);

    try {
      await collection.doc(phoneNumber).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
