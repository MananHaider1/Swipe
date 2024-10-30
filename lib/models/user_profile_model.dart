// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:lamatdating/models/subscribers_model.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';

class UserProfileModel {
  String id;
  String userId;
  String fullName;
  String userName;
  String nickname;
  String? email;
  String? profilePicture;
  String phoneNumber;
  String gender;
  String? about;
  DateTime birthDay;
  List<String> mediaFiles;
  List<String>? subsFiles;
  List<SubscribersModel>? mySubs;
  List<String>? subbedTo;
  List<String> interests;
  List<String>? followers;
  List<String>? following;
  List<String>? favSongs;
  List<String>? favTeels;
  UserAccountSettingsModel userAccountSettingsModel;
  bool isVerified;
  bool isOnline;
  bool isBoosted;
  int? boostedOn;
  int boostBalance;
  String? boostType;
  int superLikesCount;
  String? deviceToken;
  String? fbUrl;
  String? instaUrl;
  String? youtubeUrl;
  String? agoraToken;
  int? followersCount;
  int? followingCount;
  int? myPostLikes;
  String? profileCategoryName;
  int? collectedDiamond;
  bool? isPremium;
  int? premiumExpiryDate;
  String? phone_raw;
  String? countryCode;

  UserProfileModel({
    required this.isBoosted,
    required this.boostedOn,
    required this.boostBalance,
    required this.boostType,
    required this.superLikesCount,
    required this.fbUrl,
    required this.deviceToken,
    required this.instaUrl,
    required this.youtubeUrl,
    required this.agoraToken,
    required this.followersCount,
    required this.followingCount,
    required this.myPostLikes,
    required this.followers,
    required this.following,
    required this.favSongs,
    required this.favTeels,
    required this.profileCategoryName,
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.userName,
    required this.nickname,
    required this.email,
    required this.profilePicture,
    required this.userId,
    required this.gender,
    required this.about,
    required this.birthDay,
    required this.mediaFiles,
    this.subsFiles,
    this.mySubs,
    this.subbedTo,
    required this.interests,
    required this.userAccountSettingsModel,
    required this.isVerified,
    this.isOnline = true,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.phone_raw,
    this.countryCode,
  });

  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? userName,
    String? nickname,
    double? walletBalance,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? gender,
    String? about,
    bool? isBoosted,
    int? boostedOn,
    int? boostBalance,
    String? boostType,
    int? superLikesCount,
    DateTime? birthDay,
    List<String>? mediaFiles,
    List<String>? subsFiles,
    List<SubscribersModel>? mySubs,
    List<String>? subbedTo,
    List<String>? interests,
    List<String>? followers,
    List<String>? following,
    List<String>? favSongs,
    List<String>? favTeels,
    UserAccountSettingsModel? userAccountSettingsModel,
    bool? isVerified,
    bool? isOnline,
    String? deviceToken,
    String? fbUrl,
    String? instaUrl,
    String? youtubeUrl,
    String? agoraToken,
    int? followersCount,
    int? followingCount,
    int? myPostLikes,
    String? profileCategoryName,
    int? premiumExpiryDate,
    bool? isPremium,
    String? phone_raw,
    String? countryCode,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      isBoosted: isBoosted ?? this.isBoosted,
      boostedOn: boostedOn ?? this.boostedOn,
      boostBalance: boostBalance ?? this.boostBalance,
      boostType: boostType ?? this.boostType,
      superLikesCount: superLikesCount ?? this.superLikesCount,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      about: about ?? this.about,
      birthDay: birthDay ?? this.birthDay,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      subsFiles: subsFiles ?? this.subsFiles,
      mySubs: mySubs ?? this.mySubs,
      subbedTo: subbedTo ?? this.subbedTo,
      interests: interests ?? this.interests,
      userAccountSettingsModel:
          userAccountSettingsModel ?? this.userAccountSettingsModel,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      favSongs: favSongs ?? this.favSongs,
      favTeels: favTeels ?? this.favTeels,
      // from v2
      deviceToken: deviceToken ?? this.deviceToken,
      instaUrl: instaUrl ?? this.instaUrl,
      fbUrl: fbUrl ?? this.fbUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      agoraToken: agoraToken ?? this.agoraToken,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      myPostLikes: myPostLikes ?? this.myPostLikes,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      profileCategoryName: profileCategoryName ?? this.profileCategoryName,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      phone_raw: phone_raw ?? this.phone_raw,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    // from v1
    result.addAll({'id': id});
    result.addAll({'userId': userId});
    result.addAll({'fullName': fullName});
    result.addAll({'userName': userName});
    result.addAll({'nickname': nickname});
    if (email != null) {
      result.addAll({'email': email});
    }
    if (profilePicture != null) {
      result.addAll({'profilePicture': profilePicture});
    }

    result.addAll({'phoneNumber': phoneNumber});

    result.addAll({'gender': gender});
    if (about != null) {
      result.addAll({'about': about});
    }
    result.addAll({'birthDay': birthDay.millisecondsSinceEpoch});
    result.addAll({'mediaFiles': mediaFiles});
    result.addAll({'subsFiles': subsFiles});
    result.addAll({'mySubs': mySubs});
    result.addAll({'subbedTo': subbedTo});
    result.addAll({'interests': interests});
    result.addAll({'isBoosted': isBoosted});
    result.addAll({'boostedOn': boostedOn});
    result.addAll({'boostBalance': boostBalance});
    result.addAll({'boostType': boostType});
    result.addAll({'superLikesCount': superLikesCount});
    result
        .addAll({'userAccountSettingsModel': userAccountSettingsModel.toMap()});
    result.addAll({'isVerified': isVerified});
    result.addAll({'isOnline': isOnline});
    result.addAll({'favSongs': favSongs});
    result.addAll({'favTeels': favTeels});
    // from v2
    result.addAll({'deviceToken': deviceToken});
    result.addAll({'instaUrl': instaUrl});
    result.addAll({'youtubeUrl': youtubeUrl});
    result.addAll({'agoraToken': agoraToken});
    result.addAll({'followersCount': followersCount});
    result.addAll({'followingCount': followingCount});
    result.addAll({'myPostLikes': myPostLikes});
    result.addAll({'followers': followers});
    result.addAll({'following': following});
    result.addAll({'profileCategoryName': profileCategoryName});
    result.addAll({'fbUrl': fbUrl});

    result.addAll({'isPremium': isPremium});
    result.addAll({'premiumExpiryDate': premiumExpiryDate});
    result.addAll({'phone_raw': phone_raw});
    result.addAll({'countryCode': countryCode});

    return result;
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      // from v1
      id: map['id'] ?? '',
      userId: map['userId'],
      fullName: map['fullName'] ?? '',
      userName: map['userName'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'],
      profilePicture: map['profilePicture'],
      phoneNumber: map['phoneNumber'],
      gender: map['gender'] ?? '',
      about: map['about'],
      birthDay: DateTime.fromMillisecondsSinceEpoch(map['birthDay']),
      mediaFiles: List<String>.from(map['mediaFiles']),
      subsFiles: List<String>.from(map['subsFiles'] ?? []),
      mySubs: (map['mySubs'] != null)
          ? List<SubscribersModel>.from(
        map['mySubs'].map((x) => SubscribersModel.fromMap(x)),
      ) : [],
      subbedTo: (map['subbedTo'] != null)
      ? List<String>.from(
        map['subbedTo'].map((x) => x),
      ) : [],
      interests: List<String>.from(map['interests']),
      userAccountSettingsModel:
          UserAccountSettingsModel.fromMap(map['userAccountSettingsModel']),
      isVerified: map['isVerified'] ?? false,
      isBoosted: map['isBoosted'] ?? false,
      boostedOn: map['boostedOn'] ?? 0,
      boostBalance: map['boostBalance'] ?? 0,
      boostType: map['boostType'] ?? '',
      superLikesCount: map['superLikesCount'] ?? 0,
      favSongs: List<String>.from(map['favSongs']),
      favTeels: List<String>.from(map['favTeels']),
      isOnline: map['isOnline'] ?? false,
      // from v2
      deviceToken: map['deviceToken'] ?? '',
      instaUrl: map['instaUrl'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      fbUrl: map['fbUrl'] ?? '',
      agoraToken: map['agoraToken'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      myPostLikes: map['myPostLikes'] ?? 0,
      followers: List<String>.from(map['followers']),
      following: List<String>.from(map['following']),
      profileCategoryName: map['profileCategoryName'] ?? '',

      isPremium: map['isPremium'] ?? false,
      premiumExpiryDate: map['premiumExpiryDate'] ?? 0,
      phone_raw: map['phone_raw'] ?? '',
      countryCode: map['countryCode'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfileModel.fromJson(String source) =>
      UserProfileModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserProfileModel(profileCategoryName: $profileCategoryName, following: $following, favTeels: $favTeels, favSongs: $favSongs, superLikesCount: $superLikesCount, isBoosted: $isBoosted, boostedOn: $boostedOn, boostBalance: $boostBalance, boostType: $boostType, agoraToken: $agoraToken, followers: $followers, followersCount: $followersCount, followingCount: $followingCount, myPostLikes: $myPostLikes, deviceToken: $deviceToken, instaUrl: $instaUrl, youtubeUrl: $youtubeUrl, fbUrl: $fbUrl, id: $id, userId: $userId, phoneNumber: $phoneNumber, fullName: $fullName, userName: $userName, nickname: $nickname, email: $email, profilePicture: $profilePicture, phoneNumber: $phoneNumber, gender: $gender, about: $about, birthDay: $birthDay, mediaFiles: $mediaFiles, subsFiles: $subsFiles, mySubs: $mySubs, subbedTo: $subbedTo interests: $interests, userAccountSettingsModel: $userAccountSettingsModel, isVerified: $isVerified, isOnline: $isOnline, isPremium: $isPremium, premiumExpiryDate: $premiumExpiryDate, phone_raw: $phone_raw, countryCode: $countryCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other is UserProfileModel &&
        other.id == id &&
        other.userId == userId &&
        other.fullName == fullName &&
        other.userName == userName &&
        other.nickname == nickname &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.phoneNumber == phoneNumber &&
        other.gender == gender &&
        other.isBoosted == isBoosted &&
        other.boostedOn == boostedOn &&
        other.boostBalance == boostBalance &&
        other.boostType == boostType &&
        other.superLikesCount == superLikesCount &&
        other.about == about &&
        other.birthDay == birthDay &&
        listEquals(other.mediaFiles, mediaFiles) &&
        listEquals(other.subsFiles, subsFiles) &&
        listEquals(other.mySubs, mySubs) &&
        listEquals(other.subbedTo, subbedTo) &&
        listEquals(other.interests, interests) &&
        other.userAccountSettingsModel == userAccountSettingsModel &&
        other.isVerified == isVerified &&
        other.isOnline == isOnline &&
        other.favSongs == favSongs &&
        other.favTeels == favTeels &&
        // from v2
        other.deviceToken == deviceToken &&
        other.fbUrl == fbUrl &&
        other.instaUrl == instaUrl &&
        other.youtubeUrl == youtubeUrl &&
        other.agoraToken == agoraToken &&
        other.followersCount == followersCount &&
        other.followingCount == followingCount &&
        other.myPostLikes == myPostLikes &&
        other.followers == followers &&
        other.following == following &&
        other.profileCategoryName == profileCategoryName &&
        other.isPremium == isPremium &&
        other.premiumExpiryDate == premiumExpiryDate &&
        other.phone_raw == phone_raw &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        fullName.hashCode ^
        userName.hashCode ^
        nickname.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        phoneNumber.hashCode ^
        gender.hashCode ^
        isBoosted.hashCode ^
        boostedOn.hashCode ^
        boostBalance.hashCode ^
        boostType.hashCode ^
        about.hashCode ^
        birthDay.hashCode ^
        mediaFiles.hashCode ^
        subsFiles.hashCode ^
        mySubs.hashCode ^
        subbedTo.hashCode ^
        interests.hashCode ^
        userAccountSettingsModel.hashCode ^
        isVerified.hashCode ^
        isOnline.hashCode ^
        favSongs.hashCode ^
        favTeels.hashCode ^
        // from v2
        deviceToken.hashCode ^
        fbUrl.hashCode ^
        instaUrl.hashCode ^
        youtubeUrl.hashCode ^
        agoraToken.hashCode ^
        followersCount.hashCode ^
        followingCount.hashCode ^
        myPostLikes.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        profileCategoryName.hashCode ^
        isPremium.hashCode ^
        premiumExpiryDate.hashCode ^
        phone_raw.hashCode ^
        countryCode.hashCode;
  }
}
