// import 'package:easy_localization/easy_localization.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';
// import 'package:lamatdating/modal/search/search_user.dart';

// import 'package:lamatdating/constants.dart';
// // import 'package:lamatdating/v2/view/profile/proifle_screen.dart';
// import 'package:flutter/material.dart';

// class ItemSearchUser extends StatelessWidget {
//   final SearchUserData? searchUser;

//   const ItemSearchUser(this.searchUser, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       focusColor: Colors.transparent,
//       hoverColor: Colors.transparent,
//       highlightColor: Colors.transparent,
//       overlayColor: WidgetStateProperty.all(Colors.transparent),
//       onTap: () => {},
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) =>
//       //         ProfileScreen(1, searchUser?.phoneNumber.toString()),
//       //   ),
//       // ),
//       child: Container(
//         margin: const EdgeInsets.only(left: 20, right: 20),
//         padding: const EdgeInsets.only(top: 10),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.all(5.0),
//                       child: Image(
//                         image: AssetImage(icUserPlaceHolder),
//                         color: AppConstants.textColorLight,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 65,
//                       width: 65,
//                       child: ClipOval(
//                         child: Image.network(
//                           (searchUser?.userProfile == null ||
//                                   searchUser!.userProfile!.isEmpty
//                               ? ''
//                               : searchUser?.userProfile ?? ''),
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container();
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   width: 15,
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         searchUser?.fullName ?? '',
//                         style: const TextStyle(
//                           fontFamily: fNSfUiMedium,
//                           fontSize: 17,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 2,
//                       ),
//                       Text(
//                         '${AppRes.atSign}${searchUser?.userName}',
//                         style: const TextStyle(
//                             color: AppConstants.textColorLight,
//                             fontFamily: fNSfUiMedium,
//                             fontSize: 14,
//                             overflow: TextOverflow.ellipsis),
//                         maxLines: 1,
//                       ),
//                       const SizedBox(
//                         height: 2,
//                       ),
//                       Text(
//                         '${searchUser?.followersCount} ${LocaleKeys.fans.tr()} ${searchUser?.myPostCount} ${LocaleKeys.videos.tr()}',
//                         style: const TextStyle(
//                           color: AppConstants.primaryColor,
//                           fontFamily: fNSfUiLight,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Container(
//               color: AppConstants.textColorLight,
//               height: 0.2,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
