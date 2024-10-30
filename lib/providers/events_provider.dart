import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/event_model.dart';

final freeNumbersProvider =
    FutureProvider.family<List<String>, String>((ref, eventType) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('events').doc(eventType);

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    final users = docSnapshot.data()!['users'];
    final List<String> usersList =
        (users as List<dynamic>).map((user) => user.toString()).toList();
    return usersList;
  } else {
    // create a new document
    await docRef.set({
      'name': eventType,
      'image': eventType == 'photoVerified'
          ? 'https://images.pexels.com/photos/7480127/pexels-photo-7480127.jpeg?cs=srgb&dl=pexels-angela-roma-7480127.jpg&fm=jpg'
          : eventType == 'freeTonight'
              ? 'https://images.pexels.com/photos/801863/pexels-photo-801863.jpeg?cs=srgb&dl=pexels-maumascaro-801863.jpg&fm=jpg'
              : eventType == 'lookingForLove'
                  ? 'https://images.pexels.com/photos/1759823/pexels-photo-1759823.jpeg?cs=srgb&dl=pexels-gabriel-bastelli-865174-1759823.jpg&fm=jpg'
                  : 'https://images.pexels.com/photos/801863/pexels-photo-801863.jpeg?cs=srgb&dl=pexels-maumascaro-801863.jpg&fm=jpg',
      'isActive': true,
      'startDate': DateTime.now().toUtc().millisecondsSinceEpoch,
      'endDate': DateTime.now()
          .toUtc()
          .add(const Duration(days: 365 * 30))
          .millisecondsSinceEpoch,
      'users': []
    });
    return [];
  }
});

final allEventsProvider = FutureProvider<List<EventsModel>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  // Filter by eventType (assuming 'eventType' field exists in the document)
  final docRef = firestore.collection('events');
  final docSnapshot = await docRef.get();

  if (docSnapshot.docs.isNotEmpty) {
    final events =
        docSnapshot.docs.map((e) => EventsModel.fromMap(e.data())).toList();
    return events;
  } else {
    return [];
  }
});

Future<bool> addUserToEventUsers(
    String userPhoneNumber, String eventType) async {
  final firestore = FirebaseFirestore.instance;
  final docRef = firestore.collection('events').doc(eventType);
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    final users = docSnapshot.data()!['users'];
    final List<String> usersList =
        (users as List<dynamic>).map((user) => user.toString()).toList();
    if (usersList.contains(userPhoneNumber)) {
      return false;
    } else {
      usersList.add(userPhoneNumber);
      await docRef.set(
          {'users': FieldValue.arrayUnion(usersList)}, SetOptions(merge: true));
      return true;
    }
  }
  return false;
}
