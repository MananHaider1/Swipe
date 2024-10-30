import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/subscribers_model.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/block_user_provider.dart';
import 'package:lamatdating/providers/get_current_location_provider.dart';
import 'package:lamatdating/providers/subscriptions/is_subscribed_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';

final filteredOtherUsersProvider =
    FutureProvider.family<List<UserProfileModel>, WidgetRef>((ref, reff) async {
  List<UserProfileModel> usersList = [];
  final otherUsers = ref.watch(otherUsersProvider(reff));
  // final box = Hive.box(HiveConstants.hiveBox);
  // final lastUpdated = box.get(HiveConstants.lastUpdatedKey);
  // if (lastUpdated != null &&
  //     await box.get(HiveConstants.cachedProfiles) != null &&
  //     await box.get(HiveConstants.cachedProfiles) != [] &&
  //     DateTime.now().difference(lastUpdated) > const Duration(hours: 24)) {
  //       for (var user in await box.get(HiveConstants.cachedProfiles)) {
  //          final userProf = UserProfileModel.fromJson(user);
  //           usersList.add(userProf);
  //       }
  //   // usersList.addAll(
  //   //     await box.get(HiveConstants.cachedProfiles));
  // } else {
  otherUsers.whenData((value) {
    usersList.addAll(value);
  });
  // }

  final myProfileProvider = ref.watch(userProfileFutureProvider);
  final isPremiumUserRef = ref.watch(isPremiumUserProvider);
  // AppRes.currentLocationProviderProvider =
  //     ref.watch(getCurrentLocationProviderProvider).value;

  List<UserProfileModel> filteredUserList = [];

  myProfileProvider.whenData((value) {
    if (value != null && AppRes.currentLocationProviderProvider != null) {
      final UserAccountSettingsModel mySettings =
          value.userAccountSettingsModel;

      for (var user in usersList) {
        bool willBeShown = false;
        bool isBoth = false;

        final userAge = DateTime.now().difference(user.birthDay).inDays ~/ 365;
        final userLocation = AppRes.currentLocationProviderProvider!;
        final userGender = user.gender;

        double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                mySettings.location.latitude,
                mySettings.location.longitude,
                userLocation.latitude,
                userLocation.longitude) /
            1;

        if (mySettings.interestedIn == null) {
          isBoth = true;
        }

        bool isWorldWide = mySettings.distanceInKm == null;

        bool isDistanceOk = isWorldWide ||
            (mySettings.distanceInKm! >= (distanceBetweenMeAndUser / 1000));

        if (userAge >= mySettings.minimumAge &&
            userAge <= mySettings.maximumAge &&
            isDistanceOk) {
          if (isBoth) {
            willBeShown = true;
          } else {
            if (mySettings.interestedIn == userGender) {
              willBeShown = true;
            } else {
              willBeShown = false;
            }
          }
        }

        if (willBeShown) {
          filteredUserList.add(user);
        }
      }
    }
  });

  bool isPremiumUser = false;
  isPremiumUserRef.whenData((value) {
    isPremiumUser = value;
  });

  if (!isPremiumUser) {
    filteredUserList.removeWhere((element) {
      return element.userAccountSettingsModel.showOnlyToPremiumUsers ?? false;
    });
  }
  DateTime? ntpTime;
  Future<void> getNTPTime() async {
    ntpTime = DateTime.now().toUtc();
  }

  await getNTPTime();

  // final currentTime = ntpTime!;

  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  for (int i = 0; i < filteredUserList.length; i++) {
    final user = filteredUserList[i];
    if (user.isBoosted == true) {
      final boostType = user.boostType;
      final boostedTime = DateTime.fromMillisecondsSinceEpoch(user.boostedOn!);
      Duration boostDuration = ntpTime!.difference(boostedTime);
      if ((boostType == AppRes.daily &&
              boostDuration > const Duration(hours: 24)) ||
          (boostType == AppRes.weekly &&
              boostDuration > const Duration(hours: 168)) ||
          (boostType == AppRes.monthly &&
              boostDuration > const Duration(hours: 720))) {
        final newUserProf = user.copyWith(isBoosted: false);
        filteredUserList[i] = newUserProf;
        await userCollection
            .doc(newUserProf.phoneNumber)
            .set(newUserProf.toMap(), SetOptions(merge: true));
        debugPrint("NewCachedOtherUsersProvider: Boost Expired");
      }
    }
    if (user.isPremium != null) {
      if (user.isPremium == true && user.premiumExpiryDate != null) {
        final premiumExpireTime =
            DateTime.fromMillisecondsSinceEpoch(user.premiumExpiryDate!);
        if (ntpTime!.isAfter(premiumExpireTime)) {
          final newUserProf = user.copyWith(isPremium: false);
          filteredUserList[i] = newUserProf;
          await userCollection
              .doc(newUserProf.phoneNumber)
              .set(newUserProf.toMap(), SetOptions(merge: true));
          debugPrint("NewCachedOtherUsersProvider: Premium Expired");
        }
      }
    }
  }

  filteredUserList.sort((a, b) {
    if (b.isBoosted && !a.isBoosted) return 1;
    if (!b.isBoosted && a.isBoosted) return -1;
    return 0;
  });

  // if (filteredUserList.isNotEmpty) {
  //   prefss!.setString('usersList', filteredUserList.toString());
  // }

  // List cachedUsersList = [];
  // for (final user in filteredUserList) {
  //   final doc = user.toJson();
  //   cachedUsersList.add(doc);
  // }
  // await box.put(HiveConstants.cachedProfiles, cachedUsersList).then((value) =>
  //     debugPrint("NewCachedOtherUsersProvider: ${cachedUsersList.length}"));
  // await box.put(HiveConstants.lastUpdatedKey, ntpTime);

  return filteredUserList;
});

final allUsersProvider =
    FutureProvider.family<List<UserProfileModel>, WidgetRef>((ref, reff) async {
  List<UserProfileModel> usersList = [];

  final otherUsers = ref.watch(otherUsersProvider(reff));

  otherUsers.whenData((value) {
    usersList.addAll(value);
  });

  final myProfileProvider = ref.watch(userProfileFutureProvider);
  final isPremiumUserRef = ref.watch(isPremiumUserProvider);

  List<UserProfileModel> filteredUserList = [];

  myProfileProvider.whenData((value) {
    if (value != null) {
      filteredUserList.add(value);
      final UserAccountSettingsModel mySettings =
          value.userAccountSettingsModel;

      for (var user in usersList) {
        bool willBeShown = false;
        bool isBoth = false;

        final userAge = DateTime.now().difference(user.birthDay).inDays ~/ 365;
        final userLocation = user.userAccountSettingsModel.location;
        final userGender = user.gender;

        double distanceBetweenMeAndUser = Geolocator.distanceBetween(
                mySettings.location.latitude,
                mySettings.location.longitude,
                userLocation.latitude,
                userLocation.longitude) /
            1;

        if (mySettings.interestedIn == null) {
          isBoth = true;
        }

        bool isWorldWide = mySettings.distanceInKm == null;

        bool isDistanceOk = isWorldWide ||
            (mySettings.distanceInKm! >= (distanceBetweenMeAndUser / 1000));

        if (userAge >= mySettings.minimumAge &&
            userAge <= mySettings.maximumAge &&
            isDistanceOk) {
          if (isBoth) {
            willBeShown = true;
          } else {
            if (mySettings.interestedIn == userGender) {
              willBeShown = true;
            } else {
              willBeShown = false;
            }
          }
        }

        if (willBeShown) {
          filteredUserList.add(user);
        }
      }
    }
  });

  bool isPremiumUser = false;
  isPremiumUserRef.whenData((value) {
    isPremiumUser = value;
  });

  if (!isPremiumUser) {
    filteredUserList.removeWhere((element) {
      return element.userAccountSettingsModel.showOnlyToPremiumUsers ?? false;
    });
  }

  filteredUserList.sort((a, b) {
    if (b.isBoosted && !a.isBoosted) return 1;
    if (!b.isBoosted && a.isBoosted) return -1;
    return 0;
  });

  return filteredUserList;
});

final otherUserProfileFutureProvider =
    FutureProvider.family<UserProfileModel?, String>((ref, phoneNumber) async {
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  // DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
  //     .collection(DbPaths.collectionusers)
  //     .doc(phoneNumber)
  //     .get();

  final docRef = userCollection.doc(phoneNumber);
  final snapshot = await docRef.get();

  return UserProfileModel.fromMap(snapshot.data()!);
});

// Suggested code may be subject to a license. Learn more: ~LicenseLog:2663140503.
final closestUsersProvider =
    Provider.family<List<ClosestUser>, WidgetRef>((ref, reff) {
  List<UserProfileModel> usersList = [];

  final otherUsers = ref.watch(otherUsersProvider(reff));

  otherUsers.whenData((value) {
    usersList.addAll(value);
  });

  List<ClosestUser> closestUsers = [];

  // AppRes.currentLocationProviderProvider ??=
  //     ref.watch(getCurrentLocationProviderProvider).value;

  for (var user in usersList) {
    final userLocation = user.userAccountSettingsModel.location;

    double distanceBetweenMeAndUser = Geolocator.distanceBetween(
            AppRes.currentLocationProviderProvider!.latitude,
            AppRes.currentLocationProviderProvider!.longitude,
            userLocation.latitude,
            userLocation.longitude) /
        1;

    closestUsers
        .add(ClosestUser(user: user, distance: distanceBetweenMeAndUser));
  }

  return closestUsers;
});

class ClosestUser {
  UserProfileModel user;
  double distance;
  ClosestUser({
    required this.user,
    required this.distance,
  });
}

class SimilarUser {
  UserProfileModel user;
  double similarity;
  SimilarUser({
    required this.user,
    required this.similarity,
  });
}

// final otherUsersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
//   final allOtherUsers =
//       await getAllOtherUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);

//   final List<String> blockedUsersIds = [];
//   final usersIblocked =
//       await getBlockUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);
//   for (var user in usersIblocked) {
//     blockedUsersIds.add(user.blockedUserId);
//   }
//   final usersWhoBlockedMe = await getUsersWhoBlockedMe(
//       ref.watch(currentUserStateProvider)!.phoneNumber!);
//   for (var user in usersWhoBlockedMe) {
//     blockedUsersIds.add(user.blockedByUserId);
//   }

//   final filteredUsers = allOtherUsers.where((user) {
//     return !blockedUsersIds.contains(user.phoneNumber);
//   }).toList();

//   return filteredUsers;
// });

final otherUsersProvider =
    FutureProvider.family<List<UserProfileModel>, WidgetRef>((ref, reff) async {
  final box = Hive.box(HiveConstants.hiveBox);
  final allOtherUsers = await getAllOtherUsers(
    ref.watch(currentUserStateProvider)!.phoneNumber!,
    reff,
  );

  final List<String> blockedUsersIds = [];
  final usersIblocked =
      await getBlockUsers(ref.watch(currentUserStateProvider)!.phoneNumber!);
  for (var user in usersIblocked) {
    blockedUsersIds.add(user.blockedUserId);
  }
  final usersWhoBlockedMe = await getUsersWhoBlockedMe(
      ref.watch(currentUserStateProvider)!.phoneNumber!);
  for (var user in usersWhoBlockedMe) {
    blockedUsersIds.add(user.blockedByUserId);
  }

  final filteredUsers = allOtherUsers.where((user) {
    return !blockedUsersIds.contains(user.phoneNumber);
  }).toList();

  // Save the fetched data to Hive
  final cachedUsers = [];
  for (var user in filteredUsers) {
    cachedUsers.add(user.toJson());
  }
  await box.put(HiveConstants.allOtherUsersKey, cachedUsers);

  return filteredUsers;
}
// }
// keepAlive: true
        );

// final followersProvider = FutureProvider<List<UserProfileModel>>((ref) async {});

final otherUsersWithoutBlockedProvider =
    FutureProvider.family<List<UserProfileModel>, WidgetRef>((ref, reff) async {
  return await getAllOtherUsers(
      ref.watch(currentUserStateProvider)!.phoneNumber!, reff,
      getAll: true);
});

final nextUsersProvider = StateProvider<bool>((ref) => false);

class NextUsersProvider extends ChangeNotifier {
  bool _getNextUsers = false;

  bool get getNextUsers => _getNextUsers;

  set getNextUsers(bool value) {
    _getNextUsers = value;
    notifyListeners(); // Notify listeners of the change
  }
}

Future<List<UserProfileModel>> getAllOtherUsers(
    String currentUserId, WidgetRef ref,
    {bool? getAll}) async {
  final box = Hive.box(HiveConstants.hiveBox);
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);
  final getNexxt = ref.watch(nextUsersProvider);
  if (getNexxt) {
    final lastDocId = await box.get('lastDocId');
    // final firstDocId = await box.get('firstDocId');
    final otherUsers = await userCollection
        .where("phoneNumber", isNotEqualTo: currentUserId)
        .startAt(lastDocId)
        .limit(50)
        .get();
    final lastDocIdNew = otherUsers.docs[otherUsers.docs.length - 1].id;
    await box.put('lastDocId', lastDocIdNew);
    final allOtherUsers = otherUsers.docs.map((doc) {
      return UserProfileModel.fromMap(doc.data());
    }).toList();
    debugPrint("AllOtherUsers: ${allOtherUsers.length}");

    return allOtherUsers;
  } else if (getAll ?? false) {
    final otherUsers = await userCollection
        .where("phoneNumber", isNotEqualTo: currentUserId)
        .get();
    final allOtherUsers = otherUsers.docs.map((doc) {
      return UserProfileModel.fromMap(doc.data());
    }).toList();
    debugPrint("AllOtherUsers: ${allOtherUsers.length}");
    return allOtherUsers;
  } else {
    final otherUsers = await userCollection
        .where("phoneNumber", isNotEqualTo: currentUserId)
        .limit(50)
        .get();

    final lastDocId = otherUsers.docs[otherUsers.docs.length - 1].id;
    final firstDocId = otherUsers.docs[0].id;
    await box.put('lastDocId', lastDocId);
    await box.put('firstDocId', firstDocId);

    final allOtherUsers = otherUsers.docs.map((doc) {
      return UserProfileModel.fromMap(doc.data());
    }).toList();
    debugPrint("AllOtherUsers: ${allOtherUsers.length}");

    return allOtherUsers;
  }
}

Future<bool> subToUser(
    {required SubscribersModel subModel,
    required String phoneNumber
    }) async {
  final userCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection);

  //  {
  await userCollection.doc(phoneNumber).set({
    "mySubs": FieldValue.arrayUnion([subModel.toMap()])
  }, SetOptions(merge: true));
  await userCollection.doc(subModel.phoneNumber).set({
    "subbedTo":  FieldValue.arrayUnion([phoneNumber])
  }, SetOptions(merge: true));
  EasyLoading.showSuccess("Subscribed");
  return true;
  // } else {
  //   EasyLoading.showError("Already Subscribed!)");
  //   return false;
  // }
}
