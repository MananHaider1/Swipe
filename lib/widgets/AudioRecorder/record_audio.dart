// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/constants.dart';
// import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/utils/color_detector.dart';
import 'package:lamatdating/utils/open_settings.dart';
import 'package:lamatdating/utils/permissions.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/utils/utils.dart';
import 'package:lamatdating/widgets/AudioRecorder/play_button.dart';

///
typedef Fn = void Function();

/// Example app.
class AudioRecord extends ConsumerStatefulWidget {
  const AudioRecord({
    super.key,
    required this.title,
    required this.callback,
    required this.prefs,
  });

  final String title;
  final Function callback;
  final SharedPreferences prefs;

  @override
  AudioRecordState createState() => AudioRecordState();
}

class AudioRecordState extends ConsumerState<AudioRecord> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer(logLevel: Level.error);
  FlutterSoundRecorder? _mRecorder =
      FlutterSoundRecorder(logLevel: Level.error);
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = !kIsWeb
      ? 'Recording-${DateTime.now().millisecondsSinceEpoch}.aac'
      : 'Recording-${DateTime.now().millisecondsSinceEpoch}.webm';
  Codec _codec = Codec.aacMP4;

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setStateIfMounted(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setStateIfMounted(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();

    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    stopWatchStream();
    super.dispose();
  }

  bool issinit = true;
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permissions.getMicrophonePermission();

      if (status != PermissionStatus.granted) {
        Lamat.showRationale(
          "Permission to access Microphone is required to Start.",
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpenSettings(
                      prefs: widget.prefs,
                    )));
      } else {
        await _mRecorder!.openRecorder();
        _mRecorderIsInited = true;
      }
    } else {
      await _mRecorder!.openRecorder();
      _codec = Codec.opusWebM;
      _mRecorderIsInited = true;
    }
  }

  // ----------------------  Here is the code for recording and playback -------
  Timer? timerr;
  void record() async {
    if (!kIsWeb) {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
    }

    setStateIfMounted(() {
      recordertime = '00:00:00';
      hoursStr = '00';
      secondsStr = '00';
      hoursStr = '00';
      minutesStr = '00';
    });

    _mRecorder!
        .startRecorder(
      codec: _codec,
      toFile: _mPath,
      //codec: kIsWeb ? Codec.aac : Codec.aacADTS,
    )
        .then((value) {
      setStateIfMounted(() {
        status = 'recording';
        issinit = false;
      });
      startTimerNow();
    });
  }

  File? recordedfile;
  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) async {
      setStateIfMounted(() {
        _mplaybackReady = true;
        status = 'recorded';
      });
      setStateIfMounted(() {
        recordedfile = File(value!);
        recordertime = "$hoursStr:$minutesStr:$secondsStr";
      });
      debugPrint("${recordedfile!.path}!!!!!!!!!!!!!!!!!!!!!!!!!!");
      debugPrint("$hoursStr:$minutesStr:$secondsStr !!!!!!!!!!!!!!!!!!!!!!!");

      setStateIfMounted(() {
        streamController!.done;
        streamController!.close();
        timerSubscription!.cancel();
      });
    });
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            // codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setStateIfMounted(() {});
            })
        .then((value) {
      setStateIfMounted(() {
        // status = 'play';
      });
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setStateIfMounted(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  String status = 'notrecording';

  onWillPopNEw(poped) {
    return Future.value(issinit == true
        ? true
        : status == 'recorded'
            ? _mPlayer!.isPlaying
                ? false
                : true
            : false);
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return isLoading == true
          ? const CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppConstants.secondaryColor))
          : Container(
              margin: const EdgeInsets.only(bottom: 40),
              height: status == 'recorded'
                  ? MediaQuery.of(context).size.height * .256
                  : MediaQuery.of(context).size.height * .12,
              decoration: BoxDecoration(
                color: Teme.isDarktheme(widget.prefs)
                    ? AppConstants.primaryColorDark
                    : AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // const SizedBox(
                  //   height: AppConstants.defaultNumericValue,
                  // ),
                  _mPlayer!.isPlaying
                      ? const SizedBox(
                          height: AppConstants.defaultNumericValue,
                        )
                      : Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(13),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _mRecorder!.isRecording
                                      ? "$hoursStr:$minutesStr:$secondsStr"
                                      : recordertime,
                                  style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w700,
                                    color: pickTextColorBasedOnBgColorAdvanced(
                                        Teme.isDarktheme(widget.prefs)
                                            ? AppConstants.primaryColorDark
                                            : AppConstants.primaryColor),
                                  ),
                                ),
                                PlayButton(
                                  pauseIcon: const Icon(
                                    Icons.stop,
                                    color: AppConstants.lamatREDbuttonColor,
                                    size: 30,
                                  ),
                                  playIcon: const Icon(Icons.mic,
                                      color: AppConstants.lamatREDbuttonColor,
                                      size: 30),
                                  onPressed: getRecorderFn(),
                                ),
                              ]),
                        ),
                  status == 'recorded'
                      ? Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(13),
                          // height: 160,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RawMaterialButton(
                                  onPressed: getPlaybackFn(),
                                  elevation: 2.0,
                                  fillColor: _mPlayer!.isPlaying
                                      ? Colors.white
                                      : AppConstants.primaryColor,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Icon(
                                    _mPlayer!.isPlaying
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                    size: 45.0,
                                    color: _mPlayer!.isPlaying
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                status == 'recorded'
                                    ? _mPlayer!.isPlaying
                                        ? const SizedBox()
                                        : RawMaterialButton(
                                            disabledElevation: 0,
                                            onPressed: () {
                                              debugPrint(
                                                  "File1:${recordedfile!.path}!!!!!!!!!!!!!!");
                                              // final observer =
                                              //     ref.watch(observerProvider);
                                              debugPrint(
                                                  "File2:${recordedfile!.path}!!!!!!!!!!!!!!");
                                              // if (recordedfile!.lengthSync() /
                                              //         1000000 >
                                              //     observer
                                              //         .maxFileSizeAllowedInMB) {
                                              //   Lamat.toast(
                                              //       'File should be less than - ${observer.maxFileSizeAllowedInMB}MB\n\nSelected File size is - ${(recordedfile!.lengthSync() / 1000000).round()}MB');
                                              // } else
                                              {
                                                setStateIfMounted(() {
                                                  isLoading = true;
                                                });
                                                Lamat.toast(
                                                  "Sending Recording ... Please wait !",
                                                );
                                                widget
                                                    .callback(recordedfile,
                                                        false, true, false)
                                                    .then((recordedUrl) {
                                                  Navigator.pop(
                                                      context, recordedUrl);
                                                });
                                              }
                                            },
                                            shape: const CircleBorder(),
                                            elevation: .5,
                                            fillColor: Colors.yellow[900],
                                            padding: const EdgeInsets.all(15.0),
                                            // style: ElevatedButton.styleFrom(
                                            //   shape: RoundedRectangleBorder(
                                            //       borderRadius:
                                            //           BorderRadius.circular(
                                            //               20.0),
                                            //       side: const BorderSide(
                                            //           color:
                                            //               AppConstants.primaryColor)),
                                            //   elevation: 0.2,
                                            //   backgroundColor:
                                            //       AppConstants.primaryColor,
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //           horizontal: 20,
                                            //           vertical: 20),
                                            // ),
                                            child: const Icon(
                                              Icons.send,
                                              size: 30,
                                              color: Colors.white,
                                            ),
                                          )
                                    : const SizedBox()
                              ]),
                        )
                      : const SizedBox(),
                ],
              ));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: PopScope(
        onPopInvokedWithResult: (popped, result) {
          onWillPopNEw;
        },
        child: makeBody(),
      ),
    );
  }

  //------ Timer Widget Section Below:
  bool flag = true;
  Stream<int>? timerStream;
  // ignore: cancel_subscriptions
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';
  String recordertime = '00:00:00';
  // ignore: close_sinks
  StreamController<int>? streamController;
  Stream<int> stopWatchStream() {
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
      setStateIfMounted(() {
        hoursStr =
            ((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
        minutesStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
        secondsStr = (newTick % 60).floor().toString().padLeft(2, '0');
      });
      // print(secondsStr);
    });
  }

  //------
}
