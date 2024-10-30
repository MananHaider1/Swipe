import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/broadcast_provider.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/lazy_load_chat_provider.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfiniteCOLLECTIONListViewWidget extends StatefulWidget {
  final SharedPreferences prefs;
  final FirestoreDataProviderMESSAGESforGROUPCHAT?
      firestoreDataProviderMESSAGESforGROUPCHAT;
  final FirestoreDataProviderMESSAGESforLAZYLOADINGCHAT?
      firestoreDataProviderMESSAGESforLAZYLOADINGCHAT;
  final FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE?
      firestoreDataProviderMESSAGESforBROADCASTCHATPAGE;
  final String? datatype;
  final Widget? list;
  final Query? refdata;
  final bool? isreverse;
  final EdgeInsets? padding;
  final String? parentid;
  final ScrollController scrollController;
  const InfiniteCOLLECTIONListViewWidget({
    this.firestoreDataProviderMESSAGESforGROUPCHAT,
    this.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE,
    this.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT,
    this.datatype,
    this.isreverse,
    required this.prefs,
    this.padding,
    this.parentid,
    this.list,
    this.refdata,
    required this.scrollController,
    super.key,
  });

  @override
  InfiniteCOLLECTIONListViewWidgetState createState() =>
      InfiniteCOLLECTIONListViewWidgetState();
}

class InfiniteCOLLECTIONListViewWidgetState
    extends State<InfiniteCOLLECTIONListViewWidget> {
  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(scrollListener);
    if (widget.datatype == Dbkeys.datatypeGROUPCHATMSGS) {
      widget.firestoreDataProviderMESSAGESforGROUPCHAT!
          .fetchNextData(widget.datatype, widget.refdata, true);
    } else if (widget.datatype == Dbkeys.datatypeBROADCASTCMSGS) {
      widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
          .fetchNextData(widget.datatype, widget.refdata, true);
    } else if (widget.datatype == Dbkeys.datatypeONETOONEMSGS) {
      widget.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
          .fetchNextData(widget.datatype, widget.refdata, true);
    }
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (widget.scrollController.offset >=
            widget.scrollController.position.maxScrollExtent / 2 &&
        !widget.scrollController.position.outOfRange) {
      if (widget.datatype == Dbkeys.datatypeGROUPCHATMSGS) {
        if (widget.firestoreDataProviderMESSAGESforGROUPCHAT!.hasNext) {
          widget.firestoreDataProviderMESSAGESforGROUPCHAT!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else if (widget.datatype == Dbkeys.datatypeBROADCASTCMSGS) {
        if (widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!.hasNext) {
          widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else if (widget.datatype == Dbkeys.datatypeONETOONEMSGS) {
        if (widget.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!.hasNext) {
          widget.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      reverse:
          widget.isreverse == null || widget.isreverse == false ? false : true,
      controller: widget.scrollController,
      padding: widget.padding ?? const EdgeInsets.all(0),
      children: widget.datatype == Dbkeys.datatypeONETOONEMSGS
          ? [
              Container(child: widget.list),
              (widget.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
                          .hasNext ==
                      true)
                  ? Center(
                      child: GestureDetector(
                        onTap: () {
                          widget
                              .firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
                              .fetchNextData(
                                  widget.datatype, widget.refdata, false);
                        },
                        child: Padding(
                          padding: widget
                                  .firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
                                  .recievedDocs
                                  .isEmpty
                              ? EdgeInsets.fromLTRB(
                                  38,
                                  MediaQuery.of(context).size.height / 3,
                                  38,
                                  38)
                              : const EdgeInsets.fromLTRB(18, 38, 18, 48),
                          child: const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppConstants.secondaryColor),
                            ),
                          ),
                        ),
                      ),
                    )
                  : widget.firestoreDataProviderMESSAGESforLAZYLOADINGCHAT!
                          .recievedDocs.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.fromLTRB(26, 28, 26, 97),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.message_rounded,
                                size: 60,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(widget.prefs)
                                        ? AppConstants.backgroundColorDark
                                        : AppConstants.backgroundColor),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text("Say Hi! ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(widget.prefs)
                                                  ? AppConstants
                                                      .backgroundColorDark
                                                  : AppConstants
                                                      .backgroundColor),
                                      fontSize: 18))
                            ],
                          ),
                        ))
                      : const SizedBox(),
            ]
          : widget.datatype == Dbkeys.datatypeBROADCASTCMSGS
              ? [
                  Container(child: widget.list),
                  (widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                              .hasNext ==
                          true)
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              widget
                                  .firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                                  .fetchNextData(
                                      widget.datatype, widget.refdata, false);
                            },
                            child: Padding(
                              padding: widget
                                      .firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                                      .recievedDocs
                                      .isEmpty
                                  ? EdgeInsets.fromLTRB(
                                      38,
                                      MediaQuery.of(context).size.height / 3,
                                      38,
                                      38)
                                  : const EdgeInsets.fromLTRB(18, 38, 18, 48),
                              child: const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConstants.secondaryColor),
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.firestoreDataProviderMESSAGESforBROADCASTCHATPAGE!
                              .recievedDocs.isEmpty
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.fromLTRB(26, 28, 26, 97),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_rounded,
                                    size: 60,
                                    color: AppConstants.primaryColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Recent Chats",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppConstants.lamatGrey,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ))
                          : const SizedBox(),
                ]
              : [
                  Container(child: widget.list),
                  (widget.firestoreDataProviderMESSAGESforGROUPCHAT!.hasNext ==
                          true)
                      ? Center(
                          child: GestureDetector(
                            onTap: () {
                              widget.firestoreDataProviderMESSAGESforGROUPCHAT!
                                  .fetchNextData(
                                      widget.datatype, widget.refdata, false);
                            },
                            child: Padding(
                              padding: widget
                                      .firestoreDataProviderMESSAGESforGROUPCHAT!
                                      .recievedDocs
                                      .isEmpty
                                  ? EdgeInsets.fromLTRB(
                                      38,
                                      MediaQuery.of(context).size.height / 3,
                                      38,
                                      38)
                                  : const EdgeInsets.fromLTRB(18, 38, 18, 18),
                              child: const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.8,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConstants.secondaryColor),
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.firestoreDataProviderMESSAGESforGROUPCHAT!
                              .recievedDocs.isEmpty
                          ? const Center(
                              child: Padding(
                              padding: EdgeInsets.fromLTRB(26, 28, 26, 97),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.message_rounded,
                                    size: 60,
                                    color: AppConstants.primaryColor,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Recent Chats",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: AppConstants.lamatGrey,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ))
                          : const SizedBox(),
                ]);
}
