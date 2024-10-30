import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

final userProfileFutureProvider =
    FutureProvider<UserProfileModel?>((ref) async {
  final box = Hive.box(HiveConstants.hiveBox);
 UserProfileModel? userProf;

  // // Check if data is already stored and within 24 hours
  // final lastUpdated = box.get(HiveConstants.lastUserProfileUpdatedKey);
  // if (lastUpdated != null &&
  //     DateTime.now().difference(lastUpdated) < const Duration(days: 1)) {
  //   // Use data from Hive if it's recent
  //   final oldUser =
  //       UserProfileModel.fromJson(box.get(HiveConstants.currentUserProf));
  //   final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  //   if (oldUser.phoneNumber == phoneNumber) {
  //     return oldUser;
  //   }
  // }

  // Fetch new data if not available or outdated in Hive
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final docRef = userCollection.doc(phoneNumber);
   await docRef.get().then((event) async {
    if (event.exists) {
      final doc = event.data();
      final userNumber = doc?['phoneNumber'];
      if (userNumber != null && doc != null) {
         userProf = UserProfileModel.fromMap(doc);
 if (userProf != null) {
  // Save data to Hive
  await box.put(HiveConstants.currentUserProf, userProf!.toJson());
  debugPrint("User Profile =======> SET: ${userProf!.toJson()}");
  await box.put(
      HiveConstants.lastUserProfileUpdatedKey, DateTime.now().toUtc());
  AppRes.phoneNumber = phoneNumber;
  box.put(HiveConstants.userSet, true);}
  return userProf;
      }
    } else {
      return userProf;
    }
  });

  return userProf;
});

final userProfileNotifier = Provider<UserProfileNotifier>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier {
  final _userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  Future<bool> createUserProfile(UserProfileModel userProfileModel) async {
    final box = Hive.box(HiveConstants.hiveBox);
    try {
      UserProfileModel? newUserProfile;

      newUserProfile = userProfileModel;

      await _userCollection
          .doc(newUserProfile.phoneNumber)
          .set(newUserProfile.toMap(), SetOptions(merge: true));
      await box.put(HiveConstants.currentUserProf, newUserProfile.toJson());
      debugPrint(
          "User Profile Cached =======> SET: ${newUserProfile.toJson()}");
      await box.put(
          HiveConstants.lastUserProfileUpdatedKey, DateTime.now().toUtc());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserProfile(UserProfileModel userProfileModel) async {
    final box = Hive.box(HiveConstants.hiveBox);
    try {
      UserProfileModel newUserProfile = userProfileModel;

      await _userCollection
          .doc(newUserProfile.phoneNumber)
          .update(newUserProfile.toMap());
      // Save data to Hive
      await box.put(HiveConstants.currentUserProf, newUserProfile.toJson());
      debugPrint(
          "User Profile Cached =======> SET: ${newUserProfile.toJson()}");
      await box.put(
          HiveConstants.lastUserProfileUpdatedKey, DateTime.now().toUtc());
      return true;
    } catch (e) {
      return false;
    }
  }

  //Update Online Status
  Future<void> updateOnlineStatus({
    required bool isOnline,
    required String phoneNumber,
  }) async {
    await _userCollection.doc(phoneNumber).update({"isOnline": isOnline});
  }

  Future<void> updateAgoraToken({
    required String? agoraToken,
    required String phoneNumber,
  }) async {
    await _userCollection.doc(phoneNumber).update({"agoraToken": agoraToken});
  }

  Future<void> saveFavouriteMusic({
    required String? soundId,
    required String phoneNumber,
  }) async {
    final doc = await _userCollection.doc(phoneNumber).get();
    final favSongs = List<String>.from(doc.data()?['favSongs'] ?? []);

    if (favSongs.contains(soundId)) {
      // If the soundId is already in favSongs, remove it
      await _userCollection.doc(phoneNumber).update({
        "favSongs": FieldValue.arrayRemove([soundId])
      });
    } else {
      // If the soundId is not in favSongs, add it
      await _userCollection.doc(phoneNumber).update({
        "favSongs": FieldValue.arrayUnion([soundId])
      });
    }
  }

  Future<void> saveFavouriteTeels({required String? id, ref}) async {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final doc = await _userCollection.doc(phoneNumber).get();
    final favSongs = List<String>.from(doc.data()?['favTeels'] ?? []);

    if (favSongs.contains(id)) {
      // If the soundId is already in favSongs, remove it
      await _userCollection.doc(phoneNumber).update({
        "favTeels": FieldValue.arrayRemove([id])
      });
    } else {
      // If the soundId is not in favSongs, add it
      await _userCollection.doc(phoneNumber).update({
        "favTeels": FieldValue.arrayUnion([id])
      });
    }
  }

  Future<void> followUnfollow({required String? followUser, ref}) async {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final doc = await _userCollection.doc(phoneNumber).get();
    final docUser = await _userCollection.doc(followUser).get();
    final follow = List<String>.from(docUser.data()?['followers'] ?? []);
    final following = List<String>.from(doc.data()?['following'] ?? []);

    if (follow.contains(phoneNumber)) {
      await _userCollection.doc(followUser).update({
        "followers": FieldValue.arrayRemove([phoneNumber])
      });
    } else {
      await _userCollection.doc(followUser).update({
        "followers": FieldValue.arrayUnion([phoneNumber])
      });
    }
    if (following.contains(followUser)) {
      await _userCollection.doc(phoneNumber).update({
        "following": FieldValue.arrayRemove([followUser])
      });
    } else {
      await _userCollection.doc(phoneNumber).update({
        "following": FieldValue.arrayUnion([followUser])
      });
    }
  }

  Future<List<String>> getFavouriteMusic({
    required String phoneNumber,
  }) async {
    final userDoc = await _userCollection.doc(phoneNumber).get();
    final favSongsIds = List<String>.from(userDoc.data()?['favSongs'] ?? []);
    return favSongsIds;
  }
}
