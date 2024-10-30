// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/utils/status_bar_color.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/country_code.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String? title;
  final User? user;
  final bool isVerifying;
  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  final String phoneNumber;
  final String countryCode;
  final String rawPhoneNum;
  const OtpPage({
    super.key,
    this.title,
    this.user,
    required this.isVerifying,
    required this.isaccountapprovalbyadminneeded,
    required this.accountApprovalMessage,
    required this.prefs,
    required this.doc,
    required this.isblocknewlogins,
    required this.phoneNumber,
    required this.countryCode,
    required this.rawPhoneNum,
  });

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  // final _otpController2 = TextEditingController();
  // final _otpController3 = TextEditingController();
  // final _otpController4 = TextEditingController();
  // final _otpController5 = TextEditingController();
  // final _otpController6 = TextEditingController();
  final storage = const FlutterSecureStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  var mapDeviceInfo = {};
  String _verificationId = "";
  String? deviceid;
  User? user;
  PhoneAuthCredential? authCredential;
  String? fcmToken;

  Future<void> _setFCMToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
  }

  setdeviceinfo() async {
    if (!kIsWeb) {
      if (Platform.isAndroid == true) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          deviceid = androidInfo.id + androidInfo.device;
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: androidInfo.model,
            Dbkeys.deviceInfoOS: 'android',
            Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: androidInfo.id,
            Dbkeys.deviceInfoOSID: androidInfo.id,
            Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
            Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      } else if (Platform.isIOS == true) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          deviceid =
              "${iosInfo.systemName}${iosInfo.model}${iosInfo.systemVersion}";
          mapDeviceInfo = {
            Dbkeys.deviceInfoMODEL: iosInfo.model,
            Dbkeys.deviceInfoOS: 'ios',
            Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
            Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
            Dbkeys.deviceInfoOSID: iosInfo.name,
            Dbkeys.deviceInfoOSVERSION: iosInfo.name,
            Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
            Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
          };
        });
      }
    } else {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      setState(() {
        deviceid = webBrowserInfo.appName! +
            webBrowserInfo.browserName.toString() +
            webBrowserInfo.appVersion!;
        mapDeviceInfo = {
          Dbkeys.deviceInfoMODEL: webBrowserInfo.appName,
          Dbkeys.deviceInfoOS: 'web',
          Dbkeys.deviceInfoISPHYSICAL: webBrowserInfo.platform,
          Dbkeys.deviceInfoDEVICEID: deviceid,
          Dbkeys.deviceInfoOSID: webBrowserInfo.productSub,
          Dbkeys.deviceInfoOSVERSION: webBrowserInfo.productSub,
          Dbkeys.deviceInfoMANUFACTURER: webBrowserInfo.appName,
          Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
        };
      });
    }
  }

  Future<void> _phoneSignIn() async {
    await _auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: widget.phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    return null;
    //  final firebaseUser = widget.user;
    //  await firebaseUser!.updatePhoneNumber(authCredential);
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      EasyLoading.showError('invalidPhoneNumber'.tr());
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    setState(() {
      _verificationId = verificationId;
      _isLoading = false;
    });
    EasyLoading.showSuccess('codeIsSent'.tr());
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _phoneSignIn();

    setdeviceinfo();

    _setFCMToken();

    setStatusBarColor(widget.prefs);

    super.initState();
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(currentUserNo.replaceFirst(RegExp(r'\+'), ''))
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(Dbkeys.topicUSERS)
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }
    if (kIsWeb == false) {
      await FirebaseMessaging.instance
          .subscribeToTopic(Platform.isAndroid
              ? Dbkeys.topicUSERSandroid
              : Platform.isIOS
                  ? Dbkeys.topicUSERSios
                  : Dbkeys.topicUSERSweb)
          .catchError((err) {
        debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
      });
    }

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          for (var doc in query.docs) {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (!doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
                if (kIsWeb == false) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic(
                          "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                  });
                }
              }
            } else {
              if (kIsWeb == false) {
                await FirebaseMessaging.instance
                    .subscribeToTopic(
                        "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                    .catchError((err) {
                  debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                });
              }
            }
          }
        }
      });
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionchannels)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.isNotEmpty) {
          for (var doc in query.docs) {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (!doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
                if (kIsWeb == false) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic(
                          "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                  });
                }
              }
            } else {
              if (kIsWeb == false) {
                await FirebaseMessaging.instance
                    .subscribeToTopic(
                        "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                    .catchError((err) {
                  debugPrint('ERROR SUBSCRIBING NOTIFICATION$err');
                });
              }
            }
          }
        }
      });
    }
  }

  void _onOtpVerification() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.watch(authStateProvider).value;
      EasyLoading.show(status: 'verifyingOTP'.tr());
      _isLoading = true;
      if (widget.isVerifying == false) {
        await ref
            .read(authProvider)
            .signInWithPhoneNumber(_otpController.text.trim(), _verificationId)
            .then((value) async {
          EasyLoading.showSuccess('loginSuccessful'.tr());
          user = value;
          var phoneNo = widget.phoneNumber.trim();

          final result = await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .where(Dbkeys.id, isEqualTo: user!.uid)
              .get();
          final documents = result.docs;

          try {
            if (documents.isEmpty) {
              await widget.prefs.setString(Dbkeys.id, user!.uid);
              await widget.prefs.setString(Dbkeys.phoneRaw, widget.rawPhoneNum);
              await widget.prefs.setString(Dbkeys.phone, phoneNo);
              await widget.prefs.setString(Dbkeys.accountapprovalmessage,
                  widget.accountApprovalMessage!);
              await widget.prefs.setBool(Dbkeys.isaccountapprovalbyadminneeded,
                  widget.isaccountapprovalbyadminneeded ?? false);
              await widget.prefs
                  .setString(Dbkeys.countryCode, widget.countryCode);

              unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, false));

              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LandingWidget()));
            } else {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(user!.phoneNumber)
                  .set(
                      !documents[0].data().containsKey(Dbkeys.deviceDetails)
                          ? {
                              Dbkeys.authenticationType:
                                  AuthenticationType.passcode.index,
                              Dbkeys.lastLogin:
                                  DateTime.now().millisecondsSinceEpoch,
                              Dbkeys.deviceDetails: mapDeviceInfo,
                              Dbkeys.currentDeviceID:
                                  deviceid ?? user!.phoneNumber! + user!.uid,
                              Dbkeys.notificationTokens: [fcmToken],
                            }
                          : {
                              Dbkeys.authenticationType:
                                  AuthenticationType.passcode.index,
                              Dbkeys.lastLogin:
                                  DateTime.now().millisecondsSinceEpoch,
                              Dbkeys.currentDeviceID:
                                  deviceid ?? user!.phoneNumber! + user!.uid,
                              Dbkeys.notificationTokens: [fcmToken],
                            },
                      SetOptions(merge: true));
              // Write data to local
              await widget.prefs.setString(Dbkeys.id, user!.uid);
              // await widget.prefs.setString(
              //     Dbkeys.nickname, documents[0][Dbkeys.nickname] ?? '');
              // await widget.prefs.setString(
              //     Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
              // await widget.prefs.setString(
              //     Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
              await widget.prefs.setString(Dbkeys.phone, user!.phoneNumber!);

              if (!kIsWeb) subscribeToNotification(user!.phoneNumber!, false);

              final box = Hive.box(HiveConstants.hiveBox);
              box.put(HiveConstants.userSet, true);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LandingWidget()));
            }
          } catch (e) {
            showERRORSheet(context, "", message: e.toString());
          }
        });
      } else {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _otpController.text.trim(),
        );
        final firebaseUser = authState!;
        if (!firebaseUser.providerData
            .any((element) => element.providerId == 'phone')) {
          await firebaseUser.linkWithCredential(credential);
        } else {
          EasyLoading.showInfo("UserLinked to an existing account");
        }

        debugPrint('Linked With Credential !!!!!!!!!!!!!!!!!!!!!!!!!');

        final phoneNo = widget.phoneNumber.trim();
        final fcmTokenn = await FirebaseMessaging.instance.getToken();
        final result = await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.id, isEqualTo: user!.uid)
            .get();
        final documents = result.docs;

        try {
          if (documents.isEmpty) {
            await widget.prefs.setString(Dbkeys.id, user!.uid);
            await widget.prefs.setString(Dbkeys.phoneRaw, widget.rawPhoneNum);
            await widget.prefs.setString(Dbkeys.phone, phoneNo);
            await widget.prefs.setString(
                Dbkeys.accountapprovalmessage, widget.accountApprovalMessage!);
            await widget.prefs.setBool(Dbkeys.isaccountapprovalbyadminneeded,
                widget.isaccountapprovalbyadminneeded ?? false);
            await widget.prefs
                .setString(Dbkeys.countryCode, widget.countryCode);

            unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, false));

            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LandingWidget()));
          } else {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(user!.phoneNumber)
                .set(
                    !documents[0].data().containsKey(Dbkeys.deviceDetails)
                        ? {
                            Dbkeys.authenticationType:
                                AuthenticationType.passcode.index,
                            Dbkeys.lastLogin:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.deviceDetails: mapDeviceInfo,
                            Dbkeys.currentDeviceID:
                                deviceid ?? user!.phoneNumber! + user!.uid,
                            Dbkeys.notificationTokens: [fcmToken],
                          }
                        : {
                            Dbkeys.authenticationType:
                                AuthenticationType.passcode.index,
                            Dbkeys.lastLogin:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.currentDeviceID:
                                deviceid ?? user!.phoneNumber! + user!.uid,
                            Dbkeys.notificationTokens: [fcmToken],
                          },
                    SetOptions(merge: true));
            // Write data to local
            await widget.prefs.setString(Dbkeys.id, user!.uid);
            // await widget.prefs.setString(
            //     Dbkeys.nickname, documents[0][Dbkeys.nickname] ?? '');
            // await widget.prefs.setString(
            //     Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
            // await widget.prefs
            //     .setString(Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
            await widget.prefs.setString(Dbkeys.phone, user!.phoneNumber!);

            if (!kIsWeb) subscribeToNotification(user!.phoneNumber!, false);
            final box = Hive.box(HiveConstants.hiveBox);
            box.put(HiveConstants.userSet, true);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LandingWidget()));
          }
        } catch (e) {
          if (kDebugMode) showERRORSheet(context, "", message: e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.defaultNumericValue),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultNumericValue),
                  child: CustomAppBar(
                    leading: CustomIconButton(
                        padding: const EdgeInsets.all(
                            AppConstants.defaultNumericValue / 1.8),
                        onPressed: () => Navigator.pop(context),
                        color: AppConstants.primaryColor,
                        icon: leftArrowSvg),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                SizedBox(height: height * .1),
                Center(
                    child: CustomHeadLine(
                  // prefs: widget.prefs,
                  text: 'enterTheCode'.tr(),
                )),
                const SizedBox(height: AppConstants.defaultNumericValue * 2),
                Center(
                  child: SizedBox(
                    width: width * .8,
                    child: PinFieldAutoFill(
                      keyboardType: TextInputType.phone,
                      decoration: UnderlineDecoration(
                        bgColorBuilder: FixedColorBuilder(
                            Teme.isDarktheme(widget.prefs)
                                ? Colors.white.withOpacity(.2)
                                : AppConstants.primaryColor.withOpacity(.2)),
                        textStyle: TextStyle(
                            fontSize: 28,
                            color: Teme.isDarktheme(widget.prefs)
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold),
                        colorBuilder:
                            FixedColorBuilder(Colors.black.withOpacity(0.0)),
                      ),
                      currentCode: _otpController.text,
                      controller: _otpController,
                      onCodeSubmitted: (otp) {
                        if (otp.isEmpty) {
                          EasyLoading.showError('pleaseEnterTheCode'.tr());
                        } else if (otp.length != 6) {
                          EasyLoading.showError('correctotp'.tr());
                        }
                        return;
                      },
                      onCodeChanged: (code) {
                        // _otpController.text = code ?? "";
                        debugPrint(_otpController.text);
                        if (code!.length == 6) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _onOtpVerification();
                        }
                      },
                    ),
                  ),
                ),
                // OtpTextField(
                //   handleControllers: (controllers) {
                //     controllers[1] = _otpController2;
                //     controllers[2] = _otpController3;
                //     controllers[3] = _otpController4;
                //     controllers[4] = _otpController5;
                //     controllers[5] = _otpController6;

                //     _otpController.text = controllers[0]!.text +
                //         controllers[1]!.text +
                //         controllers[2]!.text +
                //         controllers[3]!.text +
                //         controllers[4]!.text +
                //         controllers[5]!.text;
                //   },
                //   // controller: _otpController,
                //   numberOfFields: 6,
                //   fieldWidth: width * .12,
                //   borderColor: AppConstants.primaryColor,
                //   textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                //         fontWeight: FontWeight.bold,
                //         fontSize: 24,
                //       ),
                //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //   showFieldAsBox: true,
                //   //runs when a code is typed in
                //   onCodeChanged: (value) {

                //     if (_otpController.text.trim().length == 6) {
                //       _onOtpVerification();
                //     }
                //   },
                //   //runs when every textfield is filled
                //   onSubmit: (otp) {
                //     if (otp.isEmpty) {
                //       EasyLoading.showError('pleaseEnterTheCode'.tr());
                //     } else if (otp.length != 6) {
                //       EasyLoading.showError('correctotp'.tr());
                //     }
                //     return;
                //   },
                // ),

                const SizedBox(height: AppConstants.defaultNumericValue),
                Center(
                    child: SizedBox(
                        width: width * .7,
                        child: Text('weHaveSentYouAnOTP'.tr()))),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _isLoading
            ? SizedBox(
                child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
                child: Lottie.asset(loadingDiam,
                    fit: BoxFit.contain, width: 60, height: 60, repeat: true),
              ))
            : SafeArea(
                child: Padding(
                    padding: !kIsWeb
                        ? const EdgeInsets.all(AppConstants.defaultNumericValue)
                        : EdgeInsets.only(
                            right: AppConstants.defaultNumericValue,
                            bottom: AppConstants.defaultNumericValue * 2,
                            left: width * .7),
                    child: CustomButton(
                      onPressed: _onOtpVerification,
                      prefs: widget.prefs,
                      text: LocaleKeys.verify.tr(),
                    ))),
      ),
    );
  }
}

String getFormattedCountryCode(CountryCode country) {
  return "${country.code} ${country.dialCode} ";
}
