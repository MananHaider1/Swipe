// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class SubscribersModel {
  String phoneNumber;
  int subExpiryDate;

  SubscribersModel({
    required this.phoneNumber,
   required this.subExpiryDate,
  });

  SubscribersModel copyWith({
    String? phoneNumber,
  int? subExpiryDate
  }) {
    return SubscribersModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subExpiryDate: subExpiryDate ?? this.subExpiryDate,
      
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'subExpiryDate': subExpiryDate});

    return result;
  }

  factory SubscribersModel.fromMap(Map<String, dynamic> map) {
    return SubscribersModel(
      
      phoneNumber: map['phoneNumber'] ?? '',
      subExpiryDate: map['subExpiryDate'] ?? 0,

    );
  }

  String toJson() => json.encode(toMap());

  factory SubscribersModel.fromJson(String source) =>
      SubscribersModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SubscribersModel(phoneNumber: $phoneNumber, subExpiryDate: $subExpiryDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubscribersModel &&
        other.phoneNumber == phoneNumber &&
        other.subExpiryDate == subExpiryDate;
  }

  @override
  int get hashCode {
    return 
        phoneNumber.hashCode ^
        subExpiryDate.hashCode;
  }
}
