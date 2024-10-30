import 'package:easy_localization/easy_localization.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/database_keys.dart';

import 'package:flutter/material.dart';

Map getTranslateNotificationStringsMap(BuildContext context) {
  Map map = {
    Dbkeys.notificationStringNewTextMessage: LocaleKeys.ntm.tr(),
    Dbkeys.notificationStringNewImageMessage: LocaleKeys.nim.tr(),
    Dbkeys.notificationStringNewVideoMessage: LocaleKeys.nvm.tr(),
    Dbkeys.notificationStringNewAudioMessage: LocaleKeys.nam.tr(),
    Dbkeys.notificationStringNewContactMessage: LocaleKeys.ncm.tr(),
    Dbkeys.notificationStringNewDocumentMessage: LocaleKeys.ndm.tr(),
    Dbkeys.notificationStringNewLocationMessage: LocaleKeys.nlm.tr(),
    Dbkeys.notificationStringNewIncomingAudioCall: LocaleKeys.niac.tr(),
    Dbkeys.notificationStringNewIncomingVideoCall: LocaleKeys.nivc.tr(),
    Dbkeys.notificationStringCallEnded: LocaleKeys.ce.tr(),
    Dbkeys.notificationStringMissedCall: LocaleKeys.mc.tr(),
    Dbkeys.notificationStringAcceptOrRejectCall: LocaleKeys.aorc.tr(),
    Dbkeys.notificationStringCallRejected: LocaleKeys.cr.tr(),
  };
  return map;
}
