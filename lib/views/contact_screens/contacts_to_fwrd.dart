// ignore_for_file: avoid_function_literals_in_foreach_calls, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';

class SelectContactsToForward extends ConsumerStatefulWidget {
  const SelectContactsToForward({
    super.key,
    required this.currentUserNo,
    required this.contentPeerNo,
    required this.model,
    required this.prefs,
    required this.onSelect,
    required this.messageOwnerPhone,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserNo;
  final String? contentPeerNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final String messageOwnerPhone;
  final Function(List<dynamic> selectedList) onSelect;

  @override
  SelectContactsToForwardState createState() => SelectContactsToForwardState();
}

class SelectContactsToForwardState
    extends ConsumerState<SelectContactsToForward>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  List<Map<String, dynamic>> joinedGroupsList = [];
  List<LocalUserData> selectedDynamicListFORUSERS = [];
  List<Map<String, dynamic>> selectedDynamicListFORGROUPS = [];
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
          joinedGroupsList.add(group.data());
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
            debugPrint('isGroupsloading $isGroupsloading');
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
    // final groupList = ref.watch(groupsListProvider);
    final observer = ref.watch(observerProvider);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  bottomSheet: selectedDynamicListFORUSERS.isNotEmpty ||
                          selectedDynamicListFORGROUPS.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.only(top: 6),
                          width: MediaQuery.of(context).size.width,
                          height: 97,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedDynamicListFORGROUPS
                                      .reversed
                                      .toList()
                                      .length,
                                  itemBuilder: (context, int i) {
                                    var m = selectedDynamicListFORGROUPS
                                        .reversed
                                        .toList()[i];
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 80,
                                          padding: const EdgeInsets.fromLTRB(
                                              11, 10, 12, 10),
                                          child: Column(
                                            children: [
                                              customCircleAvatarGroup(
                                                  url: m.containsKey(
                                                          Dbkeys.groupPHOTOURL)
                                                      ? m[Dbkeys.groupPHOTOURL]
                                                      : '',
                                                  radius: 20),
                                              const SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                selectedDynamicListFORGROUPS
                                                            .reversed
                                                            .toList()[i]
                                                        [Dbkeys.groupNAME] ??
                                                    '',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          right: 17,
                                          top: 5,
                                          child: InkWell(
                                            onTap: () {
                                              setStateIfMounted(() {
                                                selectedDynamicListFORGROUPS.remove(
                                                    selectedDynamicListFORGROUPS
                                                        .reversed
                                                        .toList()[i]);
                                              });
                                            },
                                            child: Container(
                                              width: 20.0,
                                              height: 20.0,
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ), //............
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: selectedDynamicListFORUSERS
                                      .reversed
                                      .toList()
                                      .length,
                                  itemBuilder: (context, int i) {
                                    return widget.contentPeerNo ==
                                                selectedDynamicListFORUSERS
                                                    .reversed
                                                    .toList()[i]
                                                    .id ||
                                            widget.currentUserNo ==
                                                selectedDynamicListFORUSERS
                                                    .reversed
                                                    .toList()[i]
                                                    .id
                                        ? const SizedBox(
                                            height: 0,
                                            width: 0,
                                          )
                                        : Stack(
                                            children: [
                                              Container(
                                                width: 80,
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        11, 10, 12, 10),
                                                child: Column(
                                                  children: [
                                                    customCircleAvatar(
                                                        url:
                                                            selectedDynamicListFORUSERS
                                                                .reversed
                                                                .toList()[i]
                                                                .photoURL,
                                                        radius: 20),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      selectedDynamicListFORUSERS
                                                          .reversed
                                                          .toList()[i]
                                                          .name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                right: 17,
                                                top: 5,
                                                child: InkWell(
                                                  onTap: () {
                                                    setStateIfMounted(() {
                                                      selectedDynamicListFORUSERS
                                                          .remove(
                                                              selectedDynamicListFORUSERS
                                                                  .reversed
                                                                  .toList()[i]);
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.black,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ), //............
                                                ),
                                              )
                                            ],
                                          );
                                  }),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  key: _scaffold,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0.4,
                    actions: <Widget>[
                      selectedDynamicListFORUSERS.isNotEmpty ||
                              selectedDynamicListFORGROUPS.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.check,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                              ),
                              onPressed: () async {
                                List<dynamic> finalList = [];
                                selectedDynamicListFORGROUPS
                                    .forEach((element) async {
                                  finalList.add(element);
                                  setStateIfMounted(() {});
                                });

                                for (var element
                                    in selectedDynamicListFORUSERS) {
                                  await contactsProvider
                                      .fetchFromFiretsoreAndReturnData(
                                          widget.prefs, element.id,
                                          (peerDoc) async {
                                    finalList.add(peerDoc.data());
                                    setStateIfMounted(() {});
                                  });
                                }
                                widget.onSelect(finalList);
                                Navigator.of(context).pop();
                              })
                          : const SizedBox()
                    ],
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
                      'selectcontactstoforward'.tr(),
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
                                          Text('nocontacts'.tr(),
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
                                            trailing: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        AppConstants.lamatGrey,
                                                    width: 1),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: selectedDynamicListFORGROUPS
                                                          .lastIndexWhere((element) =>
                                                              element[Dbkeys
                                                                  .groupID] ==
                                                              joinedGroupsList[
                                                                      i][
                                                                  Dbkeys
                                                                      .groupID]) >=
                                                      0
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 19.0,
                                                      color: AppConstants
                                                          .primaryColor,
                                                    )
                                                  : const Icon(
                                                      null,
                                                      size: 19.0,
                                                    ),
                                            ),
                                            leading: customCircleAvatarGroup(
                                                url: joinedGroupsList[i]
                                                        .containsKey(Dbkeys
                                                            .groupPHOTOURL)
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
                                              '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} Participants',
                                              style: const TextStyle(
                                                color: AppConstants.lamatGrey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            onTap: () {
                                              setStateIfMounted(() {
                                                if (selectedDynamicListFORGROUPS
                                                        .lastIndexWhere((element) =>
                                                            element[Dbkeys
                                                                .groupID] ==
                                                            joinedGroupsList[i][
                                                                Dbkeys
                                                                    .groupID]) >=
                                                    0) {
                                                  selectedDynamicListFORGROUPS
                                                      .remove(
                                                          joinedGroupsList[i]);
                                                  setStateIfMounted(() {});
                                                } else {
                                                  if (selectedDynamicListFORUSERS
                                                              .length +
                                                          selectedDynamicListFORGROUPS
                                                              .length >
                                                      observer.maxNoOfContactsSelectForForward -
                                                          1) {
                                                    Lamat.toast(
                                                        '${'maxallowed'.tr()} ${observer.maxNoOfContactsSelectForForward}');
                                                  } else {
                                                    selectedDynamicListFORGROUPS
                                                        .add(joinedGroupsList[
                                                            i]);
                                                    setStateIfMounted(() {});
                                                  }
                                                }
                                              });
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

                                      return widget.contentPeerNo ==
                                                  contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                          idx]
                                                      .phone ||
                                              widget.currentUserNo ==
                                                  contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                          idx]
                                                      .phone
                                          ? const SizedBox(
                                              height: 0,
                                              width: 0,
                                            )
                                          : alreadyAddedUser ??
                                              FutureBuilder<LocalUserData?>(
                                                  future: contactsProvider
                                                      .fetchUserDataFromnLocalOrServer(
                                                          widget.prefs, phone),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              LocalUserData?>
                                                          snapshot) {
                                                    if (snapshot.hasData) {
                                                      LocalUserData user =
                                                          snapshot.data!;
                                                      return Column(
                                                        children: [
                                                          ListTile(
                                                            trailing: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color: AppConstants
                                                                        .lamatGrey,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              child: selectedDynamicListFORUSERS.lastIndexWhere((element) =>
                                                                          element
                                                                              .id ==
                                                                          user.id) >=
                                                                      0
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check,
                                                                      size:
                                                                          19.0,
                                                                      color: AppConstants
                                                                          .primaryColor,
                                                                    )
                                                                  : const Icon(
                                                                      null,
                                                                      size:
                                                                          19.0,
                                                                    ),
                                                            ),
                                                            leading:
                                                                customCircleAvatar(
                                                              url:
                                                                  user.photoURL,
                                                              radius: 22,
                                                            ),
                                                            title: Text(
                                                                user.name,
                                                                style: TextStyle(
                                                                    color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget
                                                                            .prefs)
                                                                        ? AppConstants
                                                                            .backgroundColorDark
                                                                        : AppConstants
                                                                            .backgroundColor))),
                                                            subtitle: Text(
                                                                phone,
                                                                style: const TextStyle(
                                                                    color: AppConstants
                                                                        .lamatGrey)),
                                                            // contentPadding: EdgeInsets.symmetric(
                                                            //     horizontal:
                                                            //         10.0,
                                                            //     vertical:
                                                            // 0.0),
                                                            onTap: () {
                                                              setStateIfMounted(
                                                                  () {
                                                                if (selectedDynamicListFORUSERS.lastIndexWhere((element) =>
                                                                        element
                                                                            .id ==
                                                                        user.id) >=
                                                                    0) {
                                                                  selectedDynamicListFORUSERS
                                                                      .remove(snapshot
                                                                          .data!);
                                                                  setStateIfMounted(
                                                                      () {});
                                                                } else {
                                                                  if (snapshot
                                                                          .data!
                                                                          .id ==
                                                                      widget
                                                                          .messageOwnerPhone) {
                                                                  } else {
                                                                    if (selectedDynamicListFORUSERS.length +
                                                                            selectedDynamicListFORGROUPS
                                                                                .length >
                                                                        observer.maxNoOfContactsSelectForForward -
                                                                            1) {
                                                                      Lamat.toast(
                                                                          '${'maxallowed'.tr()} ${observer.maxNoOfContactsSelectForForward}');
                                                                    } else {
                                                                      selectedDynamicListFORUSERS.add(
                                                                          snapshot
                                                                              .data!);
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    }
                                                                  }
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
