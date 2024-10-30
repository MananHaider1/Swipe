// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/contact_screens/add_unsaved_contact.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contacts extends ConsumerStatefulWidget {
  const Contacts({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
  });
  final String? currentUserNo;
  final DataModel? model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  @override
  ContactsState createState() => ContactsState();
}

class ContactsState extends ConsumerState<Contacts>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?>? _filtered = <String, String>{};

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();

  late String _query;

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  ContactsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _query = "";
          _filtered = contacts;
        });
      } else {
        setState(() {
          _query = _filter.text;
          _filtered =
              Map.fromEntries(contacts!.entries.where((MapEntry contact) {
            return contact.value
                .toLowerCase()
                .trim()
                .contains(RegExp(r'' + _query.toLowerCase().trim() + ''));
          }));
        });
      }
    });
  }

  loading() {
    return const Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
      ))
    ]);
  }

  @override
  initState() {
    super.initState();
    getContacts();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarTitle = Text(
        'searchcontact'.tr(),
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: pickTextColorBasedOnBgColorAdvanced(
              Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor),
        ),
      );

      _searchPressed();
    });
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> currentUser = widget.model!.currentUser!;
    return currentUser[Dbkeys.hidden] != null &&
        currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        Completer<Map<String?, String?>>();

    final storage = Hive.box(HiveConstants.hiveBox);
    // LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          contacts = _filtered = c;
        });
      }
    });

    Lamat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        
          if (storage.isOpen) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? phone = getNormalizedNumber(number.value);

                        return phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  for (var number in numbers) {
                    cachedContacts[number] = p.displayName;
                  }
                  setState(() {});
                }
              });

              // await storage.setItem(Dbkeys.cachedContacts, _cachedContacts);
              completer.complete(cachedContacts);
            });
          }
          // }
        
      } else {
        Lamat.showRationale(
          'permcontact'.tr(),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpenSettings(
                      permtype: 'contact',
                      prefs: widget.prefs,
                    )));
      }
    }).catchError((onError) {
      Lamat.showRationale('${'errorOccured'.tr()} $onError');
    });

    return completer.future;
  }

  Widget _appBarTitle = const Text('');

  void _searchPressed() {
    Icon searchIcon = Icon(
      Icons.search,
      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor),
    );
    setState(() {
      if (searchIcon.icon == Icons.search) {
        searchIcon = Icon(
          Icons.close,
          color: pickTextColorBasedOnBgColorAdvanced(
              Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor),
        );
        _appBarTitle = TextField(
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          style: TextStyle(
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
            fontSize: 18.5,
            fontWeight: FontWeight.w600,
          ),
          controller: _filter,
          decoration: InputDecoration(
              labelStyle: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
              ),
              hintText: 'search'.tr(),
              hintStyle: TextStyle(
                fontSize: 18.5,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
              )),
        );
      } else {
        _appBarTitle = Text(
          'searchcontact'.tr(),
          style: TextStyle(
            fontSize: 18.5,
            color: pickTextColorBasedOnBgColorAdvanced(
                Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor),
          ),
        );

        _filter.clear();
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final contactsProvider = ref.watch(smartContactProvider);

    Icon searchIcon = Icon(
      Icons.search,
      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor),
    );

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0.4,
                    titleSpacing: 5,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                      ),
                    ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    centerTitle: false,
                    title: _appBarTitle,
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.add_call,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AddunsavedNumber(
                                prefs: widget.prefs,
                                model: widget.model,
                                currentUserNo: widget.currentUserNo);
                          }));
                        },
                      ),
                      IconButton(
                        icon: searchIcon,
                        onPressed: _searchPressed,
                      )
                    ],
                  ),
                  body: contacts == null
                      ? loading()
                      : RefreshIndicator(
                          onRefresh: () {
                            return getContacts(refresh: true);
                          },
                          child: _filtered!.isEmpty
                              ? ListView(children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.5),
                                      child: Center(
                                        child: Text('nocontacts'.tr(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: AppConstants.lamatBlack,
                                            )),
                                      ))
                                ])
                              : ListView.builder(
                                  padding: const EdgeInsets.all(10),
                                  itemCount: _filtered!.length,
                                  itemBuilder: (context, idx) {
                                    MapEntry user =
                                        _filtered!.entries.elementAt(idx);
                                    String phone = user.key;
                                    return FutureBuilder<LocalUserData?>(
                                        future: contactsProvider
                                            .fetchUserDataFromnLocalOrServer(
                                                widget.prefs, phone),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<LocalUserData?>
                                                snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data != null) {
                                            var userDoc = snapshot.data!;
                                            return ListTile(
                                              leading: CircleAvatar(
                                                  backgroundColor: AppConstants
                                                      .secondaryColor,
                                                  radius: 22.5,
                                                  child: Text(
                                                    Lamat.getInitials(
                                                        userDoc.name),
                                                    style: const TextStyle(
                                                        color: AppConstants
                                                            .lamatWhite),
                                                  )),
                                              title: Text(userDoc.name,
                                                  style: TextStyle(
                                                    color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                            .isDarktheme(
                                                                widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor),
                                                  )),
                                              subtitle: Text(phone,
                                                  style: const TextStyle(
                                                      color: AppConstants
                                                          .lamatGrey)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 0.0),
                                              onTap: () {
                                                hidekeyboard(context);
                                                dynamic wUser =
                                                    model.userData[phone];
                                                if (wUser != null &&
                                                    wUser[Dbkeys.chatStatus] !=
                                                        null) {
                                                  if (model.currentUser![
                                                              Dbkeys.locked] !=
                                                          null &&
                                                      model.currentUser![
                                                              Dbkeys.locked]
                                                          .contains(phone)) {
                                                    ChatController.authenticate(
                                                        model,
                                                        'authneededchat'.tr(),
                                                        prefs: widget.prefs,
                                                        shouldPop: false,
                                                        state: Navigator.of(
                                                            context),
                                                        type: Lamat
                                                            .getAuthenticationType(
                                                                widget
                                                                    .biometricEnabled,
                                                                model),
                                                        onSuccess: () {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ChatScreen(
                                                                  isSharingIntentForwarded:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  model: model,
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  peerNo: phone,
                                                                  unread: 0)),
                                                          (Route r) =>
                                                              r.isFirst);
                                                    });
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ChatScreen(
                                                                    isSharingIntentForwarded:
                                                                        false,
                                                                    prefs: widget
                                                                        .prefs,
                                                                    model:
                                                                        model,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo,
                                                                    peerNo:
                                                                        phone,
                                                                    unread:
                                                                        0)));
                                                  }
                                                } else {
                                                  Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                    return PreChat(
                                                        prefs: widget.prefs,
                                                        model: widget.model,
                                                        name: user.value,
                                                        phone: phone,
                                                        currentUserNo: widget
                                                            .currentUserNo);
                                                  }));
                                                }
                                              },
                                            );
                                          }
                                          return ListTile(
                                            leading: CircleAvatar(
                                                backgroundColor:
                                                    AppConstants.secondaryColor,
                                                radius: 22.5,
                                                child: Text(
                                                  Lamat.getInitials(user.value),
                                                  style: const TextStyle(
                                                      color: AppConstants
                                                          .lamatWhite),
                                                )),
                                            title: Text(user.value,
                                                style: TextStyle(
                                                  color: pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor),
                                                )),
                                            subtitle: Text(phone,
                                                style: const TextStyle(
                                                    color: AppConstants
                                                        .lamatGrey)),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 0.0),
                                            onTap: () {
                                              hidekeyboard(context);
                                              dynamic wUser =
                                                  model.userData[phone];
                                              if (wUser != null &&
                                                  wUser[Dbkeys.chatStatus] !=
                                                      null) {
                                                if (model.currentUser![
                                                            Dbkeys.locked] !=
                                                        null &&
                                                    model.currentUser![
                                                            Dbkeys.locked]
                                                        .contains(phone)) {
                                                  ChatController.authenticate(
                                                      model,
                                                      'authneededchat'.tr(),
                                                      prefs: widget.prefs,
                                                      shouldPop: false,
                                                      state: Navigator.of(
                                                          context),
                                                      type: Lamat
                                                          .getAuthenticationType(
                                                              widget
                                                                  .biometricEnabled,
                                                              model),
                                                      onSuccess: () {
                                                    Navigator.pushAndRemoveUntil(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => ChatScreen(
                                                                isSharingIntentForwarded:
                                                                    false,
                                                                prefs: widget
                                                                    .prefs,
                                                                model: model,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo,
                                                                peerNo: phone,
                                                                unread: 0)),
                                                        (Route r) => r.isFirst);
                                                  });
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatScreen(
                                                                  isSharingIntentForwarded:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  model: model,
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  peerNo: phone,
                                                                  unread: 0)));
                                                }
                                              } else {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                  return PreChat(
                                                      prefs: widget.prefs,
                                                      model: widget.model,
                                                      name: user.value,
                                                      phone: phone,
                                                      currentUserNo:
                                                          widget.currentUserNo);
                                                }));
                                              }
                                            },
                                          );
                                        });
                                  },
                                )));
            }))));
  }
}
