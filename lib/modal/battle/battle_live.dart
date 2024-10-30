import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/stream_goal_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';

class LiveBattleInvite {
  String? _channelId;
  String? inviteePhone;
  UserProfileModel? _userProfile;
  GoalModel? _goalModel;
  bool? _isHost;
  bool? _isCoHost;
  String? _status;

  LiveBattleInvite(
      {String? channelId,
      String? inviteePhone,
      UserProfileModel? userProfile,
      GoalModel? goalModel,
      bool? isHost,
      bool? isCoHost,
      String? status}) {
    _channelId = channelId;
    _userProfile = userProfile!;
    _goalModel = goalModel;
    _isHost = isHost!;
    _isCoHost = isCoHost!;
    _status = status;
  }

  Map<String, dynamic> toJson() {
    return {
      "channelId": _channelId,
      "inviteePhone": inviteePhone,
      "isHost": _isHost,
      "isCoHost": _isCoHost,
      "userProfile": _userProfile,
      "goalModel": _goalModel,
      "status": _status
    };
  }

  LiveBattleInvite.fromJson(Map<String, dynamic>? json) {
    if (json?["goalModel"] != null) {
      _goalModel = GoalModel.fromJson(json?["goalModel"]);
    }

    if (json?["userProfile"] != null) {
      _userProfile = UserProfileModel.fromJson(json?["userProfile"]);
    }

    _isHost = json?["isHost"];
    _isCoHost = json?["isCoHost"];

    _channelId = json?["channelId"];

    inviteePhone = json?["inviteePhone"];

    _status = json?["status"];
  }

  Map<String, dynamic> toFireStore() {
    return {
      "channelId": _channelId,
      "inviteePhone": inviteePhone,
      "isHost": _isHost,
      "isCoHost": _isCoHost,
      "userProfile": _userProfile,
      "goalModel": _goalModel,
      "status": _status
    };
  }

  factory LiveBattleInvite.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    List<String> joinedUser = [];
    data?['joinedUser'].forEach((v) {
      joinedUser.add(v);
    });
    return LiveBattleInvite(
      channelId: data?["channelId"],
      inviteePhone: data?["inviteePhone"],
      isHost: data?["isHost"],
      isCoHost: data?["isCoHost"],
      userProfile: data?["userProfile"],
      goalModel: data?["goalModel"],
      status: data?["status"],
    );
  }

  String? get channelId => _channelId;

  bool? get isHost => _isHost;

  bool? get isCoHost => _isCoHost;

  UserProfileModel? get userProfile => _userProfile;

  GoalModel? get goalModel => _goalModel;

  String? get status => _status;
}

final liveBattleInviteStream =
    StreamProvider.autoDispose<QuerySnapshot<LiveBattleInvite>?>((ref) {
  final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
  // LiveBattleInvite? invite;

  return FirebaseFirestore.instance
      .collection(FirebaseConstants.liveBattleInvites)
      .where('inviteePhone', isEqualTo: phoneNumber)
      .withConverter(
        fromFirestore: LiveBattleInvite.fromFireStore,
        toFirestore: (LiveBattleInvite value, options) => value.toFireStore(),
      )
      .snapshots();
  //     .listen((event) {
  //   invite = event.docs.first.data();
  // });} catch (e) {
  //   debugPrint(e.toString());
  // }
  // return invite;
});

Future<bool> inviteLiveBattle({
  required BuildContext context,
  required String channelId,
  required String inviteePhone,
  UserProfileModel? userProf,
  required GoalModel goalModel,
  required bool isHost,
  required bool isCoHost,
  required String status,
}) async {
  LiveBattleInvite invite = LiveBattleInvite(
    channelId: channelId,
    inviteePhone: inviteePhone,
    goalModel: goalModel,
    userProfile: userProf,
    isHost: isHost,
    isCoHost: isCoHost,
    status: "pending",
  );
  debugPrint("invite ==> $invite");
  try {
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.liveBattleInvites)
        .doc(inviteePhone)
        .set(invite.toJson());
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> acceptLiveBattle({
  required BuildContext context,
  required String inviteId,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.liveBattleInvites)
        .doc(inviteId)
        .delete();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

Future<bool> rejectLiveBattle({
  required BuildContext context,
  required String inviteId,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection(FirebaseConstants.liveBattleInvites)
        .doc(inviteId)
        .delete();
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}
