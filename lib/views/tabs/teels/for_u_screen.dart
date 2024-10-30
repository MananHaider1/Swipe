// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/constants.dart';

import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:lamatdating/views/loading_error/error_page.dart';
import 'package:lamatdating/views/loading_error/loading_page.dart';
import 'package:lamatdating/views/video/item_video.dart';

class ForYouScreen extends ConsumerStatefulWidget {
  const ForYouScreen({super.key});

  @override
  ConsumerState<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends ConsumerState<ForYouScreen>
    with AutomaticKeepAliveClientMixin {
  List<Widget> mList = [];
  int start = 0;
  int limit = 10;
  PageController pageController = PageController();

  int? yourTotalPageCount;

  int _currentPage = 0;

  @override
  bool get wantKeepAlive => true;

  Widget buildPreviousButton() {
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
      color: AppConstants.primaryColorDark.withOpacity(.5),
      onPressed: () {
        if (_currentPage > 0) {
          pageController.previousPage(
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      },
    );
  }

  Widget buildNextButton() {
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
      color: AppConstants.primaryColorDark.withOpacity(.5),
      onPressed: () {
        if (_currentPage < yourTotalPageCount! - 1) {
          pageController.nextPage(
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final teelsListAsyncValue = ref.watch(getTeelsProvider);
    super.build(context);

    return teelsListAsyncValue.when(
      data: (teelsList) {
        int end = (start + limit > teelsList.length)
            ? teelsList.length
            : start + limit;
        if (kDebugMode) {
          print("Teels => ${teelsList.length.toString()}");
        }

        List<Widget> newItems = List<Widget>.generate(
          ((end - start) < 0) ? 0 : end - start,
          (index) {
            return teelsList.isNotEmpty
                ? Container(
                    color: AppConstants.backgroundColorDark,
                    child: ItemVideo(teelsList[start + index], false))
                : const NoItemFoundWidget();
          },
        );

        if (mList.isEmpty) {
          mList = newItems;
        } else {
          mList.addAll(newItems);
        }

        if (kDebugMode) {
          print(mList.toString());
        }

        setState(() {
          yourTotalPageCount = (mList.length).ceil();
          // _currentPage = yourTotalPageCount! - 1;
        });
        (start + limit > teelsList.length)
            ? start += teelsList.length
            : start += limit;

        return teelsList.isNotEmpty
            ? Stack(
                children: [
                  PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: pageController,
                    pageSnapping: true,
                    onPageChanged: (value) {
                      _currentPage = value;
                      if (kDebugMode) {
                        print(value);
                      }
                      if (value == mList.length - 1) {
                        getLatestTeels();
                      }
                    },
                    scrollDirection: Axis.vertical,
                    children: mList,
                  ),
                  if (kIsWeb)
                    Positioned(
                      left: AppConstants.defaultNumericValue,
                      top: height * .48,
                      child: buildPreviousButton(),
                    ),
                  if (kIsWeb)
                    Positioned(
                      left: AppConstants.defaultNumericValue,
                      top: height * .52,
                      child: buildNextButton(),
                    ),
                ],
              )
            : const Center(child: NoItemFoundWidget());
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    );
  }

  Future<void> getLatestTeels() async {
    final teelsListAsyncValue = ref.watch(getTeelsProvider);

    teelsListAsyncValue.when(
      data: (teelsList) {
        int end = (start + limit > teelsList.length)
            ? teelsList.length
            : start + limit;
        if (kDebugMode) {
          print("Teels => ${teelsList.length.toString()}");
        }

        List<Widget> newItems = List<Widget>.generate(
          end - start,
          (index) => Container(
              color: AppConstants.backgroundColorDark,
              child: ItemVideo(teelsList[start + index], false)),
        );

        if (mList.isEmpty) {
          mList = newItems;
        } else {
          mList.addAll(newItems);
        }
        if (kDebugMode) {
          print(mList.toString());
        }

        setState(() {});
        (start + limit > teelsList.length)
            ? start += teelsList.length
            : start += limit;
      },
      loading: () => const LoadingPage(),
      error: (e, _) => const ErrorPage(),
    );
  }
}
