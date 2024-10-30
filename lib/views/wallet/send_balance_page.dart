// ignore_for_file: library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class SendBalancePage extends ConsumerStatefulWidget {
  const SendBalancePage({super.key});

  @override
  _SendBalancePageState createState() => _SendBalancePageState();
}

class _SendBalancePageState extends ConsumerState<SendBalancePage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultNumericValue),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.defaultNumericValue),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  right: AppConstants.defaultNumericValue,
                  top: MediaQuery.of(context).padding.top,
                ),
                child: CustomAppBar(
                  leading: Row(children: [
                    CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () => Navigator.pop(context),
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                  ]),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.sendDymonds.tr(),
                  )),
                  trailing: const SizedBox(width: 32),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue * 2),
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(hintText: '+27 XXXXXXXXXX'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.enterrecipient.tr();
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: LocaleKeys.amount.tr()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.pleaseenteramount.tr();
                  }
                  if (double.tryParse(value) == null) {
                    return LocaleKeys.pleaseentervalidnumber.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final recipientId = _recipientController.text;
                    final amount = double.parse(_amountController.text);
                    ref.read(sendBalanceProvider(
                        {'recipientId': recipientId, 'amount': amount}));
                  }
                  EasyLoading.showSuccess(LocaleKeys.success.tr());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.3),
                  child: Text(LocaleKeys.sendDymonds.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
