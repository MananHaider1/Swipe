// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final observerProvider = ChangeNotifierProvider<Observer>((ref) => Observer());

class Observer with ChangeNotifier {
  bool isOngoingCall = false;
  bool isshowerrorlog = true;
  bool isblocknewlogins = false;
  bool iscallsallowed = true;
  DocumentSnapshot<Map<String, dynamic>>? userAppSettingsDoc;
  bool istextmessagingallowed = true;
  bool ismediamessagingallowed = true;
  bool isadmobshow = false;
  String? privacypolicy;
  String? privacypolicyType;
  String? tnc;
  String? tncType;
  String? androidapplink;
  String? iosapplink;
  bool isCallFeatureTotallyHide = IsCallFeatureTotallyHide;
  bool is24hrsTimeformat = Is24hrsTimeformat;
  int groupMemberslimit = GroupMemberslimit;
  int broadcastMemberslimit = BroadcastMemberslimit;
  int statusDeleteAfterInHours = StatusDeleteAfterInHours;
  String feedbackEmail = FeedbackEmail;
  bool isLogoutButtonShowInSettingsPage = IsLogoutButtonShowInSettingsPage;
  bool isAllowCreatingGroups = IsAllowCreatingGroups;
  bool isAllowCreatingBroadcasts = IsAllowCreatingBroadcasts;
  bool isAllowCreatingStatus = IsAllowCreatingStatus;
  bool isPercentProgressShowWhileUploading =
      IsPercentProgressShowWhileUploading;
  int maxFileSizeAllowedInMB = MaxFileSizeAllowedInMB;
  //--
  int maxNoOfFilesInMultiSharing = MaxNoOfFilesInMultiSharing;
  int maxNoOfContactsSelectForForward = MaxNoOfContactsSelectForForward;
  String appShareMessageStringAndroid = '';
  String appShareMessageStringiOS = '';
  bool isCustomAppShareLink = false;
  bool isWebCompatible = false;
  setisOngoingCall(bool v) {
    isOngoingCall = v;
    notifyListeners();
  }

  setObserver(
      {bool? getisshowerrorlog,
      bool? getisblocknewlogins,
      bool? getiscallsallowed,
      bool? getistextmessagingallowed,
      bool? getismediamessagingallowed,
      bool? getisadmobshow,
      String? getprivacypolicy,
      DocumentSnapshot<Map<String, dynamic>>? getuserAppSettingsDoc,
      String? getprivacypolicyType,
      String? gettnc,
      String? gettncType,
      String? getandroidapplink,
      String? getiosapplink,
      bool? getis24hrsTimeformat,
      int? getgroupMemberslimit,
      int? getbroadcastMemberslimit,
      int? getstatusDeleteAfterInHours,
      String? getfeedbackEmail,
      bool? getisLogoutButtonShowInSettingsPage,
      bool? getisCallFeatureTotallyHide,
      bool? getisAllowCreatingGroups,
      bool? getisAllowCreatingBroadcasts,
      bool? getisAllowCreatingStatus,
      bool? getisPercentProgressShowWhileUploading,
      int? getmaxFileSizeAllowedInMB,
      int? getmaxNoOfFilesInMultiSharing,
      int? getmaxNoOfContactsSelectForForward,
      String? getappShareMessageStringAndroid,
      String? getappShareMessageStringiOS,
      bool? getisCustomAppShareLink,
      bool? getisWebCompatible}) {
    isWebCompatible = getisWebCompatible ?? isWebCompatible;
    userAppSettingsDoc = getuserAppSettingsDoc ?? userAppSettingsDoc;
    isshowerrorlog = getisshowerrorlog ?? isshowerrorlog;
    isblocknewlogins = getisblocknewlogins ?? isblocknewlogins;
    iscallsallowed = getiscallsallowed ?? iscallsallowed;

    istextmessagingallowed =
        getistextmessagingallowed ?? istextmessagingallowed;
    ismediamessagingallowed =
        getismediamessagingallowed ?? ismediamessagingallowed;
    isadmobshow = getisadmobshow ?? isadmobshow;
    privacypolicy = getprivacypolicy ?? privacypolicy;
    privacypolicyType = getprivacypolicyType ?? privacypolicyType;
    tnc = gettnc ?? tnc;
    tncType = gettncType ?? tncType;
    androidapplink = getandroidapplink ?? androidapplink;
    iosapplink = getiosapplink ?? iosapplink;

    is24hrsTimeformat = getis24hrsTimeformat ?? is24hrsTimeformat;
    groupMemberslimit = getgroupMemberslimit ?? groupMemberslimit;
    broadcastMemberslimit = getbroadcastMemberslimit ?? broadcastMemberslimit;
    statusDeleteAfterInHours =
        getstatusDeleteAfterInHours ?? statusDeleteAfterInHours;
    feedbackEmail = getfeedbackEmail ?? feedbackEmail;
    isLogoutButtonShowInSettingsPage =
        getisLogoutButtonShowInSettingsPage ?? isLogoutButtonShowInSettingsPage;
    isCallFeatureTotallyHide =
        getisCallFeatureTotallyHide ?? isCallFeatureTotallyHide;
    isAllowCreatingGroups = getisAllowCreatingGroups ?? isAllowCreatingGroups;
    isAllowCreatingBroadcasts =
        getisAllowCreatingBroadcasts ?? isAllowCreatingBroadcasts;
    isAllowCreatingStatus = getisAllowCreatingStatus ?? isAllowCreatingStatus;
    isPercentProgressShowWhileUploading =
        getisPercentProgressShowWhileUploading ??
            isPercentProgressShowWhileUploading;
    maxFileSizeAllowedInMB =
        getmaxFileSizeAllowedInMB ?? maxFileSizeAllowedInMB;
    maxNoOfFilesInMultiSharing =
        getmaxNoOfFilesInMultiSharing ?? maxNoOfFilesInMultiSharing;
    maxNoOfContactsSelectForForward =
        getmaxNoOfContactsSelectForForward ?? maxNoOfContactsSelectForForward;
    appShareMessageStringAndroid =
        getappShareMessageStringAndroid ?? appShareMessageStringAndroid;
    appShareMessageStringiOS =
        getappShareMessageStringiOS ?? appShareMessageStringiOS;
    isCustomAppShareLink = getisCustomAppShareLink ?? isCustomAppShareLink;
    notifyListeners();
  }
}

// initial default key values for null value in database---
const IsCallFeatureTotallyHide =
    false; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const Is24hrsTimeformat =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int GroupMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int BroadcastMemberslimit =
    500; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int StatusDeleteAfterInHours =
    24; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsLogoutButtonShowInSettingsPage =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const FeedbackEmail =
    ''; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingGroups =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingBroadcasts =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsAllowCreatingStatus =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const IsPercentProgressShowWhileUploading =
    true; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxFileSizeAllowedInMB =
    60; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfFilesInMultiSharing =
    10; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const int MaxNoOfContactsSelectForForward =
    7; // This is just the initial default value.  Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.

//---- ####### Below Details Not neccsarily required unless you are using the Admin App:
const ConnectWithAdminApp =
    true; // If you are planning to use the admin app, set it to "true". We recommend it to always set it to true for Advance features whether you use the admin app or not.
const dynamic RateAppUrlAndroid =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const dynamic RateAppUrlIOS =
    null; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const TERMS_CONDITION_URL =
    'https://www.freeprivacypolicy.com/live/33966b6e-ca53-4263-a639-ede09fd6401b'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
const PRIVACY_POLICY_URL =
    'https://www.freeprivacypolicy.com/live/33966b6e-ca53-4263-a639-ede09fd6401b'; // Once the database is written, It can only be changed from Admin App OR directly inside Firestore database - appsettings/userapp document.
//--