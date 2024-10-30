import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/providers/call_history_provider.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfiniteListView extends StatefulWidget {
  final FirestoreDataProviderCALLHISTORY? firestoreDataProviderCALLHISTORY;
  final String? datatype;
  final Widget? list;
  final Query? refdata;
  final SharedPreferences prefs;
  final bool? isreverse;
  final EdgeInsets? padding;
  final String? parentid;
  const InfiniteListView({
    this.firestoreDataProviderCALLHISTORY,
    this.datatype,
    this.isreverse,
    this.padding,
    required this.prefs,
    this.parentid,
    this.list,
    this.refdata,
    super.key,
  });

  @override
  InfiniteListViewState createState() => InfiniteListViewState();
}

class InfiniteListViewState extends State<InfiniteListView> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position.maxScrollExtent / 2 &&
        !scrollController.position.outOfRange) {
      if (widget.datatype == 'CALLHISTORY') {
        if (widget.firestoreDataProviderCALLHISTORY!.hasNext) {
          widget.firestoreDataProviderCALLHISTORY!
              .fetchNextData(widget.datatype, widget.refdata, false);
        }
      } else {}
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        reverse: widget.isreverse == null || widget.isreverse == false
            ? false
            : true,
        controller: scrollController,
        padding: widget.padding ?? const EdgeInsets.all(0),
        children: widget.datatype == 'CALLHISTORY'
            ?
            //-----PRODUCTS
            [
                Container(child: widget.list),
                (widget.firestoreDataProviderCALLHISTORY!.hasNext == true)
                    ? Center(
                        child: GestureDetector(
                          onTap: () {
                            widget.firestoreDataProviderCALLHISTORY!
                                .fetchNextData(
                                    widget.datatype, widget.refdata, false);
                          },
                          child: SizedBox(
                            height: widget.firestoreDataProviderCALLHISTORY!
                                    .recievedDocs.isEmpty
                                ? 205
                                : 100,
                            width: widget.firestoreDataProviderCALLHISTORY!
                                    .recievedDocs.isEmpty
                                ? 205
                                : 100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppConstants.secondaryColor)),
                            ),
                          ),
                        ),
                      )
                    : widget.firestoreDataProviderCALLHISTORY!.recievedDocs
                            .isEmpty
                        ? Align(
                            alignment: Alignment.center,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    28,
                                    MediaQuery.of(context).size.height / 48.7,
                                    28,
                                    10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        padding: const EdgeInsets.all(22),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          // borderRadius: BorderRadius.all(
                                          //   Radius.circular(20),
                                          // ),
                                        ),
                                        height: 100,
                                        width: 100,
                                        child: const Icon(Icons.call,
                                            size: 60, color: Colors.grey)),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      "No calls",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              pickTextColorBasedOnBgColorAdvanced(
                                                  Teme.isDarktheme(widget.prefs)
                                                      ? AppConstants
                                                          .backgroundColorDark
                                                      : AppConstants
                                                          .backgroundColor),
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "All Video & Audio call history will be shown here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13.9,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            height: 0,
                          ),
              ]
            : [],
      );
}
