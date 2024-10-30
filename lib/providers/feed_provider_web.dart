// ignore_for_file: unused_element

import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/feed_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:mime/mime.dart' as mime;
// import 'package:universal_html/html.dart';

final getFeedsProvider =
    FutureProvider.family<List<FeedModel>, WidgetRef>((ref, reff) async {
  final feedsCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.feedsCollection);
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final machingProvider = ref.watch(matchStreamProvider);
  final otherUsersRef = ref.watch(otherUsersProvider(reff));

  final List<String> feedsUserIds = [phoneNumber!];
  int addedCount = 0;

  machingProvider.whenData((matches) {
    matches.removeWhere((element) => element.isMatched == false);
    otherUsersRef.whenData((otherUsers) {
      final List<String> matchUserIds = [];
      for (var match in matches) {
        matchUserIds.add(match.userIds
            .firstWhere((phoneNumber) => phoneNumber != phoneNumber));
      }

      for (var matchUserId in matchUserIds) {
        for (var otherUser in otherUsers) {
          if (matchUserId == otherUser.phoneNumber) {
            if (addedCount <= 28) {
              feedsUserIds.add(otherUser.phoneNumber);
              addedCount++;
            } else {
              break;
            }
          }
        }
      }
    });
  });

  // final List<String> feedsUserIds = [];

  // otherUsersRef.whenData((otherUsers) {
  //   for (var otherUser in otherUsers) {
  //     if (addedCount <= 25) {
  //       feedsUserIds.add(otherUser.phoneNumber);
  //       addedCount++;
  //     } else {
  //       break; // Stop adding when 29 items are reached
  //     }
  //   }
  // });

  final snapshot =
      await feedsCollection.where('phoneNumber', whereIn: feedsUserIds).get();

  final List<FeedModel> feeds = [];
  for (final doc in snapshot.docs) {
    feeds.add(FeedModel.fromMap(doc.data()));
  }

  feeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return feeds;
});

final _feedsCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.feedsCollection);

Future<bool> addFeed(FeedModel feedModel) async {
  try {
    await _feedsCollection.doc(feedModel.id).set(feedModel.toMap());

    return true;
  } catch (e) {
    return false;
  }
}

final commentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, feedId) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.feedsCollection)
      .doc(feedId)
      .snapshots()
      .map((snapshot) =>
          List<Map<String, dynamic>>.from(snapshot.data()?['comments'] ?? []));
});

Stream<int> commentsCountStream(String feedId) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.feedsCollection)
      .doc(feedId)
      .snapshots()
      .map((snapshot) =>
          List<Map<String, dynamic>>.from(snapshot.data()?['comments'] ?? [])
              .length);
}

Future<bool> addComment(
    String feedId, String commentText, String phoneNumber) async {
  try {
    final feedRef = _feedsCollection.doc(feedId);
    final feedDoc = await feedRef.get();
    final feedData = feedDoc.data();
    if (feedData != null) {
      final feed = FeedModel.fromMap(feedData);
      final newComment = {
        'phoneNumber': phoneNumber,
        'text': commentText.toString(),
        'likes': [],
      };

      feed.comments.add(newComment);

      await feedRef.update({
        'comments': FieldValue.arrayUnion([newComment])
      });
    }
    return true;
  } catch (e) {
    return false;
  }
}

final removeCommentProvider = Provider<void>((ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;

  void removeComment(String feedId, String commentText) async {
    final feedRef = _feedsCollection.doc(feedId);
    final feedSnapshot = await feedRef.get();

    if (!feedSnapshot.exists) {
      throw Exception('Feed does not exist');
    }

    final feed = FeedModel.fromMap(feedSnapshot.data()!);
    final commentToRemove = feed.comments.firstWhere(
        (comment) =>
            comment['phoneNumber'] == phoneNumber! &&
            comment['text'] == commentText,
        orElse: () => {});

    if (commentToRemove.isEmpty) {
      throw Exception('Comment does not exist');
    }

    feed.comments.remove(commentToRemove);

    await feedRef.update({
      'comments': FieldValue.arrayRemove([commentToRemove])
    });
  }
});

Future<bool> likeFeed(String feedId, String phoneNumber) async {
  try {
    final feedDoc = await _feedsCollection.doc(feedId).get();
    final feedData = feedDoc.data();
    if (feedData != null) {
      final feed = FeedModel.fromMap(feedData);
      final likes = feed.likes;
      if (!likes.contains(phoneNumber)) {
        likes.add(phoneNumber);
        await _feedsCollection.doc(feedId).update({'likes': likes});
      } else {
        likes.remove(phoneNumber);
        await _feedsCollection.doc(feedId).update({'likes': likes});
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

// Future<bool> unlikeFeed(String feedId, String phoneNumber) async {
//   try {
//     final feedDoc = await _feedsCollection.doc(feedId).get();
//     final feedData = feedDoc.data();
//     if (feedData != null) {
//       final feed = FeedModel.fromMap(feedData);
//       final likes = feed.likes;
//       if (likes.contains(phoneNumber)) {
//         likes.remove(phoneNumber);
//         await _feedsCollection.doc(feedId).update({'likes': likes});
//       }
//     }
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

Stream<bool> isLiked(String feedId, String phoneNumber) {
  return _feedsCollection.doc(feedId).snapshots().map((snapshot) {
    final feedData = snapshot.data();
    if (feedData != null) {
      final feed = FeedModel.fromMap(feedData);
      final likes = feed.likes;
      final liked = (likes.contains(phoneNumber)) ? true : false;
      return liked;
    }
    return false;
  });
}

Stream<int> getTotalLikes(String feedId) {
  return _feedsCollection.doc(feedId).snapshots().map((snapshot) {
    final feedData = snapshot.data();
    if (feedData != null) {
      final feed = FeedModel.fromMap(feedData);
      final likes = feed.likes;
      return likes.length;
    }
    return 0;
  });
}

Future<List<FeedModel>> getLikedFeeds(String phoneNumber) async {
  final snapshot = await _feedsCollection.get();
  final List<FeedModel> likedFeeds = [];
  for (final doc in snapshot.docs) {
    final feedData = doc.data();

    final feed = FeedModel.fromMap(feedData);
    final likes = feed.likes;
    if (likes.contains(phoneNumber)) {
      likedFeeds.add(feed);
    }
  }
  return likedFeeds;
}

Future<bool> isFeedLiked(String feedId, String phoneNumber) async {
  try {
    final feedDoc = await _feedsCollection.doc(feedId).get();
    final feedData = feedDoc.data();
    if (feedData != null) {
      final feed = FeedModel.fromMap(feedData);
      final likes = feed.likes;
      return likes.contains(phoneNumber);
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> updateFeed(FeedModel feedModel) async {
  try {
    await _feedsCollection.doc(feedModel.id).update(feedModel.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteFeed(String id) async {
  try {
    await _feedsCollection.doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<String>> uploadFeedImages(
    {required List<Uint8List?> files, required String phoneNumber}) async {
  try {
    final List<String> urls = [];
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    for (var element in files) {
      final currentTime = DateTime.now();
      final imageRef = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.feedsCollection)
          .child(phoneNumber)
          .child('${currentTime.millisecondsSinceEpoch}$phoneNumber');

      // final storageRef = ref;

      String? downloadUrl;

      final uploadTask = imageRef.putData(element!, metadata);
      await uploadTask.whenComplete(() async {
        downloadUrl = await imageRef.getDownloadURL();
      });

      if (downloadUrl != null) {
        urls.add(downloadUrl!);
      }
    }

    return urls;
  } catch (e) {
    return [];
  }
}

Future<List<String>> uploadFeedImagesAsBytes(
    {required List<Uint8List> files, required String phoneNumber}) async {
  try {
    final List<String> urls = [];

    for (var element in files) {
      final base64Data = base64Encode(element);
      final mimeType = mime.lookupMimeType(base64Data);
      if (kDebugMode) {
        print("MIMETYPE: $mimeType");
      }
      final filename =
          '${math.Random().nextInt(100000000000000000)}.${mime.extensionFromMime(mimeType!)}';
      if (kDebugMode) {
        print("FILENAME: $filename");
      }
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.feedsCollection)
          .child(phoneNumber)
          .child(currentTime.millisecondsSinceEpoch.toString() +
              phoneNumber +
              filename);

      final uploadTask = ref.putData(element);
      String? url;
      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
        if (kDebugMode) {
          print("URL: $url");
        }
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
