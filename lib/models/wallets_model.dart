import 'dart:convert';

import 'package:collection/collection.dart';

class WalletsModel {
  String id;
  String phoneNumber;
  double balance;
  int points;
  double depositsTotal;
  double withdrawalsTotal;
  List<Map<String, dynamic>> deposits;
  List<Map<String, dynamic>> withdrawals;
  List<Map<String, dynamic>> rewards;
  double rewardsTotal;
  List<Map<String, dynamic>> earnings;
  double earningsTotal;
  List<Map<String, dynamic>> gifts;
  double giftsTotal;
  List<TransactionModel>? transactions;

  WalletsModel({
    required this.id,
    required this.phoneNumber,
    required this.balance,
    required this.points,
    required this.depositsTotal,
    required this.withdrawalsTotal,
    required this.deposits,
    required this.withdrawals,
    required this.rewards,
    required this.rewardsTotal,
    required this.earnings,
    required this.earningsTotal,
    required this.gifts,
    this.transactions,
    required this.giftsTotal,
  });

  WalletsModel copyWith(
      {String? id,
      String? phoneNumber,
      double? balance,
      int? points,
      double? depositsTotal,
      double? withdrawalsTotal,
      List<Map<String, dynamic>>? deposits,
      List<Map<String, dynamic>>? withdrawals,
      List<Map<String, dynamic>>? rewards,
      double? rewardsTotal,
      List<Map<String, dynamic>>? earnings,
      double? earningsTotal,
      List<Map<String, dynamic>>? gifts,
      List<TransactionModel>? transactions,
      double? giftsTotal}) {
    return WalletsModel(
        id: id ?? this.id,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        balance: balance ?? this.balance,
        points: points ?? this.points,
        depositsTotal: depositsTotal ?? this.depositsTotal,
        withdrawalsTotal: withdrawalsTotal ?? this.withdrawalsTotal,
        deposits: deposits ?? this.deposits,
        withdrawals: withdrawals ?? this.withdrawals,
        rewards: rewards ?? this.rewards,
        rewardsTotal: rewardsTotal ?? this.rewardsTotal,
        earnings: earnings ?? this.earnings,
        earningsTotal: earningsTotal ?? this.earningsTotal,
        gifts: gifts ?? this.gifts,
        transactions: transactions ?? this.transactions,
        giftsTotal: giftsTotal ?? this.giftsTotal);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'balance': balance,
      'points': points,
      'depositsTotal': depositsTotal,
      'withdrawalsTotal': withdrawalsTotal,
      'deposits': deposits,
      'withdrawals': withdrawals,
      'rewards': rewards,
      'rewardsTotal': rewardsTotal,
      'earnings': earnings,
      'earningsTotal': earningsTotal,
      'gifts': gifts,
      'transactions': transactions?.map((x) => x.toMap()).toList(),
      'giftsTotal': giftsTotal
    };
  }

  factory WalletsModel.fromMap(Map<String, dynamic> map) {
    return WalletsModel(
        id: map['id'],
        phoneNumber: map['phoneNumber'],
        balance: map['balance'],
        points: map['points'],
        depositsTotal: map['depositsTotal'],
        withdrawalsTotal: map['withdrawalsTotal'],
        deposits: List<Map<String, dynamic>>.from(map['deposits']),
        withdrawals: List<Map<String, dynamic>>.from(map['withdrawals']),
        rewards: List<Map<String, dynamic>>.from(map['rewards']),
        rewardsTotal: map['rewardsTotal'],
        earnings: List<Map<String, dynamic>>.from(map['earnings']),
        earningsTotal: map['earningsTotal'],
        gifts: List<Map<String, dynamic>>.from(map['gifts']),
        transactions: List<TransactionModel>.from(
            map['transactions']?.map((x) => TransactionModel.fromMap(x))),
        giftsTotal: map['giftsTotal']);
  }

  String toJson() => json.encode(toMap());

  factory WalletsModel.fromJson(String source) =>
      WalletsModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'WalletsModel(id: $id, phoneNumber: $phoneNumber, balance: $balance, points: $points, depositsTotal: $depositsTotal, withdrawalsTotal: $withdrawalsTotal, deposits: $deposits, withdrawals: $withdrawals, rewards: $rewards, rewardsTotal: $rewardsTotal, earnings: $earnings, earningsTotal:$earningsTotal , gifts:$gifts , transactions: $transactions , giftsTotal :$giftsTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    final listEquals = const DeepCollectionEquality().equals;

    return other is WalletsModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.balance == balance &&
        other.points == points &&
        other.depositsTotal == depositsTotal &&
        other.withdrawalsTotal == withdrawalsTotal &&
        listEquals(other.deposits, deposits) &&
        listEquals(other.withdrawals, withdrawals) &&
        listEquals(other.rewards, rewards) &&
        other.rewardsTotal == rewardsTotal &&
        listEquals(other.earnings, earnings) &&
        other.earningsTotal == earningsTotal &&
        listEquals(other.gifts, gifts) &&
        listEquals(other.transactions, transactions) &&
        other.giftsTotal == giftsTotal;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        balance.hashCode ^
        points.hashCode ^
        depositsTotal.hashCode ^
        withdrawalsTotal.hashCode ^
        deposits.hashCode ^
        withdrawals.hashCode ^
        rewards.hashCode ^
        rewardsTotal.hashCode ^
        earnings.hashCode ^
        earningsTotal.hashCode ^
        gifts.hashCode ^
        transactions.hashCode ^
        giftsTotal.hashCode;
  }
}

class TransactionModel {
  String type;
  String? from;
  String? to;
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
  TransactionModel({
    required this.type,
    this.from,
    this.to,
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

  TransactionModel copyWith({
    String? type,
    String? from,
    String? to,
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
    return TransactionModel(
      type: type ?? this.type,
      from: from ?? this.from,
      to: to ?? this.to,
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
      'type': type,
      'from': from,
      'to': to,
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

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      type: map['type'] as String,
      from: map['from'] as String,
      to: map['to'] as String,
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

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TransactionModel( type: $type, from: $from, to: $to, phoneNumber: $phoneNumber, status: $status, createdAt: $createdAt, accountNumber: $accountNumber, bankName: $bankName, accountName: $accountName, address: $address, city: $city, state: $state, zipCode: $zipCode, country: $country, amount: $amount, paypalEmail: $paypalEmail, )';

  @override
  bool operator ==(covariant TransactionModel other) {
    if (identical(this, other)) return true;

    return other.type == type &&
        other.from == from &&
        other.to == to &&
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
