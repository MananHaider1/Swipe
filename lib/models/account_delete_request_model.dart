import 'dart:convert';

class AccountDeleteRequestModel {
  String phoneNumber;
  DateTime requestDate;
  DateTime deleteDate;
  AccountDeleteRequestModel({
    required this.phoneNumber,
    required this.requestDate,
    required this.deleteDate,
  });

  AccountDeleteRequestModel copyWith({
    String? phoneNumber,
    DateTime? requestDate,
    DateTime? deleteDate,
  }) {
    return AccountDeleteRequestModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      requestDate: requestDate ?? this.requestDate,
      deleteDate: deleteDate ?? this.deleteDate,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'phoneNumber': phoneNumber});
    result.addAll({'requestDate': requestDate.millisecondsSinceEpoch});
    result.addAll({'deleteDate': deleteDate.millisecondsSinceEpoch});

    return result;
  }

  factory AccountDeleteRequestModel.fromMap(Map<String, dynamic> map) {
    return AccountDeleteRequestModel(
      phoneNumber: map['phoneNumber'] ?? '',
      requestDate: DateTime.fromMillisecondsSinceEpoch(map['requestDate']),
      deleteDate: DateTime.fromMillisecondsSinceEpoch(map['deleteDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountDeleteRequestModel.fromJson(String source) =>
      AccountDeleteRequestModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'AccountDeleteRequestModel(phoneNumber: $phoneNumber, requestDate: $requestDate, deleteDate: $deleteDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AccountDeleteRequestModel &&
        other.phoneNumber == phoneNumber &&
        other.requestDate == requestDate &&
        other.deleteDate == deleteDate;
  }

  @override
  int get hashCode =>
      phoneNumber.hashCode ^ requestDate.hashCode ^ deleteDate.hashCode;
}
