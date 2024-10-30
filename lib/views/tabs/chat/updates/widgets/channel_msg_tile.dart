// ignore_for_file: use_build_context_synchronously, empty_catches

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/tabs/chat/recents/chat.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/lm_time.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/m_msg.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/late_load.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/views/tabs/chat/updates/Channels/channel_chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget channelMessageTile(
    {required BuildContext context,
    required List<Map<String, dynamic>> streamDocSnap,
    required int index,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel,
    required int unRead,
    required WidgetRef ref,
    required bool isGroupChatMuted}) {
  showMenuForGroupChat(contextForDialog, var groupDoc) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(Builder(
        builder: (BuildContext popable) => ListTile(
            dense: true,
            leading: Icon(isGroupChatMuted ? Icons.volume_up : Icons.volume_off,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
                size: 22),
            title: Text(
              isGroupChatMuted
                  ? LocaleKeys.unmutenotifications.tr()
                  : LocaleKeys.mutenotifications.tr(),
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

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectiongroups)
                  .doc(streamDocSnap[index][Dbkeys.groupID])
                  .update({
                Dbkeys.groupMUTEDMEMBERS: isGroupChatMuted
                    ? FieldValue.arrayRemove([currentUserNo])
                    : FieldValue.arrayUnion([currentUserNo]),
              }).then((value) async {
                if (isGroupChatMuted == true) {
                  await FirebaseMessaging.instance
                      .subscribeToTopic(
                          "GROUP${streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    FirebaseFirestore.instance
                        .collection(DbPaths.collectiongroups)
                        .doc(streamDocSnap[index][Dbkeys.groupID])
                        .update({
                      Dbkeys.groupMUTEDMEMBERS: !isGroupChatMuted
                          ? FieldValue.arrayRemove([currentUserNo])
                          : FieldValue.arrayUnion([currentUserNo]),
                    });
                  });
                } else {
                  await FirebaseMessaging.instance
                      .unsubscribeFromTopic(
                          "GROUP${streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, streamDocSnap[index][Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                      .catchError((err) {
                    FirebaseFirestore.instance
                        .collection(DbPaths.collectiongroups)
                        .doc(streamDocSnap[index][Dbkeys.groupID])
                        .update({
                      Dbkeys.groupMUTEDMEMBERS: !isGroupChatMuted
                          ? FieldValue.arrayRemove([currentUserNo])
                          : FieldValue.arrayUnion([currentUserNo]),
                    });
                  });
                }
              });
            })));
    if (groupDoc[Dbkeys.groupCREATEDBY] == currentUserNo) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(
                Icons.delete,
                size: 22,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
              ),
              title: Text(
                LocaleKeys.deletegroup.tr(),
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
                                LocaleKeys.deletegroup.tr(),
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
                                    Navigator.of(dialogcontext).pop();

                                    Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () async {
                                      String groupId = groupDoc[Dbkeys.groupID];
                                      await FirebaseFirestore.instance
                                          .collection(DbPaths.collectiongroups)
                                          .doc(groupId)
                                          .get()
                                          .then((doc) async {
                                        await FirebaseFirestore.instance
                                            .collection(DbPaths
                                                .collectiontemptokensforunsubscribe)
                                            .doc(groupId)
                                            .delete();
                                        await doc.reference.delete();
                                      });

                                      //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                                    });
                                  },
                                )
                              ],
                            ));
                  },
                  context: context,
                ));
              })));
    } else {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(
                Icons.remove_circle_outlined,
                size: 22,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Teme.isDarktheme(prefs)
                        ? AppConstants.dialogColorDark
                        : AppConstants.backgroundColor),
              ),
              title: Text(
                LocaleKeys.leavegroup.tr(),
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
                                LocaleKeys.leavegroup.tr(),
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
                                    LocaleKeys.leave.tr(),
                                    style: const TextStyle(
                                        color: AppConstants.lamatREDbuttonColor,
                                        fontSize: 18),
                                  ),
                                  onPressed: () async {
                                    Navigator.of(dialogcontext).pop();
                                    Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () async {
                                      String groupId = groupDoc[Dbkeys.groupID];
                                      DateTime time = DateTime.now();
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection(DbPaths
                                                .collectiontemptokensforunsubscribe)
                                            .doc(currentUserNo)
                                            .delete();
                                      } catch (err) {}
                                      await FirebaseFirestore.instance
                                          .collection(DbPaths
                                              .collectiontemptokensforunsubscribe)
                                          .doc(currentUserNo)
                                          .set({
                                        Dbkeys.groupIDfiltered: groupId
                                            .replaceAll(RegExp('-'), '')
                                            .substring(
                                                1,
                                                groupId
                                                    .replaceAll(RegExp('-'), '')
                                                    .toString()
                                                    .length),
                                        Dbkeys.notificationTokens: cachedModel
                                                    .currentUser![
                                                Dbkeys.notificationTokens] ??
                                            [],
                                        'type': 'unsubscribe'
                                      }).then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection(
                                                DbPaths.collectiongroups)
                                            .doc(groupId)
                                            .update(groupDoc[
                                                        Dbkeys.groupADMINLIST]
                                                    .contains(currentUserNo)
                                                ? {
                                                    Dbkeys.groupADMINLIST:
                                                        FieldValue.arrayRemove(
                                                            [currentUserNo]),
                                                    Dbkeys.groupMEMBERSLIST:
                                                        FieldValue.arrayRemove(
                                                            [currentUserNo]),
                                                    currentUserNo:
                                                        FieldValue.delete(),
                                                    '$currentUserNo-joinedOn':
                                                        FieldValue.delete()
                                                  }
                                                : {
                                                    Dbkeys.groupMEMBERSLIST:
                                                        FieldValue.arrayRemove(
                                                            [currentUserNo]),
                                                    currentUserNo:
                                                        FieldValue.delete(),
                                                    '$currentUserNo-joinedOn':
                                                        FieldValue.delete()
                                                  });

                                        await FirebaseFirestore.instance
                                            .collection(
                                                DbPaths.collectiongroups)
                                            .doc(groupId)
                                            .collection(
                                                DbPaths.collectiongroupChats)
                                            .doc(
                                                '${time.millisecondsSinceEpoch}--$groupId')
                                            .set({
                                          Dbkeys.groupmsgCONTENT:
                                              '$currentUserNo ${LocaleKeys.leftthegroup.tr()}',
                                          Dbkeys.groupmsgLISToptional: [],
                                          Dbkeys.groupmsgTIME:
                                              time.millisecondsSinceEpoch,
                                          Dbkeys.groupmsgSENDBY: currentUserNo,
                                          Dbkeys.groupmsgISDELETED: false,
                                          Dbkeys.groupmsgTYPE: Dbkeys
                                              .groupmsgTYPEnotificationUserLeft,
                                        });

                                        try {
                                          await FirebaseFirestore.instance
                                              .collection(DbPaths
                                                  .collectiontemptokensforunsubscribe)
                                              .doc(currentUserNo)
                                              .delete();
                                        } catch (err) {}
                                      }).catchError((err) {
                                        // Lamat.toast(
                                        //     getTranslated(context,
                                        //         'unabletoleavegrp'));
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
    }
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
        .collection(DbPaths.collectiongroups)
        .doc(streamDocSnap[index][Dbkeys.groupID])
        .collection(DbPaths.collectiongroupChats)
        .where(Dbkeys.groupmsgTYPE, whereIn: [
          MessageType.text.index,
          MessageType.image.index,
          MessageType.doc.index,
          MessageType.audio.index,
          MessageType.video.index,
          MessageType.contact.index,
          MessageType.location.index
        ])
        .orderBy(Dbkeys.timestamp, descending: true)
        .limit(1)
        .snapshots(),
    placeholder: Column(
      children: [
        ListTile(
            onLongPress: () {
              showMenuForGroupChat(context, streamDocSnap[index]);
            },
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            leading: customCircleAvatarGroup(
                url: streamDocSnap[index][Dbkeys.groupPHOTOURL], radius: 22),
            title: Text(
              streamDocSnap[index][Dbkeys.groupNAME],
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
              '${streamDocSnap[index][Dbkeys.groupMEMBERSLIST].length} ${LocaleKeys.followers.tr()}',
              style: TextStyle(
                color: lightGrey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              streamDocSnap != []
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChannelChatPage(
                              isCurrentUserMuted: isGroupChatMuted,
                              isSharingIntentForwarded: false,
                              model: cachedModel,
                              prefs: prefs,
                              joinedTime: streamDocSnap[index]
                                      [Dbkeys.groupCREATEDON]
                                  .toDate()
                                  .millisecondsSinceEpoch,

                              // streamDocSnap[index][streamDocSnap[index][
                              //     Dbkeys.groupCREATEDBY]+"-joinedOn"],
                              currentUserno: currentUserNo,
                              groupID: streamDocSnap[index][Dbkeys.groupID])))
                  : {};
            },
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                unRead == 0
                    ? const SizedBox()
                    : Container(
                        padding: const EdgeInsets.all(7.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.lamatGreenColor400,
                        ),
                        child: Text(unRead.toString(),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(
                  height: 3,
                ),
              ],
            )),
        const Divider(
          height: 0,
        ),
      ],
    ),
    noDataWidget: Column(
      children: [
        ListTile(
            onLongPress: () {
              showMenuForGroupChat(context, streamDocSnap[index]);
            },
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            leading: customCircleAvatarGroup(
                url: streamDocSnap[index][Dbkeys.groupPHOTOURL], radius: 22),
            title: Text(
              streamDocSnap[index][Dbkeys.groupNAME],
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
              '${streamDocSnap[index][Dbkeys.groupMEMBERSLIST].length} ${LocaleKeys.followers.tr()}',
              style: TextStyle(
                color: lightGrey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChannelChatPage(
                          isCurrentUserMuted: isGroupChatMuted,
                          isSharingIntentForwarded: false,
                          model: cachedModel,
                          prefs: prefs,
                          joinedTime: streamDocSnap[index]
                                  [Dbkeys.groupCREATEDON]
                              .toDate()
                              .millisecondsSinceEpoch,

                          //  streamDocSnap[index]
                          //     ['$currentUserNo-joinedOn'],
                          currentUserno: currentUserNo,
                          groupID: streamDocSnap[index][Dbkeys.groupID])));
            },
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                unRead == 0
                    ? const SizedBox()
                    : Container(
                        padding: const EdgeInsets.all(7.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.lamatGreenColor400,
                        ),
                        child: Text(unRead.toString(),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                const SizedBox(
                  height: 3,
                ),
              ],
            )),
        const Divider(
          height: 0,
        ),
      ],
    ),
    onfetchdone: (messages) {
      var lastMessage = messages.last;

      return Column(
        children: [
          ListTile(
              onLongPress: () {
                showMenuForGroupChat(context, streamDocSnap[index]);
              },
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              leading: customCircleAvatarGroup(
                  url: streamDocSnap[index][Dbkeys.groupPHOTOURL], radius: 22),
              title: Text(
                streamDocSnap[index][Dbkeys.groupNAME],
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
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  lastMessage[Dbkeys.groupmsgSENDBY] == currentUserNo
                      ? const SizedBox()
                      : Consumer(builder: (context, ref, child) {
                          return FutureBuilder<LocalUserData?>(
                              future: ref
                                  .watch(smartContactProvider)
                                  .fetchUserDataFromnLocalOrServer(prefs,
                                      lastMessage[Dbkeys.groupmsgSENDBY]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<LocalUserData?> snapshot) {
                                if (snapshot.hasData) {
                                  return Text("${snapshot.data!.name}:  ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: unRead > 0
                                            ? Teme.isDarktheme(prefs)
                                                ? const Color(0xff9aacb5)
                                                : darkGrey
                                            : lightGrey,
                                      ));
                                }
                                return Text(
                                    "${lastMessage[Dbkeys.groupmsgSENDBY]}:  ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: unRead > 0
                                          ? Teme.isDarktheme(prefs)
                                              ? const Color(0xff9aacb5)
                                              : darkGrey
                                          : lightGrey,
                                    ));
                              });
                        }),
                  lastMessage[Dbkeys.groupmsgISDELETED] == true
                      ? Text(LocaleKeys.msgdeleted.tr(),
                          style: TextStyle(
                              fontSize: 14,
                              color: unRead > 0
                                  ? Teme.isDarktheme(prefs)
                                      ? const Color(0xff9aacb5)
                                      : darkGrey.withOpacity(0.4)
                                  : lightGrey.withOpacity(0.4),
                              fontStyle: FontStyle.italic))
                      : lastMessage[Dbkeys.groupmsgTYPE] ==
                              MessageType.text.index
                          ? SizedBox(
                              width: lastMessage[Dbkeys.groupmsgSENDBY] ==
                                      currentUserNo
                                  ? MediaQuery.of(context).size.width / 2.9
                                  : MediaQuery.of(context).size.width / 4.2,
                              child: Text(lastMessage[Dbkeys.groupmsgCONTENT],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: unRead > 0
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: unRead > 0
                                          ? Teme.isDarktheme(prefs)
                                              ? const Color(0xff9aacb5)
                                              : darkGrey
                                          : lightGrey)),
                            )
                          : getMediaMessage(context, false, lastMessage),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChannelChatPage(
                            isCurrentUserMuted: isGroupChatMuted,
                            isSharingIntentForwarded: false,
                            model: cachedModel,
                            prefs: prefs,
                            joinedTime: streamDocSnap[index]
                                    [Dbkeys.groupCREATEDON]
                                .toDate()
                                .millisecondsSinceEpoch,

                            // streamDocSnap[index]
                            //     ['$currentUserNo-joinedOn'],
                            currentUserno: currentUserNo,
                            groupID: streamDocSnap[index][Dbkeys.groupID])));
              },
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  lastMessage == {} || lastMessage == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            getLastMessageTime(context, currentUserNo,
                                lastMessage[Dbkeys.timestamp], ref),
                            style: TextStyle(
                                color: unRead != 0
                                    ? AppConstants.lamatGreenColor500
                                    : lightGrey,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isGroupChatMuted
                          ? Icon(
                              Icons.volume_off,
                              size: 20,
                              color: lightGrey.withOpacity(0.5),
                            )
                          : const Icon(
                              Icons.volume_up,
                              size: 20,
                              color: Colors.transparent,
                            ),
                      unRead == 0
                          ? const SizedBox()
                          : Container(
                              margin: EdgeInsets.only(
                                  left: isGroupChatMuted ? 7 : 0),
                              padding: const EdgeInsets.all(7.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppConstants.lamatGreenColor400,
                              ),
                              child: Text(unRead.toString(),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                    ],
                  ),
                ],
              )),
          const Divider(
            height: 0,
          ),
        ],
      );
    },
  );
}
