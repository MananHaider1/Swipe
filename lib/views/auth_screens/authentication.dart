import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/Passcode/passcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticate extends StatefulWidget {
  final String? answer, question, passcode, phoneNo, caption;
  final SharedPreferences prefs;
  final NavigatorState state;
  final DataModel model;
  final Function onSuccess;
  final AuthenticationType type;
  final bool shouldPop;
  const Authenticate(
      {super.key,
      required this.type,
      required this.answer,
      required this.model,
      required this.question,
      required this.passcode,
      required this.prefs,
      required this.phoneNo,
      required this.state,
      required this.caption,
      required this.onSuccess,
      required this.shouldPop});

  @override
  AuthenticateState createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  late int passcodeTries;

  @override
  void initState() {
    super.initState();
    passcodeTries = widget.prefs.getInt(Dbkeys.passcodeTries) ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (passcodeVisible()) {
        widget.type == AuthenticationType.passcode
            ? _showLockScreen()
            : _biometricAuthentication();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!passcodeVisible()) {
      child = Material(
          color: AppConstants.lamatBlack,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Text(
              'Tryagain'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppConstants.lamatWhite, fontSize: 18, height: 1.5),
            ),
          )));
    } else {
      child = Container();
    }
    return Lamat.getNTPWrappedWidget(child);
  }

  bool passcodeVisible() {
    int lastAttempt = widget.prefs.getInt(Dbkeys.lastAttempt) ??
        DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    DateTime lastTried = DateTime.fromMillisecondsSinceEpoch(lastAttempt);
    return (passcodeTries <= 3 ||
        DateTime.now().isAfter(lastTried
            .add(Duration(minutes: math.pow(2, passcodeTries - 3) as int))));
  }

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  _onPasscodeEntered(String enteredPasscode) {
    if (enteredPasscode.length == 4) {
      bool isValid = Lamat.getHashedAnswer(enteredPasscode) == widget.passcode;
      _verificationNotifier.add(isValid);
      if (isValid) {
        widget.prefs.setInt(Dbkeys.passcodeTries, 0); // reset tries
        widget.onSuccess();
      } else {
        passcodeTries += 1;
        widget.prefs.setInt(Dbkeys.passcodeTries, passcodeTries);
        widget.prefs
            .setInt(Dbkeys.lastAttempt, DateTime.now().millisecondsSinceEpoch);
        if (passcodeTries > 3) {
          Lamat.toast(
              '${'tryAfter'.tr()} ${math.pow(2, passcodeTries - 3)} ${'minutes'.tr()}');
          Lamat.toast('error'.tr());
          widget.state.pop();
        }
      }
    }
  }

  _showLockScreen() {
    widget.state.push(MaterialPageRoute(
      builder: (context) => PasscodeScreen(
          prefs: widget.prefs,
          phoneNo: widget.phoneNo,
          wait: false,
          onSubmit: null,
          authentication: true,
          passwordDigits: 4,
          title: 'enterPassword'.tr(),
          shouldPop: widget.shouldPop,
          passwordEnteredCallback: _onPasscodeEntered,
          cancelLocalizedText: 'cancel'.tr(),
          deleteLocalizedText: 'delete'.tr(),
          shouldTriggerVerification: _verificationNotifier.stream,
          question: widget.question,
          answer: widget.answer),
    ));
  }

  _biometricAuthentication() {
    LocalAuthentication()
        .authenticate(
      localizedReason: widget.caption!,
    )
        .then((res) {
      if (res == true) {
        if (widget.shouldPop) widget.state.pop();
        widget.onSuccess();
      } else {
        Lamat.toast('error'.tr());
      }
    }).catchError((e) {
      return Future.value(null);
    });
  }
}
