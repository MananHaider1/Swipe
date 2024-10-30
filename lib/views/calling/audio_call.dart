// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/utils/error_codes.dart';

import 'package:lamatdating/views/tabs/chat/chat_home.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/call_history_provider.dart';

import 'package:lamatdating/models/call.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/Common/cached_image.dart';
import 'package:lamatdating/utils/call_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pip_view/pip_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../utils/theme_management.dart';

class AudioCall extends ConsumerStatefulWidget {
  final String? channelName;
  final Call call;
  final SharedPreferences prefs;
  final String? currentuseruid;
  final ClientRoleType? role;
  const AudioCall(
      {super.key,
      required this.call,
      required this.prefs,
      required this.currentuseruid,
      this.channelName,
      this.role});

  @override
  AudioCallState createState() => AudioCallState();
}

class AudioCallState extends ConsumerState<AudioCall> {
  final _infoStrings = <String>[];
  final _users = <int>[];
  bool muted = false;
  late RtcEngine _engine;
  int localUID = 0;

  Timer? timer;

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.stopPreview();
    _engine.release();
    stream = null;
    if (streamController != null) {
      streamController!.done;
      streamController!.close();
    }
    if (timerSubscription != null) {
      timerSubscription!.cancel();
    }
    if (_mPlayer != null) {
      _mPlayer!.stopPlayer();
      _mPlayer!.closePlayer();
      _mPlayer = null;
    }

    super.dispose();
  }

  Stream<DocumentSnapshot>? stream;
  @override
  void initState() {
    super.initState();
    initAgora();
    stream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentuseruid == widget.call.callerId
            ? widget.call.receiverId
            : widget.call.callerId)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .snapshots();
    if (widget.call.callerId == widget.currentuseruid) {
      _playCallingTone(context);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = ref.watch(observerProvider);
      observer.setisOngoingCall(true);
    });
  }

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.error);

  Future<void> _playCallingTone(context) async {
    try {
      final player = AudioCache(prefix: 'assets/sounds/');
      final url = await player.load('callingtone.mp3');

      _mPlayer!.openPlayer().then((value) async {
        _mPlayer!.setVolume(0.4);
        play() async {
          await _mPlayer!.startPlayer(
              fromURI: url.path,
              codec: Codec.mp3,
              whenFinished: () {
                play();
              });
        }

        await _mPlayer!.startPlayer(
            fromDataBuffer: File(url.path).readAsBytesSync(),
            codec: Codec.mp3,
            whenFinished: () async {
              await play();
            });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  bool isalreadyendedcall = false;
  void _stopCallingSound(context) async {
    if (_mPlayer != null) {
      try {
        if (_mPlayer != null) {
          _mPlayer!.stopPlayer();
          _mPlayer!.closePlayer();
          _mPlayer = null;
        }
      } catch (e) {
        Lamat.toast("Failed to stop calling sound.  Error $e");
      }
    }
  }

  bool isfakeloader = false;
  bool isspeaker = false;
  bool isPickedup = false;

  Future<void> initAgora() async {
    // retrieve permissions
    [Permission.microphone, Permission.camera].request();

    if (widget.call.callerId == widget.currentuseruid) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({
        'TYPE': 'OUTGOING',
        'ISVIDEOCALL': widget.call.isvideocall,
        'PEER': widget.call.receiverId,
        'TARGET': widget.call.receiverId,
        'TIME': widget.call.timeepoch,
        'DP': widget.call.receiverPic,
        'ISMUTED': false,
        'ISJOINEDEVER': false,
        'STATUS': 'calling',
        'STARTED': null,
        'ENDED': null,
        'CALLERNAME': widget.call.callerName,
        'CHANNEL': "",
        'UID': "",
      }, SetOptions(merge: true));
    }

    //create the engine
    _engine = createAgoraRtcEngine();
    debugPrint('Agora RTC SDK Status: ${_engine.getVersion()}');
    await _engine.initialize(const RtcEngineContext(
      appId: Agora_APP_ID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    debugPrint('engine initialized');

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, mssg) {
          Lamat.toast('$err- $mssg');
          debugPrint('$err- $mssg');
          if (kDebugMode) showERRORSheet(context, err.name, message: mssg);
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
          debugPrint("local user ${conn.localUid} joined");
          setState(() {});
          if (widget.call.callerId == widget.currentuseruid) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'TYPE': 'OUTGOING',
              'ISVIDEOCALL': widget.call.isvideocall,
              'PEER': widget.call.receiverId,
              'TARGET': widget.call.receiverId,
              'TIME': widget.call.timeepoch,
              'DP': widget.call.receiverPic,
              'ISMUTED': false,
              'ISJOINEDEVER': false,
              'STATUS': 'calling',
              'STARTED': null,
              'ENDED': null,
              'CALLERNAME': widget.call.callerName,
              'CHANNEL': conn.channelId,
              'UID': conn.localUid,
            }, SetOptions(merge: true)).then((value) async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.call.receiverId)
                  .collection(DbPaths.collectioncallhistory)
                  .doc(widget.call.timeepoch.toString())
                  .set({
                'TYPE': 'INCOMING',
                'ISVIDEOCALL': widget.call.isvideocall,
                'PEER': widget.call.callerId,
                'TARGET': widget.call.receiverId,
                'TIME': widget.call.timeepoch,
                'DP': widget.call.callerPic,
                'ISMUTED': false,
                'ISJOINEDEVER': true,
                'STATUS': 'missedcall',
                'STARTED': null,
                'ENDED': null,
                'CALLERNAME': widget.call.callerName,
                'CHANNEL': conn.channelId,
                'UID': conn.localUid,
              }, SetOptions(merge: true)).then((value) {
                WakelockPlus.enable();
                flutterLocalNotificationsPlugin.cancelAll();
              }).catchError((e) {
                Lamat.toast(e.toString());
              });
            });
          }
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          debugPrint("remote user $remoteUid joined");
          // if (widget.call.callerId == widget.currentuseruid) {
          //   timer = Timer.periodic(const Duration(seconds: 60), (_) {
          //     minusBalanceProvider(ref, AppRes.msgCost);
          //     if (AppRes.walletBalance == null ||
          //         AppRes.walletBalance! < AppRes.callCost) {
          //       _onCallEnd(context);
          //     }
          //   });
          // }

          setState(() {
            _users.add(remoteUid);

            isPickedup = true;
          });

          startTimerNow();

          if (widget.currentuseruid == widget.call.callerId) {
            isfakeloader = true;
            setState(() {});
            _stopCallingSound(context);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'TIME': widget.call.timeepoch,
              'STARTED': DateTime.now(),
              'STATUS': 'pickedup',
              'ISJOINEDEVER': true,
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'TIME': widget.call.timeepoch,
              'STARTED': DateTime.now(),
              'STATUS': 'pickedup',
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .set({
              Dbkeys.audioCallMade: FieldValue.increment(1),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .set({
              Dbkeys.audioCallRecieved: FieldValue.increment(1),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectiondashboard)
                .doc(DbPaths.docchatdata)
                .set({
              Dbkeys.audiocallsmade: FieldValue.increment(1),
            }, SetOptions(merge: true));
            setState(() {
              isPickedup = true;
            });

            Future.delayed(const Duration(milliseconds: 500), () {
              isfakeloader = false;
              setState(() {});
            });
          }
          // Lamat.toast('joined - ${connection.localUid}');
          WakelockPlus.enable();
          flutterLocalNotificationsPlugin.cancelAll();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          debugPrint("remote user $remoteUid left channel");
          setState(() {});

          _stopCallingSound(context);
          if (isalreadyendedcall == false) {
            FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'TIME': widget.call.timeepoch,
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'TIME': widget.call.timeepoch,
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
          }
          flutterLocalNotificationsPlugin.cancelAll();
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          Lamat.toast("Failed to Call. Please try calling again !");
          flutterLocalNotificationsPlugin.cancelAll();
        },
      ),
    );
    debugPrint('Agora RTC SDK Status: Set Handler');

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    debugPrint('Agora RTC SDK Status: Set Client Role');
    await _engine.enableAudio();
    if (!kIsWeb) _engine.setDefaultAudioRouteToSpeakerphone(isspeaker);
    debugPrint('Agora RTC SDK Status: Joining Channel');
    await _engine.joinChannel(
        token: widget.call.token!,
        channelId: widget.call.channelId!,
        uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ));

    debugPrint('Agora RTC SDK Status: Joined Channel');
  }

  Widget _toolbar(
    bool isshowspeaker,
    String? status,
    BuildContext context,
  ) {
    if (widget.role == ClientRoleType.clientRoleAudience) return Container();
    final observer = ref.watch(observerProvider);
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          status == 'ended' || status == 'rejected'
              ? const SizedBox(height: 42, width: 42)
              : RawMaterialButton(
                  onPressed: _onToggleMute,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: muted ? colorCallbuttons : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    muted ? Icons.mic_off : Icons.mic,
                    color: muted ? Colors.white : colorCallbuttons,
                    size: 22.0,
                  ),
                ),
          RawMaterialButton(
            onPressed: () async {
              setState(() {
                isalreadyendedcall =
                    status == 'ended' || status == 'rejected' ? true : false;
              });

              _onCallEnd(context);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: status == 'ended' || status == 'rejected'
                ? Colors.black
                : Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              status == 'ended' || status == 'rejected'
                  ? Icons.close
                  : Icons.call,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          isshowspeaker == true
              ? RawMaterialButton(
                  onPressed: _onToggleSpeaker,
                  shape: const CircleBorder(),
                  elevation: 2.0,
                  fillColor: isspeaker ? colorCallbuttons : Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    isspeaker ? Icons.volume_mute_rounded : Icons.volume_down,
                    color: isspeaker ? Colors.white : colorCallbuttons,
                    size: 22.0,
                  ),
                )
              : const SizedBox(height: 42, width: 42),
          status == 'pickedup'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: () {
                      PIPView.of(context)!.presentBelow(ChatHomePage(
                          doc: observer.userAppSettingsDoc!,
                          isShowOnlyCircularSpin: true,
                          currentUserNo: widget.currentuseruid!,
                          prefs: widget.prefs));
                    },
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.open_in_full_outlined,
                      color: Colors.black87,
                      size: 15.0,
                    ),
                  ),
                )
              : const SizedBox(
                  width: 0,
                ),
        ],
      ),
    );
  }

  audioscreenForPORTRAIT({
    required BuildContext context,
    String? status,
    bool? ispeermuted,
  }) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (status == 'rejected') {
      _stopCallingSound(context);
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Teme.isDarktheme(widget.prefs)
                ? AppConstants.backgroundColorDark
                : AppConstants.backgroundColor,
            height: h / 4,
            width: w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 17,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text("End-to-End Encryption",
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                // SizedBox(height: h / 35),
                SizedBox(
                  height: h / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 7),
                      SizedBox(
                        width: w / 1.1,
                        child: Text(
                          widget.call.callerId == widget.currentuseruid
                              ? widget.call.receiverName!
                              : widget.call.callerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor),
                            fontSize: 27,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        IsRemovePhoneNumberFromCallingPageWhenOnCall == true
                            ? ''
                            : widget.call.callerId == widget.currentuseruid
                                ? widget.call.receiverId!
                                : widget.call.callerId!,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: pickTextColorBasedOnBgColorAdvanced(
                                  Teme.isDarktheme(widget.prefs)
                                      ? AppConstants.backgroundColorDark
                                      : AppConstants.backgroundColor)
                              .withOpacity(0.34),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: h / 25),
                status == 'pickedup'
                    ? Text(
                        "$hoursStr:$minutesStr:$secondsStr",
                        style: const TextStyle(
                            fontSize: 20.0,
                            color: AppConstants.lamatGreenColor300,
                            fontWeight: FontWeight.w600),
                      )
                    : Text(
                        status == 'pickedup'
                            ? 'picked'.tr()
                            : status == 'nonetwork'
                                ? 'connecting'.tr()
                                : status == 'ringing' || status == 'missedcall'
                                    ? 'calling'.tr()
                                    : status == 'calling'
                                        ? widget.call.receiverId ==
                                                widget.currentuseruid
                                            ? 'connecting'.tr()
                                            : 'calling'.tr()
                                        : status == 'pickedup'
                                            ? 'oncall'.tr()
                                            : status == 'ended'
                                                ? 'callended'.tr()
                                                : status == 'rejected'
                                                    ? 'callrejected'.tr()
                                                    : 'plswait'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: status == 'pickedup'
                              ? AppConstants.primaryColor
                              : pickTextColorBasedOnBgColorAdvanced(
                                      Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor)
                                  .withOpacity(0.6),
                          fontSize: 18,
                        ),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Stack(
            children: [
              widget.call.callerId == widget.currentuseruid
                  ? widget.call.receiverPic == null ||
                          widget.call.receiverPic == '' ||
                          status == 'ended' ||
                          status == 'rejected'
                      ? Container(
                          height: w + (w / 11),
                          width: w,
                          color: Colors.white12,
                          child: Icon(
                            status == 'ended'
                                ? Icons.person_off
                                : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                            size: 140,
                            color: Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor,
                          ),
                        )
                      : Stack(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(15),
                                height: h * .75,
                                width: w,
                                color: Colors.white12,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(
                                          AppConstants.defaultNumericValue)),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.call.callerId ==
                                            widget.currentuseruid
                                        ? widget.call.receiverPic!
                                        : widget.call.callerPic!,
                                    fit: BoxFit.cover,
                                    height: h * .73,
                                    width: w,
                                    placeholder: (context, url) => Center(
                                        child: Container(
                                      height: w + (w / 11),
                                      width: w,
                                      color: Colors.white12,
                                      child: Icon(
                                        status == 'ended'
                                            ? Icons.person_off
                                            : status == 'rejected'
                                                ? Icons.call_end_rounded
                                                : Icons.person,
                                        size: 140,
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                      ),
                                    )),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: w + (w / 11),
                                      width: w,
                                      color: Colors.white12,
                                      child: Icon(
                                        status == 'ended'
                                            ? Icons.person_off
                                            : status == 'rejected'
                                                ? Icons.call_end_rounded
                                                : Icons.person,
                                        size: 140,
                                        color: Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.backgroundColorDark
                                            : AppConstants.backgroundColor,
                                      ),
                                    ),
                                  ),
                                )),
                            Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.black.withOpacity(0.18),
                            ),
                          ],
                        )
                  : widget.call.callerPic == null ||
                          widget.call.callerPic == '' ||
                          status == 'ended' ||
                          status == 'rejected'
                      ? Container(
                          height: w + (w / 11),
                          width: w,
                          color: Colors.white12,
                          child: Icon(
                            status == 'ended'
                                ? Icons.person_off
                                : status == 'rejected'
                                    ? Icons.call_end_rounded
                                    : Icons.person,
                            size: 140,
                            color: Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor,
                          ),
                        )
                      : Stack(
                          children: [
                            Container(
                                height: w + (w / 11),
                                width: w,
                                color: Teme.isDarktheme(widget.prefs)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor,
                                child: CachedNetworkImage(
                                  imageUrl: widget.call.callerId ==
                                          widget.currentuseruid
                                      ? widget.call.receiverPic!
                                      : widget.call.callerPic!,
                                  fit: BoxFit.cover,
                                  height: w + (w / 11),
                                  width: w,
                                  placeholder: (context, url) => Center(
                                      child: Container(
                                    height: w + (w / 11),
                                    width: w,
                                    color: Colors.white12,
                                    child: Icon(
                                      status == 'ended'
                                          ? Icons.person_off
                                          : status == 'rejected'
                                              ? Icons.call_end_rounded
                                              : Icons.person,
                                      size: 140,
                                      color: Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                    ),
                                  )),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: w + (w / 11),
                                    width: w,
                                    color: Colors.white12,
                                    child: Icon(
                                      status == 'ended'
                                          ? Icons.person_off
                                          : status == 'rejected'
                                              ? Icons.call_end_rounded
                                              : Icons.person,
                                      size: 140,
                                      color: Teme.isDarktheme(widget.prefs)
                                          ? AppConstants.backgroundColorDark
                                          : AppConstants.backgroundColor,
                                    ),
                                  ),
                                )),
                            Container(
                              height: w + (w / 11),
                              width: w,
                              color: Colors.black.withOpacity(0.18),
                            ),
                          ],
                        ),
              // widget.call.callerId == widget.currentuseruid
              //     ? widget.call.receiverPic == null ||
              //             widget.call.receiverPic == '' ||
              //             status == 'ended' ||
              //             status == 'rejected'
              //         ? SizedBox()
              //         : Container(
              //             height: w + (w / 11),
              //             width: w,
              //             color: Colors.black.withOpacity(0.3),
              //           )
              //     : widget.call.callerPic == null ||
              //             widget.call.callerPic == '' ||
              //             status == 'ended' ||
              //             status == 'rejected'
              //         ? SizedBox()
              //         : Container(
              //             height: w + (w / 11),
              //             width: w,
              //             color: Colors.black.withOpacity(0.3),
              //           ),
              Positioned(
                  bottom: 20,
                  child: SizedBox(
                    width: w,
                    height: 20,
                    child: Center(
                      child: status == 'pickedup'
                          ? ispeermuted == true
                              ? const Text(
                                  "Call muted",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.yellow,
                                    fontSize: 16,
                                  ),
                                )
                              : const SizedBox(
                                  height: 0,
                                )
                          : const SizedBox(
                              height: 0,
                            ),
                    ),
                  )),
            ],
          ),
          SizedBox(height: h / 6),
        ],
      ),
    );
  }

  audioscreenForLANDSCAPE({
    required BuildContext context,
    String? status,
    bool? ispeermuted,
  }) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    if (status == 'rejected') {
      _stopCallingSound(context);
    }
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            status == 'nonetwork'
                ? "Connecting..."
                : status == 'ringing' || status == 'missedcall'
                    ? "Calling..."
                    : status == 'calling'
                        ? "Calling..."
                        : status == 'pickedup'
                            ? "On Call"
                            : status == 'ended'
                                ? "Call Ended!"
                                : status == 'rejected'
                                    ? "Call Rejected!"
                                    : 'plswait'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: status == 'pickedup'
                  ? AppConstants.primaryColor
                  : pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor),
              fontSize: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              status == 'pickedup' ? "Call picked up" : "Voice Call",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: status == 'pickedup'
                    ? AppConstants.primaryColor
                    : AppConstants.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 25),
          status != 'pickedup'
              ? const SizedBox()
              : Text(
                  "$hoursStr:$minutesStr:$secondsStr",
                  style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.cyan,
                      fontWeight: FontWeight.w700),
                ),
          const SizedBox(height: 45),
          status == 'pickedup'
              ? widget.call.callerId == widget.currentuseruid
                  ? widget.call.receiverPic == null
                      ? SizedBox(
                          height: w > h ? 60 : 140,
                        )
                      : CachedImage(
                          widget.call.callerId == widget.currentuseruid
                              ? widget.call.receiverPic
                              : widget.call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 140,
                          width: w > h ? 60 : 140,
                          radius: w > h ? 70 : 168,
                        )
                  : widget.call.callerPic == null
                      ? SizedBox(
                          height: w > h ? 60 : 140,
                        )
                      : CachedImage(
                          widget.call.callerId == widget.currentuseruid
                              ? widget.call.receiverPic
                              : widget.call.callerPic,
                          isRound: true,
                          height: w > h ? 60 : 140,
                          width: w > h ? 60 : 140,
                          radius: w > h ? 70 : 168,
                        )
              : SizedBox(
                  height: w > h ? 60 : 140,
                  width: w > h ? 60 : 140,
                  child: Icon(
                    status == 'ended' ||
                            status == 'rejected' ||
                            status == 'pickedup'
                        ? Icons.call_end_sharp
                        : Icons.call,
                    size: w > h ? 60 : 140,
                    color: pickTextColorBasedOnBgColorAdvanced(
                            Teme.isDarktheme(widget.prefs)
                                ? AppConstants.backgroundColorDark
                                : AppConstants.backgroundColor)
                        .withOpacity(0.25),
                  ),
                ),
          const SizedBox(height: 45),
          Text(
            widget.call.callerId == widget.currentuseruid
                ? widget.call.receiverName!
                : widget.call.callerName!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: pickTextColorBasedOnBgColorAdvanced(
                  Teme.isDarktheme(widget.prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor),
              fontSize: 22,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            IsRemovePhoneNumberFromCallingPageWhenOnCall == true
                ? ''
                : widget.call.callerId == widget.currentuseruid
                    ? widget.call.receiverId!
                    : widget.call.callerId!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: pickTextColorBasedOnBgColorAdvanced(
                      Teme.isDarktheme(widget.prefs)
                          ? AppConstants.backgroundColorDark
                          : AppConstants.backgroundColor)
                  .withOpacity(0.54),
              fontSize: 19,
            ),
          ),
          SizedBox(
            height: h / 10,
          ),
          status == 'pickedup'
              ? ispeermuted == true
                  ? const Text(
                      "Call is Muted",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 19,
                      ),
                    )
                  : const SizedBox(
                      height: 0,
                    )
              : const SizedBox(
                  height: 0,
                )
        ],
      ),
    );
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return const SizedBox();
              }
              return const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    final callHistoryProvider =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);
    final observer = ref.watch(observerProvider);
    stopWatchStream();
    await CallUtils.callMethods.endCall(call: widget.call);
    DateTime now = DateTime.now();
    observer.setisOngoingCall(false);
    _stopCallingSound(context);
    if (isalreadyendedcall == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'TIME': widget.call.timeepoch, 'STATUS': 'ended', 'ENDED': now},
              SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'TIME': widget.call.timeepoch, 'STATUS': 'ended', 'ENDED': now},
              SetOptions(merge: true));
      //----------
      //----------

      if (widget.currentuseruid == widget.call.callerId) {
        try {
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(widget.call.callerId)
              .collection('recent')
              .doc('callended')
              .delete();
          if (isPickedup == false) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .collection('recent')
                .doc('callended')
                .set({
              'id': widget.call.receiverId,
              'ENDED': DateTime.now(),
              'CALLERNAME': widget.call.callerName,
            }, SetOptions(merge: true));
          }
        } catch (e) {
          if (kDebugMode) {
            print("$e");
          }
        }
      } else {
        try {
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(widget.call.receiverId)
              .collection('recent')
              .doc('callended')
              .delete();
          if (isPickedup == false) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection('recent')
                .doc('callended')
                .delete();
            Future.delayed(const Duration(milliseconds: 300), () async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.call.callerId)
                  .collection('recent')
                  .doc('callended')
                  .set({
                'id': widget.call.callerId,
                'ENDED': DateTime.now(),
                'CALLERNAME': widget.call.callerName,
              });
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print("$e");
          }
        }
      }
    }

    WakelockPlus.disable();
    callHistoryProvider.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.currentuseruid)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(14),
        true);
    Navigator.pop(context);
    setStatusBarColor(widget.prefs);
  }

  void _onToggleMute() async {
    setState(() {
      muted = !muted;
    });
    _stopCallingSound(context);
    await _engine.muteLocalAudioStream(muted);
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentuseruid)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onToggleSpeaker() async {
    setState(() {
      isspeaker = !isspeaker;
    });
    await _engine.setEnableSpeakerphone(isspeaker);
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    setStatusBarColor(widget.prefs);
    return WillPopScope(
        onWillPop: onWillPopNEw,
        child: h > w && ((h / w) > 1.5)
            ? PIPView(builder: (context, isFloating) {
                return Scaffold(
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    body:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
                      stream: stream
                          as Stream<DocumentSnapshot<Map<String, dynamic>?>?>?,
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null) {
                            return Center(
                              child: Stack(
                                children: <Widget>[
                                  audioscreenForPORTRAIT(
                                      context: context,
                                      status: 'calling',
                                      ispeermuted: false),
                                  _panel(),
                                  _toolbar(false, 'calling', context),
                                ],
                              ),
                            );
                          } else {
                            if (snapshot.data!.data() == null) {
                              return Center(
                                child: Stack(
                                  children: <Widget>[
                                    audioscreenForPORTRAIT(
                                        context: context,
                                        status: 'calling',
                                        ispeermuted: false),
                                    _panel(),
                                    _toolbar(false, 'calling', context),
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: Stack(
                                  children: <Widget>[
                                    audioscreenForPORTRAIT(
                                        context: context,
                                        status:
                                            snapshot.data!.data()!["STATUS"],
                                        ispeermuted:
                                            snapshot.data!.data()!["ISMUTED"]),
                                    _panel(),
                                    _toolbar(
                                        snapshot.data!.data()!["STATUS"] ==
                                                'pickedup'
                                            ? true
                                            : false,
                                        snapshot.data!.data()!["STATUS"],
                                        context),
                                  ],
                                ),
                              );
                            }
                          }
                        } else if (!snapshot.hasData) {
                          return Center(
                            child: Stack(
                              children: <Widget>[
                                audioscreenForPORTRAIT(
                                    context: context,
                                    status: 'nonetwork',
                                    ispeermuted: false),
                                _panel(),
                                _toolbar(false, 'nonetwork', context),
                              ],
                            ),
                          );
                        }

                        return Center(
                          child: Stack(
                            children: <Widget>[
                              audioscreenForPORTRAIT(
                                  context: context,
                                  status: 'calling',
                                  ispeermuted: false),
                              _panel(),
                              _toolbar(false, 'calling', context),
                            ],
                          ),
                        );
                      },
                    ));
              })
            : PIPView(builder: (context, isFloating) {
                return Scaffold(
                    backgroundColor: Teme.isDarktheme(widget.prefs)
                        ? AppConstants.backgroundColorDark
                        : AppConstants.backgroundColor,
                    body:
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
                      stream: stream
                          as Stream<DocumentSnapshot<Map<String, dynamic>?>?>?,
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data == null) {
                            return Center(
                              child: Stack(
                                children: <Widget>[
                                  audioscreenForLANDSCAPE(
                                      context: context,
                                      status: 'calling',
                                      ispeermuted: false),
                                  _panel(),
                                  _toolbar(false, 'calling', context),
                                ],
                              ),
                            );
                          } else {
                            if (snapshot.data!.data() == null) {
                              return Center(
                                child: Stack(
                                  children: <Widget>[
                                    audioscreenForLANDSCAPE(
                                        context: context,
                                        status: 'calling',
                                        ispeermuted: false),
                                    _panel(),
                                    _toolbar(false, 'calling', context),
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: Stack(
                                  children: <Widget>[
                                    audioscreenForLANDSCAPE(
                                        context: context,
                                        status:
                                            snapshot.data!.data()!["STATUS"],
                                        ispeermuted:
                                            snapshot.data!.data()!["ISMUTED"]),
                                    _panel(),
                                    _toolbar(
                                        snapshot.data!.data()!["STATUS"] ==
                                                'pickedup'
                                            ? true
                                            : false,
                                        snapshot.data!.data()!["STATUS"],
                                        context),
                                  ],
                                ),
                              );
                            }
                          }
                        } else if (!snapshot.hasData) {
                          return Center(
                            child: Stack(
                              children: <Widget>[
                                audioscreenForLANDSCAPE(
                                    context: context,
                                    status: 'nonetwork',
                                    ispeermuted: false),
                                _panel(),
                                _toolbar(false, 'nonetwork', context),
                              ],
                            ),
                          );
                        }
                        return Center(
                          child: Stack(
                            children: <Widget>[
                              audioscreenForLANDSCAPE(
                                  context: context,
                                  status: 'calling',
                                  ispeermuted: false),
                              _panel(),
                              _toolbar(false, 'calling', context),
                            ],
                          ),
                        );
                      },
                    ));
              }));
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;
  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  // ignore: close_sinks
  StreamController<int>? streamController;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    // ignore: close_sinks

    Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController!.stream;
  }

  startTimerNow() {
    timerStream = stopWatchStream();
    timerSubscription = timerStream!.listen((int newTick) {
      setState(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      flutterLocalNotificationsPlugin.cancelAll();
    });
  }

  //------
}
