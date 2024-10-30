import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:lamatdating/models/feed_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/feed_provider_web.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider_web.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedPostPage extends ConsumerStatefulWidget {
  const FeedPostPage({super.key});

  @override
  ConsumerState<FeedPostPage> createState() => _FeedPostPageState();
}

class _FeedPostPageState extends ConsumerState<FeedPostPage> {
  final TextEditingController _postController = TextEditingController();
  // final List<h.File> _selectedImages = [];
  final List<Uint8List?> _selectedImagesBytes = [];

  bool _bottomButtonVisible = true;
  bool _enablePostButton = false;
  double _postFontSize = 28;

  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void _onPost() async {
    EasyLoading.show(status: LocaleKeys.posting.tr());
    if (kDebugMode) {
      // print("IMAGE BYTES: $_selectedImagesBytes");
      // print("IMAGE BYTES: $_selectedImages");
    }

    final currentTime = DateTime.now();
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final feedId = phoneNumber! + currentTime.millisecondsSinceEpoch.toString();

    List<String> imageUrls = [];

    if (_selectedImagesBytes.isNotEmpty) {
      if (kDebugMode) {
        print("IMAGE BYTES: ${_selectedImagesBytes.length}");
      }
      await uploadFeedImages(
              files: _selectedImagesBytes, phoneNumber: phoneNumber)
          .then((value) {
        setState(() {
          imageUrls = value;
        });
      });
    }
    if (kDebugMode) {
      print("IMAGE URLS: ${imageUrls.length}");
    }

    final FeedModel feedModel = FeedModel(
        id: feedId,
        caption: _postController.text.isEmpty ? null : _postController.text,
        phoneNumber: phoneNumber,
        createdAt: currentTime,
        images: imageUrls,
        likes: [],
        comments: []);

    await addFeed(feedModel).then((result) {
      if (result) {
        EasyLoading.showSuccess(LocaleKeys.posted.tr());
        ref.invalidate(getFeedsProvider);

        !Responsive.isDesktop(context)
            ? Navigator.pop(context)
            : ref.invalidate(arrangementProviderExtend);
      } else {
        EasyLoading.showError(LocaleKeys.failedtopost.tr());
      }
    });
  }

  void _onPressedGallery() async {
    // kIsWeb
    //     ?
    await pickMediaAsBytes().then((value) async {
      setState(() {
        _selectedImagesBytes.add(value!);
      });
    });

    // : await _picker.pickMultiImage(imageQuality: 30).then((value) async {
    //     for (var item in value) {
    //       setState(() {
    //         _selectedImages.add(File(item.path));
    //       });
    //     }
    //   });
  }

  // void _onPressedCamera() async {
  //   await _picker
  //       .pickImage(source: ImageSource.camera, imageQuality: 50)
  //       .then((value) async {
  //     if (value != null) {
  //       await xFileToBytes(value).then((value) {
  //         setState(() {
  //           _selectedImagesBytes.add(value);
  //         });
  //       });
  //       // setState(() {
  //       //   // _selectedImages.add();
  //       // });
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final prefss = ref.watch(sharedPreferences).value;
    _enablePostButton =
        _postController.text.isNotEmpty || _selectedImagesBytes.isNotEmpty;

    return SafeArea(
      child: Scaffold(
        bottomSheet: _bottomButtonVisible
            ? CreateNewPostBottomButtons(
                onPressedOpenGallery: _onPressedGallery,
                // onPressedOpenCamera: _onPressedCamera,
                prefss: prefss!,
              )
            : CreatePostBottomButtonsBar(
                // onPressedOpenCamera: _onPressedCamera,
                onPressedOpenGallery: _onPressedGallery,
                onPressedHideBottomButton: () {
                  setState(() {
                    _bottomButtonVisible = true;
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              ),
        backgroundColor: Teme.isDarktheme(prefss!)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _createNewPostTopBar(context, _onPost),
                const SizedBox(
                  height: 16,
                ),
                const CretePostNameSection(),
                _createNewPostTextField(),
                _createNewPostImageSection(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createNewPostImageSection(BuildContext context) {
    return Wrap(
        children:
            // !kIsWeb
            //     ?
            _selectedImagesBytes.map((e) {
      return SizedBox(
        width: _selectedImagesBytes.length > 1
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.memory(
                e!,
                errorBuilder: (context, url, error) =>
                    const Center(child: Icon(CupertinoIcons.photo)),
                fit: BoxFit.cover,
              ),
              // Image.file(e, fit: BoxFit.cover),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedImagesBytes
                        .removeAt(_selectedImagesBytes.indexOf(e));
                  });
                },
                icon: const Icon(Icons.cancel),
              ),
            )
          ],
        ),
      );
    }).toList()
        // : _selectedImagesBytes.map((e) {
        //     return SizedBox(
        //       width: _selectedImagesBytes.length > 1
        //           ? MediaQuery.of(context).size.width / 2
        //           : MediaQuery.of(context).size.width,
        //       child: Stack(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.all(4.0),
        //             child: Image(image: MemoryImage(e)),
        //           ),
        //           Positioned(
        //             right: 0,
        //             top: 0,
        //             child: IconButton(
        //               onPressed: () {
        //                 setState(() {
        //                   _selectedImagesBytes
        //                       .removeAt(_selectedImagesBytes.indexOf(e));
        //                 });
        //               },
        //               icon: const Icon(Icons.cancel),
        //             ),
        //           )
        //         ],
        //       ),
        //     );
        //   }).toList(),
        );
  }

  Container _createNewPostTextField() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: _postFontSize, end: _postFontSize),
          builder: (context, double size, child) {
            return TextField(
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardType: TextInputType.multiline,
              maxLines: 9,
              minLines: 1,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(decoration: TextDecoration.none, fontSize: size),
              controller: _postController,
              onTap: () {
                setState(() {
                  _bottomButtonVisible = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _enablePostButton = true;
                  } else {
                    _enablePostButton = false;
                  }
                  if (value.length > 85) {
                    _postFontSize = 16;
                  } else {
                    _postFontSize = 28;
                  }
                });
              },
              decoration: InputDecoration(
                hintText: LocaleKeys.whatsonyourmind.tr(),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    // color: Colors.black.withOpacity(0.38),
                    ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _createNewPostTopBar(BuildContext context, VoidCallback onPost) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.black.withOpacity(0.12),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomIconButton(
              padding:
                  const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
              onPressed: () {
                _bottomButtonVisible = true;
                FocusScope.of(context).requestFocus(FocusNode());
                !Responsive.isDesktop(context)
                    ? Navigator.pop(context)
                    : ref.invalidate(arrangementProviderExtend);
              },
              color: AppConstants.primaryColor,
              icon: leftArrowSvg),
          const SizedBox(width: AppConstants.defaultNumericValue / 2),
          Expanded(
            child: Text(LocaleKeys.createPost.tr(),
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: ElevatedButton(
              onPressed: _enablePostButton
                  ? () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      onPost();
                    }
                  : null,
              child: Text(LocaleKeys.post.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateNewPostBottomButtons extends StatelessWidget {
  final VoidCallback onPressedOpenGallery;
  // final VoidCallback onPressedOpenCamera;
  final SharedPreferences prefss;
  const CreateNewPostBottomButtons({
    super.key,
    required this.onPressedOpenGallery,
    // required this.onPressedOpenCamera,
    required this.prefss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Teme.isDarktheme(prefss)
          ? AppConstants.backgroundColorDark
          : AppConstants.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(LocaleKeys.gallery.tr()),
            onTap: onPressedOpenGallery,
            leading: const Icon(Icons.photo_library, color: Colors.red),
          ),
          // const Divider(),
          // ListTile(
          //   title: Text(LocaleKeys.camera.tr()),
          //   onTap: onPressedOpenCamera,
          //   leading: const Icon(Icons.camera_alt, color: Colors.purple),
          // ),
        ],
      ),
    );
  }
}

class CreatePostBottomButtonsBar extends StatelessWidget {
  final VoidCallback onPressedHideBottomButton;
  final VoidCallback onPressedOpenGallery;
  // final VoidCallback onPressedOpenCamera;
  const CreatePostBottomButtonsBar({
    super.key,
    required this.onPressedHideBottomButton,
    required this.onPressedOpenGallery,
    // required this.onPressedOpenCamera,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(
            height: 1,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: onPressedOpenGallery,
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.red,
                  )),
              // IconButton(
              //     onPressed: onPressedOpenCamera,
              //     icon: const Icon(
              //       Icons.camera_alt,
              //       color: Colors.purple,
              //     )),
              IconButton(
                  onPressed: onPressedHideBottomButton,
                  icon: const Icon(Icons.pending_rounded,
                      color: Colors.blueGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

class CretePostNameSection extends ConsumerWidget {
  const CretePostNameSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserProfile = ref.watch(userProfileFutureProvider);

    return currentUserProfile.when(
        data: (data) {
          return data == null
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(
                      top: 0, bottom: 8, left: 16, right: 16),
                  child: Row(
                    children: [
                      UserCirlePicture(
                          imageUrl: data.profilePicture,
                          size: AppConstants.defaultNumericValue * 2.5),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(data.fullName,
                            style: Theme.of(context).textTheme.titleLarge!),
                      ),
                    ],
                  ),
                );
        },
        error: (_, __) => const SizedBox(),
        loading: () => const SizedBox());
  }
}
