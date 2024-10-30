// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
// import 'package:flutter/foundation.dart';

class TeelsModel {
  String id;
  String phoneNumber;
  String userName;
  DateTime createdAt;
  String? caption;

  String? postVideo;
  String? postType;
  String? thumbnail;
  String? postSound;
  String? duration;
  bool isOrignalSound;
  String? postHashTag;
  String? singer;
  String? soundImage;
  String? soundTitle;
  String? profileCategoryName;
  List<String> likes;
  List<String> saves;
  List<String> views;
  List<Map<String, dynamic>> comments;
  String? soundId;
  bool isTrending;
  bool videoShowLikes;
  bool canComment;
  bool canDuet;
  bool canSave;
  bool canDownload;
  TeelsModel({
    required this.id,
    required this.phoneNumber,
    required this.userName,
    required this.createdAt,
    this.caption,
    required this.postVideo,
    required this.postType,
    required this.thumbnail,
    required this.postSound,
    this.duration,
    required this.isOrignalSound,
    this.postHashTag,
    required this.singer,
    required this.profileCategoryName,
    required this.soundImage,
    required this.soundTitle,
    required this.likes,
    required this.saves,
    required this.views,
    required this.comments,
    required this.soundId,
    required this.isTrending,
    required this.videoShowLikes,
    required this.canComment,
    required this.canDuet,
    required this.canSave,
    required this.canDownload,
  });

  TeelsModel copyWith({
    String? id,
    String? phoneNumber,
    String? userName,
    DateTime? createdAt,
    String? caption,
    String? postVideo,
    String? postType,
    String? thumbnail,
    String? profileCategoryName,
    String? postSound,
    String? duration,
    bool? isOrignalSound,
    String? postHashTag,
    String? singer,
    String? soundImage,
    String? soundTitle,
    List<String>? likes,
    List<String>? saves,
    List<String>? views,
    List<Map<String, dynamic>>? comments,
    String? soundId,
    bool? isTrending,
    bool? videoShowLikes,
    bool? canComment,
    bool? canDuet,
    bool? canSave,
    bool? canDownload,
  }) {
    return TeelsModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
      profileCategoryName: profileCategoryName ?? this.profileCategoryName,
      postVideo: postVideo ?? this.postVideo,
      postType: postType ?? this.postType,
      thumbnail: thumbnail ?? this.thumbnail,
      postSound: postSound ?? this.postSound,
      duration: duration ?? this.duration,
      isOrignalSound: isOrignalSound ?? this.isOrignalSound,
      postHashTag: postHashTag ?? this.postHashTag,
      singer: singer ?? this.singer,
      soundImage: soundImage ?? this.soundImage,
      soundTitle: soundTitle ?? this.soundTitle,
      likes: likes ?? this.likes,
      saves: saves ?? this.saves,
      views: views ?? this.views,
      comments: comments ?? this.comments,
      soundId: soundId ?? this.soundId,
      isTrending: isTrending ?? this.isTrending,
      videoShowLikes: videoShowLikes ?? this.videoShowLikes,
      canComment: canComment ?? this.canComment,
      canDuet: canDuet ?? this.canDuet,
      canSave: canSave ?? this.canSave,
      canDownload: canDownload ?? this.canDownload,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'userName': userName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'caption': caption,
      'postVideo': postVideo,
      'postType': postType,
      'thumbnail': thumbnail,
      'postSound': postSound,
      'duration': duration,
      'isOrignalSound': isOrignalSound,
      'postHashTag': postHashTag,
      'singer': singer,
      'profileCategoryName': profileCategoryName,
      'soundImage': soundImage,
      'soundTitle': soundTitle,
      'likes': likes,
      'saves': saves,
      'views': views,
      'comments': comments,
      'soundId': soundId,
      'isTrending': isTrending,
      'videoShowLikes': videoShowLikes,
      'canComment': canComment,
      'canDuet': canDuet,
      'canSave': canSave,
      'canDownload': canDownload,
    };
  }

  factory TeelsModel.fromMap(Map<String, dynamic> map) {
    return TeelsModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      caption: map['caption'],
      postVideo: map['postVideo'],
      postType: map['postType'],
      thumbnail: map['thumbnail'],
      postSound: map['postSound'],
      duration: map['duration'],
      isOrignalSound: map['isOrignalSound'],
      postHashTag: map['postHashTag'],
      singer: map['singer'],
      profileCategoryName: map['profileCategoryName'],
      soundImage: map['soundImage'],
      soundTitle: map['soundTitle'],
      likes: List<String>.from(map['likes']),
      saves: List<String>.from(map['saves']),
      views: List<String>.from(map['views']),
      comments: (map['comments'] != null)
          ? List<Map<String, dynamic>>.from(map['comments'])
          : [],
      soundId: map['soundId'],
      isTrending: map['isTrending'] ?? true,
      videoShowLikes: map['videoShowLikes'] ?? true,
      canComment: map['canComment'] ?? true,
      canDuet: map['canDuet'] ?? true,
      canSave: map['canSave'] ?? true,
      canDownload: map['canDownload'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory TeelsModel.fromJson(String source) =>
      TeelsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TeelsModel(id: $id, phoneNumber: $phoneNumber, userName: $userName, createdAt: $createdAt, caption: $caption, postVideo: $postVideo, saves: $saves, postType: $postType, thumbnail: $thumbnail, postSound: $postSound, duration: $duration, isOrignalSound: $isOrignalSound, postHashTag: $postHashTag, singer: $singer, soundImage: $soundImage, soundTitle: $soundTitle, profileCategoryName: $profileCategoryName, likes: $likes, views: $views, comments: $comments, soundId: $soundId, isTrending: $isTrending, videoShowLikes: $videoShowLikes, canComment: $canComment, canDuet: $canDuet, canSave: $canSave, canDownload: $canDownload)';
  }

  @override
  bool operator ==(covariant TeelsModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.userName == userName &&
        other.createdAt == createdAt &&
        other.caption == caption &&
        other.postVideo == postVideo &&
        other.postType == postType &&
        other.thumbnail == thumbnail &&
        other.postSound == postSound &&
        other.duration == duration &&
        other.isOrignalSound == isOrignalSound &&
        other.postHashTag == postHashTag &&
        other.singer == singer &&
        other.profileCategoryName == profileCategoryName &&
        other.soundImage == soundImage &&
        other.soundTitle == soundTitle &&
        listEquals(other.likes, likes) &&
        listEquals(other.saves, saves) &&
        listEquals(other.views, views) &&
        listEquals(other.comments, comments) &&
        other.soundId == soundId &&
        other.isTrending == isTrending &&
        other.videoShowLikes == videoShowLikes &&
        other.canComment == canComment &&
        other.canDuet == canDuet &&
        other.canSave == canSave &&
        other.canDownload == canDownload;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        userName.hashCode ^
        createdAt.hashCode ^
        caption.hashCode ^
        postVideo.hashCode ^
        postType.hashCode ^
        thumbnail.hashCode ^
        postSound.hashCode ^
        duration.hashCode ^
        isOrignalSound.hashCode ^
        postHashTag.hashCode ^
        singer.hashCode ^
        profileCategoryName.hashCode ^
        soundImage.hashCode ^
        soundTitle.hashCode ^
        likes.hashCode ^
        saves.hashCode ^
        views.hashCode ^
        comments.hashCode ^
        soundId.hashCode ^
        isTrending.hashCode ^
        videoShowLikes.hashCode ^
        canComment.hashCode ^
        canDuet.hashCode ^
        canSave.hashCode ^
        canDownload.hashCode;
  }
}
