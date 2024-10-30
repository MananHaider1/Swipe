// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:lamatdating/generated/locale_keys.g.dart';

// import 'package:lamatdating/constants.dart';
// import 'package:lamatdating/helpers/media_picker_helper.dart';
// import 'package:lamatdating/models/user_profile_model.dart';
// import 'package:lamatdating/providers/user_profile_provider.dart';
// import 'package:lamatdating/views/custom/custom_app_bar.dart';
// import 'package:lamatdating/views/custom/custom_button.dart';
// import 'package:lamatdating/views/custom/custom_headline.dart';
// import 'package:restart_app/restart_app.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class PaidContentPage extends ConsumerStatefulWidget {
//   final UserProfileModel userProfileModel;
//   final SharedPreferences prefs;
//   const PaidContentPage(
//       {Key? key, required this.userProfileModel, required this.prefs})
//       : super(key: key);

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _PaidContentPageState();
// }

// class _PaidContentPageState extends ConsumerState<PaidContentPage> {
//   final _formKey = GlobalKey<FormState>();

//   final List<String> _medias = [
//     for (var i = 0; i < AppConfig.maxNumOfMedia; i++) ""
//   ];
//   final List<String> imagesUrls = [];

//   @override
//   void initState() {
//     for (var i = 0; i < _medias.length; i++) {
//       if (widget.userProfileModel.subsFiles != null &&
//           widget.userProfileModel.subsFiles!.length > i) {
//         if (widget.userProfileModel.subsFiles != null) {
//           _medias[i] = widget.userProfileModel.subsFiles![i];
//         }
//       }
//     }

//     super.initState();
//   }

//   void _onSave() async {
//     if (_formKey.currentState!.validate()) {
//       for (var i = 0; i < _medias.length; i++) {
//         if (_medias[i] != "" && Uri.parse(_medias[i]).hasScheme) {
//           imagesUrls.add(_medias[i]);
//         }
//       }
//       final newUserProfileModel = widget.userProfileModel.copyWith(
//         subsFiles: imagesUrls,
//       );
//       EasyLoading.show(status: LocaleKeys.saving.tr());

//       await ref
//           .read(userProfileNotifier)
//           .updateUserProfile(newUserProfileModel)
//           .then((value) {
//         EasyLoading.dismiss();
//         ref.invalidate(userProfileFutureProvider);
//         Restart.restartApp();
//       });
//     }
//   }

//   Future<String?> _uploadSubMediaFiles(
//       PickedFileModel path, String phoneNumber) async {
//     final storageRef = FirebaseStorage.instance.ref();

//     final imageRef = storageRef.child(
//         "user_media_files/$phoneNumber/${DateTime.now().toUtc().millisecondsSinceEpoch}${path.fileName}");
//     final uploadTask = imageRef.putData(path.pickedFile!);

//     await uploadTask.whenComplete(() async {
//       final imageUrl = await imageRef.getDownloadURL();
//       debugPrint("Media URL Uploaded Subs: $imageUrl");
//       return imageUrl;
//     });
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).requestFocus(FocusNode());
//       },
//       child: Scaffold(
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Padding(
//                     padding: EdgeInsets.only(
//                         left: AppConstants.defaultNumericValue,
//                         top: MediaQuery.of(context).padding.top),
//                     child: const CustomAppBar(
//                       // leading: CustomIconButton(
//                       //     icon: leftArrowSvg,
//                       //     onPressed: _onSave,
//                       //     padding: const EdgeInsets.all(
//                       //         AppConstants.defaultNumericValue / 1.8)),
//                       title: Center(
//                           child: CustomHeadLine(
//                         text: "Subscribers Only",
//                       )),
//                       trailing:
//                           SizedBox(width: AppConstants.defaultNumericValue * 2),
//                     )),
//                 const SizedBox(height: AppConstants.defaultNumericValue),
//                 Text(
//                   "Subscriber Only",
//                   style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                       fontWeight: FontWeight.bold,
//                       fontSize: AppConstants.defaultNumericValue * 1.5),
//                 ),
//                 const SizedBox(height: AppConstants.defaultNumericValue / 2),
//                 Wrap(
//                   spacing: AppConstants.defaultNumericValue / 2.1,
//                   runSpacing: AppConstants.defaultNumericValue / 2.1,
//                   alignment: WrapAlignment.center,
//                   children: _medias
//                       .map(
//                         (image) => GestureDetector(
//                           onTap: () async {
//                             void selecImage() async {
//                               final imagePath = await pickMedia();
//                               if (imagePath != null) {
//                                 setState(() {
//                                   _medias[_medias.indexOf(image)] = imagePath;
//                                 });
//                               }
//                             }

//                             if (image != "") {
//                               showModalBottomSheet(
//                                   context: context,
//                                   builder: (context) {
//                                     return Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         ListTile(
//                                           title: Text(
//                                               LocaleKeys.selectNewImage.tr()),
//                                           leading: const Icon(Icons.image),
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                             selecImage();
//                                           },
//                                         ),
//                                         ListTile(
//                                           title: Text(LocaleKeys
//                                               .removeCurrentImage
//                                               .tr()),
//                                           leading: const Icon(Icons.delete),
//                                           onTap: () {
//                                             setState(() {
//                                               _medias[_medias.indexOf(image)] =
//                                                   "";
//                                             });
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   });
//                             } else {
//                               selecImage();
//                             }
//                           },
//                           child: SizedBox(
//                             width: (MediaQuery.of(context).size.width -
//                                     AppConstants.defaultNumericValue * 3) /
//                                 3,
//                             height: (MediaQuery.of(context).size.width -
//                                     AppConstants.defaultNumericValue * 3) /
//                                 3,
//                             child: image.isEmpty
//                                 ? Container(
//                                     decoration: const BoxDecoration(
//                                         color: Colors.black12),
//                                     child: const Center(
//                                         child: Icon(CupertinoIcons.photo)),
//                                   )
//                                 : Uri.parse(image).isAbsolute
//                                     ? CachedNetworkImage(
//                                         imageUrl: image,
//                                         placeholder: (context, url) =>
//                                             const Center(
//                                                 child: CircularProgressIndicator
//                                                     .adaptive()),
//                                         errorWidget: (context, url, error) =>
//                                             const Center(
//                                                 child:
//                                                     Icon(CupertinoIcons.photo)),
//                                         fit: BoxFit.cover,
//                                       )
//                                     : Image.file(
//                                         File(image),
//                                         fit: BoxFit.cover,
//                                       ),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 Wrap(
//                   spacing: AppConstants.defaultNumericValue / 2.1,
//                   runSpacing: AppConstants.defaultNumericValue / 2.1,
//                   alignment: WrapAlignment.center,
//                   children: _medias
//                       .map(
//                         (image) => GestureDetector(
//                           onTap: () async {
//                             void selecImage() async {
//                               final imagePath = await pickMediaAsData();
//                               if (imagePath != null) {
//                                 EasyLoading.show(
//                                     status: LocaleKeys.uploading.tr());
//                                 await _uploadSubMediaFiles(imagePath,
//                                         widget.userProfileModel.phoneNumber)
//                                     .then((value) {
//                                   EasyLoading.dismiss();
//                                   if (value != null) {
//                                     imagesUrls.add(value);
//                                     setState(() {
//                                       _medias[_medias.indexOf(image)] = value;
//                                     });

//                                     debugPrint("Media URL Uploaded Subs");
//                                   }
//                                 });
//                               }
//                             }

//                             if (image != "") {
//                               showModalBottomSheet(
//                                   context: context,
//                                   builder: (context) {
//                                     return Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         ListTile(
//                                           title: Text(
//                                               LocaleKeys.selectNewImage.tr()),
//                                           leading: const Icon(Icons.image),
//                                           onTap: () {
//                                             Navigator.pop(context);
//                                             selecImage();
//                                           },
//                                         ),
//                                         ListTile(
//                                           title: Text(LocaleKeys
//                                               .removeCurrentImage
//                                               .tr()),
//                                           leading: const Icon(Icons.delete),
//                                           onTap: () {
//                                             setState(() {
//                                               _medias[_medias.indexOf(image)] =
//                                                   "";
//                                             });
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   });
//                             } else {
//                               selecImage();
//                             }
//                           },
//                           child: SizedBox(
//                               width: (MediaQuery.of(context).size.width -
//                                       AppConstants.defaultNumericValue * 3) /
//                                   3,
//                               height: (MediaQuery.of(context).size.width -
//                                       AppConstants.defaultNumericValue * 3) /
//                                   3,
//                               child: image.isEmpty
//                                   ? Container(
//                                       decoration: const BoxDecoration(
//                                           color: Colors.black12),
//                                       child: const Center(
//                                           child: Icon(CupertinoIcons.photo)),
//                                     )
//                                   : CachedNetworkImage(
//                                       imageUrl: image,
//                                       placeholder: (context, url) =>
//                                           const Center(
//                                               child: CircularProgressIndicator
//                                                   .adaptive()),
//                                       errorWidget: (context, url, error) =>
//                                           const Center(
//                                               child:
//                                                   Icon(CupertinoIcons.photo)),
//                                       fit: BoxFit.cover,
//                                     )),
//                         ),
//                       )
//                       .toList(),
//                 ),
//                 const SizedBox(height: AppConstants.defaultNumericValue / 2),
//                 Text(
//                   "${LocaleKeys.youcanaddupto.tr()} ${AppConfig.maxNumOfMedia} ${LocaleKeys.images.tr()}",
//                   textAlign: TextAlign.end,
//                   style: Theme.of(context).textTheme.bodySmall,
//                 ),
//                 const SizedBox(height: AppConstants.defaultNumericValue),
//                 CustomButton(
//                   onPressed: _onSave,
//                   text: LocaleKeys.save.tr(),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
