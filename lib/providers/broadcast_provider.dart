// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/providers/firebase_provider.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/utils.dart';

class FirebaseBroadcastServices {
  getBroadcastsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .where(Dbkeys.broadcastCREATEDBY, isEqualTo: phone)
        .orderBy(Dbkeys.broadcastCREATEDON, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => BroadcastModel.fromJson(document.data()))
            .toList());
  }

  FlutterSecureStorage storage = const FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Lamat.toast(
        "Waiting for recipient to join the chat.",
      );
      return false;
    }
  }

  sendMessageToBroadcastRecipients({
    required List<dynamic> recipientList,
    required BuildContext context,
    required String content,
    required String currentUserNo,
    required String broadcastId,
    required MessageType type,
    required DataModel cachedModel,
  }) async {
    String? privateKey = await storage.read(key: Dbkeys.privateKey);
    content = content.trim();
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(broadcastId)
          .collection(DbPaths.collectionbroadcastsChats)
          .doc('$timestamp--$currentUserNo')
          .set({
        Dbkeys.broadcastmsgCONTENT: content,
        Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgLISToptional: [],
        Dbkeys.broadcastmsgTIME: timestamp,
        Dbkeys.broadcastmsgSENDBY: currentUserNo,
        // Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgTYPE: type.index,
        Dbkeys.broadcastLocations: []
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(broadcastId)
          .update({
        Dbkeys.broadcastLATESTMESSAGETIME: timestamp,
      });
      recipientList.forEach((peer) async {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(peer)
            .get()
            .then((userDoc) async {
          try {
            String? sharedSecret = (await const e2ee.X25519()
                    .calculateSharedSecret(
                        e2ee.Key.fromBase64(privateKey!, false),
                        e2ee.Key.fromBase64(userDoc[Dbkeys.publicKey], true)))
                .toBase64();
            final key = encrypt.Key.fromBase64(sharedSecret);
            cryptor = encrypt.Encrypter(encrypt.Salsa20(key));

            final encrypted = content;
            // encryptWithCRC(content);
            //  AESEncryptData.encryptAES(content, sharedSecret);
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            if (content.trim() != '') {
              var chatId = Lamat.getChatId(currentUserNo, peer);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(broadcastId)
                  .collection(DbPaths.collectionbroadcastsChats)
                  .doc('$timestamp--$currentUserNo')
                  .set({
                Dbkeys.broadcastLocations:
                    FieldValue.arrayUnion(['$chatId--BREAK--$timestamp2'])
              }, SetOptions(merge: true)).then((value) async {
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .set({
                  currentUserNo: true,
                  peer: userDoc[Dbkeys.lastSeen],
                  Dbkeys.isbroadcast: true,
                }, SetOptions(merge: true)).then((value) {
                  Future messaging = FirebaseFirestore.instance
                      .collection(DbPaths.collectionusers)
                      .doc(peer)
                      .collection(Dbkeys.chatsWith)
                      .doc(Dbkeys.chatsWith)
                      .set({
                    currentUserNo: 4,
                  }, SetOptions(merge: true));
                  cachedModel.addMessage(peer, timestamp2, messaging);
                }).then((value) {
                  Future messaging = FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId)
                      .doc('$timestamp2')
                      .set({
                    Dbkeys.from: currentUserNo,
                    Dbkeys.to: peer,
                    Dbkeys.timestamp: timestamp2,
                    Dbkeys.content: encrypted,
                    Dbkeys.messageType: type.index,
                    Dbkeys.isbroadcast: true,
                    Dbkeys.broadcastID: broadcastId,
                    Dbkeys.hasRecipientDeleted: false,
                    Dbkeys.hasSenderDeleted: false,
                    Dbkeys.latestEncrypted: true,
                    Dbkeys.isMuted: false,
                    Dbkeys.sendername:
                        cachedModel.currentUser![Dbkeys.nickname],
                    Dbkeys.isReply: false,
                    Dbkeys.replyToMsgDoc: null,
                    Dbkeys.isForward: false,
                  }, SetOptions(merge: true));
                  cachedModel.addMessage(peer, timestamp2, messaging);
                });
              });
            }
          } catch (e) {
            Lamat.toast('Failed to Send message. Error:$e');
          }
        }).catchError(((e) {
          Lamat.toast('Failed to Send message. Error:$e');
        }));
      });
    } else {
      Lamat.toast('Nothing to Send !');
    }
  }
}

class BroadcastModel {
  Map<String, dynamic> docmap = {};
  BroadcastModel.fromJson(Map<String, dynamic> parsedJSON)
      : docmap = parsedJSON;
}

final firestoreDataProviderMESSAGESforBROADCASTCHATPAGE =
    Provider<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>((ref) {
  return FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE();
});

//  _________ Broadcast Chat page Messages ____________
class FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE {
  var datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;
  String? parentid;
  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading,
              startAfter:
                  datalistSnapshot.isNotEmpty ? datalistSnapshot.last : null,
              refdata: refdataa);
      if (isAfterNewdocCreated == true) {
        datalistSnapshot.clear();
        datalistSnapshot.addAll(snap.docs);
      } else {
        datalistSnapshot.addAll(snap.docs);
      }

      if (snap.docs.length <
          maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading) {
        _hasNext = false;
      }
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isFetchingData = false;
  }

  addDoc(DocumentSnapshot newDoc) {
    int index = datalistSnapshot
        .indexWhere((doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]);
    if (index < 0) {
      List<DocumentSnapshot> list = datalistSnapshot.reversed.toList();
      list.add(newDoc);
      List<DocumentSnapshot> finallist = list.reversed.toList();
      datalistSnapshot = finallist;
    }
  }

  bool checkIfDocAlreadyExits(
      {required DocumentSnapshot newDoc, int? timestamp}) {
    return timestamp != null
        ? datalistSnapshot.indexWhere(
                (doc) => doc[Dbkeys.timestamp] == newDoc[Dbkeys.timestamp]) >=
            0
        : datalistSnapshot.contains(newDoc);
  }

  int totalDocsLoadedLength() {
    return datalistSnapshot.length;
  }

  updateparticulardocinProvider({
    required DocumentSnapshot updatedDoc,
  }) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.timestamp] == updatedDoc[Dbkeys.timestamp]);

    datalistSnapshot.removeAt(index);
    datalistSnapshot.insert(index, updatedDoc);
  }

  deleteparticulardocinProvider({required DocumentSnapshot deletedDoc}) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.timestamp] == deletedDoc[Dbkeys.timestamp]);

    if (index >= 0) {
      datalistSnapshot.removeAt(index);
    }
  }
}
