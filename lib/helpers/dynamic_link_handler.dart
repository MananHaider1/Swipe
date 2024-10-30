// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/foundation.dart';

// class DynamicLinkHandler {
//   FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
//   Future<void> initDynamicLinks() async {
//     dynamicLinks.onLink.listen((dynamicLinkData) {
//       // Listen and retrieve dynamic links here
//       final String deepLink = dynamicLinkData.link.toString(); // Get DEEP LINK
//       // Ex: https://namnp.page.link/product/013232
//       final String path = dynamicLinkData.link.path; // Get PATH
//       // Ex: product/013232
//       if (deepLink.isEmpty) return;
//       handleDeepLink(path);
//     }).onError((error) {
//       if (kDebugMode) {
//         print('onLink error');
//       }
//       if (kDebugMode) {
//         print(error.message);
//       }
//     });
//     initUniLinks();
//   }

//   Future<void> initUniLinks() async {
//     try {
//       final initialLink = await dynamicLinks.getInitialLink();
//       if (initialLink == null) return;
//       handleDeepLink(initialLink.link.path);
//     } catch (e) {
//       // Error
//     }
//   }

//   void handleDeepLink(String path) {
//     // navigate to detailed product screen
//   }
// }
