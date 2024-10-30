// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/match_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/tabs/home/user_card_widget.dart';
import 'package:lamatdating/views/tabs/matches/matches_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/e2ee.dart' as e2ee;
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/crc.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';

class SmartContactsPage extends ConsumerStatefulWidget {
  final String currentUserNo;
  final DataModel model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  final Function onTapCreateGroup;
  final Function onTapCreateBroadcast;
  const SmartContactsPage({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.onTapCreateBroadcast,
    required this.prefs,
    required this.onTapCreateGroup,
  });

  @override
  SmartContactsPageState createState() => SmartContactsPageState();
}

class SmartContactsPageState extends ConsumerState<SmartContactsPage> {
  // Map<String?, String?>? contacts;
  // Map<String?, String?>? _filtered = Map<String, String>();

  // final TextEditingController _filter = TextEditingController();
  final scrollController = ScrollController();
  int inviteContactsCount = 30;

  List<String> followbackList = [];
  List<String> following = [];
  List<String> followers = [];
  final List<UserProfileModel> followersProfiles = [];

  // bool _isSearchBarVisible = false;
  final _searchController = TextEditingController();
  final List<MatchedUsersView> matchedViews = [];

  List<UserProfileModel> otherUserProf = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(scrollListener);
    final box = Hive.box(HiveConstants.hiveBox);
    final profileModel =
        UserProfileModel.fromJson(box.get(HiveConstants.currentUserProf));
    followers = profileModel.followers ?? [];
    following = profileModel.following ?? [];
    followbackList =
        following.where((element) => followers.contains(element)).toList();
  }

  FlutterSecureStorage storage = const FlutterSecureStorage();
  String? sharedSecret;
  String? privateKey;

  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);
  readLocal() async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await const e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(
                  widget.model.currentUser![Dbkeys.publicKey], true)))
          .toBase64();
      setState(() {});
    } catch (e) {
      sharedSecret = null;
      setState(() {});
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Lamat.toast(
        'waitingpeer'.tr(),
      );
      return false;
    }
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      setStateIfMounted(() {
        inviteContactsCount = inviteContactsCount + 250;
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableContacts = ref.watch(smartContactProvider);
    final otherUsers = ref.watch(otherUsersProvider(ref));
    final matchedUsersProvider = ref.watch(matchStreamProvider);

    final List<UserProfileModel> searchedUsers = matchedViews
            .where((element) {
              return element.user.fullName
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
            })
            .map((e) => e.user)
            .toList() +
        otherUserProf.where((element) {
          return element.fullName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
        }).toList() +
        followersProfiles.where((element) {
          return element.fullName
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
        }).toList();

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0,
                    titleSpacing: 5,
                    toolbarHeight: MediaQuery.of(context).padding.top + 120,
                    title: Text(
                      'selectsinglecontact'.tr(),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                      ),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 0, top: 40, bottom: 40),
                      child: CustomIconButton(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 1.8),
                          onPressed: () => Navigator.pop(context),
                          color: AppConstants.primaryColor,
                          icon: leftArrowSvg),
                    ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    centerTitle: false,
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.sync_rounded,
                          color: AppConstants.primaryColor,
                        ),
                        onPressed: () async {
                          if (widget.prefs.getBool('allowed-contacts') ==
                              true) {
                            Lamat.toast('loading'.tr());
                          }

                          await availableContacts.fetchContacts(
                            context,
                            widget.model,
                            widget.currentUserNo,
                            widget.prefs,
                            true,
                            isRequestAgain:
                                widget.prefs.getBool('allowed-contacts') == true
                                    ? false
                                    : true,
                          );
                        },
                      ),
                    ],
                  ),
                  body: RefreshIndicator(
                      onRefresh:
                          widget.prefs.getBool('allowed-contacts') == true
                              ? () async {
                                  return availableContacts.fetchContacts(
                                      context,
                                      model,
                                      widget.currentUserNo,
                                      widget.prefs,
                                      true);
                                }
                              : () async {},
                      child:
                          // availableContacts.contactsBookContactList!.isEmpty
                          //     ? ListView(children: [
                          //         Padding(
                          //             padding: EdgeInsets.only(
                          //                 top: MediaQuery.of(context).size.height /
                          //                     2.5),
                          //             child: Center(
                          //               child: Column(
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.center,
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.center,
                          //                 children: [
                          //                   Text('nocontacts'.tr(),
                          //                       textAlign: TextAlign.center,
                          //                       style: const TextStyle(
                          //                         fontSize: 18,
                          //                         color: AppConstants.lamatGrey,
                          //                       )),
                          //                   const SizedBox(
                          //                     height: 40,
                          //                   ),
                          //                   IconButton(
                          //                       onPressed: () async {
                          //                         availableContacts
                          //                             .setIsLoading(true);
                          //                         await availableContacts
                          //                             .fetchContacts(
                          //                           context,
                          //                           model,
                          //                           widget.currentUserNo,
                          //                           widget.prefs,
                          //                           true,
                          //                           isRequestAgain: true,
                          //                         )
                          //                             .then((d) {
                          //                           Future.delayed(
                          //                               const Duration(
                          //                                   milliseconds: 500), () {
                          //                             availableContacts
                          //                                 .setIsLoading(false);
                          //                           });
                          //                         });
                          //                         setState(() {});
                          //                       },
                          //                       icon: const Icon(
                          //                         Icons.refresh_rounded,
                          //                         size: 40,
                          //                         color: AppConstants.primaryColor,
                          //                       ))
                          //                 ],
                          //               ),
                          //             ))
                          //       ])
                          //     :
                          Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.only(bottom: 15, top: 0),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Container(
                              key: const Key('searchBar'),
                              padding: const EdgeInsets.all(
                                  AppConstants.defaultNumericValue / 3),
                              decoration: BoxDecoration(
                                color:
                                    AppConstants.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue,
                                ),
                              ),
                              child: TextField(
                                controller: _searchController,
                                autofocus: false,
                                onChanged: (_) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                  hintText: LocaleKeys.search.tr(),
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.search,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ListTile(
                              tileColor:
                                  AppConstants.primaryColor.withOpacity(.3),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              leading: const CircleAvatar(
                                  backgroundColor: AppConstants.secondaryColor,
                                  radius: 22.5,
                                  child: Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                  )),
                              title: Text(
                                'share'.tr(),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                  ),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 11.0),
                              onTap: () {
                                Lamat.invite(context, ref);
                              },
                            ),
                            ListTile(
                              tileColor:
                                  AppConstants.primaryColor.withOpacity(.3),
                              leading: const CircleAvatar(
                                  backgroundColor: AppConstants.secondaryColor,
                                  radius: 22.5,
                                  child: Icon(
                                    Icons.group,
                                    color: Colors.white,
                                  )),
                              title: Text(
                                'newgroup'.tr(),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                  ),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 11.0),
                              onTap: () {
                                widget.onTapCreateGroup();
                              },
                            ),
                            ListTile(
                              tileColor:
                                  AppConstants.primaryColor.withOpacity(.3),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              leading: const CircleAvatar(
                                  backgroundColor: AppConstants.secondaryColor,
                                  radius: 22.5,
                                  child: Icon(
                                    Icons.campaign,
                                    color: Colors.white,
                                  )),
                              title: Text(
                                'newbroadcast'.tr(),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor,
                                  ),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 22.0, vertical: 11.0),
                              onTap: () {
                                widget.onTapCreateBroadcast();
                              },
                            ),

                            if (searchedUsers.isNotEmpty)
                              const SizedBox(height: 10),

                            if (searchedUsers.isNotEmpty)
                              Expanded(
                                child: GridView(
                                  scrollDirection: Axis.vertical,
                                  padding: const EdgeInsets.only(
                                    left: AppConstants.defaultNumericValue,
                                    right: AppConstants.defaultNumericValue,
                                    bottom: AppConstants.defaultNumericValue,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing:
                                        AppConstants.defaultNumericValue,
                                    mainAxisSpacing:
                                        AppConstants.defaultNumericValue,
                                  ),
                                  children: searchedUsers.map((match) {
                                    final user = match;
                                    final phone = user.phoneNumber;
                                    return GestureDetector(
                                      onTap: () {
                                        hidekeyboard(context);
                                        dynamic wUser = model.userData[phone];
                                        if (wUser != null &&
                                            wUser[Dbkeys.chatStatus] != null) {
                                          if (model.currentUser![
                                                      Dbkeys.locked] !=
                                                  null &&
                                              model.currentUser![Dbkeys.locked]
                                                  .contains(phone)) {
                                            ChatController.authenticate(
                                                model, 'authneededchat'.tr(),
                                                prefs: widget.prefs,
                                                shouldPop: false,
                                                state: Navigator.of(context),
                                                type:
                                                    Lamat.getAuthenticationType(
                                                        widget.biometricEnabled,
                                                        model), onSuccess: () {
                                              !Responsive.isDesktop(context)
                                                  ? Navigator.pushAndRemoveUntil(
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
                                                                  unread: 0)),
                                                      (Route r) => r.isFirst)
                                                  : ref
                                                      .read(
                                                          arrangementProviderExtend
                                                              .notifier)
                                                      .setArrangement(ChatScreen(
                                                          isSharingIntentForwarded:
                                                              false,
                                                          prefs: widget.prefs,
                                                          model: model,
                                                          currentUserNo: widget
                                                              .currentUserNo,
                                                          peerNo: phone,
                                                          unread: 0));
                                            });
                                          } else {
                                            !Responsive.isDesktop(context)
                                                ? Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => ChatScreen(
                                                            isSharingIntentForwarded:
                                                                false,
                                                            prefs: widget.prefs,
                                                            model: model,
                                                            currentUserNo: widget
                                                                .currentUserNo,
                                                            peerNo: phone,
                                                            unread: 0)))
                                                : ref
                                                    .read(
                                                        arrangementProviderExtend
                                                            .notifier)
                                                    .setArrangement(ChatScreen(
                                                        isSharingIntentForwarded:
                                                            false,
                                                        prefs: widget.prefs,
                                                        model: model,
                                                        currentUserNo: widget
                                                            .currentUserNo,
                                                        peerNo: phone,
                                                        unread: 0));
                                          }
                                        } else {
                                          !Responsive.isDesktop(context)
                                              ? Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                  return PreChat(
                                                      prefs: widget.prefs,
                                                      model: widget.model,
                                                      name: user.nickname,
                                                      phone: phone,
                                                      currentUserNo:
                                                          widget.currentUserNo);
                                                }))
                                              : ref
                                                  .read(
                                                      arrangementProviderExtend
                                                          .notifier)
                                                  .setArrangement(PreChat(
                                                      prefs: widget.prefs,
                                                      model: widget.model,
                                                      name: user.nickname,
                                                      phone: phone,
                                                      currentUserNo: widget
                                                          .currentUserNo));
                                        }
                                      },
                                      child: GridTile(
                                        footer: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: AppConstants
                                                    .defaultNumericValue /
                                                2,
                                            horizontal: AppConstants
                                                .defaultNumericValue,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                        .defaultNumericValue /
                                                    2),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 10.0, sigmaY: 10.0),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                    AppConstants
                                                            .defaultNumericValue /
                                                        2),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue /
                                                          2),
                                                  color: Colors.black38,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${user.fullName.split(" ").first} ${DateTime.now().difference(user.birthDay).inDays ~/ 365}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        header: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                  CupertinoIcons.heart_solid,
                                                  color: CupertinoColors
                                                      .destructiveRed,
                                                  size: AppConstants
                                                          .defaultNumericValue *
                                                      1.5),
                                              const Spacer(),
                                              if (user.isVerified)
                                                GestureDetector(
                                                  onTap: () {
                                                    EasyLoading.showToast(
                                                        LocaleKeys.verifiedUser
                                                            .tr());
                                                  },
                                                  child: const Padding(
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: AppConstants
                                                              .defaultNumericValue),
                                                      child: Image(
                                                        image: AssetImage(
                                                            verifiedIcon),
                                                        height: 22,
                                                        width: 22,
                                                      )),
                                                ),
                                              if (user.isOnline)
                                                const SizedBox(width: 4),
                                              if (user.isOnline)
                                                const OnlineStatus(),
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                    .defaultNumericValue),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                    .defaultNumericValue),
                                            child: (user.mediaFiles.isEmpty &&
                                                    user.profilePicture == null)
                                                ? const Center(
                                                    child: Icon(
                                                        CupertinoIcons.photo),
                                                  )
                                                : (user.profilePicture != null)
                                                    ? CachedNetworkImage(
                                                        imageUrl: user
                                                            .profilePicture!,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            const Center(
                                                                child: CircularProgressIndicator
                                                                    .adaptive()),
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return const Center(
                                                              child: Icon(
                                                                  CupertinoIcons
                                                                      .photo));
                                                        },
                                                      )
                                                    : user.mediaFiles.isEmpty
                                                        ? const Center(
                                                            child: Icon(
                                                                CupertinoIcons
                                                                    .photo),
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl: user
                                                                    .mediaFiles
                                                                    .isNotEmpty
                                                                ? user
                                                                    .mediaFiles
                                                                    .first
                                                                : '',
                                                            fit: BoxFit.cover,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const Center(
                                                                    child: CircularProgressIndicator
                                                                        .adaptive()),
                                                            errorWidget:
                                                                (context, url,
                                                                    error) {
                                                              return const Center(
                                                                  child: Icon(
                                                                      CupertinoIcons
                                                                          .photo));
                                                            },
                                                          ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            //  if (matchedViews.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              child: Text(
                                LocaleKeys.matches.tr(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            otherUsers.when(
                              data: (data) {
                                if (data.isEmpty) {
                                  return const Center(
                                    child: SizedBox(),
                                  );
                                } else {
                                  otherUserProf = data;
                                  return matchedUsersProvider.when(
                                    data: (matches) {
                                      matches.removeWhere((element) =>
                                          element.isMatched == false);

                                      for (final user in data) {
                                        if (matches.any((element) => element
                                            .userIds
                                            .contains(user.phoneNumber))) {
                                          matchedViews.add(MatchedUsersView(
                                              user: user,
                                              matchId: matches
                                                  .firstWhere((element) =>
                                                      element.userIds.contains(
                                                          user.phoneNumber))
                                                  .id));
                                        }
                                      }

                                      return GridView(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.only(
                                          left:
                                              AppConstants.defaultNumericValue,
                                          right:
                                              AppConstants.defaultNumericValue,
                                          bottom:
                                              AppConstants.defaultNumericValue,
                                        ),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing:
                                              AppConstants.defaultNumericValue,
                                          mainAxisSpacing:
                                              AppConstants.defaultNumericValue,
                                        ),
                                        children: matchedViews.map((match) {
                                          final user = match.user;
                                          final phone = user.phoneNumber;
                                          return GestureDetector(
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
                                                    !Responsive.isDesktop(context)
                                                        ? Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ChatScreen(
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
                                                                    unread: 0)),
                                                            (Route r) =>
                                                                r.isFirst)
                                                        : ref
                                                            .read(
                                                                arrangementProviderExtend
                                                                    .notifier)
                                                            .setArrangement(ChatScreen(
                                                                isSharingIntentForwarded:
                                                                    false,
                                                                prefs: widget
                                                                    .prefs,
                                                                model: model,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo,
                                                                peerNo: phone,
                                                                unread: 0));
                                                  });
                                                } else {
                                                  !Responsive.isDesktop(context)
                                                      ? Navigator.push(
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
                                                                  unread: 0)))
                                                      : ref
                                                          .read(
                                                              arrangementProviderExtend
                                                                  .notifier)
                                                          .setArrangement(ChatScreen(
                                                              isSharingIntentForwarded:
                                                                  false,
                                                              prefs:
                                                                  widget.prefs,
                                                              model: model,
                                                              currentUserNo: widget
                                                                  .currentUserNo,
                                                              peerNo: phone,
                                                              unread: 0));
                                                }
                                              } else {
                                                !Responsive.isDesktop(context)
                                                    ? Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                        return PreChat(
                                                            prefs: widget.prefs,
                                                            model: widget.model,
                                                            name: user.nickname,
                                                            phone: phone,
                                                            currentUserNo: widget
                                                                .currentUserNo);
                                                      }))
                                                    : ref
                                                        .read(
                                                            arrangementProviderExtend
                                                                .notifier)
                                                        .setArrangement(PreChat(
                                                            prefs: widget.prefs,
                                                            model: widget.model,
                                                            name: user.nickname,
                                                            phone: phone,
                                                            currentUserNo: widget
                                                                .currentUserNo));
                                              }
                                            },
                                            child: GridTile(
                                              footer: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: AppConstants
                                                          .defaultNumericValue /
                                                      2,
                                                  horizontal: AppConstants
                                                      .defaultNumericValue,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                              .defaultNumericValue /
                                                          2),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 10.0,
                                                        sigmaY: 10.0),
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets
                                                          .all(AppConstants
                                                                  .defaultNumericValue /
                                                              2),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(AppConstants
                                                                    .defaultNumericValue /
                                                                2),
                                                        color: Colors.black38,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '${match.user.fullName.split(" ").first} ${DateTime.now().difference(match.user.birthDay).inDays ~/ 365}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              header: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        CupertinoIcons
                                                            .heart_solid,
                                                        color: CupertinoColors
                                                            .destructiveRed,
                                                        size: AppConstants
                                                                .defaultNumericValue *
                                                            1.5),
                                                    const Spacer(),
                                                    if (match.user.isVerified)
                                                      GestureDetector(
                                                        onTap: () {
                                                          EasyLoading.showToast(
                                                              LocaleKeys
                                                                  .verifiedUser
                                                                  .tr());
                                                        },
                                                        child: const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        AppConstants
                                                                            .defaultNumericValue),
                                                            child: Image(
                                                              image: AssetImage(
                                                                  verifiedIcon),
                                                              height: 22,
                                                              width: 22,
                                                            )),
                                                      ),
                                                    if (match.user.isOnline)
                                                      const SizedBox(width: 4),
                                                    if (match.user.isOnline)
                                                      const OnlineStatus(),
                                                  ],
                                                ),
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                          .defaultNumericValue),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .circular(AppConstants
                                                          .defaultNumericValue),
                                                  child: (match.user.mediaFiles
                                                              .isEmpty &&
                                                          match.user
                                                                  .profilePicture ==
                                                              null)
                                                      ? const Center(
                                                          child: Icon(
                                                              CupertinoIcons
                                                                  .photo),
                                                        )
                                                      : (match.user
                                                                  .profilePicture !=
                                                              null)
                                                          ? CachedNetworkImage(
                                                              imageUrl: match
                                                                  .user
                                                                  .profilePicture!,
                                                              fit: BoxFit.cover,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child: CircularProgressIndicator
                                                                          .adaptive()),
                                                              errorWidget:
                                                                  (context, url,
                                                                      error) {
                                                                return const Center(
                                                                    child: Icon(
                                                                        CupertinoIcons
                                                                            .photo));
                                                              },
                                                            )
                                                          : match
                                                                  .user
                                                                  .mediaFiles
                                                                  .isEmpty
                                                              ? const Center(
                                                                  child: Icon(
                                                                      CupertinoIcons
                                                                          .photo),
                                                                )
                                                              : CachedNetworkImage(
                                                                  imageUrl: match
                                                                          .user
                                                                          .mediaFiles
                                                                          .isNotEmpty
                                                                      ? match
                                                                          .user
                                                                          .mediaFiles
                                                                          .first
                                                                      : '',
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Center(
                                                                          child:
                                                                              CircularProgressIndicator.adaptive()),
                                                                  errorWidget:
                                                                      (context,
                                                                          url,
                                                                          error) {
                                                                    return const Center(
                                                                        child: Icon(
                                                                            CupertinoIcons.photo));
                                                                  },
                                                                ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                    error: (_, __) {
                                      return const SizedBox();
                                    },
                                    loading: () => const SizedBox(),
                                  );
                                }
                              },
                              error: (_, __) => const SizedBox(),
                              loading: () => const SizedBox(),
                            ),

                            if (followbackList.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
                                child: Text(
                                  "Friends",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            if (followbackList.isNotEmpty)
                              otherUsers.when(
                                data: (data) {
                                  if (data.isEmpty) {
                                    return const Center(
                                      child: SizedBox(),
                                    );
                                  } else {
                                    final List<UserProfileModel> users = data;
                                    otherUserProf = data;
                                    final List<String> followersNumbers =
                                        followbackList;

                                    for (var user in users) {
                                      if (followersNumbers
                                          .contains(user.phoneNumber)) {
                                        followersProfiles.add(user);
                                      }
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(0),
                                      itemCount: followersProfiles.length,
                                      itemBuilder: (context, idx) {
                                        UserProfileModel user =
                                            followersProfiles.elementAt(idx);
                                        String phone = user.phoneNumber;
                                        return ListTile(
                                          tileColor: AppConstants.primaryColor
                                              .withOpacity(.3),
                                          leading: customCircleAvatar(
                                              url: user.profilePicture,
                                              radius: 22),
                                          title: Text(user.nickname,
                                              style: TextStyle(
                                                color:
                                                    pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                                ),
                                              )),
                                          subtitle: Text("@${user.userName}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      AppConstants.lamatGrey)),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 22.0,
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
                                                    state:
                                                        Navigator.of(context),
                                                    type: Lamat
                                                        .getAuthenticationType(
                                                            widget
                                                                .biometricEnabled,
                                                            model),
                                                    onSuccess: () {
                                                  !Responsive.isDesktop(context)
                                                      ? Navigator.pushAndRemoveUntil(
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
                                                              r.isFirst)
                                                      : ref
                                                          .read(
                                                              arrangementProviderExtend
                                                                  .notifier)
                                                          .setArrangement(ChatScreen(
                                                              isSharingIntentForwarded:
                                                                  false,
                                                              prefs:
                                                                  widget.prefs,
                                                              model: model,
                                                              currentUserNo: widget
                                                                  .currentUserNo,
                                                              peerNo: phone,
                                                              unread: 0));
                                                });
                                              } else {
                                                !Responsive.isDesktop(context)
                                                    ? Navigator.push(
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
                                                                unread: 0)))
                                                    : ref
                                                        .read(
                                                            arrangementProviderExtend
                                                                .notifier)
                                                        .setArrangement(ChatScreen(
                                                            isSharingIntentForwarded:
                                                                false,
                                                            prefs: widget.prefs,
                                                            model: model,
                                                            currentUserNo: widget
                                                                .currentUserNo,
                                                            peerNo: phone,
                                                            unread: 0));
                                              }
                                            } else {
                                              !Responsive.isDesktop(context)
                                                  ? Navigator.push(context,
                                                      MaterialPageRoute(
                                                          builder: (context) {
                                                      return PreChat(
                                                          prefs: widget.prefs,
                                                          model: widget.model,
                                                          name: user.nickname,
                                                          phone: phone,
                                                          currentUserNo: widget
                                                              .currentUserNo);
                                                    }))
                                                  : ref
                                                      .read(
                                                          arrangementProviderExtend
                                                              .notifier)
                                                      .setArrangement(PreChat(
                                                          prefs: widget.prefs,
                                                          model: widget.model,
                                                          name: user.nickname,
                                                          phone: phone,
                                                          currentUserNo: widget
                                                              .currentUserNo));
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                error: (_, __) => const SizedBox(),
                                loading: () => const SizedBox(),
                              ),

                            availableContacts
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        18, 18, 18, 18),
                                    child: Text(
                                      (LocaleKeys.saved).tr(),
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                            availableContacts
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .isEmpty
                                ? const SizedBox(
                                    height: 0,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(00),
                                      itemCount: availableContacts
                                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                                          .length,
                                      itemBuilder: (context, idx) {
                                        DeviceContactIdAndName user =
                                            availableContacts
                                                .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                .elementAt(idx);
                                        String phone = user.phone;
                                        String name = user.name ?? user.phone;
                                        return FutureBuilder<LocalUserData?>(
                                          future: availableContacts
                                              .fetchUserDataFromnLocalOrServer(
                                                  widget.prefs, phone),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<LocalUserData?>
                                                  snapshot) {
                                            if (snapshot.hasData &&
                                                snapshot.data != null) {
                                              return ListTile(
                                                tileColor: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                leading: customCircleAvatar(
                                                    url:
                                                        snapshot.data!.photoURL,
                                                    radius: 22),
                                                title: Text(snapshot.data!.name,
                                                    style: TextStyle(
                                                      color:
                                                          pickTextColorBasedOnBgColorAdvanced(
                                                        Teme.isDarktheme(
                                                                widget.prefs)
                                                            ? AppConstants
                                                                .backgroundColorDark
                                                            : AppConstants
                                                                .backgroundColor,
                                                      ),
                                                    )),
                                                subtitle: Text(phone,
                                                    style: const TextStyle(
                                                        color: AppConstants
                                                            .lamatGrey)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 22.0,
                                                        vertical: 0.0),
                                                onTap: () {
                                                  hidekeyboard(context);
                                                  dynamic wUser =
                                                      model.userData[phone];
                                                  if (wUser != null &&
                                                      wUser[Dbkeys
                                                              .chatStatus] !=
                                                          null) {
                                                    if (model.currentUser![
                                                                Dbkeys
                                                                    .locked] !=
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
                                                        !Responsive.isDesktop(
                                                                context)
                                                            ? Navigator.pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => ChatScreen(
                                                                        isSharingIntentForwarded:
                                                                            false,
                                                                        prefs: widget
                                                                            .prefs,
                                                                        model:
                                                                            model,
                                                                        currentUserNo: widget
                                                                            .currentUserNo,
                                                                        peerNo:
                                                                            phone,
                                                                        unread:
                                                                            0)),
                                                                (Route r) =>
                                                                    r.isFirst)
                                                            : ref
                                                                .read(arrangementProviderExtend
                                                                    .notifier)
                                                                .setArrangement(ChatScreen(
                                                                    isSharingIntentForwarded:
                                                                        false,
                                                                    prefs:
                                                                        widget
                                                                            .prefs,
                                                                    model:
                                                                        model,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo,
                                                                    peerNo: phone,
                                                                    unread: 0));
                                                      });
                                                    } else {
                                                      !Responsive.isDesktop(
                                                              context)
                                                          ? Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatScreen(
                                                                      isSharingIntentForwarded:
                                                                          false,
                                                                      prefs:
                                                                          widget
                                                                              .prefs,
                                                                      model:
                                                                          model,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo,
                                                                      peerNo:
                                                                          phone,
                                                                      unread:
                                                                          0)))
                                                          : ref
                                                              .read(
                                                                  arrangementProviderExtend
                                                                      .notifier)
                                                              .setArrangement(ChatScreen(
                                                                  isSharingIntentForwarded:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  model: model,
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  peerNo: phone,
                                                                  unread: 0));
                                                    }
                                                  } else {
                                                    !Responsive.isDesktop(
                                                            context)
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                            return PreChat(
                                                                prefs: widget
                                                                    .prefs,
                                                                model: widget
                                                                    .model,
                                                                name: name,
                                                                phone: phone,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo);
                                                          }))
                                                        : ref
                                                            .read(
                                                                arrangementProviderExtend
                                                                    .notifier)
                                                            .setArrangement(PreChat(
                                                                prefs: widget
                                                                    .prefs,
                                                                model: widget
                                                                    .model,
                                                                name: name,
                                                                phone: phone,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo));
                                                  }
                                                },
                                              );
                                            }
                                            return ListTile(
                                              tileColor:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                              leading: customCircleAvatar(
                                                  radius: 22),
                                              title: Text(name,
                                                  style: TextStyle(
                                                    color:
                                                        pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                    ),
                                                  )),
                                              subtitle: Text(phone,
                                                  style: const TextStyle(
                                                      color: AppConstants
                                                          .lamatGrey)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 22.0,
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
                                                      !Responsive.isDesktop(
                                                              context)
                                                          ? Navigator.pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) => ChatScreen(
                                                                      isSharingIntentForwarded:
                                                                          false,
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model:
                                                                          model,
                                                                      currentUserNo: widget
                                                                          .currentUserNo,
                                                                      peerNo:
                                                                          phone,
                                                                      unread:
                                                                          0)),
                                                              (Route r) => r
                                                                  .isFirst)
                                                          : ref
                                                              .read(arrangementProviderExtend
                                                                  .notifier)
                                                              .setArrangement(ChatScreen(
                                                                  isSharingIntentForwarded:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  model: model,
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  peerNo: phone,
                                                                  unread: 0));
                                                    });
                                                  } else {
                                                    !Responsive.isDesktop(
                                                            context)
                                                        ? Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ChatScreen(
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
                                                                    unread: 0)))
                                                        : ref
                                                            .read(
                                                                arrangementProviderExtend
                                                                    .notifier)
                                                            .setArrangement(ChatScreen(
                                                                isSharingIntentForwarded:
                                                                    false,
                                                                prefs: widget
                                                                    .prefs,
                                                                model: model,
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo,
                                                                peerNo: phone,
                                                                unread: 0));
                                                  }
                                                } else {
                                                  !Responsive.isDesktop(context)
                                                      ? Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                          return PreChat(
                                                              prefs:
                                                                  widget.prefs,
                                                              model:
                                                                  widget.model,
                                                              name: name,
                                                              phone: phone,
                                                              currentUserNo: widget
                                                                  .currentUserNo);
                                                        }))
                                                      : ref
                                                          .read(
                                                              arrangementProviderExtend
                                                                  .notifier)
                                                          .setArrangement(PreChat(
                                                              prefs:
                                                                  widget.prefs,
                                                              model:
                                                                  widget.model,
                                                              name: name,
                                                              phone: phone,
                                                              currentUserNo: widget
                                                                  .currentUserNo));
                                                }
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              child: Text(
                                "${(LocaleKeys.inviteTo).tr()} $Appname",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(0),
                                itemCount: inviteContactsCount >=
                                        availableContacts
                                            .contactsBookContactList!.length
                                    ? availableContacts
                                        .contactsBookContactList!.length
                                    : inviteContactsCount,
                                itemBuilder: (context, idx) {
                                  MapEntry user = availableContacts
                                      .contactsBookContactList!.entries
                                      .elementAt(idx);
                                  String phone = user.key;
                                  return availableContacts
                                              .previouslyFetchedKEYPhoneInSharedPrefs
                                              .indexWhere((element) =>
                                                  element.phone == phone) >=
                                          0
                                      ? Container(
                                          width: 0,
                                        )
                                      : Stack(
                                          children: [
                                            ListTile(
                                              tileColor:
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor,
                                              leading: CircleAvatar(
                                                  backgroundColor:
                                                      AppConstants.primaryColor,
                                                  radius: 22.5,
                                                  child: Text(
                                                    Lamat.getInitials(
                                                        user.value),
                                                    style: const TextStyle(
                                                        color: AppConstants
                                                            .lamatWhite),
                                                  )),
                                              title: Text(user.value,
                                                  style: TextStyle(
                                                    color:
                                                        pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                    ),
                                                  )),
                                              subtitle: Text(phone,
                                                  style: const TextStyle(
                                                      color: AppConstants
                                                          .lamatGrey)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 22.0,
                                                      vertical: 0.0),
                                              onTap: () {
                                                hidekeyboard(context);
                                                Lamat.invite(context, ref);
                                              },
                                            ),
                                            Positioned(
                                              right: 19,
                                              bottom: 19,
                                              child: InkWell(
                                                  onTap: () {
                                                    hidekeyboard(context);
                                                    Lamat.invite(context, ref);
                                                  },
                                                  child: const Icon(
                                                    Icons.person_add_alt,
                                                    color: AppConstants
                                                        .primaryColor,
                                                  )),
                                            )
                                          ],
                                        );
                                },
                              ),
                            ),
                          ],
                        ),
                      )));
            }))));
  }

  loading() {
    return const Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
      ))
    ]);
  }
}
