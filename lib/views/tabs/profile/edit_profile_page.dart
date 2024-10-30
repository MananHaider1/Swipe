import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/user_profile_provider.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final UserProfileModel userProfileModel;
  const EditProfilePage({super.key, required this.userProfileModel});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _chatNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _aboutController = TextEditingController();
  String? _profilePicture;
  final List<String> _interests = [];
  final List<String> _medias = [
    for (var i = 0; i < AppConfig.maxNumOfMedia; i++) ""
  ];

  @override
  void initState() {
    _fullNameController.text = widget.userProfileModel.fullName;
    _emailController.text = widget.userProfileModel.email ?? "";
    _phoneNumberController.text = widget.userProfileModel.phoneNumber;
    _aboutController.text = widget.userProfileModel.about ?? "";
    _profilePicture = widget.userProfileModel.profilePicture;
    _userNameController.text = widget.userProfileModel.userName;
    _facebookController.text = widget.userProfileModel.fbUrl ?? "";
    _instagramController.text = widget.userProfileModel.instaUrl ?? "";
    _youtubeController.text = widget.userProfileModel.youtubeUrl ?? "";
    _chatNameController.text = widget.userProfileModel.nickname;
    _interests.addAll(widget.userProfileModel.interests);
    for (var i = 0; i < _medias.length; i++) {
      if (widget.userProfileModel.mediaFiles.length > i) {
        _medias[i] = widget.userProfileModel.mediaFiles[i];
      }
    }

    super.initState();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final newUserProfileModel = widget.userProfileModel.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        about: _aboutController.text.trim(),
        profilePicture: _profilePicture,
        interests: _interests,
        mediaFiles: _medias,
        fbUrl: _facebookController.text.trim(),
        instaUrl: _instagramController.text.trim(),
        youtubeUrl: _youtubeController.text.trim(),
        nickname: _chatNameController.text.trim(),
        userName: _userNameController.text.trim(),
      );
      EasyLoading.show(status: LocaleKeys.saving.tr());

      await ref
          .read(userProfileNotifier)
          .updateUserProfile(newUserProfileModel)
          .then((value) {
        EasyLoading.dismiss();
        !Responsive.isDesktop(context)
            ? Navigator.pop(context)
            : ref.invalidate(arrangementProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefss = ref.watch(sharedPreferences).value;
    double width = MediaQuery.of(context).size.width;
    final myUserProvider = ref.read(authProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                    padding: EdgeInsets.only(
                        left: AppConstants.defaultNumericValue,
                        top: MediaQuery.of(context).padding.top),
                    child: CustomAppBar(
                      leading: CustomIconButton(
                          icon: leftArrowSvg,
                          onPressed: () {
                            !Responsive.isDesktop(context)
                                ? Navigator.pop(context)
                                : ref.invalidate(arrangementProvider);
                          },
                          padding: const EdgeInsets.all(
                              AppConstants.defaultNumericValue / 1.8)),
                      title: Center(
                          child: CustomHeadLine(
                        text: LocaleKeys.editProfile.tr(),
                      )),
                      trailing: const SizedBox(
                          width: AppConstants.defaultNumericValue * 2),
                    )),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        AppConstants.defaultNumericValue * 10),
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue * 10),
                      child: GestureDetector(
                        onTap: () async {
                          void setProfilePicture() async {
                            final imagePath = await pickMedia();
                            if (imagePath != null) {
                              setState(() {
                                _profilePicture = imagePath;
                              });
                            }
                          }

                          if (_profilePicture != null &&
                              _profilePicture != "") {
                            showModalBottomSheet(
                                backgroundColor: Teme.isDarktheme(prefss!)
                                    ? AppConstants.backgroundColorDark
                                    : AppConstants.backgroundColor,
                                isScrollControlled: true,
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(25.0)),
                                ),
                                builder: (context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height:
                                            AppConstants.defaultNumericValue,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: AppConstants
                                                  .defaultNumericValue,
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: WebsafeSvg.asset(
                                                  closeIcon,
                                                  colorFilter: const ColorFilter.mode(
                                                //  AppConstants.primaryColor,
                                                AppConstants.secondaryColor,
                                                // Colors.white,
                                                // Colors.grey,
                                                //  Colors.black,
                                                  BlendMode.srcIn,),
                                                  height: 32,
                                                  width: 32,
                                                  fit: BoxFit.contain,
                                                )),
                                            SizedBox(
                                              width: width * .3,
                                            ),
                                            Container(
                                                width: AppConstants
                                                        .defaultNumericValue *
                                                    3,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  color: AppConstants.hintColor,
                                                )),
                                          ]),
                                      const SizedBox(
                                        width: AppConstants.defaultNumericValue,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            LocaleKeys.change,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                          height:
                                              AppConstants.defaultNumericValue /
                                                  2),
                                      ListTile(
                                        title: Text(LocaleKeys
                                            .setNewProfilePicture
                                            .tr()),
                                        leading: const Icon(Icons.image),
                                        onTap: () {
                                          Navigator.pop(context);
                                          setProfilePicture();
                                        },
                                      ),
                                      ListTile(
                                        title: Text(LocaleKeys
                                            .removeProfilePicture
                                            .tr()),
                                        leading: const Icon(Icons.delete),
                                        onTap: () {
                                          setState(() {
                                            _profilePicture = "";
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            setProfilePicture();
                          }
                        },
                        child: SizedBox(
                          width: AppConstants.defaultNumericValue * 7,
                          height: AppConstants.defaultNumericValue * 7,
                          child: _profilePicture == null ||
                                  _profilePicture!.isEmpty
                              ? CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  child: const Icon(
                                    CupertinoIcons.person_circle_fill,
                                    color: AppConstants.primaryColor,
                                    size: AppConstants.defaultNumericValue * 7,
                                  ),
                                )
                              : Uri.parse(_profilePicture!).isAbsolute
                                  ? CachedNetworkImage(
                                      imageUrl: _profilePicture!,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator
                                              .adaptive(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_profilePicture!),
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (AppConfig.canChangeNickName)
                  const SizedBox(height: AppConstants.defaultNumericValue),
                if (AppConfig.canChangeNickName)
                  TextFormField(
                    controller: _chatNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.1),
                      hintText: LocaleKeys.chatNickname.tr(),
                      border: OutlineInputBorder(
                        // Set outline border
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.pleaseenteryournickname.tr();
                      }
                      return null;
                    },
                  ),
                if (AppConfig.canChangeName)
                  const SizedBox(height: AppConstants.defaultNumericValue),
                if (AppConfig.canChangeName)
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppConstants.primaryColor.withOpacity(.1),
                      hintText: "John Doe",
                      border: OutlineInputBorder(
                        // Set outline border
                        borderRadius: BorderRadius.circular(
                            AppConstants.defaultNumericValue),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return LocaleKeys.pleaseenteryourfullname.tr();
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _userNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.primaryColor.withOpacity(.1),
                    hintText: LocaleKeys.username.tr(),
                    border: OutlineInputBorder(
                      // Set outline border
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return LocaleKeys.pleaseenteryourusername.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue,
                        vertical: AppConstants.defaultNumericValue * 1.4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                    ),
                    child: Text(_phoneNumberController.text,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: AppConstants.defaultNumericValue * 1.5,
                            ))),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue,
                        vertical: AppConstants.defaultNumericValue * 1.4),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                    ),
                    child: _emailController.text == ""
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Icon(Icons.g_mobiledata_rounded,
                                    color: Colors.blue),
                                Text(_emailController.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              AppConstants.defaultNumericValue *
                                                  1.5,
                                        )),
                                TextButton(
                                  onPressed: () async {
                                    final email =
                                        await myUserProvider.linkGoogle(ref);
                                    if (email != null) {
                                      _emailController.text = email;
                                    }
                                  },
                                  child: Text(
                                    LocaleKeys.link.tr(),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                )
                              ])
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Icon(Icons.g_mobiledata_rounded,
                                    color: Colors.blue),
                                Text(_emailController.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              AppConstants.defaultNumericValue *
                                                  1.5,
                                        )),
                                TextButton(
                                  onPressed: () async {
                                    final isUnlinked = await myUserProvider
                                        .unlinkGoogleSignIn(ref);
                                    if (isUnlinked) {
                                      _emailController.text = "";
                                    }
                                  },
                                  child: Text(
                                    LocaleKeys.unlink.tr(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                )
                              ])),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _aboutController,
                  maxLines: null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.primaryColor.withOpacity(.1),
                    hintText: LocaleKeys.bio,
                    border: OutlineInputBorder(
                      // Set outline border
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _instagramController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.primaryColor.withOpacity(.1),
                    hintText: LocaleKeys.instagramUsername.tr(),
                    border: OutlineInputBorder(
                      // Set outline border
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    // if (value!.isEmpty) {
                    //   return LocaleKeys.pleaseenteryourinstagramusername.tr();
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _facebookController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.primaryColor.withOpacity(.1),
                    hintText: LocaleKeys.facebookUsername.tr(),
                    border: OutlineInputBorder(
                      // Set outline border
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    // if (value!.isEmpty) {
                    //   return LocaleKeys.pleaseenteryourfacebookusername.tr();
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                TextFormField(
                  controller: _youtubeController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.primaryColor.withOpacity(.1),
                    hintText: LocaleKeys.youtubeUsername.tr(),
                    border: OutlineInputBorder(
                      // Set outline border
                      borderRadius: BorderRadius.circular(
                          AppConstants.defaultNumericValue),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    // if (value!.isEmpty) {
                    //   return LocaleKeys.pleaseenteryouryoutubeusername.tr();
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Text(
                  LocaleKeys.myInterests.tr(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.defaultNumericValue * 1.5),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Wrap(
                  spacing: AppConstants.defaultNumericValue / 2,
                  children: AppConfig.interests
                      .map(
                        (interest) => ChoiceChip(
                          label: Text(interest[0].toUpperCase() +
                              interest.substring(1)),
                          selected: _interests.contains(interest),
                          shape: _interests.contains(interest)
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.defaultNumericValue * 2),
                                  side: const BorderSide(
                                      color: AppConstants.primaryColor,
                                      width: 1),
                                )
                              : null,
                          selectedColor:
                              AppConstants.primaryColor.withOpacity(0.3),
                          onSelected: (notSelected) {
                            setState(() {
                              if (notSelected) {
                                if (_interests.length >=
                                    AppConfig.maxNumOfInterests) {
                                  EasyLoading.showToast(
                                      "${LocaleKeys.youcanonlyselect.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                                      toastPosition:
                                          EasyLoadingToastPosition.bottom);
                                } else {
                                  _interests.add(interest);
                                }
                              } else {
                                _interests.remove(interest);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Text(
                  "${LocaleKeys.youcanselectupto.tr()} ${AppConfig.maxNumOfInterests} ${LocaleKeys.interests.tr()}",
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                Text(
                  LocaleKeys.myPhotos.tr(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.defaultNumericValue * 1.5),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Wrap(
                  spacing: AppConstants.defaultNumericValue / 2.1,
                  runSpacing: AppConstants.defaultNumericValue / 2.1,
                  alignment: WrapAlignment.center,
                  children: _medias
                      .map(
                        (image) => GestureDetector(
                          onTap: () async {
                            void selecImage() async {
                              final imagePath = await pickMedia();
                              if (imagePath != null) {
                                setState(() {
                                  _medias[_medias.indexOf(image)] = imagePath;
                                });
                              }
                            }

                            if (image != "") {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text(
                                              LocaleKeys.selectNewImage.tr()),
                                          leading: const Icon(Icons.image),
                                          onTap: () {
                                            Navigator.pop(context);
                                            selecImage();
                                          },
                                        ),
                                        ListTile(
                                          title: Text(LocaleKeys
                                              .removeCurrentImage
                                              .tr()),
                                          leading: const Icon(Icons.delete),
                                          onTap: () {
                                            setState(() {
                                              _medias[_medias.indexOf(image)] =
                                                  "";
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else {
                              selecImage();
                            }
                          },
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width -
                                    AppConstants.defaultNumericValue * 3) /
                                3,
                            height: (MediaQuery.of(context).size.width -
                                    AppConstants.defaultNumericValue * 3) /
                                3,
                            child: image.isEmpty
                                ? Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: const Center(
                                        child: Icon(CupertinoIcons.photo)),
                                  )
                                : Uri.parse(image).isAbsolute
                                    ? CachedNetworkImage(
                                        imageUrl: image,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child: CircularProgressIndicator
                                                    .adaptive()),
                                        errorWidget: (context, url, error) =>
                                            const Center(
                                                child:
                                                    Icon(CupertinoIcons.photo)),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(image),
                                        fit: BoxFit.cover,
                                      ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                Text(
                  "${LocaleKeys.youcanaddupto.tr()} ${AppConfig.maxNumOfMedia} ${LocaleKeys.images.tr()}",
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                CustomButton(
                  onPressed: _onSave,
                  text: LocaleKeys.save.tr(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
