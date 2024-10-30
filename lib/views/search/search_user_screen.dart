// // ignore_for_file: library_private_types_in_public_api

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:lamatdating/helpers/api_service.dart';
// import 'package:lamatdating/helpers/constants.dart';
// import 'package:lamatdating/helpers/my_loading/my_loading.dart';
// import 'package:lamatdating/modal/search/search_user.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';
// import 'package:lamatdating/views/search/item_search_user.dart';

// class SearchUserScreen extends ConsumerStatefulWidget {
//   const SearchUserScreen({super.key});

//   @override
//   _SearchUserScreenState createState() => _SearchUserScreenState();
// }

// class _SearchUserScreenState extends ConsumerState<SearchUserScreen> {
//   String keyWord = '';
//   ApiService apiService = ApiService();

//   int start = 0;
//   final _streamController = StreamController<List<SearchUserData>?>();
//   final ScrollController _scrollController = ScrollController();

//   List<SearchUserData>? searchUserList = [];

//   bool isLoading = true;

//   @override
//   void initState() {
//     _scrollController.addListener(() {
//       if (_scrollController.position.maxScrollExtent ==
//           _scrollController.position.pixels) {
//         if (!isLoading) {
//           isLoading = true;
//           callApiForSearchUsers();
//         }
//       }
//     });
//     // callApiForSearchUsers();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Consumer(
//           builder: (context, ref, child) {
//             final myLoadingProviderProvider = ref.watch(myLoadingProvider);
//             start = 0;
//             keyWord = myLoadingProviderProvider.getSearchText;
//             searchUserList = [];
//             callApiForSearchUsers();
//             return Container();
//           },
//         ),
//         Expanded(
//           child: StreamBuilder(
//             stream: _streamController.stream,
//             builder: (context, snapshot) {
//               List<SearchUserData>? searchUser = [];
//               if (snapshot.data != null) {
//                 searchUser = (snapshot.data)!;
//                 searchUserList?.addAll(searchUser);
//               }
//               return searchUserList == null || searchUserList!.isEmpty
//                   ? const LoadingPage()
//                   : ListView(
//                       physics: const BouncingScrollPhysics(),
//                       controller: _scrollController,
//                       padding: const EdgeInsets.only(left: 10, bottom: 20),
//                       children: List.generate(
//                         searchUserList?.length ?? 0,
//                         (index) => ItemSearchUser(searchUserList?[index]),
//                       ),
//                     );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void callApiForSearchUsers() {
//     apiService.client.close();

//     apiService
//         .getSearchUser(start.toString(), ConstRes.count.toString(), keyWord)
//         .then((value) {
//       start += ConstRes.count;
//       isLoading = false;
//       _streamController.add(value.data);
//     });
//   }
// }
