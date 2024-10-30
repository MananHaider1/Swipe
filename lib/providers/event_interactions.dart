import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/user_interaction_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

final eventInteractionFutureProvider =
    FutureProvider.family<List<UserInteractionModel>, String>(
        (ref, eventType) async {
  final interactionCollection = await FirebaseFirestore.instance
      .collection('Events')
      .doc(eventType)
      .get();
  final interactionList = interactionCollection.data()!['interactions'];
  return await interactionList
      .where("phoneNumber",
          isEqualTo: ref.watch(currentUserStateProvider)!.phoneNumber)
      .get()
      .then((snapshot) async {
    final List<UserInteractionModel> interactionList = [];
    for (var doc in snapshot.docs) {
      interactionList.add(UserInteractionModel.fromMap(doc.data()));
    }
    return interactionList;
  });
});

// final isNewInteractionListFutureProvider = FutureProvider<bool>((ref) async {
//   final isRefreshedasync = ref.watch(eventInteractionFutureProvider);
//   bool isRefreshed = false;
//   isRefreshedasync.when(data: (data) {
//     return (data.isNotEmpty) ? isRefreshed = true : isRefreshed = false;
//   }, error: (error, __) {
//     return isRefreshed = false;
//   }, loading: () {
//     return isRefreshed = false;
//   });
//   return isRefreshed;
// });

final _interactionCollection = FirebaseFirestore.instance.collection('Events');

Future<bool> createEventInteraction(
    UserInteractionModel interaction, String eventType) async {
  try {
    await _interactionCollection
        .doc(eventType)
        .collection("interactions")
        .doc(interaction.id)
        .set(interaction.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteInteraction(String interactionId, String eventType) async {
  try {
    await _interactionCollection
        .doc(eventType)
        .collection("interactions")
        .doc(interactionId)
        .delete();
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
    String otherUserId, String currentUserId, String eventType) async {
  final interactionCollection = _interactionCollection
      .doc(eventType)
      .collection("interactions")
      .doc(otherUserId + currentUserId);

  return await interactionCollection.get().then((snapshot) {
    if (!snapshot.exists) {
      return null;
    }
    return UserInteractionModel.fromMap(snapshot.data()!);
  });
}
