// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/bank_card_model.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/models/withdrawal_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/modal/plan/coin_plans.dart';
import 'package:lamatdating/helpers/my_loading/costumview/common_ui.dart';

final walletsStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  return FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection)
      .where('phoneNumber', isEqualTo: phoneNumber)
      .snapshots();
});

final createNewWalletProvider = FutureProvider.autoDispose<void>((ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final id = List.generate(64, (index) => _chars[random.nextInt(_chars.length)])
      .join();

  final newWallet = WalletsModel(
    id: id,
    phoneNumber: phoneNumber!,
    balance: 0.000001,
    points: 0,
    depositsTotal: 0.000001,
    withdrawalsTotal: 0.000001,
    deposits: [],
    withdrawals: [],
    rewards: [],
    rewardsTotal: 0.000001,
    earnings: [],
    earningsTotal: 0.000001,
    gifts: [],
    transactions: [],
    giftsTotal: 0.000001,
  );

  await walletsCollection.doc(phoneNumber).set(newWallet.toMap());
});

final createNewWalletForOtherProvider =
    FutureProvider.autoDispose.family<void, String>((ref, phoneNumber) async {
  // final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  final id = List.generate(64, (index) => _chars[random.nextInt(_chars.length)])
      .join();

  final newWallet = WalletsModel(
    id: id,
    phoneNumber: phoneNumber,
    balance: 0.000001,
    points: 0,
    depositsTotal: 0.000001,
    withdrawalsTotal: 0.000001,
    deposits: [],
    withdrawals: [],
    rewards: [],
    rewardsTotal: 0.000001,
    earnings: [],
    earningsTotal: 0.000001,
    gifts: [],
    transactions: [],
    giftsTotal: 0.000001,
  );

  await walletsCollection.doc(phoneNumber).set(newWallet.toMap());
});

final addBalanceProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    transaction.update(walletDoc, {
      'balance': FieldValue.increment(amount),
    });
  });
});

Future<bool> minusBalanceProvider(ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);

  // Get current balance before update
  final DocumentSnapshot<Map<String, dynamic>> snapshot = await walletDoc.get();
  final currentBalance = snapshot.get('balance') ?? 0.0;

  // Check if sufficient balance
  if (currentBalance < amount) {
    // Handle insufficient balance scenario (e.g., throw error, show message)
    EasyLoading.showError('Insufficient balance');
    return false;
  } else {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(walletDoc, {
        'balance': FieldValue.increment(-amount), // Minus the amount
      });
    });
    return true;
  }
}

Future<double> checkBalance(ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);
  final walletDoc = walletsCollection.doc(phoneNumber);
  final currentBalance = await walletDoc.get();

  return currentBalance.get('balance') ?? 0.0;
}

// Future<MyWithdrawalCard> getMyWithdrawalCard(ref) async {
//   final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//   final myCardCollection = FirebaseFirestore.instance
//       .collection(FirebaseConstants.userProfileCollection);
//   final cardDoc = myCardCollection.doc(phoneNumber);
//   final myCard = await cardDoc.get();
//   if (myCard.exists) {
//     return MyWithdrawalCard.fromJson(myCard.get('bankCard').data()!);
//   } else {
//     return MyWithdrawalCard();
//   }
// }

final getMyWithdrawalCard = FutureProvider<MyWithdrawalCard?>((ref) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final collection = FirebaseFirestore.instance
      .collection(FirebaseConstants.userProfileCollection)
      .doc(phoneNumber)
      .collection('bankCard')
      .doc('card');
  final snapshot = await collection.get();
  if (!snapshot.exists) {
    // Create a new card if it doesn't exist
    final newCard = MyWithdrawalCard(
      accountNumber: 00000000000000,
      bankName: '',
      accountName: '',
      city: '',
      address: '',
      paypalEmail: '',
      country: '',
      state: '',
      zipCode: '',
    );
    await collection.set(newCard.toMap()); // Assuming correct 'toMap' method

    return newCard;
  } else {
    final card = snapshot;
    if (card.exists) {
      return MyWithdrawalCard.fromMap(
          card.data()!); // Assuming correct method name
    } else {
      // Create a new card if it doesn't exist
      final newCard = MyWithdrawalCard(
        accountNumber: 00000000000000,
        bankName: '',
        accountName: '',
        city: '',
        address: '',
        paypalEmail: '',
        country: '',
        state: '',
        zipCode: '',
      );
      await collection.set(newCard.toMap()); // Assuming correct 'toMap' method

      return newCard;
    }
  }
});

Future<CoinPlans> getCoinPlanList() async {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await _firestore.collection('coinPlans').get();

  if (querySnapshot.docs.isNotEmpty) {
    List<CoinPlanData> coinPlanDataList = querySnapshot.docs
        .map((doc) => CoinPlanData.fromJson(doc.data()))
        .toList();
    return CoinPlans(data: coinPlanDataList);
  } else {
    EasyLoading.showError("No coin plans found");
    return CoinPlans(data: []);
  }
}

final addEarningProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'earningsTotal': FieldValue.increment(amount),
  });
});

final minusEarningProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'earningsTotal': FieldValue.increment(-amount),
  });
});

final addDepositProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'depositsTotal': FieldValue.increment(amount),
  });
});

final addWithdrawalProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'withdrawalsTotal': FieldValue.increment(amount),
  });
});

final _withdrawalsCollection = FirebaseFirestore.instance
    .collection(FirebaseConstants.withdrawalsCollection);

Future<bool> addWithdrawal(WithrawalModel withdrawalModel) async {
  final withdrawTransaction = TransactionModel(
    type: "withdraw",
    from: "",
    to: "",
    phoneNumber: withdrawalModel.phoneNumber,
    status: "pending",
    createdAt: DateTime.now(),
    accountNumber: withdrawalModel.accountNumber,
    bankName: withdrawalModel.bankName,
    accountName: withdrawalModel.accountName,
    address: withdrawalModel.address,
    city: withdrawalModel.city,
    state: withdrawalModel.state,
    zipCode: withdrawalModel.zipCode,
    country: withdrawalModel.country,
    amount: withdrawalModel.amount,
    paypalEmail: withdrawalModel.paypalEmail,
  );
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final senderWalletDoc = walletsCollection.doc(
    withdrawalModel.phoneNumber,
  );
  try {
    await _withdrawalsCollection
        .doc(withdrawalModel.id)
        .set(withdrawalModel.toMap(), SetOptions(merge: true));
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(senderWalletDoc, {
        'transactions': FieldValue.arrayUnion([withdrawTransaction.toMap()])
      });

      // CommonUI.showToast(msg: LocaleKeys.success.tr());
    });

    return true;
  } catch (e) {
    return false;
  }
}

final addRewardProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'rewardsTotal': FieldValue.increment(amount),
  });
});

final minusRewardProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'rewardsTotal': FieldValue.increment(-amount),
  });
});

final addGiftProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'giftsTotal': FieldValue.increment(amount),
  });
});

final minusGiftProvider =
    FutureProvider.autoDispose.family<void, double>((ref, amount) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final walletDoc = walletsCollection.doc(phoneNumber);
  await walletDoc.update({
    'giftsTotal': FieldValue.increment(-amount),
  });
});

final sendBalanceProvider = FutureProvider.autoDispose
    .family<bool, Map<String, dynamic>>((ref, data) async {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  final walletsCollection = FirebaseFirestore.instance
      .collection(FirebaseConstants.walletsCollection);

  final amount = data['amount'];
  final recipientId = data['recipientId'];

  final senderWalletDoc = walletsCollection.doc(phoneNumber);
  final recipientWalletDoc = walletsCollection.doc(recipientId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final senderSnapshot = await transaction.get(senderWalletDoc);
    final recipientSnapshot = await transaction.get(recipientWalletDoc);

    final senderBalance = senderSnapshot.data()?['balance'] ?? 0;
    final recipientBalance = recipientSnapshot.data()?['balance'] ?? 0;

    final senderTransaction = TransactionModel(
      type: "send",
      from: phoneNumber,
      to: recipientId,
      phoneNumber: phoneNumber!,
      status: "success",
      createdAt: DateTime.now(),
      accountNumber: 0,
      bankName: "",
      accountName: "",
      address: "",
      city: "",
      state: "",
      zipCode: "",
      country: "",
      amount: amount,
      paypalEmail: "",
    );

    final recipientTransaction = TransactionModel(
      type: "receive",
      from: phoneNumber,
      to: recipientId,
      phoneNumber: phoneNumber,
      status: "success",
      createdAt: DateTime.now(),
      accountNumber: 0,
      bankName: "",
      accountName: "",
      address: "",
      city: "",
      state: "",
      zipCode: "",
      country: "",
      amount: amount,
      paypalEmail: "",
    );

    if (senderBalance >= amount) {
      transaction.update(senderWalletDoc, {'balance': senderBalance - amount});
      transaction.update(senderWalletDoc, {
        'transactions': FieldValue.arrayUnion([senderTransaction.toMap()])
      });
      transaction
          .update(recipientWalletDoc, {'balance': recipientBalance + amount});
      transaction.update(recipientWalletDoc, {
        'transactions': FieldValue.arrayUnion([recipientTransaction.toMap()])
      });
      //CommonUI.showToast(msg: 'Funds Sent');
      return true;
    } else {
      //CommonUI.showToast(msg: 'Insufficient Balance');
      return false;
    }
  });
  return false;
});

Future<void> sendGiftProvider({
  required int giftCost,
  required String recipientId,
}) async {
  try {
    final phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
    final walletsCollection = FirebaseFirestore.instance
        .collection(FirebaseConstants.walletsCollection);
    final double giftCostSend = giftCost.toDouble();

    final senderWalletDoc = walletsCollection.doc(phoneNumber);
    final recipientWalletDoc = walletsCollection.doc(recipientId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Check if recipient wallet exists
      final recipientWalletSnapshot = await transaction.get(recipientWalletDoc);
      if (!recipientWalletSnapshot.exists) {
        // Create recipient wallet if it does not exist
        createNewWalletForOtherProvider(recipientId);
      }

      transaction.update(senderWalletDoc, {
        'balance': FieldValue.increment(-giftCostSend),
      });

      transaction.update(recipientWalletDoc, {
        'giftsTotal': FieldValue.increment(giftCostSend),
        'balance': FieldValue.increment(giftCostSend),
      });
    });
  } catch (e) {
    if (kDebugMode) {
      print('Transaction failed: $e');
    }
  }
}


// final sendGiftProvider = FutureProvider.autoDispose
//     .family<void, Map<String, dynamic>>((ref, data) async {
//   final giftCost = double.parse(data['giftCost']);
//   final recipientId = data['recipientId'];

//   try {
//     final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//     final walletsCollection = FirebaseFirestore.instance
//         .collection(FirebaseConstants.walletsCollection);

//     final senderWalletDoc = walletsCollection.doc(phoneNumber);
//     final recipientWalletDoc = walletsCollection.doc(recipientId);

//     await FirebaseFirestore.instance.runTransaction((transaction) async {
//       // Check if recipient wallet exists
//       final recipientWalletSnapshot = await transaction.get(recipientWalletDoc);
//       if (!recipientWalletSnapshot.exists) {
//         // Create recipient wallet if it does not exist
//         ref.read(createNewWalletForOtherProvider(recipientId));
//       }

//       transaction.update(senderWalletDoc, {
//         'balance': FieldValue.increment(-giftCost),
//       });

//       transaction.update(recipientWalletDoc, {
//         'giftsTotal': FieldValue.increment(giftCost),
//       });
//     });
//   } catch (e) {
//     if (kDebugMode) {
//       print('Transaction failed: $e');
//     }
//   }
// });



// final sendGiftProvider = FutureProvider.autoDispose
//     .family<void, Map<String, dynamic>>((ref, data) async {
//   final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
//   final walletsCollection = FirebaseFirestore.instance
//       .collection(FirebaseConstants.walletsCollection);

//   final giftCost = data['giftCost'];
//   final recipientId = data['recipientId'];

//   final senderWalletDoc = walletsCollection.doc(phoneNumber);
//   final recipientWalletDoc = walletsCollection.doc(recipientId);

//   await FirebaseFirestore.instance.runTransaction((transaction) async {
//     transaction.update(senderWalletDoc, {
//       'balance': FieldValue.increment(-giftCost),
//     });
//     transaction.update(recipientWalletDoc, {
//       'giftsTotal': FieldValue.increment(giftCost),
//     });
//   });
// });
