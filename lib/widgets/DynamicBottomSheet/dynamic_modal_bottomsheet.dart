// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:lamatdating/constants.dart';

showDialogPermBottomSheet({
  required BuildContext context,
  required List<Widget> widgetList,
  Function(BuildContext context)? popableWidgetList,
  String? title,
  required bool isdark,
  String? desc,
  double? height,
  bool? isextraMargin = true,
  bool isCentre = true,
  double padding = 7,
}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Equivalent to `isDismissible: false`
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultNumericValue,
            ),
          ),
          content: SizedBox(
              height: MediaQuery.of(context).size.height *
                  .5, // Replace with the desired height
              width: MediaQuery.of(context).size.width *
                  .8, // Replace with the desired width
              child: Wrap(
                children: [
                  popableWidgetList != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            if (title != null && title != '')
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isdark
                                        ? AppConstants.lamatWhite
                                        : AppConstants.lamatBlack,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: popableWidgetList(context).length,
                              itemBuilder: (_, index) {
                                return popableWidgetList(context)[index];
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: widgetList.length,
                          itemBuilder: (_, index) {
                            return widgetList[index];
                          },
                        ),
                ],
              )),
        ),
      );
    },
  );

  // showModalBottomSheet<dynamic>(
  //     isScrollControlled: true,
  //     context: context,
  //     builder: (BuildContext bc) {
  //       return Wrap(children: <Widget>[
  //         Container(
  //           color: Colors.white,
  //           padding: EdgeInsets.all(padding),
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: const Radius.circular(25.0),
  //                     topRight: const Radius.circular(25.0))),
  //             child: Column(
  //                 // mainAxisSize: MainAxisSize.max,
  //                 // mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: isCentre == true
  //                     ? CrossAxisAlignment.center
  //                     : CrossAxisAlignment.start,
  //                 children: widgetList),
  //           ),
  //         )
  //       ]);
  //     });
}
