// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/profile_settings/profile_view.dart';
import 'package:lamatdating/views/status/components/status_time_format.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

showViewers(BuildContext context, DocumentSnapshot myStatusDoc, var filtered,
    String currentuserno, SharedPreferences prefs, DataModel model) {
  var statusViewerList = [];
  myStatusDoc[Dbkeys.statusVIEWERLIST].forEach((phone) {
    if (!statusViewerList.contains(phone)) {
      statusViewerList.add(phone);
    }
  });

  showModalBottomSheet(
      backgroundColor: Teme.isDarktheme(prefs)
          ? AppConstants.dialogColorDark
          : AppConstants.backgroundColor,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        // return your layout
        return Consumer(builder: (context, ref, _child) {
          return Container(
              padding: const EdgeInsets.all(12),
              height: MediaQuery.of(context).size.height / 1.1,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          LocaleKeys.viewedby.tr(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(prefs)
                                    ? AppConstants.dialogColorDark
                                    : AppConstants.backgroundColor),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.visibility,
                              color: AppConstants.lamatGrey),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            ' ${statusViewerList.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(prefs)
                                      ? AppConstants.dialogColorDark
                                      : AppConstants.backgroundColor),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statusViewerList.length,
                      itemBuilder: (context, int i) {
                        List viewerslist = [];
                        List viewerslistNotFinal =
                            myStatusDoc[Dbkeys.statusVIEWERLISTWITHTIME]
                                .reversed
                                .toList();
                        for (var m in viewerslistNotFinal) {
                          if (!viewerslist.contains(m)) {
                            viewerslist.add(m);
                          }
                        }

                        return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .doc(viewerslist[i]['phone'])
                                .get(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListTile(
                                  isThreeLine: false,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(5, 6, 10, 6),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.26),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    filtered!.entries.toList().indexWhere(
                                                (element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']) >
                                            0
                                        ? filtered!.entries
                                            .elementAt(filtered!.entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']))
                                            .value
                                            .toString()
                                        : viewerslist[i]['phone'],
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(prefs)
                                                  ? AppConstants.dialogColorDark
                                                  : AppConstants
                                                      .backgroundColor),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    getStatusTime(
                                        viewerslist[i]['time'], context, ref),
                                    style: const TextStyle(
                                        height: 1.4,
                                        color: AppConstants.lamatGrey),
                                  ),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data.exists) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfileView(
                                                snapshot.data!.data(),
                                                currentuserno,
                                                model,
                                                prefs,
                                                const [],
                                                firestoreUserDoc: snapshot.data,
                                              )),
                                    );
                                  },
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(5, 6, 10, 6),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: snapshot.data[Dbkeys.photoUrl] ==
                                              null
                                          ? Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.person),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: snapshot
                                                      .data[Dbkeys.photoUrl] ??
                                                  '',
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.person),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 50.0,
                                                height: 50.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.person),
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    filtered!.entries.toList().indexWhere(
                                                (element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']) >
                                            0
                                        ? filtered!.entries
                                            .elementAt(filtered!.entries
                                                .toList()
                                                .indexWhere((element) =>
                                                    element.key ==
                                                    viewerslist[i]['phone']))
                                            .value
                                            .toString()
                                        : snapshot.data[Dbkeys.nickname],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          pickTextColorBasedOnBgColorAdvanced(
                                              Teme.isDarktheme(prefs)
                                                  ? AppConstants.dialogColorDark
                                                  : AppConstants
                                                      .backgroundColor),
                                    ),
                                  ),
                                  subtitle: Text(
                                    getStatusTime(
                                        viewerslist[i]['time'], context, ref),
                                    style: const TextStyle(
                                        height: 1.4,
                                        color: AppConstants.lamatGrey),
                                  ),
                                );
                              }
                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(5, 6, 10, 6),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.26),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  filtered!.entries.toList().indexWhere(
                                              (element) =>
                                                  element.key ==
                                                  viewerslist[i]['phone']) >
                                          0
                                      ? filtered!.entries
                                          .elementAt(filtered!.entries
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.key ==
                                                  viewerslist[i]['phone']))
                                          .value
                                          .toString()
                                      : viewerslist[i]['phone'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(prefs)
                                            ? AppConstants.dialogColorDark
                                            : AppConstants.backgroundColor),
                                  ),
                                ),
                                subtitle: Text(
                                  getStatusTime(
                                      viewerslist[i]['time'], context, ref),
                                  style: const TextStyle(
                                      height: 1.4,
                                      color: AppConstants.lamatGrey),
                                ),
                              );
                            });
                      }),
                ],
              ));
        });
      });
}
