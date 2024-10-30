import 'dart:convert';

class MyWithdrawalCard {
  String? bankName;
  String? accountName;
  int? accountNumber;
  String? address;
  String? city;
  String? state;
  String? zipCode;
  String? country;
  String? paypalEmail;
  MyWithdrawalCard({
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.paypalEmail,
  });

  MyWithdrawalCard copyWith({
    int? accountNumber,
    String? bankName,
    String? accountName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? paypalEmail,
  }) {
    return MyWithdrawalCard(
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      paypalEmail: paypalEmail ?? this.paypalEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'paypalEmail': paypalEmail,
    };
  }

  factory MyWithdrawalCard.fromMap(Map<String, dynamic> map) {
    return MyWithdrawalCard(
      bankName: map['bankName'] ?? "",
      accountName: map['accountName'] ?? "",
      accountNumber: map['accountNumber']?.toInt() ?? 0,
      address: map['address'] ?? "",
      city: map['city'] ?? "",
      state: map['state'] ?? "",
      zipCode: map['zipCode'] ?? "",
      country: map['country'] ?? "",
      paypalEmail: map['paypalEmail'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MyWithdrawalCard.fromJson(String source) =>
      MyWithdrawalCard.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MyWithdrawalCard( bankName: $bankName, accountName: $accountName, accountNumber: $accountNumber, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, paypalEmail: $paypalEmail, )';

  @override
  bool operator ==(covariant MyWithdrawalCard other) {
    if (identical(this, other)) return true;

    return other.bankName == bankName &&
        other.accountName == accountName &&
        other.accountNumber == accountNumber &&
        other.address == address &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country &&
        other.paypalEmail == paypalEmail;
  }

  @override
  int get hashCode =>
      bankName.hashCode ^
      accountName.hashCode ^
      accountNumber.hashCode ^
      address.hashCode ^
      city.hashCode ^
      state.hashCode ^
      zipCode.hashCode ^
      country.hashCode ^
      paypalEmail.hashCode;
}
