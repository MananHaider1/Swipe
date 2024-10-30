// ignore_for_file: unused_field, no_leading_underscores_for_local_identifiers, deprecated_member_use, unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_translate/components/google_translate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/models/data_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/animated_splash/splash_anim.dart';
import 'package:lamatdating/views/landing_page/landing_page.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_scr/pre_chat.dart';
import 'package:lamatdating/views/tabs/home/notification_page.dart';
import 'package:lamatdating/views/tabs/profile/first_time_update_profile_page.dart'
    if (dart.library.html) 'package:lamatdating/views/tabs/profile/first_time_update_profile_page_web.dart';
import 'package:localstorage/localstorage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lamatdating/firebase_options.dart';
import 'package:lamatdating/helpers/config_loading.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/key_res.dart';
import 'package:lamatdating/helpers/session_manager.dart';
import 'package:lamatdating/providers/app_settings_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/broadcast_provider.dart';
import 'package:lamatdating/providers/group_chat_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/auth/login_page.dart';
import 'package:lamatdating/views/tabs/bottom_nav_bar_page.dart';
import 'package:lamatdating/views/tabs/chat/chat_home.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data['title'] == 'Call Ended' ||
      message.data['title'] == 'Missed Call') {
    flutterLocalNotificationsPlugin.cancelAll();
    final data = message.data;
    final titleMultilang = data['titleMultilang'];
    final bodyMultilang = data['bodyMultilang'];

    await showNotificationWithDefaultSound(
        'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
  } else {
    if (message.data['title'] == 'You have message(s)' ||
        message.data['title'] == 'message in Group') {
      //-- need not to do anythig for these message type as it will be automatically popped up.
    } else if (message.data['title'] == 'Incoming Audio Call...' ||
        message.data['title'] == 'Incoming Video Call...') {
      final data = message.data;
      final title = data['title'];
      final body = data['body'];
      final titleMultilang = data['titleMultilang'];
      final bodyMultilang = data['bodyMultilang'];

      await showNotificationWithDefaultSound(
          title, body, titleMultilang, bodyMultilang);
    }
  }

  return Future<void>.value();
}

DocumentSnapshot<Map<String, dynamic>>? docu;

SessionManager sessionManager = SessionManager();

final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
final FirebaseBroadcastServices firebaseBroadcastServices =
    FirebaseBroadcastServices();

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final broadcastsListProvider = StreamProvider<List<BroadcastModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseBroadcastServices.getBroadcastsList(phone);
});

final groupsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getGroupsList(phone);
});

final channelsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getChannelsList(phone);
});

final allChannelsListProvider = StreamProvider<List<GroupModel>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  final phone = prefs?.getString(Dbkeys.phone) ?? '';
  return firebaseGroupServices.getAllChannelsList(phone);
});

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  final WidgetsBinding binds = WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // FlutterBranchSdk.initSession();

  // FlutterBranchSdk.validateSDKIntegration();

  binds.renderView.automaticSystemUiAdjustment = false;

  FlutterNativeSplash.preserve(widgetsBinding: binds);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
      // argument for `webProvider`
      webProvider: ReCaptchaV3Provider(reCaptchaSiteKey),
      // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Safety Net provider
      // 3. Play Integrity provider
      androidProvider: AndroidProvider.playIntegrity,
      // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
      // your preferred provider. Choose from:
      // 1. Debug provider
      // 2. Device Check provider
      // 3. App Attest provider
      // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
      appleProvider: AppleProvider.deviceCheck,
    );
  }

  if (!kIsWeb) {
    await FlutterDownloader.initialize(
      ignoreSsl: true,
    );
  }
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
  }
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);
  }

  GoogleTranslate.initialize(
    apiKey: GoogleTransalteAPIkey,
    sourceLanguage: "",
    targetLanguage: "",
  );

  if (IsBannerAdShow == true && kIsWeb == false ||
      IsInterstitialAdShow == true && kIsWeb == false ||
      IsVideoAdShow == true && kIsWeb == false ||
      isAdmobAvailable == true && kIsWeb == false) {
    MobileAds.instance.initialize();
  }

  await Hive.initFlutter();
  await Hive.openBox(HiveConstants.hiveBox);
  await initLocalStorage();

  if (!kIsWeb) {
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: '2022',
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel for basic tests',
              defaultColor: AppConstants.primaryColor,
              ledColor: Colors.white)
        ],
        debug: false);
  }

  Stripe.publishableKey = Stripe_PublishableKey;

  await dotenv.load(fileName: 'assets/.env');

  configLoading(
    isDarkMode: false,
    foregroundColor: AppConstants.primaryColor,
    backgroundColor: Colors.white,
  );
  if (!kIsWeb) {
    await FlutterBranchSdk.init(enableLogging: true, disableTracking: false);
  }
  await sessionManager.initPref();

  String? languageCode = sessionManager.getString(KeyRes.languageCode);

  if (languageCode == "" || languageCode == " ") {
    AppRes.selectedLanguage = "en";
  } else {
    AppRes.selectedLanguage =
        sessionManager.getString(KeyRes.languageCode) ?? "en";
  }

  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
          Locale('da'),
          Locale('de'),
          Locale('el'),
          Locale('es'),
          Locale('fr'),
          Locale('hi'),
          Locale('id'),
          Locale('it'),
          Locale('ja'),
          Locale('ko'),
          Locale('nb'),
          Locale('nl'),
          Locale('pl'),
          Locale('pt'),
          Locale('ru'),
          Locale('th'),
          Locale('tr'),
          Locale('vi'),
          Locale('zh'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(child: MyApp())));
  });
}

class MyApp extends ConsumerStatefulWidget {
  static var navigatorKey = GlobalKey<NavigatorState>();

  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => MyAppState();

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

class MyAppState extends ConsumerState<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  Box<dynamic>? box;
  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  SharedPreferences? prefs;

  @override
  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    if (!kIsWeb) {
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: (ReceivedAction receivedAction) async {
          await NotificationController.onActionReceivedMethod(
              context, receivedAction);
        },
        onNotificationCreatedMethod:
            (ReceivedNotification receivedNotification) async {
          await NotificationController.onNotificationCreatedMethod(
              context, receivedNotification);
        },
        onNotificationDisplayedMethod:
            (ReceivedNotification receivedNotification) async {
          await NotificationController.onNotificationDisplayedMethod(
              context, receivedNotification);
        },
        onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
          await NotificationController.onDismissActionReceivedMethod(
              context, receivedAction);
        },
      );
    }
    box = Hive.box(HiveConstants.hiveBox);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      prefs = ref.watch(sharedPreferencesProvider).value;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));

    final darkTheme = ref.watch(darkThemeProvider);

    return OKToast(
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        title: Appname,
        debugShowCheckedModeBanner: false,
        builder: EasyLoading.init(),
        theme: Styles.themeData(darkTheme == true ? true : false, context),
        home: SelectionArea(child: SplashScreen(prefss: prefs)),
      ),
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  final SharedPreferences? prefss;
  const SplashScreen({
    super.key,
    this.prefss,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.watch(sharedPreferencesProvider).value;
      final themeChange = ref.watch(darkThemeProvider.notifier);

      Future.delayed(const Duration(seconds: 4), () {
        if (widget.prefss != null || prefs != null) {
          themeChange.darkTheme = Teme.isDarktheme(widget.prefss ?? prefs!);
        }
        Navigator.pushReplacement(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: const LandingWidget()));
      });
      Future.delayed(const Duration(seconds: 1), () {
        FlutterNativeSplash.remove();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(AppConstants.splashBg), fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              GifView.asset(
                AppConstants.splashAnimLight,
                height: 150,
                width: 200,
                frameRate: 60, // default is 15 FPS
              ),
              const Spacer(),
            ],
          )),
        ),
      ),
    );
  }
}

class LandingWidget extends ConsumerStatefulWidget {
  const LandingWidget({
    super.key,
  });

  @override
  ConsumerState<LandingWidget> createState() => _LandingWidgetState();
}

class _LandingWidgetState extends ConsumerState<LandingWidget> {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final fireIns = FirebaseFirestore.instance;
  Box<dynamic>? box;
  bool showSplash = true;

  @override
  void initState() {
    box = Hive.box(HiveConstants.hiveBox);

    _setupInteractedMessage();
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      showNotification(message);
    });
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });

    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> initialise() async {
    return await fireIns.collection("appSettings").doc("userapp").get();
  }

  Future<void> _setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    final prefss = ref.watch(sharedPreferencesProvider).value!;
    final cachedModel = DataModel(prefss.getString(Dbkeys.phone));
    if (message.data['type'] == 'message') {
      final otherUserId = message.data["phoneNumber"]!;
      final matchId = message.data["matchId"]!;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PreChat(
            name: otherUserId,
            phone: otherUserId,
            currentUserNo: ref.watch(currentUserStateProvider)!.phoneNumber,
            model: cachedModel,
            prefs: prefss,
          ),
        ),
      );
    } else if (message.data['type'] == 'notification') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationPage(),
        ),
      );
    }
  }

  bool userSet = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final authState = ref.watch(authStateProvider);
    final prefss = ref.watch(sharedPreferencesProvider).value;
    final phone = prefss?.getString(Dbkeys.phone) ?? '';
    final appSettingsSnapshot = ref.watch(appSettingsDocProvider);
    final doc = appSettingsSnapshot.value;
    final settings = ref.watch(appSettingsProvider).value;
    final userProfileRef = ref.watch(userProfileFutureProvider);

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: [
          authState.when(
            data: (data) {
              if (data != null) {
                debugPrint("Phone Start ==>: ${data.phoneNumber}");
                if (doc == null || settings == null) {
                  if (doc == null) {
                    debugPrint("Doc is null");
                  }
                  if (settings == null) {
                    debugPrint("Settings is null");
                  }
                  return const SplashAnimPage();
                } else {
                  if (prefss == null) {
                    if (prefss == null) {
                      debugPrint("Prefs is null");
                    }
                    return const SplashAnimPage();
                  } else {
                    if (data.phoneNumber == "" || data.phoneNumber == null) {
                      showSplash = false;
                      return PhoneLoginLandingWidget(
                        phoneNumber: "",
                        user: data,
                        isVerifying: true,
                        prefs: prefss,
                        accountApprovalMessage:
                            doc[Dbkeys.accountapprovalmessage],
                        isaccountapprovalbyadminneeded:
                            doc.data()![Dbkeys.isblocknewlogins],
                        isblocknewlogins: doc.data()![Dbkeys.isblocknewlogins],
                        title: LocaleKeys.verifyPhone.tr(),
                        doc: doc,
                      );
                    } else {
                      userSet = boxMain.get(HiveConstants.userSet) == null
                          ? false
                          : boxMain.get(HiveConstants.userSet) as bool;
                      box!.put(Dbkeys.phone, data.phoneNumber!);
                      debugPrint("Phone End ==>: ${data.phoneNumber}");
                      if (userSet) {
                        debugPrint("userSet 1 ===> $userSet");
                        final user = userProfileRef.value;
                        final userProf = UserProfileModel.fromJson(
                            boxMain.get(HiveConstants.currentUserProf));
                        debugPrint("userSet 2 ===> $userSet");

                        showSplash = false;
                        return BottomNavBarPage(
                            currentUser: userProf,
                            user: data,
                            prefs: prefss,
                            doc: doc,
                            phoneNumber: data.phoneNumber!,
                            phone: phone);
                      } else {
                        showSplash = false;
                        return FirstTimeUserProfilePage(prefs: prefss);
                      }
                    }
                  }
                }
              } else {
                if (doc == null || settings == null) {
                  return const SplashAnimPage();
                } else {
                  final isHomePageEnabled = settings.isHomePageEnabled ?? false;
                  if (kIsWeb && isHomePageEnabled && Responsive.isDesktop(context)) {
                    showSplash = false;
                    return WebHomePage(
                      prefs: prefss!,
                      accountApprovalMessage:
                          doc[Dbkeys.accountapprovalmessage],
                      isaccountapprovalbyadminneeded:
                          doc.data()![Dbkeys.isblocknewlogins],
                      isblocknewlogins: doc.data()![Dbkeys.isblocknewlogins],
                      title: 'signIn'.tr(),
                      doc: doc,
                    );
                  } else {
                    showSplash = false;
                    return LoginPage(
                      prefs: prefss!,
                      accountApprovalMessage:
                          doc[Dbkeys.accountapprovalmessage],
                      isaccountapprovalbyadminneeded:
                          doc.data()![Dbkeys.isblocknewlogins],
                      isblocknewlogins: doc.data()![Dbkeys.isblocknewlogins],
                      title: 'signIn'.tr(),
                      doc: doc,
                    );
                  }
                }
              }
            },
            error: (_, e) {
              return const ErrorPage();
            },
            loading: () => const SplashAnimPage(),
          ),
          if (showSplash)
            AnimatedContainer(
              height: height,
              width: width,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppConstants.splashBg),
                      fit: BoxFit.cover)),
              child: Padding(
                padding:
                    const EdgeInsets.all(AppConstants.defaultNumericValue * 2),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    GifView.asset(
                      AppConstants.splashAnimLight,
                      height: 150,
                      width: 200,
                      frameRate: 60, // default is 15 FPS
                    ),
                    const Spacer(),
                  ],
                )),
              ),
            ),
          if (showRestartButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                  onPressed: () async {
                    await Restart.restartApp();
                  },
                  child: const Icon(Icons.refresh)),
            ),
        ],
      ),
    );
  }
}

Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();
  showNotification(message);
}

void showNotification(RemoteMessage message) {
  debugPrint("Notification type: ${message.data["type"]}");
  debugPrint("Other User Id ${message.data["phoneNumber"]}");
  debugPrint("MatchId ${message.data["matchId"]}");

  if (!kIsWeb) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.data["id"],
        channelKey: '2022', // Configure your notification channel
        title: message.data["title"],
        body: message.data["body"],
        roundedBigPicture: message.data["image"],
        wakeUpScreen: true,
      ),
    );
  }
  // showDialog(
  //     context: context,
  //     builder: (context) => Container(
  //           decoration: BoxDecoration(
  //             color: Teme.isDarktheme(prefs)
  //                 ? AppConstants.backgroundColorDark
  //                 : AppConstants.backgroundColor,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           width: MediaQuery.of(context).size.width * .8,
  //           height: MediaQuery.of(context).size.width,
  //           padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircleAvatar(
  //                 radius: 50,
  //                 backgroundImage: NetworkImage(message.data["image"]),
  //               ),
  //               const SizedBox(height: AppConstants.defaultNumericValue),
  //               Text(message.data["title"], style: Theme.of(context).textTheme.titleLarge),
  //               const SizedBox(height: AppConstants.defaultNumericValue),
  //               Text(message.data["body"], style: Theme.of(context).textTheme.bodyMedium),
  //               const SizedBox(height: AppConstants.defaultNumericValue),
  //               // Text(item.!, style: Theme.of(context).textTheme.bodyMedium),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   TextButton(
  //                     child: Text(
  //                       LocaleKeys.close.tr(),
  //                       style: const TextStyle(color: Colors.red),
  //                     ),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                   ),
  //                   const SizedBox(width: AppConstants.defaultNumericValue),
  //                   TextButton(
  //                     child: Text(LocaleKeys.delete.tr()),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       deleteNotification(message.data["id"]!);
  //                     },
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ));
}

void logError(String code, String? message) {
  if (message != null) {
    debugPrint('Error: $code\nError Message: $message');
  } else {
    debugPrint('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      BuildContext context, ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      BuildContext context, ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      BuildContext context, ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        "notifications-page",
        (route) =>
            (route.settings.name != '/notifications-page') || route.isFirst,
        arguments: receivedAction);
  }
}
