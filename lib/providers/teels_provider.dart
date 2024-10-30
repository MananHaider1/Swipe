// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/comment_model.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';

final getTeelsProvider = FutureProvider<List<TeelsModel>>((ref) async {
  final teelsCollection =
      FirebaseFirestore.instance.collection(FirebaseConstants.teelsCollection);
  // final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;
  // final machingProvider = ref.watch(matchStreamProvider);
  // final otherUsersRef = ref.watch(otherUsersProvider);

  // final List<String> teelsUserIds = [currentUserId!];

  // machingProvider.whenData((matches) {
  //   otherUsersRef.whenData((otherUsers) {
  //     final List<String> matchUserIds = [];
  //     for (var match in matches) {
  //       matchUserIds.add(match.userIds
  //           .firstWhere((phoneNumber) => phoneNumber != currentUserId));
  //     }

  //     for (var matchUserId in matchUserIds) {
  //       for (var otherUser in otherUsers) {
  //         if (matchUserId == otherUser.phoneNumber ||
  //             matchUserId != otherUser.phoneNumber) {
  //           teelsUserIds.add(otherUser.phoneNumber);
  //         }
  //       }
  //     }
  //   });
  // });

  // otherUsersRef.whenData((otherUsers) {
  //   int addedCount = 0;
  //   for (var otherUser in otherUsers) {
  //     if (addedCount <= 28) {
  //       teelsUserIds.add(otherUser.phoneNumber);
  //       addedCount++;
  //     } else {
  //       break;
  //     }
  //   }
  // });

  final snapshot = await teelsCollection.get();

  final List<TeelsModel> teels = [];
  for (final doc in snapshot.docs) {
    teels.add(TeelsModel.fromMap(doc.data()));
  }

  teels.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return teels;
});

final _teelsCollection =
    FirebaseFirestore.instance.collection(FirebaseConstants.teelsCollection);

Future<bool> addTeel(TeelsModel teelModel) async {
  try {
    await _teelsCollection.doc(teelModel.id).set(teelModel.toMap());

    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> likeTeel(String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final likes = teel.likes;
      if (!likes.contains(phoneNumber)) {
        likes.add(phoneNumber);
        await _teelsCollection.doc(teelId).update({'likes': likes});
      } else {
        likes.remove(phoneNumber);
        await _teelsCollection.doc(teelId).update({'likes': likes});
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> saveTeel(String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final saves = teel.saves;
      if (!saves.contains(phoneNumber)) {
        saves.add(phoneNumber);
        await _teelsCollection.doc(teelId).update({'saves': saves});
      } else {
        saves.remove(phoneNumber);
        await _teelsCollection.doc(teelId).update({'saves': saves});
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> increaseTeelViewCount(String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final views = teel.views;
      if (!views.contains(phoneNumber)) {
        views.add(phoneNumber);
        await _teelsCollection.doc(teelId).update({'views': views});
      }
    }
    return true;
  } catch (e) {
    return false;
  }
}

final commentsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, teelId) {
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.teelsCollection)
      .doc(teelId)
      .snapshots()
      .map((snapshot) =>
          List<Map<String, dynamic>>.from(snapshot.data()?['comments'] ?? []));
});

Future<bool> addComment(
    String teelId, String commentText, String phoneNumber) async {
  String commentId = userIdDateTime(phoneNumber);
  try {
    final teelRef = _teelsCollection.doc(teelId);
    final teelDoc = await teelRef.get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
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

Future<bool> likeComment(
    String commentId, String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
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
      await _teelsCollection
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
  return _teelsCollection.doc(teelId).snapshots().map((snapshot) {
    final teelData = snapshot.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
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
  return _teelsCollection.doc(teelId).snapshots().map((snapshot) {
    final teelData = snapshot.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
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

// Future<bool> isLiked(String teelId, String phoneNumber) async {
//   try {
//     final teelDoc = await _teelsCollection.doc(teelId).get();
//     final teelData = teelDoc.data();

//     if (teelData != null) {
//       final teel = TeelsModel.fromMap(teelData);
//       final likes = teel.likes;
//       final liked = (likes.contains(phoneNumber)) ? true : false;
//       return liked;
//     }
//     return false;
//   } catch (e) {
//     return false;
//   }
// }

final getTotalLikes = StreamProvider.family<int, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.likes;
        yield likes.length;
      }
    }
  } catch (e) {
    yield 0;
  }
});

final getTeelLikes =
    StreamProvider.family<List<String>, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.likes;
        yield likes;
      }
    }
  } catch (e) {
    yield [];
  }
});

final getTeelSaves =
    StreamProvider.family<List<String>, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final likes = teel.saves;
        yield likes;
      }
    }
  } catch (e) {
    yield [];
  }
});

final getFollowers =
    StreamProvider.family<List<String>, String>((ref, phoneNumber) async* {
  try {
    final userDoc = _userCollection.doc(phoneNumber).snapshots();
    await for (var snapshot in userDoc) {
      final userData = snapshot.data();
      if (userData != null) {
        final user = UserProfileModel.fromMap(userData);
        final followers = user.followers;
        yield followers!;
      }
    }
  } catch (e) {
    yield [];
  }
});

final _userCollection = FirebaseFirestore.instance
    .collection(FirebaseConstants.userProfileCollection);

final isLikeTeel =
    StreamProvider.family<bool, List<String>>((ref, list) async* {
  try {
    final teelDoc = _teelsCollection.doc(list[0]).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final isLike = teel.likes.contains(list[1]);
        yield isLike;
      }
    }
  } catch (e) {
    yield false;
  }
});

final getTotalSaves = StreamProvider.family<int, String>((ref, teelId) async* {
  try {
    final teelDoc = _teelsCollection.doc(teelId).snapshots();
    await for (var snapshot in teelDoc) {
      final teelData = snapshot.data();
      if (teelData != null) {
        final teel = TeelsModel.fromMap(teelData);
        final saves = teel.saves;
        yield saves.length;
      }
    }
  } catch (e) {
    yield 0;
  }
});

final totalCommentLikesProvider =
    StreamProvider.family<int, String>((ref, parameters) async* {
  String commentId = parameters.split(',')[0];
  String teelId = parameters.split(',')[1];

  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final comments =
          teel.comments.map((c) => CommentModel.fromMap(c)).toList();
      for (var comment in comments) {
        if (comment.id == commentId) {
          yield comment.likes!.length;
        }
      }
    }
  } catch (e) {
    yield 0;
  }
});

Future<List<TeelsModel>> getLikedTeels(String phoneNumber) async {
  final snapshot = await _teelsCollection.get();
  final List<TeelsModel> likedTeels = [];
  for (final doc in snapshot.docs) {
    final teelData = doc.data();

    final teel = TeelsModel.fromMap(teelData);
    final likes = teel.likes;
    if (likes.contains(phoneNumber)) {
      likedTeels.add(teel);
    }
  }
  return likedTeels;
}

Future<bool> isTeelLiked(String teelId, String phoneNumber) async {
  try {
    final teelDoc = await _teelsCollection.doc(teelId).get();
    final teelData = teelDoc.data();
    if (teelData != null) {
      final teel = TeelsModel.fromMap(teelData);
      final likes = teel.likes;
      return likes.contains(phoneNumber);
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> updateTeel(TeelsModel teelModel) async {
  try {
    await _teelsCollection.doc(teelModel.id).update(teelModel.toMap());
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> deleteTeel(String id) async {
  try {
    await _teelsCollection.doc(id).delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> uploadTeelFile(
    {required File uploadFile, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
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

Future<String> uploadTeelSound(
    {required File uploadSound, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
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

Future<String> uploadTeelThumbnail(
    {required File uploadThumbnail, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
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

Future<String> uploadTeelSoundImage(
    {required File uploadTeelSoundImage, required String phoneNumber}) async {
  try {
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
        .child(phoneNumber)
        .child(currentTime.millisecondsSinceEpoch.toString() +
            phoneNumber +
            uploadTeelSoundImage.path.split('/').last);

    final uploadTask = ref.putFile(uploadTeelSoundImage);
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

final getHashtagsProvider = FutureProvider<List<DocumentSnapshot>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection(FirebaseConstants.hashtags)
      .get();
  return snapshot.docs;
});

Future<String> uploadTeelFileWeb(
    {Uint8List? uploadFile,
    Uint8List? uploadPhoto,
    required String phoneNumber,
    required String type}) async {
  String? url;
  String fileurl = "";
  try {
    if (uploadFile != null) {
      final metadata = SettableMetadata(
        contentType: 'video/mp4',
      );
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.teelsCollection)
          .child(phoneNumber)
          .child("${currentTime.millisecondsSinceEpoch}$phoneNumber.mp4");

      // final videoBytes = await convertFileToBytes(uploadFile);

      final uploadTask = ref.putData(uploadFile, metadata);

      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });
    } else {
      final currentTime = DateTime.now();
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.teelsCollection)
          .child(phoneNumber)
          .child(
              "${currentTime.millisecondsSinceEpoch}${phoneNumber}photo.jpg");

      final uploadTask = ref.putData(uploadPhoto!);

      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });
    }

    if (url != null) {
      fileurl = url!;
    }

    return fileurl;
  } catch (e) {
    return "";
  }
}

Future<String> uploadTeelThumbnailWeb(
    {required Uint8List uploadThumbnail, required String phoneNumber}) async {
  try {
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );
    String fileurl = "";

    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.teelsCollection)
        .child(phoneNumber)
        .child("${currentTime.millisecondsSinceEpoch}${phoneNumber}thumb.jpeg");

    final uploadTask = ref.putData(uploadThumbnail, metadata);
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
