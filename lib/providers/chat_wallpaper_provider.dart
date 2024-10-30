import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/chat_wallpaper_model.dart';

final chatWallpaperProvider =
    ChangeNotifierProvider<ChatWallpaperProvider>((ref) {
  return ChatWallpaperProvider();
});

class ChatWallpaperProvider extends ChangeNotifier {
  Future<void> setWallpaper(ChatWallpaperModel? model) async {
    final box = Hive.box(HiveConstants.hiveBox);
    await box.put(HiveConstants.chatWallpaper, model?.toJson());
    notifyListeners();
  }

  ChatWallpaperModel? getWallpaper() {
    final box = Hive.box(HiveConstants.hiveBox);
    final chatWallpaperJson =
        box.get(HiveConstants.chatWallpaper, defaultValue: null);

    return chatWallpaperJson != null
        ? ChatWallpaperModel.fromJson(chatWallpaperJson)
        : null;
  }
}
