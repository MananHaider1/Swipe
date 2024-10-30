import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:lamatdating/widgets/Passcode/passcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Security extends StatefulWidget {
  final String? phoneNo, answer, title;
  final bool setPasscode, shouldPop;
  final SharedPreferences prefs;
  final Function onSuccess;

  const Security(this.phoneNo,
      {super.key,
      this.shouldPop = false,
      this.setPasscode = false,
      this.answer,
      required this.title,
      required this.prefs,
      required this.onSuccess});

  @override
  SecurityState createState() => SecurityState();
}

class SecurityState extends State<Security> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? _passCode;

  @override
  Widget build(BuildContext context) {
    return Lamat.getNTPWrappedWidget(Stack(children: [
      Scaffold(
          backgroundColor: Teme.isDarktheme(widget.prefs)
              ? AppConstants.backgroundColorDark
              : AppConstants.backgroundColor,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                )),
            elevation: 0.4,
            title: Text(
              widget.title!,
              style: TextStyle(
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor)),
            ),
          ),
          bottomSheet: Container(
            margin: EdgeInsets.only(
                bottom: !kIsWeb
                    ? Platform.isIOS
                        ? 15
                        : 0
                    : 15),
            height: 67,
            width: MediaQuery.of(this.context).size.width,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: myElevatedButton(
                  color: AppConstants.primaryColor,
                  child: Text(
                    LocaleKeys.done.tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (widget.setPasscode) {
                      if (_passCode == null) {
                        Lamat.toast(
                          LocaleKeys.setpasscode.tr(),
                        );
                      }
                      if (
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // _formKey.currentState.validate() &&

                          _passCode != null) {
                        var data = {
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // QUESTION: _question.text,
                          // ANSWER:
                          //     Lamat.getHashedAnswer(_answer.text),
                          Dbkeys.passcode: Lamat.getHashedString(_passCode!)
                        };
                        setState(() {
                          isLoading = true;
                        });
                        widget.prefs.setInt(Dbkeys.passcodeTries, 0);
                        widget.prefs.setInt(Dbkeys.answerTries, 0);
                        FirebaseFirestore.instance
                            .collection(DbPaths.collectionusers)
                            .doc(widget.phoneNo)
                            .update(data)
                            .then((_) {
                          // Lamat.toast(
                          //     getTranslated(this.context, 'welcometo') +
                          //         ' $Appname!');
                          widget.onSuccess(this.context);
                        });
                      }
                      widget.prefs
                          .setString(Dbkeys.isPINsetDone, widget.phoneNo!);
                    } else {
                      if (_formKey.currentState!.validate()) {
                        var data = {
                          // ignore: todo
                          //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                          // QUESTION: _question.text,
                          // ANSWER:
                          //     Lamat.getHashedAnswer(_answer.text),
                        };
                        setState(() {
                          isLoading = true;
                        });
                        widget.prefs.setInt(Dbkeys.passcodeTries, 0);
                        widget.prefs.setInt(Dbkeys.answerTries, 0);
                        FirebaseFirestore.instance
                            .collection(DbPaths.collectionusers)
                            .doc(widget.phoneNo)
                            .update(data as Map<String, Object?>)
                            .then((_) {
                          widget.onSuccess(this.context);
                          widget.prefs
                              .setString(Dbkeys.isPINsetDone, widget.phoneNo!);
                        });
                      }
                    }
                  },
                )),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  widget.setPasscode
                      ? ListTile(
                          trailing: Icon(Icons.check_circle,
                              color: _passCode == null
                                  ? AppConstants.lamatGrey
                                  : AppConstants.primaryColor,
                              size: 35),
                          title: myElevatedButton(
                            color: AppConstants.primaryColor,
                            child: Text(
                              LocaleKeys.setpasscode.tr(),
                              style: TextStyle(
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    AppConstants.primaryColor),
                              ),
                            ),
                            onPressed: _showLockScreen,
                          ))
                      : const SizedBox(),
                  widget.setPasscode
                      ? const SizedBox(height: 20)
                      : const SizedBox(),
                  // ignore: todo
                  //TODO://----REMOVE BELOW COMMENT TO ASK SECURITY QUESTION SET----
                  // ListTile(
                  //     subtitle: Text(
                  //   getTranslated(this.context, 'setpasslong'),
                  // )),
                  // ListTile(
                  //   leading: Icon(Icons.lock),
                  //   title: TextFormField(
                  //     decoration: InputDecoration(
                  //         labelText:
                  //             getTranslated(this.context, 'sques')),
                  //     controller: _question,
                  //     autovalidateMode: AutovalidateMode.always,
                  //     validator: (v) {
                  //       return v.trim().isEmpty
                  //           ? getTranslated(this.context, 'quesempty')
                  //           : null;
                  //     },
                  //   ),
                  // ),
                  // ListTile(
                  //   leading: Icon(Icons.lock_open),
                  //   title: TextFormField(
                  //     autovalidateMode: AutovalidateMode.always,
                  //     decoration: InputDecoration(
                  //         labelText:
                  //             getTranslated(this.context, 'sans')),
                  //     controller: _answer,
                  //     validator: (v) {
                  //       if (v.trim().isEmpty)
                  //         return getTranslated(
                  //             this.context, 'ansempty');
                  //       if (Lamat.getHashedAnswer(v) ==
                  //           widget.answer)
                  //         return getTranslated(this.context, 'newans');
                  //       return null;
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ))),
      Positioned(
        child: isLoading
            ? Container(
                color: pickTextColorBasedOnBgColorAdvanced(
                        !Teme.isDarktheme(widget.prefs)
                            ? AppConstants.backgroundColorDark
                            : AppConstants.backgroundColor)
                    .withOpacity(0.6),
                child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.secondaryColor)),
                ),
              )
            : Container(),
      )
    ]));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = enteredPasscode.length == 4;
    _verificationNotifier.add(isValid);
    _passCode = null;
    if (isValid) {
      setState(() {
        _passCode = enteredPasscode;
      });
    }
  }

  _showLockScreen() {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            prefs: widget.prefs,
            onSubmit: null,
            wait: true,
            authentication: false,
            passwordDigits: 4,
            title: LocaleKeys.enterpass.tr(),
            passwordEnteredCallback: _onPasscodeEntered,
            cancelLocalizedText: LocaleKeys.cancel.tr(),
            deleteLocalizedText: LocaleKeys.delete.tr(),
            shouldTriggerVerification: _verificationNotifier.stream,
          ),
        ));
  }
}
