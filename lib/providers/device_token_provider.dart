import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/device_model.dart';

class DeviceTokenProvider {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _deviceTokenCollection = FirebaseConstants.deviceTokensCollection;

  // getDeviceToken() async {
  //   String? deviceToken = await _firebaseMessaging.getToken();
  //   return deviceToken;
  // }

  Future<void> saveDeviceToken(String currentUserId) async {
    String? token = await _firebaseMessaging.getToken();
    // final token =  await _firebaseMessaging.getToken();
    if (token != null) {
      final DeviceTokenModel deviceToken = DeviceTokenModel(
        deviceToken: token,
        phoneNumber: currentUserId,
      );
      await FirebaseFirestore.instance
          .collection(_deviceTokenCollection)
          .doc(deviceToken.deviceToken)
          .set(deviceToken.toMap());
    }
  }

  Future<void> deleteDeviceToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await FirebaseFirestore.instance
          .collection(_deviceTokenCollection)
          .doc(token)
          .delete();
    }
  }
}
