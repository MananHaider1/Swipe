import 'dart:convert';
import 'package:collection/collection.dart';

class StoryModel {
  String id;
  String phoneNumber;
  DateTime createdAt;
  String? caption;
  String? uploadFile;
  String? postType;
  String? thumbnail;
  String? postSound;
  String? duration;
  bool isOrignalSound;
  String? postHashTag;
  String? singer;
  String? soundImage;
  String? soundTitle;
  List<String> likes;
  String? soundId;
  StoryModel({
    required this.isOrignalSound,
    required this.postType,
    this.postHashTag,
    required this.singer,
    required this.postSound,
    required this.soundId,
    required this.soundImage,
    required this.soundTitle,
    required this.thumbnail,
    this.duration,
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
    this.caption,
    required this.uploadFile,
    required this.likes,
  });

  StoryModel copyWith({
    String? id,
    String? phoneNumber,
    DateTime? createdAt,
    String? caption,
    String? uploadFile,
    String? postType,
    String? thumbnail,
    String? postSound,
    String? duration,
    bool? isOrignalSound,
    String? postHashTag,
    String? singer,
    String? soundImage,
    String? soundTitle,
    List<String>? likes,
    String? soundId,
  }) {
    return StoryModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
      uploadFile: uploadFile ?? this.uploadFile,
      likes: likes ?? this.likes,
      postType: postType ?? this.postType,
      isOrignalSound: isOrignalSound ?? this.isOrignalSound,
      postSound: postSound ?? this.postSound,
      singer: singer ?? this.singer,
      soundId: soundId ?? this.soundId,
      soundImage: soundImage ?? this.soundImage,
      soundTitle: soundTitle ?? this.soundTitle,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      postHashTag: postHashTag ?? this.postHashTag,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});
    if (caption != null) {
      result.addAll({'caption': caption});
    }
    result.addAll({'uploadFile': uploadFile});
    result.addAll({'postType': postType});
    result.addAll({'isOrignalSound': isOrignalSound});
    result.addAll({'postSound': postSound});
    result.addAll({'singer': singer});
    result.addAll({'soundId': soundId});
    result.addAll({'soundImage': soundImage});
    result.addAll({'soundTitle': soundTitle});
    result.addAll({'thumbnail': thumbnail});
    result.addAll({'duration': duration});
    result.addAll({'postHashTag': postHashTag});
    result.addAll({'likes': likes});

    return result;
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      caption: map['caption'],
      uploadFile: map['uploadFile'],
      postType: map['postType'],
      isOrignalSound: map['isOrignalSound'],
      postSound: map['postSound'],
      singer: map['singer'],
      soundId: map['soundId'],
      soundImage: map['soundImage'],
      soundTitle: map['soundTitle'],
      thumbnail: map['thumbnail'],
      duration: map['duration'],
      postHashTag: map['postHashTag'],
      likes: List<String>.from(map['likes']),
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) =>
      StoryModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StoryModel(id: $id, phoneNumber: $phoneNumber, createdAt: $createdAt, caption: $caption, uploadFile: $uploadFile,  postType: $postType, isOrignalSound: $isOrignalSound, postSound: $postSound, singer: $singer, soundId: $soundId, soundImage: $soundImage, soundTitle: $soundTitle, thumbnail: $thumbnail, postHashTag: $postHashTag, duration: $duration, likes: $likes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is StoryModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.createdAt == createdAt &&
        other.caption == caption &&
        other.uploadFile == uploadFile &&
        other.postType == postType &&
        other.isOrignalSound == isOrignalSound &&
        other.postSound == postSound &&
        other.singer == singer &&
        other.soundId == soundId &&
        other.soundImage == soundImage &&
        other.soundTitle == soundTitle &&
        other.thumbnail == thumbnail &&
        other.duration == duration &&
        other.postHashTag == postHashTag &&
        listEquals(other.likes, likes);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        createdAt.hashCode ^
        caption.hashCode ^
        uploadFile.hashCode ^
        postType.hashCode ^
        isOrignalSound.hashCode ^
        postSound.hashCode ^
        singer.hashCode ^
        soundId.hashCode ^
        soundImage.hashCode ^
        soundTitle.hashCode ^
        thumbnail.hashCode ^
        duration.hashCode ^
        postHashTag.hashCode ^
        likes.hashCode;
  }
}
