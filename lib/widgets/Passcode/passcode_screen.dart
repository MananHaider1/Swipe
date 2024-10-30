import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:lamatdating/widgets/Passcode/circle.dart';
import 'package:lamatdating/widgets/Passcode/keyboard.dart';
import 'package:lamatdating/widgets/Passcode/shake_curve.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PasswordEnteredCallback = void Function(String text);

class PasscodeScreen extends StatefulWidget {
  final String? title, question, answer, phoneNo;
  final int passwordDigits;
  final PasswordEnteredCallback passwordEnteredCallback;
  final String cancelLocalizedText;
  final String deleteLocalizedText;
  final Stream<bool> shouldTriggerVerification;
  final Widget? bottomWidget;
  final bool shouldPop;
  final CircleUIConfig? circleUIConfig;
  final KeyboardUIConfig? keyboardUIConfig;
  final bool wait, authentication;
  final SharedPreferences prefs;
  final Function? onSubmit;

  const PasscodeScreen(
      {super.key,
      required this.onSubmit,
      required this.title,
      this.passwordDigits = 6,
      required this.prefs,
      required this.passwordEnteredCallback,
      required this.cancelLocalizedText,
      required this.deleteLocalizedText,
      required this.shouldTriggerVerification,
      required this.wait,
      this.circleUIConfig,
      this.keyboardUIConfig,
      this.bottomWidget,
      this.authentication = false,
      this.question,
      this.answer,
      this.phoneNo,
      this.shouldPop = true});

  @override
  State<StatefulWidget> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<bool> streamSubscription;
  String enteredPasscode = '';
  late AnimationController controller;
  late Animation<double> animation;
  bool _isValid = false;
  // TextEditingController _answer = TextEditingController();
  // GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int passcodeTries = 0;
  int answerTries = 0;
  bool forgetVisible = false;

  bool forgetActionable() {
    int tries = widget.prefs.getInt(Dbkeys.answerTries) ?? 0;
    int lastAnswered = widget.prefs.getInt(Dbkeys.lastAnswered) ??
        DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    DateTime lastTried = DateTime.fromMillisecondsSinceEpoch(lastAnswered);
    return (tries <= Dbkeys.triesThreshold ||
        DateTime.now().isAfter(lastTried.add(Duration(
            minutes: math.pow(Dbkeys.timeBase, tries - Dbkeys.triesThreshold)
                as int))));
  }

  @override
  void initState() {
    super.initState();
    if (widget.authentication) {
      passcodeTries = widget.prefs.getInt(Dbkeys.passcodeTries) ?? 0;
      forgetVisible = passcodeTries > Dbkeys.triesThreshold - 1;
      answerTries = widget.prefs.getInt(Dbkeys.answerTries) ?? 0;
    }
    streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
      _showValidation(isValid);
      setState(() {
        _isValid = isValid;
      });
    });
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation curve =
        CurvedAnimation(parent: controller, curve: ShakeCurve());
    animation = Tween(begin: 0.0, end: 10.0).animate(curve as Animation<double>)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            enteredPasscode = '';
            controller.value = 0;
          });
        }
      })
      ..addListener(() {
        setState(() {
          // the animation object’s value is the changed state
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Lamat.getNTPWrappedWidget(Scaffold(
      appBar: widget.wait
          ? AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              elevation: 0,
              backgroundColor: Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor,
              title: Text(
                widget.title!,
                style: TextStyle(
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                ),
              ),
              actions: const <Widget>[],
            )
          : null,
      backgroundColor: Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.wait
                  ? "Use a passcode that is difficult to guess. "
                  : widget.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, left: 60, right: 60),
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _buildCircles(),
              ),
            ),
            IntrinsicHeight(
              child: Container(
                margin: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Keyboard(
                  onDeleteCancelTap: _onDeleteCancelButtonPressed,
                  onKeyboardTap: _onKeyboardButtonPressed,
                  shouldShowCancel: enteredPasscode.isEmpty,
                  cancelLocalizedText: widget.cancelLocalizedText,
                  deleteLocalizedText: widget.deleteLocalizedText,
                  keyboardUIConfig: widget.keyboardUIConfig ??
                      KeyboardUIConfig(
                          primaryColor: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                          digitTextStyle: TextStyle(
                              fontSize: 30,
                              color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor))),
                ),
              ),
            ),
            _isValid == true
                ? Container(
                    margin: EdgeInsets.only(
                        bottom: !kIsWeb
                            ? Platform.isIOS
                                ? 15
                                : 0
                            : 15),
                    height: 107,
                    width: MediaQuery.of(this.context).size.width,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 39, 28, 10),
                        child: myElevatedButton(
                          color: AppConstants.lamatGreenColor500,
                          child: const Text(
                            "Done",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: _isValid
                              ? () {
                                  if (widget.onSubmit != null) {
                                    widget.onSubmit!(enteredPasscode);
                                  }
                                  Navigator.maybePop(context);
                                }
                              : null,
                        )),
                  )
                : const SizedBox(),
            widget.authentication && forgetVisible
                ? const Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 7, left: 20, right: 20),
                    child: Text(
                        "To proceed next, Please try again later or Logout of the App to Reset Passcode.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white,
                            fontWeight: FontWeight.w300)))
                : const SizedBox()
          ],
        ),
      )),
    ));
  }

  List<Widget> _buildCircles() {
    var list = <Widget>[];
    var config = widget.circleUIConfig != null
        ? widget.circleUIConfig!
        : CircleUIConfig(
            fillColor: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
            borderColor: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
          );
    config.extraSize = animation.value;
    for (int i = 0; i < widget.passwordDigits; i++) {
      list.add(Circle(
        filled: i < enteredPasscode.length,
        circleUIConfig: config,
      ));
    }
    return list;
  }

  _onDeleteCancelButtonPressed() {
    if (enteredPasscode.isNotEmpty) {
      setState(() {
        enteredPasscode =
            enteredPasscode.substring(0, enteredPasscode.length - 1);
        widget.passwordEnteredCallback(enteredPasscode);
      });
    } else {
      Navigator.maybePop(context);
    }
  }

  _onKeyboardButtonPressed(String text) {
    setState(() {
      if (enteredPasscode.length < widget.passwordDigits) {
        enteredPasscode += text;
        widget.passwordEnteredCallback(enteredPasscode);
        if (enteredPasscode.length == widget.passwordDigits) {
          if (widget.authentication &&
              widget.prefs.getInt(Dbkeys.passcodeTries)! >
                  Dbkeys.triesThreshold - 1) {
            if (forgetVisible != true) {
              setState(() {
                forgetVisible = true;
              });
            }
          }
        }
      }
    });
  }

  @override
  didUpdateWidget(PasscodeScreen old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the one
    if (widget.shouldTriggerVerification != old.shouldTriggerVerification) {
      streamSubscription.cancel();
      streamSubscription = widget.shouldTriggerVerification.listen((isValid) {
        _showValidation(isValid);
        setState(() {
          _isValid = isValid;
        });
      });
    }
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
    streamSubscription.cancel();
  }

  _showValidation(bool isValid) {
    if (!widget.wait) {
      if (isValid && widget.shouldPop) {
        Navigator.maybePop(context);
      } else {
        controller.forward();
      }
    }
  }
}
