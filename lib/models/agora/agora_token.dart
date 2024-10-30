class AgoraToken {
  AgoraToken({
    String? token,
    String? channelId,
  }) {
    _channelId = channelId;
    _token = token;
  }

  AgoraToken.fromJson(dynamic json) {
    _token = json['token'];
    _channelId = json['channelId'];
  }

  String? _token;
  String? _channelId;

  AgoraToken copyWith({
    String? token,
    String? channelId,
  }) =>
      AgoraToken(token: token ?? _token, channelId: channelId ?? _channelId);

  String get token => _token!;
  String get channelId => _channelId!;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['token'] = _token;
    map['channelId'] = _channelId;
    return map;
  }
}

class AgoraTokenDemo {
  AgoraTokenDemo({
    String? token,
  }) {
    _token = token;
  }

  AgoraTokenDemo.fromJson(dynamic json) {
    _token = json['rtcToken'];
  }

  String? _token;

  AgoraTokenDemo copyWith({
    String? token,
  }) =>
      AgoraTokenDemo(
        token: token ?? _token,
      );

  String get token => _token!;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['rtcToken'] = _token;
    return map;
  }
}
