import 'dart:core';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:lamatdating/providers/auth_providers.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/widgets/CountryPicker/country_code.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/utils.dart';
// import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreChat extends ConsumerStatefulWidget {
  final String? name, phone, currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const PreChat(
      {super.key,
      required this.name,
      required this.prefs,
      required this.phone,
      required this.currentUserNo,
      required this.model});

  @override
  PreChatState createState() => PreChatState();
}

class PreChatState extends ConsumerState<PreChat> with WidgetsBindingObserver {
  bool? isLoading, isUser = false;
  bool issearching = true;
  String? peerphone;
  bool issearchraw = false;
  String? formattedphone;
  String? myphoneNumber;
  DataModel? _cachedModel;
  bool isloaded = false;
  Map<String, dynamic> peer = {};

  @override
  initState() {
    // getModel();
    isLoading = true;
    String? peer = widget.phone;
    // String peer = '+213-0791809113';
    setState(() {
      peerphone = peer!.replaceAll(RegExp(r'-'), '');
      peerphone!.trim();
    });

    formattedphone = peerphone;

    if (!peerphone!.startsWith('+')) {
      if ((peerphone!.length > 11)) {
        for (var code in CountryCodes) {
          if (peerphone!.startsWith(code) && issearching == true) {
            setState(() {
              formattedphone =
                  peerphone!.substring(code.length, peerphone!.length);
              issearchraw = true;
              issearching = false;
            });
          }
        }
      } else {
        setState(() {
          setState(() {
            issearchraw = true;
            formattedphone = peerphone;
          });
        });
      }
    } else {
      setState(() {
        issearchraw = false;
        formattedphone = peerphone;
      });
    }
    WidgetsBinding.instance.addObserver(this);
    if (widget.currentUserNo != '') {
      getModel();
    }
    getUser();

    super.initState();
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.prefs.getString(Dbkeys.phone));
    return _cachedModel;
  }

  getUser() {
    Query<Map<String, dynamic>> query = issearchraw == true
        ? FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phoneRaw, isEqualTo: formattedphone ?? peerphone)
            .limit(1)
        : FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.phone, isEqualTo: formattedphone ?? peerphone)
            .limit(1);

    query.get().then((user) {
      setState(() {
        isUser = user.docs.isEmpty ? false : true;
      });
      if (isUser!) {
        peer = user.docs[0].data();

//  OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == true
//               ? widget.user.containsKey(Dbkeys.deviceSavedLeads)
//                   ? widget.user[Dbkeys.deviceSavedLeads]
//                           .contains(widget.currentUserNo)
//                       ? buildBody(context)
//                       : SizedBox(
//                           height: 40,
//                         )
//                   : SizedBox()
//               : buildBody(context),
        if (OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == true) {
          if (peer.containsKey(Dbkeys.deviceSavedLeads)) {
            if (peer[Dbkeys.deviceSavedLeads].contains(widget.currentUserNo)) {
              if (peer[Dbkeys.phone] == widget.currentUserNo) {
                debugPrint(
                    'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Phone Matched peer[Dbkeys.phone] == widget.currentUserNo');
                Navigator.of(context).pop();
              } else {
                _cachedModel!.addUser(user.docs[0]);
                setState(() {
                  isloaded = true;
                  isLoading = false;
                });
              }
            } else {
              debugPrint(
                  'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Doesnot Contain deviceSavedLeads currentUserNo');
              Navigator.of(context).pop();
              Lamat.toast(LocaleKeys.userPrivate.tr());
            }
          } else {
            debugPrint(
                'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Doesnot Contain deviceSavedLeads');
            Navigator.of(context).pop();
            Lamat.toast(LocaleKeys.userPrivate.tr());
          }
        } else {
          if (peer[Dbkeys.phone] == widget.currentUserNo) {
            debugPrint(
                'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Phone Matched peer[Dbkeys.phone] == widget.currentUserNo');
            Navigator.of(context).pop();
          } else {
            _cachedModel!.addUser(user.docs[0]);
            setState(() {
              isloaded = true;
              isLoading = false;
            });
          }
        }
      } else {
        Query<Map<String, dynamic>> queryretrywithoutzero = issearchraw == true
            ? FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1)
            : FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .where(Dbkeys.phoneRaw,
                    isEqualTo: formattedphone == null
                        ? peerphone!.substring(1, peerphone!.length)
                        : formattedphone!.substring(1, formattedphone!.length))
                .limit(1);
        queryretrywithoutzero.get().then((user) {
          setState(() {
            isLoading = false;
            isUser = user.docs.isEmpty ? false : true;
          });
          if (isUser!) {
            peer = user.docs[0].data();

            if (OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == true) {
              if (peer.containsKey(Dbkeys.deviceSavedLeads)) {
                if (peer[Dbkeys.deviceSavedLeads]
                    .contains(widget.currentUserNo)) {
                  if (peer[Dbkeys.phone] == widget.currentUserNo) {
                    debugPrint(
                        'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Phone Matched peer[Dbkeys.phone] == widget.currentUserNo');
                    Navigator.of(context).pop();
                  } else {
                    _cachedModel!.addUser(user.docs[0]);
                    setState(() {
                      isloaded = true;
                      isLoading = false;
                    });
                  }
                } else {
                  debugPrint(
                      'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Doesnot Contain deviceSavedLeads currentUserNo');
                  Navigator.of(context).pop();
                  Lamat.toast(LocaleKeys.userPrivate.tr());
                }
              } else {
                debugPrint(
                    'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Doesnot Contain deviceSavedLeads');
                Navigator.of(context).pop();
                Lamat.toast(LocaleKeys.userPrivate.tr());
              }
            } else {
              if (peer[Dbkeys.phone] == widget.currentUserNo) {
                debugPrint(
                    'Nav Back >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Phone Matched peer[Dbkeys.phone] == widget.currentUserNo');
                Navigator.of(context).pop();
              } else {
                _cachedModel!.addUser(user.docs[0]);
                setState(() {
                  isloaded = true;
                  isLoading = false;
                });
              }
            }
          }
        });
      }
    });
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading!
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
              ))
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Lamat.getNTPWrappedWidget(Scaffold(
      // appBar: AppBar(
      //     elevation: 0.4,
      //     leading: IconButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       icon: Icon(
      //         Icons.keyboard_arrow_left_rounded,
      //         size: 30,
      //         color: pickTextColorBasedOnBgColorAdvanced(
      //             Teme.isDarktheme(widget.prefs)
      //                 ? AppConstants.backgroundColorDark
      //                 : AppConstants.backgroundColor),
      //       ),
      //     ),
      //     backgroundColor: Teme.isDarktheme(widget.prefs)
      //         ? AppConstants.backgroundColorDark
      //         : AppConstants.backgroundColor,
      //     title: Text(
      //       widget.name!,
      //       style: TextStyle(
      //         color: pickTextColorBasedOnBgColorAdvanced(
      //             Teme.isDarktheme(widget.prefs)
      //                 ? AppConstants.backgroundColorDark
      //                 : AppConstants.backgroundColor),
      //       ),
      //     )),
      body: isLoading == true
          ? const SizedBox()
          : ChatScreen(
              isSharingIntentForwarded: false,
              prefs: widget.prefs,
              unread: 0,
              currentUserNo: widget.currentUserNo,
              model: _cachedModel!,
              peerNo: peer[Dbkeys.phone]),
      backgroundColor: Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
    ));
  }
}
