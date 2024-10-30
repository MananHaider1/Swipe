// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, unused_local_variable

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
// import 'package:lamatdating/helpers/media_picker_helper_web.dart';
import 'package:lamatdating/main.dart';
import 'package:lamatdating/models/teels_model.dart';
import 'package:lamatdating/providers/add_story_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/teels_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';

class UploadScreenTeels extends ConsumerStatefulWidget {
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final String? soundId;
  final Uint8List? postVideoWeb;
  final Uint8List? postPhotoWeb;
  final Uint8List? thumbNailWeb;
  final bool? isPhoto;

  const UploadScreenTeels(
      {super.key,
      this.postVideo,
      this.thumbNail,
      this.sound,
      this.soundId,
      this.postVideoWeb,
      this.postPhotoWeb,
      this.thumbNailWeb,
      this.isPhoto});

  @override
  ConsumerState<UploadScreenTeels> createState() => _UploadScreenTeelsState();
}

class _UploadScreenTeelsState extends ConsumerState<UploadScreenTeels> {
  ValueNotifier<int> textSize = ValueNotifier<int>(0);
  String postDes = '';
  bool canDownload = true;
  bool canSave = true;
  bool canComment = true;
  bool canDuet = true;
  bool showLikes = true;
  String currentHashTag = '';
  List<String> hashTags = [];
  Uint8List? thumb;
  String generateRandomString(int length) {
    const chars =
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  void initState() {
    super.initState();
  }

  final controller = DetectableTextEditingController(
    regExp: detectionRegExp(url: false, hashtag: true, atSign: false),
    detectedStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.6,
        fontSize: 13,
        color: AppConstants.primaryColor),
  );

  bool isDetected(String s, RegExp hashTagRegExp) {
    final matches = hashTagRegExp.allMatches(s);
    return matches.isNotEmpty;
  }

  List<String> extractDetections(String s, RegExp hashTagRegExp) {
    final matches = hashTagRegExp.allMatches(s);
    return matches.map((match) => match.group(0)!).toList();
  }

  void _onPost() async {
    EasyLoading.show(status: LocaleKeys.posting.tr());
    Duration? duration;
    if (!kIsWeb) {
      final player = AudioPlayer();
      duration = await player.setUrl(widget.sound!);
    } else {
      duration = const Duration(seconds: 30);
    }

    final currentTime = DateTime.now();
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    final userName = ref.watch(userProfileFutureProvider).when(data: (data) {
      if (data != null) {
        return data.userName;
      } else {
        return "";
      }
    }, error: (Object error, StackTrace stackTrace) {
      return "";
    }, loading: () {
      return "";
    });
    final String profileCategory =
        ref.watch(userProfileFutureProvider).when(data: (data) {
      if (data != null) {
        return data.profileCategoryName!;
      } else {
        return "New";
      }
    }, error: (Object error, StackTrace stackTrace) {
      return "New";
    }, loading: () {
      return "New";
    });
    final String name = ref.watch(userProfileFutureProvider).when(data: (data) {
      if (data != null) {
        return data.fullName;
      }
      return "";
    }, error: (Object error, StackTrace stackTrace) {
      return "";
    }, loading: () {
      return "";
    });

    final storyId =
        phoneNumber! + currentTime.millisecondsSinceEpoch.toString();

    String fileUrl = "";
    String thumbnailUrl = "";
    String postSoundUrl = "";
    String postType = "video";
    String postDuration = duration.toString();

    if (widget.postVideo != null) {
      final url = await uploadTeelFile(
        uploadFile: File(widget.postVideo ?? ''),
        phoneNumber: phoneNumber,
      );
      fileUrl = url;
    }

    if (widget.postVideoWeb != null) {
      final url = await uploadTeelFileWeb(
          uploadFile: widget.postVideoWeb!,
          phoneNumber: phoneNumber,
          type: "video");
      fileUrl = url;
    }

    if (widget.thumbNail != null) {
      final url1 = await uploadStoryThumbnail(
        uploadThumbnail: File(widget.thumbNail!),
        phoneNumber: phoneNumber,
      );
      thumbnailUrl = url1;
    } else {
      thumbnailUrl = profilePic;
    }

    if (thumb != null) {
      final url = await uploadTeelThumbnailWeb(
        uploadThumbnail: thumb!,
        phoneNumber: phoneNumber,
      );
      thumbnailUrl = url;
    }

    if (widget.sound != null) {
      final url2 = await uploadStorySound(
        uploadSound: File(widget.postVideo ?? ''),
        phoneNumber: phoneNumber,
      );
      postSoundUrl = url2;
    }

    if (widget.sound != null) {
      final url2 = await uploadStorySoundImage(
        uploadStorySoundImage: File(widget.thumbNail!),
        phoneNumber: phoneNumber,
      );
      postSoundUrl = url2;
    }
    // if (widget.sound == null) {
    //   final url2 = profilePic;
    //   postSoundImage = url2;
    // }

    if (currentHashTag.isNotEmpty) {
      hashTags.add(currentHashTag);
      currentHashTag = '';
    }

    final TeelsModel teelsModel = TeelsModel(
        id: storyId,
        userName: userName,
        caption: postDes,
        phoneNumber: phoneNumber,
        createdAt: currentTime,
        postVideo: fileUrl,
        likes: [],
        views: [],
        saves: [],
        profileCategoryName: profileCategory,
        isOrignalSound: (widget.soundId == null) ? true : false,
        postSound: postSoundUrl,
        postType: postType,
        singer: name,
        soundId: storyId.isNotEmpty ? storyId : generateRandomString(10),
        soundImage: thumbnailUrl,
        soundTitle: '$userName • ${LocaleKeys.originalSound.tr()}',
        thumbnail: thumbnailUrl,
        postHashTag: hashTags.join(","),
        duration: postDuration,
        comments: [],
        isTrending: false,
        canComment: canComment,
        canDownload: canDownload,
        canDuet: canDuet,
        canSave: canSave,
        videoShowLikes: showLikes);

    for (final hashtag in hashTags) {
      final hashtagDoc =
          FirebaseFirestore.instance.collection('hashtags').doc(hashtag);
      final hashtagSnapshot = await hashtagDoc.get();

      if (hashtagSnapshot.exists) {
      } else {
        // Document does not exist, create a document
        await hashtagDoc.set({
          'name': hashtag,
          'image':
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRMg-8QhbZvcf-pxSXg2WtE3NnTmdqr0b_BHA&usqp=CAU',
          'createdAt': DateTime.now(),
          'verified': false,
        });
      }
    }

    await addTeel(teelsModel).then((result) {
      if (result) {
        ref.read(addBalanceProvider(AppRes.teelReward.toDouble()));
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        EasyLoading.showSuccess(LocaleKeys.posted.tr());
        ref.invalidate(getTeelsProvider);
        // Navigator.pop(context);
        // Navigator.pop(context);
      } else {
        EasyLoading.showError(LocaleKeys.failedtopost.tr());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return Container(
      height: height * .9,
      decoration: BoxDecoration(
        color: !Teme.isDarktheme(prefs!)
            ? AppConstants.backgroundColor
            : AppConstants.backgroundColorDark,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: const BoxDecoration(
                  // color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    LocaleKeys.uploadVideo.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                child: InkWell(
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close_rounded,
                      // color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                height: 160,
                width: 110,
                child: InkWell(
                  onTap: () async {
                    // final imagePath =
                    //     await pickMediaWeb(isVideo: false).then((value) {
                    //   final observer = ref.watch(observerProvider);

                    //   if (value != null) {
                    //     if (value.lengthInBytes / (1024 * 1024) <
                    //         observer.maxFileSizeAllowedInMB) {
                    //       setState(() {
                    //         thumb = value;
                    //       });
                    //     }
                    //   }
                    // });
                    await pickMediaAsData().then((value) {
                      final observer = ref.watch(observerProvider);
                      if (value != null) {
                        if (value.pickedFile!.lengthInBytes / (1024 * 1024) <
                            observer.maxFileSizeAllowedInMB) {
                          setState(() {
                            thumb = value.pickedFile;
                          });
                        }
                      }
                    });
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(
                        Radius.circular(AppConstants.defaultNumericValue)),
                    child: SizedBox(
                      height: 160,
                      width: 110,
                      child: Stack(
                        children: [
                          Container(
                            height: 160,
                            width: 110,
                            color: Colors.grey,
                          ),
                          Center(
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                          if (thumb != null)
                            Image(
                              height: 160,
                              width: 110,
                              fit: BoxFit.cover,
                              image: MemoryImage(thumb!),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(.1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(AppConstants.defaultNumericValue)),
                      ),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      height: 160,
                      child: DetectableTextField(
                        controller: controller,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontSize: 16,
                            ),
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2200),
                        ],
                        enableSuggestions: false,
                        maxLines: 8,
                        onChanged: (value) {
                          textSize.value = value.length;
                          postDes = value;
                          if (isDetected(value, hashTagRegExp)) {
                            hashTags = extractDetections(
                              value,
                              hashTagRegExp,
                            );
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: LocaleKeys.awesomeCaption.tr(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: ValueListenableBuilder(
                valueListenable: textSize,
                builder: (context, dynamic value, child) => Text(
                  '$value/${AppRes.textTotalCount}',
                  style: const TextStyle(
                    color: AppConstants.textColorLight,
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          ExpansionTile(
            title: const Text('Privacy Settings'),

            // trailing: const Icon(Icons.arrow_drop_down), // default icon
            onExpansionChanged: (bool expanding) {
              setState(() {
                if (expanding) {
                  // if the tile is expanding change the icon
                  const ExpansionTile(
                    title: Text('Privacy Settings'),
                    trailing: Icon(Icons.arrow_drop_up),
                  );
                } else {
                  // if the tile is collapsing change the icon
                  const ExpansionTile(
                    title: Text('Privacy Settings'),
                    trailing: Icon(Icons.arrow_drop_down),
                  );
                }
              });
            },
            children: <Widget>[
              CheckboxListTile(
                title: const Text('Others can download video'),
                value: canDownload,
                onChanged: (bool? value) {
                  setState(() {
                    canDownload = value!;
                  });
                },
              ),
              CheckboxListTile(
                shape: const CircleBorder(),
                title: const Text('Others can save video'),
                value: canSave,
                onChanged: (bool? value) {
                  setState(() {
                    canSave = value!;
                  });
                },
              ),
              CheckboxListTile(
                shape: const CircleBorder(),
                title: const Text('Others can comment on video'),
                value: canComment,
                onChanged: (bool? value) {
                  setState(() {
                    canComment = value!;
                  });
                },
              ),
              CheckboxListTile(
                shape: const CircleBorder(),
                title: const Text('Others can duet with video'),
                value: canDuet,
                onChanged: (bool? value) {
                  setState(() {
                    canDuet = value!;
                  });
                },
              ),
              CheckboxListTile(
                shape: const CircleBorder(),
                title: const Text('Show likes to others'),
                value: showLikes,
                onChanged: (bool? value) {
                  setState(() {
                    showLikes = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              const SizedBox(
                width: AppConstants.defaultNumericValue,
              ),
              Expanded(
                  child: CustomButton(
                      onPressed: () {
                        if (currentHashTag.isNotEmpty) {
                          hashTags.add(currentHashTag);
                        }

                        if (thumb != null) {
                          showDialog(
                            context: context,
                            builder: (context) => const LoaderDialog(),
                          );
                        }
                        (thumb == null)
                            ? EasyLoading.showError('Please select a thumbnail')
                            : _onPost();
                      },
                      text: LocaleKeys.uploadVideo.tr().toUpperCase())),
              const SizedBox(
                width: AppConstants.defaultNumericValue,
              ),
            ],
          ),

          const SizedBox(
            height: 30,
          ),
          const Text(
            AppRes.privacyPolicy,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontFamily: fNSfUiLight,
              color: AppConstants.textColorLight,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          InkWell(
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WebViewScreen(3),
              ),
            ),
            child: Text(
              LocaleKeys.policyCenter.tr(),
              style: const TextStyle(
                color: AppConstants.primaryColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      )),
    );
  }

  // void initSessionManager() async {
  //   await _sessionManager.initPref();
  // }
}
