import 'dart:async';
import 'package:lamatdating/widgets/Audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:lamatdating/constants.dart';

typedef OnError = void Function(Exception exception);

enum PlayerState { stopped, playing, paused }

class AudioPlayback extends StatefulWidget {
  final String? url;
  final Widget downloadwidget;
  const AudioPlayback({super.key, this.url, required this.downloadwidget});
  @override
  AudioPlaybackState createState() => AudioPlaybackState();
}

class AudioPlaybackState extends State<AudioPlayback> {
  Duration? duration;
  Duration? position;

  late AudioPlayer audioPlayer;

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  late StreamSubscription _positionSubscription;
  late StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(widget.url);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = const Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(color: Colors.white70, child: _buildPlayer()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() => Container(
        // width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              IconButton(
                onPressed: isPlaying ? null : () => play(),
                iconSize: 34.0,
                icon: const Icon(Icons.play_arrow),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying ? () => pause() : null,
                iconSize: 34.0,
                icon: const Icon(Icons.pause),
                color: Colors.cyan,
              ),
              IconButton(
                onPressed: isPlaying || isPaused ? () => stop() : null,
                iconSize: 34.0,
                icon: const Icon(Icons.stop),
                color: Colors.cyan,
              ),
              widget.downloadwidget
            ]),
            if (duration != null)
              Column(
                children: [
                  Text(
                    position != null
                        ? "${positionText ?? ''} / ${durationText ?? ''}"
                        : duration != null
                            ? durationText
                            : '',
                    style: const TextStyle(
                        fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                      activeColor: AppConstants.primaryColor,
                      value: position?.inMilliseconds.toDouble() ?? 0.0,
                      onChanged: (double value) {
                        audioPlayer.seek((value / 1000).roundToDouble());
                      },
                      min: 0.0,
                      max: duration!.inMilliseconds.toDouble()),
                ],
              ),
            // if (position != null) _buildMuteButtons(),
          ],
        ),
      );
}
