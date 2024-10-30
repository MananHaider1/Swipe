import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class FeedModel {
  String id;
  String phoneNumber;
  DateTime createdAt;
  String? caption;
  List<String> images;
  List<String> likes;
  List<Map<String, dynamic>> comments; // Add this line
  FeedModel({
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
    this.caption,
    required this.images,
    required this.likes,
    required this.comments, // And this line
  });

  FeedModel copyWith({
    String? id,
    String? phoneNumber,
    DateTime? createdAt,
    String? caption,
    List<String>? images,
    List<String>? likes,
    List<Map<String, dynamic>>? comments, // And this line
  }) {
    return FeedModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      caption: caption ?? this.caption,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments, // And this line
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
    result.addAll({'images': images});
    result.addAll({'likes': likes});
    result.addAll({'comments': comments}); // And this line

    return result;
  }

  factory FeedModel.fromMap(Map<String, dynamic> map) {
    return FeedModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      caption: map['caption'],
      images: List<String>.from(map['images']),
      likes: List<String>.from(map['likes']),
      comments: (map['comments'] != null)
          ? List<Map<String, dynamic>>.from(map['comments'])
          : [], // And this line
    );
  }

  String toJson() => json.encode(toMap());

  factory FeedModel.fromJson(String source) =>
      FeedModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'FeedModel(id: $id, phoneNumber: $phoneNumber, createdAt: $createdAt, caption: $caption, images: $images, likes: $likes, comments: $comments)'; // And modify this line
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    final listEquals = const DeepCollectionEquality().equals;

    return other is FeedModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.createdAt == createdAt &&
        other.caption == caption &&
        listEquals(other.images, images) &&
        listEquals(other.likes, likes) &&
        listEquals(other.comments, comments); // And modify this line
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        createdAt.hashCode ^
        caption.hashCode ^
        images.hashCode ^
        likes.hashCode ^
        comments.hashCode; // And modify this line
  }
}

class FeedComment {
  String? _comment;
  String? _commentType;
  String? _id;
  bool? _isVerify;
  String? _phoneNumber;
  String? _userImage;
  String? _userName;
  String? _fullName;

  FeedComment(
      {String? comment,
      String? commentType,
      String? id,
      bool? isVerify,
      String? phoneNumber,
      String? userImage,
      String? userName,
      String? fullName}) {
    _comment = comment;
    _commentType = commentType;
    _id = id;
    _isVerify = isVerify;
    _phoneNumber = phoneNumber;
    _userImage = userImage;
    _userName = userName;
    _fullName = fullName;
  }

  Map<String, dynamic> toJson() {
    return {
      "comment": _comment,
      "commentType": _commentType,
      "id": _id,
      "isVerify": _isVerify,
      "phoneNumber": _phoneNumber,
      "userImage": _userImage,
      "userName": _userName,
      "fullName": _fullName,
    };
  }

  FeedComment.fromJson(Map<String, dynamic>? json) {
    _comment = json?["comment"];
    _commentType = json?["commentType"];
    _id = json?["id"];
    _isVerify = json?["isVerify"];
    _phoneNumber = json?["phoneNumber"];
    _userImage = json?["userImage"];
    _userName = json?["userName"];
    _fullName = json?["fullName"];
  }

  Map<String, dynamic> toFireStore() {
    return {
      "comment": _comment,
      "commentType": _commentType,
      "id": _id,
      "isVerify": _isVerify,
      "phoneNumber": _phoneNumber,
      "userImage": _userImage,
      "userName": _userName,
      "fullName": _fullName,
    };
  }

  factory FeedComment.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return FeedComment(
      comment: data?['comment'],
      commentType: data?['commentType'],
      id: data?['id'],
      isVerify: data?['isVerify'],
      phoneNumber: data?['phoneNumber'],
      userImage: data?['userImage'],
      userName: data?['userName'],
      fullName: data?['fullName'],
    );
  }

  String? get userName => _userName;

  String? get userImage => _userImage;

  String? get phoneNumber => _phoneNumber;

  bool? get isVerify => _isVerify;

  String? get id => _id;

  String? get commentType => _commentType;

  String? get comment => _comment;

  String? get fullName => _fullName;
}
