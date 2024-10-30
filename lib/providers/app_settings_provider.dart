import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/app_settings_model.dart';

final appSettingsProvider = FutureProvider<AppSettingsModel?>((ref) async {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection)
      .doc("settings");
  final snapshot = await collection.get();
  if (!snapshot.exists) {
    return null;
  }
  final doc = snapshot.data();
  return AppSettingsModel.fromMap(doc!);
});

final getGiftsProvider = FutureProvider<List<Gifts>?>((ref) async {
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.appSettingsCollection)
      .doc("settings")
      .collection("gifts");
  final snapshot = await collection.get();
  if (snapshot.docs.isEmpty) {
    return null;
  }
  return snapshot.docs.map((doc) => Gifts.fromJson(doc.data())).toList();
});

final appSettingsDocProvider =
    FutureProvider<DocumentSnapshot<Map<String, dynamic>>>(
  (ref) async {
    final fireIns = FirebaseFirestore.instance;
    // final fireIns = ref.read(firebaseProvider);
    return await fireIns.collection("appSettings").doc("userapp").get();
  },
);
