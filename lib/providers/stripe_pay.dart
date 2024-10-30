// ignore_for_file: unused_element, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/theme_management.dart';

Future<bool> stripeProvider(ref, amount, name, stripePaymentPageUrl) async {
  // final paymentURL = "https://stripe-no-website-example.onrender.com/$name/prod_QBRqRL6r2XaF18";
  final paymentURL = stripePaymentPageUrl;
  try {
    // EasyLoading.show();
    final response = await http.post(Uri.parse(paymentURL));

    EasyLoading.dismiss();
    if (response.statusCode == 200) {
      return true;
    }
  } catch (e) {
    EasyLoading.showError(e.toString());
    return false;
  }

  return false;
}

class StripePaymentHandle {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment(
      String amount,
      String currency,
      String name,
      String email,
      String phone,
      String city,
      String country,
      String address,
      String address2,
      String postalCode,
      String state,
      Function succesFunc) async {
    try {
      DarkThemeProvider themeChangeProvider = DarkThemeProvider();
      final theme = await themeChangeProvider.darkThemePreference.getTheme();
      paymentIntent = await createPaymentIntent(amount, currency);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              billingDetails: BillingDetails(
                  name: name,
                  email: email,
                  phone: phone,
                  address: Address(
                      city: city,
                      country: country,
                      line1: address,
                      line2: address2,
                      postalCode: postalCode,
                      state: state)),
              paymentIntentClientSecret:
                  paymentIntent!['client_secret'], //Gotten from payment intent
              style: theme ? ThemeMode.dark : ThemeMode.light,
              merchantDisplayName: Appname));

      //STEP 3: Display Payment sheet
      displayPaymentSheet(succesFunc);
    } catch (e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  displayPaymentSheet(Function callBackFunc) async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();
      callBackFunc;
      Fluttertoast.showToast(msg: 'Payment succesfully completed');
    } on Exception catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
            msg: 'Error from Stripe: ${e.error.localizedMessage}');
      } else {
        Fluttertoast.showToast(msg: 'Unforeseen error: $e');
      }
    }
  }

//create Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

//calculate Amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
}
