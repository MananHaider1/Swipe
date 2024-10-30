// // ignore_for_file: no_leading_underscores_for_local_identifiers

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/helpers/constants.dart';

// import 'package:lamatdating/helpers/my_loading/my_loading.dart';
// import 'package:lamatdating/views/search/search_user_screen.dart';
// import 'package:lamatdating/views/search/search_video_screen.dart';
// import 'package:flutter/material.dart';

// class SearchScreen extends ConsumerWidget {
//   const SearchScreen({super.key});

//   @override
//   Widget build(BuildContext context, ref) {
//     final myLoadingProviderProvider = ref.watch(myLoadingProvider);
//     PageController _pageController = PageController(
//         initialPage: myLoadingProviderProvider.getSearchPageIndex);
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 InkWell(
//                   focusColor: Colors.transparent,
//                   hoverColor: Colors.transparent,
//                   highlightColor: Colors.transparent,
//                   overlayColor: MaterialStateProperty.all(Colors.transparent),
//                   onTap: () => Navigator.pop(context),
//                   child: const SizedBox(
//                     height: 50,
//                     width: 50,
//                     child: Icon(
//                       Icons.keyboard_arrow_left,
//                       size: 35,
//                       color: AppConstants.textColorLight,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.only(right: 15),
//                     padding:
//                         const EdgeInsets.only(left: 15, right: 15, bottom: 5),
//                     height: 45,
//                     decoration: const BoxDecoration(
//                       color: AppConstants.primaryColorDark,
//                       borderRadius: BorderRadius.all(Radius.circular(50)),
//                     ),
//                     child: TextField(
//                       controller: TextEditingController(
//                           text: myLoadingProviderProvider.getSearchText),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: LocaleKeys.search.tr(),
//                         hintStyle: const TextStyle(
//                           color: AppConstants.textColorLight,
//                           fontSize: 15,
//                         ),
//                       ),
//                       onChanged: (value) {
//                         myLoadingProviderProvider.setSearchText(value);
//                       },
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Consumer(
//               builder: (BuildContext context, ref, Widget? child) {
//                 final myLoadingProviderProvider = ref.watch(myLoadingProvider);
//                 return Row(
//                   children: [
//                     const SizedBox(
//                       width: 20,
//                     ),
//                     Expanded(
//                       child: InkWell(
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         overlayColor:
//                             MaterialStateProperty.all(Colors.transparent),
//                         onTap: () {
//                           _pageController.animateToPage(0,
//                               duration: const Duration(milliseconds: 500),
//                               curve: Curves.linear);
//                         },
//                         child: Container(
//                           height: 40,
//                           decoration: const BoxDecoration(
//                               color: AppConstants.backgroundColorDark,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(5))),
//                           child: Center(
//                             child: Text(
//                               LocaleKeys.videos.tr(),
//                               style: TextStyle(
//                                 color: myLoadingProviderProvider
//                                             .getSearchPageIndex ==
//                                         0
//                                     ? AppConstants.primaryColor
//                                     : AppConstants.textColorLight,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 40,
//                     ),
//                     Expanded(
//                       child: InkWell(
//                         focusColor: Colors.transparent,
//                         hoverColor: Colors.transparent,
//                         highlightColor: Colors.transparent,
//                         overlayColor:
//                             MaterialStateProperty.all(Colors.transparent),
//                         onTap: () {
//                           _pageController.animateToPage(1,
//                               duration: const Duration(milliseconds: 500),
//                               curve: Curves.linear);
//                         },
//                         child: Container(
//                           height: 40,
//                           decoration: const BoxDecoration(
//                               color: AppConstants.backgroundColorDark,
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(5))),
//                           child: Center(
//                             child: Text(
//                               LocaleKeys.users.tr(),
//                               style: TextStyle(
//                                 color: myLoadingProviderProvider
//                                             .getSearchPageIndex ==
//                                         1
//                                     ? AppConstants.primaryColor
//                                     : AppConstants.textColorLight,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 20,
//                     ),
//                   ],
//                 );
//               },
//             ),
//             const SizedBox(
//               height: 5,
//             ),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const BouncingScrollPhysics(),
//                 children: const [
//                   SearchVideoScreen(),
//                   SearchUserScreen(),
//                 ],
//                 onPageChanged: (value) {
//                   myLoadingProviderProvider.setSearchPageIndex(value);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
