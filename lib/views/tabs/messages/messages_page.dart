// import 'dart:convert';
// import 'dart:io';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:websafe_svg/websafe_svg.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/helpers/constants.dart';
// import 'package:lamatdating/helpers/date_formater.dart';
// import 'package:lamatdating/helpers/encrypt_helper.dart';
// import 'package:lamatdating/models/chat_item_model.dart';
// import 'package:lamatdating/models/match_model.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/auth_providers.dart';
// import 'package:lamatdating/providers/chat_provider.dart';
// import 'package:lamatdating/providers/match_provider.dart';
// import 'package:lamatdating/providers/other_users_provider.dart';
// import 'package:lamatdating/views/ads/banner_ads.dart';
// import 'package:lamatdating/views/custom/custom_app_bar.dart';
// import 'package:lamatdating/views/custom/custom_headline.dart';
// // import 'package:lamatdating/views/custom/custom_icon_button.dart';
// import 'package:lamatdating/views/custom/subscription_builder.dart';
// import 'package:lamatdating/views/live/widgets/user_circle_widg.dart';
// import 'package:lamatdating/views/loading_error/error_page.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
// import 'package:lamatdating/views/tabs/home/home_page.dart';
// import 'package:lamatdating/views/tabs/messages/components/chat_page.dart';

// class MessageConsumerPage extends ConsumerWidget {
//   const MessageConsumerPage({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final matches = ref.watch(matchStreamProvider);
//     // final prefs = ref.watch(sharedPreferencesProvider).value;

//     return matches.when(
//       data: (data) {
//         final List<MessageViewModel> messages = [];

//         messages.addAll(getAllMessages(ref, data));

//         // return MessagesPage(messages: messages);
//         return SubscriptionBuilder(
//           builder: (context, isPremiumUser) {
//             return MessagesPage(
//                 messages: messages, isPremiumUser: isPremiumUser);
//           },
//         );
//       },
//       error: (_, __) => const ErrorPage(),
//       loading: () => const LoadingPage(),
//     );
//   }
// }

// class MessagesPage extends ConsumerStatefulWidget {
//   final List<MessageViewModel> messages;
//   final bool isPremiumUser;
//   const MessagesPage({
//     Key? key,
//     required this.messages,
//     required this.isPremiumUser,
//   }) : super(key: key);

//   @override
//   ConsumerState<MessagesPage> createState() => _MessagesPageState();
// }

// class _MessagesPageState extends ConsumerState<MessagesPage> {
//   // bool _isSearchBarVisible = false;
//   final _searchController = TextEditingController();

//   @override
//   void initState() {
//     if (!widget.isPremiumUser && isAdmobAvailable && !kIsWeb) {
//       InterstitialAd.load(
//         adUnitId: Platform.isAndroid
//             ? AndroidAdUnits.interstitialId
//             : IOSAdUnits.interstitialId,
//         request: const AdRequest(),
//         adLoadCallback: InterstitialAdLoadCallback(
//           onAdLoaded: (ad) async {
//             debugPrint('InterstitialAd loaded.');

//             await Future.delayed(const Duration(seconds: 4)).then((value) {
//               ad.show();
//             });
//           },
//           onAdFailedToLoad: (error) {},
//         ),
//       );
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final prefs = ref.watch(sharedPreferencesProvider).value;
//     final searchedMessages = widget.messages.where((element) {
//       return element.matchedUser.fullName
//           .toLowerCase()
//           .contains(_searchController.text.toLowerCase());
//     }).toList();

//     searchedMessages.sort((a, b) {
//       return b.lastMessageDate.compareTo(a.lastMessageDate);
//     });

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
//               leading: const Row(
//                 children: [
//                   // CustomIconButton(
//                   //     padding: const EdgeInsets.all(
//                   //         AppConstants.defaultNumericValue / 1.8),
//                   //     onPressed: () => Navigator.pop(context),
//                   //     color: AppConstants.primaryColor,
//                   //     icon: leftArrowSvg),
//                   // const SizedBox(
//                   //   width: 10,
//                   // ),
//                   SizedBox()
//                   // CustomIconButton(
//                   //   icon: menuIcon,
//                   //   color: AppConstants.primaryColor,
//                   //   onPressed: () {
//                   //     setState(() {
//                   //       _isSearchBarVisible = !_isSearchBarVisible;
//                   //       _searchController.clear();
//                   //     });
//                   //   },
//                   //   padding: const EdgeInsets.all(
//                   //       AppConstants.defaultNumericValue / 1.8),
//                   // ),
//                 ],
//               ),
//               title: Center(
//                 child: CustomHeadLine(
//                   text: LocaleKeys.chats.tr(),
//                 ),
//               ),
//               trailing: const NotificationButton(),
//             ),
//           ),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: AppConstants.defaultNumericValue),
//                 Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: AppConstants.defaultNumericValue),
//                     child: SizedBox(
//                         height: 40, // Set the height you want here
//                         child: TextField(
//                           controller: _searchController,
//                           autofocus: false,
//                           onChanged: (_) {
//                             setState(() {});
//                           },
//                           decoration: InputDecoration(
//                             contentPadding: EdgeInsets.zero,
//                             hintText: LocaleKeys.search.tr(),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(
//                                 AppConstants.defaultNumericValue,
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             filled: true,
//                             fillColor:
//                                 AppConstants.primaryColor.withOpacity(0.1),
//                             prefixIcon: WebsafeSvg.asset(
//                               searchIcon,
//                               color: AppConstants.primaryColor,
//                               height: 10,
//                               width: 10,
//                               fit: BoxFit.scaleDown,
//                             ),
//                           ),
//                         ))),
//                 const SizedBox(height: AppConstants.defaultNumericValue),
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: searchedMessages.length,
//                     itemBuilder: (context, index) {
//                       final message = searchedMessages[index];
//                       return ConversationTile(messageViewModel: message);
//                     },
//                   ),
//                 ),
//                 SubscriptionBuilder(
//                   builder: (context, isPremiumUser) {
//                     return isPremiumUser
//                         ? const SizedBox()
//                         : const MyBannerAd();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ConversationTile extends ConsumerWidget {
//   final MessageViewModel messageViewModel;
//   const ConversationTile({
//     Key? key,
//     required this.messageViewModel,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context, ref) {
//     return Column(
//       children: [
//         ListTile(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 CupertinoPageRoute(
//                   builder: (context) => ChatPage(
//                     otherUserId: messageViewModel.matchedUser.phoneNumber,
//                     matchId: messageViewModel.matchId,
//                   ),
//                 ),
//               );
//             },
//             title: Row(
//               children: [
//                 Text(
//                   messageViewModel.matchedUser.fullName,
//                   style: Theme.of(context)
//                       .textTheme
//                       .titleMedium!
//                       .copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 if (messageViewModel.unreadCount > 0)
//                   const SizedBox(width: AppConstants.defaultNumericValue / 2),
//                 if (messageViewModel.unreadCount > 0)
//                   Badge(
//                     backgroundColor: AppConstants.primaryColor,
//                     label: Text(messageViewModel.unreadCount.toString()),
//                   ),
//               ],
//             ),
//             trailing: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   DateFormatter.toTime(messageViewModel.lastMessageDate),
//                   style: Theme.of(context).textTheme.bodySmall!,
//                 ),
//                 Text(
//                   DateFormatter.toYearMonthDay2(
//                       messageViewModel.lastMessageDate),
//                   style: Theme.of(context).textTheme.bodySmall!,
//                 ),
//               ],
//             ),
//             subtitle: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 if (messageViewModel.lastMessage.phoneNumber ==
//                     ref.watch(currentUserStateProvider)!.phoneNumber)
//                   Text(LocaleKeys.you.tr()),
//                 if (messageViewModel.lastMessage.image != null)
//                   const Icon(
//                     Icons.image,
//                     color: AppConstants.primaryColor,
//                   ),
//                 if (messageViewModel.lastMessage.image != null)
//                   const SizedBox(width: AppConstants.defaultNumericValue / 2),
//                 if (messageViewModel.lastMessage.video != null)
//                   const Icon(
//                     Icons.movie,
//                     color: AppConstants.primaryColor,
//                   ),
//                 if (messageViewModel.lastMessage.video != null)
//                   const SizedBox(width: AppConstants.defaultNumericValue / 2),
//                 Text(
//                   decryptText(messageViewModel.lastMessage.message ?? ""),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//             leading: Stack(
//               children: [
//                 UserCirlePicture(
//                     imageUrl: messageViewModel.matchedUser.profilePicture,
//                     size: AppConstants.defaultNumericValue * 3),
//                 if (messageViewModel.matchedUser.isOnline)
//                   Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: AppConstants.primaryColor, // Set border color
//                         width: 2.0, // Set border width
//                       ),
//                     ),
//                     child: const CircleAvatar(
//                       backgroundColor: AppConstants.onlineStatus,
//                       radius: 5,
//                     ),
//                   )
//               ],
//             )),
//       ],
//     );
//   }
// }

// class MessageViewModel {
//   UserProfileModel matchedUser;
//   String matchId;
//   ChatItemModel lastMessage;
//   DateTime lastMessageDate;
//   int unreadCount;
//   MessageViewModel({
//     required this.matchedUser,
//     required this.matchId,
//     required this.lastMessage,
//     required this.lastMessageDate,
//     required this.unreadCount,
//   });

//   MessageViewModel copyWith({
//     UserProfileModel? matchedUser,
//     String? matchId,
//     ChatItemModel? lastMessage,
//     DateTime? lastMessageDate,
//     int? unreadCount,
//   }) {
//     return MessageViewModel(
//       matchedUser: matchedUser ?? this.matchedUser,
//       matchId: matchId ?? this.matchId,
//       lastMessage: lastMessage ?? this.lastMessage,
//       lastMessageDate: lastMessageDate ?? this.lastMessageDate,
//       unreadCount: unreadCount ?? this.unreadCount,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};

//     result.addAll({'matchedUser': matchedUser.toMap()});
//     result.addAll({'matchId': matchId});
//     result.addAll({'lastMessage': lastMessage.toMap()});
//     result.addAll({'lastMessageDate': lastMessageDate.millisecondsSinceEpoch});
//     result.addAll({'unreadCount': unreadCount});

//     return result;
//   }

//   factory MessageViewModel.fromMap(Map<String, dynamic> map) {
//     return MessageViewModel(
//       matchedUser: UserProfileModel.fromMap(map['matchedUser']),
//       matchId: map['matchId'] ?? '',
//       lastMessage: ChatItemModel.fromMap(map['lastMessage']),
//       lastMessageDate:
//           DateTime.fromMillisecondsSinceEpoch(map['lastMessageDate']),
//       unreadCount: map['unreadCount']?.toInt() ?? 0,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory MessageViewModel.fromJson(String source) =>
//       MessageViewModel.fromMap(json.decode(source));

//   @override
//   String toString() {
//     return 'MessageViewModel(matchedUser: $matchedUser, matchId: $matchId, lastMessage: $lastMessage, lastMessageDate: $lastMessageDate, unreadCount: $unreadCount)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is MessageViewModel &&
//         other.matchedUser == matchedUser &&
//         other.matchId == matchId &&
//         other.lastMessage == lastMessage &&
//         other.lastMessageDate == lastMessageDate &&
//         other.unreadCount == unreadCount;
//   }

//   @override
//   int get hashCode {
//     return matchedUser.hashCode ^
//         matchId.hashCode ^
//         lastMessage.hashCode ^
//         lastMessageDate.hashCode ^
//         unreadCount.hashCode;
//   }
// }

// List<MessageViewModel> getAllMessages(WidgetRef ref, List<MatchModel> data) {
//   final otherUserIds = data.map((e) {
//     return e.userIds.any((element) =>
//             element != ref.watch(currentUserStateProvider)!.phoneNumber)
//         ? e.userIds.firstWhere((element) =>
//             element != ref.watch(currentUserStateProvider)!.phoneNumber)
//         : null;
//   }).toList();

//   final otherUsers = ref.watch(otherUsersProvider);
//   List<UserProfileModel> matchedUsers = [];
//   otherUsers.whenData((value) {
//     matchedUsers = value.where((element) {
//       return otherUserIds.contains(element.phoneNumber);
//     }).toList();
//   });

//   List<MessageViewModel> messages = [];

//   for (var match in data) {
//     final chatProvider = ref.watch(chatStreamProviderProvider(match.id));
//     chatProvider.whenData((value) {
//       final UserProfileModel otherUser = matchedUsers.firstWhere((element) =>
//           element.phoneNumber ==
//           match.userIds.firstWhere((element) =>
//               element != ref.watch(currentUserStateProvider)!.phoneNumber));

//       int unreadCount = 0;
//       for (var message in value) {
//         if (message.phoneNumber !=
//             ref.watch(currentUserStateProvider)!.phoneNumber) {
//           if (message.isRead == false) {
//             unreadCount++;
//           }
//         }
//       }

//       if (value.isNotEmpty) {
//         MessageViewModel message = MessageViewModel(
//           matchedUser: otherUser,
//           lastMessage: value.first,
//           lastMessageDate: value.first.createdAt,
//           matchId: match.id,
//           unreadCount: unreadCount,
//         );

//         messages.add(message);
//       }
//     });
//   }

//   return messages;
// }
