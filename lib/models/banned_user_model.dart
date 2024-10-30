import 'dart:convert';

class BannedUserModel {
  String phoneNumber;
  DateTime bannedAt;
  DateTime bannedUntil;
  bool isLifetimeBan;
  BannedUserModel({
    required this.phoneNumber,
    required this.bannedAt,
    required this.bannedUntil,
    required this.isLifetimeBan,
  });

  BannedUserModel copyWith({
    String? phoneNumber,
    DateTime? bannedAt,
    DateTime? bannedUntil,
    bool? isLifetimeBan,
  }) {
    return BannedUserModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedUntil: bannedUntil ?? this.bannedUntil,
      isLifetimeBan: isLifetimeBan ?? this.isLifetimeBan,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'bannedAt': bannedAt.millisecondsSinceEpoch});
    result.addAll({'bannedUntil': bannedUntil.millisecondsSinceEpoch});
    result.addAll({'isLifetimeBan': isLifetimeBan});

    return result;
  }

  factory BannedUserModel.fromMap(Map<String, dynamic> map) {
    return BannedUserModel(
      phoneNumber: map['phoneNumber'] ?? '',
      bannedAt: DateTime.fromMillisecondsSinceEpoch(map['bannedAt']),
      bannedUntil: DateTime.fromMillisecondsSinceEpoch(map['bannedUntil']),
      isLifetimeBan: map['isLifetimeBan'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory BannedUserModel.fromJson(String source) =>
      BannedUserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'BannedUserModel(phoneNumber: $phoneNumber, bannedAt: $bannedAt, bannedUntil: $bannedUntil, isLifetimeBan: $isLifetimeBan)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BannedUserModel &&
        other.phoneNumber == phoneNumber &&
        other.bannedAt == bannedAt &&
        other.bannedUntil == bannedUntil &&
        other.isLifetimeBan == isLifetimeBan;
  }

  @override
  int get hashCode {
    return phoneNumber.hashCode ^
        bannedAt.hashCode ^
        bannedUntil.hashCode ^
        isLifetimeBan.hashCode;
  }
}
