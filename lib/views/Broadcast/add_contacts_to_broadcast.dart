// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/widgets/InputTextBox/input_text_box.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/main.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';

import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/calling/pickup_layout.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/MyElevatedButton/elevated_butn.dart';

class AddContactsToBroadcast extends ConsumerStatefulWidget {
  const AddContactsToBroadcast({
    super.key,
    this.blacklistedUsers,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.isAddingWhileCreatingBroadcast,
    this.broadcastID,
  });

  final List? blacklistedUsers;
  final String? broadcastID;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final bool isAddingWhileCreatingBroadcast;

  @override
  AddContactsToBroadcastState createState() => AddContactsToBroadcastState();
}

class AddContactsToBroadcastState extends ConsumerState<AddContactsToBroadcast>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  List<LocalUserData> _selectedList = [];

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = TextEditingController();
  final TextEditingController broadcastname = TextEditingController();
  final TextEditingController broadcastdesc = TextEditingController();
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
        color: pickTextColorBasedOnBgColorAdvanced(
                !Teme.isDarktheme(widget.prefs)
                    ? AppConstants.backgroundColorDark
                    : AppConstants.backgroundColor)
            .withOpacity(0.8),
        child: const Center(
            child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
        )),
      )
    ]);
  }

  bool iscreatingbroadcast = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final contactsProvider = ref.watch(smartContactProvider);
    final broadcastsList = ref.watch(broadcastsListProvider);
    // final groupsList = ref.watch<List<GroupModel>>();

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Lamat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer(
                  builder: (context, ref, child) => Consumer(
                      builder: (context, ref, child) => Scaffold(
                          key: _scaffold,
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
                            title: _selectedList.isEmpty
                                ? Text(
                                    "Select Contacts to Add",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants
                                                      .backgroundColorDark
                                                  : AppConstants
                                                      .backgroundColor),
                                    ),
                                    textAlign: TextAlign.left,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Select Contacts to Add",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        widget.isAddingWhileCreatingBroadcast ==
                                                true
                                            ? '${_selectedList.length} / ${contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length}'
                                            : '${_selectedList.length} ${'selected'.tr()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                            actions: <Widget>[
                              _selectedList.isEmpty
                                  ? const SizedBox()
                                  : IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color:
                                            pickTextColorBasedOnBgColorAdvanced(
                                                Teme.isDarktheme(widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor),
                                      ),
                                      onPressed:
                                          widget.isAddingWhileCreatingBroadcast ==
                                                  true
                                              ? () async {
                                                  broadcastdesc.clear();
                                                  broadcastname.clear();
                                                  showModalBottomSheet(
                                                      backgroundColor: Teme
                                                              .isDarktheme(
                                                                  widget.prefs)
                                                          ? AppConstants
                                                              .dialogColorDark
                                                          : AppConstants
                                                              .backgroundColor,
                                                      isScrollControlled: true,
                                                      context: context,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        25.0)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        // return your layout
                                                        var w = MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width;
                                                        return Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2.2,
                                                              child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    const SizedBox(
                                                                      height:
                                                                          12,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 3,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              7),
                                                                      child:
                                                                          Text(
                                                                        "Setup Broadcast Details",
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style: TextStyle(
                                                                            color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs)
                                                                                ? AppConstants.dialogColorDark
                                                                                : AppConstants.backgroundColor),
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 16.5),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                      // height: 63,
                                                                      height:
                                                                          83,
                                                                      width: w /
                                                                          1.24,
                                                                      child:
                                                                          InpuTextBox(
                                                                        isDark:
                                                                            Teme.isDarktheme(widget.prefs),
                                                                        controller:
                                                                            broadcastname,
                                                                        leftrightmargin:
                                                                            0,
                                                                        showIconboundary:
                                                                            false,
                                                                        boxcornerradius:
                                                                            5.5,
                                                                        boxheight:
                                                                            50,
                                                                        hinttext:
                                                                            "Broadcast name",
                                                                        prefixIconbutton:
                                                                            Icon(
                                                                          Icons
                                                                              .edit,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10),
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                      // height: 63,
                                                                      height:
                                                                          83,
                                                                      width: w /
                                                                          1.24,
                                                                      child:
                                                                          InpuTextBox(
                                                                        isDark:
                                                                            Teme.isDarktheme(widget.prefs),
                                                                        maxLines:
                                                                            1,
                                                                        controller:
                                                                            broadcastdesc,
                                                                        leftrightmargin:
                                                                            0,
                                                                        showIconboundary:
                                                                            false,
                                                                        boxcornerradius:
                                                                            5.5,
                                                                        boxheight:
                                                                            50,
                                                                        hinttext:
                                                                            'pleaseEnterDescription'.tr(),
                                                                        prefixIconbutton:
                                                                            Icon(
                                                                          Icons
                                                                              .message,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    myElevatedButton(
                                                                        color: AppConstants
                                                                            .secondaryColor,
                                                                        child:
                                                                            const Padding(
                                                                          padding: EdgeInsets.fromLTRB(
                                                                              10,
                                                                              15,
                                                                              10,
                                                                              15),
                                                                          child:
                                                                              Text(
                                                                            "Create Broadcast",
                                                                            style:
                                                                                TextStyle(color: Colors.white, fontSize: 18),
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () async {
                                                                          Navigator.of(_scaffold.currentContext!)
                                                                              .pop();
                                                                          List<String>
                                                                              listusers =
                                                                              [];
                                                                          List<String>
                                                                              listmembers =
                                                                              [];
                                                                          for (var element
                                                                              in _selectedList) {
                                                                            listusers.add(element.id);
                                                                            listmembers.add(element.id);
                                                                          }

                                                                          DateTime
                                                                              time =
                                                                              DateTime.now();
                                                                          DateTime
                                                                              time2 =
                                                                              DateTime.now().add(const Duration(seconds: 1));
                                                                          Map<String, dynamic>
                                                                              broadcastdata =
                                                                              {
                                                                            Dbkeys.broadcastDESCRIPTION: broadcastdesc.text.isEmpty
                                                                                ? ''
                                                                                : broadcastdesc.text.trim(),
                                                                            Dbkeys.broadcastCREATEDON:
                                                                                time,
                                                                            Dbkeys.broadcastCREATEDBY:
                                                                                widget.currentUserNo,
                                                                            Dbkeys.broadcastNAME: broadcastname.text.isEmpty
                                                                                ? 'Unnamed BroadCast'
                                                                                : broadcastname.text.trim(),
                                                                            Dbkeys.broadcastADMINLIST:
                                                                                [
                                                                              widget.currentUserNo
                                                                            ],
                                                                            Dbkeys.broadcastID:
                                                                                '${widget.currentUserNo!}--${time.millisecondsSinceEpoch}',
                                                                            Dbkeys.broadcastMEMBERSLIST:
                                                                                listmembers,
                                                                            Dbkeys.broadcastLATESTMESSAGETIME:
                                                                                time.millisecondsSinceEpoch,
                                                                            Dbkeys.broadcastBLACKLISTED:
                                                                                [],
                                                                          };

                                                                          for (var element
                                                                              in listmembers) {
                                                                            broadcastdata.putIfAbsent(element.toString(),
                                                                                () => time.millisecondsSinceEpoch);

                                                                            broadcastdata.putIfAbsent('$element-joinedOn',
                                                                                () => time.millisecondsSinceEpoch);
                                                                          }
                                                                          setStateIfMounted(
                                                                              () {
                                                                            iscreatingbroadcast =
                                                                                true;
                                                                          });
                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection(DbPaths.collectionbroadcasts)
                                                                              .doc('${widget.currentUserNo!}--${time.millisecondsSinceEpoch}')
                                                                              .set(broadcastdata)
                                                                              .then((value) async {
                                                                            await FirebaseFirestore.instance.collection(DbPaths.collectionbroadcasts).doc('${widget.currentUserNo!}--${time.millisecondsSinceEpoch}').collection(DbPaths.collectionbroadcastsChats).doc('${time2.millisecondsSinceEpoch}--${widget.currentUserNo!}').set({
                                                                              Dbkeys.broadcastmsgCONTENT: '',
                                                                              Dbkeys.broadcastmsgLISToptional: listmembers,
                                                                              Dbkeys.broadcastmsgTIME: time2.millisecondsSinceEpoch,
                                                                              Dbkeys.broadcastmsgSENDBY: widget.currentUserNo,
                                                                              Dbkeys.broadcastmsgISDELETED: false,
                                                                              Dbkeys.broadcastmsgTYPE: Dbkeys.broadcastmsgTYPEnotificationAddedUser,
                                                                            }).then((value) async {
                                                                              Navigator.of(_scaffold.currentContext!).pop();
                                                                            }).catchError((err) {
                                                                              setStateIfMounted(() {
                                                                                iscreatingbroadcast = false;
                                                                              });

                                                                              Lamat.toast('Error Creating Broadcast. $err');
                                                                              if (kDebugMode) {
                                                                                print('Error Creating Broadcast. $err');
                                                                              }
                                                                            });
                                                                          });
                                                                        }),
                                                                  ])),
                                                        );
                                                      });
                                                }
                                              : () async {
                                                  // List<String> listusers = [];
                                                  List<String> listmembers = [];
                                                  for (var element
                                                      in _selectedList) {
                                                    // listusers.add(element[Dbkeys.phone]);
                                                    listmembers.add(element.id);
                                                    // listmembers
                                                    //     .add(widget.currentUserNo!);
                                                  }
                                                  DateTime time =
                                                      DateTime.now();

                                                  setStateIfMounted(() {
                                                    iscreatingbroadcast = true;
                                                  });

                                                  Map<String, dynamic> docmap =
                                                      {
                                                    Dbkeys.broadcastMEMBERSLIST:
                                                        FieldValue.arrayUnion(
                                                            listmembers)
                                                  };

                                                  for (var element
                                                      in _selectedList) {
                                                    await docmap.putIfAbsent(
                                                        '${element.id}-joinedOn',
                                                        () => time
                                                            .millisecondsSinceEpoch);
                                                  }

                                                  setStateIfMounted(() {});
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(DbPaths
                                                          .collectionbroadcasts)
                                                      .doc(widget.broadcastID)
                                                      .update(docmap)
                                                      .then((value) async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(DbPaths
                                                            .collectionbroadcasts)
                                                        .doc(
                                                            '${widget.currentUserNo!}--${time.millisecondsSinceEpoch}')
                                                        .collection(DbPaths
                                                            .collectionbroadcastsChats)
                                                        .doc(
                                                            '${time.millisecondsSinceEpoch}--${widget.currentUserNo!}')
                                                        .set({
                                                      Dbkeys.broadcastmsgCONTENT:
                                                          '',
                                                      Dbkeys.broadcastmsgLISToptional:
                                                          listmembers,
                                                      Dbkeys.broadcastmsgTIME: time
                                                          .millisecondsSinceEpoch,
                                                      Dbkeys.broadcastmsgSENDBY:
                                                          widget.currentUserNo,
                                                      Dbkeys.broadcastmsgISDELETED:
                                                          false,
                                                      Dbkeys.broadcastmsgTYPE:
                                                          Dbkeys
                                                              .broadcastmsgTYPEnotificationAddedUser,
                                                    }).then((value) async {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }).catchError((err) {
                                                      setStateIfMounted(() {
                                                        iscreatingbroadcast =
                                                            false;
                                                      });

                                                      Lamat.toast(
                                                          "Error adding broadcast");
                                                    });
                                                  });
                                                },
                                    )
                            ],
                          ),
                          bottomSheet: contactsProvider
                                          .searchingcontactsindatabase ==
                                      true ||
                                  iscreatingbroadcast == true ||
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
                                  height: 97,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedList.reversed
                                          .toList()
                                          .length,
                                      itemBuilder: (context, int i) {
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 80,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      11, 10, 12, 10),
                                              child: Column(
                                                children: [
                                                  customCircleAvatar(
                                                      url: _selectedList
                                                          .reversed
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: pickTextColorBasedOnBgColorAdvanced(Teme
                                                              .isDarktheme(
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
                                                    _selectedList.remove(
                                                        _selectedList.reversed
                                                            .toList()[i]);
                                                  });
                                                },
                                                child: Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  padding:
                                                      const EdgeInsets.all(2.0),
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
                                ),
                          body: RefreshIndicator(
                              onRefresh: () {
                                return contactsProvider.fetchContacts(
                                    context,
                                    model,
                                    widget.currentUserNo!,
                                    widget.prefs,
                                    false);
                              },
                              child: contactsProvider
                                              .searchingcontactsindatabase ==
                                          true ||
                                      iscreatingbroadcast == true
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
                                                    const Text("No Contacts",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          color: AppConstants
                                                              .lamatGrey,
                                                        )),
                                                    const SizedBox(
                                                      height: 40,
                                                    ),
                                                    IconButton(
                                                        onPressed: () async {
                                                          contactsProvider
                                                              .setIsLoading(
                                                                  true);
                                                          await contactsProvider
                                                              .fetchContacts(
                                                            context,
                                                            model,
                                                            widget
                                                                .currentUserNo!,
                                                            widget.prefs,
                                                            true,
                                                            isRequestAgain:
                                                                true,
                                                          )
                                                              .then((d) {
                                                            Future.delayed(
                                                                const Duration(
                                                                    milliseconds:
                                                                        500),
                                                                () {
                                                              contactsProvider
                                                                  .setIsLoading(
                                                                      false);
                                                            });
                                                          });
                                                          setState(() {});
                                                        },
                                                        icon: const Icon(
                                                          Icons.refresh_rounded,
                                                          size: 40,
                                                          color: AppConstants
                                                              .primaryColor,
                                                        ))
                                                  ],
                                                ),
                                              ))
                                        ])
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              bottom: _selectedList.isEmpty
                                                  ? 0
                                                  : 80),
                                          child: Stack(
                                            children: [
                                              FutureBuilder(
                                                  future: Future.delayed(
                                                      const Duration(
                                                          seconds: 2)),
                                                  builder: (c, s) =>
                                                      s.connectionState ==
                                                              ConnectionState
                                                                  .done
                                                          ? Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        30),
                                                                child: Card(
                                                                  elevation:
                                                                      0.5,
                                                                  color: Colors
                                                                          .grey[
                                                                      100],
                                                                  child:
                                                                      Container(
                                                                          padding: const EdgeInsets
                                                                              .fromLTRB(
                                                                              8,
                                                                              10,
                                                                              8,
                                                                              10),
                                                                          child:
                                                                              RichText(
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                WidgetSpan(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                                                                                    child: Icon(
                                                                                      Icons.contact_page,
                                                                                      color: AppConstants.primaryColor.withOpacity(0.7),
                                                                                      size: 14,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                TextSpan(text: "No Saved Contacts", style: TextStyle(color: AppConstants.secondaryColor.withOpacity(0.7), height: 1.3, fontSize: 13, fontWeight: FontWeight.w400)),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                ),
                                                              ),
                                                            )
                                                          : Container(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child:
                                                                  const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              30),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          valueColor:
                                                                              AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor),
                                                                        ),
                                                                      )),
                                                            )),
                                              Container(
                                                color: Teme.isDarktheme(
                                                        widget.prefs)
                                                    ? AppConstants
                                                        .backgroundColorDark
                                                    : AppConstants
                                                        .backgroundColor,
                                                child: ListView.builder(
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  itemCount: contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .length,
                                                  itemBuilder: (context, idx) {
                                                    String phone = contactsProvider
                                                        .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                            idx]
                                                        .phone;
                                                    Widget? alreadyAddedUser =
                                                        widget.isAddingWhileCreatingBroadcast ==
                                                                true
                                                            ? null
                                                            : broadcastsList
                                                                .when(
                                                                data:
                                                                    (broadcastsList) {
                                                                  final broadcast = broadcastsList.lastWhere((element) =>
                                                                      element.docmap[
                                                                          Dbkeys
                                                                              .broadcastID] ==
                                                                      widget
                                                                          .broadcastID);
                                                                  return broadcast
                                                                          .docmap[Dbkeys
                                                                              .broadcastMEMBERSLIST]
                                                                          .contains(
                                                                              phone)
                                                                      ? const SizedBox()
                                                                      : null;
                                                                },
                                                                loading: () =>
                                                                    const Center(
                                                                        child:
                                                                            CircularProgressIndicator()),
                                                                error: (_,
                                                                        __) =>
                                                                    const Text(
                                                                        'Error'),
                                                              );
                                                    return alreadyAddedUser ??
                                                        FutureBuilder<
                                                                LocalUserData?>(
                                                            future: contactsProvider
                                                                .fetchUserDataFromnLocalOrServer(
                                                                    widget
                                                                        .prefs,
                                                                    phone),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        LocalUserData?>
                                                                    snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                LocalUserData
                                                                    user =
                                                                    snapshot
                                                                        .data!;
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
                                                                            border:
                                                                                Border.all(color: AppConstants.lamatGrey, width: 1),
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                          ),
                                                                          child: _selectedList.lastIndexWhere((element) => element.id == phone) >= 0
                                                                              ? const Icon(
                                                                                  Icons.check,
                                                                                  size: 19.0,
                                                                                  color: AppConstants.primaryColor,
                                                                                )
                                                                              : const Icon(
                                                                                  Icons.check,
                                                                                  color: Colors.transparent,
                                                                                  size: 19.0,
                                                                                ),
                                                                        ),
                                                                        title: Text(
                                                                            user
                                                                                .name,
                                                                            style:
                                                                                TextStyle(
                                                                              color: pickTextColorBasedOnBgColorAdvanced(Teme.isDarktheme(widget.prefs) ? AppConstants.backgroundColorDark : AppConstants.backgroundColor),
                                                                            )),
                                                                        subtitle: Text(
                                                                            phone,
                                                                            style:
                                                                                const TextStyle(color: AppConstants.lamatGrey)),
                                                                        contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                10.0,
                                                                            vertical:
                                                                                0.0),
                                                                        onTap:
                                                                            () {
                                                                          if (_selectedList.indexWhere((element) => element.id == phone) >=
                                                                              0) {
                                                                            _selectedList.removeAt(_selectedList.indexWhere((element) =>
                                                                                element.id ==
                                                                                phone));
                                                                            setStateIfMounted(() {});
                                                                          } else {
                                                                            _selectedList.add(snapshot.data!);
                                                                            setStateIfMounted(() {});
                                                                          }
                                                                        },
                                                                      ),
                                                                      const Divider()
                                                                    ],
                                                                  ),
                                                                );
                                                              }
                                                              return const SizedBox();
                                                            });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )))));
            }))));
  }
}
