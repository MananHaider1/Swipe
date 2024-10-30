// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/responsive.dart';

class TextStatus extends ConsumerStatefulWidget {
  final String currentuserNo;
  final List<dynamic> phoneNumberVariants;
  const TextStatus(
      {super.key,
      required this.currentuserNo,
      required this.phoneNumberVariants});

  @override
  TextStatusState createState() => TextStatusState();
}

class TextStatusState extends ConsumerState<TextStatus> {
  final TextEditingController _controller = TextEditingController();
  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  String getColorString() {
    Color color = colorsList[colorIndex];
    String colorString = color.toString(); // Color(0x12345678)
    String valueString =
        colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    return valueString;
  }

  List<Color> colorsList = [
    Colors.blueGrey[700]!,
    Colors.purple[700]!,
    Colors.blue[600]!,
    Colors.orange[500]!,
    Colors.cyan[700]!,
    Colors.pink[400]!,
    Colors.brown[600]!,
    Colors.red[400]!,
  ];
  int colorIndex = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPopNEw,
      child: Scaffold(
        backgroundColor: colorsList[colorIndex],
        body: Stack(
          children: [
            Center(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.fromLTRB(23, 23, 23, 10),
                child: TextField(
                  decoration: const InputDecoration(border: InputBorder.none),
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(MaxTextlettersInStatus),
                  ],
                  onChanged: (text) {
                    setState(() {});
                  },
                  maxLines: 7,
                  minLines: 1,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.6,
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
                right: 93,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    if ((colorsList.length - 1) == colorIndex) {
                      colorIndex = 0;
                    } else {
                      colorIndex++;
                    }
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.palette_rounded,
                      size: 30, color: Colors.white),
                )),
            Positioned(
                right: 19,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    _controller.text.trim();
                    if (_controller.text.isNotEmpty) {
                      final observer = ref.watch(observerProvider);
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionnstatus)
                          .doc(widget.currentuserNo)
                          .set({
                        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
                          {
                            Dbkeys.statusItemID:
                                DateTime.now().millisecondsSinceEpoch,
                            Dbkeys.statusItemTYPE: Dbkeys.statustypeTEXT,
                            Dbkeys.statusItemCAPTION: _controller.text,
                            Dbkeys.statusItemBGCOLOR: getColorString(),
                          }
                        ]),
                        Dbkeys.statusPUBLISHERPHONE: widget.currentuserNo,
                        Dbkeys.statusPUBLISHERPHONEVARIANTS:
                            widget.phoneNumberVariants,
                        Dbkeys.statusVIEWERLIST: [],
                        Dbkeys.statusVIEWERLISTWITHTIME: [],
                        Dbkeys.statusPUBLISHEDON: DateTime.now(),
                        Dbkeys.statusEXPIRININGON: DateTime.now().add(
                            Duration(hours: observer.statusDeleteAfterInHours)),
                      }, SetOptions(merge: true)).then((value) {
                        (!Responsive.isDesktop(context))
                            ? Navigator.of(context).pop()
                            : ref.invalidate(arrangementProvider);
                      });
                    }
                  },
                  icon: Icon(Icons.done,
                      size: 30,
                      color: _controller.text.isEmpty
                          ? Colors.white24
                          : Colors.white),
                )),
            Positioned(
                left: 19,
                top: (MediaQuery.of(context).padding.top) + 23,
                child: IconButton(
                  onPressed: () {
                    (!Responsive.isDesktop(context))
                        ? Navigator.of(context).pop()
                        : ref.invalidate(arrangementProvider);
                  },
                  icon: const Icon(Icons.close, size: 30, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
