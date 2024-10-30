// ignore_for_file: no_logic_in_create_state, void_checks, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/admob.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/utils/alias.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/util/messagedata.dart';

class SearchChats extends ConsumerStatefulWidget {
  const SearchChats(
      {required this.currentUserNo,
      required this.isSecuritySetupDone,
      required this.prefs,
      super.key})
      ;
  final String? currentUserNo;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  @override
  ConsumerState createState() => SearchChatsState(currentUserNo: currentUserNo);
}

class SearchChatsState extends ConsumerState<SearchChats> {
  SearchChatsState({Key? key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  final TextEditingController _filter = TextEditingController();
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);
  BannerAd? myBanner;
  AdWidget? adWidget;
  @override
  void initState() {
    if (!kIsWeb) {
      myBanner = BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: const BannerAdListener(),
      );
    }
    super.initState();
    Lamat.internetLookUp();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      if (IsBannerAdShow == true && observer.isadmobshow == true && !kIsWeb) {
        myBanner!.load();
        adWidget = AdWidget(ad: myBanner!);
        setState(() {});
      }
    });
  }

  getuid(BuildContext context) {
    final UserProvider userProvider = ref.watch(userProviderProvider);
    userProvider.getUserDetails(currentUserNo);
  }

  void cancelUnreadSubscriptions() {
    for (var subscription in unreadSubscriptions) {
      subscription.cancel();
    }
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  String? currentUserNo;

  bool isLoading = false;

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {
    if (user[Dbkeys.phone] == currentUserNo) {
      return const SizedBox(width: 0, height: 0);
    } else {
      return StreamBuilder(
        stream: getUnread(user).asBroadcastStream(),
        builder: (context, AsyncSnapshot<MessageData> unreadData) {
          int unread = unreadData.hasData &&
                  unreadData.data!.snapshot.docs.isNotEmpty
              ? unreadData.data!.snapshot.docs
                  .where((t) => t[Dbkeys.timestamp] > unreadData.data!.lastSeen)
                  .length
              : 0;
          return Column(
            children: [
              ListTile(
                  onLongPress: () {
                    unawaited(showDialog(
                        context: context,
                        builder: (context) {
                          return AliasForm(user, _cachedModel, widget.prefs);
                        }));
                  },
                  leading: customCircleAvatar(
                      url: user[Dbkeys.photoUrl], radius: 22),
                  title: Text(
                    Lamat.getNickname(user)!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pickTextColorBasedOnBgColorAdvanced(
                          Teme.isDarktheme(widget.prefs)
                              ? AppConstants.backgroundColorDark
                              : AppConstants.backgroundColor),
                      fontSize: 16.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    if (_cachedModel!.currentUser![Dbkeys.locked] != null &&
                        _cachedModel!.currentUser![Dbkeys.locked]
                            .contains(user[Dbkeys.phone])) {
                      NavigatorState state = Navigator.of(context);
                      ChatController.authenticate(
                          _cachedModel!, LocaleKeys.authneededchat.tr(),
                          state: state,
                          shouldPop: false,
                          type: Lamat.getAuthenticationType(
                              biometricEnabled, _cachedModel),
                          prefs: widget.prefs, onSuccess: () {
                        state.push(MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                isSharingIntentForwarded: false,
                                prefs: widget.prefs,
                                unread: unread,
                                model: _cachedModel!,
                                currentUserNo: currentUserNo,
                                peerNo: user[Dbkeys.phone] as String?)));
                      });
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  isSharingIntentForwarded: false,
                                  prefs: widget.prefs,
                                  unread: unread,
                                  model: _cachedModel!,
                                  currentUserNo: currentUserNo,
                                  peerNo: user[Dbkeys.phone] as String?)));
                    }
                  },
                  trailing: unread != 0
                      ? Container(
                          padding: const EdgeInsets.all(7.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: user[Dbkeys.lastSeen] == true
                                ? AppConstants.lamatGreenColor400
                                : Colors.blue[300],
                          ),
                          child: Text(unread.toString(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      : user[Dbkeys.lastSeen] == true
                          ? Container(
                              padding: const EdgeInsets.all(7.0),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppConstants.lamatGreenColor400),
                              child: const SizedBox(width: 0, height: 0),
                            )
                          : const SizedBox(
                              height: 0,
                              width: 0,
                            )),
              const Divider(),
            ],
          );
        },
      );
    }
  }

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = Lamat.getChatId(currentUserNo!, user[Dbkeys.phone]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[currentUserNo!] != null && doc[currentUserNo!] is int) {
        unreadSubscriptions.add(FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(
              MessageData(snapshot: snapshot, lastSeen: doc[currentUserNo!]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(phoneNo) {
    Map<String, dynamic> currentUser = _cachedModel!.currentUser!;
    return currentUser[Dbkeys.hidden] != null &&
        currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  final StreamController<String> _userQuery =
      StreamController<String>.broadcast();

  List<Map<String, dynamic>> _users = List.from(<Map<String, dynamic>>[]);

  _chats(Map<String?, Map<String, dynamic>?> userData,
      Map<String, dynamic>? currentUser) {
    _users = Map.from(userData)
        .values
        .where((user) => user.keys.contains(Dbkeys.chatStatus))
        .toList()
        .cast<Map<String, dynamic>>();
    Map<String?, int?> lastSpokenAt = _cachedModel!.lastSpokenAt;
    List<Map<String, dynamic>> filtered = List.from(<Map<String, dynamic>>[]);

    _users.sort((a, b) {
      int aTimestamp = lastSpokenAt[a[Dbkeys.phone]] ?? 0;
      int bTimestamp = lastSpokenAt[b[Dbkeys.phone]] ?? 0;
      return bTimestamp - aTimestamp;
    });

    if (!showHidden) {
      _users.removeWhere((user) => _isHidden(user[Dbkeys.phone]));
    }

    return RefreshIndicator(
        onRefresh: () {
          isAuthenticating = false;
          setState(() {
            showHidden = true;
          });
          return Future.value(false);
        },
        child: _users.isNotEmpty
            ? StreamBuilder(
                stream: _userQuery.stream.asBroadcastStream(),
                builder: (context, snapshot) {
                  if (_filter.text.isNotEmpty || snapshot.hasData) {
                    filtered = _users.where((user) {
                      return user[Dbkeys.nickname]
                          .toLowerCase()
                          .trim()
                          .contains(RegExp(
                              r'' + _filter.text.toLowerCase().trim() + ''));
                    }).toList();
                    if (filtered.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(0.0),
                        itemBuilder: (context, index) =>
                            buildItem(context, filtered.elementAt(index)),
                        itemCount: filtered.length,
                      );
                    } else {
                      return const SizedBox();
                    }
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                    itemBuilder: (context, index) =>
                        buildItem(context, _users.elementAt(index)),
                    itemCount: _users.length,
                  );
                })
            : const SizedBox());
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  Widget build(BuildContext context) {
    final observer = ref.watch(observerProvider);
    return Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child: ScopedModelDescendant<DataModel>(builder: (context, child, model) {
        _cachedModel = model;
        // will implement Google ads here in next update
        return ListView(
            padding: IsBannerAdShow == true && observer.isadmobshow == true
                ? const EdgeInsets.fromLTRB(5, 5, 5, 60)
                : const EdgeInsets.all(5),
            shrinkWrap: true,
            children: [
              Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: TextField(
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: _filter,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      hintText: LocaleKeys.searchrecentchats.tr(),
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.1), width: 0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30.0)),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ),
                  )),
              _chats(model.userData, model.currentUser)
            ]);
      }),
    ));
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true && !kIsWeb) {
      myBanner!.dispose();
    }
  }
}
