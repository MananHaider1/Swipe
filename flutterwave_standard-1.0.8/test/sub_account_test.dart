
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/models/subaccount.dart';

main() {
  group("SubAccount should", () {
    final subAccountOne = SubAccount(id: "12345");
    final subAccountTwo = SubAccount(id: "12345", transactionChargeType: "flat");
    final subAccountThree = SubAccount(id: "1235", transactionPercentage: 10.0);

    test("return correct json values", () {
      final subAccountOneJson = {"id": "12345"};
      expect(subAccountOneJson, subAccountOne.toJson());

      final subAccountTwoJson = {"id": "12345", "transaction_charge_type": "flat"};
      expect(subAccountTwoJson, subAccountTwo.toJson());

      final subAccountThreeJson = {"id": "1235", "transaction_charge": 10.0};
      expect(subAccountThreeJson, subAccountThree.toJson());
    });

  });

}
