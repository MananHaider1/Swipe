// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

// import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final int price;
  final Function onSuccess;
  const CheckoutPage({super.key, required this.price, required this.onSuccess});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    EasyLoading.dismiss();
    super.initState();
    amountController.text = (widget.price / 100).toString();
  }

  checkout() async {
    try {
      return await FlutterPaystackPlus.openPaystackPopup(
          publicKey: PaystackPublicKey,
          context: context,
          secretKey: PaystackSecretKey,
          currency: AppConfig.currency,
          customerEmail: emailController.text,
          amount: widget.price.toString(),
          reference: 'ref_${DateTime.now().millisecondsSinceEpoch}',
          callBackUrl: "https://lamatt.web.app",
          onClosed: () {
            debugPrint('Could\'nt finish payment');
          },
          onSuccess: () async {
            debugPrint('Payment successful');
            await widget.onSuccess();
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          });
    } catch (e) {
      // EasyLoading.showError(LocaleKeys.purchaseFailed.tr());
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text('Checkout Page')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: amountController,
                    readOnly: true,
                    canRequestFocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    // initialValue: widget.price.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefix: Text(
                        'R',
                        style:
                            Theme.of(context).inputDecorationTheme.prefixStyle,
                      ),
                      hintText: '2000',
                      // labelText: 'Amount',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'janedoe@who.com',
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultNumericValue),
                          child: CustomButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  checkout();
                                }
                              },
                              text: LocaleKeys.continu.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class Checkout2Page extends ConsumerStatefulWidget {
  final UserProfileModel user;
  final String price;
  final Function onSuccess;
  const Checkout2Page(
      {super.key,
      required this.price,
      required this.onSuccess,
      required this.user});

  @override
  ConsumerState<Checkout2Page> createState() => _Checkout2PageState();
}

class _Checkout2PageState extends ConsumerState<Checkout2Page> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController amountController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    EasyLoading.dismiss();
    super.initState();
    amountController.text = (int.parse(widget.price) / 100).toString();
  }

  checkout() async {
    try {
      final Customer customer = Customer(
        name: widget.user.fullName,
        phoneNumber: widget.user.phoneNumber,
        email: emailController.text,
      );
      final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey: flutterwavePublicKey,
        currency: AppConfig.currency,
        txRef: const Uuid().v1(),
        amount: widget.price,
        redirectUrl: AppConfig.webAppUrl,
        customer: customer,
        paymentOptions: "ussd, card, mpesa, credit",
        customization: Customization(title: "My Payment"),
        isTestMode: true,
      );
      final ChargeResponse response = await flutterwave.charge();
      if (response.success == true) {
        debugPrint("${response.toJson()}");
        widget.onSuccess;
        EasyLoading.showSuccess(response.status.toString());
      } else {
        EasyLoading.showError(response.status.toString());
        debugPrint("no response");
      }
    } catch (e) {
      // EasyLoading.showError(LocaleKeys.purchaseFailed.tr());
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: height * .05,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultNumericValue),
                child: CustomAppBar(
                  leading: CustomIconButton(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.5),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: AppConstants.primaryColor,
                      icon: closeIcon),
                  title: const Center(
                      child: CustomHeadLine(
                    // prefs: widget.prefs,
                    text: "Checkout",
                  )),
                ),
              ),
              SizedBox(
                height: height * .03,
              ),
              TextFormField(
                controller: amountController,
                readOnly: true,
                canRequestFocus: false,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                // initialValue: widget.price.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefix: Text(
                    'R',
                    style: Theme.of(context).inputDecorationTheme.prefixStyle,
                  ),
                  hintText: '2000',
                  // labelText: 'Amount',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'janedoe@who.com',
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 50),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.defaultNumericValue),
                      child: CustomButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              checkout();
                            }
                          },
                          text: LocaleKeys.continu.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
