import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';
// import 'package:lamatdating/views/paystack_payment/paystack_page.dart';

class PaymentSuccess extends StatelessWidget {
  final int price;
  const PaymentSuccess(
      {super.key, required this.successMessage, required this.price});
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Image.network(
                      "https://www.pngitem.com/pimgs/m/669-6697805_success-illustration-hd-png-download.png",
                      height: MediaQuery.of(context).size.height * 0.4, //40%
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                    Text(successMessage,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        )),
                    const Spacer(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             CheckoutPage(price: price)));
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppConstants.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 5.0),
                          child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text('Back to Home Screen',
                                  style: TextStyle(fontSize: 20)))),
                    ),
                    const Spacer(),
                  ],
                ))));
  }
}
