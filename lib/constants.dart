// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lamatdating/helpers/database_keys.dart';

import 'package:lamatdating/models/app_settings_model.dart';
import 'package:lamatdating/models/country_code.dart';
import 'package:lamatdating/models/user_account_settings_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';

const String Appname = '𝓵𝓪𝓶𝓪𝓽';

const bool isDemo = false;

const bool showRestartButton = false;

const bool bitmuk = true;

const bool stripe = true;

const bool flutterwave = true;

const bool momo = false;

const bool paypal = true;

const bool paystack = true;

const bool isGoogleAuthAvailable = false;

const bool isEmailLoginAvailable = false;

const bool isEmailRegAvailable = false;

const bool isFacebookAuthAvailable = false;

const bool isPhoneAuthAvailable = true;

const String troubleSignInUrl = "https://lamatt.web.app/";

const String numberChangeUrl = "https://lamatt.web.app/";

const bool isCompanyHasFAQ = true;

const bool isCompanyHasAbout = true;

const bool isCompanyHasContact = true;

const String locationApiKey = "XXXXXXXXXXXXXXXXXXX";

const String reCaptchaSiteKey = "XXXXXXXXXXXXXXXXXXX";

const bool isAdmobAvailable = true;

const Color colorCallbuttons = AppConstants.primaryColor;

const bool deleteMessaqgeForEveryoneDeleteFromServer = true;

const int ImageQualityCompress = 50;

const int DpImageQualityCompress = 34;

const bool IsVideoQualityCompress = true;

int maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading = 25;

int maxAdFailedLoadAttempts = 3;

const int timeOutSeconds = 50;

const IsShowNativeTimDate = true;

const IsShowDeleteChatOption = true;

const IsRemovePhoneNumberFromCallingPageWhenOnCall = true;

const OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe = false;

const DEFAULT_LANGUAGE_FILE_CODE = 'en';

const IsShowLanguageNameInNativeLanguage = false;

const IsShowUserFullNameAsSavedInYourContacts = false;

const IsShowGIFsenderButtonByGIPHY = true;

const IsShowSearchTab = true;

const textInSendButton = "";

const AgoraVideoResultionWIDTH = 1920;

const AgoraVideoResultionHEIGHT = 1080;

const IsHIDELightDarkModeSwitchInApp = false;

const IsShowLightDarkModeSwitchInLoginScreen = true;

const IsShowTextLabelsInPhotoVideoEditorPage = true;

const int MaxTextlettersInStatus = 200;

const int ContactsSearchCountBatchSize = 150;

const IsShowLanguageChangeButtonInLoginAndHome = true;

// Boosts Costs
const oneBoostCost = 19.99;
const popularBoostCost = 20.99;
const bestValueCost = 90.99;
const popularBoostAmount = 7;
const bestValueBoostAmount = 30;

// Subscriptions Costs
const dailySubCost = 19.99;
const monthlySubCost = 49.99;
const yearlySubCost = 99.99;
const subToUserCost = 500;

//*--Admob Configurations- (By default Test Ad Units pasted)----------
const IsBannerAdShow = true;
// Set this to 'true' if you want to show Banner ads throughout the app
const Admob_BannerAdUnitID_Android = 'ca-app-pub-3940256099942544/6300978111';
// Test Id: 'ca-app-pub-3940256099942544/6300978111'
const Admob_BannerAdUnitID_Ios = 'ca-app-pub-3940256099942544/2934735716';
// Test Id: 'ca-app-pub-3940256099942544/2934735716'
const IsInterstitialAdShow = true;
// Set this to 'true' if you want to show Interstitial ads throughout the app
const InterstitialUnit_Android = 'ca-app-pub-3940256099942544/1033173712';
// Test Id:  'ca-app-pub-3940256099942544/1033173712'
const InterstitialUnit_IOS = 'ca-app-pub-3940256099942544/4411468910';
// Test Id: 'ca-app-pub-3940256099942544/4411468910'
const IsVideoAdShow = true;
// Set this to 'true' if you want to show Video ads throughout the app
const RewardedAdUnit_Android = 'ca-app-pub-3940256099942544/5224354917';
// Test Id: 'ca-app-pub-3940256099942544/5224354917'
const RewardedAdUnit_IOS = 'ca-app-pub-3940256099942544/1712485313';
// Test Id: 'ca-app-pub-3940256099942544/1712485313'
//Also don't forget to Change the Admob App Id in "lamat/android/app/src/main/AndroidManifest.xml" & "lamat/ios/Runner/Info.plist"

//*--Agora Configurations---
const Agora_APP_ID = 'XXXXXXXXXXXXXXXXXXX';
// Grab it from: https://www.agora.io/en/
const Agora_Primary_Certificate = 'XXXXXXXXXXXXXXXXXXX';
// Enable the primary certificate for the project and copy & paste the value here.

// *--Giphy Configurations---
const GiphyAPIKey = 'XXXXXXXXXXXXXXXXXXX';
// Grab it from: https://developers.giphy.com/

// *--Google Translation API Configurations---
const GoogleTransalteAPIkey = 'XXXXXXXXXXXXXXXXXXX';
// Set this api key if you want to enable TEXT message translation. Enable the "Cloud Translation API for your Project from the Google Cloud Platform dashboard: https://console.cloud.google.com/marketplace/product/google/translate.googleapis.com. Then go to "Credentials" and create a API key and paste it here. Leave it blank '' if you don't want translate feature in app.

//*--App Configurations---
const DEFAULT_COUNTTRYCODE_ISO = 'RSA';
//default country ISO 2 letter for login screen
const DEFAULT_COUNTTRYCODE_NUMBER = '+27';
//default country code number for login screen
const FONTFAMILY_NAME = 'SFDisplay';
// make sure you have registered the font in pubspec.yaml

const FONTFAMILY_NAME_ONLY_LOGO = '';
// make sure you have registered the font in pubspec.yaml

// Paypal configurations
const Paypal_ClientId = 'PASTE_PAYPAL_CLIENT_ID';
const Paypal_Secret = 'PASTE_PAYPAL_SECRET';
const ReturnUrlSuccess = 'https://www.example.com/return';
const ReturnUrlCancel = 'https://www.example.com/cancel';

// Stripe configurations
const Stripe_PublishableKey = 'PASTE_STRIPE_PUBLISHABLE_KEY';

// Paystack configurations
const PaystackPublicKey = 'XXXXXXXXXXXXXXXXXXX';
const PaystackSecretKey = 'XXXXXXXXXXXXXXXXXXX';

// Flutterwave configurations
const flutterwavePublicKey = "";

// Mtn Momo configurations
const subscriptionKey = 'PASTE_MTN_MOMO_PUBLIC_KEY';
const APIUser = 'PASTE_MTN_MOMO_API_USER';
const partyId = "XXXXXXXXXXXXXXXXXXX";

//--WARNING----- PLEASE DONT EDIT THE BELOW LINES UNLESS YOU ARE A DEVELOPER -------
const SplashPath = 'assets/images/splash.jpeg';
const AppLogoPathDarkModeLogo = 'assets/images/applogo_light.png';
const AppLogoPathLightModeLogo = 'assets/images/applogo_dark.png';

class SubscriptionConstants {
  SubscriptionConstants._();

  static const String appleApiKey = "XXXXXXXXXXXXXXXXXXX";

  static const String googleApiKey = "XXXXXXXXXXXXXXXXXXX";

  static const String entitlementId = "premium";

  static const String userAppId = "XXXXXXXXXXXXXXXXXXX";
}

class AndroidAdUnits {
  AndroidAdUnits._();

  static const String appId = "ca-app-pub-2905260182023832~9665703071";

  static const String bannerId = "ca-app-pub-2905260182023832/2749775088";

  static const String interstitialId = "ca-app-pub-2905260182023832/5184366732";

  static const String rewardedVideoId =
      "ca-app-pub-2905260182023832/2898859337";
}

class IOSAdUnits {
  IOSAdUnits._();

  static const String appId = "admob_ios_app_id";

  static const String bannerId = "admob_ios_banner_id";

  static const String interstitialId = "admob_ios_interstitial_id";

  static const String rewardedVideoId = "admob_ios_rewarded_video_id";
}

class AppConfig {
  AppConfig._();
  //App Name

  //App Web Url
  static const String webAppUrl = "https://lamatt.web.app/";

  //App Web Rating Url
  static const String webAppRatingUrl = "https://lamatt.web.app/";

  // App Currency
  static String currency = 'ZAR';

  //Chat background
  static const String defaultChatBg = "assets/images/chat_bg.png";

  static const List<Color> wallpaperSolidColors = [
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
    Colors.cyan,
    Colors.teal,
    Colors.lime,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.lightBlueAccent,
    Colors.deepOrange,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.grey,
    Colors.white,
  ];

  static const Color dislikeButtonColor = Color.fromARGB(255, 195, 16, 4);

  static const Color superLikeButtonColor = Color.fromARGB(255, 3, 160, 204);

  static const Color likeButtonColor = Color.fromARGB(255, 3, 223, 10);

  static const bool showInteractionButtonText = false;

  static const String likeButtonText = "Like";

  static const String superLikeButtonText = "SuperLike";

  static const String dislikeButtonText = "Dislike";

  static const bool allowTransGender = true;

  static const String maleText = "male";

  static const String femaleText = "female";

  static const String transText = "other";

  static const double initialDistanceInKM = 150;

  static const double initialMaximumDistanceInKM = 40074;

  static const int maximumUserAge = 99;

  static const bool canChangeName = true;

  static const bool canChangeNickName = true;

  static const bool canChangeUserName = true;

  static const bool userProfileShowWithoutImages = false;

  static const int minimumAgeRequired = 18;

  static const int maxNumOfMedia = 15;

  static const int maxNumOfInterests = 10;

  static const List<int> budgets = [
    250,
    500,
    1000,
    1500,
    2000,
    2500,
    3500,
    4500,
    5500,
    6500,
    7500,
    8500,
    9500
  ];

  static const List<String> interests = [
    "pets",
    "exercise",
    "dancing",
    "cooking",
    "politics",
    "sports",
    "photography",
    "art",
    "learning",
    "music",
    "movies",
    "books",
    "gaming",
    "food",
    "fashion",
    "technology",
    "science",
    "health",
    "business",
    "writing",
    "blogging",
    "languages",
    "travel",
    "yoga",
    "volunteering",
    "singing",
    "jokes",
    "shopping",
    "social media",
    "video games",
  ];

  static const List<String> groupstype = [
    Dbkeys.groupTYPEonlyadminmessageallowed,
    Dbkeys.groupTYPEallusersmessageallowed
  ];
}

class AppRes {
  static const String fiftySecond = '15s';
  static const String thirtySecond = '30s';
  static const String imageMessage = '🖼️ Image';
  static const String videoMessage = '🎥 Video';
  static const String hashTag = '#';
  static const String atSign = '@';
  static const String look = 'Look';
  static const String textTotalCount = '2200';
  static const String hintX = 'XX-XXXX-XXXXXXXX';
  static const String boostSingle = "booster_1";
  static const String boostThree = "booster_5";
  static const String boostSeven = "booster_10";
  static const String boostThirty = "booster_15";
  static const String boostSingleIOS = "boost_1";
  static const String boostThreeIOS = "boost_3";
  static const String boostSevenIOS = "boost_7";
  static const String boostThirtyIOS = "boost_30";
  static const String daily = "daily";
  static const String weekly = "weekly";
  static const String monthly = "monthly";

  static int? primaryColor;
  static int? primaryDarkColor;
  static int? secondaryColor;
  static int? secondaryDarkColor;
  static int? tintColor;
  static String? appLogo;
  static String? rewindIconn;
  static String? dislikeIconn;
  static String? likeIconn;
  static String? superLikeIconn;
  static String? boostIconn;
  static String? phoneNumber;
  static double? walletBalance;
  static List<UserProfileModel>? userProfileList;
  static List<CountryCode>? countryCodesData;
  static UserLocation? currentLocationProviderProvider;

  static String redeemTitle(String value) {
    return '1000 Dymonds = $value ${AppConfig.currency}';
  }

  static String whatReport(int value) {
    return 'Report ${value == 1 ? 'Post' : 'User'}';
  }

  static String checkOutThisAmazingProfile(dynamic result) {
    return 'Check out this amazing profile $result 😋😋';
  }

  static String minimumCoinRequired =
      'Minimum ${SettingRes.minFansForLive ?? '0'} fans required to start livestream!';
  static const String privacyPolicy =
      'By continuing, you agree to  $Appname\'s terms of use\nand confirm that you have read our privacy policy.';
  static String selectedLanguage = "";
  static int msgCost = 10;
  static int callCost = 10;
  static int teelReward = 10;
  static int likeRewards = 1;

  static const String isSuccessPurchase = "is_success_purchase";
  static const String hmmA = "h:mm a";
  static const String hhMmA = "hh:mm a";
  static const String dMY = "dd MMM yyyy";
  static const String isHttp = "http://";
  static const String isHttps = "https://";
  static const String reportName = 'reportName';
  static const String reportImage = 'reportImage';
  static const String reportAge = 'reportAge';
  static const String reportAddress = 'reportAddress';
  static const String report = 'Report';
}

class FreemiumLimitation {
  FreemiumLimitation._();

  static const int maxDailyLikeLimitFree = 14;

  static const int maxDailySuperLikeLimitFree = 0;

  static const int maxDailyDislikeLimitFree = 50;

  static const int maxDailyLikeLimitPremium = 100;

  static const int maxDailySuperLikeLimitPremium = 2;

  static const int maxDailyDislikeLimitPremium = 200;

  static const int maxDailyRewindLimitPremium = 5;

  static const int maxMonnthlyBoostLimitPremium = 5;

  static const int maxMonthlySuperLikeLimitPremium = 30;
}

class AppConstants {
  AppConstants._();

  // Colors
  static const Color primaryColor = Color(0xFF6E3DFF);
  static const Color primaryColorDark = Color(0xFF24115E);
  static const Color secondaryColor = Color(0xFFFF6C28);
  static const Color midColor = Color(0xFFFAA108);
  static const Color chatTextFieldAndOtherText = Color(0xFFF4EEEE);
  static const Color chatMyTextColor = Color(0xFFFFC1CA);
  static const Color chatBackground = Color(0xffe8ded5);
  static const Color dialogColorDark = Color(0xFF0A0030);
  static const Color textColor = Colors.white;
  static const Color hintColor = Color(0xFFD8D8D8);
  static const Color textColorLight = Color(0xFF73667E);
  static const Color backgroundColor = Colors.white;
  static const Color backgroundColorDark = Color(0xFF0A0030);
  static const Color textFieldColor = Color.fromARGB(10, 111, 63, 255);
  static const double defaultNumericValue = 16.0;
  static const Color subtitleTextColor = Color(0xFF6B6B6B);
  static const Color onlineStatus = Color(0xFF26F288);
  static const Color lamatWhite = Color(0xffffffff);
  static const Color lamatBlack = Color(0xff1E1E1E);
  static const Color lamatGrey = Color(0xff8596a0);
  static const Color lamatREDbuttonColor = Color(0xffe90b41);
  static const Color lamatCHATBUBBLEcolor = Color(0xffe9fedf);
  static const Color lamatGreenColorAccent = Color(0xff69F0AE);
  static const Color lamatGreenColor100 = Color(0xffC8E6C9);
  static const Color lamatGreenColor200 = Color(0xffA5D6A7);
  static const Color lamatGreenColor300 = Color(0xff81C784);
  static const Color lamatGreenColor400 = Color(0xff66BB6A);
  static const Color lamatGreenColor500 = Color(0xff4CAF50);

  // Images
  static const String logo = 'assets/logos/logo.png';
  static const String liveStream = 'assets/images/livestream.png';
  static const String symbol = 'assets/logos/symbol-wh.png';
  static const String symbolColor = 'assets/logos/symbol-cl.png';
  static const String agoraAppId = '51c051a260a849088b1a063b0c58cdc3';
  static const String splashAnimDark = 'assets/logos/logo-anim.gif';
  static const String splashAnim = 'assets/logos/logo-slimmed.json';
  static const String splashAnimLight = 'assets/logos/logo-anim.gif';
  static const String splashBg = 'assets/images/backgroud.png';
  static const String splashBgDark = 'assets/images/backgroud-dark.png';
  static const String ppPlaceHolder =
      'https://static.vecteezy.com/system/resources/previews/004/509/264/original/profile-placeholder-default-female-avatar-vector.jpg';

  // Gradients
  static LinearGradient defaultGradient = LinearGradient(
    colors: [
      primaryColor.withOpacity(0.8),
      primaryColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient secondaryGradient = LinearGradient(
    colors: [
      secondaryColor.withOpacity(0.8),
      secondaryColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static LinearGradient premiumGradient = const LinearGradient(
    colors: [
      primaryColor,
      midColor,
      secondaryColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class SettingRes {
  static String? admobBanner = '';
  static String? admobInt = '';
  static String? admobIntIos = '';
  static String? admobBannerIos = '';
  static int? maxUploadDaily = 0;
  static int? liveMinViewers = 0;
  static int? liveTimeout = 0;
  static int? rewardVideoUpload = 0;
  static int? minFansForLive = 0;
  static int? minFansVerification = 0;
  static int? minRedeemCoins = 0;
  static double? coinValue = 0.0;
  static String? currency = 'ZAR';
  static String agoraAppId = 'XXXXXXXXXXXXXXXXXXX';
  static List<Gifts>? gifts = [];
}

class AgoraRes {
  static String channelName = "";
  static String token = "";
}

class FirebaseConstants {
  FirebaseConstants._();

  static const String userProfileCollection = "userProfile";
  static const String userInteractionCollection = "userInteraction";
  static const String matchCollection = "matches";
  static const String chatCollection = "chat";
  static const String verificationFormsCollection = "verificationForms";
  static const String feedsCollection = "feeds";
  static const String meetingsCollection = "meetings";
  static const String deviceTokensCollection = "deviceTokens";
  static const String notificationsCollection = "notifications";
  static const String blockedUsersCollection = "blockedUsers";
  static const String reportsCollection = "reports";
  static const String bannedUsersCollection = "bannedUsers";
  static const String accountDeleteRequestCollection = "accountDeleteRequest";
  static const String appSettingsCollection = "appSettings";
  static const String storiesCollection = "stories";
  static const String teelsCollection = "teels";
  static const String walletsCollection = "wallets";
  static const String hashtags = 'hashtags';
  static const String soundList = 'soundList';
  static const String withdrawalsCollection = 'withdrawals';
  static const String liveBattleInvites = 'liveBattleInvites';
}

class FirebaseConst {
  static const String userChatList = 'userChatList';
  static const String userList = 'userList';
  static const String time = 'time';
  static const String lastMsg = 'lastMsg';
  static const String image = 'image';
  static const String video = 'video';
  static const String user = 'user';
  static const String chat = 'chat';
  static const String chatList = 'chatList';
  static const String blockFromOther = 'blockFromOther';
  static const String block = 'block';
  static const String noDeletedId = 'not_deleted_identities';
  static const String liveStreamUser = 'liveStreamUser';
  static const String id = 'id';
  static const String comment = 'comment';
  static const String watchingCount = 'watchingCount';
  static const String collectedDiamond = 'collectedDiamond';
  static const String timing = 'timing';
  static const String watching = 'watching';
  static const String collected = 'collected';
  static const String profileImage = 'profileImage';
  static const String joinedUser = 'joinedUser';
  static const String isDeleted = 'isDeleted';
  static const String deletedId = 'deletedId';
  static const String msg = 'msg';
  static const String hashtags = 'hashtags';
}

class HiveConstants {
  HiveConstants._();

  static const String hiveBox = "hiveBox";
  static const String chatWallpaper = "chatWallpaper";
  static const String showCompleteDialog = "showCompleteDialog";
  static const String guidedTour = "guidedTour";
  static const String cachedProfiles = "cachedProfiles";
  static const String cachedInterationFilter = "cachedInterationFilter";
  static const String cachedFeeds = "cachedFeeds";
  static const String currentUserProf = "currentUserProf";
  static const String userSet = "userSet";
  static const String allOtherUsersKey = "all_other_users_unfiltered";
  static const String lastUpdatedKey = "last_all_users_update";
  static const String lastUserProfileUpdatedKey = "last_user_profile_update";
  static const String agoraToken = "agora_token";
  static const String agoraChannelId = "agora_channel_id";
}

///Json
const String countryCodeJson = "assets/json/country_code.json";

/// Lottie Json
const String lottieNoItemFound = "assets/json/lottie/no_item_found.json";
const String lottieSearch = "assets/json/searching.json";
const String loadingDiam = 'assets/images/animation_diamond.json';
const icCrushAnimation = 'assets/json/lottie/heart_anim.json';
const doubleTap = 'assets/json/lottie/double_tap.json';

///Icons

const String lamatStarIcon = 'assets/icons/lamatAlt.svg';
const String dislikeIconAlt = "assets/icons/nope.png";
const String rewindIconAlt = "assets/icons/rewind.png";
const String superLikeIcon = "assets/icons/superlike.svg";
const String superLikeIconAlt = "assets/icons/superlike.png";
const String likeIcon = "assets/icons/heart-filled.svg";
const String emptyLikeIcon = "assets/icons/heart.svg";
const String likeIconAlt = "assets/icons/like.gif";
const String boltIcon = "assets/icons/bolt.svg";
const String boltIconAlt = "assets/icons/bolt.png";
const String appleLogo = "assets/images/apple.png";
const String facebookLogo = "assets/images/facebook.png";
const String googleLogo = "assets/images/google.png";
const String twitterLogo = "assets/images/twitter.png";
const String appleLogoSvg = "assets/images/apple.svg";
const String googleLogoSvg = "assets/images/google.svg";
const String emailLogoSvg = "assets/images/email.svg";
const String phoneLogoSvg = "assets/icons/phone.svg";
const String translateSvg = "assets/icons/translate.svg";
const String facebookLogoSvg = "assets/icons/facebook.svg";
const String instagramLogo = "assets/icons/instagram.svg";
const String leftArrowSvg = "assets/icons/arrow-left.svg";
const String downArrowAlt = "assets/icons/alt-arrow-down.svg";
const String paperplaneIcon = "assets/icons/paperplane.svg";
const String ellipsisIcon = "assets/icons/ellipsis.svg";
const String bellIcon = "assets/icons/bell.svg";
const String mailIcon = "assets/icons/messages.svg";
const String mailActiveIcon = "assets/icons/messagesfilled.svg";
const String profileIcon = "assets/icons/profile.svg";
const String profileActiveIcon = "assets/icons/profile-filled.svg";
const String feedsIcon = "assets/icons/feed.svg";
const String feedsActiveIcon = "assets/icons/feedfilled.svg";
const String filterIcon = "assets/icons/filter.svg";
const String rightArrowIcon = "assets/icons/arrow-right.svg";
const String searchIcon = "assets/icons/search.svg";
const String questionIcon = "assets/icons/question.svg";
const String closeIcon = "assets/icons/close.svg";
const String profilePic = "assets/logos/profile_pic.png";
const String editIcon = "assets/icons/edit.svg";
const String pinIcon = "assets/icons/pin.svg";
const String homeIcon = "assets/icons/lamat.svg";
const String imgIcon = "assets/icons/img.svg";
const String verifiedIcon = "assets/icons/verified.png";
const String icPurpleHeart = "assets/icons/light_pink_heart.png";
const String gridIcon = "assets/icons/grid.svg";
const String reelsIcon = "assets/icons/teels.svg";
const String reelsActiveIcon = "assets/icons/teelsfilled.svg";
const String liveIcon = "assets/icons/live.svg";
const String livestreamIcon = "assets/icons/livestream.svg";
const String addvideoIcon = "assets/icons/addvideo.svg";
const String walletIcon = "assets/icons/wallet.svg";
const String houseIcon = "assets/icons/home.svg";
const String boostedIcon = "assets/icons/boosted.svg";
const String likeAnim = "assets/icons/like_animation.json";
const String dislikeAnim = "assets/icons/dislike_animation.json";
const String giftIcon = "assets/icons/gift.svg";
const String giftBoldIcon = "assets/icons/gift-bold.svg";
const String commentIcon = "assets/icons/comment.svg";
const String itsAMatch = "assets/icons/itsamatch.gif";
const String niceAnim = "assets/icons/nice.json";
const String nopeAnim = "assets/icons/nope-anim.json";
const String niceAnim2 = "assets/icons/crush-anim2.json";
const String nopeAnim2 = "assets/icons/nope-anim2.json";
const String commentIconFilled = "assets/icons/chat.svg";
const String favIcon = "assets/icons/favorite.svg";
const String shareIcon = "assets/icons/share.svg";
const String addIcon = "assets/icons/addIcon.svg";
const String icBgDisk = 'assets/icons/bg_disk.png';
const String icMusic = 'assets/icons/music.png';
const String musicIcon = "assets/icons/music.svg";
const String menuIcon = "assets/icons/menu.svg";
const String addVideoIcon = "assets/icons/add-video.svg";
const String openProfileIcon = "assets/icons/open_profile.svg";
const String cameraIcon = "assets/icons/camera.svg";
const String emojiIcon = "assets/icons/emoji.svg";
const String fileIcon = "assets/icons/file.svg";
const String flipCameraIcon = "assets/icons/flip-camera.svg";
const String galleryIcon = "assets/icons/gallery.svg";
const String microphoneIcon = "assets/icons/microphone.svg";
const String recordVideoIcon = "assets/icons/record-video.svg";
const String stickersIcon = "assets/icons/stickers.svg";
const String videoIcon = "assets/icons/video.svg";
const String phoneCallIcon = "assets/icons/phone-call.svg";
const String giftFilledIcon = "assets/icons/gift-filled.svg";
const String contactsPermAnim = "assets/icons/contacts-perm.json";
const String textIcon = "assets/icons/text.svg";
const String upwardArrow = "assets/icons/Upward-arrow.svg";
const String settingsIcon = "assets/icons/settings.svg";
const String settingsLinearIcon = "assets/icons/settings-linear.svg";
const String hidenIcon = "assets/icons/hiden.svg";
const String unhidenIcon = "assets/icons/unhiden.svg";
const String cardDotsIcon = "assets/icons/card-dots.svg";
const String transactionsIcon = "assets/icons/transactions.svg";
const String meetupIcon = "assets/icons/meetup.svg";
const String logoutIcon = "assets/icons/logout.svg";
const String micOnIcon = "assets/icons/mic-on.svg";
const String micOffIcon = "assets/icons/mic-off.svg";
const String singerIcon = "assets/icons/singer.svg";
const String downloadIcon = "assets/icons/download.svg";
const String qrCodeIcon = "assets/icons/qrcode.svg";
const String vsIcon = "assets/icons/vs_icon.svg";
const String coinsIcon = "assets/images/premium.gif";
const String crownIcon = "assets/icons/crown-star.svg";

// const String videoCallIcon = "assets/icons/video-call.svg";
// const String callIcon = "assets/icons/call.svg";
// const String callFilledIcon = "assets/icons/call-filled.svg";
// const String callMissedIcon = "assets/icons/call-missed.svg";
// const String callMissedFilledIcon = "assets/icons/call-missed-filled.svg";

/// Images
const String chatBgLight = 'assets/images/chat_bg.jpg';
const String chatBgDark = 'assets/images/chat_bg_dark.png';
const icLogo = 'assets/logos/logo.png';
const icMalaika = 'assets/images/common/p3.jpg';
const icMalaika2 = 'assets/images/common/profile17.png';
const icUserPlaceHolder = "assets/images/user_placeholder.png";
const loading_gif = "assets/logos/loading_pic.gif";

const isNotificationOn = 'is_notification_on';

//Image Quality
const double maxWidth = 1080;
const double maxHeight = 1080;
const int quality = 100;

//FontName
const fNSfUiBold = 'SfUiBold';
const fNSfUiRegular = 'SfUiRegular';
const fNSfUiMedium = 'SfUiMedium';
const fNSfUiLight = 'SfUiLight';
const fNSfUiSemiBold = 'SfUiSemiBold';
const fNSfUiHeavy = 'SfUiHeavy';

//Strings
const byFlutterMaster = 'By $Appname';
const following = 'Following';
const forYou = 'For You';
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'lamat', // id
  'Notification',
  importance: Importance.max,
);

const List<String> paymentMethods = ['Paystack', 'Paypal', 'Other'];
const List<String> reportReasons = [
  'Inappropriate',
  'Nudity',
  'Spam',
  'Fake',
  'Deceased',
  'Impersonation',
  'Privacy',
  'Vandalism',
  'Abandoned Profile',
  'Other'
];

class ConstRes {
  static const int count = 10;

  static const String isLogin = "is_login";

  static const String favourite = 'favourite';

  static const String camera = '';

  static const String lamatCamera = 'lamat_camera';

  static const String isAccepted = 'is_accepted';

  static const bool isDialog = true;
}
