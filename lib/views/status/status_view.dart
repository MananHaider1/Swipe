import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/profile_settings/profile_view.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';
import 'package:lamatdating/widgets/story_view/controller/story_controller.dart';
import 'package:lamatdating/widgets/story_view/widgets/story_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusView extends ConsumerStatefulWidget {
  final DocumentSnapshot<dynamic> statusDoc;
  final String currentUserNo;
  final String postedbyFullname;
  final String? postedbyPhotourl;
  final Function(String val)? callback;

  final SharedPreferences prefs;
  final DataModel model;

  const StatusView({
    super.key,
    required this.statusDoc,
    required this.postedbyFullname,
    required this.currentUserNo,
    required this.prefs,
    required this.model,
    this.postedbyPhotourl,
    this.callback,
  });
  @override
  StatusViewState createState() => StatusViewState();
}

class StatusViewState extends ConsumerState<StatusView> {
  final storyController = StoryController();
  List<StoryItem?> statusitemslist = [];
  String timeString = '';
  @override
  void initState() {
    super.initState();
    if (widget.statusDoc[Dbkeys.statusITEMSLIST].length > 0) {
      widget.statusDoc[Dbkeys.statusITEMSLIST].forEach((statusMap) {
        if (statusMap[Dbkeys.statusItemTYPE] == Dbkeys.statustypeIMAGE) {
          statusitemslist.add(
            StoryItem.pageImage(
                url: statusMap[Dbkeys.statusItemURL] ??
                    "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                caption: statusMap[Dbkeys.statusItemCAPTION] ?? "",
                controller: storyController,
                duration: const Duration(seconds: 7)),
          );
          setState(() {});
        } else if (statusMap[Dbkeys.statusItemTYPE] == Dbkeys.statustypeVIDEO) {
          statusitemslist.add(
            StoryItem.pageVideo(
                statusMap[Dbkeys.statusItemURL] ??
                    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                caption: statusMap[Dbkeys.statusItemCAPTION] ?? "",
                controller: storyController,
                duration: Duration(
                    milliseconds:
                        statusMap[Dbkeys.statusItemDURATION].round())),
          );
        } else if (statusMap[Dbkeys.statusItemTYPE] == Dbkeys.statustypeTEXT) {
          int value = int.parse(statusMap[Dbkeys.statusItemBGCOLOR], radix: 16);
          Color finalColor = Color(value);
          statusitemslist.add(StoryItem.text(
              title: statusMap[Dbkeys.statusItemCAPTION],
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.6,
                  fontWeight: FontWeight.w700),
              backgroundColor: finalColor));
        }
      });
    }
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  int statusPosition = 0;
  @override
  Widget build(BuildContext context) {
    final contactsProvider = ref.watch(smartContactProvider);
    return Scaffold(
      body: Stack(
        children: [
          StoryView(
            storyItems: statusitemslist,
            onStoryShow: (s) {
              statusPosition = statusPosition + 1;

              if ((statusPosition - 1) <
                  widget.statusDoc[Dbkeys.statusITEMSLIST].length) {
                FirebaseFirestore.instance
                    .collection(DbPaths.collectionnstatus)
                    .doc(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE])
                    .get()
                    .then((doc) {
                  if (doc.exists) {
                    FirebaseFirestore.instance
                        .collection(DbPaths.collectionnstatus)
                        .doc(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE])
                        .set({
                      widget.currentUserNo: FieldValue.arrayUnion([
                        widget.statusDoc[Dbkeys.statusITEMSLIST]
                            [statusPosition - 1][Dbkeys.statusItemID]
                      ])
                    }, SetOptions(merge: true));
                  }
                });
              }
              if (widget.currentUserNo !=
                      widget.statusDoc[Dbkeys.statusPUBLISHERPHONE] &&
                  !widget.statusDoc[Dbkeys.statusVIEWERLIST]
                      .contains(widget.currentUserNo) &&
                  statusPosition == 1) {
                FirebaseFirestore.instance
                    .collection(DbPaths.collectionnstatus)
                    .doc(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE])
                    .get()
                    .then((doc) {
                  if (doc.exists) {
                    //  FirebaseFirestore.instance
                    //                     .collection(DbPaths.collectionnstatus)
                    //                     .doc(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE])
                    //                     .update({
                    //                   Dbkeys.statusVIEWERLIST:
                    //                       FieldValue.arrayUnion([widget.currentUserNo])
                    //                 });
                    FirebaseFirestore.instance
                        .collection(DbPaths.collectionnstatus)
                        .doc(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE])
                        .update({
                      Dbkeys.statusVIEWERLIST:
                          FieldValue.arrayUnion([widget.currentUserNo]),
                      Dbkeys.statusVIEWERLISTWITHTIME: FieldValue.arrayUnion([
                        {
                          'phone': widget.currentUserNo,
                          'time': DateTime.now().millisecondsSinceEpoch
                        }
                      ])
                    });
                  }
                });
              }
            },
            onComplete: () {
              if (widget.currentUserNo ==
                  widget.statusDoc[Dbkeys.statusPUBLISHERPHONE]) {
                (!Responsive.isDesktop(context))
                    ? {Navigator.maybePop(context)}
                    : ref.invalidate(arrangementProvider);
              } else {
                (!Responsive.isDesktop(context))
                    ? {Navigator.maybePop(context)}
                    : ref.invalidate(arrangementProvider);
                widget.callback!(widget.statusDoc[Dbkeys.statusPUBLISHERPHONE]);
              }
            },
            progressPosition: ProgressPosition.top,
            repeat: false,
            controller: storyController,
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 140,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withOpacity(0.5),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      (!Responsive.isDesktop(context))
                          ? Navigator.of(context).pop()
                          : ref.invalidate(arrangementProvider);
                    },
                    child: const SizedBox(
                      width: 10,
                      child:
                          Icon(Icons.arrow_back, size: 24, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    width: 19,
                  ),
                  InkWell(
                    onTap: () async {
                      if (widget.currentUserNo ==
                          widget.statusDoc[Dbkeys.statusPUBLISHERPHONE]) {
                        (!Responsive.isDesktop(context))
                            ? Navigator.of(context).pop()
                            : ref.invalidate(arrangementProvider);
                      } else {
                        await contactsProvider.fetchFromFiretsoreAndReturnData(
                            widget.prefs,
                            widget.statusDoc[Dbkeys.statusPUBLISHERPHONE],
                            (doc) {
                          (!Responsive.isDesktop(context))
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileView(
                                            doc.data()!,
                                            widget.currentUserNo,
                                            widget.model,
                                            widget.prefs,
                                            const [],
                                            firestoreUserDoc: doc,
                                          )),
                                )
                              : ref
                                  .read(arrangementProvider.notifier)
                                  .setArrangement(ProfileView(
                                    doc.data()!,
                                    widget.currentUserNo,
                                    widget.model,
                                    widget.prefs,
                                    const [],
                                    firestoreUserDoc: doc,
                                  ));
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                          child: customCircleAvatar(
                              url: widget.postedbyPhotourl, radius: 20),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.45,
                              child: Text(
                                widget.postedbyFullname,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: AppConstants.lamatWhite,
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              getStatusTime(
                                  widget.statusDoc[Dbkeys.statusITEMSLIST][
                                      widget.statusDoc[Dbkeys.statusITEMSLIST]
                                              .length -
                                          1][Dbkeys.statusItemID],
                                  this.context,
                                  ref),
                              style: const TextStyle(
                                  color: AppConstants.lamatWhite,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
