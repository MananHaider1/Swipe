import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/meeting_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
// import 'package:lamatdating/providers/match_provider.dart';
// import 'package:lamatdating/providers/other_users_provider.dart';

final getMeetingsProvider = StreamProvider<List<MeetingModel>>((ref) async* {
  final meetingsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.meetingsCollection);
  final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;

  // final List<String> meetingsUserIds = [currentUserId];

  yield* meetingsCollection
      .where(
        'host',
        isEqualTo: currentUserId,
      )
      .snapshots()
      .map((snapshot) {
    final List<MeetingModel> meetings = [];
    for (final doc in snapshot.docs) {
      meetings.add(MeetingModel.fromMap(doc.data()));
    }

    meetings.sort((a, b) => b.createdAt.millisecondsSinceEpoch
        .compareTo(a.createdAt.millisecondsSinceEpoch));

    return meetings;
  });
});

// final getMeetingsProvider = FutureProvider<List<MeetingModel>>((ref) async {
//   final meetingsCollection = FirebaseFirestore.instance
//       .collection(FirebaseConstants.meetingsCollection);
//   final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;
//   // final machingProvider = ref.watch(matchStreamProvider);
//   // final otherUsersRef = ref.watch(otherUsersProvider);

//   final List<String> meetingsUserIds = [currentUserId];

//   // otherUsersRef.whenData((otherUsers) {
//   //   for (var otherUser in otherUsers) {
//   //     meetingsUserIds.add(otherUser.phoneNumber);
//   //   }
//   // });

//   final snapshot =
//       await meetingsCollection.where('phoneNumber', whereIn: meetingsUserIds).get();

//   final List<MeetingModel> meetings = [];
//   for (final doc in snapshot.docs) {
//     meetings.add(MeetingModel.fromMap(doc.data()));
//   }

//   meetings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//   return meetings;
// });

final _meetingsCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.meetingsCollection);

Future<bool> addMeeting(MeetingModel meetingModel) async {
  try {
    await _meetingsCollection
        .doc(meetingModel.id)
        .set(meetingModel.toMap(), SetOptions(merge: true));

    return true;
  } catch (e) {
    return false;
  }
}

// Future<bool> likeMeeting(String meetingId, String phoneNumber) async {
//   try {
//     final meetingDoc = await _meetingsCollection.doc(meetingId).get();
//     final meetingData = meetingDoc.data();
//     if (meetingData != null) {
//       final meeting = MeetingModel.fromMap(meetingData);
//       final likes = meeting.likes;
//       if (!likes.contains(phoneNumber)) {
//         likes.add(phoneNumber);
//         await _meetingsCollection.doc(meetingId).update({'likes': likes});
//       }
//     }
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

// Future<bool> isLiked(String meetingId, String phoneNumber) async {
//   try {
//     final meetingDoc = await _meetingsCollection.doc(meetingId).get();
//     final meetingData = meetingDoc.data();

//     if (meetingData != null) {
//       final meeting = MeetingModel.fromMap(meetingData);
//       final likes = meeting.likes;
//       final liked = (likes.contains(phoneNumber)) ? true : false;
//       return liked;
//     }
//     return false;
//   } catch (e) {
//     return false;
//   }
// }

// Future<int> getTotalLikes(String meetingId) async {
//   try {
//     final meetingDoc = await _meetingsCollection.doc(meetingId).get();
//     final meetingData = meetingDoc.data();
//     if (meetingData != null) {
//       final meeting = MeetingModel.fromMap(meetingData);
//       final likes = meeting.likes;
//       return likes.length;
//     }
//     return 0;
//   } catch (e) {
//     return 0;
//   }
// }

// Future<List<MeetingModel>> getLikedMeetings(String phoneNumber) async {
//   final snapshot = await _meetingsCollection.get();
//   final List<MeetingModel> likedMeetings = [];
//   for (final doc in snapshot.docs) {
//     final meetingData = doc.data();

//     final meeting = MeetingModel.fromMap(meetingData);
//     final likes = meeting.likes;
//     if (likes.contains(phoneNumber)) {
//       likedMeetings.add(meeting);
//     }
//   }
//   return likedMeetings;
// }

// Future<bool> isMeetingLiked(String meetingId, String phoneNumber) async {
//   try {
//     final meetingDoc = await _meetingsCollection.doc(meetingId).get();
//     final meetingData = meetingDoc.data();
//     if (meetingData != null) {
//       final meeting = MeetingModel.fromMap(meetingData);
//       final likes = meeting.likes;
//       return likes.contains(phoneNumber);
//     }
//     return false;
//   } catch (e) {
//     return false;
//   }
// }

Future<bool> updateMeeting(MeetingModel meetingModel) async {
  try {
    await _meetingsCollection.doc(meetingModel.id).update(meetingModel.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteMeeting(String id) async {
  try {
    await _meetingsCollection.doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<String>> uploadMeetingImages(
    {required List<File> files, required String phoneNumber}) async {
  try {
    final List<String> urls = [];

    for (var element in files) {
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.meetingsCollection)
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
