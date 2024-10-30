import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

final interactionFutureProvider =
    FutureProvider<List<UserInteractionModel>>((ref) async {
  final interactionCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userInteractionCollection);

  return await interactionCollection
      .where("phoneNumber",
          isEqualTo: ref.watch(currentUserStateProvider)!.phoneNumber)
      .get()
      .then((snapshot) async {
    final List<UserInteractionModel> interactionList = [];
    for (var doc in snapshot.docs) {
      interactionList.add(UserInteractionModel.fromMap(doc.data()));
    }
    final box = Hive.box(HiveConstants.hiveBox);
    List cachedUsersList = [];
    for (final user in interactionList) {
      final doc = user.toJson();
      cachedUsersList.add(doc);
    }
    await box.put(HiveConstants.cachedInterationFilter, cachedUsersList).then(
        (value) =>
            debugPrint("NewCachedInterationFilter: ${cachedUsersList.length}"));
    return interactionList;
  });
});

final isNewInteractionListFutureProvider = FutureProvider<bool>((ref) async {
  final isRefreshedasync = ref.watch(interactionFutureProvider);
  bool isRefreshed = false;
  isRefreshedasync.when(data: (data) {
    return (data.isNotEmpty) ? isRefreshed = true : isRefreshed = false;
  }, error: (error, __) {
    return isRefreshed = false;
  }, loading: () {
    return isRefreshed = false;
  });
  return isRefreshed;
});

final _interactionCollection = FirebaseFirestore.instance
    .collection(FirebaseConstants.userInteractionCollection);

Future<bool> createInteraction(UserInteractionModel interaction) async {
  try {
    await _interactionCollection.doc(interaction.id).set(interaction.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteInteraction(String interactionId) async {
  try {
    await _interactionCollection.doc(interactionId).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> isNewInteractionList(bool isRefresh) async {
  try {
    if (isRefresh) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<UserInteractionModel?> getExistingInteraction(
    String otherUserId, String currentUserId) async {
  final interactionCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userInteractionCollection);

  return await interactionCollection
      .where("id", isEqualTo: otherUserId + currentUserId)
      .get()
      .then((snapshot) {
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return UserInteractionModel.fromMap(snapshot.docs.first.data());
  });
}
