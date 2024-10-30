import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import "package:universal_html/html.dart" as h;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/chat_item_model.dart';

final chatStreamProviderProvider =
    StreamProvider.family<List<ChatItemModel>, String>((ref, matchId) {
  final chatCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.matchCollection)
      .doc(matchId)
      .collection(FirebaseConstants.chatCollection);

  return chatCollection.orderBy('createdAt', descending: true).snapshots().map(
    (event) {
      return event.docs.isEmpty
          ? []
          : event.docs.map((doc) {
              return ChatItemModel.fromMap(doc.data());
            }).toList();
    },
  );
});

final chatProvider = Provider<ChatProvider>((ref) {
  return ChatProvider();
});

class ChatProvider {
  Future<bool> createChatItem(String matchId, ChatItemModel chat) async {
    final chatCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.matchCollection)
        .doc(matchId)
        .collection(FirebaseConstants.chatCollection);

    try {
      await chatCollection.doc(chat.id).set(chat.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  //Delete chat
  Future<bool> deleteChatItem(String matchId, String chatId) async {
    final chatCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.matchCollection)
        .doc(matchId)
        .collection(FirebaseConstants.chatCollection);

    try {
      await chatCollection.doc(chatId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  //Clear all chats
  Future<bool> clearChat(String matchId) async {
    final chatCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.matchCollection)
        .doc(matchId)
        .collection(FirebaseConstants.chatCollection);

    try {
      await chatCollection.get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //Update chat
  Future<bool> updateChatItem(String matchId, ChatItemModel chat) async {
    final chatCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.matchCollection)
        .doc(matchId)
        .collection(FirebaseConstants.chatCollection);

    try {
      await chatCollection.doc(chat.id).update(chat.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadFile(
      {required File file, required String matchId}) async {
    final currentTime = DateTime.now();

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.chatCollection)
          .child(matchId)
          .child(currentTime.millisecondsSinceEpoch.toString());

      final uploadTask = ref.putFile(file);
      String? url;
      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFileWeb(
      {required h.File file, required String matchId}) async {
    final currentTime = DateTime.now();
    final ref = FirebaseStorage.instance
        .ref()
        .child(FirebaseConstants.chatCollection)
        .child(matchId)
        .child(currentTime.millisecondsSinceEpoch.toString());

    try {
      final reader = h.FileReader();
      final completer = Completer<String?>();
      // String? downloadUrl;

      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final uploadTask =
            ref.child(file.name).putData(reader.result as Uint8List);
        uploadTask.then((taskSnapshot) async {
          final downloadUrl = await taskSnapshot.ref.getDownloadURL();
          completer.complete(downloadUrl);
        });
      });

      return completer.future;

      // final uploadTask = ref.putFile(file);
      // String? url;
      // await uploadTask.whenComplete(() async {
      //   url = await ref.getDownloadURL();
      // });

      // return url;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadFileAsBytes(
      {required file, required String matchId}) async {
    final currentTime = DateTime.now();

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child(FirebaseConstants.chatCollection)
          .child(matchId)
          .child(currentTime.millisecondsSinceEpoch.toString());

      final uploadTask = ref.putData(file);
      String? url;
      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      return url;
    } catch (e) {
      return null;
    }
  }
}
