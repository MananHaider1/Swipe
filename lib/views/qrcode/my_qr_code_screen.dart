// // ignore_for_file: use_build_context_synchronously

// import 'dart:ui' as ui;

// import 'package:easy_localization/easy_localization.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:websafe_svg/websafe_svg.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/helpers/common_fun.dart';
// import 'package:lamatdating/constants.dart';
// import 'package:lamatdating/helpers/my_loading/costumview/common_ui.dart';
// import 'package:lamatdating/helpers/my_loading/my_loading.dart';
// import 'package:lamatdating/helpers/session_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class MyQrScanCodeScreen extends ConsumerStatefulWidget {
//   const MyQrScanCodeScreen({super.key});

//   @override
//   ConsumerState<MyQrScanCodeScreen> createState() => _MyQrScanCodeScreenState();
// }

// class _MyQrScanCodeScreenState extends ConsumerState<MyQrScanCodeScreen> {
//   InterstitialAd? interstitialAd;

//   @override
//   void initState() {
//     _ads();
//     super.initState();
//   }

//   void _ads() {
//     CommonFun.interstitialAd((ad) {
//       interstitialAd = ad;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final myLoadingProviderProvider = ref.watch(myLoadingProvider);
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 55,
//               child: Stack(
//                 children: [
//                   InkWell(
//                     focusColor: Colors.transparent,
//                     hoverColor: Colors.transparent,
//                     highlightColor: Colors.transparent,
//                     overlayColor: WidgetStateProperty.all(Colors.transparent),
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Padding(
//                       padding: EdgeInsets.all(8.0),
//                       child: Icon(
//                         Icons.chevron_left_rounded,
//                         size: 35,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Text(
//                       LocaleKeys.myCode.tr(),
//                       style: const TextStyle(
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               height: 0.3,
//               color: AppConstants.textColorLight,
//               margin: const EdgeInsets.only(bottom: 10),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 padding: const EdgeInsets.only(bottom: 40),
//                 child: Column(
//                   children: [
//                     RepaintBoundary(
//                       key: screenshotKey,
//                       child: Container(
//                         width: double.infinity,
//                         margin: const EdgeInsets.symmetric(
//                             horizontal: 25, vertical: 15),
//                         decoration: const BoxDecoration(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(15),
//                           ),
//                           color: AppConstants.primaryColorDark,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black,
//                               blurRadius: 10,
//                             ),
//                           ],
//                         ),
//                         child: Stack(
//                           children: [
//                             Column(
//                               children: [
//                                 Align(
//                                   alignment: AlignmentDirectional.topCenter,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 25, bottom: 15),
//                                     child: ClipRRect(
//                                       borderRadius: const BorderRadius.all(
//                                           Radius.circular(15)),
//                                       child: QrImageView(
//                                         backgroundColor: Colors.white,
//                                         data: SessionManager.phoneNumber
//                                             .toString(),
//                                         version: QrVersions.auto,
//                                         size: 200.0,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 ClipOval(
//                                   child: Image(
//                                     height: 50,
//                                     width: 50,
//                                     fit: BoxFit.cover,
//                                     image: NetworkImage(
//                                         myLoadingProviderProvider
//                                             .getUser!.data!.userProfile!),
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             Container(),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text(
//                                   '${AppRes.atSign}${myLoadingProviderProvider.getUser!.data!.userName}',
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Text(
//                                   myLoadingProviderProvider.getUser!.data!.bio!,
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: AppConstants.textColorLight,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Text(
//                                   LocaleKeys.scanToFollowMe.tr(),
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     color: AppConstants.primaryColor,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 const Image(
//                                   image: AssetImage(icLogo),
//                                   height: 60,
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 15,
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         InkWell(
//                           focusColor: Colors.transparent,
//                           hoverColor: Colors.transparent,
//                           highlightColor: Colors.transparent,
//                           overlayColor:
//                               WidgetStateProperty.all(Colors.transparent),
//                           onTap: () => _takeScreenShot(context),
//                           child: Column(
//                             children: [
//                               ClipOval(
//                                 child: Container(
//                                   height: 40,
//                                   width: 40,
//                                   decoration: const BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         AppConstants.primaryColor,
//                                         AppConstants.secondaryColor,
//                                       ],
//                                     ),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(12),
//                                     child: WebsafeSvg.asset(
//                                       height: 36,
//                                       width: 36,
//                                       fit: BoxFit.fitHeight,
//                                       feedsIcon,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                               Text(
//                                 LocaleKeys.saveCode.tr(),
//                                 style: const TextStyle(
//                                   color: AppConstants.textColorLight,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   final GlobalKey screenshotKey = GlobalKey();

//   void _takeScreenShot(BuildContext context) async {
//     RenderRepaintBoundary boundary = screenshotKey.currentContext!
//         .findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 10);
//     ByteData? byteData =
//         await (image.toByteData(format: ui.ImageByteFormat.png));
//     if (byteData == null) return;
//     Uint8List pngBytes = byteData.buffer.asUint8List();
//     if (kDebugMode) {
//       print(pngBytes);
//     }
//     convertImageToFile(pngBytes, context);
//   }

//   Future convertImageToFile(Uint8List image, BuildContext context) async {
//     MimeType type = MimeType.png;
//     // LamatCamera.saveImage(file.path);
//     await FileSaver.instance
//         .saveAs(name: 'myqrcode', ext: '.png', mimeType: type, bytes: image);

//     if (!kIsWeb && interstitialAd != null) {
//       interstitialAd?.show().then((value) {
//         Navigator.pop(context);
//       });
//     } else {
//       Navigator.pop(context);
//     }
//     CommonUI.showToast(msg: LocaleKeys.fileSavedSuccessfully.tr());
//   }

//   Future saveFile(Uint8List image, BuildContext context) async {
//     MimeType type = MimeType.png;
//     // LamatCamera.saveImage(file.path);
//     await FileSaver.instance
//         .saveAs(name: 'myqrcode', ext: '.png', mimeType: type, bytes: image);

//     if (!kIsWeb && interstitialAd != null) {
//       interstitialAd?.show().then((value) {
//         // Navigator.pop(context);
//       });
//     } else {
//       // Navigator.pop(context);
//     }
//     CommonUI.showToast(msg: LocaleKeys.fileSavedSuccessfully.tr());
//   }
// }
