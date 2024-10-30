import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/enum.dart';
import 'package:lamatdating/views/tabs/chat/recents/chat.dart';

import 'package:flutter/material.dart';

Widget getMediaMessage(BuildContext context, bool isBold, var lastMessage) {
  Color textColor = isBold ? darkGrey : lightGrey;
  Color iconColor = isBold ? darkGrey : lightGrey;
  TextStyle style = TextStyle(
    color: textColor,
    fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
  );
  return lastMessage![Dbkeys.messageType] == MessageType.doc.index
      ? Row(
          children: [
            Icon(Icons.file_copy, size: 17.7, color: iconColor),
            const SizedBox(
              width: 4,
            ),
            Text(
              LocaleKeys.doc.tr(),
              style: style,
              maxLines: 1,
            ),
          ],
        )
      : lastMessage[Dbkeys.messageType] == MessageType.audio.index
          ? Row(
              children: [
                Icon(Icons.mic, size: 17.7, color: iconColor),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  LocaleKeys.audio.tr(),
                  style: style,
                  maxLines: 1,
                ),
              ],
            )
          : lastMessage[Dbkeys.messageType] == MessageType.location.index
              ? Row(
                  children: [
                    Icon(Icons.location_on, size: 17.7, color: iconColor),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      LocaleKeys.location.tr(),
                      style: style,
                      maxLines: 1,
                    ),
                  ],
                )
              : lastMessage[Dbkeys.messageType] == MessageType.contact.index
                  ? Row(
                      children: [
                        Icon(Icons.contact_page, size: 17.7, color: iconColor),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          LocaleKeys.contact.tr(),
                          style: style,
                          maxLines: 1,
                        ),
                      ],
                    )
                  : lastMessage[Dbkeys.messageType] == MessageType.video.index
                      ? Row(
                          children: [
                            Icon(Icons.videocam, size: 18, color: iconColor),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              LocaleKeys.video.tr(),
                              style: style,
                              maxLines: 1,
                            ),
                          ],
                        )
                      : lastMessage[Dbkeys.messageType] ==
                              MessageType.image.index
                          ? Row(
                              children: [
                                Icon(Icons.image, size: 16, color: iconColor),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  LocaleKeys.image.tr(),
                                  style: style,
                                  maxLines: 1,
                                ),
                              ],
                            )
                          : const SizedBox();
}
