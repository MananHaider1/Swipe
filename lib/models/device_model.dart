import 'dart:convert';

class DeviceTokenModel {
  String phoneNumber;
  String deviceToken;
  DeviceTokenModel({
    required this.phoneNumber,
    required this.deviceToken,
  });

  DeviceTokenModel copyWith({
    String? phoneNumber,
    String? deviceToken,
  }) {
    return DeviceTokenModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'deviceToken': deviceToken,
    };
  }

  factory DeviceTokenModel.fromMap(Map<String, dynamic> map) {
    return DeviceTokenModel(
      phoneNumber: map['phoneNumber'],
      deviceToken: map['deviceToken'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DeviceTokenModel.fromJson(String source) =>
      DeviceTokenModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'DeviceMode(phoneNumber: $phoneNumber, deviceToken: $deviceToken)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceTokenModel &&
        other.phoneNumber == phoneNumber &&
        other.deviceToken == deviceToken;
  }

  @override
  int get hashCode => phoneNumber.hashCode ^ deviceToken.hashCode;
}
