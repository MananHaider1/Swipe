import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/models/call.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/models/call_methods.dart';
import 'package:lamatdating/views/calling/pickup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickupLayout extends ConsumerWidget {
  final Widget scaffold;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    super.key,
    required this.scaffold,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context, ref) {
    final userProvider = ref.watch(userProviderProvider);
    final observer = ref.watch(observerProvider);

    return observer.isOngoingCall == true
        ? scaffold
        : (userProvider.getUser != null)
            ? StreamBuilder<DocumentSnapshot>(
                stream:
                    callMethods.callStream(phone: userProvider.getUser!.phone),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    Call call = Call.fromMap(
                        snapshot.data!.data() as Map<dynamic, dynamic>);

                    if (!call.hasDialled!) {
                      return PickupScreen(
                        prefs: prefs,
                        call: call,
                        currentuseruid: userProvider.getUser!.phone,
                      );
                    }
                  }
                  return scaffold;
                },
              )
            : Center(
                child: NoItemFoundWidget(text: LocaleKeys.noCardFound.tr()),
              );
  }
}
