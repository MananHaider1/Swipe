// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:flutter/services.dart';

enum AudioPlayerState {
  STOPPED,

  PLAYING,

  PAUSED,

  COMPLETED,
}

const MethodChannel _channel = MethodChannel('bz.rxla.flutter/audio');

class AudioPlayer {
  final StreamController<AudioPlayerState> _playerStateController =
      StreamController.broadcast();

  final StreamController<Duration> _positionController =
      StreamController.broadcast();

  AudioPlayerState _state = AudioPlayerState.STOPPED;
  Duration _duration = const Duration();

  AudioPlayer() {
    _channel.setMethodCallHandler(_audioPlayerStateChange);
  }

  /// Play a given url.
  Future<void> play(String? url, {bool isLocal = false}) async =>
      await _channel.invokeMethod('play', {'url': url, 'isLocal': isLocal});

  /// Pause the currently playing stream.
  Future<void> pause() async => await _channel.invokeMethod('pause');

  /// Stop the currently playing stream.
  Future<void> stop() async => await _channel.invokeMethod('stop');

  /// Mute sound.
  Future<void> mute(bool muted) async =>
      await _channel.invokeMethod('mute', muted);

  /// Seek to a specific position in the audio stream.
  Future<void> seek(double seconds) async =>
      await _channel.invokeMethod('seek', seconds);

  /// Stream for subscribing to player state change events.
  Stream<AudioPlayerState> get onPlayerStateChanged =>
      _playerStateController.stream;

  /// Reports what the player is currently doing.
  AudioPlayerState get state => _state;

  /// Reports the duration of the current media being played. It might return
  /// 0 if we have not determined the length of the media yet. It is best to
  /// call this from a state listener when the state has become
  /// [AudioPlayerState.PLAYING].
  Duration get duration => _duration;

  /// Stream for subscribing to audio position change events. Roughly fires
  /// every 200 milliseconds. Will continously update the position of the
  /// playback if the status is [AudioPlayerState.PLAYING].
  Stream<Duration> get onAudioPositionChanged => _positionController.stream;

  Future<void> _audioPlayerStateChange(MethodCall call) async {
    switch (call.method) {
      case "audio.onCurrentPosition":
        assert(_state == AudioPlayerState.PLAYING);
        _positionController.add(Duration(milliseconds: call.arguments));
        break;
      case "audio.onStart":
        _state = AudioPlayerState.PLAYING;
        _playerStateController.add(AudioPlayerState.PLAYING);
        // print('PLAYING ${call.arguments}');
        _duration = Duration(milliseconds: call.arguments);
        break;
      case "audio.onPause":
        _state = AudioPlayerState.PAUSED;
        _playerStateController.add(AudioPlayerState.PAUSED);
        break;
      case "audio.onStop":
        _state = AudioPlayerState.STOPPED;
        _playerStateController.add(AudioPlayerState.STOPPED);
        break;
      case "audio.onComplete":
        _state = AudioPlayerState.COMPLETED;
        _playerStateController.add(AudioPlayerState.COMPLETED);
        break;
      case "audio.onError":
        // If there's an error, we assume the player has stopped.
        _state = AudioPlayerState.STOPPED;
        _playerStateController.addError(call.arguments);

        break;
      default:
        throw ArgumentError('Unknown method ${call.method} ');
    }
  }
}
