// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/search/item_search_video.dart';

class VideosByHashTagScreen extends ConsumerStatefulWidget {
  final String? hashTag;

  const VideosByHashTagScreen(this.hashTag, {super.key});

  @override
  _VideosByHashTagScreenState createState() => _VideosByHashTagScreenState();
}

class _VideosByHashTagScreenState extends ConsumerState<VideosByHashTagScreen> {
  var start = 0;
  int? count = 0;

  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final StreamController _streamController =
      StreamController<List<TeelsModel>?>();
  List<TeelsModel> postList = [];

  @override
  void initState() {
    _scrollController.addListener(
      () {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          if (!isLoading) {
            callApiForGetPostsByHashTag();
          }
        }
      },
    );
    callApiForGetPostsByHashTag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      width: 40,
                      padding: const EdgeInsets.only(left: 10),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Center(
                    child: Text(
                      widget.hashTag!,
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              height: 80,
              decoration: const BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.secondaryColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.secondaryColor,
                          blurRadius: 10,
                          offset: Offset(1, 1),
                        ),
                      ],
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        AppRes.hashTag,
                        style: TextStyle(
                          fontFamily: fNSfUiBold,
                          fontSize: 45,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hashTag!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: fNSfUiBold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        '$count ${LocaleKeys.videos.tr()}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppConstants.textColorLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  List<TeelsModel>? userVideo = [];
                  if (snapshot.data != null) {
                    userVideo = (snapshot.data as List<TeelsModel>?)!;
                    postList.addAll(userVideo);
                    _streamController.add(null);
                  }
                  if (kDebugMode) {
                    print(postList.length);
                  }
                  return postList.isEmpty
                      ? const LoadingPage()
                      : GridView(
                          shrinkWrap: true,
                          controller: _scrollController,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1 / 1.4,
                          ),
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 10, bottom: 20),
                          children: List.generate(
                            postList.length,
                            (index) => ItemSearchVideo(
                              videoData: postList[index],
                              postList: postList,
                              type: "video",
                              hashTag: widget.hashTag,
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void callApiForGetPostsByHashTag() {
    final allTeels = ref.watch(getTeelsProvider);

    allTeels.when(
      data: (teelsList) {
        final hashtagTeels = teelsList
            .where((element) => element.postHashTag!.contains(widget.hashTag!))
            .toList();

        if (hashtagTeels.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
                child: NoItemFoundWidget(text: LocaleKeys.noFeedFound.tr())),
          );
        } else {
          start += ConstRes.count;
          isLoading = false;
          if (count == 0) {
            count = hashtagTeels.length;
            setState(() {});
          }
          _streamController.add(hashtagTeels);
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(LocaleKeys.error.toString())),
    );
  }
}
