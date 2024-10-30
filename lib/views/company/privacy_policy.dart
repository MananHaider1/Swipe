// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:lamatdating/helpers/constants.dart';
// import 'package:lamatdating/providers/home_arrangement_provider.dart';
// import 'package:lamatdating/responsive.dart';
// import 'package:lamatdating/views/custom/custom_app_bar.dart';
// import 'package:lamatdating/views/custom/custom_headline.dart';
// import 'package:lamatdating/views/custom/custom_icon_button.dart';
// import 'package:lamatdating/views/others/webview_page.dart'
//     if (dart.library.html) 'package:lamatdating/views/others/webview_page_web.dart';

// class PrivacyPolicy extends ConsumerWidget {
//   const PrivacyPolicy({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context, ref) {
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 0,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: AppConstants.defaultNumericValue),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: AppConstants.defaultNumericValue),
//             child: CustomAppBar(
//               leading: CustomIconButton(
//                   icon: leftArrowSvg,
//                   onPressed: () {
//                     (!Responsive.isDesktop(context))
//                         ? Navigator.pop(context)
//                         : ref.invalidate(arrangementProviderExtend);
//                   },
//                   padding: const EdgeInsets.all(
//                       AppConstants.defaultNumericValue / 1.8)),
//               title: Center(
//                   child: CustomHeadLine(
//                 text: 'privacyPolicy'.tr(),
//               )),
//               trailing:
//                   const SizedBox(width: AppConstants.defaultNumericValue * 2),
//             ),
//           ),
//           const SizedBox(height: AppConstants.defaultNumericValue),
//           const Expanded(child: WebViewPage(url: privacyPolicyUrl)),
//         ],
//       ),
//     );
//   }
// }
