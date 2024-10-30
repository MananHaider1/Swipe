// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/other_users_provider.dart';
// import 'package:lamatdating/providers/user_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/call_history/call_history.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/chat.dart';
import 'package:lamatdating/views/tabs/chat/recents/chat.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/lm_time.dart';
import 'package:lamatdating/views/tabs/chat/recents/widgets/m_msg.dart';
import 'package:lamatdating/providers/smart_contact_provider.dart';

import 'package:lamatdating/utils/alias.dart';
import 'package:lamatdating/utils/chat_controller.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/unawaited.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/utils/late_load.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget getPersonalMessageTile(
    {required BuildContext context,
    required WidgetRef ref,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel,
    var lastMessage,
    required var peer,
    required int unRead,
    peerSeenStatus,
    required var isPeerChatMuted,
    readFunction}) {
  final otherUserProfile = ref
      .watch(otherUserProfileFutureProvider(peer[Dbkeys.phone].toString()))
      .value;
  //-- context menu with Set Alias & Delete Chat tile
  showMenuForOneToOneChat(
      contextForDialog, Map<String, dynamic> targetUser, bool isMuted) {
    List<Widget> tiles = List.from(<Widget>[]);

    tiles.add(Builder(
        builder: (BuildContext popable) => ListTile(
            dense: true,
            leading: const Icon(FontAwesomeIcons.userEdit, size: 18),
            title: Text(
              LocaleKeys.setalias.tr(),
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

              showDialog(
                  context: context,
                  builder: (context) {
                    return AliasForm(targetUser, cachedModel, prefs);
                  });
            })));
    tiles.add(Builder(
        builder: (BuildContext popable) => ListTile(
            dense: true,
            leading:
                Icon(isMuted ? Icons.volume_up : Icons.volume_off, size: 22),
            title: Text(
              isMuted
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

              FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(Lamat.getChatId(currentUserNo, peer[Dbkeys.phone]))
                  .update({
                "$currentUserNo-muted": !isMuted,
              });
            })));
    if (IsShowDeleteChatOption == true) {
      tiles.add(Builder(
          builder: (BuildContext tilecontext) => ListTile(
              dense: true,
              leading: const Icon(Icons.delete, size: 22),
              title: Text(
                LocaleKeys.deleteChat.tr(),
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
                Navigator.of(tilecontext).pop();
                unawaited(showDialog(
                  builder: (BuildContext context) {
                    return Builder(
                        builder: (BuildContext popable) => AlertDialog(
                              backgroundColor: Teme.isDarktheme(prefs)
                                  ? AppConstants.dialogColorDark
                                  : AppConstants.backgroundColor,
                              title: Text(
                                LocaleKeys.deleteChat.tr(),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(prefs)
                                          ? AppConstants.dialogColorDark
                                          : AppConstants.backgroundColor),
                                ),
                              ),
                              content: Text(
                                LocaleKeys.suredelete.tr(),
                                style: TextStyle(
                                  color: pickTextColorBasedOnBgColorAdvanced(
                                          Teme.isDarktheme(prefs)
                                              ? AppConstants.dialogColorDark
                                              : AppConstants.backgroundColor)
                                      .withOpacity(0.6),
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
                                    Navigator.of(context).pop();
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
                                    Navigator.of(popable).pop();
                                    String chatId = Lamat.getChatId(
                                        currentUserNo,
                                        targetUser[Dbkeys.phone]);

                                    if (targetUser[Dbkeys.phone] != null) {
                                      await FirebaseFirestore.instance
                                          .collection(
                                              DbPaths.collectionmessages)
                                          .doc(chatId)
                                          .delete()
                                          .then((v) async {
                                        await FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(currentUserNo)
                                            .collection(Dbkeys.chatsWith)
                                            .doc(Dbkeys.chatsWith)
                                            .set({
                                          targetUser[Dbkeys.phone]:
                                              FieldValue.delete(),
                                        }, SetOptions(merge: true));
                                        // print('DELETED CHAT DOC 1');

                                        await FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(targetUser[Dbkeys.phone])
                                            .collection(Dbkeys.chatsWith)
                                            .doc(Dbkeys.chatsWith)
                                            .set({
                                          currentUserNo: FieldValue.delete(),
                                        }, SetOptions(merge: true));
                                      }).then((value) {});
                                    } else {
                                      Lamat.toast(LocaleKeys.errorDelete.tr());
                                    }
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

  return Column(
    children: [
      ListTile(
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          onLongPress: () {
            showMenuForOneToOneChat(context, peer, isPeerChatMuted);
          },
          leading: Stack(
            children: [
              customCircleAvatar(url: peer[Dbkeys.photoUrl], radius: 22),
              peer[Dbkeys.lastSeen] == true ||
                      peer[Dbkeys.lastSeen] == currentUserNo
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Teme.isDarktheme(prefs)
                            ? AppConstants.backgroundColorDark
                            : Colors.white,
                        radius: 8,
                        child: const CircleAvatar(
                          backgroundColor: AppConstants.lamatGreenColor400,
                          radius: 6,
                        ),
                      ))
                  : const SizedBox()
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              peer[Dbkeys.lastSeen] == currentUserNo
                  ? Text(
                      LocaleKeys.typing.tr(),
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: lightGrey,
                          fontSize: 14),
                    )
                  : lastMessage == null || lastMessage == {}
                      ? const SizedBox(
                          width: 0,
                        )
                      : lastMessage![Dbkeys.from] != currentUserNo
                          ? const SizedBox()
                          : lastMessage![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? readFunction == "" || readFunction == null
                                  ? const SizedBox(
                                      width: 0,
                                    )
                                  : futureLoadString(
                                      future: readFunction,
                                      placeholder: const SizedBox(
                                        width: 0,
                                      ),
                                      onfetchdone: (message) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 6),
                                          child: Icon(
                                            Icons.done_all,
                                            size: 15,
                                            color: peerSeenStatus == null
                                                ? lightGrey
                                                : lastMessage == null ||
                                                        lastMessage == {}
                                                    ? lightGrey
                                                    : peerSeenStatus is bool
                                                        ? Colors.lightBlue
                                                        : peerSeenStatus >
                                                                lastMessage[Dbkeys
                                                                    .timestamp]
                                                            ? Colors.lightBlue
                                                            : lightGrey,
                                          ),
                                        );
                                      })
                              : Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.done_all,
                                    size: 15,
                                    color: peerSeenStatus == null
                                        ? lightGrey
                                        : lastMessage == null ||
                                                lastMessage == {}
                                            ? lightGrey
                                            : peerSeenStatus is int
                                                ? Colors.lightBlue
                                                : peerSeenStatus ??
                                                        lastMessage?[
                                                            Dbkeys.timestamp] ??
                                                        1736453074 >
                                                            lastMessage[Dbkeys
                                                                .timestamp]
                                                    ? Colors.lightBlue
                                                    : lightGrey,
                                  ),
                                ),
              peer[Dbkeys.lastSeen] == currentUserNo
                  ? const SizedBox()
                  : lastMessage == null || lastMessage == {}
                      ? const SizedBox()
                      : (currentUserNo == lastMessage[Dbkeys.from] &&
                                      lastMessage![Dbkeys.hasSenderDeleted]) ==
                                  true ||
                              (currentUserNo != lastMessage[Dbkeys.from] &&
                                  lastMessage![Dbkeys.hasRecipientDeleted])
                          ? Text(LocaleKeys.msgdeleted.tr(),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: unRead > 0
                                      ? Teme.isDarktheme(prefs)
                                          ? const Color(0xff9aacb5)
                                          : darkGrey.withOpacity(0.4)
                                      : lightGrey.withOpacity(0.4),
                                  fontStyle: FontStyle.italic))
                          : lastMessage![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? readFunction == "" || readFunction == null
                                  ? const SizedBox()
                                  : Expanded(
                                      child: SizedBox(
                                        child: futureLoadString(
                                            future: readFunction,
                                            placeholder: const Text(""),
                                            onfetchdone: (message) {
                                              return Text(message,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: unRead > 0
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: unRead > 0
                                                          ? Teme.isDarktheme(
                                                                  prefs)
                                                              ? const Color(
                                                                  0xff9aacb5)
                                                              : darkGrey
                                                          : lightGrey));
                                            }),
                                      ),
                                    )
                              : getMediaMessage(
                                  context, unRead > 0, lastMessage),
            ],
          ),
          title: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: IsShowUserFullNameAsSavedInYourContacts == false
                  ? Text(
                      Lamat.getNickname(peer) ?? "",
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
                    )
                  : Consumer(builder: (context, ref, child) {
                      // _filtered = availableContacts.filtered;
                      return FutureBuilder<LocalUserData?>(
                          future: ref
                              .watch(smartContactProvider)
                              .fetchUserDataFromnLocalOrServer(
                                  prefs, peer[Dbkeys.phone]),
                          builder: (BuildContext context,
                              AsyncSnapshot<LocalUserData?> snapshot3) {
                            if (snapshot3.hasData && snapshot3.data != null) {
                              return Text(
                                snapshot3.data!.name,
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
                              );
                            }
                            return Text(
                              Lamat.getNickname(peer) ?? "",
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
                            );
                          });
                    })),
          onTap: () {
            if (cachedModel.currentUser![Dbkeys.locked] != null &&
                cachedModel.currentUser![Dbkeys.locked]
                    .contains(peer[Dbkeys.phone])) {
              if (prefs.getString(Dbkeys.isPINsetDone) != currentUserNo ||
                  prefs.getString(Dbkeys.isPINsetDone) == null) {
                ChatController.unlockChat(
                    currentUserNo, peer[Dbkeys.phone] as String?);
                !Responsive.isDesktop(context)
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatScreen(
                                isSharingIntentForwarded: false,
                                prefs: prefs,
                                unread: unRead,
                                model: cachedModel,
                                currentUserNo: currentUserNo,
                                peerNo: peer[Dbkeys.phone] as String?)))
                    : ref
                        .read(arrangementProviderExtend.notifier)
                        .setArrangement(ChatScreen(
                            isSharingIntentForwarded: false,
                            prefs: prefs,
                            unread: unRead,
                            model: cachedModel,
                            currentUserNo: currentUserNo,
                            peerNo: peer[Dbkeys.phone] as String?));
              } else {
                NavigatorState state = Navigator.of(context);
                ChatController.authenticate(
                    cachedModel, LocaleKeys.authneededchat.tr(),
                    state: state,
                    shouldPop: false,
                    type: Lamat.getAuthenticationType(false, cachedModel),
                    prefs: prefs, onSuccess: () {
                  !Responsive.isDesktop(context)
                      ? state.push(MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              isSharingIntentForwarded: false,
                              prefs: prefs,
                              unread: unRead,
                              model: cachedModel,
                              currentUserNo: currentUserNo,
                              peerNo: peer[Dbkeys.phone] as String?)))
                      : ref
                          .read(arrangementProviderExtend.notifier)
                          .setArrangement(ChatScreen(
                              isSharingIntentForwarded: false,
                              prefs: prefs,
                              unread: unRead,
                              model: cachedModel,
                              currentUserNo: currentUserNo,
                              peerNo: peer[Dbkeys.phone] as String?));
                });
              }
            } else {
              !Responsive.isDesktop(context)
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              isSharingIntentForwarded: false,
                              prefs: prefs,
                              unread: unRead,
                              model: cachedModel,
                              currentUserNo: currentUserNo,
                              peerNo: peer[Dbkeys.phone] as String?)))
                  : {
                      updateCurrentIndex(ref, 10),
                      ref
                          .read(arrangementProvider.notifier)
                          .setArrangement(UserDetailsPage(
                            user: otherUserProfile!,
                          )),
                      ref
                          .read(arrangementProviderExtend.notifier)
                          .setArrangement(ChatScreen(
                              isSharingIntentForwarded: false,
                              prefs: prefs,
                              unread: unRead,
                              model: cachedModel,
                              currentUserNo: currentUserNo,
                              peerNo: peer[Dbkeys.phone] as String?))
                    };
            }
          },
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
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
                  isPeerChatMuted
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
                          margin:
                              EdgeInsets.only(left: isPeerChatMuted ? 7 : 0),
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
}
