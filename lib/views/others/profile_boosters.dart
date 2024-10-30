// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/helpers/constants.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/user_profile_provider.dart';
// import 'package:lamatdating/views/custom/custom_button.dart';
// import 'package:lamatdating/views/loading_error/error_page.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BoostersPageWidget extends ConsumerWidget {
//   final SharedPreferences prefs;
//   final Widget Function(UserProfileModel data)? builder;
//   const BoostersPageWidget({
//     Key? key,
//     this.builder,
//     required this.prefs,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProfileFutureProvider);

//     return user.when(
//       data: (data) {
//         return data == null
//             ? const ErrorPage()
//             : builder == null
//                 ? BoostersPage(user: data)
//                 : builder!(data);
//       },
//       error: (_, __) => const ErrorPage(),
//       loading: () => const LoadingPage(),
//     );
//   }
// }

// class BoostersPage extends ConsumerStatefulWidget {
//   final UserProfileModel user;
//   const BoostersPage({Key? key, required this.user}) : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _BoostersPageState();
// }

// class _BoostersPageState extends ConsumerState<BoostersPage> {
//   int selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           style: IconButton.styleFrom(
//             foregroundColor: const Color(0xFFAA0000),
//             backgroundColor: AppConstants.primaryColor.withOpacity(.1),
//             disabledBackgroundColor: Colors.white38,
//             hoverColor: AppConstants.primaryColor.withOpacity(0.22),
//             focusColor: AppConstants.primaryColor.withOpacity(0.12),
//             highlightColor: AppConstants.primaryColor.withOpacity(0.12),
//           ),
//         ),
//         title: Row(
//           children: [
//             Text(
//               LocaleKeys.profileBoosters.tr(),
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge!
//                   .copyWith(fontWeight: FontWeight.bold),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: AppConstants.defaultNumericValue / 2,
//                   vertical: AppConstants.defaultNumericValue / 4),
//               decoration: BoxDecoration(
//                 borderRadius:
//                     BorderRadius.circular(AppConstants.defaultNumericValue * 3),
//                 gradient: AppConstants.defaultGradient,
//                 border: Border.all(color: Colors.transparent, width: 1),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppConstants.primaryColor.withOpacity(0.2),
//                     blurRadius: AppConstants.defaultNumericValue * 2,
//                     spreadRadius: AppConstants.defaultNumericValue / 4,
//                     offset: const Offset(0, AppConstants.defaultNumericValue),
//                   ),
//                 ],
//               ),
//               child: GestureDetector(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title:
//                             Text(LocaleKeys.upcomingFeature.tr().toUpperCase()),
//                         content: Row(
//                           children: [
//                             Text(LocaleKeys.thisisanupcomingfeat.tr()),
//                             Container(
//                               margin: const EdgeInsets.only(bottom: 3),
//                               padding: const EdgeInsets.only(
//                                   left: AppConstants.defaultNumericValue / 3,
//                                   right: AppConstants.defaultNumericValue / 3,
//                                   bottom: 2),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(
//                                     AppConstants.defaultNumericValue * 3),
//                                 gradient: AppConstants.defaultGradient,
//                                 border: Border.all(
//                                     color: Colors.transparent, width: 1),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: AppConstants.primaryColor
//                                         .withOpacity(0.2),
//                                     blurRadius:
//                                         AppConstants.defaultNumericValue * 2,
//                                     spreadRadius:
//                                         AppConstants.defaultNumericValue / 4,
//                                     offset: const Offset(
//                                         0, AppConstants.defaultNumericValue),
//                                   ),
//                                 ],
//                               ),
//                               child: Text(
//                                 LocaleKeys.pro.tr(),
//                                 style: const TextStyle(
//                                     shadows: [
//                                       Shadow(
//                                         blurRadius: 2.0,
//                                         color: Colors.black26,
//                                         offset: Offset(1.0, 1.0),
//                                       ),
//                                     ],
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize:
//                                         AppConstants.defaultNumericValue / 1.8),
//                               ),
//                             ),
//                             Text(LocaleKeys.feature.tr()),
//                           ],
//                         ),
//                         actions: [
//                           TextButton(
//                             child: Text(
//                               LocaleKeys.gotit.tr().toUpperCase(),
//                               style: const TextStyle(color: Colors.black),
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           )
//                         ],
//                       ),
//                     );
//                   },
//                   child: Text(
//                     LocaleKeys.pro.tr(),
//                     style: const TextStyle(
//                         shadows: [
//                           Shadow(
//                             blurRadius: 2.0,
//                             color: Colors.black26,
//                             offset: Offset(1.0, 1.0),
//                           ),
//                         ],
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: AppConstants.defaultNumericValue / 2),
//                   )),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: AppConstants.defaultNumericValue),
//               Container(
//                 height: AppConstants.defaultNumericValue * 7,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(
//                       AppConstants.defaultNumericValue * 1.5),
//                   // Image set to background of the body
//                   image: const DecorationImage(
//                       image: AssetImage("assets/images/premium-bg.png"),
//                       fit: BoxFit.cover),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                         child: ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: AppConstants.defaultNumericValue,
//                           vertical: AppConstants.defaultNumericValue),
//                       title: Text(LocaleKeys.popularity.tr(),
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white)),
//                       subtitle: Text(LocaleKeys.veryLow,
//                           style: const TextStyle(color: Colors.white)),
//                     )),
//                     const Image(
//                       image: AssetImage("assets/images/boost.png"),
//                       width: AppConstants.defaultNumericValue * 5,
//                       height: AppConstants.defaultNumericValue * 5,
//                       fit: BoxFit.contain,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: AppConstants.defaultNumericValue * 3),
//               Expanded(
//                 child: ListView(
//                   children: <Widget>[
//                     Container(
//                       height: AppConstants.defaultNumericValue * 5,
//                       decoration: BoxDecoration(
//                         //             border: const GradientBoxBorder(
//                         //   gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
//                         //   width: 4,
//                         // ),
//                         borderRadius: BorderRadius.circular(
//                             AppConstants.defaultNumericValue * 1.1),
//                         // Image set to background of the body
//                         color: (selectedIndex == 1)
//                             ? AppConstants.primaryColor.withOpacity(.05)
//                             : Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(0, -5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // const Image(
//                           //   image: AssetImage("assets/images/boost.png"),
//                           //   width: AppConstants.defaultNumericValue * 3,
//                           //   height: AppConstants.defaultNumericValue * 3,
//                           //   fit: BoxFit.contain,
//                           // ),
//                           Expanded(
//                               child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal:
//                                   AppConstants.defaultNumericValue * 1.5,
//                             ),
//                             title: Text(LocaleKeys.sixHoursBoost.tr(),
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black)),
//                             subtitle: Text('30 ${LocaleKeys.diamonds.tr()}',
//                                 style: const TextStyle(
//                                     color: AppConstants.primaryColor)),
//                           )),
//                           TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   selectedIndex = 1;
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: Text(LocaleKeys.upcomingFeature
//                                           .tr()
//                                           .toUpperCase()),
//                                       content: Row(
//                                         children: [
//                                           Text(LocaleKeys.thisisanupcomingfeat
//                                               .tr()),
//                                           Container(
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 3),
//                                             padding: const EdgeInsets.only(
//                                                 left: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 right: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 bottom: 2),
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius
//                                                   .circular(AppConstants
//                                                           .defaultNumericValue *
//                                                       3),
//                                               gradient:
//                                                   AppConstants.defaultGradient,
//                                               border: Border.all(
//                                                   color: Colors.transparent,
//                                                   width: 1),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: AppConstants
//                                                       .primaryColor
//                                                       .withOpacity(0.2),
//                                                   blurRadius: AppConstants
//                                                           .defaultNumericValue *
//                                                       2,
//                                                   spreadRadius: AppConstants
//                                                           .defaultNumericValue /
//                                                       4,
//                                                   offset: const Offset(
//                                                       0,
//                                                       AppConstants
//                                                           .defaultNumericValue),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Text(
//                                               LocaleKeys.pro.tr(),
//                                               style: const TextStyle(
//                                                   shadows: [
//                                                     Shadow(
//                                                       blurRadius: 2.0,
//                                                       color: Colors.black26,
//                                                       offset: Offset(1.0, 1.0),
//                                                     ),
//                                                   ],
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: AppConstants
//                                                           .defaultNumericValue /
//                                                       1.5),
//                                             ),
//                                           ),
//                                           Text(LocaleKeys.feature.tr()),
//                                         ],
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           child: Text(
//                                             LocaleKeys.gotit.tr().toUpperCase(),
//                                             style: const TextStyle(
//                                                 color: Colors.black),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         )

//                                         // TextButton(
//                                         //   child: const Text(
//                                         //     "Sure",
//                                         //     style: TextStyle(color: Colors.red),
//                                         //   ),
//                                         //   onPressed: () async {
//                                         //     Navigator.of(context).pop();

//                                         //     await ref.read(authProvider).signOut();
//                                         //   },
//                                         // ),
//                                       ],
//                                     ),
//                                   );
//                                 });
//                               },
//                               child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           AppConstants.defaultNumericValue,
//                                       vertical:
//                                           AppConstants.defaultNumericValue / 2),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(
//                                         AppConstants.defaultNumericValue * 1.5),
//                                     border: Border.all(
//                                         color: Colors.black.withOpacity(.05),
//                                         width: 1),
//                                   ),
//                                   child: Text(
//                                     selectedIndex == 1
//                                         ? LocaleKeys.selected.tr()
//                                         : LocaleKeys.select.tr(),
//                                     style: const TextStyle(color: Colors.black),
//                                   )))
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: AppConstants.defaultNumericValue),
//                     Container(
//                       height: AppConstants.defaultNumericValue * 5,
//                       decoration: BoxDecoration(
//                         //             border: const GradientBoxBorder(
//                         //   gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
//                         //   width: 4,
//                         // ),
//                         borderRadius: BorderRadius.circular(
//                             AppConstants.defaultNumericValue * 1.1),
//                         // Image set to background of the body
//                         color: (selectedIndex == 2)
//                             ? AppConstants.primaryColor.withOpacity(.05)
//                             : Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(0, -5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // const Image(
//                           //   image: AssetImage("assets/images/boost.png"),
//                           //   width: AppConstants.defaultNumericValue * 3,
//                           //   height: AppConstants.defaultNumericValue * 3,
//                           //   fit: BoxFit.contain,
//                           // ),
//                           Expanded(
//                               child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal:
//                                   AppConstants.defaultNumericValue * 1.5,
//                             ),
//                             title: Text(LocaleKeys.OneDayBooster,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black)),
//                             subtitle: Text('70 ${LocaleKeys.diamonds}',
//                                 style: const TextStyle(
//                                     color: AppConstants.primaryColor)),
//                           )),
//                           TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   selectedIndex = 2;
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: Text(S
//                                           .of(context)
//                                           .UpcomingFeature
//                                           .toUpperCase()),
//                                       content: Row(
//                                         children: [
//                                           Text(S
//                                               .of(context)
//                                               .ThisisanupcomingGpecho),
//                                           Container(
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 3),
//                                             padding: const EdgeInsets.only(
//                                                 left: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 right: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 bottom: 2),
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius
//                                                   .circular(AppConstants
//                                                           .defaultNumericValue *
//                                                       3),
//                                               gradient:
//                                                   AppConstants.defaultGradient,
//                                               border: Border.all(
//                                                   color: Colors.transparent,
//                                                   width: 1),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: AppConstants
//                                                       .primaryColor
//                                                       .withOpacity(0.2),
//                                                   blurRadius: AppConstants
//                                                           .defaultNumericValue *
//                                                       2,
//                                                   spreadRadius: AppConstants
//                                                           .defaultNumericValue /
//                                                       4,
//                                                   offset: const Offset(
//                                                       0,
//                                                       AppConstants
//                                                           .defaultNumericValue),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Text(
//                                               LocaleKeys.PRO,
//                                               style: const TextStyle(
//                                                   shadows: [
//                                                     Shadow(
//                                                       blurRadius: 2.0,
//                                                       color: Colors.black26,
//                                                       offset: Offset(1.0, 1.0),
//                                                     ),
//                                                   ],
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: AppConstants
//                                                           .defaultNumericValue /
//                                                       1.5),
//                                             ),
//                                           ),
//                                           Text(LocaleKeys.feature),
//                                         ],
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           child: Text(
//                                             LocaleKeys.Gotit.toUpperCase(),
//                                             style: const TextStyle(
//                                                 color: Colors.black),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         )

//                                         // TextButton(
//                                         //   child: const Text(
//                                         //     "Sure",
//                                         //     style: TextStyle(color: Colors.red),
//                                         //   ),
//                                         //   onPressed: () async {
//                                         //     Navigator.of(context).pop();

//                                         //     await ref.read(authProvider).signOut();
//                                         //   },
//                                         // ),
//                                       ],
//                                     ),
//                                   );
//                                 });
//                               },
//                               child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           AppConstants.defaultNumericValue,
//                                       vertical:
//                                           AppConstants.defaultNumericValue / 2),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(
//                                         AppConstants.defaultNumericValue * 1.5),
//                                     border: Border.all(
//                                         color: Colors.black.withOpacity(.05),
//                                         width: 1),
//                                   ),
//                                   child: Text(
//                                     selectedIndex == 2
//                                         ? LocaleKeys.Selected
//                                         : LocaleKeys.Select,
//                                     style: const TextStyle(color: Colors.black),
//                                   )))
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: AppConstants.defaultNumericValue),
//                     Container(
//                       height: AppConstants.defaultNumericValue * 5,
//                       decoration: BoxDecoration(
//                         //             border: const GradientBoxBorder(
//                         //   gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
//                         //   width: 4,
//                         // ),
//                         borderRadius: BorderRadius.circular(
//                             AppConstants.defaultNumericValue * 1.1),
//                         // Image set to background of the body
//                         color: (selectedIndex == 3)
//                             ? AppConstants.primaryColor.withOpacity(.05)
//                             : Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(0, -5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // const Image(
//                           //   image: AssetImage("assets/images/boost.png"),
//                           //   width: AppConstants.defaultNumericValue * 3,
//                           //   height: AppConstants.defaultNumericValue * 3,
//                           //   fit: BoxFit.contain,
//                           // ),
//                           Expanded(
//                               child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal:
//                                   AppConstants.defaultNumericValue * 1.5,
//                             ),
//                             title: const Text('Three Days Booster',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black)),
//                             subtitle: Text('120 ${LocaleKeys.diamonds}',
//                                 style: const TextStyle(
//                                     color: AppConstants.primaryColor)),
//                           )),
//                           TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   selectedIndex = 3;
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: Text(S
//                                           .of(context)
//                                           .UpcomingFeature
//                                           .toUpperCase()),
//                                       content: Row(
//                                         children: [
//                                           Text(S
//                                               .of(context)
//                                               .ThisisanupcomingGpecho),
//                                           Container(
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 3),
//                                             padding: const EdgeInsets.only(
//                                                 left: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 right: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 bottom: 2),
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius
//                                                   .circular(AppConstants
//                                                           .defaultNumericValue *
//                                                       3),
//                                               gradient:
//                                                   AppConstants.defaultGradient,
//                                               border: Border.all(
//                                                   color: Colors.transparent,
//                                                   width: 1),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: AppConstants
//                                                       .primaryColor
//                                                       .withOpacity(0.2),
//                                                   blurRadius: AppConstants
//                                                           .defaultNumericValue *
//                                                       2,
//                                                   spreadRadius: AppConstants
//                                                           .defaultNumericValue /
//                                                       4,
//                                                   offset: const Offset(
//                                                       0,
//                                                       AppConstants
//                                                           .defaultNumericValue),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Text(
//                                               LocaleKeys.PRO,
//                                               style: const TextStyle(
//                                                   shadows: [
//                                                     Shadow(
//                                                       blurRadius: 2.0,
//                                                       color: Colors.black26,
//                                                       offset: Offset(1.0, 1.0),
//                                                     ),
//                                                   ],
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: AppConstants
//                                                           .defaultNumericValue /
//                                                       1.5),
//                                             ),
//                                           ),
//                                           Text(LocaleKeys.feature),
//                                         ],
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           child: Text(
//                                             LocaleKeys.Gotit.toUpperCase(),
//                                             style: const TextStyle(
//                                                 color: Colors.black),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         )

//                                         // TextButton(
//                                         //   child: const Text(
//                                         //     "Sure",
//                                         //     style: TextStyle(color: Colors.red),
//                                         //   ),
//                                         //   onPressed: () async {
//                                         //     Navigator.of(context).pop();

//                                         //     await ref.read(authProvider).signOut();
//                                         //   },
//                                         // ),
//                                       ],
//                                     ),
//                                   );
//                                 });
//                               },
//                               child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           AppConstants.defaultNumericValue,
//                                       vertical:
//                                           AppConstants.defaultNumericValue / 2),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(
//                                         AppConstants.defaultNumericValue * 1.5),
//                                     border: Border.all(
//                                         color: Colors.black.withOpacity(.05),
//                                         width: 1),
//                                   ),
//                                   child: Text(
//                                     selectedIndex == 3
//                                         ? LocaleKeys.Selected
//                                         : LocaleKeys.Select,
//                                     style: const TextStyle(color: Colors.black),
//                                   )))
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: AppConstants.defaultNumericValue),
//                     Container(
//                       height: AppConstants.defaultNumericValue * 5,
//                       decoration: BoxDecoration(
//                         //             border: const GradientBoxBorder(
//                         //   gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
//                         //   width: 4,
//                         // ),
//                         borderRadius: BorderRadius.circular(
//                             AppConstants.defaultNumericValue * 1.1),
//                         // Image set to background of the body
//                         color: (selectedIndex == 4)
//                             ? AppConstants.primaryColor.withOpacity(.05)
//                             : Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             spreadRadius: 2,
//                             offset: const Offset(0, -5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           // const Image(
//                           //   image: AssetImage("assets/images/boost.png"),
//                           //   width: AppConstants.defaultNumericValue * 3,
//                           //   height: AppConstants.defaultNumericValue * 3,
//                           //   fit: BoxFit.contain,
//                           // ),
//                           Expanded(
//                               child: ListTile(
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal:
//                                   AppConstants.defaultNumericValue * 1.5,
//                             ),
//                             title: Text(LocaleKeys.SevenDaysBooster,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black)),
//                             subtitle: Text('400 ${LocaleKeys.diamonds}',
//                                 style: const TextStyle(
//                                     color: AppConstants.primaryColor)),
//                           )),
//                           TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   selectedIndex = 4;
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) => AlertDialog(
//                                       title: Text(S
//                                           .of(context)
//                                           .UpcomingFeature
//                                           .toUpperCase()),
//                                       content: Row(
//                                         children: [
//                                           Text(S
//                                               .of(context)
//                                               .ThisisanupcomingGpecho),
//                                           Container(
//                                             margin: const EdgeInsets.only(
//                                                 bottom: 3),
//                                             padding: const EdgeInsets.only(
//                                                 left: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 right: AppConstants
//                                                         .defaultNumericValue /
//                                                     3,
//                                                 bottom: 2),
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius
//                                                   .circular(AppConstants
//                                                           .defaultNumericValue *
//                                                       3),
//                                               gradient:
//                                                   AppConstants.defaultGradient,
//                                               border: Border.all(
//                                                   color: Colors.transparent,
//                                                   width: 1),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                   color: AppConstants
//                                                       .primaryColor
//                                                       .withOpacity(0.2),
//                                                   blurRadius: AppConstants
//                                                           .defaultNumericValue *
//                                                       2,
//                                                   spreadRadius: AppConstants
//                                                           .defaultNumericValue /
//                                                       4,
//                                                   offset: const Offset(
//                                                       0,
//                                                       AppConstants
//                                                           .defaultNumericValue),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: Text(
//                                               LocaleKeys.PRO,
//                                               style: const TextStyle(
//                                                   shadows: [
//                                                     Shadow(
//                                                       blurRadius: 2.0,
//                                                       color: Colors.black26,
//                                                       offset: Offset(1.0, 1.0),
//                                                     ),
//                                                   ],
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: AppConstants
//                                                           .defaultNumericValue /
//                                                       1.5),
//                                             ),
//                                           ),
//                                           Text(LocaleKeys.feature),
//                                         ],
//                                       ),
//                                       actions: [
//                                         TextButton(
//                                           child: Text(
//                                             LocaleKeys.Gotit.toUpperCase(),
//                                             style: const TextStyle(
//                                                 color: Colors.black),
//                                           ),
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                         )

//                                         // TextButton(
//                                         //   child: const Text(
//                                         //     "Sure",
//                                         //     style: TextStyle(color: Colors.red),
//                                         //   ),
//                                         //   onPressed: () async {
//                                         //     Navigator.of(context).pop();

//                                         //     await ref.read(authProvider).signOut();
//                                         //   },
//                                         // ),
//                                       ],
//                                     ),
//                                   );
//                                 });
//                               },
//                               child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal:
//                                           AppConstants.defaultNumericValue,
//                                       vertical:
//                                           AppConstants.defaultNumericValue / 2),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(
//                                         AppConstants.defaultNumericValue * 1.5),
//                                     border: Border.all(
//                                         color: Colors.black.withOpacity(.05),
//                                         width: 1),
//                                   ),
//                                   child: Text(
//                                     selectedIndex == 4
//                                         ? LocaleKeys.Selected
//                                         : LocaleKeys.Select,
//                                     style: const TextStyle(color: Colors.black),
//                                   )))
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           )),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
//           child: CustomButton(
//             onPressed: () async {
//               // final UserAccountSettingsModel userAccountSettingsModel =
//               //     UserAccountSettingsModel(
//               //   boosted: _boosted,
//               //   boostedOn: _boostedOn,
//               //   boosterLength: _boosterLength,
//               //   minimumAge: _minimumAge.toInt(),
//               //   maximumAge: _maximumAge.toInt(),
//               //   location: _userLocation,
//               // );

//               // final userProfileModel = widget.user.copyWith(
//               //   userAccountSettingsModel: userAccountSettingsModel,
//               // );
//               // EasyLoading.show(status: 'Boosting...');

//               // await ref
//               //     .read(userProfileNotifier)
//               //     .updateUserProfile(userProfileModel)
//               //     .then((value) {
//               //   ref.invalidate(userProfileFutureProvider);
//               //   EasyLoading.dismiss();
//               //   Navigator.pop(context);
//               // });
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text(LocaleKeys.UpcomingFeature.toUpperCase()),
//                   content: Row(
//                     children: [
//                       Text(LocaleKeys.ThisisanupcomingGpecho),
//                       Container(
//                         margin: const EdgeInsets.only(bottom: 3),
//                         padding: const EdgeInsets.only(
//                             left: AppConstants.defaultNumericValue / 3,
//                             right: AppConstants.defaultNumericValue / 3,
//                             bottom: 2),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(
//                               AppConstants.defaultNumericValue * 3),
//                           gradient: AppConstants.defaultGradient,
//                           border:
//                               Border.all(color: Colors.transparent, width: 1),
//                           boxShadow: [
//                             BoxShadow(
//                               color: AppConstants.primaryColor.withOpacity(0.2),
//                               blurRadius: AppConstants.defaultNumericValue * 2,
//                               spreadRadius:
//                                   AppConstants.defaultNumericValue / 4,
//                               offset: const Offset(
//                                   0, AppConstants.defaultNumericValue),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           LocaleKeys.PRO,
//                           style: const TextStyle(
//                               shadows: [
//                                 Shadow(
//                                   blurRadius: 2.0,
//                                   color: Colors.black26,
//                                   offset: Offset(1.0, 1.0),
//                                 ),
//                               ],
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: AppConstants.defaultNumericValue / 1.8),
//                         ),
//                       ),
//                       Text(LocaleKeys.feature),
//                     ],
//                   ),
//                   actions: [
//                     TextButton(
//                       child: Text(
//                         LocaleKeys.Gotit.toUpperCase(),
//                         style: const TextStyle(color: Colors.black),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     )

//                     // TextButton(
//                     //   child: const Text(
//                     //     "Sure",
//                     //     style: TextStyle(color: Colors.red),
//                     //   ),
//                     //   onPressed: () async {
//                     //     Navigator.of(context).pop();

//                     //     await ref.read(authProvider).signOut();
//                     //   },
//                     // ),
//                   ],
//                 ),
//               );
//             },
//             text: LocaleKeys.Boost,
//           ),
//         ),
//       ),
//     );
//   }
// }



// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // 
// // import 'package:lamatdating/helpers/constants.dart';
// // import 'package:lamatdating/models/user_account_settings_model.dart';
// // import 'package:lamatdating/models/user_profile_model.dart';
// // import 'package:lamatdating/providers/user_profile_provider.dart';
// // import 'package:lamatdating/views/custom/custom_button.dart';
// // import 'package:lamatdating/views/others/set_user_location_page.dart';

// // class BoostersPage extends ConsumerStatefulWidget {
// //   final UserProfileModel user;
// //   const BoostersPage({Key? key, required this.user}) : super(key: key);

// //   @override
// //   ConsumerState<ConsumerStatefulWidget> createState() => _BoostersPageState();
// // }

// // class _BoostersPageState extends ConsumerState<BoostersPage> {
// //   bool? _boosted;
// //   late DateTime? _boostedOn;
// //   late int? _boosterLength;
// //   late UserLocation _userLocation;
// //   late double _minimumAge;
// //   late double _maximumAge;

// //   @override
// //   void initState() {
// //     _boosted = widget.user.userAccountSettingsModel.boosted;
// //     _boostedOn = widget.user.userAccountSettingsModel.boostedOn;
// //     _boosterLength = widget.user.userAccountSettingsModel.boosterLength;
// //     _userLocation = widget.user.userAccountSettingsModel.location;
// //     _minimumAge = widget.user.userAccountSettingsModel.minimumAge.toDouble();
// //     _maximumAge = widget.user.userAccountSettingsModel.maximumAge.toDouble();
// //     super.initState();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Boosters'),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.stretch,
// //           children: [
// //             const SizedBox(height: AppConstants.defaultNumericValue),
// //             GestureDetector(
// //               onTap: () async {},
// //               child: Container(),
// //             ),
// //             const SizedBox(height: AppConstants.defaultNumericValue),
// //             const SizedBox(height: AppConstants.defaultNumericValue * 2),
// //             const SizedBox(height: AppConstants.defaultNumericValue),
// //             const SizedBox(height: AppConstants.defaultNumericValue * 2),
// //             const SizedBox(height: AppConstants.defaultNumericValue),
// //             const SizedBox(height: AppConstants.defaultNumericValue * 2),
// //             CustomButton(
// //               onPressed: () async {
// //                 final UserAccountSettingsModel userAccountSettingsModel =
// //                     UserAccountSettingsModel(
// //                   boosted: _boosted,
// //                   boostedOn: _boostedOn,
// //                   boosterLength: _boosterLength,
// //                   minimumAge: _minimumAge.toInt(),
// //                   maximumAge: _maximumAge.toInt(),
// //                   location: _userLocation,
// //                 );

// //                 final userProfileModel = widget.user.copyWith(
// //                   userAccountSettingsModel: userAccountSettingsModel,
// //                 );
// //                 EasyLoading.show(
// //                     status: 'Boosting...',
// //                     indicator: const Icon(CupertinoIcons.rocket_fill));

// //                 await ref
// //                     .read(userProfileNotifier)
// //                     .updateUserProfile(userProfileModel)
// //                     .then((value) {
// //                   ref.invalidate(userProfileFutureProvider);
// //                   EasyLoading.dismiss();
// //                   Navigator.pop(context);
// //                 });
// //               },
// //               text: 'Boost',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

