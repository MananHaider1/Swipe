import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/Groups/group_chat_page.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';

class SelectContactToShare extends ConsumerStatefulWidget {
  const SelectContactToShare({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.prefs,
    required this.sharedFiles,
    this.sharedText,
  });
  final String? currentUserNo;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile> sharedFiles;
  final String? sharedText;

  @override
  SelectContactToShareState createState() => SelectContactToShareState();
}

class SelectContactToShareState extends ConsumerState<SelectContactToShare>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  var joinedGroupsList = [];
  @override
  bool get wantKeepAlive => true;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedGroups();
  }

  fetchJoinedGroups() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: widget.currentUserNo)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .get()
        .then((groupsList) {
      if (groupsList.docs.isNotEmpty) {
        for (var group in groupsList.docs) {
          joinedGroupsList.add(group);
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
          }
          setState(() {});
        }
      } else {
        isGroupsloading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  loading() {
    return const Stack(children: [
      Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
      ))
    ]);
  }

  int currentUploadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final contactsProvider = ref.watch(smartContactProvider);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  key: _scaffold,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0.4,
                    titleSpacing: -5,
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
                    // leadingWidth: 40,
                    title: Text(
                      LocaleKeys.selectcontacttoshare.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor),
                      ),
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: () {
                      return contactsProvider.fetchContacts(context, model,
                          widget.currentUserNo!, widget.prefs, false);
                    },
                    child: contactsProvider.searchingcontactsindatabase ==
                                true ||
                            isGroupsloading == true
                        ? loading()
                        : contactsProvider
                                .alreadyJoinedSavedUsersPhoneNameAsInServer
                                .isEmpty
                            ? ListView(shrinkWrap: true, children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height /
                                                2.5),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(LocaleKeys.nocontacts.tr(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: AppConstants.lamatGrey,
                                              )),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                contactsProvider
                                                    .setIsLoading(true);
                                                await contactsProvider
                                                    .fetchContacts(
                                                  context,
                                                  model,
                                                  widget.currentUserNo!,
                                                  widget.prefs,
                                                  true,
                                                  isRequestAgain: true,
                                                )
                                                    .then((d) {
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                    contactsProvider
                                                        .setIsLoading(false);
                                                  });
                                                });
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.refresh_rounded,
                                                size: 40,
                                                color:
                                                    AppConstants.primaryColor,
                                              ))
                                        ],
                                      ),
                                    ))
                              ])
                            : ListView(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                  ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: joinedGroupsList.length,
                                    itemBuilder: (context, i) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            leading: customCircleAvatarGroup(
                                                url: joinedGroupsList.contains(
                                                        Dbkeys.groupPHOTOURL)
                                                    ? joinedGroupsList[i]
                                                        [Dbkeys.groupPHOTOURL]
                                                    : '',
                                                radius: 22),
                                            title: Text(
                                              joinedGroupsList[i]
                                                  [Dbkeys.groupNAME],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: pickTextColorBasedOnBgColorAdvanced(
                                                    Teme.isDarktheme(
                                                            widget.prefs)
                                                        ? AppConstants
                                                            .backgroundColorDark
                                                        : AppConstants
                                                            .backgroundColor),
                                                fontSize: 16,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} ${LocaleKeys.participants.tr()}',
                                              style: const TextStyle(
                                                color: AppConstants.lamatGrey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onTap: () {
                                              // for group
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => GroupChatPage(
                                                          isCurrentUserMuted:
                                                              joinedGroupsList[i].containsKey(Dbkeys.groupMUTEDMEMBERS)
                                                                  ? joinedGroupsList[i][Dbkeys.groupMUTEDMEMBERS]
                                                                      .contains(widget
                                                                          .currentUserNo)
                                                                  : false,
                                                          sharedText:
                                                              widget.sharedText,
                                                          sharedFiles: widget
                                                              .sharedFiles,
                                                          isSharingIntentForwarded:
                                                              true,
                                                          model: widget.model,
                                                          prefs: widget.prefs,
                                                          joinedTime:
                                                              joinedGroupsList[i][
                                                                  '${widget.currentUserNo}-joinedOn'],
                                                          currentUserno: widget
                                                              .currentUserNo!,
                                                          groupID:
                                                              joinedGroupsList[i]
                                                                  [Dbkeys.groupID])));
                                            },
                                          ),
                                          const Divider(
                                            height: 2,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  ListView.builder(
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: contactsProvider
                                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                                        .length,
                                    itemBuilder: (context, idx) {
                                      String phone = contactsProvider
                                          .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                              idx]
                                          .phone;
                                      Widget? alreadyAddedUser;

                                      return alreadyAddedUser ??
                                          FutureBuilder<LocalUserData?>(
                                              future: contactsProvider
                                                  .fetchUserDataFromnLocalOrServer(
                                                      widget.prefs, phone),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<LocalUserData?>
                                                      snapshot) {
                                                if (snapshot.hasData) {
                                                  LocalUserData user =
                                                      snapshot.data!;
                                                  return Column(
                                                    children: [
                                                      ListTile(
                                                        leading:
                                                            customCircleAvatar(
                                                          url: user.photoURL,
                                                          radius: 22.5,
                                                        ),
                                                        title: Text(user.name,
                                                            style: TextStyle(
                                                                color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                        .isDarktheme(widget
                                                                            .prefs)
                                                                    ? AppConstants
                                                                        .backgroundColorDark
                                                                    : AppConstants
                                                                        .backgroundColor))),
                                                        subtitle: Text(phone,
                                                            style: const TextStyle(
                                                                color: AppConstants
                                                                    .lamatGrey)),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                                vertical: 0.0),
                                                        onTap: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionusers)
                                                              .doc(user.id)
                                                              .get()
                                                              .then((usr) {
                                                            if (usr.exists) {
                                                              if (usr.data()![Dbkeys
                                                                      .accountstatus] ==
                                                                  Dbkeys
                                                                      .sTATUSdeleted) {
                                                                Lamat.toast(
                                                                  LocaleKeys
                                                                      .usernotavail
                                                                      .tr(),
                                                                );
                                                              } else {
                                                                widget.model
                                                                    .addUser(
                                                                        usr);
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => ChatScreen(
                                                                            sharedText: widget
                                                                                .sharedText,
                                                                            sharedFiles: widget
                                                                                .sharedFiles,
                                                                            isSharingIntentForwarded:
                                                                                true,
                                                                            prefs: widget
                                                                                .prefs,
                                                                            unread:
                                                                                0,
                                                                            model:
                                                                                widget.model,
                                                                            currentUserNo: widget.currentUserNo,
                                                                            peerNo: user.id)));
                                                              }
                                                            } else {
                                                              Lamat.toast(
                                                                LocaleKeys
                                                                    .usernotavail
                                                                    .tr(),
                                                              );
                                                            }
                                                          });
                                                        },
                                                      ),
                                                      const Divider(
                                                        height: 2,
                                                      )
                                                    ],
                                                  );
                                                }
                                                return const SizedBox();
                                              });
                                    },
                                  ),
                                ],
                              ),
                  ));
            }))));
  }
}
