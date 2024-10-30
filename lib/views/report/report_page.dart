// import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamatdating/generated/locale_keys.g.dart';

import 'package:lamatdating/constants.dart';
import 'package:lamatdating/helpers/media_picker_helper.dart';
import 'package:lamatdating/models/report_model.dart';
import 'package:lamatdating/models/user_profile_model.dart';
import 'package:lamatdating/providers/auth_providers.dart';
import 'package:lamatdating/providers/report_provider.dart';
import 'package:lamatdating/views/custom/custom_app_bar.dart';
import 'package:lamatdating/views/custom/custom_button.dart';
import 'package:lamatdating/views/custom/custom_headline.dart';
import 'package:lamatdating/views/custom/custom_icon_button.dart';
import 'package:lamatdating/views/tabs/live/widgets/user_circle_widg.dart';
import 'package:lamatdating/views/otherProfile/user_details_page.dart';

class ReportPage extends ConsumerStatefulWidget {
  final UserProfileModel userProfileModel;
  final Function? onBackFunc;
  const ReportPage({super.key, required this.userProfileModel, this.onBackFunc});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _imagesScrollcontroller = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final List<String> _imagePaths = [];

  void onTapAddImage() async {
    final image = await pickMedia();
    if (image == null) {
      return;
    } else {
      setState(() {
        _imagePaths.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(LocaleKeys.report.tr()),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultNumericValue),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultNumericValue),
                child: CustomAppBar(
                  leading: CustomIconButton(
                      icon: leftArrowSvg,
                      onPressed: () {
                        (widget.onBackFunc != null)
                            ? widget.onBackFunc
                            : Navigator.pop(context);
                      },
                      padding: const EdgeInsets.all(
                          AppConstants.defaultNumericValue / 1.8)),
                  title: Center(
                      child: CustomHeadLine(
                    text: LocaleKeys.reportUser.tr(),
                  )),
                  trailing: const SizedBox(
                      width: AppConstants.defaultNumericValue * 2),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Card(
                child: ListTile(
                  leading: UserCirlePicture(
                      imageUrl: widget.userProfileModel.profilePicture,
                      size: 35),
                  title: Text(widget.userProfileModel.fullName),
                ),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              TextFormField(
                controller: _reasonController,
                maxLines: 9,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: LocaleKeys.explainBriefly.tr(),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.defaultNumericValue),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return LocaleKeys.pleaseEnterDescription.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              Text(
                LocaleKeys.addImages.tr(),
                style:
                    const TextStyle(fontSize: AppConstants.defaultNumericValue),
              ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              _imagePaths.isEmpty
                  ? AddNewImageWidget(
                      onPressed: onTapAddImage,
                    )
                  : SingleChildScrollView(
                      controller: _imagesScrollcontroller,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _imagePaths.map((imagePath) {
                          return Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height:
                                        MediaQuery.of(context).size.width * 0.5,
                                    margin: const EdgeInsets.only(
                                        right:
                                            AppConstants.defaultNumericValue),
                                    child: CachedNetworkImage(
                                      imageUrl: imagePath,
                                      placeholder: (context, url) =>
                                          const Center(
                                              child: CircularProgressIndicator
                                                  .adaptive()),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                              child:
                                                  Icon(CupertinoIcons.photo)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CupertinoButton(
                                      padding: const EdgeInsets.all(0),
                                      color: Colors.red,
                                      child: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _imagePaths.remove(imagePath);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (_imagePaths.indexOf(imagePath) ==
                                  _imagePaths.length - 1)
                                const SizedBox(
                                    width: AppConstants.defaultNumericValue),
                              if (_imagePaths.indexOf(imagePath) ==
                                  _imagePaths.length - 1)
                                AddNewImageWidget(
                                  onPressed: onTapAddImage,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: AppConstants.defaultNumericValue),
              CustomButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final ReportModel reportModel = ReportModel(
                      id: "${widget.userProfileModel.phoneNumber}report${DateTime.now().millisecondsSinceEpoch}",
                      createdAt: DateTime.now(),
                      images: _imagePaths,
                      reason: _reasonController.text,
                      reportedByUserId:
                          ref.watch(currentUserStateProvider)!.phoneNumber!,
                      reportingUserId: widget.userProfileModel.phoneNumber,
                    );

                    EasyLoading.show(status: LocaleKeys.sending.tr());
                    await reportUser(reportModel).then((value) {
                      EasyLoading.dismiss();
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(LocaleKeys.reportSent.tr()),
                              content: Text("${LocaleKeys.blockUser.tr()}?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(LocaleKeys.no.tr())),
                                TextButton(
                                    onPressed: () async {
                                      await showBlockDialog(
                                              context,
                                              widget
                                                  .userProfileModel.phoneNumber,
                                              ref
                                                  .watch(
                                                      currentUserStateProvider)!
                                                  .phoneNumber!)
                                          .then((value) {
                                        Navigator.pop(context);
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: Text(LocaleKeys.yes.tr())),
                              ],
                            );
                          });
                    });
                  }
                },
                text: LocaleKeys.submit.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddNewImageWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const AddNewImageWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(AppConstants.defaultNumericValue),
        ),
        child: const Center(child: Icon(Icons.add)),
      ),
    );
  }
}
