import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/helpers/common_fun.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/my_loading/costumview/common_ui.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoViewPage extends ConsumerStatefulWidget {
  final List<String> images;
  final SharedPreferences prefs;
  final String? title;
  final int index;
  const PhotoViewPage({
    super.key,
    required this.images,
    required this.prefs,
    this.title,
    this.index = 0,
  });

  // SharedPreferences get prefs => null;

  @override
  ConsumerState<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends ConsumerState<PhotoViewPage> {
  final _pageController = PageController();
  final _photoViewController = PhotoViewController();
  InterstitialAd? interstitialAd;

  final List<String> _images = [];

  void _ads() {
    CommonFun.interstitialAd((ad) {
      interstitialAd = ad;
    });
  }

  @override
  void initState() {
    _images.addAll(widget.images);
    if (!kIsWeb) {
      _ads();
    }
    Future.delayed(const Duration(milliseconds: 10), () {
      _pageController.jumpToPage(widget.index);
    });
    super.initState();
  }

  Future saveFile(BuildContext context,
      {Uint8List? image, LinkDetails? link}) async {
    MimeType type = MimeType.png;
    // LamatCamera.saveImage(file.path);

    if (image != null) {
      await FileSaver.instance.saveFile(
          name: 'download', ext: '.png', mimeType: type, bytes: image);
    }
    if (link != null) {
      await FileSaver.instance
          .saveFile(name: 'download', ext: '.png', mimeType: type, link: link);
    }

    if (!kIsWeb && interstitialAd != null) {
      interstitialAd?.show().then((value) {
        // Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _photoViewController.dispose();
    _images.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Teme.isDarktheme(widget.prefs)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomIconButton(
            icon: leftArrowSvg,
            onPressed: () {
              (!Responsive.isDesktop(context))
                  ? Navigator.pop(context)
                  : ref.invalidate(arrangementProviderExtend);
            },
            padding:
                const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
          ),
        ),
        title: Text(widget.title == null ? "" : widget.title!),
        actions: [
          Tooltip(
            message: 'Save Image',
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                Icons.download,
                color: AppConstants.primaryColor,
              ),
              onPressed: () async {
                final String image = _images[_pageController.page!.round()];
                await saveFile(context, link: LinkDetails(link: image));
                CommonUI.showToast(msg: LocaleKeys.fileSavedSuccessfully.tr());
              },
            ),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _images.map((image) {
          return Uri.parse(image).isAbsolute
              ? PhotoView(
                  controller: _photoViewController,
                  imageProvider: CachedNetworkImageProvider(image),
                )
              : PhotoView(
                  controller: _photoViewController,
                  imageProvider: FileImage(File(image)),
                );
        }).toList(),
      ),
    );
  }
}

class SinglePhotoViewPage extends StatefulWidget {
  final List<String> images;
  final String? title;
  final int? index;
  const SinglePhotoViewPage({
    super.key,
    required this.images,
    this.title,
    this.index,
  });

  @override
  State<SinglePhotoViewPage> createState() => _SinglePhotoViewPage();
}

class _SinglePhotoViewPage extends State<SinglePhotoViewPage> {
  final _pageController = PageController();
  final _photoViewController = PhotoViewController();

  final List<String> _images = [];
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    _images.addAll(widget.images);
    if (!kIsWeb) {
      _ads();
    }
    Future.delayed(const Duration(milliseconds: 10), () {
      _pageController.jumpToPage(widget.index!);
    });
    super.initState();
  }

  void _ads() {
    CommonFun.interstitialAd((ad) {
      interstitialAd = ad;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _photoViewController.dispose();
    _images.clear();
    super.dispose();
  }

  Future saveFile(BuildContext context,
      {Uint8List? image, LinkDetails? link}) async {
    MimeType type = MimeType.png;
    // LamatCamera.saveImage(file.path);

    if (image != null) {
      await FileSaver.instance.saveFile(
          name: 'download', ext: '.png', mimeType: type, bytes: image);
    }
    if (link != null) {
      await FileSaver.instance
          .saveFile(name: 'download', ext: '.png', mimeType: type, link: link);
    }

    if (!kIsWeb && interstitialAd != null) {
      interstitialAd?.show().then((value) {
        // Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title == null ? "" : widget.title!),
      //   actions:  [
      //     Tooltip(
      //       message: 'Save Image',
      //       child: CupertinoButton(
      //         padding: EdgeInsets.zero,
      //         child: const Icon(
      //           Icons.download,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           final String image = _images[_pageController.page!.round()];
      //           final File file = File(image);
      //           final String fileName = file.path.split('/').last;

      //           final String filePath = '${file.parent.path}/$fileName';

      //           final File fileToSave = File(filePath);

      //           if (fileToSave.existsSync()) {
      //             fileToSave.deleteSync();
      //           }
      //           file.copySync(filePath);
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             SnackBar(
      //               content: Text('Image saved to $filePath'),
      //             ),
      //           );
      //         },
      //       ),
      //     )
      //   ],
      // ),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.only(
                  left: AppConstants.defaultNumericValue,
                  top: MediaQuery.of(context).padding.top),
              child: CustomAppBar(
                  leading: CustomIconButton(
                      icon: leftArrowSvg,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8)),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.images.tr(),
                  )),
                  trailing: Tooltip(
                    message: 'Save Image',
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(
                        Icons.download,
                        color: AppConstants.primaryColor,
                      ),
                      onPressed: () async {
                        final String image =
                            _images[_pageController.page!.round()];
                        await saveFile(context, link: LinkDetails(link: image));
                        CommonUI.showToast(
                            msg: LocaleKeys.fileSavedSuccessfully.tr());
                      },
                    ),
                  ))),
          const SizedBox(height: AppConstants.defaultNumericValue),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _images.map((image) {
                return Uri.parse(image).isAbsolute
                    ? PhotoView(
                        controller: _photoViewController,
                        imageProvider: CachedNetworkImageProvider(image),
                      )
                    : PhotoView(
                        controller: _photoViewController,
                        imageProvider: FileImage(File(image)),
                      );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
