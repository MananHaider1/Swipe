import 'dart:convert';

import 'package:lamatdating/constants.dart';

// import 'package:lamatdating/helpers/constants.dart';

class AppSettingsModel {
  bool isChattingEnabledBeforeMatch;
  bool? isHomePageEnabled;
  String? admobBanner;
  String? admobInt;
  String? admobIntIos;
  String? admobBannerIos;
  int? maxUploadDaily;
  int? liveMinViewers;
  int? liveTimeout;
  int? rewardVideoUpload;
  int? minFansForLive;
  int? minFansVerification;
  int? minRedeemCoins;
  int? minWithdrawal;
  num? coinValue;
  int? dailyWithdrawalLimit;
  String? currency;
  String? agoraAppId;
  String? agoraAppCert;
  int? primaryColor;
  int? primaryDarkColor;
  int? secondaryColor;
  int? secondaryDarkColor;
  int? tintColor;
  String? appLogo;
  AppSettingsModel({
    this.admobBanner,
    this.isHomePageEnabled,
    this.admobBannerIos,
    this.admobInt,
    this.admobIntIos,
    this.agoraAppId,
    this.coinValue,
    this.dailyWithdrawalLimit,
    this.currency,
    this.agoraAppCert,
    this.liveMinViewers,
    this.liveTimeout,
    this.maxUploadDaily,
    this.minFansForLive,
    this.minFansVerification,
    this.minRedeemCoins,
    this.minWithdrawal,
    this.rewardVideoUpload,
    required this.isChattingEnabledBeforeMatch,
    this.primaryColor,
    this.primaryDarkColor,
    this.secondaryColor,
    this.secondaryDarkColor,
    this.tintColor,
    this.appLogo,
  });

  AppSettingsModel copyWith({
    bool? isChattingEnabledBeforeMatch,
    bool? isHomePageEnabled,
    String? admobBanner,
    String? admobInt,
    String? admobIntIos,
    String? admobBannerIos,
    int? maxUploadDaily,
    int? liveMinViewers,
    int? liveTimeout,
    int? rewardVideoUpload,
    int? minFansForLive,
    int? minFansVerification,
    int? minRedeemCoins,
    int? minWithdrawal,
    num? coinValue,
    int? dailyWithdrawalLimit,
    String? currency,
    String? agoraAppId,
    String? agoraAppCert,
    int? primaryColor,
    int? primaryDarkColor,
    int? secondaryColor,
    int? secondaryDarkColor,
    int? tintColor,
    String? appLogo,
  }) {
    return AppSettingsModel(
      isChattingEnabledBeforeMatch:
          isChattingEnabledBeforeMatch ?? this.isChattingEnabledBeforeMatch,
      isHomePageEnabled: isHomePageEnabled ?? this.isHomePageEnabled,
      admobBanner: admobBanner ?? this.admobBanner,
      admobInt: admobInt ?? this.admobInt,
      admobIntIos: admobIntIos ?? this.admobIntIos,
      admobBannerIos: admobBannerIos ?? this.admobBannerIos,
      maxUploadDaily: maxUploadDaily ?? this.maxUploadDaily,
      liveMinViewers: liveMinViewers ?? this.liveMinViewers,
      liveTimeout: liveTimeout ?? this.liveTimeout,
      rewardVideoUpload: rewardVideoUpload ?? this.rewardVideoUpload,
      minFansForLive: minFansForLive ?? this.minFansForLive,
      minFansVerification: minFansVerification ?? this.minFansVerification,
      minRedeemCoins: minRedeemCoins ?? this.minRedeemCoins,
      minWithdrawal: minWithdrawal ?? this.minWithdrawal,
      coinValue: coinValue ?? this.coinValue,
      dailyWithdrawalLimit: dailyWithdrawalLimit ?? this.dailyWithdrawalLimit,
      currency: currency ?? this.currency,
      agoraAppId: agoraAppId ?? this.agoraAppId,
      agoraAppCert: agoraAppCert ?? this.agoraAppCert,
      primaryColor: primaryColor ?? this.primaryColor,
      primaryDarkColor: primaryDarkColor ?? this.primaryDarkColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      secondaryDarkColor: secondaryDarkColor ?? this.secondaryDarkColor,
      tintColor: tintColor ?? this.tintColor,
      appLogo: appLogo ?? this.appLogo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isChattingEnabledBeforeMatch': isChattingEnabledBeforeMatch,
      'isHomePageEnabled': isHomePageEnabled ?? true,
      'admobBanner': admobBanner,
      'admobInt': admobInt,
      'admobIntIos': admobIntIos,
      'admobBannerIos': admobBannerIos,
      'maxUploadDaily': maxUploadDaily,
      'liveMinViewers': liveMinViewers,
      'liveTimeout': liveTimeout,
      'rewardVideoUpload': rewardVideoUpload,
      'minFansForLive': minFansForLive,
      'minFansVerification': minFansVerification,
      'minRedeemCoins': minRedeemCoins,
      'minWithdrawal': minWithdrawal,
      'coinValue': coinValue,
      'dailyWithdrawalLimit': dailyWithdrawalLimit,
      'currency': currency,
      'agoraAppId': agoraAppId,
      'agoraAppCert': agoraAppCert,
      'primaryColor': primaryColor,
      'primaryDarkColor': primaryDarkColor,
      'secondaryColor': secondaryColor,
      'secondaryDarkColor': secondaryDarkColor,
      'tintColor': tintColor,
      'appLogo': appLogo,
    };
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
        isChattingEnabledBeforeMatch:
            map['isChattingEnabledBeforeMatch'] ?? true,
        isHomePageEnabled: map['isHomePageEnabled'] ?? true,
        admobBanner: map['admobBanner'] ?? '',
        admobInt: map['admobInt'] ?? '',
        admobIntIos: map['admobIntIos'] ?? '',
        admobBannerIos: map['admobBannerIos'] ?? '',
        maxUploadDaily: map['maxUploadDaily'].round(),
        liveMinViewers: map['liveMinViewers'].round(),
        liveTimeout: map['liveTimeout'].round(),
        rewardVideoUpload: map['rewardVideoUpload'].round(),
        minFansForLive: map['minFansForLive'].round(),
        minFansVerification: map['minFansVerification'].round(),
        minRedeemCoins: map['minRedeemCoins'].round(),
        minWithdrawal: map['minWithdrawal'].round(),
        coinValue: map['coinValue'] as double,
        dailyWithdrawalLimit: map['dailyWithdrawalLimit'].round(),
        currency: map['currency'] ?? '',
        agoraAppId: map['agoraAppId'] ?? '',
        agoraAppCert: map['agoraAppCert'] ?? '',
        primaryColor:
            (map['primaryColor'] is String && map['primaryColor'] != null)
                ? int.parse(map['primaryColor'])
                : int.parse(AppConstants.primaryColor.value.toString()),
        primaryDarkColor: (map['primaryDarkColor'] is String &&
                map['primaryDarkColor'] != null)
            ? int.parse(map['primaryDarkColor'])
            : int.parse(AppConstants.primaryColorDark.value.toString()),
        secondaryColor:
            (map['secondaryColor'] is String && map['secondaryColor'] != null)
                ? int.parse(map['secondaryColor'])
                : int.parse(AppConstants.secondaryColor.value.toString()),
        secondaryDarkColor: (map['secondaryDarkColor'] is String &&
                map['secondaryDarkColor'] != null)
            ? int.parse(map['secondaryDarkColor'])
            : int.parse(AppConstants.secondaryColor.value.toString()),
        tintColor: (map['tintColor'] is String && map['tintColor'] != null)
            ? int.parse(map['tintColor'])
            : int.parse(AppConstants.midColor.value.toString()),
        appLogo: (map['appLogo'] is String && map['appLogo'] != null)
            ? map['appLogo']
            : 'https://cdn-icons-png.freepik.com/256/6399/6399428.png');
  }

  String toJson() => json.encode(toMap());

  factory AppSettingsModel.fromJson(String source) =>
      AppSettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AppSettingsModel(isChattingEnabledBeforeMatch: $isChattingEnabledBeforeMatch, isHomePageEnabled: $isHomePageEnabled, admobBanner: $admobBanner , admobInt: $admobInt , admobIntIos: $admobIntIos , admobBannerIos: $admobBannerIos, maxUploadDaily: $maxUploadDaily, liveMinViewers: $liveMinViewers, liveTimeout: $liveTimeout, rewardVideoUpload: $rewardVideoUpload, minFansForLive: $minFansForLive, minFansVerification: $minFansVerification, minRedeemCoins: $minRedeemCoins, minWithdrawal: $minWithdrawal, coinValue: $coinValue, dailyWithdrawalLimit: $dailyWithdrawalLimit, currency: $currency, agoraAppId: $agoraAppId, agoraAppCert: $agoraAppCert, primaryColor: $primaryColor, primaryDarkColor: $primaryDarkColor, secondaryColor: $secondaryColor, secondaryDarkColor: $secondaryDarkColor, tintColor: $tintColor, appLogo: $appLogo)';

  @override
  bool operator ==(covariant AppSettingsModel other) {
    if (identical(this, other)) return true;

    return other.isChattingEnabledBeforeMatch == isChattingEnabledBeforeMatch &&
        other.isHomePageEnabled == isHomePageEnabled &&
        other.admobBanner == admobBanner &&
        other.admobInt == admobInt &&
        other.admobIntIos == admobIntIos &&
        other.admobBannerIos == admobBannerIos &&
        other.maxUploadDaily == maxUploadDaily &&
        other.liveMinViewers == liveMinViewers &&
        other.liveTimeout == liveTimeout &&
        other.rewardVideoUpload == rewardVideoUpload &&
        other.minFansForLive == minFansForLive &&
        other.minFansVerification == minFansVerification &&
        other.minRedeemCoins == minRedeemCoins &&
        other.minWithdrawal == minWithdrawal &&
        other.coinValue == coinValue &&
        other.dailyWithdrawalLimit == dailyWithdrawalLimit &&
        other.currency == currency &&
        other.agoraAppId == agoraAppId &&
        other.agoraAppCert == agoraAppCert &&
        other.primaryColor == primaryColor &&
        other.primaryDarkColor == primaryDarkColor &&
        other.secondaryColor == secondaryColor &&
        other.secondaryDarkColor == secondaryDarkColor &&
        other.tintColor == tintColor &&
        other.appLogo == appLogo;
  }

  @override
  int get hashCode =>
      isChattingEnabledBeforeMatch.hashCode ^
      isHomePageEnabled.hashCode ^
      admobBanner.hashCode ^
      admobInt.hashCode ^
      admobIntIos.hashCode ^
      admobBannerIos.hashCode ^
      maxUploadDaily.hashCode ^
      liveMinViewers.hashCode ^
      liveTimeout.hashCode ^
      rewardVideoUpload.hashCode ^
      minFansForLive.hashCode ^
      minFansVerification.hashCode ^
      minRedeemCoins.hashCode ^
      minWithdrawal.hashCode ^
      coinValue.hashCode ^
      dailyWithdrawalLimit.hashCode ^
      currency.hashCode ^
      agoraAppId.hashCode ^
      agoraAppCert.hashCode ^
      primaryColor.hashCode ^
      primaryDarkColor.hashCode ^
      secondaryColor.hashCode ^
      secondaryDarkColor.hashCode ^
      tintColor.hashCode ^
      appLogo.hashCode;
}

class Gifts {
  Gifts({
    int? id,
    int? coinPrice,
    String? image,
    int? createdAt,
    int? updatedAt,
  }) {
    _id = id;
    _coinPrice = coinPrice;
    _image = image;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Gifts.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _coinPrice = json['coinPrice'];
    _image = json['image'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  int? _id;
  int? _coinPrice;
  String? _image;
  int? _createdAt;
  int? _updatedAt;
  Gifts copyWith({
    int? id,
    int? coinPrice,
    String? image,
    int? createdAt,
    int? updatedAt,
  }) =>
      Gifts(
        id: id ?? _id,
        coinPrice: coinPrice ?? _coinPrice,
        image: image ?? _image,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  int? get id => _id;
  int? get coinPrice => _coinPrice;
  String? get image => _image;
  int? get createdAt => _createdAt;
  int? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['coinPrice'] = _coinPrice;
    map['image'] = _image;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}

// TODO

//     SettingRes.admobBanner = setting?.data?.admobBanner;
//     SettingRes.admobInt = setting?.data?.admobInt;
//     SettingRes.admobIntIos = setting?.data?.admobIntIos;
//     SettingRes.admobBannerIos = setting?.data?.admobBannerIos;
//     SettingRes.maxUploadDaily = setting?.data?.maxUploadDaily;
//     SettingRes.liveMinViewers = setting?.data?.liveMinViewers;
//     SettingRes.liveTimeout = setting?.data?.liveTimeout;
//     SettingRes.rewardVideoUpload = setting?.data?.rewardVideoUpload;
//     SettingRes.minFansForLive = setting?.data?.minFansForLive;
//     SettingRes.minFansVerification = setting?.data?.minFansVerification;
//     SettingRes.minRedeemCoins = setting?.data?.minRedeemCoins;
//     SettingRes.coinValue = setting?.data?.coinValue;
//     SettingRes.currency = setting?.data?.currency;
//     SettingRes.agoraAppId = setting?.data?.agoraAppId.toString() ?? '';
//     SettingRes.gifts = setting?.data?.gifts;
