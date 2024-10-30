// ignore_for_file: prefer_final_fields, library_private_types_in_public_api

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/views/custom/lottie/no_item_found_widget.dart';
import 'package:websafe_svg/websafe_svg.dart';

import 'item_video.dart';

class VideoListScreen extends ConsumerStatefulWidget {
  final List<TeelsModel?>? list;
  final List<ItemVideo>? listVid;
  final int index;
  final String? type;
  final String? phoneNumber;
  final String? soundId;
  final String? hashTag;
  final String? keyWord;

  const VideoListScreen({
    super.key,
    required this.list,
    this.listVid,
    required this.index,
    required this.type,
    this.phoneNumber,
    this.soundId,
    this.hashTag,
    this.keyWord,
  });

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends ConsumerState<VideoListScreen> {
  late List<ItemVideo> mList;
  PageController? _pageController;
  String comment = '';
  var start = 0;
  var position = 0;

  @override
  void initState() {
    if (kDebugMode) {
      print(widget.list!.length);
    }
    mList = (widget.listVid == null)
        ? List.generate(widget.list!.length,
            (index) => ItemVideo(widget.list![index], true))
        : widget.listVid!;
    _pageController = PageController(initialPage: widget.index);
    start = widget.list!.length;
    position = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final currentUserId =
    //     ref.watch(currentUserStateProvider)!.phoneNumber.toString();
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  pageSnapping: true,
                  onPageChanged: (value) {
                    if (kDebugMode) {
                      print(value);
                    }
                    if (value == mList.length - 1) {
                      callApiForYou();
                    }
                  },
                  scrollDirection: Axis.vertical,
                  children: mList,
                ),
              ),
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: () {
                !(Responsive.isDesktop(context))
                    ? Navigator.pop(context)
                    : ref.invalidate(arrangementProvider);
              },
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WebsafeSvg.asset(
                    leftArrowSvg,
                    colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                // AppConstants.secondaryColor,
                                                Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                    height: 30,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void callApiForYou() {
    final allTeels = ref.watch(getTeelsProvider);

    allTeels.when(
      data: (teelsList) {
        final typeTeels = teelsList
            .where((element) => element.postType!.contains(widget.type!))
            .toList();

        if (typeTeels.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
                child: NoItemFoundWidget(text: LocaleKeys.noFeedFound.tr())),
          );
        } else {
          if (typeTeels.isNotEmpty) {
            if (mList.isEmpty) {
              mList = List<Widget>.generate(
                typeTeels.length,
                (index) {
                  return ItemVideo(typeTeels[index], true);
                },
              ) as List<ItemVideo>;
              setState(() {});
            } else {
              for (TeelsModel data in typeTeels) {
                mList.add(ItemVideo(data, true));
              }
            }
            start += ConstRes.count;
          }
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text(LocaleKeys.somethingWentWrong.tr())),
    );
  }
}
