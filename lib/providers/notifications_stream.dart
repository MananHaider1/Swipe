import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/helpers/database_paths.dart';

final notificationsProvider =
    StreamProvider<DocumentSnapshot<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection(DbPaths.collectionnotifications)
      .doc(DbPaths.usersnotifications)
      .snapshots();
});
