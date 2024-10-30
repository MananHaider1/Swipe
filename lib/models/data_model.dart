import 'dart:core';
import 'dart:io';
import 'package:async/async.dart' show StreamGroup;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataModel extends Model {
  Map<String?, Map<String, dynamic>?> userData =
      <String?, Map<String, dynamic>?>{};

  final Map<String, Future> _messageStatus = <String, Future>{};

  _getMessageKey(String? peerNo, int? timestamp) => '$peerNo$timestamp';

  getMessageStatus(String? peerNo, int? timestamp) {
    final key = _getMessageKey(peerNo, timestamp);
    return _messageStatus[key] ?? true;
  }

  bool _loaded = false;

  final _storage = Hive.box(HiveConstants.hiveBox);

  addMessage(String? peerNo, int? timestamp, Future future) {
    final key = _getMessageKey(peerNo, timestamp);
    future.then((_) {
      _messageStatus.remove(key);
    });
    _messageStatus[key] = future;
  }

  addUser(DocumentSnapshot<Map<String, dynamic>> user) {
    userData[user.data()![Dbkeys.phone]] = user.data();
    notifyListeners();
  }

  setWallpaper(String? phone, File image) async {
    final dir = await getDir();
    int now = DateTime.now().millisecondsSinceEpoch;
    String path = '${dir.path}/WALLPAPER-$phone-$now';
    await image.copy(path);
    userData[phone]![Dbkeys.wallpaper] = path;
    updateItem(phone!, {Dbkeys.wallpaper: path});
    notifyListeners();
  }

  removeWallpaper(String phone) {
    userData[phone]![Dbkeys.wallpaper] = null;
    String? path = userData[phone]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[phone]![Dbkeys.wallpaper] = null;
    }
    updateItem(phone, {Dbkeys.wallpaper: null});
    notifyListeners();
  }

  getDir() async {
    return await getApplicationDocumentsDirectory();
  }

  updateItem(String key, Map<String, dynamic> value) {
    Map<String, dynamic> old = _storage.get(key) ?? <String, dynamic>{};

    old.addAll(value);
    _storage.put(key, old);
  }

  setAlias(String aliasName, File? image, String phone) async {
    userData[phone]![Dbkeys.aliasName] = aliasName;
    if (image != null) {
      final dir = await getDir();
      int now = DateTime.now().millisecondsSinceEpoch;
      String path = '${dir.path}/$phone-$now';
      await image.copy(path);
      userData[phone]![Dbkeys.aliasAvatar] = path;
    }
    updateItem(phone, {
      Dbkeys.aliasName: userData[phone]![Dbkeys.aliasName],
      Dbkeys.aliasAvatar: userData[phone]![Dbkeys.aliasAvatar],
    });
    notifyListeners();
  }

  removeAlias(String phone) {
    userData[phone]![Dbkeys.aliasName] = null;
    String? path = userData[phone]![Dbkeys.aliasAvatar];
    if (path != null) {
      File(path).delete();
      userData[phone]![Dbkeys.aliasAvatar] = null;
    }
    updateItem(phone, {Dbkeys.aliasName: null, Dbkeys.aliasAvatar: null});
    notifyListeners();
  }

  bool get loaded => _loaded;

  Map<String, dynamic>? get currentUser => _currentUser;

  Map<String, dynamic>? _currentUser;

  Map<String?, int?> get lastSpokenAt => _lastSpokenAt;

  final Map<String?, int?> _lastSpokenAt = {};

  getChatOrder(List<String> chatsWith, String currentUserNo) {
    List<Stream<QuerySnapshot>> messages = [];
    for (var otherNo in chatsWith) {
      String chatId = Lamat.getChatId(currentUserNo, otherNo);
      messages.add(FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId)
          .snapshots());
    }
    StreamGroup.merge(messages).listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot message = snapshot.docs.last;
        _lastSpokenAt[message[Dbkeys.from] == currentUserNo
            ? message[Dbkeys.to]
            : message[Dbkeys.from]] = message[Dbkeys.timestamp];
        notifyListeners();
      }
    });
  }

  DataModel(String? currentUserNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserNo)
        .snapshots()
        .listen((user) {
      _currentUser = user.data();
      notifyListeners();
    });
    
      if (_storage.isOpen) {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .collection(Dbkeys.chatsWith)
            .doc(Dbkeys.chatsWith)
            .snapshots()
            .listen((chatsWith) {
          if (chatsWith.exists) {
            List<Stream<DocumentSnapshot>> users = [];
            List<String> peers = [];
            for (var data in chatsWith.data()!.entries) {
              peers.add(data.key);
              users.add(FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(data.key)
                  .snapshots());
              if (userData[data.key] != null) {
                userData[data.key]![Dbkeys.chatStatus] = chatsWith[data.key];
              }
            }
            if (currentUserNo != null) {
              getChatOrder(peers, currentUserNo);
            }

            notifyListeners();
            Map<String?, Map<String, dynamic>?> newData =
                <String?, Map<String, dynamic>?>{};
            StreamGroup.merge(users).listen((user) {
              if (user.exists) {
                newData[user[Dbkeys.phone]] =
                    user.data() as Map<String, dynamic>?;
                newData[user[Dbkeys.phone]]![Dbkeys.chatStatus] =
                    chatsWith[user[Dbkeys.phone]];
                Map<String, dynamic>? stored =
                    _storage.get(user[Dbkeys.phone]);
                if (stored != null) {
                  newData[user[Dbkeys.phone]]!.addAll(stored);
                }
              }
              userData = Map.from(newData);
              notifyListeners();
            });
          }
          if (!_loaded) {
            _loaded = true;
            notifyListeners();
          }
        });
      }
    
  }
}
