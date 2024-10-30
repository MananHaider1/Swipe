// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/models/call.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/error_codes.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/call_history_provider.dart';

import 'package:lamatdating/utils/call_utilities.dart';
import 'package:lamatdating/utils/status_bar_color.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pip_view/pip_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VideoCall extends ConsumerStatefulWidget {
  final String channelName;
  final String currentuseruid;
  final SharedPreferences prefs;
  final Call call;
  final ClientRoleType role;
  const VideoCall(
      {super.key,
      required this.call,
      required this.prefs,
      required this.currentuseruid,
      required this.channelName,
      required this.role});
  @override
  ConsumerState<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends ConsumerState<VideoCall> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;
  Stream<DocumentSnapshot>? stream;

  Timer? timer;
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

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.stopPreview();
    _engine.release();
    stream = null;
    if (_mPlayer != null) {
      _mPlayer!.stopPlayer();
      _mPlayer!.closePlayer();
      _mPlayer = null;
    }

    super.dispose();
  }

  bool isPickedup = false;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.error);

  Future<void> _playCallingTone(context) async {
    try {
      final player = AudioCache(prefix: 'assets/sounds/');
      final url = await player.load('callingtone.mp3');

      _mPlayer!.openPlayer().then((value) async {
        _mPlayer!.setVolume(1);
        play() async {
          await _mPlayer!.startPlayer(
              fromDataBuffer: File(url.path).readAsBytesSync(),
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

  runFakeloader() {
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        isfakeloader = false;
      });
    });
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

  Future<void> initAgora() async {
    // retrieve permissions
    [Permission.microphone, Permission.camera].request();

    if (widget.call.callerId == widget.currentuseruid) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch!.toString())
          .set({
        'TYPE': 'OUTGOING',
        'ISVIDEOCALL': widget.call.isvideocall,
        'PEER': widget.call.receiverId,
        'TIME': widget.call.timeepoch,
        'DP': widget.call.receiverPic,
        'ISMUTED': false,
        'TARGET': widget.call.receiverId,
        'ISJOINEDEVER': false,
        'STATUS': 'calling',
        'STARTED': null,
        'ENDED': null,
        'CALLERNAME': widget.call.callerName,
        'CHANNEL': widget.channelName,
        'UID': "",
      }, SetOptions(merge: true));
    }

    //create the engine
    _engine = createAgoraRtcEngine();
    debugPrint('Agora RTC SDK Version: ${_engine.getVersion()}');
    await _engine.initialize(const RtcEngineContext(
      appId: Agora_APP_ID,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    debugPrint('Agora RTC SDK Status: Initialized');
    VideoEncoderConfiguration configuration = const VideoEncoderConfiguration(
        dimensions: VideoDimensions(
            height: AgoraVideoResultionHEIGHT,
            width: AgoraVideoResultionWIDTH));
    debugPrint('Agora RTC SDK Status: Set Video Encoder Configuration');
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, mssg) {
          Lamat.toast('$err- $mssg');
          debugPrint('$err- $mssg');
          if (kDebugMode) showERRORSheet(context, err.name, message: mssg);
        },
        onJoinChannelSuccess: (RtcConnection conn, int elapsed) async {
          debugPrint("local user ${conn.localUid} joined");
          setState(() {
            _localUserJoined = true;
          });
          if (widget.call.callerId == widget.currentuseruid) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch!.toString())
                .set({
              'TYPE': 'OUTGOING',
              'ISVIDEOCALL': widget.call.isvideocall,
              'PEER': widget.call.receiverId,
              'TIME': widget.call.timeepoch,
              'DP': widget.call.receiverPic,
              'ISMUTED': false,
              'TARGET': widget.call.receiverId,
              'ISJOINEDEVER': false,
              'STATUS': 'calling',
              'STARTED': null,
              'ENDED': null,
              'CALLERNAME': widget.call.callerName,
              'CHANNEL': widget.channelName,
              'UID': conn.localUid!.toString(),
            }, SetOptions(merge: true)).then((value) async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.call.receiverId)
                  .collection(DbPaths.collectioncallhistory)
                  .doc(widget.call.timeepoch!.toString())
                  .set({
                'TYPE': 'INCOMING',
                'ISVIDEOCALL': widget.call.isvideocall,
                'PEER': widget.call.callerId,
                'TIME': widget.call.timeepoch,
                'DP': widget.call.callerPic,
                'ISMUTED': false,
                'TARGET': widget.call.receiverId,
                'ISJOINEDEVER': true,
                'STATUS': 'missedcall',
                'STARTED': null,
                'ENDED': null,
                'CALLERNAME': widget.call.callerName,
                'CHANNEL': widget.channelName,
                'UID': conn.localUid!.toString(),
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

          setState(() {
            isPickedup = true;
            _remoteUid = remoteUid;
          });
          if (widget.call.callerId == widget.currentuseruid) {
            timer = Timer.periodic(const Duration(seconds: 60), (_) {
              minusBalanceProvider(ref, AppRes.msgCost);
              if (AppRes.walletBalance == null ||
                  AppRes.walletBalance! < AppRes.callCost) {
                _onCallEnd(context);
              }
            });
          }
          if (widget.currentuseruid == widget.call.callerId) {
            _stopCallingSound(context);
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
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
              'STARTED': DateTime.now(),
              'STATUS': 'pickedup',
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .set({
              Dbkeys.videoCallMade: FieldValue.increment(1),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .set({
              Dbkeys.videoCallRecieved: FieldValue.increment(1),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectiondashboard)
                .doc(DbPaths.docchatdata)
                .set({
              Dbkeys.videocallsmade: FieldValue.increment(1),
            }, SetOptions(merge: true));
            setState(() {
              isPickedup = true;
              _remoteUid = remoteUid;
              isfakeloader = true;
            });

            Future.delayed(const Duration(milliseconds: 200), () {
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
          setState(() {
            _remoteUid = null;
          });

          _stopCallingSound(context);
          if (isalreadyendedcall == false) {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.callerId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.call.receiverId)
                .collection(DbPaths.collectioncallhistory)
                .doc(widget.call.timeepoch.toString())
                .set({
              'STATUS': 'ended',
              'ENDED': DateTime.now(),
            }, SetOptions(merge: true));
            //----------
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

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setVideoEncoderConfiguration(configuration);

    await _engine.joinChannel(
      token: widget.call.token!,
      channelId: widget.call.channelId!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  Future<bool> onWillPopNEw() {
    return Future.value(false);
  }

  Widget _panel(
      {required BuildContext context, bool? ispeermuted, String? status}) {
    if (status == 'rejected') {
      _stopCallingSound(context);
    }
    return Container(
      // padding: const EdgeInsets.symmetric(vertical: 28),
      alignment: Alignment.bottomCenter,
      child: Container(
        // height: 73,
        margin: const EdgeInsets.symmetric(vertical: 138),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            status == 'pickedup' && ispeermuted == true
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Call is Muted",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'calling' || status == 'ringing' || status == 'missedcall'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.call.receiverId == widget.currentuseruid
                              ? 'Connecting...'
                              : 'Calling...',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'nonetwork'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Connecting...',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black87),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'ended'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Call Ended!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppConstants.lamatREDbuttonColor,
                            ))),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
            status == 'rejected'
                ? Flexible(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Call Rejected!",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppConstants.lamatREDbuttonColor),
                        )),
                  )
                : const SizedBox(
                    height: 0,
                    width: 0,
                  ),
          ],
        ),
      ),
    );
  }

  bool muted = false;
  void _onToggleMute() async {
    setState(() {
      muted = !muted;
    });
    _stopCallingSound(context);
    await _engine.muteLocalAudioStream(muted);
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentuseruid)
        .collection(DbPaths.collectioncallhistory)
        .doc(widget.call.timeepoch.toString())
        .set({'ISMUTED': muted}, SetOptions(merge: true));
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onSwitchCamera() async {
    await _engine.switchCamera();
  }

  bool isspeaker = true;
  void _onToggleSpeaker() async {
    setState(() {
      isspeaker = !isspeaker;
    });
    await _engine.setEnableSpeakerphone(isspeaker);
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void _onCallEnd(BuildContext context) async {
    final firestoreDataProviderCALLHISTORY =
        ref.watch(firestoreDataProviderCALLHISTORYProvider);
    final observer = ref.watch(observerProvider);

    _stopCallingSound(context);
    await CallUtils.callMethods.endCall(call: widget.call);
    DateTime now = DateTime.now();
    observer.setisOngoingCall(false);
    if (isalreadyendedcall == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.callerId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.call.receiverId)
          .collection(DbPaths.collectioncallhistory)
          .doc(widget.call.timeepoch.toString())
          .set({'STATUS': 'ended', 'ENDED': now}, SetOptions(merge: true));

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
              'ENDED': DateTime.now().millisecondsSinceEpoch,
              'CALLERNAME': widget.call.callerName,
            }, SetOptions(merge: true));
          }
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
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
                'ENDED': DateTime.now().millisecondsSinceEpoch,
                'CALLERNAME': widget.call.callerName,
              });
            });
          }
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
      }
    }
    WakelockPlus.disable();

    firestoreDataProviderCALLHISTORY.fetchNextData(
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
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Widget _toolbar(
    BuildContext context,
    bool isshowspeaker,
    String? status,
  ) {
    final observer = ref.watch(observerProvider);
    if (widget.role == ClientRoleType.clientRoleAudience) return Container();

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isshowspeaker == true
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
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
                  ))
              : const SizedBox(height: 0, width: 65.67),
          status != 'ended' && status != 'rejected'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
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
                  ))
              : const SizedBox(height: 42, width: 65.67),
          SizedBox(
            width: 65.67,
            child: RawMaterialButton(
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
          ),
          status == 'ended' || status == 'rejected'
              ? const SizedBox(
                  width: 65.67,
                )
              : SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: _onSwitchCamera,
                    shape: const CircleBorder(),
                    elevation: 2.0,
                    fillColor: Colors.white,
                    padding: const EdgeInsets.all(12.0),
                    child: const Icon(
                      Icons.switch_camera,
                      color: colorCallbuttons,
                      size: 20.0,
                    ),
                  ),
                ),
          status == 'pickedup'
              ? SizedBox(
                  width: 65.67,
                  child: RawMaterialButton(
                    onPressed: () {
                      PIPView.of(context)!.presentBelow(ChatHomePage(
                          doc: observer.userAppSettingsDoc!,
                          isShowOnlyCircularSpin: true,
                          currentUserNo: widget.currentuseruid,
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
                  width: 65.67,
                )
        ],
      ),
    );
  }

  bool isuserenlarged = false;
  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: onWillPopNEw,
        child: PIPView(builder: (context, isFloating) {
          return Scaffold(
              backgroundColor: Colors.black,
              body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>?>?>(
                stream:
                    stream as Stream<DocumentSnapshot<Map<String, dynamic>?>?>?,
                builder: (BuildContext context, snapshot) {
                  if (_localUserJoined == false) {
                    return Center(
                      child: Stack(
                        children: <Widget>[
                          _remoteUid == null
                              ? _localVideo()
                              : isuserenlarged
                                  ? _localVideo()
                                  : _remoteVideo(),
                          _toolbar(context, false, 'calling'),
                          _panel(
                              context: context,
                              status: 'calling',
                              ispeermuted: false),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    if (snapshot.data!.data() == null) {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            _remoteUid == null
                                ? _localVideo()
                                : isuserenlarged == true
                                    ? _localVideo()
                                    : _remoteVideo(),
                            _toolbar(context, false, 'calling'),
                            _panel(
                                status: 'calling',
                                ispeermuted: false,
                                context: context),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Stack(
                          children: <Widget>[
                            isfakeloader
                                ? Container()
                                : _remoteUid == null
                                    ? _localVideo()
                                    : isuserenlarged
                                        ? _localVideo()
                                        : _remoteVideo(),
                            _toolbar(
                                context,
                                snapshot.data!.data()!["STATUS"] == 'pickedup'
                                    ? true
                                    : false,
                                snapshot.data!.data()!["STATUS"]),
                            snapshot.data!.data()!["STATUS"] == 'pickedup' &&
                                    _remoteUid != null &&
                                    _localUserJoined == true
                                ? Positioned(
                                    bottom:
                                        screenWidth > screenHeight ? 40 : 120,
                                    right: screenWidth > screenHeight ? 20 : 10,
                                    child: isfakeloader
                                        ? Container()
                                        : SizedBox(
                                            height: screenWidth > screenHeight
                                                ? screenWidth / 4.7
                                                : screenHeight / 4.7,
                                            width: screenWidth > screenHeight
                                                ? (screenWidth / 4.7) / 1.7
                                                : (screenHeight / 4.7) / 1.7,
                                            child: Stack(
                                              children: [
                                                Center(
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        isuserenlarged =
                                                            !isuserenlarged;
                                                        isfakeloader = true;
                                                      });

                                                      runFakeloader();
                                                    },
                                                    child: isuserenlarged
                                                        ? _remoteVideo()
                                                        : _localVideo(),
                                                  ),
                                                ),
                                                const Positioned(
                                                    top: 5,
                                                    right: 5,
                                                    child: Icon(
                                                      Icons.sync,
                                                      color: Colors.white70,
                                                      size: 20,
                                                    ))
                                              ],
                                            ),
                                          ))
                                : const SizedBox(),
                            _panel(
                                context: context,
                                status: snapshot.data!.data()!["STATUS"],
                                ispeermuted: snapshot.data!.data()!["ISMUTED"]),
                          ],
                        ),
                      );
                    }
                  }
                  return Center(
                    child: Stack(
                      children: <Widget>[
                        _remoteUid == null
                            ? _localVideo()
                            : isuserenlarged
                                ? _localVideo()
                                : _remoteVideo(),
                        _toolbar(context, false, 'calling'),
                        _panel(
                            context: context,
                            status: 'calling',
                            ispeermuted: false),
                      ],
                    ),
                  );
                },
              ));
        }));
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  // Display local user's video
  Widget _localVideo() {
    if (_localUserJoined == true) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: _engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
