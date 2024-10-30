// ignore_for_file: library_private_types_in_public_api, avoid_function_literals_in_foreach_calls, empty_catches, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/views/custom/custom_button.dart';

import '../../../../custom/custom_icon_button.dart';

class AddContactsToChannel extends ConsumerStatefulWidget {
  const AddContactsToChannel({
    super.key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.isAddingWhileCreatingGroup,
    this.groupID,
  });
  final String? groupID;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final bool isAddingWhileCreatingGroup;

  @override
  AddContactsToChannelState createState() => AddContactsToChannelState();
}

class AddContactsToChannelState extends ConsumerState<AddContactsToChannel>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  final List<LocalUserData> _selectedList = [];
  List<String> targetUserNotificationTokens = [];
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();
  final TextEditingController groupname = TextEditingController();
  final TextEditingController groupdesc = TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        color: Teme.isDarktheme(widget.prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        child: const Center(
            child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
        )),
      )
    ]);
  }

  bool iscreatinggroup = false;
  @override
  Widget build(BuildContext context) {
    final contactsProvider = ref.watch(smartContactProvider);
    final groupList = ref.watch(channelsListProvider);
    super.build(context);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Scaffold(
                  key: _scaffold,
                  backgroundColor: Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  appBar: AppBar(
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      child: CustomIconButton(
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 1.8),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LandingWidget())),
                          color: AppConstants.primaryColor,
                          icon: leftArrowSvg),
                    ),
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    centerTitle: false,
                    // leadingWidth: 40,
                    title: _selectedList.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.selectcontacts.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.isAddingWhileCreatingGroup == true
                                    ? '${_selectedList.length} / ${contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length}'
                                    : '${_selectedList.length} ${LocaleKeys.selected.tr()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.selectcontacts.tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                widget.isAddingWhileCreatingGroup == true
                                    ? '${_selectedList.length} / ${contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length}'
                                    : '${_selectedList.length} ${LocaleKeys.selected.tr()}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Teme.isDarktheme(widget.prefs)
                                  ? AppConstants.backgroundColorDark
                                  : AppConstants.backgroundColor),
                        ),
                        onPressed: widget.isAddingWhileCreatingGroup == true
                            ? () async {
                                groupdesc.clear();
                                groupname.clear();
                                showModalBottomSheet(
                                    backgroundColor:
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.dialogColorDark
                                            : AppConstants.backgroundColor,
                                    isScrollControlled: true,
                                    context: context,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25.0)),
                                    ),
                                    builder: (BuildContext context) {
                                      // return your layout
                                      var w = MediaQuery.of(context).size.width;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom),
                                        child: Container(
                                            padding: const EdgeInsets.all(16),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.2,
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  const SizedBox(
                                                    height: 12,
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      LocaleKeys.startChannel
                                                          .tr(),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? AppConstants
                                                                  .dialogColorDark
                                                              : AppConstants
                                                                  .backgroundColor),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16.5),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 0),
                                                    // height: 63,
                                                    height: 83,
                                                    width: w / 1.24,
                                                    child: TextFormField(
                                                      controller: groupname,
                                                      autofocus: false,
                                                      validator: (val) {
                                                        if (val!.isEmpty) {
                                                          return LocaleKeys
                                                              .channelName
                                                              .tr();
                                                        }
                                                        return null;
                                                      },
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: AppConstants
                                                            .primaryColor
                                                            .withOpacity(.1),
                                                        hintText: LocaleKeys
                                                            .channelName
                                                            .tr(),
                                                        border:
                                                            OutlineInputBorder(
                                                          // Set outline border
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.edit,
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 0),
                                                    // height: 63,
                                                    height: 83,
                                                    width: w / 1.24,
                                                    child: TextFormField(
                                                      controller: groupdesc,
                                                      autofocus: false,
                                                      validator: (val) {
                                                        if (val!.isEmpty) {
                                                          return LocaleKeys
                                                              .pleaseEnterDescription
                                                              .tr();
                                                        }
                                                        return null;
                                                      },
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .words,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: AppConstants
                                                            .primaryColor
                                                            .withOpacity(.1),
                                                        hintText: LocaleKeys
                                                            .channeldesc
                                                            .tr(),
                                                        border:
                                                            OutlineInputBorder(
                                                          // Set outline border
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  AppConstants
                                                                      .defaultNumericValue),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        prefixIcon: Icon(
                                                          Icons.message,
                                                          color: Colors.grey
                                                              .withOpacity(0.5),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 6,
                                                  ),
                                                  CustomButton(
                                                      color: AppConstants
                                                          .primaryColor,
                                                      text:
                                                          LocaleKeys.start.tr(),
                                                      onPressed: () async {
                                                        Navigator.of(_scaffold
                                                                .currentContext!)
                                                            .pop();
                                                        List<String> listusers =
                                                            [];
                                                        List<String>
                                                            listmembers = [];

                                                        for (var element
                                                            in _selectedList) {
                                                          await contactsProvider
                                                              .fetchFromFiretsoreAndReturnData(
                                                                  widget.prefs,
                                                                  element.id,
                                                                  (peerDoc) async {
                                                            listusers.add(
                                                                element.id);
                                                            listmembers.add(
                                                                element.id);
                                                            if (peerDoc.data()![
                                                                    Dbkeys
                                                                        .notificationTokens] !=
                                                                null) {
                                                              if (peerDoc
                                                                      .data()![
                                                                          Dbkeys
                                                                              .notificationTokens]
                                                                      .length >
                                                                  0) {
                                                                targetUserNotificationTokens
                                                                    .add(peerDoc
                                                                        .data()![
                                                                            Dbkeys.notificationTokens]
                                                                        .last);
                                                              }
                                                            }
                                                          });
                                                        }
                                                        listmembers.add(widget
                                                            .currentUserNo!);
                                                        if (widget
                                                                .model!
                                                                .currentUser![Dbkeys
                                                                    .notificationTokens]
                                                                .last !=
                                                            null) {
                                                          targetUserNotificationTokens
                                                              .add(widget
                                                                  .model!
                                                                  .currentUser![
                                                                      Dbkeys
                                                                          .notificationTokens]
                                                                  .last);
                                                        }

                                                        DateTime time =
                                                            DateTime.now();
                                                        DateTime time2 =
                                                            DateTime.now().add(
                                                                const Duration(
                                                                    seconds:
                                                                        1));
                                                        String groupID =
                                                            '${widget.currentUserNo!.toString()}--${time.millisecondsSinceEpoch.toString()}';
                                                        Map<String, dynamic>
                                                            groupdata = {
                                                          Dbkeys.groupDESCRIPTION:
                                                              groupdesc.text
                                                                  .trim(),
                                                          Dbkeys.groupCREATEDON:
                                                              time,
                                                          Dbkeys.groupCREATEDBY:
                                                              widget
                                                                  .currentUserNo,
                                                          Dbkeys.groupNAME:
                                                              groupname.text
                                                                  .trim(),
                                                          Dbkeys.groupIDfiltered: groupID
                                                              .replaceAll(
                                                                  RegExp('-'),
                                                                  '')
                                                              .substring(
                                                                  1,
                                                                  groupID
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              '-'),
                                                                          '')
                                                                      .toString()
                                                                      .length),
                                                          Dbkeys.groupISTYPINGUSERID:
                                                              '',
                                                          Dbkeys.groupADMINLIST:
                                                              [
                                                            widget.currentUserNo
                                                          ],
                                                          Dbkeys.groupID:
                                                              groupID,
                                                          Dbkeys.groupISVERIFIED:
                                                              true,
                                                          Dbkeys.groupPHOTOURL:
                                                              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMg-8QhbZvcf-pxSXg2WtE3NnTmdqr0b_BHA&usqp=CAU',
                                                          Dbkeys.groupMEMBERSLIST:
                                                              listmembers,
                                                          Dbkeys.groupLATESTMESSAGETIME:
                                                              time.millisecondsSinceEpoch,
                                                          Dbkeys.groupTYPE: Dbkeys
                                                              .groupTYPEonlyadminmessageallowed,
                                                        };

                                                        for (var element
                                                            in listmembers) {
                                                          groupdata.putIfAbsent(
                                                              element
                                                                  .toString(),
                                                              () => time
                                                                  .millisecondsSinceEpoch);

                                                          groupdata.putIfAbsent(
                                                              '$element-joinedOn',
                                                              () => time
                                                                  .millisecondsSinceEpoch);
                                                        }
                                                        setStateIfMounted(() {
                                                          iscreatinggroup =
                                                              true;
                                                        });
                                                        final collection =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionchannels)
                                                                .get();
                                                        if (collection.docs !=
                                                                [] ||
                                                            collection.size !=
                                                                0) {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionchannels)
                                                              .doc(
                                                                  '${widget.currentUserNo!}--${time.millisecondsSinceEpoch}')
                                                              .set(groupdata)
                                                              .then(
                                                                  (value) async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(DbPaths
                                                                    .collectionchannels)
                                                                .doc(
                                                                    '${widget.currentUserNo!}--${time.millisecondsSinceEpoch}')
                                                                .collection(DbPaths
                                                                    .collectiongroupChats)
                                                                .doc(
                                                                    '${time.millisecondsSinceEpoch}--${widget.currentUserNo!}')
                                                                .set({
                                                              Dbkeys.groupmsgCONTENT:
                                                                  '',
                                                              Dbkeys.groupmsgLISToptional:
                                                                  listusers,
                                                              Dbkeys.groupmsgTIME:
                                                                  time.millisecondsSinceEpoch,
                                                              Dbkeys.groupmsgSENDBY:
                                                                  widget
                                                                      .currentUserNo,
                                                              Dbkeys.groupmsgISDELETED:
                                                                  false,
                                                              Dbkeys.groupmsgTYPE:
                                                                  Dbkeys
                                                                      .groupmsgTYPEnotificationCreatedGroup,
                                                            }).then((value) async {
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionchannels)
                                                                  .doc(
                                                                      '${widget.currentUserNo!}--${time.millisecondsSinceEpoch}')
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectiongroupChats)
                                                                  .doc(
                                                                      '${time2.millisecondsSinceEpoch}--${widget.currentUserNo!}')
                                                                  .set({
                                                                Dbkeys.groupmsgCONTENT:
                                                                    '',
                                                                Dbkeys.groupmsgLISToptional:
                                                                    listmembers,
                                                                Dbkeys.groupmsgTIME:
                                                                    time2
                                                                        .millisecondsSinceEpoch,
                                                                Dbkeys.groupmsgSENDBY:
                                                                    widget
                                                                        .currentUserNo,
                                                                Dbkeys.groupmsgISDELETED:
                                                                    false,
                                                                Dbkeys.groupmsgTYPE:
                                                                    Dbkeys
                                                                        .groupmsgTYPEnotificationAddedUser,
                                                              }).then(
                                                                      (val) async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        DbPaths
                                                                            .collectiontemptokensforunsubscribe)
                                                                    .doc(
                                                                        groupID)
                                                                    .set({
                                                                  Dbkeys.groupIDfiltered: groupID
                                                                      .replaceAll(
                                                                          RegExp(
                                                                              '-'),
                                                                          '')
                                                                      .substring(
                                                                          1,
                                                                          groupID
                                                                              .replaceAll(RegExp('-'), '')
                                                                              .toString()
                                                                              .length),
                                                                  Dbkeys.notificationTokens:
                                                                      targetUserNotificationTokens,
                                                                  'type':
                                                                      'subscribe'
                                                                });
                                                              }).then(
                                                                      (value) async {
                                                                Navigator.of(
                                                                        _scaffold
                                                                            .currentContext!)
                                                                    .pop();
                                                              }).catchError(
                                                                      (err) {
                                                                setStateIfMounted(
                                                                    () {
                                                                  iscreatinggroup =
                                                                      false;
                                                                });

                                                                Lamat.toast(
                                                                    '${LocaleKeys.error.tr()} $err');
                                                                debugPrint(
                                                                    'Error Creating group: $err');
                                                              });
                                                            });
                                                          });
                                                        } else {
                                                          EasyLoading.showError(
                                                              "No Group found");
                                                          Navigator.of(context)
                                                              .pop();
                                                        }
                                                      }),
                                                ])),
                                      );
                                    });
                              }
                            : () async {
                                // List<String> listusers = [];
                                List<String> listmembers = [];
                                for (var element in _selectedList) {
                                  await contactsProvider
                                      .fetchFromFiretsoreAndReturnData(
                                          widget.prefs, element.id,
                                          (peerDoc) async {
                                    listmembers.add(element.id);
                                    if (peerDoc.data()![
                                            Dbkeys.notificationTokens] !=
                                        null) {
                                      if (peerDoc
                                              .data()![
                                                  Dbkeys.notificationTokens]
                                              .length >
                                          0) {
                                        targetUserNotificationTokens.add(peerDoc
                                            .data()![Dbkeys.notificationTokens]
                                            .last);
                                      }
                                    }
                                  });
                                }
                                DateTime time = DateTime.now();

                                setStateIfMounted(() {
                                  iscreatinggroup = true;
                                });

                                Map<String, dynamic> docmap = {
                                  Dbkeys.groupMEMBERSLIST:
                                      FieldValue.arrayUnion(listmembers)
                                };

                                _selectedList.forEach((element) async {
                                  docmap.putIfAbsent('${element.id}-joinedOn',
                                      () => time.millisecondsSinceEpoch);
                                  docmap.putIfAbsent(element.id,
                                      () => time.millisecondsSinceEpoch);
                                });
                                setStateIfMounted(() {});
                                try {
                                  await FirebaseFirestore.instance
                                      .collection(DbPaths
                                          .collectiontemptokensforunsubscribe)
                                      .doc(widget.groupID)
                                      .delete();
                                } catch (err) {}
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectionchannels)
                                    .doc(widget.groupID)
                                    .update(docmap)
                                    .then((value) async {
                                  await FirebaseFirestore.instance
                                      .collection(DbPaths.collectionchannels)
                                      .doc(widget.groupID)
                                      .collection(DbPaths.collectiongroupChats)
                                      .doc(widget.groupID)
                                      .set({
                                    Dbkeys.groupmsgCONTENT: '',
                                    Dbkeys.groupmsgLISToptional: listmembers,
                                    Dbkeys.groupmsgTIME:
                                        time.millisecondsSinceEpoch,
                                    Dbkeys.groupmsgSENDBY: widget.currentUserNo,
                                    Dbkeys.groupmsgISDELETED: false,
                                    Dbkeys.groupmsgTYPE: Dbkeys
                                        .groupmsgTYPEnotificationAddedUser,
                                  }).then((v) async {
                                    await FirebaseFirestore.instance
                                        .collection(DbPaths
                                            .collectiontemptokensforunsubscribe)
                                        .doc(widget.groupID)
                                        .set({
                                      Dbkeys.groupIDfiltered: widget.groupID!
                                          .replaceAll(RegExp('-'), '')
                                          .substring(
                                              1,
                                              widget.groupID!
                                                  .replaceAll(RegExp('-'), '')
                                                  .toString()
                                                  .length),
                                      Dbkeys.notificationTokens:
                                          targetUserNotificationTokens,
                                      'type': 'subscribe'
                                    });
                                  }).then((value) async {
                                    Navigator.of(context).pop();
                                  }).catchError((err) {
                                    setStateIfMounted(() {
                                      iscreatinggroup = false;
                                    });

                                    Lamat.toast(
                                      LocaleKeys.errorOccured.tr(),
                                    );
                                  });
                                });
                              },
                      )
                    ],
                  ),
                  bottomSheet: contactsProvider.searchingcontactsindatabase ==
                              true ||
                          iscreatinggroup == true ||
                          _selectedList.isEmpty
                      ? const SizedBox(
                          height: 0,
                          width: 0,
                        )
                      : Container(
                          color: Teme.isDarktheme(widget.prefs)
                              ? AppConstants.dialogColorDark
                              : AppConstants.backgroundColor,
                          padding: const EdgeInsets.only(top: 6),
                          width: MediaQuery.of(context).size.width,
                          height: 94,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedList.reversed.toList().length,
                              itemBuilder: (context, int i) {
                                return Stack(
                                  children: [
                                    Container(
                                      width: 90,
                                      padding: const EdgeInsets.fromLTRB(
                                          11, 10, 12, 10),
                                      child: Column(
                                        children: [
                                          customCircleAvatar(
                                              url: _selectedList.reversed
                                                  .toList()[i]
                                                  .photoURL,
                                              radius: 20),
                                          const SizedBox(
                                            height: 7,
                                          ),
                                          Text(
                                            _selectedList.reversed
                                                .toList()[i]
                                                .name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  pickTextColorBasedOnBgColorAdvanced(
                                                      Teme.isDarktheme(
                                                              widget.prefs)
                                                          ? AppConstants
                                                              .backgroundColorDark
                                                          : AppConstants
                                                              .backgroundColor),
                                            ),
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
                                            _selectedList.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          width: 20.0,
                                          height: 20.0,
                                          padding: const EdgeInsets.all(2.0),
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
                        ),
                  body: RefreshIndicator(
                      onRefresh: () {
                        return contactsProvider.fetchContacts(context, model,
                            widget.currentUserNo!, widget.prefs, false);
                      },
                      child: contactsProvider.searchingcontactsindatabase ==
                                  true ||
                              iscreatinggroup == true
                          ? loading()
                          : contactsProvider
                                  .alreadyJoinedSavedUsersPhoneNameAsInServer
                                  .isEmpty
                              ? ListView(shrinkWrap: true, children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
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
                              : Padding(
                                  padding: EdgeInsets.only(
                                      bottom: _selectedList.isEmpty ? 0 : 80),
                                  child: Stack(
                                    children: [
                                      FutureBuilder(
                                          future: Future.delayed(
                                              const Duration(seconds: 2)),
                                          builder: (c, s) => s
                                                      .connectionState ==
                                                  ConnectionState.done
                                              ? Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30),
                                                    child: Card(
                                                      elevation: 0.5,
                                                      color: Colors.grey[100],
                                                      child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  8, 10, 8, 10),
                                                          child: RichText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: TextSpan(
                                                              children: [
                                                                WidgetSpan(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            2.5,
                                                                        right:
                                                                            4),
                                                                    child: Icon(
                                                                      Icons
                                                                          .contact_page,
                                                                      color: AppConstants
                                                                          .primaryColor
                                                                          .withOpacity(
                                                                              0.7),
                                                                      size: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                    text: LocaleKeys
                                                                        .nosave
                                                                        .tr(),
                                                                    // text:
                                                                    //     'No Saved Contacts available for this task',
                                                                    style: TextStyle(
                                                                        color: AppConstants.primaryColor.withOpacity(
                                                                            0.7),
                                                                        height:
                                                                            1.3,
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w400)),
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(30),
                                                      child:
                                                          CircularProgressIndicator(
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppConstants
                                                                    .secondaryColor),
                                                      )),
                                                )),
                                      Container(
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                        child: ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          padding: const EdgeInsets.all(10),
                                          itemCount: contactsProvider
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .length,
                                          itemBuilder: (context, idx) {
                                            String phone = contactsProvider
                                                .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                    idx]
                                                .phone;
                                            Widget? alreadyAddedUser =
                                                groupList.when(
                                              data: (groupLists) {
                                                return widget
                                                            .isAddingWhileCreatingGroup ==
                                                        true
                                                    ? null
                                                    : groupLists
                                                                .lastWhere((element) =>
                                                                    element.docmap[
                                                                        Dbkeys
                                                                            .groupID] ==
                                                                    widget
                                                                        .groupID)
                                                                .docmap[Dbkeys
                                                                    .groupMEMBERSLIST]
                                                                .contains(
                                                                    phone) ||
                                                            groupLists
                                                                .lastWhere((element) =>
                                                                    element.docmap[
                                                                        Dbkeys
                                                                            .groupID] ==
                                                                    widget
                                                                        .groupID)
                                                                .docmap[Dbkeys
                                                                    .groupADMINLIST]
                                                                .contains(phone)
                                                        ? const SizedBox()
                                                        : null;
                                              },
                                              loading: () =>
                                                  null, // return a loading widget if necessary
                                              error: (_, __) =>
                                                  null, // handle error state if necessary
                                            );
                                            return alreadyAddedUser ??
                                                FutureBuilder<LocalUserData?>(
                                                    future: contactsProvider
                                                        .fetchUserDataFromnLocalOrServer(
                                                            widget.prefs,
                                                            phone),
                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<
                                                                LocalUserData?>
                                                            snapshot) {
                                                      if (snapshot.hasData) {
                                                        LocalUserData user =
                                                            snapshot.data!;
                                                        return Container(
                                                            color: Teme.isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                                ? AppConstants
                                                                    .backgroundColorDark
                                                                : AppConstants
                                                                    .backgroundColor,
                                                            child: Column(
                                                              children: [
                                                                ListTile(
                                                                  tileColor: Teme.isDarktheme(
                                                                          widget
                                                                              .prefs)
                                                                      ? AppConstants
                                                                          .backgroundColorDark
                                                                      : AppConstants
                                                                          .backgroundColor,
                                                                  leading:
                                                                      customCircleAvatar(
                                                                    url: user
                                                                        .photoURL,
                                                                    radius:
                                                                        22.5,
                                                                  ),
                                                                  trailing:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border: Border.all(
                                                                          color: AppConstants
                                                                              .lamatGrey,
                                                                          width:
                                                                              1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child: _selectedList.lastIndexWhere((element) =>
                                                                                element.id ==
                                                                                phone) >=
                                                                            0
                                                                        ? const Icon(
                                                                            Icons.check,
                                                                            size:
                                                                                19.0,
                                                                            color:
                                                                                AppConstants.primaryColor,
                                                                          )
                                                                        : const Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.transparent,
                                                                            size:
                                                                                19.0,
                                                                          ),
                                                                  ),
                                                                  title: Text(
                                                                      user.name,
                                                                      style:
                                                                          TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                            ? AppConstants.backgroundColorDark
                                                                            : AppConstants.backgroundColor),
                                                                      )),
                                                                  subtitle: Text(
                                                                      phone,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              AppConstants.lamatGrey)),
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10.0,
                                                                      vertical:
                                                                          0.0),
                                                                  onTap: () {
                                                                    if (_selectedList.indexWhere((element) =>
                                                                            element.id ==
                                                                            phone) >=
                                                                        0) {
                                                                      _selectedList.removeAt(_selectedList.indexWhere((element) =>
                                                                          element
                                                                              .id ==
                                                                          phone));
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    } else {
                                                                      _selectedList
                                                                          .add(
                                                                              user);
                                                                      setStateIfMounted(
                                                                          () {});
                                                                    }
                                                                  },
                                                                ),
                                                                const Divider()
                                                              ],
                                                            ));
                                                      }
                                                      return const SizedBox(
                                                        height: 0,
                                                      );
                                                    });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )));
            }))));
  }
}
