import 'dart:convert';

class UserInteractionModel {
  String id;
  String phoneNumber;
  String intractToUserId;
  bool isSuperLike;
  bool isLike;
  bool isDislike;
  DateTime createdAt;
  UserInteractionModel({
    required this.id,
    required this.phoneNumber,
    required this.intractToUserId,
    required this.isSuperLike,
    required this.isLike,
    required this.isDislike,
    required this.createdAt,
  });

  UserInteractionModel copyWith({
    String? id,
    String? phoneNumber,
    String? intractToUserId,
    bool? isSuperLike,
    bool? isLike,
    bool? isDislike,
    DateTime? createdAt,
  }) {
    return UserInteractionModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      intractToUserId: intractToUserId ?? this.intractToUserId,
      isSuperLike: isSuperLike ?? this.isSuperLike,
      isLike: isLike ?? this.isLike,
      isDislike: isDislike ?? this.isDislike,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'intractToUserId': intractToUserId});
    result.addAll({'isSuperLike': isSuperLike});
    result.addAll({'isLike': isLike});
    result.addAll({'isDislike': isDislike});
    result.addAll({'createdAt': createdAt.millisecondsSinceEpoch});

    return result;
  }

  factory UserInteractionModel.fromMap(Map<String, dynamic> map) {
    return UserInteractionModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      intractToUserId: map['intractToUserId'] ?? '',
      isSuperLike: map['isSuperLike'] ?? false,
      isLike: map['isLike'] ?? false,
      isDislike: map['isDislike'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserInteractionModel.fromJson(String source) =>
      UserInteractionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserInteractionModel(id: $id, phoneNumber: $phoneNumber, intractToUserId: $intractToUserId, isSuperLike: $isSuperLike, isLike: $isLike, isDislike: $isDislike, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserInteractionModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.intractToUserId == intractToUserId &&
        other.isSuperLike == isSuperLike &&
        other.isLike == isLike &&
        other.isDislike == isDislike &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        intractToUserId.hashCode ^
        isSuperLike.hashCode ^
        isLike.hashCode ^
        isDislike.hashCode ^
        createdAt.hashCode;
  }
}
