// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> batchwriteFirestoreData(List taskList) async {
  WriteBatch writeBatch = FirebaseFirestore.instance.batch();
//-------Below Firestore Document for Admin Credentials ---------
  for (var f in taskList) {
    var task = Map<String, dynamic>.from(f);
    writeBatch.set(task['ref'], task['map'], SetOptions(merge: true));
  }

// unless commit is called, nothing happens. So commit is called below---
  await writeBatch.commit().catchError((err) {
    // ignore: invalid_return_type_for_catch_error
    return false;
  });
  return true;
}

class BatchWriteComponent {
  var ref;
  var map;

  BatchWriteComponent({
    required this.ref,
    required this.map,
  });

  Map<String, dynamic> toMap() {
    return {'ref': ref, 'map': map};
  }
}
