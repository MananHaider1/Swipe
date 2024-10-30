import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
//
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/wallets_model.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart'; // For formatting dates

class AllTransactionsPage extends StatelessWidget {
  final List<TransactionModel> transactions;

  const AllTransactionsPage({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('All Transactions'),
      // ),
      body: Column(
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
                text: LocaleKeys.alltransactions.tr(),
              )),
              // trailing: CustomIconButton(
              //   icon: ellipsisIcon,
              //   onPressed: () {},
              // ),
            ),
          ),
          const SizedBox(height: AppConstants.defaultNumericValue),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  shadowColor: Colors.transparent,
                  color: AppConstants.primaryColor.withOpacity(.1),
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
                        backgroundColor: transaction.type == 'deposit'
                            ? Colors.green.withOpacity(.1)
                            : transaction.type == 'withdraw'
                                ? Colors.purple.withOpacity(.1)
                                : transaction.type == 'send'
                                    ? Colors.grey.withOpacity(.1)
                                    : Colors.orange.withOpacity(.1),
                        child: Icon(
                          // Choose an icon based on transaction status
                          transaction.type == 'deposit'
                              ? Icons.file_download_outlined
                              : transaction.type == 'withdraw'
                                  ? Icons.file_upload_outlined
                                  : transaction.type == 'send'
                                      ? Icons.keyboard_double_arrow_up_rounded
                                      : Icons
                                          .keyboard_double_arrow_down_rounded,
                          color: transaction.type == 'deposit'
                              ? Colors.green
                              : transaction.type == 'withdraw'
                                  ? Colors.purple
                                  : transaction.type == 'send'
                                      ? Colors.grey
                                      : Colors.orange,
                        ),
                      ),
                      title: Text(transaction.amount.toStringAsFixed(2),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        DateFormat.yMMMd().format(transaction.createdAt),
                      ),
                      trailing: Icon(
                        // Choose an icon based on transaction status
                        transaction.status == 'success'
                            ? Icons.check_circle
                            : transaction.status == 'failed'
                                ? Icons.error_outline
                                : Icons.hourglass_empty_rounded,
                        color: transaction.status == 'success'
                            ? Colors.green
                            : transaction.status == 'failed'
                                ? Colors.red
                                : Colors.grey,
                      ),
                      onTap: () {
                        // Handle navigation to transaction details page if needed
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
