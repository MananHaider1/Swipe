// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/models/data_model.dart';
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

class ContactsSelect extends ConsumerStatefulWidget {
  const ContactsSelect({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.onSelect,
  });
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final Function(String? contactname, String contactphone) onSelect;

  @override
  ContactsSelectState createState() => ContactsSelectState();
}

class ContactsSelectState extends ConsumerState<ContactsSelect>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?> _filtered = <String, String>{};

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
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
        'selectcontact'.tr(),
        style: TextStyle(
          fontSize: 18,
          color: pickTextColorBasedOnBgColorAdvanced(
              Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor),
        ),
      );
    });
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> _currentUser = widget.model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        Completer<Map<String?, String?>>();

    final storage = Hive.box(HiveConstants.hiveBox);
    // LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

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
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  for (var number in numbers) {
                    _cachedContacts[number] = p.displayName;
                    setState(() {});
                  }
                  setState(() {});
                }
              });
              setState(() {});
              await storage.put(Dbkeys.cachedContacts, _cachedContacts);
              return completer.complete(_cachedContacts);
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
      Lamat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  Widget _appBarTitle = const Text('');
  Icon? _searchIcon;

  void _searchPressed() {
    setState(() {
      if (_searchIcon!.icon == Icons.search) {
        _searchIcon = Icon(
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
        _searchIcon = Icon(
          Icons.search,
          color: pickTextColorBasedOnBgColorAdvanced(
              Teme.isDarktheme(widget.prefs)
                  ? AppConstants.backgroundColorDark
                  : AppConstants.backgroundColor),
        );
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

    _searchIcon = Icon(
      Icons.search,
      color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor),
    );

    _searchPressed();

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
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    centerTitle: false,
                    title: _appBarTitle,
                    actions: <Widget>[
                      IconButton(
                        icon: _searchIcon!,
                        onPressed: _searchPressed,
                      )
                    ],
                  ),
                  body: RefreshIndicator(
                      onRefresh: () {
                        return getContacts(refresh: true);
                      },
                      child: _filtered.isEmpty
                          ? ListView(children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height /
                                          2.5),
                                  child: Center(
                                    child: Text('nosearchresult'.tr(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: AppConstants.lamatBlack,
                                        )),
                                  ))
                            ])
                          : ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: _filtered.length,
                              itemBuilder: (context, idx) {
                                MapEntry user =
                                    _filtered.entries.elementAt(idx);
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
                                              backgroundColor:
                                                  AppConstants.secondaryColor,
                                              radius: 22.5,
                                              child: Text(
                                                Lamat.getInitials(userDoc.name),
                                                style: const TextStyle(
                                                    color: AppConstants
                                                        .lamatWhite),
                                              )),
                                          title: Text(userDoc.name,
                                              style: TextStyle(
                                                  color: pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor))),
                                          subtitle: Text(phone,
                                              style: const TextStyle(
                                                  color:
                                                      AppConstants.lamatGrey)),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 0.0),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            widget.onSelect(user.value, phone);
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
                                                  color:
                                                      AppConstants.lamatWhite),
                                            )),
                                        title: Text(user.value,
                                            style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor))),
                                        subtitle: Text(phone,
                                            style: const TextStyle(
                                                color: AppConstants.lamatGrey)),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 0.0),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          widget.onSelect(user.value, phone);
                                        },
                                      );
                                    });
                              },
                            )));
            }))));
  }
}
