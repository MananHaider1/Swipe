import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/views/calling/audio_call.dart';
import 'package:lamatdating/views/calling/video_call.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/models/call.dart';
import 'package:lamatdating/models/call_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {String? fromUID,
      String? fromFullname,
      String? fromDp,
      String? toFullname,
      String? toDp,
      String? toUID,
      bool? isvideocall,
      required String? currentuseruid,
      required SharedPreferences prefs,
      context}) async {
    EasyLoading.show();
    int timeepoch = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic>? res = await FunctionCall().makeCloudCall();
    if (res == null) {
      Lamat.toast("Failed to Dial Call. Please try again !");
    } else {
      debugPrint("Agora Call Details ====> $res");
      Call call = Call(
          token: res['token'].toString(),
          timeepoch: timeepoch,
          callerId: fromUID,
          callerName: fromFullname,
          callerPic: fromDp,
          receiverId: toUID,
          receiverName: toFullname,
          receiverPic: toDp,
          channelId: res['channelId'].toString(),
          isvideocall: isvideocall);
      debugPrint("Agora Call Details ====> ${res['token'].toString()}");
      debugPrint("Agora Call Details ====> ${res['channelId'].toString()}");
      ClientRoleType role = ClientRoleType.clientRoleBroadcaster;
      bool callMade = await callMethods.makeCall(
          call: call, isvideocall: isvideocall, timeepoch: timeepoch);

      call.hasDialled = true;
      if (isvideocall == false) {
        if (callMade) {
          EasyLoading.dismiss();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCall(
                key: Key(call.timeepoch.toString()),
                prefs: prefs,
                currentuseruid: currentuseruid,
                call: call,
                channelName: call.channelId,
                role: role,
              ),
            ),
          );
        }
      } else {
        if (callMade) {
          EasyLoading.dismiss();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCall(
                key: Key(call.timeepoch.toString()),
                prefs: prefs,
                currentuseruid: currentuseruid!,
                call: call,
                channelName: call.channelId!,
                role: role,
              ),
            ),
          );
        }
      }
    }
  }
}

class FunctionCall {
  Future<Map<String, dynamic>?> makeCloudCall() async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createCallsWithTokens');
      dynamic resp = await callable.call(
        {
          "appId": Agora_APP_ID,
          "appCertificate": Agora_Primary_Certificate,
        },
      );

      if (resp.data != null) {
        Map<String, dynamic> res = {
          'token': resp.data['data']['token'],
          'channelId': resp.data['data']['channelId'],
        };
        debugPrint("Agora Call Details ====> $res");
        return res;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }
}
