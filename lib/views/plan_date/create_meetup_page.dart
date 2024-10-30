// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/models/meeting_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/home_arrangement_provider.dart';
import 'package:lamatdating/providers/meeting_provider.dart';
import 'package:lamatdating/providers/shared_pref_provider.dart';
import 'package:lamatdating/providers/wallets_provider.dart';
import 'package:lamatdating/responsive.dart';
import 'package:lamatdating/utils/theme_management.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';

import 'package:lamatdating/views/wallet/dialog_coins_plan.dart';

class CreateMeetupPage extends ConsumerStatefulWidget {
  final UserProfileModel user;
  const CreateMeetupPage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<CreateMeetupPage> createState() => _CreateMeetupPageState();
}

class _CreateMeetupPageState extends ConsumerState<CreateMeetupPage> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _meetingVenueController = TextEditingController();
  final List<File> _selectedImages = [];
  bool _bottomButtonVisible = true;
  bool _enablePostButton = false;
  double _postFontSize = 28;
  TimeOfDay _selectedTime1 = TimeOfDay.now();
  TimeOfDay _selectedTime2 = TimeOfDay.now();
  final ImagePicker _picker = ImagePicker();
  DateTime _selectedDate = DateTime.now();
  final List<int> selectedBudget = [];
  double? walletBalance;

  String formatDate(DateTime date) {
    return DateFormat('EEEE, dd LLL yyyy').format(date);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkBalance(ref).then((value) {
        walletBalance = value;
      });
    });
  }

  Future<void> _selectTime(BuildContext context, int tileNumber) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (tileNumber == 1) {
          _selectedTime1 = picked;
        } else if (tileNumber == 2) {
          _selectedTime2 = picked;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void onSelectBudget(bool notSelected, int budget) {
    setState(() {
      if (notSelected) {
        if (selectedBudget.isNotEmpty) {
          EasyLoading.showToast("${LocaleKeys.youcanonlyselect} 1",
              toastPosition: EasyLoadingToastPosition.bottom);
        } else {
          selectedBudget.add(budget);
        }
      } else {
        selectedBudget.remove(budget);
      }
    });
  }

  void _onPressedGallery() async {
    await _picker.pickMultiImage(imageQuality: 30).then((value) async {
      for (var item in value) {
        setState(() {
          _selectedImages.add(File(item.path));
        });
      }
    });
  }

  void _onPressedCamera() async {
    await _picker
        .pickImage(source: ImageSource.camera, imageQuality: 30)
        .then((value) async {
      if (value != null) {
        setState(() {
          _selectedImages.add(File(value.path));
        });
      }
    });
  }

  void _onPost() async {
    // final holdFunds = ref.watch(minusBalanceProvider as ProviderListenable);
    EasyLoading.show(status: LocaleKeys.sending.tr());

    final currentTime = DateTime.now();
    final currentUserId = ref.watch(currentUserStateProvider)!.phoneNumber;
    final otherUserId = widget.user.phoneNumber;
    final meetingId =
        currentUserId! + currentTime.millisecondsSinceEpoch.toString();
    final List<String> imageUrls = [];
    final budget = selectedBudget.isEmpty ? 0 : selectedBudget.first;

    if (_selectedImages.isNotEmpty) {
      final urls = await uploadMeetingImages(
          files: _selectedImages, phoneNumber: currentUserId);
      imageUrls.addAll(urls);
    }

    final MeetingModel meetingModel = MeetingModel(
      id: meetingId,
      status: 'pending',
      host: currentUserId,
      invitee: otherUserId,
      description: _postController.text,
      budget: budget,
      createdAt: currentTime,
      images: imageUrls,
      meetingStartTime: _selectedTime1.format(context),
      meetingVenue: _meetingVenueController.text,
      meetingEndTime: _selectedTime2.format(context),
      meetingDate: _selectedDate,
    );

    if (_postController.text.isEmpty) {
      EasyLoading.showError(LocaleKeys.msgCantBeEmpty.tr());
      return;
    } else if (_meetingVenueController.text.isEmpty) {
      EasyLoading.showError(LocaleKeys.venueEmpty.tr());
      return;
    } else if (_selectedDate == DateTime.now()) {
      EasyLoading.showError(LocaleKeys.dateEmpty.tr());
      return;
    } else if (_selectedTime1 == TimeOfDay.now()) {
      EasyLoading.showError(LocaleKeys.startEmpty.tr());
      return;
    } else if (_selectedTime2 == TimeOfDay.now()) {
      EasyLoading.showError(LocaleKeys.endEmpty.tr());
      return;
    } else if (budget == 0) {
      EasyLoading.showError(LocaleKeys.sponsorEmpty.tr());
      return;
    } else if (walletBalance == null) {
      EasyLoading.showError(LocaleKeys.connecting.tr());
      checkBalance(ref).then((value) {
        walletBalance = value;
      });
    } else if (walletBalance! < budget.toDouble()) {
      EasyLoading.showError(LocaleKeys.insufficientBalance.tr());
      showModalBottomSheet(
        context: context,
        builder: (context) => const DialogCoinsPlan(),
        backgroundColor: Colors.transparent,
      );
    } else {
      minusBalanceProvider(ref, budget.toDouble()).then((value) async => {
            if (value)
              {
                await addMeeting(meetingModel).then((result) {
                  if (result) {
                    // addBalanceProvider(_budget.toDouble());
                    EasyLoading.showSuccess(LocaleKeys.sentSuccessfully);
                    ref.invalidate(getMeetingsProvider);
                    // Navigator.pop(context);
                  } else {
                    // ref.read(addBalanceProvider(_budget.toDouble()));
                    EasyLoading.showError(LocaleKeys.failedtopost.tr());
                  }
                })
              }
            else
              {EasyLoading.showError(LocaleKeys.failedtopost.tr())}
          });
      !Responsive.isDesktop(context)
          ? Navigator.pop(context)
          : ref.invalidate(arrangementProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferences).value;
    _enablePostButton =
        _postController.text.isNotEmpty || _selectedImages.isNotEmpty;
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String formattedDate = formatDate(_selectedDate);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Teme.isDarktheme(prefs!)
            ? AppConstants.backgroundColorDark
            : AppConstants.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _createNewPostTopBar(context, _onPost),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                CretePostNameSection(
                  user: widget.user,
                ),
                _createNewPostTextField(),
                const SizedBox(
                  height: AppConstants.defaultNumericValue / 2,
                ),
                // const SizedBox(
                //   height: AppConstants.defaultNumericValue,
                // ),
                // Row(
                //   children: [
                //     const SizedBox(
                //       width: AppConstants.defaultNumericValue,
                //     ),
                //     Text(
                //       "Sponsor Amount",
                //       style: Theme.of(context)
                //           .textTheme
                //           .headlineSmall!
                //           .copyWith(fontWeight: FontWeight.bold),
                //     ),
                //   ],
                // ),
                const SizedBox(height: AppConstants.defaultNumericValue / 2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: AppConstants.defaultNumericValue),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: AppConfig.budgets
                            .map((amount) => Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ChoiceChip(
                                    avatar: const CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Colors.transparent,
                                        foregroundImage:
                                            AssetImage(icPurpleHeart)),
                                    label: Text(amount.toString()[0] +
                                        amount.toString().substring(1)),
                                    selected: selectedBudget.contains(amount),
                                    shape: selectedBudget.contains(amount)
                                        ? RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                AppConstants
                                                        .defaultNumericValue *
                                                    2),
                                            side: const BorderSide(
                                                color:
                                                    AppConstants.primaryColor,
                                                width: 1),
                                          )
                                        : null,
                                    selectedColor: AppConstants.primaryColor
                                        .withOpacity(0.3),
                                    onSelected: (notSelected) {
                                      onSelectBudget(notSelected, amount);
                                    },
                                  ),
                                ))
                            .toList(),
                      )),
                ),
                const SizedBox(
                  height: AppConstants.defaultNumericValue / 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultNumericValue),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectedImages.length < 2
                              ? _onPressedGallery
                              : () {
                                  EasyLoading.showError(
                                      LocaleKeys.maxnooffiles.tr());
                                },
                          child: Container(
                            // width: width * .4,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color:
                                    AppConstants.secondaryColor.withOpacity(.1),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.defaultNumericValue)),
                            child: const Icon(
                              CupertinoIcons.photo_fill_on_rectangle_fill,
                              color: AppConstants.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onPressedCamera,
                          child: Container(
                            // width: width * .4,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                                color:
                                    AppConstants.primaryColor.withOpacity(.1),
                                borderRadius: BorderRadius.circular(
                                    AppConstants.defaultNumericValue)),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: AppConstants.defaultNumericValue,
                    ),
                    _selectedImages.isNotEmpty
                        ? Text(
                            LocaleKeys.photos.tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          )
                        : const SizedBox()
                  ],
                ),
                if (_selectedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue),
                    child: SizedBox(
                        height: height * .25,
                        child: _createNewPostImageSection(context)),
                  ),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                ListTile(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        CupertinoIcons.calendar_today,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        LocaleKeys.date.tr(),
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: AppConstants.textColorLight),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.defaultNumericValue * 1.3),
                  ),
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultNumericValue),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppConstants.defaultNumericValue / 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.defaultNumericValue),
                              color: AppConstants.primaryColor.withOpacity(0.1),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  const Icon(
                                    CupertinoIcons.clock,
                                    color: AppConstants.primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    LocaleKeys.start.tr(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: AppConstants.textColorLight),
                                  ),
                                ],
                              ),
                              subtitle: Text(_selectedTime1.format(context),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          AppConstants.defaultNumericValue *
                                              2)),
                              onTap: () => _selectTime(context, 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical:
                                      AppConstants.defaultNumericValue / 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.defaultNumericValue),
                                color: AppConstants.secondaryColor
                                    .withOpacity(0.1),
                              ),
                              child: ListTile(
                                title: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(
                                      CupertinoIcons.clock_fill,
                                      color: AppConstants.secondaryColor,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      LocaleKeys.end.tr(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: AppConstants.textColorLight),
                                    ),
                                  ],
                                ),
                                subtitle: Text(_selectedTime2.format(context),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            AppConstants.defaultNumericValue *
                                                2)),
                                onTap: () => _selectTime(context, 2),
                              )),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: AppConstants.defaultNumericValue,
                    ),
                    Text(
                      LocaleKeys.venue.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultNumericValue),
                _createNewPostVenueField(),
                const SizedBox(
                  height: AppConstants.defaultNumericValue,
                ),
                SizedBox(
                  height: height * .1,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createNewPostImageSection(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust the number of columns as needed
        crossAxisSpacing: 4.0, // Spacing between grid items
        mainAxisSpacing: 4.0, // Spacing between rows
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) {
        final image = _selectedImages[index];
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: CachedNetworkImage(
                imageUrl: image.path,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(CupertinoIcons.photo)),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
                icon: const Icon(Icons.cancel),
              ),
            )
          ],
        );
      },
    );
  }

  Container _createNewPostTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultNumericValue),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: _postFontSize, end: _postFontSize),
          builder: (context, double size, child) {
            return TextField(
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              autofocus: false,
              // minLines: 3,
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
                hintText: 'Type your message...',
                // focusedBorder: InputBorder.none,
                // enabledBorder: InputBorder.none,
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                // errorBorder: InputBorder.none,
                // focusedErrorBorder: InputBorder.none,
                // disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                filled: true,
                fillColor: AppConstants.primaryColor.withOpacity(.1),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _createNewPostVenueField() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultNumericValue),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: _postFontSize, end: _postFontSize),
          builder: (context, double size, child) {
            return TextField(
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardType: TextInputType.multiline,
              maxLines: 2,
              // minLines: 3,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(decoration: TextDecoration.none, fontSize: size),
              controller: _meetingVenueController,
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
                hintText: LocaleKeys.enterVenue.tr(),
                // focusedBorder: InputBorder.none,
                // enabledBorder: InputBorder.none,
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 0, minHeight: 0),
                // errorBorder: InputBorder.none,
                // focusedErrorBorder: InputBorder.none,
                // disabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(18.0),
                ),
                filled: true,
                fillColor: AppConstants.primaryColor.withOpacity(.1),
              ),
            );
          },
        ),
      ),
    );
  }

  Column _createNewPostTopBar(BuildContext context, VoidCallback onPost) {
    return Column(children: [
      const SizedBox(height: AppConstants.defaultNumericValue),
      Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultNumericValue),
        child: CustomAppBar(
          leading: Row(
            children: [
              CustomIconButton(
                  padding: const EdgeInsets.all(
                      AppConstants.defaultNumericValue / 1.8),
                  onPressed: !Responsive.isDesktop(context)
                      ? () {
                          _bottomButtonVisible = true;
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.pop(context);
                        }
                      : () {
                          ref.invalidate(arrangementProviderExtend);
                        },
                  color: AppConstants.primaryColor,
                  icon: leftArrowSvg),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          title: Center(
            child: CustomHeadLine(
              text: LocaleKeys.meetup.tr(),
            ),
          ),
          trailing: CustomIconButton(
              backgroundColor: _enablePostButton
                  ? AppConstants.primaryColor.withOpacity(.1)
                  : Colors.black12,
              padding:
                  const EdgeInsets.all(AppConstants.defaultNumericValue / 1.8),
              onPressed: _enablePostButton
                  ? () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      onPost();
                    }
                  : null,
              color:
                  _enablePostButton ? AppConstants.primaryColor : Colors.grey,
              icon: paperplaneIcon),
        ),
      ),
    ]);
  }
}

class CreateNewPostBottomButtons extends StatelessWidget {
  final VoidCallback onPressedOpenGallery;
  final VoidCallback onPressedOpenCamera;
  const CreateNewPostBottomButtons({
    super.key,
    required this.onPressedOpenGallery,
    required this.onPressedOpenCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(LocaleKeys.gallery.tr()),
            onTap: onPressedOpenGallery,
            leading: const Icon(Icons.photo_library, color: Colors.red),
          ),
          const Divider(),
          ListTile(
            title: Text(LocaleKeys.camera.tr()),
            onTap: onPressedOpenCamera,
            leading: const Icon(Icons.camera_alt, color: Colors.purple),
          ),
        ],
      ),
    );
  }
}

class CreatePostBottomButtonsBar extends StatelessWidget {
  final VoidCallback onPressedHideBottomButton;
  final VoidCallback onPressedOpenGallery;
  final VoidCallback onPressedOpenCamera;
  const CreatePostBottomButtonsBar({
    super.key,
    required this.onPressedHideBottomButton,
    required this.onPressedOpenGallery,
    required this.onPressedOpenCamera,
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
              IconButton(
                  onPressed: onPressedOpenCamera,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.purple,
                  )),
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
  final UserProfileModel user;
  const CretePostNameSection({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentUserProfile = ref.watch(userProfileFutureProvider);
    final otherUser = user;

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8, left: 16, right: 16),
      child: Row(
        children: [
          UserCirlePicture(
              imageUrl: otherUser.profilePicture,
              size: AppConstants.defaultNumericValue * 2.5),
          const SizedBox(width: 16),
          Expanded(
            child: Text(otherUser.fullName,
                style: Theme.of(context).textTheme.titleLarge!),
          ),
        ],
      ),
    );
  }
}
