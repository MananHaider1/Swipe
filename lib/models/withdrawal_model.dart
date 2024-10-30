import 'dart:convert';

class WithrawalModel {
  String id;
  String phoneNumber;
  String status;
  DateTime createdAt;
  int? accountNumber;
  String? bankName;
  String? accountName;
  String? address;
  String? city;
  String? state;
  String? zipCode;
  String? country;
  double amount;
  String? paypalEmail;
  WithrawalModel({
    required this.id,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.accountNumber,
    this.bankName,
    this.accountName,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    required this.amount,
    this.paypalEmail,
  });

  WithrawalModel copyWith({
    String? id,
    String? phoneNumber,
    String? status,
    DateTime? createdAt,
    int? accountNumber,
    String? bankName,
    String? accountName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? amount,
    String? paypalEmail,
  }) {
    return WithrawalModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      amount: amount ?? this.amount,
      paypalEmail: paypalEmail ?? this.paypalEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'phoneNumber': phoneNumber,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'accountName': accountName,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'amount': amount,
      'paypalEmail': paypalEmail,
    };
  }

  factory WithrawalModel.fromMap(Map<String, dynamic> map) {
    return WithrawalModel(
      id: map['id'] as String,
      phoneNumber: map['phoneNumber'] as String,
      status: map['status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      accountNumber: map['accountNumber'] as int,
      bankName: map['bankName'] as String,
      accountName: map['accountName'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      state: map['state'] as String,
      zipCode: map['zipCode'] as String,
      country: map['country'] as String,
      amount: map['amount'] as double,
      paypalEmail: map['paypalEmail'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory WithrawalModel.fromJson(String source) =>
      WithrawalModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WithrawalModel( id: $id, phoneNumber: $phoneNumber, status: $status, createdAt: $createdAt, accountNumber: $accountNumber, bankName: $bankName, accountName: $accountName, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, amount: $amount, paypalEmail: $paypalEmail, )';

  @override
  bool operator ==(covariant WithrawalModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.accountNumber == accountNumber &&
        other.bankName == bankName &&
        other.accountName == accountName &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        other.amount == amount &&
        other.paypalEmail == paypalEmail;
  }

  @override
  int get hashCode =>
      phoneNumber.hashCode ^
      status.hashCode ^
      createdAt.hashCode ^
      accountNumber.hashCode ^
      bankName.hashCode ^
      accountName.hashCode ^
      address.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zipCode.hashCode ^
      country.hashCode ^
      amount.hashCode ^
      paypalEmail.hashCode;
}
