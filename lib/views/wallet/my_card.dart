import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

//

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/bank_card_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class MyCardPage extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  MyCardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsyncValue = ref.watch(getMyWithdrawalCard);
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    return Scaffold(
      body: cardAsyncValue.when(
        data: (card) => _buildCardDetails(card, context, ref, phoneNumber),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(LocaleKeys.noCardFound.tr())),
      ),
    );
  }

  Widget _buildCardDetails(MyWithdrawalCard? card, context, ref, phone) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          onPressed: () {
                            (!Responsive.isDesktop(context))
                                ? Navigator.pop(context)
                                : ref.invalidate(arrangementProviderExtend);
                          },
                          color: AppConstants.primaryColor,
                          icon: leftArrowSvg),
                    ]),
                    title: Center(
                        child: CustomHeadLine(
                      text: LocaleKeys.myCard.tr(),
                    )),
                    trailing: CustomIconButton(
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8),
                      icon: editIcon,
                      color: AppConstants.secondaryColor,
                      onPressed: () =>
                          _showEditCardForm(context, card, phone, ref),
                    )),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              CreditCard(
                card: card!,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final titles = [
                      LocaleKeys.address.tr(),
                      LocaleKeys.state.tr(),
                      LocaleKeys.zipcode.tr(),
                      LocaleKeys.paypal.tr()
                    ];
                    final bgColors = [
                      Colors.green.withOpacity(.1),
                      Colors.purple.withOpacity(.1),
                      Colors.grey.withOpacity(.1),
                      Colors.orange.withOpacity(.1)
                    ];
                    final iconColors = [
                      Colors.green,
                      Colors.purple,
                      Colors.grey,
                      Colors.orange
                    ];
                    final leadIcons = [
                      Icons.home,
                      Icons.grain_rounded,
                      Icons.pin,
                      Icons.paypal_rounded
                    ];
                    final subtitles = [
                      card.address,
                      card.state,
                      card.zipCode,
                      card.paypalEmail
                    ];

                    return Card(
                      color: AppConstants.primaryColor.withOpacity(.1),
                      shadowColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppConstants.defaultNumericValue),
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue,
                        vertical: AppConstants.defaultNumericValue / 2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: bgColors[index],
                            child: Icon(
                              leadIcons[index],
                              color: iconColors[index],
                            ),
                          ),
                          title: Text(
                            titles[index],
                          ),
                          subtitle: Text(subtitles[index]!,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold)),
                          onTap: () {
                            // Handle navigation to transaction details page if needed
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Text('Bank Name: ${card.bankName}'),
              // Text('Account Name: ${card.accountName}'),
              // Text('Account Number: ${card.accountNumber}'),
              // Text('Address: ${card.address}'),
              // Text('City: ${card.city}'),
              // Text('State: ${card.state}'),
              // Text('Zip Code: ${card.zipCode}'),
              // Text('Country: ${card.country}'),
              // Text('PayPal Email: ${card.paypalEmail}'),
            ],
          )),
    );
  }

  void _showEditCardForm(BuildContext context, MyWithdrawalCard? card,
      String phone, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppConstants.defaultNumericValue),
        ),
      ),
      builder: (context) => _buildEditCardForm(card, phone, context, ref),
    );
  }

  Widget _buildEditCardForm(
      MyWithdrawalCard? card, String phone, context, ref) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              CustomAppBar(
                trailing: CustomIconButton(
                    padding: const EdgeInsets.all(
                        AppConstants.defaultNumericValue / 1.8),
                    onPressed: () => Navigator.pop(context),
                    color: AppConstants.secondaryColor,
                    icon: closeIcon),
                title: Center(
                    child: CustomHeadLine(
                  text: LocaleKeys.editCard.tr(),
                )),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.bankName,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.bankName.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.bankName = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.accountName,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.accountOwnerName.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.accountName = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.accountNumber.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.accountNumber.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  } else if (value.length < 8 ||
                      value.contains(RegExp(r'[a-zA-Z]')) ||
                      value.contains(RegExp(r'[^\w\s]'))) {
                    return LocaleKeys.atleasteightdigit.tr();
                  }
                  return null;
                },
                onSaved: (value) => card?.accountNumber = int.tryParse(value!),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.address,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.street.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.address = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.city,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.city.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.city = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.state,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.state.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.state = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.zipCode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.zipcode.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return LocaleKeys.ziperror.tr();
                  }
                  return null;
                },
                onSaved: (value) => card?.zipCode = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.country,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.country.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSaved: (value) => card?.country = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                initialValue: card?.paypalEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppConstants.primaryColor.withOpacity(.1),
                  hintText: LocaleKeys.paypalemail.tr(),
                  border: OutlineInputBorder(
                    // Set outline border
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value!.isNotEmpty) {
                    if (!value.contains('@')) {
                      return LocaleKeys.paypalemailError.tr();
                    }
                  }
                  return null;
                },
                onSaved: (value) => card?.paypalEmail = value,
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              SizedBox(
                width: MediaQuery.of(context).size.width * .8,
                child: CustomButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        try {
                          await FirebaseFirestore.instance
                              .collection(
                                  FirebaseConstants.userProfileCollection)
                              .doc(phone)
                              .collection('bankCard')
                              .doc('card')
                              .update(card!.toMap()); // Assuming a toMap method
                          ref.refresh(getMyWithdrawalCard);
                          Navigator.pop(context);
                        } on FirebaseException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${LocaleKeys.errorOccured.tr()} ${e.message}')),
                          );
                        }
                      }
                    },
                    text: LocaleKeys.save),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CreditCard extends ConsumerStatefulWidget {
  final MyWithdrawalCard card;
  const CreditCard({super.key, required this.card});

  @override
  CreditCardState createState() => CreditCardState();
}

class CreditCardState extends ConsumerState<CreditCard> {
  // String balance = '0.00 ';
  String hiddenBalance = '********';
  bool isHidden = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 300,
        // width: width * 0.6,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 14.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: width * 0.4,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: AppConstants.defaultNumericValue,
                              ),
                              WebsafeSvg.asset(lamatStarIcon,
                                  // color: AppConstants.secondaryColor,
                                  width: 30,
                                  fit: BoxFit.fitHeight,
                                  height: 30),
                              const SizedBox(
                                width: AppConstants.defaultNumericValue / 2,
                              ),
                              Text(widget.card.bankName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: AppConstants.defaultNumericValue,
                        ),
                        SizedBox(
                          width: width * 0.4,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(.1),
                              child: const Icon(
                                Icons.paypal_rounded,
                                color: Colors.orange,
                              ),
                            ),
                            // title: Text(
                            //   LocaleKeys.paypal.tr(),
                            // ),
                            title: Text(widget.card.paypalEmail ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                            onTap: () {
                              // Handle navigation to transaction details page if needed
                            },
                          ),
                        ),
                        const SizedBox(
                          height: AppConstants.defaultNumericValue,
                        ),
                        SizedBox(
                            width: width * 0.3,
                            child: Row(children: [
                              Text(widget.card.city!),
                              const SizedBox(width: 10),
                              Text(widget.card.country!),
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppConstants.hintColor,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${widget.card.accountNumber!}",
                            style: const TextStyle(
                              fontSize: 26.0,
                              color: Color(0xff66646d),
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(widget.card.accountName!,
                              style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
