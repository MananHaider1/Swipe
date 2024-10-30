// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:websafe_svg/websafe_svg.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// import 'package:lamatdating/constants.dart';

// class ScanQrCodeScreen extends StatefulWidget {
//   const ScanQrCodeScreen({super.key});

//   @override
//   ScanQrCodeScreenState createState() => ScanQrCodeScreenState();
// }

// class ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
//   late Barcode result;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   late QRViewController controller;

//   @override
//   void reassemble() {
//     if (!kIsWeb) {
//       if (Platform.isAndroid) {
//         controller.pauseCamera();
//       } else if (Platform.isIOS) {
//         controller.resumeCamera();
//       }
//     }
//     super.reassemble();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                       LocaleKeys.scanQrCode.tr(),
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
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     const SizedBox(
//                       height: 40,
//                     ),
//                     WebsafeSvg.asset(
//                       qrCodeIcon,
//                       height: 70,
//                       width: 70,
//                       color: AppConstants.primaryColor,
//                       fit: BoxFit.contain,
//                     ),
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     Text(
//                       LocaleKeys.scanQrCodeToSeeProfile.tr(),
//                       style: const TextStyle(
//                         fontSize: 18,
//                       ),
//                     ),
//                     Container(
//                       height: 250,
//                       width: 250,
//                       margin: const EdgeInsets.only(top: 40, bottom: 50),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: AppConstants.primaryColor,
//                           width: 4,
//                         ),
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(5)),
//                         color: AppConstants.primaryColorDark,
//                       ),
//                       child: QRView(
//                         onQRViewCreated: _onQRViewCreated,
//                         key: qrKey,
//                       ),
//                     ),
//                     const Image(
//                       width: 200,
//                       image: AssetImage(icLogo),
//                     ),
//                     const SizedBox(
//                       height: 40,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         result = scanData;
//         this.controller.dispose();
//         Navigator.pop(context);
//         // Navigator.push(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) => UserDetailsPage(user: result.code,)),
//         // );
//       });
//     });
//   }
// }
