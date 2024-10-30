import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/banned_user_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

Future<bool> isUserBanned(String phone) async {
  // final currentUserRef = ref.watch(currentUserStateProvider);

  final bannedUserCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.bannedUsersCollection);

  try {
    final bannedUserDoc = await bannedUserCollection.doc(phone).get();

    if (bannedUserDoc.exists) {
      final bannedUser = BannedUserModel.fromMap(bannedUserDoc.data()!);
      if (bannedUser.bannedUntil.isAfter(DateTime.now())) {
        return true;
      } else if (bannedUser.isLifetimeBan) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

final isMeBannedProvider = FutureProvider<BannedUserModel?>((ref) async {
  final currentUserRef = ref.watch(currentUserStateProvider);

  if (currentUserRef == null) {
    return null;
  } else {
    final bannedUserCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.bannedUsersCollection);

    try {
      final bannedUserDoc =
          await bannedUserCollection.doc(currentUserRef.phoneNumber).get();

      if (bannedUserDoc.exists) {
        final bannedUser = BannedUserModel.fromMap(bannedUserDoc.data()!);
        return bannedUser;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
});
