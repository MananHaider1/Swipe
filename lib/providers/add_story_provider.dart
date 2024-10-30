import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/stories_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart' as web;

final getStoryProvider =
    FutureProvider.family<List<StoryModel>, WidgetRef>((ref, reff) async {
  final storiesCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.storiesCollection);
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final machingProvider = ref.watch(matchStreamProvider);
  final otherUsersRef = ref.watch(otherUsersProvider(reff));

  final List<String> storiesUserIds = [phoneNumber!];

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
            storiesUserIds.add(otherUser.phoneNumber);
          }
        }
      }
    });
  });

  // final List<String> storiesUserIds = [];

  otherUsersRef.whenData((otherUsers) {
    for (var otherUser in otherUsers) {
      storiesUserIds.add(otherUser.phoneNumber);
    }
  });

  final snapshot = await storiesCollection
      .where('phoneNumber', whereIn: storiesUserIds)
      .get();

  final List<StoryModel> stories = [];
  for (final doc in snapshot.docs) {
    stories.add(StoryModel.fromMap(doc.data()));
  }

  stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return stories;
});

final _storiesCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.storiesCollection);

Future<bool> addStory(StoryModel storyModel) async {
  try {
    await _storiesCollection.doc(storyModel.id).set(storyModel.toMap());

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> likeStory(String storyId, String phoneNumber) async {
  try {
    final storyDoc = await _storiesCollection.doc(storyId).get();
    final storyData = storyDoc.data();
    if (storyData != null) {
      final story = StoryModel.fromMap(storyData);
      final likes = story.likes;
      if (!likes.contains(phoneNumber)) {
        likes.add(phoneNumber);
        await _storiesCollection.doc(storyId).update({'likes': likes});
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> isLiked(String storyId, String phoneNumber) async {
  try {
    final storyDoc = await _storiesCollection.doc(storyId).get();
    final storyData = storyDoc.data();

    if (storyData != null) {
      final story = StoryModel.fromMap(storyData);
      final likes = story.likes;
      final liked = (likes.contains(phoneNumber)) ? true : false;
      return liked;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<int> getTotalLikes(String storyId) async {
  try {
    final storyDoc = await _storiesCollection.doc(storyId).get();
    final storyData = storyDoc.data();
    if (storyData != null) {
      final story = StoryModel.fromMap(storyData);
      final likes = story.likes;
      return likes.length;
    }
    return 0;
  } catch (e) {
    return 0;
  }
}

Future<List<StoryModel>> getLikedStories(String phoneNumber) async {
  final snapshot = await _storiesCollection.get();
  final List<StoryModel> likedStories = [];
  for (final doc in snapshot.docs) {
    final storyData = doc.data();

    final story = StoryModel.fromMap(storyData);
    final likes = story.likes;
    if (likes.contains(phoneNumber)) {
      likedStories.add(story);
    }
  }
  return likedStories;
}

Future<bool> isStoryLiked(String storyId, String phoneNumber) async {
  try {
    final storyDoc = await _storiesCollection.doc(storyId).get();
    final storyData = storyDoc.data();
    if (storyData != null) {
      final story = StoryModel.fromMap(storyData);
      final likes = story.likes;
      return likes.contains(phoneNumber);
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> updateStory(StoryModel storyModel) async {
  try {
    await _storiesCollection.doc(storyModel.id).update(storyModel.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteStory(String id) async {
  try {
    await _storiesCollection.doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> uploadStoryFile(
    {required File uploadFile, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.storiesCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadFile.path.split('/').last);

    final uploadTask = ref.putFile(uploadFile);
    String? url;
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

Future<String> uploadStorySound(
    {required File uploadSound, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.storiesCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadSound.path.split('/').last);

    final uploadTask = ref.putFile(uploadSound);
    String? url;
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

Future<String> uploadStoryThumbnail(
    {required File uploadThumbnail, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.storiesCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadThumbnail.path.split('/').last);

    final uploadTask = ref.putFile(uploadThumbnail);
    String? url;
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

Future<String> uploadStoryThumbnailWeb(
    {required Uint8List uploadThumbnail, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance.ref().child(
        '+00_STATUS_MEDIA/$phoneNumber/thumb-${currentTime.millisecondsSinceEpoch}-$phoneNumber.jpeg');

    // final uploadTask = ref.putData(uploadThumbnail as File);
    String? url = await web.uploadFileStory(uploadThumbnail, ref);
    // await uploadTask.whenComplete(() async {
    //   url = await ref.getDownloadURL();
    // });

    if (url != null) {
      fileurl = url;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

Future<String> uploadStorySoundImage(
    {required File uploadStorySoundImage, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.storiesCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadStorySoundImage.path.split('/').last);

    final uploadTask = ref.putFile(uploadStorySoundImage);
    String? url;
    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}
