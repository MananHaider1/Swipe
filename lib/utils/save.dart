// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Save {
  static final storage = Hive.box(HiveConstants.hiveBox);
  // LocalStorage(Dbkeys.saved);

  static Future<String> getBase64FromImage({String? imageUrl, File? file}) {
    Completer<String> complete = Completer<String>();
    if (file == null) {
      // ignore: deprecated_member_use
      DefaultCacheManager().getFile(imageUrl!).listen((stream) {
        stream.file.readAsBytes().then((imageBytes) {
          complete.complete(base64Encode(imageBytes));
        });
      });
    } else {
      List<int> imageBytes = file.readAsBytesSync();
      complete.complete(base64Encode(imageBytes));
    }
    return complete.future;
  }

  static Image getImageFromBase64(String encoded) =>
      Image.memory(base64.decode(encoded));

  static saveMessage(String? peerNo, Map<String, dynamic> doc) {
  
      if (storage.isOpen) {
        List<Map<String, dynamic>> saved =
            storage.get(peerNo!)?.cast<Map<String, dynamic>>() ?? [];
        if (!(saved
            .any((doc) => doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp]))) {
          // Don't repeat the saved ones
          saved.add(doc);
          storage.put(peerNo, saved);
        }
      }
    
  }

  static deleteMessage(String? peerNo, Map<String, dynamic> doc) {
   
      if (storage.isOpen) {
        List<Map<String, dynamic>> saved =
            storage.get(peerNo!)?.cast<Map<String, dynamic>>() ?? [];
        saved.removeWhere((d) =>
            d[Dbkeys.timestamp] == doc[Dbkeys.timestamp] &&
            d[Dbkeys.content] == doc[Dbkeys.content]);
        storage.put(peerNo, saved);
      }
    
  }

  static Future<List<Map<String, dynamic>>> getSavedMessages(String? peerNo) {
    Completer<List<Map<String, dynamic>>> completer =
        Completer<List<Map<String, dynamic>>>();
   
      if (storage.isOpen) {
        completer.complete(
            storage.get(peerNo!)?.cast<Map<String, dynamic>>() ?? []);
      }
   
    return completer.future;
  }

  static void saveToDisk(ImageProvider? provider, String filename) async {
    Directory appDocDirectory =
        await (getExternalStorageDirectory() as FutureOr<Directory>);
    Directory dir = Directory('${appDocDirectory.path}/nedo/photos');
    filename = filename.replaceAll(RegExp(r'[^\d]'), '');
    save(Function callback) {
      dir.exists().then((res) {
        if (res) {
          callback(dir);
        } else {
          dir.create(recursive: true).then((dir) {
            callback(dir);
          });
        }
      });
    }

    if (provider is CachedNetworkImageProvider) {
      CachedNetworkImageProvider cache = provider;
      // ignore: deprecated_member_use
      DefaultCacheManager().getFile(cache.url).listen((stream) {
        _save(Directory directory) {
          stream.file.readAsBytes().then((bytes) {
            // File f = File(join(directory.path, '$filename.$extension'));
            // f.writeAsBytes(bytes);
          });
        }

        save(_save);
      });
    } else {
      _save(Directory directory) {
        // File f = File(join(directory.path, '$filename.$extension'));
        // f.writeAsBytes(image.bytes);
      }

      save(_save);
    }
  }
}
