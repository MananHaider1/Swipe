import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/Broadcast/broadcast_chat_page.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/tabs/chat/recents/chat.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/lm_time.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/late_load.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget broadcastMessageTile(
    {required BuildContext context,
    required WidgetRef ref,
    required List<Map<String, dynamic>> streamDocSnap,
    required int index,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel}) {
  showMenuForBroadcastChat(
    contextForDialog,
    var broadcastDoc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);

    tiles.add(Builder(
        builder: (BuildContext popable) => ListTile(
            dense: true,
            leading: const Icon(Icons.delete, size: 22),
            title: Text(
              LocaleKeys.deletebroadcast.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
              ),
            ),
            onTap: () async {
              Navigator.of(popable).pop();
              unawaited(showDialog(
                builder: (BuildContext context) {
                  return Builder(
                      builder: (BuildContext dialogcontext) => AlertDialog(
                            backgroundColor: Teme.isDarktheme(prefs)
                                ? AppConstants.dialogColorDark
                                : AppConstants.backgroundColor,
                            title: Text(
                              LocaleKeys.deletebroadcast.tr(),
                              style: TextStyle(
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Teme.isDarktheme(prefs)
                                        ? AppConstants.dialogColorDark
                                        : AppConstants.backgroundColor),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  LocaleKeys.cancel.tr(),
                                  style: const TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontSize: 18),
                                ),
                                onPressed: () {
                                  Navigator.of(dialogcontext).pop();
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  LocaleKeys.delete.tr(),
                                  style: const TextStyle(
                                      color: AppConstants.lamatREDbuttonColor,
                                      fontSize: 18),
                                ),
                                onPressed: () async {
                                  String broadcastID =
                                      broadcastDoc[Dbkeys.broadcastID];
                                  Navigator.of(dialogcontext).pop();

                                  Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () async {
                                    await FirebaseFirestore.instance
                                        .collection(
                                            DbPaths.collectionbroadcasts)
                                        .doc(broadcastID)
                                        .get()
                                        .then((doc) async {
                                      await doc.reference.delete();
                                      //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                                    });
                                  });
                                },
                              )
                            ],
                          ));
                },
                context: context,
              ));
            })));

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(
              backgroundColor: Teme.isDarktheme(prefs)
                  ? AppConstants.dialogColorDark
                  : AppConstants.backgroundColor,
              children: tiles);
        });
  }

  return streamLoadCollections(
      stream: FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(streamDocSnap[index][Dbkeys.broadcastID])
          .collection(DbPaths.collectionbroadcastsChats)
          .orderBy(Dbkeys.timestamp, descending: true)
          .limit(1)
          .snapshots(),
      placeholder: Column(
        children: [
          ListTile(
            onLongPress: () {
              showMenuForBroadcastChat(context, streamDocSnap[index]);
            },
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            leading: customCircleAvatarBroadcast(
                url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                radius: 22),
            title: Text(
              streamDocSnap[index][Dbkeys.broadcastNAME],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
                fontWeight: FontWeight.w500,
                fontSize: 16.4,
              ),
            ),
            subtitle: Text(
              '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${LocaleKeys.recipients.tr()}',
              style: const TextStyle(
                color: AppConstants.lamatGrey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BroadcastChatPage(
                          model: cachedModel,
                          prefs: prefs,
                          currentUserno: currentUserNo,
                          broadcastID: streamDocSnap[index]
                              [Dbkeys.broadcastID])));
            },
          ),
          const Divider(height: 0),
        ],
      ),
      noDataWidget: Column(
        children: [
          ListTile(
            onLongPress: () {
              showMenuForBroadcastChat(context, streamDocSnap[index]);
            },
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            leading: customCircleAvatarBroadcast(
                url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                radius: 22),
            title: Text(
              streamDocSnap[index][Dbkeys.broadcastNAME],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor),
                fontWeight: FontWeight.bold,
                fontSize: 16.4,
              ),
            ),
            subtitle: Text(
              '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${LocaleKeys.recipients.tr()}',
              style: const TextStyle(
                color: AppConstants.lamatGrey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BroadcastChatPage(
                          model: cachedModel,
                          prefs: prefs,
                          currentUserno: currentUserNo,
                          broadcastID: streamDocSnap[index]
                              [Dbkeys.broadcastID])));
            },
          ),
          const Divider(height: 0),
        ],
      ),
      onfetchdone: (events) {
        return Column(
          children: [
            ListTile(
              onLongPress: () {
                showMenuForBroadcastChat(context, streamDocSnap[index]);
              },
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              leading: customCircleAvatarBroadcast(
                  url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                  radius: 22),
              title: Text(
                streamDocSnap[index][Dbkeys.broadcastNAME],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
                  fontWeight: FontWeight.w500,
                  fontSize: 16.4,
                ),
              ),
              subtitle: Text(
                '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${LocaleKeys.recipients.tr()}',
                style: TextStyle(
                  color: lightGrey,
                  fontSize: 14,
                ),
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      getLastMessageTime(context, currentUserNo,
                          events.last[Dbkeys.timestamp], ref),
                      style: TextStyle(
                          color: lightGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(
                    height: 23,
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BroadcastChatPage(
                            model: cachedModel,
                            prefs: prefs,
                            currentUserno: currentUserNo,
                            broadcastID: streamDocSnap[index]
                                [Dbkeys.broadcastID])));
              },
            ),
            const Divider(height: 0),
          ],
        );
      });
}
