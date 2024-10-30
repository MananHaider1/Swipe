// // ignore_for_file: library_private_types_in_public_api

// import 'dart:async';

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/helpers/my_loading/my_loading.dart';
// import 'package:lamatdating/models/teels_model.dart';
// import 'package:lamatdating/providers/teels_provider.dart';
// import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
// import 'package:lamatdating/views/loading_error/loading_page.dart';

// import 'item_search_video.dart';

// class SearchVideoScreen extends ConsumerStatefulWidget {
//   const SearchVideoScreen({super.key});

//   @override
//   _SearchVideoScreenState createState() => _SearchVideoScreenState();
// }

// class _SearchVideoScreenState extends ConsumerState<SearchVideoScreen> {
//   String keyWord = '';
//   // ApiService apiService = ApiService();

//   int start = 0;
//   final _streamController = StreamController<List<TeelsModel>?>();
//   final ScrollController _scrollController = ScrollController();

//   List<TeelsModel> searchPostList = [];

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     _scrollController.addListener(() {
//       if (_scrollController.position.maxScrollExtent ==
//           _scrollController.position.pixels) {
//         if (!isLoading) {
//           isLoading = true;
//           callApiForPostList();
//         }
//       }
//     });
//     super.didChangeDependencies();
//     // ...to here
//     // getUserData(ref);
//     // saveTokenUpdate();
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
//             searchPostList = [];
//             callApiForPostList();
//             return Container();
//           },
//         ),
//         Expanded(
//           child: StreamBuilder(
//             stream: _streamController.stream,
//             builder: (context, snapshot) {
//               List<TeelsModel>? searchVideo = [];
//               if (snapshot.data != null) {
//                 searchVideo = (snapshot.data)!;
//                 searchPostList.addAll(searchVideo);
//               }
//               return searchPostList.isEmpty
//                   ? const LoadingPage()
//                   : GridView(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1 / 1.4,
//                       ),
//                       controller: _scrollController,
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.only(left: 10, bottom: 20),
//                       children: List.generate(
//                         searchPostList.length,
//                         (index) => ItemSearchVideo(
//                           videoData: searchPostList[index],
//                           postList: searchPostList,
//                           type: "video",
//                           keyWord: keyWord,
//                         ),
//                       ),
//                     );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   void callApiForPostList() {
//     final allTeels = ref.watch(getTeelsProvider);

//     allTeels.when(
//         data: (teelsList) {
//           final typeTeels = teelsList
//               .where((element) => element.caption!.contains(keyWord))
//               .skip(start)
//               .take(10)
//               .toList();

//           if (typeTeels.isEmpty) {
//             return SizedBox(
//               height: MediaQuery.of(context).size.height * 0.5,
//               child: Center(
//                   child: NoItemFoundWidget(text: LocaleKeys.noFeedFound.tr())),
//             );
//           } else {
//             if (kDebugMode) {
//               print(typeTeels.length);
//             }
//             start += 10;
//             isLoading = false;
//             _streamController.add(typeTeels);
//           }
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (error, stack) =>
//             Center(child: Text(LocaleKeys.errorOccured.tr())));
//   }
// }
