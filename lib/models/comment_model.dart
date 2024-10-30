// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
// import 'package:flutter/foundation.dart';

class CommentModel {
  String id;
  String phoneNumber;
  String text;
  DateTime createdAt;
  List<String>? likes;

  CommentModel({
    required this.id,
    required this.phoneNumber,
    required this.createdAt,
    required this.text,
    this.likes,
  });

  CommentModel copyWith({
    String? id,
    String? phoneNumber,
    String? text,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return CommentModel(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt ?? this.createdAt,
        text: text ?? this.text,
        likes: likes ?? this.likes);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likes': likes
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      text: map['text'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      likes: List<String>.from(map['likes']),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentModel(id: $id, phoneNumber: $phoneNumber, text: $text, likes: $likes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant CommentModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.text == text &&
        other.createdAt == createdAt &&
        listEquals(other.likes, likes);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        likes.hashCode;
  }
}
