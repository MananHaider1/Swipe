// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, prefer_typing_uninitialized_variables, avoid_web_libraries_in_flutter, unused_local_variable

import 'package:detectable_text_field/widgets/detectable_text_editing_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:path/path.dart' as path;
import 'package:video_compress/video_compress.dart' as compress;

import 'package:lamatdating/generated/locale_keys.g.dart';
import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/database_keys.dart';
import 'package:lamatdating/helpers/database_paths.dart';
import 'package:lamatdating/providers/add_story_provider.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/observer.dart';
import 'package:lamatdating/providers/status_provider.dart';
import 'package:lamatdating/utils/variants_gen.dart';
import 'package:lamatdating/views/dialog/loader_dialog.dart';
import 'package:lamatdating/views/webview/webview_screen.dart';

class UploadScreenStory extends ConsumerStatefulWidget {
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final String? soundId;
  final bool? isPhoto;
  final Uint8List? videoWeb;
  final Uint8List? photoWeb;
  final Uint8List? thumbNailWeb;

  const UploadScreenStory(
      {super.key,
      this.postVideo,
      this.thumbNail,
      this.sound,
      this.soundId,
      this.isPhoto,
      this.thumbNailWeb,
      this.videoWeb,
      this.photoWeb});

  @override
  ConsumerState<UploadScreenStory> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreenStory> {
  ValueNotifier<int> textSize = ValueNotifier<int>(0);
  String postDes = '';
  List<String> hashTags = [];
  List phoneNumberVariants = [];
  String? currentPhoneNum;
  bool isFetching = true;
  final videoInfo = FlutterVideoInfo();
  var info;
  Uint8List? thumb;
  // final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    // initSessionManager();
    if (kIsWeb) {
      // convertTumbNail();
    }
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  // Future<void> convertTumbNail() async {
  //   if (widget.thumbNailWeb != null) {
  //     await convertFileToBytes(widget.thumbNailWeb!)
  //         .then((value) => thumb = value);
  //     if (thumb != null && thumb!.isNotEmpty) {
  //       debugPrint("ThumbNail: Converted!!!!!!!!!!!!!!!!!!!!");
  //     }
  //   }
  // }

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setUserFields();
    setState(() {});
  }

  void setUserFields() async {
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    if (phoneNumber != '') {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(phoneNumber)
          .get()
          .then((user) {
        setState(() {
          currentPhoneNum = user[Dbkeys.phone];
          // userFullname = user[Dbkeys.nickname];
          phoneNumberVariants = phoneNumberVariantsList(
              countrycode: user[Dbkeys.countryCode],
              phonenumber: user[Dbkeys.phoneRaw]);
          // currentUserPhotourl = user[Dbkeys.photoUrl];
          isFetching = false;
        });
      });
      debugPrint("Number: Created!!!!!!!!!!!!!!!!!!!!");
    }
  }

  uploadFile(
      {required String file,
      required WidgetRef ref,
      String? caption,
      double? duration,
      String? thumbNail,
      required String type,
      required String filename}) async {
    final observer = ref.watch(observerProvider);
    final StatusProvider statusProvider = ref.watch(statusProviderProvider);
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    if (type == Dbkeys.statustypeVIDEO) {
      var infos = await videoInfo.getVideoInfo(file);
      setState(() {
        info = infos;
      });
    }
    String thumbnailUrl = "";

    if (widget.thumbNail != null) {
      final url1 = await uploadStoryThumbnail(
        uploadThumbnail: File(widget.thumbNail!),
        phoneNumber: phoneNumber!,
      );
      thumbnailUrl = url1;
    }

    statusProvider.setIsLoading(true);
    int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child('+00_STATUS_MEDIA/$phoneNumber/$filename');
    File? compressedImage;
    File? compressedVideo;
    File? fileToCompress;
    if (type == Dbkeys.statustypeIMAGE) {
      final targetPath = "${file.replaceAll(path.basename(file), "")}temp.jpg";

      File originalImageFile = File(file); // Convert XFile to File

      XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalImageFile.absolute.path,
        targetPath,
        quality: ImageQualityCompress,
        rotate: 0,
      );

      if (compressedXFile != null) {
        compressedImage = File(compressedXFile.path); // Convert XFile to File
      }
    } else if (type == Dbkeys.statustypeVIDEO) {
      fileToCompress = File(file);
      await compress.VideoCompress.setLogLevel(0);

      final compress.MediaInfo? info =
          await compress.VideoCompress.compressVideo(
        fileToCompress.path,
        quality: IsVideoQualityCompress == true
            ? compress.VideoQuality.MediumQuality
            : compress.VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      compressedVideo = File(info!.path!);
    }
    await reference
        .putFile(type == Dbkeys.statustypeIMAGE
            ? compressedImage!
            : type == Dbkeys.statustypeVIDEO
                ? compressedVideo!
                : fileToCompress!)
        .then((uploadTask) async {
      String url = await uploadTask.ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnstatus)
          .doc(phoneNumber)
          .set({
        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
          type == Dbkeys.statustypeVIDEO
              ? {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                  Dbkeys.statusItemDURATION: info!.duration,
                  'thumbNail': thumbnailUrl,
                }
              : {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                }
        ]),
        Dbkeys.statusPUBLISHERPHONE: phoneNumber,
        Dbkeys.statusPUBLISHERPHONEVARIANTS: phoneNumberVariants,
        Dbkeys.statusVIEWERLIST: [],
        Dbkeys.statusVIEWERLISTWITHTIME: [],
        Dbkeys.statusPUBLISHEDON: DateTime.now(),
        // uploadTimestamp,
        Dbkeys.statusEXPIRININGON: DateTime.now()
            .add(Duration(hours: observer.statusDeleteAfterInHours)),
        // .millisecondsSinceEpoch,
      }, SetOptions(merge: true)).then((value) {
        statusProvider.setIsLoading(false);
        EasyLoading.showSuccess(LocaleKeys.posted.tr());
        ref.invalidate(getStoryProvider);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }).onError((error, stackTrace) {
      statusProvider.setIsLoading(false);
      EasyLoading.showError(LocaleKeys.failedtopost.tr());
    });
  }

  uploadFileWeb(
      {required Uint8List file,
      required WidgetRef ref,
      String? caption,
      double? duration,
      Uint8List? thumbNail,
      required String type,
      required String filename}) async {
    final observer = ref.watch(observerProvider);
    final StatusProvider statusProvider = ref.watch(statusProviderProvider);
    final phoneNumber = ref.watch(currentUserStateProvider)!.phoneNumber;
    // if (type == Dbkeys.statustypeVIDEO) {
    //   var infos = await videoInfo.getVideoInfo(file.relativePath!);
    //   setState(() {
    //     info = infos;
    //   });
    // }
    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );
    final metadataVideo = SettableMetadata(
      contentType: 'video/mp4',
    );
    String thumbnailUrl = "";

    // final convertedFileThumb = await convertFileToBytes(widget.thumbNailWeb!);
    // final convertedFile = await convertFileToBytes(file);
    debugPrint("Uploading thumb!!!!!!!!!!!!!!!");
    if (widget.thumbNailWeb != null && widget.isPhoto == true) {
      final url1 = await uploadStoryThumbnailWeb(
        uploadThumbnail: widget.thumbNailWeb!,
        phoneNumber: phoneNumber!,
      );
      thumbnailUrl = url1;
    }
    debugPrint("Uploaded thumb!!!!!!!!!!!!!!!");

    statusProvider.setIsLoading(true);
    int uploadTimestamp = DateTime.now().millisecondsSinceEpoch;

    Reference reference = FirebaseStorage.instance
        .ref()
        .child('+00_STATUS_MEDIA/$phoneNumber/$filename');

    await reference
        .putData(type == Dbkeys.statustypeIMAGE ? file : file,
            type == Dbkeys.statustypeIMAGE ? metadata : metadataVideo)
        .then((uploadTask) async {
      String url = await uploadTask.ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection(DbPaths.collectionnstatus)
          .doc(phoneNumber)
          .set({
        Dbkeys.statusITEMSLIST: FieldValue.arrayUnion([
          type == Dbkeys.statustypeVIDEO
              ? {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                  Dbkeys.statusItemDURATION: 15000,
                  'thumbNail': thumbnailUrl.isEmpty
                      ? "https://cdn.dribbble.com/users/2479503/screenshots/6402160/placeholder.png"
                      : thumbnailUrl,
                }
              : {
                  Dbkeys.statusItemID: uploadTimestamp,
                  Dbkeys.statusItemURL: url,
                  Dbkeys.statusItemTYPE: type,
                  Dbkeys.statusItemCAPTION: caption,
                  'thumbNail': thumbnailUrl,
                }
        ]),
        Dbkeys.statusPUBLISHERPHONE: phoneNumber,
        Dbkeys.statusPUBLISHERPHONEVARIANTS: phoneNumberVariants,
        Dbkeys.statusVIEWERLIST: [],
        Dbkeys.statusVIEWERLISTWITHTIME: [],
        Dbkeys.statusPUBLISHEDON: DateTime.now(),
        // uploadTimestamp,
        Dbkeys.statusEXPIRININGON: DateTime.now()
            .add(Duration(hours: observer.statusDeleteAfterInHours)),
        // .millisecondsSinceEpoch,
      }, SetOptions(merge: true)).then((value) {
        statusProvider.setIsLoading(false);
        EasyLoading.showSuccess(LocaleKeys.posted.tr());
        // ref.invalidate(getStoryProvider);
        Navigator.pop(context);
        Navigator.pop(context);
      });
    }).onError((error, stackTrace) {
      statusProvider.setIsLoading(false);
      EasyLoading.showError(LocaleKeys.failedtopost.tr());
    });
  }

  @override
  Widget build(BuildContext context) {
    // final myProfile = ref.watch(userProfileFutureProvider);
    // final uploadPost = ref.read(addPostProvider);
    final prefs = ref.watch(sharedPreferences).value;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * .67,
      decoration: BoxDecoration(
        color: Teme.isDarktheme(prefs!)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Teme.isDarktheme(prefs)
                      ? AppConstants.backgroundColorDark
                      : AppConstants.backgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Center(
                  child: Text(
                    LocaleKeys.uploadStory.tr(),
                    style: const TextStyle(
                        fontSize: AppConstants.defaultNumericValue,
                        fontWeight: FontWeight.bold),
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: WebsafeSvg.asset(
                      closeIcon,
                      height: 30,
                     colorFilter: const ColorFilter.mode(
                                                    // Colors.blueGrey,
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                      fit: BoxFit.fitHeight,
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
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: !kIsWeb
                    ? Image(
                        height: 160,
                        width: 110,
                        fit: BoxFit.cover,
                        image: FileImage(File(widget.thumbNail!)),
                      )
                    : widget.isPhoto == true
                        ? SizedBox(
                            height: 160,
                            width: 110,
                            child: Image.memory(widget.thumbNailWeb!))
                        : const SizedBox(),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.pleaseEnterDescription.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(.1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      height: 130,
                      child: DetectableTextField(
                        controller: controller,
                        style: const TextStyle(
                          letterSpacing: 0.6,
                          fontSize: 13,
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
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => const LoaderDialog(),
                );
                if (widget.soundId != null) {
                } else {
                  if (!kIsWeb) {
                    uploadFile(
                        thumbNail: widget.isPhoto == false
                            ? widget.thumbNail
                            : widget.postVideo!,
                        file: widget.postVideo!,
                        filename:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        ref: ref,
                        type: widget.isPhoto == true
                            ? Dbkeys.statustypeIMAGE
                            : Dbkeys.statustypeVIDEO,
                        caption: postDes);
                  } else {
                    // Uint8List? videoBytes;
                    // if (widget.isPhoto == false) {
                    // final trimmedVideo = await trimVideo(widget.videoWeb!);

                    //   h.FileReader reader = h.FileReader();
                    //   reader.readAsArrayBuffer(trimmedVideo!);
                    //   reader.onLoadEnd.listen((event) {
                    //     videoBytes = reader.result as Uint8List;
                    //     // Use the Uint8List data
                    //   });
                    // }
                    // debugPrint("Uploading ${widget.videoWeb}");
                    uploadFileWeb(
                        thumbNail: widget.thumbNailWeb,
                        file: widget.isPhoto == true
                            ? widget.photoWeb!
                            : widget.videoWeb!,
                        filename: widget.isPhoto == true
                            ? "image_${DateTime.now().millisecondsSinceEpoch.toString()}.jpeg"
                            : "video_${DateTime.now().millisecondsSinceEpoch.toString()}.mp4",
                        ref: ref,
                        type: widget.isPhoto == true
                            ? Dbkeys.statustypeIMAGE
                            : Dbkeys.statustypeVIDEO,
                        caption: postDes);
                  }
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.all(
                      Radius.circular(AppConstants.defaultNumericValue * 2)),
                ),
                width: 150,
                height: 40,
                child: Center(
                  child: Text(
                    LocaleKeys.publish.tr().toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            LocaleKeys.byContinue.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
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
      ),
    );
  }
}
