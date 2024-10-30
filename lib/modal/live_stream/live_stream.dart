import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lamatdating/models/user_profile_model.dart';

class LiveStreamUser {
  String? _agoraToken;
  String? _channelId;
  String? _thumbnail;
  int? _collectedDiamond;
  int? _collectedDiamondGuest;
  String? _fullName;
  String? _hostIdentity;
  String? _id;
  bool? _isVerified;
  String? _userName;
  List<String>? _joinedUser;
  String? _userId;
  String? _userImage;
  int? _watchingCount;
  int? _followers;
  String? _streamTitle;
  int? _streamGoal;
  String? _streamGoalType;
  String? _goalDescription;
  List<UserProfileModel>? _battleUsers;

  LiveStreamUser(
      {String? agoraToken,
      String? channelId,
      String? thumbnail,
      int? collectedDiamond,
      int? collectedDiamondGuest,
      String? fullName,
      String? hostIdentity,
      String? id,
      bool? isVerified,
      List<String>? joinedUser,
      String? phoneNumber,
      String? userImage,
      int? watchingCount,
      String? userName,
      int? followers,
      String? streamTitle,
      int? streamGoal,
      String? streamGoalType,
      String? goalDescription,
      List<UserProfileModel>? battleUsers}) {
    _agoraToken = agoraToken;
    _channelId = channelId;
    _thumbnail = thumbnail;
    _collectedDiamond = collectedDiamond;
    _collectedDiamondGuest = collectedDiamondGuest;
    _fullName = fullName;
    _hostIdentity = hostIdentity;
    _id = id;
    _isVerified = isVerified;
    _joinedUser = joinedUser;
    _userId = phoneNumber;
    _userImage = userImage;
    _watchingCount = watchingCount;
    _userName = userName;
    _followers = followers;
    _streamTitle = streamTitle;
    _streamGoal = streamGoal;
    _streamGoalType = streamGoalType;
    _goalDescription = goalDescription;
    _battleUsers = battleUsers;
  }

  Map<String, dynamic> toJson() {
    return {
      "agoraToken": _agoraToken,
      "channelId": _channelId,
      "thumbnail": _thumbnail,
      "collectedDiamond": _collectedDiamond,
      "collectedDiamondGuest": _collectedDiamondGuest,
      "fullName": _fullName,
      "hostIdentity": _hostIdentity,
      "id": _id,
      "isVerified": _isVerified,
      "joinedUser": _joinedUser?.map((e) => e).toList(),
      "phoneNumber": _userId,
      "userImage": _userImage,
      "watchingCount": _watchingCount,
      "userName": _userName,
      "followers": _followers,
      "streamTitle": _streamTitle,
      "streamGoal": _streamGoal,
      "streamGoalType": _streamGoalType,
      "goalDescription": _goalDescription,
      "battleUsers": _battleUsers
    };
  }

  LiveStreamUser.fromJson(Map<String, dynamic>? json) {
    _agoraToken = json?["agoraToken"];
    _channelId = json?["channelId"];
    _thumbnail = json?["thumbnail"];
    _collectedDiamond = json?["collectedDiamond"];
    _collectedDiamondGuest = json?["collectedDiamondGuest"];
    _fullName = json?["fullName"];
    _hostIdentity = json?["hostIdentity"];
    _id = json?["id"];
    _isVerified = json?["_isVerified"];
    if (json?["joinedUser"] != null) {
      _joinedUser = [];
      json?["joinedUser"].forEach((e) {
        _joinedUser?.add(e);
      });
    }
    _userId = json?["_userId"];
    _userImage = json?["_userImage"];
    _watchingCount = json?["_watchingCount"];
    _userName = json?["userName"];
    _followers = json?["followers"];
    _streamTitle = json?["streamTitle"];
    _streamGoal = json?["streamGoal"];
    _streamGoalType = json?["streamGoalType"];
    _goalDescription = json?["goalDescription"];

    if (json?["battleUsers"] != null) {
      _battleUsers = [];
      json?["battleUsers"].forEach((e) {
        _battleUsers?.add(UserProfileModel.fromJson(e));
      });
    }
  }

  Map<String, dynamic> toFireStore() {
    return {
      "agoraToken": _agoraToken,
      "channelId": _channelId,
      "thumbnail": _thumbnail,
      "collectedDiamond": _collectedDiamond,
      "collectedDiamondGuest": _collectedDiamondGuest,
      "fullName": _fullName,
      "hostIdentity": _hostIdentity,
      "id": _id,
      "isVerified": _isVerified,
      "joinedUser": _joinedUser,
      "phoneNumber": _userId,
      "userImage": _userImage,
      "watchingCount": _watchingCount,
      "userName": _userName,
      "followers": _followers,
      "streamTitle": _streamTitle,
      "streamGoal": _streamGoal,
      "streamGoalType": _streamGoalType,
      "goalDescription": _goalDescription,
      "battleUsers": _battleUsers
    };
  }

  factory LiveStreamUser.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    List<String> joinedUser = [];
    List<UserProfileModel> battleUsers = [];
    data?['joinedUser'].forEach((v) {
      joinedUser.add(v);
    });
    data?['battleUsers'].forEach((v) {
      battleUsers.add(UserProfileModel.fromMap(v));
    });
    return LiveStreamUser(
      agoraToken: data?["agoraToken"],
      channelId: data?["channelId"],
      thumbnail: data?["thumbnail"],
      collectedDiamond: data?["collectedDiamond"] ?? 0,
      collectedDiamondGuest: data?["collectedDiamondGuest"] ?? 0,
      fullName: data?["fullName"],
      hostIdentity: data?["hostIdentity"],
      id: data?["id"],
      isVerified: data?["isVerified"],
      joinedUser: joinedUser,
      phoneNumber: data?["phoneNumber"],
      userImage: data?["userImage"],
      watchingCount: data?["watchingCount"],
      userName: data?["userName"],
      followers: data?["followers"],
      streamTitle: data?["streamTitle"],
      streamGoal: data?["streamGoal"],
      streamGoalType: data?["streamGoalType"],
      goalDescription: data?["goalDescription"],
      battleUsers: battleUsers,
    );
  }

  int? get watchingCount => _watchingCount;

  String? get userImage => _userImage;

  String? get phoneNumber => _userId;

  List<String>? get joinedUser => _joinedUser;

  bool? get isVerified => _isVerified;

  String? get id => _id;

  String? get hostIdentity => _hostIdentity;

  String? get fullName => _fullName;

  int? get collectedDiamond => _collectedDiamond;

  int? get collectedDiamondGuest => _collectedDiamondGuest;

  String? get agoraToken => _agoraToken;

  String? get channelId => _channelId;

  String? get thumbnail => _thumbnail;

  String? get userName => _userName;

  int? get followers => _followers;

  String? get streamTitle => _streamTitle;

  int? get streamGoal => _streamGoal;

  String? get streamGoalType => _streamGoalType;

  String? get goalDescription => _goalDescription;

  List<UserProfileModel>? get battleUsers => _battleUsers;
}

class LiveStreamComment {
  String? _comment;
  String? _commentType;
  int? _id;
  bool? _isVerify;
  String? _userId;
  String? _userImage;
  String? _userName;
  String? _fullName;

  LiveStreamComment(
      {String? comment,
      String? commentType,
      int? id,
      bool? isVerify,
      String? phoneNumber,
      String? userImage,
      String? userName,
      String? fullName}) {
    _comment = comment;
    _commentType = commentType;
    _id = id;
    _isVerify = isVerify;
    _userId = phoneNumber;
    _userImage = userImage;
    _userName = userName;
    _fullName = fullName;
  }

  Map<String, dynamic> toJson() {
    return {
      "comment": _comment,
      "commentType": _commentType,
      "id": _id,
      "isVerify": _isVerify,
      "phoneNumber": _userId,
      "userImage": _userImage,
      "userName": _userName,
      "fullName": _fullName,
    };
  }

  LiveStreamComment.fromJson(Map<String, dynamic>? json) {
    _comment = json?["comment"];
    _commentType = json?["commentType"];
    _id = json?["id"];
    _isVerify = json?["isVerify"];
    _userId = json?["phoneNumber"];
    _userImage = json?["userImage"];
    _userName = json?["userName"];
    _fullName = json?["fullName"];
  }

  Map<String, dynamic> toFireStore() {
    return {
      "comment": _comment,
      "commentType": _commentType,
      "id": _id,
      "isVerify": _isVerify,
      "phoneNumber": _userId,
      "userImage": _userImage,
      "userName": _userName,
      "fullName": _fullName,
    };
  }

  factory LiveStreamComment.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return LiveStreamComment(
      comment: data?['comment'],
      commentType: data?['commentType'],
      id: data?['id'],
      isVerify: data?['isVerify'],
      phoneNumber: data?['phoneNumber'],
      userImage: data?['userImage'],
      userName: data?['userName'],
      fullName: data?['fullName'],
    );
  }

  String? get userName => _userName;

  String? get userImage => _userImage;

  String? get phoneNumber => _userId;

  bool? get isVerify => _isVerify;

  int? get id => _id;

  String? get commentType => _commentType;

  String? get comment => _comment;

  String? get fullName => _fullName;
}
