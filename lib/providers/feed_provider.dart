// ignore_for_file: unused_element, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:mime/mime.dart' as mime;

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/comment_model.dart';
import 'package:lamatdating/models/feed_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/nude_detector.dart';
import 'package:lamatdating/providers/other_users_provider.dart';

final getFeedsProvider =
    FutureProvider.family<List<FeedModel>, WidgetRef>((ref, reff) async {
  final feedsCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.feedsCollection);
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  // final machingProvider = ref.watch(matchStreamProvider);
  final otherUsersRef = ref.watch(otherUsersProvider(reff));

  final List<String> feedsUserIds = [phoneNumber!];
  // int addedCount = 0;
  final box = Hive.box(HiveConstants.hiveBox);
  final userProfileRef = await box.get(HiveConstants.currentUserProf);
  final userProfile = UserProfileModel.fromJson(userProfileRef);
  final numbersList = userProfile.following;

  otherUsersRef.whenData((otherUsers) {
    for (var matchUserId in numbersList!) {
      for (var otherUser in otherUsers) {
        if (matchUserId == otherUser.phoneNumber) {
          feedsUserIds.add(otherUser.phoneNumber);
        }
      }
    }
  });

  final snapshot =
      await feedsCollection.where('phoneNumber', whereIn: feedsUserIds).get();

  final List<FeedModel> feeds = [];
  for (final doc in snapshot.docs) {
    feeds.add(FeedModel.fromMap(doc.data()));
  }

  feeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  final cachedFeeds = [];
  for (var feed in feeds) {
    cachedFeeds.add(feed.toJson());
  }
  await box.put(HiveConstants.cachedFeeds, cachedFeeds);

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

// Future<bool> addComment(
//     String feedId, String commentText, String phoneNumber) async {
//   try {
//     final feedRef = _feedsCollection.doc(feedId);
//     final feedDoc = await feedRef.get();
//     final feedData = feedDoc.data();
//     if (feedData != null) {
//       final feed = FeedModel.fromMap(feedData);
//       final newComment = {
//         'phoneNumber': phoneNumber,
//         'text': commentText.toString(),
//         'likes': [],
//       };

//       feed.comments.add(newComment);

//       await feedRef.update({
//         'comments': FieldValue.arrayUnion([newComment])
//       });
//     }
//     return true;
//   } catch (e) {
//     return false;
//   }
// }

Future<bool> addComment(
    String feedId, String commentText, String phoneNumber) async {
  String commentId = userIdDateTime(phoneNumber);
  try {
    final teelRef = _feedsCollection.doc(feedId);
    final teelDoc = await teelRef.get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = FeedModel.fromMap(teelData);
      final newComment = CommentModel(
        id: commentId,
        phoneNumber: phoneNumber,
        text: commentText,
        createdAt: DateTime.now(),
        likes: [],
      );

      teel.comments.add(newComment.toMap());

      await teelRef.update({
        'comments': FieldValue.arrayUnion([newComment.toMap()])
      });
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> updateComment(String feedId, CommentModel updatedComment) async {
  try {
    final teelRef = _feedsCollection.doc(feedId);

    // Transaction to ensure data consistency
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document snapshot
      final documentSnapshot = await transaction.get(teelRef);

      // Check if document exists
      if (!documentSnapshot.exists) {
        return false;
      }

      // Existing comments data
      final existingComments = documentSnapshot.data()!['comments'] as List;

      // Find the comment to update
      final int index = existingComments.indexWhere((comment) =>
          comment['phoneNumber'] == updatedComment.phoneNumber &&
          comment['text'] == updatedComment.text);

      if (index == -1) {
        // Comment not found, return false
        return false;
      }

      // Update the comment at the index
      transaction.update(teelRef, {
        'comments': FieldValue.arrayRemove(existingComments[index]),
      });
      transaction.update(teelRef, {
        'comments': FieldValue.arrayUnion([updatedComment.toMap()])
      });

      return true;
    });
  } catch (e) {
    return false;
  }
}

Future<bool> likeComment(
    String commentId, String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _feedsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = FeedModel.fromMap(teelData);
      final comments =
          teel.comments.map((c) => CommentModel.fromMap(c)).toList();
      for (var comment in comments) {
        if (comment.id == commentId) {
          if (!comment.likes!.contains(phoneNumber)) {
            comment.likes!.add(phoneNumber);
          } else {
            comment.likes!.remove(phoneNumber);
          }
          break;
        }
      }
      await _feedsCollection
          .doc(teelId)
          .update({'comments': comments.map((c) => c.toMap()).toList()});
    }
    return true;
  } catch (e) {
    return false;
  }
}

Stream<bool> isLikedComment(
    String teelId, String commentId, String phoneNumber) {
  return _feedsCollection.doc(teelId).snapshots().map((snapshot) {
    final teelData = snapshot.data();
    if (teelData != null) {
      final teel = FeedModel.fromMap(teelData);
      final comments = teel.comments;
      final comment = CommentModel.fromMap(
          comments.firstWhere((element) => element['id'] == commentId));
      final likes = comment.likes;
      final liked = (likes!.contains(phoneNumber)) ? true : false;
      return liked;
    }
    return false;
  });
}

Stream<int> getTotalLikesComment(
  String teelId,
  String commentId,
) {
  return _feedsCollection.doc(teelId).snapshots().map((snapshot) {
    final teelData = snapshot.data();
    if (teelData != null) {
      final teel = FeedModel.fromMap(teelData);
      final comments = teel.comments;
      final comment = CommentModel.fromMap(
          comments.firstWhere((element) => element['id'] == commentId));
      final likes = comment.likes!.length;

      return likes;
    }
    return 0;
  });
}

String userIdDateTime(String phoneNumber) {
  var now = DateTime.now();
  var formatter =
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS'); // Added '.SSS' for milliseconds
  String formattedDate = formatter.format(now);
  return phoneNumber + formattedDate;
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
        _feedsCollection.doc(feedId).update({'likes': likes});
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(
              phoneNumber,
            )
            .set({'myPostLikes': FieldValue.increment(1)},
                SetOptions(merge: true));
      } else {
        likes.remove(phoneNumber);
        _feedsCollection.doc(feedId).update({'likes': likes});
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(
              phoneNumber,
            )
            .set({'myPostLikes': FieldValue.increment(-1)},
                SetOptions(merge: true));
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
    {required List<File> files, required String phoneNumber}) async {
  try {
    final List<String> urls = [];

    for (var element in files) {
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.feedsCollection)
          .child(phoneNumber)
          .child(currentTime.millisecondsSinceEpoch.toString() +
              phoneNumber +
              element.path.split('/').last);

      final uploadTask = ref.putFile(element);
      String? url;
      await detectNudity(element.path).then((value) async {
        if (value == false) {
          await uploadTask.whenComplete(() async {
            url = await ref.getDownloadURL();
          });
        } else {
          EasyLoading.showError('Image contains nudity');
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

Future<List<String>> uploadFeedImagesWeb(
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
