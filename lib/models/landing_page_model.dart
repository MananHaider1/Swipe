import 'dart:convert';

class HomePageModel {
  String? logo;
  String? company;
  String? appName;
  String? heroImage;
  String? heroTitle;
  String? heroDescription;
  String? confidenceImage;
  String? confidenceTitle;
  String? confidenceP1;
  String? confidenceP2;
  String? readyImage;
  String? readyTitle;
  String? readyP1;
  String? readyP2;
  String? meetImage;
  String? meetTitle;
  String? meetUser;
  String? meetP1;
  String? meetP2;
  String? meetP3;
  String? successImage1;
  String? successImage2;
  String? successImage3;
  String? successTitle;
  String? successP1;
  String? successP2;
  String? successP3;
  String? experienceImage;
  String? experienceTitle;
  String? experienceP1;
  String? experienceP2;
  String? experienceP3;
  String? experienceP4;
  String? facebookUrl;
  String? instagramUrl;
  String? twitterUrl;
  String? linkedinUrl;
  String? googleUrl;
  String? appleUrl;
  String? appIcon;
  String? copyright;

  HomePageModel({
    this.logo,
    this.company,
    this.appName,
    this.heroImage,
    this.heroTitle,
    this.heroDescription,
    this.confidenceImage,
    this.confidenceTitle,
    this.confidenceP1,
    this.confidenceP2,
    this.readyImage,
    this.readyTitle,
    this.readyP1,
    this.readyP2,
    this.meetImage,
    this.meetTitle,
    this.meetUser,
    this.meetP1,
    this.meetP2,
    this.meetP3,
    this.successImage1,
    this.successImage2,
    this.successImage3,
    this.successTitle,
    this.successP1,
    this.successP2,
    this.successP3,
    this.experienceImage,
    this.experienceTitle,
    this.experienceP1,
    this.experienceP2,
    this.experienceP3,
    this.experienceP4,
    this.facebookUrl,
    this.instagramUrl,
    this.twitterUrl,
    this.linkedinUrl,
    this.googleUrl,
    this.appleUrl,
    this.appIcon,
    this.copyright,
  });

  HomePageModel copyWith({
    String? logo,
    String? company,
    String? appName,
    String? heroImage,
    String? heroTitle,
    String? heroDescription,
    String? confidenceImage,
    String? confidenceTitle,
    String? confidenceP1,
    String? confidenceP2,
    String? readyImage,
    String? readyTitle,
    String? readyP1,
    String? readyP2,
    String? meetImage,
    String? meetTitle,
    String? meetUser,
    String? meetP1,
    String? meetP2,
    String? meetP3,
    String? successImage1,
    String? successImage2,
    String? successImage3,
    String? successTitle,
    String? successP1,
    String? successP2,
    String? successP3,
    String? experienceImage,
    String? experienceTitle,
    String? experienceP1,
    String? experienceP2,
    String? experienceP3,
    String? experienceP4,
    String? facebookUrl,
    String? instagramUrl,
    String? twitterUrl,
    String? linkedinUrl,
    String? googleUrl,
    String? appleUrl,
    String? appIcon,
    String? copyright,
  }) {
    return HomePageModel(
      logo: logo ?? this.logo,
      company: company ?? this.company,
      appName: appName ?? this.appName,
      heroImage: heroImage ?? this.heroImage,
      heroTitle: heroTitle ?? this.heroTitle,
      heroDescription: heroDescription ?? this.heroDescription,
      confidenceImage: confidenceImage ?? this.confidenceImage,
      confidenceTitle: confidenceTitle ?? this.confidenceTitle,
      confidenceP1: confidenceP1 ?? this.confidenceP1,
      confidenceP2: confidenceP2 ?? this.confidenceP2,
      readyImage: readyImage ?? this.readyImage,
      readyTitle: readyTitle ?? this.readyTitle,
      readyP1: readyP1 ?? this.readyP1,
      readyP2: readyP2 ?? this.readyP2,
      meetImage: meetImage ?? this.meetImage,
      meetTitle: meetTitle ?? this.meetTitle,
      meetUser: meetUser ?? this.meetUser,
      meetP1: meetP1 ?? this.meetP1,
      meetP2: meetP2 ?? this.meetP2,
      meetP3: meetP3 ?? this.meetP3,
      successImage1: successImage1 ?? this.successImage1,
      successImage2: successImage2 ?? this.successImage2,
      successImage3: successImage3 ?? this.successImage3,
      successTitle: successTitle ?? this.successTitle,
      successP1: successP1 ?? this.successP1,
      successP2: successP2 ?? this.successP2,
      successP3: successP3 ?? this.successP3,
      experienceImage: experienceImage ?? this.experienceImage,
      experienceTitle: experienceTitle ?? this.experienceTitle,
      experienceP1: experienceP1 ?? this.experienceP1,
      experienceP2: experienceP2 ?? this.experienceP2,
      experienceP3: experienceP3 ?? this.experienceP3,
      experienceP4: experienceP4 ?? this.experienceP4,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      googleUrl: googleUrl ?? this.googleUrl,
      appleUrl: appleUrl ?? this.appleUrl,
      appIcon: appIcon ?? this.appIcon,
      copyright: copyright ?? this.copyright,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    // from v1
    result.addAll({'logo': logo});
    result.addAll({'company': company});
    result.addAll({'appName': appName});
    result.addAll({'heroImage': heroImage});
    result.addAll({'heroTitle': heroTitle});
    result.addAll({'heroDescription': heroDescription});
    result.addAll({'confidenceImage': confidenceImage});
    result.addAll({'confidenceTitle': confidenceTitle});
    result.addAll({'confidenceP1': confidenceP1});
    result.addAll({'confidenceP2': confidenceP2});
    result.addAll({'readyImage': readyImage});
    result.addAll({'readyTitle': readyTitle});
    result.addAll({'readyP1': readyP1});
    result.addAll({'readyP2': readyP2});
    result.addAll({'meetImage': meetImage});
    result.addAll({'meetTitle': meetTitle});
    result.addAll({'meetUser': meetUser});
    result.addAll({'meetP1': meetP1});
    result.addAll({'meetP2': meetP2});
    result.addAll({'meetP3': meetP3});
    result.addAll({'successImage1': successImage1});
    result.addAll({'successImage2': successImage2});
    result.addAll({'successImage3': successImage3});
    result.addAll({'successTitle': successTitle});
    result.addAll({'successP1': successP1});
    result.addAll({'successP2': successP2});
    result.addAll({'successP3': successP3});
    result.addAll({'experienceImage': experienceImage});
    result.addAll({'experienceTitle': experienceTitle});
    result.addAll({'experienceP1': experienceP1});
    result.addAll({'experienceP2': experienceP2});
    result.addAll({'experienceP3': experienceP3});
    result.addAll({'experienceP4': experienceP4});
    result.addAll({'facebookUrl': facebookUrl});
    result.addAll({'instagramUrl': instagramUrl});
    result.addAll({'twitterUrl': twitterUrl});
    result.addAll({'linkedinUrl': linkedinUrl});
    result.addAll({'googleUrl': googleUrl});
    result.addAll({'appleUrl': appleUrl});
    result.addAll({'appIcon': appIcon});
    result.addAll({'copyright': copyright});

    return result;
  }

  factory HomePageModel.fromMap(Map<String, dynamic> map) {
    return HomePageModel(
      // from v1
      logo: map['logo'] ?? '',
      company: map['company'] ?? '',
      appName: map['appName'] ?? '',
      heroImage: map['heroImage'] ?? '',
      heroTitle: map['heroTitle'] ?? '',
      heroDescription: map['heroDescription'] ?? '',
      confidenceImage: map['confidenceImage'] ?? '',
      confidenceTitle: map['confidenceTitle'] ?? '',
      confidenceP1: map['confidenceP1'] ?? '',
      confidenceP2: map['confidenceP2'] ?? '',
      readyImage: map['readyImage'] ?? '',
      readyTitle: map['readyTitle'] ?? '',
      readyP1: map['readyP1'] ?? '',
      readyP2: map['readyP2'] ?? '',
      meetImage: map['meetImage'] ?? '',
      meetTitle: map['meetTitle'] ?? '',
      meetUser: map['meetUser'] ?? '',
      meetP1: map['meetP1'] ?? '',
      meetP2: map['meetP2'] ?? '',
      meetP3: map['meetP3'] ?? '',
      successImage1: map['successImage1'] ?? '',
      successImage2: map['successImage2'] ?? '',
      successImage3: map['successImage3'] ?? '',
      successTitle: map['successTitle'] ?? '',
      successP1: map['successP1'] ?? '',
      successP2: map['successP2'] ?? '',
      successP3: map['successP3'] ?? '',
      experienceImage: map['experienceImage'] ?? '',
      experienceTitle: map['experienceTitle'] ?? '',
      experienceP1: map['experienceP1'] ?? '',
      experienceP2: map['experienceP2'] ?? '',
      experienceP3: map['experienceP3'] ?? '',
      experienceP4: map['experienceP4'] ?? '',
      facebookUrl: map['facebookUrl'] ?? '',
      instagramUrl: map['instagramUrl'] ?? '',
      twitterUrl: map['twitterUrl'] ?? '',
      linkedinUrl: map['linkedinUrl'] ?? '',
      googleUrl: map['googleUrl'] ?? '',
      appleUrl: map['appleUrl'] ?? '',
      appIcon: map['appIcon'] ?? '',
      copyright: map['copyright'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory HomePageModel.fromJson(String source) =>
      HomePageModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'HomePageModel( logo: $logo, company: $company, appName: $appName, heroImage: $heroImage, heroTitle: $heroTitle, heroDescription: $heroDescription, confidenceImage: $confidenceImage, confidenceTitle: $confidenceTitle, confidenceP1: $confidenceP1, confidenceP2: $confidenceP2, readyImage: $readyImage, readyTitle: $readyTitle, readyP1: $readyP1, readyP2: $readyP2, meetImage: $meetImage, meetTitle: $meetTitle, meetUser: $meetUser, meetP1: $meetP1, meetP2: $meetP2, meetP3: $meetP3, successImage1: $successImage1, successImage2: $successImage2, successImage3: $successImage3, successTitle: $successTitle, successP1: $successP1, successP2: $successP2, successP3: $successP3, experienceImage: $experienceImage, experienceTitle: $experienceTitle, experienceP1: $experienceP1, experienceP2: $experienceP2, experienceP3: $experienceP3, experienceP4: $experienceP4, facebookUrl: $facebookUrl, instagramUrl: $instagramUrl, twitterUrl: $twitterUrl, linkedinUrl: $linkedinUrl, googleUrl: $googleUrl, appleUrl: $appleUrl, appIcon: $appIcon, copyright: $copyright, )';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HomePageModel &&
        other.logo == logo &&
        other.company == company &&
        other.appName == appName &&
        other.heroImage == heroImage &&
        other.heroTitle == heroTitle &&
        other.heroDescription == heroDescription &&
        other.confidenceImage == confidenceImage &&
        other.confidenceTitle == confidenceTitle &&
        other.confidenceP1 == confidenceP1 &&
        other.confidenceP2 == confidenceP2 &&
        other.readyImage == readyImage &&
        other.readyTitle == readyTitle &&
        other.readyP1 == readyP1 &&
        other.readyP2 == readyP2 &&
        other.meetImage == meetImage &&
        other.meetTitle == meetTitle &&
        other.meetUser == meetUser &&
        other.meetP1 == meetP1 &&
        other.meetP2 == meetP2 &&
        other.meetP3 == meetP3 &&
        other.successImage1 == successImage1 &&
        other.successImage2 == successImage2 &&
        other.successImage3 == successImage3 &&
        other.successTitle == successTitle &&
        other.successP1 == successP1 &&
        other.successP2 == successP2 &&
        other.successP3 == successP3 &&
        other.experienceImage == experienceImage &&
        other.experienceTitle == experienceTitle &&
        other.experienceP1 == experienceP1 &&
        other.experienceP2 == experienceP2 &&
        other.experienceP3 == experienceP3 &&
        other.experienceP4 == experienceP4 &&
        other.facebookUrl == facebookUrl &&
        other.instagramUrl == instagramUrl &&
        other.twitterUrl == twitterUrl &&
        other.linkedinUrl == linkedinUrl &&
        other.googleUrl == googleUrl &&
        other.appleUrl == appleUrl &&
        other.appIcon == appIcon &&
        other.copyright == copyright;
  }

  @override
  int get hashCode {
    return logo.hashCode ^
        heroImage.hashCode ^
        heroTitle.hashCode ^
        heroDescription.hashCode ^
        confidenceImage.hashCode ^
        confidenceTitle.hashCode ^
        confidenceP1.hashCode ^
        confidenceP2.hashCode ^
        readyImage.hashCode ^
        readyTitle.hashCode ^
        readyP1.hashCode ^
        readyP2.hashCode ^
        meetImage.hashCode ^
        meetTitle.hashCode ^
        meetUser.hashCode ^
        meetP1.hashCode ^
        meetP2.hashCode ^
        meetP3.hashCode ^
        successImage1.hashCode ^
        successImage2.hashCode ^
        successImage3.hashCode ^
        successTitle.hashCode ^
        successP1.hashCode ^
        successP2.hashCode ^
        successP3.hashCode ^
        experienceImage.hashCode ^
        experienceTitle.hashCode ^
        experienceP1.hashCode ^
        experienceP2.hashCode ^
        experienceP3.hashCode ^
        experienceP4.hashCode ^
        facebookUrl.hashCode ^
        instagramUrl.hashCode ^
        twitterUrl.hashCode ^
        linkedinUrl.hashCode ^
        googleUrl.hashCode ^
        appleUrl.hashCode ^
        appIcon.hashCode ^
        copyright.hashCode;
  }
}
