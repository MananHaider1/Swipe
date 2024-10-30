// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:lamatdating/helpers/constants.dart';

// import 'package:lamatdating/models/account_delete_request_model.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/account_delete_request_provider.dart';
// import 'package:lamatdating/providers/auth_providers.dart';
// import 'package:lamatdating/providers/user_profile_provider.dart';
// import 'package:lamatdating/views/loading_error/error_page.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
// import 'package:lamatdating/views/security/blocking_page.dart';
// import 'package:lamatdating/views/settings/verification/verification_steps.dart';

// class CreatorStatusPage extends ConsumerWidget {
//   const CreatorStatusPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProfileFutureProvider);

//     return user.when(
//       data: (data) {
//         return data == null ? const ErrorPage() : CreatorPage(user: data);
//       },
//       error: (_, __) => const ErrorPage(),
//       loading: () => const LoadingPage(),
//     );
//   }
// }

// class CreatorPage extends ConsumerStatefulWidget {
//   final UserProfileModel user;
//   const CreatorPage({Key? key, required this.user}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _CreatorPageState();
// }

// class _CreatorPageState extends ConsumerState<CreatorPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Streamer Status"),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.zero,
//               shrinkWrap: true,
//               children: [
//                 // ListTile(
//                 //   leading: const Icon(Icons.block),
//                 //   title: Text(LocaleKeys.blocking.tr()),
//                 //   onTap: () {
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //           builder: (context) => const BlockingPage()),
//                 //     );
//                 //   },
//                 // ),
//                 // const Divider(),
//                 ListTile(
//                   leading: Icon(
//                       widget.user.creatorStatus == 1
//                           ? Icons.verified_rounded
//                           : widget.user.creatorStatus == 2
//                               ? Icons.safety_check_rounded
//                               : Icons.cancel,
//                       color: widget.user.creatorStatus == 1
//                           ? Colors.green
//                           : widget.user.creatorStatus == 2
//                               ? Colors.orange
//                               : Colors.red),
//                   title: Text(
//                     LocaleKeys.status.tr(),
//                   ),
//                   subtitle: Text(
//                     widget.user.creatorStatus == 1
//                         ? LocaleKeys.verified.tr()
//                         : widget.user.creatorStatus == 2
//                             ? "Pennding"
//                             : LocaleKeys.notverified.tr(),
//                     style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color:
//                             widget.user.isVerified ? Colors.green : Colors.red),
//                   ),
//                   onTap: (widget.user.creatorStatus == 1)
//                       ? () {
//                           EasyLoading.showSuccess("Approved");
//                         }
//                       : () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //       builder: (context) =>
//                           //           GetVerifiedPage(user: widget.user)),
//                           // );
//                         },
//                 ),
//                 const Divider(),
//               ],
//             ),
//           ),
//           SafeArea(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: AppConstants.primaryColor.withOpacity(.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text(
//                     LocaleKeys.apply.tr(),
//                     style: Theme.of(context).textTheme.titleSmall!.copyWith(
//                         color: AppConstants.primaryColor,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "Apply to become a live streamer!",
//                     style: Theme.of(context).textTheme.bodySmall!.copyWith(
//                         color: AppConstants.primaryColor,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: AppConstants.primaryColor),
//                     onPressed: () {
//                       showDialog(
//                         context: context,
//                         builder: (context) {
//                           return AlertDialog(
//                             title: Text(LocaleKeys.deleteAccount.tr()),
//                             content: Text(LocaleKeys.areYouSure.tr()),
//                             actions: [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text(LocaleKeys.cancel.tr()),
//                               ),
//                               TextButton(
//                                 onPressed: () async {
//                                   final pendingProfile = widget.user.copyWith(
//                                     creatorStatus: 2,
//                                   );
//                                   await ref
//                                       .read(userProfileNotifier)
//                                       .updateUserProfile(pendingProfile);
//                                 },
//                                 child: Text(LocaleKeys.apply.tr()),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                     child: Text(LocaleKeys.deleteAccount.tr()),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
